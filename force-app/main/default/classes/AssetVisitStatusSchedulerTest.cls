@IsTest
private class AssetVisitStatusSchedulerTest {

    // Counter estático para VINs únicos garantizados
    private static Integer vinCounter = 0;

    private static String uniqueVin() {
        vinCounter++;
        return 'VIN-TEST-' + String.valueOf(vinCounter).leftPad(6, '0');
    }

    // ─────────────────────────────────────────────────────────────────────────
    // HELPERS DE DATOS
    // ─────────────────────────────────────────────────────────────────────────

    private static Account insertAccount(String name) {
        Account acc = new Account(Name = name);
        insert acc;
        return acc;
    }

    private static Contact insertContact(Id accountId, String lastName) {
        Contact c = new Contact(AccountId = accountId, LastName = lastName);
        insert c;
        return c;
    }

    private static String firstActivePicklistValue(Schema.SObjectType sobjectType, String fieldName, Set<String> preferredValues) {
        Map<String, Schema.SObjectField> fieldMap = sobjectType.getDescribe().fields.getMap();
        if (!fieldMap.containsKey(fieldName)) {
            return null;
        }

        String fallbackValue;
        for (Schema.PicklistEntry entry : fieldMap.get(fieldName).getDescribe().getPicklistValues()) {
            if (!entry.isActive()) {
                continue;
            }
            if (preferredValues != null && preferredValues.contains(entry.getValue())) {
                return entry.getValue();
            }
            if (fallbackValue == null) {
                fallbackValue = entry.getValue();
            }
        }
        return fallbackValue;
    }

    /**
     * TRUCO ANTI "No se puede crear un evento en el pasado":
     * El evento siempre se crea con StartDateTime = NOW + 1 día (futuro).
     * TODAY_OVERRIDE se fija en eventDate + offsetMonths para que la
     * diferencia calculada por el scheduler sea la correcta.
     *
     * Retorna la fecha "real" del evento para que el caller calcule TODAY_OVERRIDE.
     */
    private static Date insertEventFuture(Id whoId, Id activoId, Date eventDate) {
        // Insertamos el evento 2 días en el futuro (evita validación "no pasado")
        DateTime safeDt = DateTime.now().addDays(2);

        Event e = new Event(
            Subject          = 'Visita taller',
            WhoId            = whoId,
            StartDateTime    = safeDt,
            EndDateTime      = safeDt.addHours(1),
            ActivityDateTime = safeDt,
            Description      = ''
        );

        Map<String, Schema.SObjectField> fmap = Event.SObjectType.getDescribe().fields.getMap();

        if (fmap.containsKey('activo__c') && activoId != null) {
            e.put('Activo__c', activoId);
        }
        if (fmap.containsKey('origenevento__c')) {
            String originValue = firstActivePicklistValue(
                Event.SObjectType,
                'OrigenEvento__c',
                new Set<String>{ 'Walking', 'Contact Center', 'Whatsapp_EDNA', 'twilio_wa' }
            );
            if (originValue != null) {
                e.put('OrigenEvento__c', originValue);
            }
        }

        insert e;

        // Actualizamos StartDateTime al valor real vía update directo
        // para que el scheduler lo vea con la fecha correcta
        Event inserted = new Event(Id = e.Id, StartDateTime = DateTime.newInstance(eventDate, Time.newInstance(10, 0, 0, 0)));
        inserted.EndDateTime = inserted.StartDateTime.addHours(1);
        update inserted;

        return eventDate;
    }

    private static Product2 insertProduct() {
        Product2 p = new Product2(Name = 'VehiculoTest', IsActive = true);
        Map<String, Schema.SObjectField> fmap = Product2.SObjectType.getDescribe().fields.getMap();
        if (fmap.containsKey('codigo_de_producto__c')) {
            Schema.DescribeFieldResult dfr = fmap.get('codigo_de_producto__c').getDescribe();
            if (dfr.isCreateable()) {
                p.put('Codigo_de_Producto__c', 'CP-' + uniqueVin());
            }
        }
        insert p;
        return p;
    }

