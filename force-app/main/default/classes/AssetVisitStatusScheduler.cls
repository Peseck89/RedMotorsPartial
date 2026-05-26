public without sharing class AssetVisitStatusScheduler
    implements Schedulable, Database.Batchable<SObject>, Database.Stateful {

    private static final String FIELD_STATUS = 'Estatus_visita_al_taller__c';

    private static final Integer DEFAULT_SCOPE_SIZE = 50;

    @TestVisible static Date TODAY_OVERRIDE;

    // Para debug de fallos
    private Integer okCount = 0;
    private Integer failCount = 0;
    private List<String> failSamples = new List<String>();

    public void execute(SchedulableContext sc) {
        runNow(DEFAULT_SCOPE_SIZE);
    }

    public static void runNow() { runNow(DEFAULT_SCOPE_SIZE); }

    public static void runNow(Integer scopeSize) {
        Integer s = VisitStatusSchedulerBase.normalizeScopeSize(scopeSize, DEFAULT_SCOPE_SIZE);

        if (Test.isRunningTest()) {
            runInline(s);
            return;
        }
        Database.executeBatch(new AssetVisitStatusScheduler(), s);
    }

    public static void runNow(Integer scopeSize, Integer modeIgnored) { runNow(scopeSize); }
    public static void run() { runNow(); }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, AccountId, ' + FIELD_STATUS + ', fecha_facturacion_vehiculo__c ' +
            'FROM Asset'
        );
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        process((List<Asset>)scope);
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('AssetVisitStatusScheduler FINISH -> OK=' + okCount + ', FAIL=' + failCount);
        for (String s : failSamples) System.debug('FAIL SAMPLE -> ' + s);
    }

    private static void runInline(Integer scopeSize) {
        Integer s = VisitStatusSchedulerBase.normalizeScopeSize(scopeSize, DEFAULT_SCOPE_SIZE);

        List<Asset> assets = Database.query(
            'SELECT Id, AccountId, ' + FIELD_STATUS + ', fecha_facturacion_vehiculo__c ' +
            'FROM Asset'
        );
        if (assets.isEmpty()) return;

        // ✅ FIX: process() es de instancia, así que lo llamamos con un objeto
        AssetVisitStatusScheduler runner = new AssetVisitStatusScheduler();

        for (Integer i = 0; i < assets.size(); i += s) {
            Integer endIdx = Math.min(i + s, assets.size());
            List<Asset> chunk = new List<Asset>();
            for (Integer j = i; j < endIdx; j++) chunk.add(assets[j]);
            runner.process(chunk);
        }
    }

    private void process(List<Asset> assets) {
        if (assets == null || assets.isEmpty()) return;

        Date today = getToday();

        Set<Id> accountIds = new Set<Id>();
        for (Asset a : assets) {
            if (a.AccountId != null) accountIds.add(a.AccountId);
        }

        // 1) Eventos por Contacto -> Account (igual que la clase de Cuenta)
        Map<Id, Id> contactToAccount = new Map<Id, Id>();
        if (!accountIds.isEmpty()) {
            for (Contact c : [
                SELECT Id, AccountId
                FROM Contact
                WHERE AccountId IN :accountIds
            ]) {
                if (c.AccountId != null) contactToAccount.put(c.Id, c.AccountId);
            }
        }

        Map<Id, Date> lastEventDateByAccount = new Map<Id, Date>();
        if (!contactToAccount.isEmpty()) {
            for (AggregateResult ar : [
                SELECT WhoId w, MAX(StartDateTime) ms
                FROM Event
                WHERE WhoId IN :contactToAccount.keySet()
                  AND StartDateTime != null
                GROUP BY WhoId
            ]) {
                Id contactId = (Id) ar.get('w');
                Datetime maxDt = (Datetime) ar.get('ms');
                if (contactId == null || maxDt == null) continue;

                Id accId = contactToAccount.get(contactId);
                if (accId == null) continue;

                Date maxDate = maxDt.date();
                Date existing = lastEventDateByAccount.get(accId);
                if (existing == null || maxDate > existing) {
                    lastEventDateByAccount.put(accId, maxDate);
                }
            }
        }

        // 2) Calcular estatus por Asset
        List<Asset> updates = new List<Asset>();

        for (Asset a : assets) {
            String currentStatus = (String) a.get(FIELD_STATUS);
            String newStatus;

            if (a.AccountId != null && lastEventDateByAccount.containsKey(a.AccountId)) {
                Integer months = VisitStatusSchedulerBase.fullMonthsBetween(lastEventDateByAccount.get(a.AccountId), today);
                newStatus = VisitStatusSchedulerBase.statusFromWorkshopVisitMonths(months);

            } else if (a.fecha_facturacion_vehiculo__c != null) {
                Integer months = VisitStatusSchedulerBase.fullMonthsBetween(a.fecha_facturacion_vehiculo__c, today);
                newStatus = VisitStatusSchedulerBase.statusFromVehicleAgeMonths(months);

            } else {
                newStatus = null;
                // Si quieres forzar: newStatus = ST_NUEVO;
            }

            if (newStatus != currentStatus) {
                Asset upd = new Asset(Id = a.Id);
                upd.put(FIELD_STATUS, newStatus);
                updates.add(upd);
            }
        }

        if (!updates.isEmpty()) {
            Database.SaveResult[] sr = Database.update(updates, false);
            for (Integer i = 0; i < sr.size(); i++) {
                if (sr[i].isSuccess()) {
                    okCount++;
                } else {
                    failCount++;
                    if (failSamples.size() < 20) {
                        String msg = sr[i].getErrors()[0].getMessage();
                        failSamples.add('AssetId=' + updates[i].Id + ' -> ' + msg);
                    }
                }
            }
        }
    }

    private static Date getToday() {
        return VisitStatusSchedulerBase.resolveToday(TODAY_OVERRIDE);
    }
}
