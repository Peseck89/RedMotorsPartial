public without sharing class AccountVisitStatusScheduler
    implements Schedulable, Database.Batchable<SObject> {

    private static final String FIELD_STATUS = 'CPEstatus_visita_al_taller__c';

    private static final Integer DEFAULT_SCOPE_SIZE = 50;

    @TestVisible static Date TODAY_OVERRIDE;

    public void execute(SchedulableContext sc) {
        runNow(DEFAULT_SCOPE_SIZE);
    }

    public static void runNow() {
        runNow(DEFAULT_SCOPE_SIZE);
    }

    public static void runNow(Integer scopeSize) {
        Integer s = VisitStatusSchedulerBase.normalizeScopeSize(scopeSize, DEFAULT_SCOPE_SIZE);

        if (Test.isRunningTest()) {
            runInline(s);
            return;
        }

        Database.executeBatch(new AccountVisitStatusScheduler(), s);
    }

    public static void runNow(Integer scopeSize, Integer modeIgnored) {
        runNow(scopeSize);
    }

    public static void run() {
        runNow();
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, ' + FIELD_STATUS + ' FROM Account');
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        process((List<Account>)scope);
    }

    public void finish(Database.BatchableContext bc) {
    }

    private static void runInline(Integer scopeSize) {
        Integer s = VisitStatusSchedulerBase.normalizeScopeSize(scopeSize, DEFAULT_SCOPE_SIZE);

        List<Account> accs = Database.query('SELECT Id, ' + FIELD_STATUS + ' FROM Account');
        if (accs.isEmpty()) return;

        for (Integer i = 0; i < accs.size(); i += s) {
            Integer endIdx = Math.min(i + s, accs.size());
            List<Account> chunk = new List<Account>();
            for (Integer j = i; j < endIdx; j++) {
                chunk.add(accs[j]);
            }
            process(chunk);
        }
    }

    private static void process(List<Account> accounts) {
        if (accounts == null || accounts.isEmpty()) return;

        Date today = getToday();

        Set<Id> accountIds = new Set<Id>();
        for (Account a : accounts) accountIds.add(a.Id);

        Map<Id, Id> contactToAccount = new Map<Id, Id>();
        for (Contact c : [
            SELECT Id, AccountId
            FROM Contact
            WHERE AccountId IN :accountIds
        ]) {
            if (c.AccountId != null) contactToAccount.put(c.Id, c.AccountId);
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

        Map<Id, Date> lastAssetDateByAccount = new Map<Id, Date>();
        for (AggregateResult ar : [
            SELECT AccountId a, MAX(fecha_facturacion_vehiculo__c) md
            FROM Asset
            WHERE AccountId IN :accountIds
              AND fecha_facturacion_vehiculo__c != null
            GROUP BY AccountId
        ]) {
            Id accId = (Id) ar.get('a');
            Date maxDate = (Date) ar.get('md');
            if (accId != null && maxDate != null) {
                lastAssetDateByAccount.put(accId, maxDate);
            }
        }

        List<Account> updates = new List<Account>();

        for (Account a : accounts) {
            String currentStatus = (String) a.get(FIELD_STATUS);
            String newStatus;

            if (lastEventDateByAccount.containsKey(a.Id)) {
                Integer months = VisitStatusSchedulerBase.fullMonthsBetween(lastEventDateByAccount.get(a.Id), today);
                newStatus = VisitStatusSchedulerBase.statusFromWorkshopVisitMonths(months);
            } else if (lastAssetDateByAccount.containsKey(a.Id)) {
                Integer months = VisitStatusSchedulerBase.fullMonthsBetween(lastAssetDateByAccount.get(a.Id), today);
                newStatus = VisitStatusSchedulerBase.statusFromVehicleAgeMonths(months);
            } else {
                newStatus = null;
            }

            if (newStatus != currentStatus) {
                Account upd = new Account(Id = a.Id);
                upd.put(FIELD_STATUS, newStatus);
                updates.add(upd);
            }
        }

        if (!updates.isEmpty()) {
            Database.update(updates, false);
        }
    }

    private static Date getToday() {
        return VisitStatusSchedulerBase.resolveToday(TODAY_OVERRIDE);
    }
}