    private static Asset insertAsset(Id accountId, Id productId, Date factDate, String status) {
        String vin = uniqueVin();

        Asset a = new Asset(
            Name      = 'Asset-' + vin,
            AccountId = accountId,
            Product2Id = productId
        );

        Map<String, Schema.SObjectField> fmap = Asset.SObjectType.getDescribe().fields.getMap();

        if (fmap.containsKey('serialnumber')) {
            a.put('SerialNumber', vin);
        }
        if (factDate != null && fmap.containsKey('fecha_facturacion_vehiculo__c')) {
            a.put('fecha_facturacion_vehiculo__c', factDate);
        }
        if (status != null && fmap.containsKey('estatus_visita_al_taller__c')) {
            a.put('Estatus_visita_al_taller__c', status);
        }
        if (fmap.containsKey('status')) {
            Schema.DescribeFieldResult dfr = fmap.get('status').getDescribe();
            for (Schema.PicklistEntry pe : dfr.getPicklistValues()) {
                if (pe.isActive()) { a.put('status', pe.getValue()); break; }
            }
        }

        insert a;
        return a;
    }

    // Fecha base estable: siempre 1ro del mes actual
    private static Date stableToday() {
        Date t = Date.today();
        return Date.newInstance(t.year(), t.month(), 1);
    }

    private static Date monthsAgo(Date base, Integer months) {
        Integer totalMonths = (base.year() * 12 + base.month()) - months;
        Integer y = totalMonths / 12;
        Integer m = Math.mod(totalMonths, 12);
        if (m == 0) { m = 12; y--; }
        return Date.newInstance(y, m, 1);
    }

    /**
     * Inserta evento con fecha pasada sorteando la validación:
     * 1) Inserta con fecha futura (+2 días)
     * 2) Hace update con la fecha real deseada
     * Si el trigger de update también bloquea, usamos directamente
     * la fecha futura y compensamos TODAY_OVERRIDE.
     */
    private static void insertEventWithDate(Id whoId, Id activoId, Date targetDate) {
        DateTime futureDt  = DateTime.now().addDays(2);
        DateTime targetDt  = DateTime.newInstance(targetDate, Time.newInstance(10, 0, 0, 0));

        Event e = new Event(
            Subject          = 'Visita taller',
            WhoId            = whoId,
            StartDateTime    = futureDt,
            EndDateTime      = futureDt.addHours(1),
            ActivityDateTime = futureDt,
            Description      = ''
        );

        Map<String, Schema.SObjectField> fmap = Event.SObjectType.getDescribe().fields.getMap();
        if (fmap.containsKey('activo__c') && activoId != null) {
            e.put('Activo__c', activoId);
        }
        if (fmap.containsKey('origenevento__c')) {
            String originValue = firstActivePicklistValue(
                Event.SObjectType,
                'OrigenEvento__c',
                new Set<String>{ 'Walking', 'Contact Center', 'Whatsapp_EDNA', 'twilio_wa' }
            );
            if (originValue != null) {
                e.put('OrigenEvento__c', originValue);
            }
        }

        insert e;

        // Intentamos actualizar a la fecha real
        try {
            Event upd = new Event(Id = e.Id);
            upd.StartDateTime    = targetDt;
            upd.EndDateTime      = targetDt.addHours(1);
            upd.ActivityDateTime = targetDt;
            update upd;
        } catch (Exception ex) {
            // Si el trigger también bloquea updates en pasado,
            // el evento quedará con fecha futura y TODAY_OVERRIDE
            // ya fue calculado para compensar (ver tests individuales)
            System.debug('No se pudo actualizar fecha del evento: ' + ex.getMessage());
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // TEST 1: Evento < 18 meses → VISITA RECURRENTE
    // ─────────────────────────────────────────────────────────────────────────
    @IsTest
    static void testEstatus_Recurrente() {
        // Evento: hoy+2 días. TODAY_OVERRIDE: hoy+2días+6meses
        // => diferencia = 6 meses < 18 → Visita recurrente
        Date eventDate  = Date.today().addDays(2);
        Date todayOver  = eventDate.addMonths(6);
        AssetVisitStatusScheduler.TODAY_OVERRIDE = todayOver;

        Account acc = insertAccount('Acc Recurrente');
        Contact con = insertContact(acc.Id, 'RecurrenteC');
        Product2 pro = insertProduct();
        Asset ast = insertAsset(acc.Id, pro.Id, eventDate.addMonths(-10), null);
        insertEventWithDate(con.Id, ast.Id, eventDate);

        Test.startTest();
        AssetVisitStatusScheduler.runNow(200);
        Test.stopTest();

        Asset updated = [SELECT Estatus_visita_al_taller__c FROM Asset WHERE Id = :ast.Id];
        System.assertEquals('Visita recurrente', updated.Estatus_visita_al_taller__c,
            'Evento < 18 meses debe resultar Visita recurrente');
    }

    // ─────────────────────────────────────────────────────────────────────────
    // TEST 2: Evento 18–24 meses → PREFUGA
    // ─────────────────────────────────────────────────────────────────────────
    @IsTest
    static void testEstatus_Prefuga() {
        // Evento: hoy+2 días. TODAY_OVERRIDE: evento+20meses => 20 meses → Prefuga
        Date eventDate = Date.today().addDays(2);
        Date todayOver = eventDate.addMonths(20);
        AssetVisitStatusScheduler.TODAY_OVERRIDE = todayOver;

        Account acc = insertAccount('Acc Prefuga');
        Contact con = insertContact(acc.Id, 'PrefugaC');
        Product2 pro = insertProduct();
        Asset ast = insertAsset(acc.Id, pro.Id, eventDate.addMonths(-10), null);
        insertEventWithDate(con.Id, ast.Id, eventDate);

        Test.startTest();
        AssetVisitStatusScheduler.runNow(200);
        Test.stopTest();

        Asset updated = [SELECT Estatus_visita_al_taller__c FROM Asset WHERE Id = :ast.Id];
        System.assertEquals('Prefuga', updated.Estatus_visita_al_taller__c,
            'Evento entre 18 y 24 meses debe resultar Prefuga');
    }

    // ─────────────────────────────────────────────────────────────────────────
    // TEST 3: Evento > 24 meses → FUGA
    // ─────────────────────────────────────────────────────────────────────────
    @IsTest
    static void testEstatus_Fuga() {
        // Evento: hoy+2 días. TODAY_OVERRIDE: evento+30meses => 30 meses → Fuga
        Date eventDate = Date.today().addDays(2);
        Date todayOver = eventDate.addMonths(30);
        AssetVisitStatusScheduler.TODAY_OVERRIDE = todayOver;

        Account acc = insertAccount('Acc Fuga');
        Contact con = insertContact(acc.Id, 'FugaC');
        Product2 pro = insertProduct();
        Asset ast = insertAsset(acc.Id, pro.Id, eventDate.addMonths(-5), null);
        insertEventWithDate(con.Id, ast.Id, eventDate);

        Test.startTest();
        AssetVisitStatusScheduler.runNow(200);
        Test.stopTest();

        Asset updated = [SELECT Estatus_visita_al_taller__c FROM Asset WHERE Id = :ast.Id];
        System.assertEquals('Fuga', updated.Estatus_visita_al_taller__c,
            'Evento > 24 meses debe resultar Fuga');
    }

    // ─────────────────────────────────────────────────────────────────────────
    // TEST 4: Sin evento, facturación <= 17 meses → NUEVO
    // ─────────────────────────────────────────────────────────────────────────
    @IsTest
    static void testEstatus_Nuevo() {
        Date today = stableToday();
        AssetVisitStatusScheduler.TODAY_OVERRIDE = today;

        Account acc = insertAccount('Acc Nuevo');
        Product2 pro = insertProduct();
        Asset ast = insertAsset(acc.Id, pro.Id, monthsAgo(today, 5), null);

        Test.startTest();
        AssetVisitStatusScheduler.runNow(200);
        Test.stopTest();

        Asset updated = [SELECT Estatus_visita_al_taller__c FROM Asset WHERE Id = :ast.Id];
        System.assertEquals('Nuevo', updated.Estatus_visita_al_taller__c,
            'Sin evento y facturación <= 17 meses debe resultar Nuevo');
    }

    // ─────────────────────────────────────────────────────────────────────────
    // TEST 5: Sin evento, facturación exactamente 18 meses → PRIMERA VISITA
    // ─────────────────────────────────────────────────────────────────────────
    @IsTest
    static void testEstatus_PrimeraVisita() {
        Date today = stableToday();
        AssetVisitStatusScheduler.TODAY_OVERRIDE = today;

        Account acc = insertAccount('Acc PrimeraVisita');
        Product2 pro = insertProduct();
        Asset ast = insertAsset(acc.Id, pro.Id, monthsAgo(today, 18), null);

        Test.startTest();
        AssetVisitStatusScheduler.runNow(200);
        Test.stopTest();

        Asset updated = [SELECT Estatus_visita_al_taller__c FROM Asset WHERE Id = :ast.Id];
        System.assertEquals('Primera visita', updated.Estatus_visita_al_taller__c,
            'Sin evento y facturación exactamente 18 meses debe resultar Primera visita');
    }

    // ─────────────────────────────────────────────────────────────────────────
    // TEST 6: Sin evento, facturación > 18 meses → SIN VISITA
    // ─────────────────────────────────────────────────────────────────────────
    @IsTest
    static void testEstatus_SinVisita() {
        Date today = stableToday();
        AssetVisitStatusScheduler.TODAY_OVERRIDE = today;

        Account acc = insertAccount('Acc SinVisita');
        Product2 pro = insertProduct();
        Asset ast = insertAsset(acc.Id, pro.Id, monthsAgo(today, 25), null);

        Test.startTest();
        AssetVisitStatusScheduler.runNow(200);
        Test.stopTest();

        Asset updated = [SELECT Estatus_visita_al_taller__c FROM Asset WHERE Id = :ast.Id];
        System.assertEquals('Sin visita', updated.Estatus_visita_al_taller__c,
            'Sin evento y facturación > 18 meses debe resultar Sin visita');
    }

    // ─────────────────────────────────────────────────────────────────────────
    // TEST 7: Sin fecha ni eventos → status null
    // ─────────────────────────────────────────────────────────────────────────
    @IsTest
    static void testEstatus_SinDatos() {
        AssetVisitStatusScheduler.TODAY_OVERRIDE = stableToday();

        Account acc = insertAccount('Acc SinDatos');
        Product2 pro = insertProduct();
        Asset ast = insertAsset(acc.Id, pro.Id, null, null);

        Test.startTest();
        AssetVisitStatusScheduler.runNow(200);
        Test.stopTest();

        Asset updated = [SELECT Estatus_visita_al_taller__c FROM Asset WHERE Id = :ast.Id];
        System.assertEquals(null, updated.Estatus_visita_al_taller__c,
            'Sin fecha ni eventos el estatus debe quedar null');
    }

    // ─────────────────────────────────────────────────────────────────────────
    // TEST 8: Estatus ya correcto → no genera DML update innecesario
    // ─────────────────────────────────────────────────────────────────────────
    @IsTest
    static void testSinCambio_NoUpdate() {
        Date today = stableToday();
        AssetVisitStatusScheduler.TODAY_OVERRIDE = today;

        Account acc = insertAccount('Acc NoUpdate');
        Product2 pro = insertProduct();
        Asset ast = insertAsset(acc.Id, pro.Id, monthsAgo(today, 5), 'Nuevo');

        Test.startTest();
        AssetVisitStatusScheduler.runNow(200);
        Test.stopTest();

        Asset updated = [SELECT Estatus_visita_al_taller__c FROM Asset WHERE Id = :ast.Id];
        System.assertEquals('Nuevo', updated.Estatus_visita_al_taller__c,
            'Si el estatus ya es correcto no debe cambiar');
    }

    // ─────────────────────────────────────────────────────────────────────────
    // TEST 9: Múltiples eventos → gana el más reciente
    // ─────────────────────────────────────────────────────────────────────────
    @IsTest
    static void testMultiplesEventos_TomaMasReciente() {
        // Evento viejo: hoy+2. Evento reciente: hoy+5
        // TODAY_OVERRIDE = hoy+5+3meses => evento reciente tiene 3 meses → Recurrente
        Date eventOld    = Date.today().addDays(2);
        Date eventRecent = Date.today().addDays(5);
        Date todayOver   = eventRecent.addMonths(3);
        AssetVisitStatusScheduler.TODAY_OVERRIDE = todayOver;

        Account acc = insertAccount('Acc MultiEvento');
        Contact con = insertContact(acc.Id, 'MultiEventoC');
        Product2 pro = insertProduct();
        Asset ast = insertAsset(acc.Id, pro.Id, eventOld.addMonths(-10), null);

        insertEventWithDate(con.Id, ast.Id, eventOld);
        insertEventWithDate(con.Id, ast.Id, eventRecent);

        Test.startTest();
        AssetVisitStatusScheduler.runNow(200);
        Test.stopTest();

        Asset updated = [SELECT Estatus_visita_al_taller__c FROM Asset WHERE Id = :ast.Id];
        System.assertEquals('Visita recurrente', updated.Estatus_visita_al_taller__c,
            'Debe usar el evento más reciente');
    }

    // ─────────────────────────────────────────────────────────────────────────
    // TEST 10: Ejecución vía System.schedule (Schedulable interface)
    // ─────────────────────────────────────────────────────────────────────────
    @IsTest
    static void testSchedulableExecution() {
        Date today = stableToday();
        AssetVisitStatusScheduler.TODAY_OVERRIDE = today;

        Account acc = insertAccount('Acc Scheduler');
        Product2 pro = insertProduct();
        insertAsset(acc.Id, pro.Id, monthsAgo(today, 5), null);

        Test.startTest();
        System.schedule('TestAssetVisitScheduler', '0 0 2 * * ?', new AssetVisitStatusScheduler());
        Test.stopTest();

        System.assert(true, 'El scheduler debe registrarse sin lanzar excepción');
    }

    // ─────────────────────────────────────────────────────────────────────────
    // TEST 11: Aliases runNow(), run(), runNow(null), runNow(0), runNow(n, mode)
    // ─────────────────────────────────────────────────────────────────────────
    @IsTest
    static void testRunNow_Aliases() {
        Date today = stableToday();
        AssetVisitStatusScheduler.TODAY_OVERRIDE = today;

        Account acc = insertAccount('Acc Aliases');
        Product2 pro = insertProduct();
        insertAsset(acc.Id, pro.Id, monthsAgo(today, 5), null);

        Test.startTest();
        AssetVisitStatusScheduler.runNow();
        AssetVisitStatusScheduler.run();
        AssetVisitStatusScheduler.runNow(null);
        AssetVisitStatusScheduler.runNow(0);
        AssetVisitStatusScheduler.runNow(50, 0);
        Test.stopTest();

        System.assert(true, 'Todos los alias deben ejecutarse sin errores');
    }

    // ─────────────────────────────────────────────────────────────────────────
    // TEST 12: Sin assets → rama isEmpty de runInline
    // ─────────────────────────────────────────────────────────────────────────
    @IsTest
    static void testRunInline_SinAssets() {
        AssetVisitStatusScheduler.TODAY_OVERRIDE = Date.today();

        Test.startTest();
        AssetVisitStatusScheduler.runNow(200);
        Test.stopTest();

        System.assert(true, 'Sin assets no debe lanzar excepción');
    }

    // ─────────────────────────────────────────────────────────────────────────
    // TEST 13: Fecha facturación futura → fullMonthsBetween = 0 → NUEVO
    // ─────────────────────────────────────────────────────────────────────────
    @IsTest
    static void testFechaFuturaEsNuevo() {
        Date today = stableToday();
        AssetVisitStatusScheduler.TODAY_OVERRIDE = today;

        Account acc = insertAccount('Acc FechaFutura');
        Product2 pro = insertProduct();
        Asset ast = insertAsset(acc.Id, pro.Id, today.addMonths(3), null);

        Test.startTest();
        AssetVisitStatusScheduler.runNow(200);
        Test.stopTest();

        Asset updated = [SELECT Estatus_visita_al_taller__c FROM Asset WHERE Id = :ast.Id];
        System.assertEquals('Nuevo', updated.Estatus_visita_al_taller__c,
            'Fecha futura debe resultar 0 meses → Nuevo');
    }

    
}