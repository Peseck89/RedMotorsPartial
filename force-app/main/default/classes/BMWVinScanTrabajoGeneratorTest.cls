@IsTest
private class BMWVinScanTrabajoGeneratorTest {

    public class DummyWsMock implements WebServiceMock {
        public void doInvoke(Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNamespace, String responseName, String responseType
        ) { response.put(responseName, null); }
    }

    public class DummyHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200); res.setBody('{}');
            return res;
        }
    }

    @testSetup
    static void setup() {
        Test.setMock(WebServiceMock.class, new DummyWsMock());
        Test.setMock(HttpCalloutMock.class, new DummyHttpMock());

        List<String> triggerNames = new List<String>{
            'WorkOrderTrigger',
            'WorkOrderLineItemTrigger',
            'WorkOrder_AutoUnlock',
            'WorkOrderCreationTrigger',
            'WorkStepTrigger',
            'WorkOrder', 'workorder',
            'WorkOrderLineItem', 'WOLITrigger', 'WOTrigger',
            'aprobacion de descuentos',
            'OpportunityLineItem', 'QuoteLineItem',
            'SuministrosTrigger', 'WoliSuministros', 'Suministros'
        };

        List<Trigger_control__c> allControls = [SELECT Id, Turned_off__c FROM Trigger_control__c];
        List<Trigger_control__c> toUpdate = new List<Trigger_control__c>();
        for (Trigger_control__c tc : allControls) {
            if (!tc.Turned_off__c) {
                tc.Turned_off__c = true;
                toUpdate.add(tc);
            }
        }
        if (!toUpdate.isEmpty()) update toUpdate;

        Set<String> existingNames = new Set<String>();
        for (Trigger_control__c tc : [SELECT Name FROM Trigger_control__c]) {
            existingNames.add(tc.Name.toLowerCase());
        }
        List<Trigger_control__c> toInsert = new List<Trigger_control__c>();
        for (String name : triggerNames) {
            if (!existingNames.contains(name.toLowerCase())) {
                toInsert.add(new Trigger_control__c(Name = name, Turned_off__c = true));
            }
        }
        if (!toInsert.isEmpty()) insert toInsert;

        Account a = new Account(Name = 'ACC');
        insert a;

        Product2 mano = new Product2(
            Name = 'Mano de Obra', IsActive = true,
            tipoProducto__c = 'Mano de Obra', Codigo_de_Producto__c = 'MO23'
        );
        insert mano;

        Product2 sumi = new Product2(
            Name = 'Suministros', IsActive = true,
            tipoProducto__c = 'Mano de Obra', Codigo_de_Producto__c = 'SUMI'
        );
        insert sumi;

        Id stdPbId = Test.getStandardPricebookId();
        ensurePricebookActive(stdPbId);

        Id pbBavarianDolar = getOrCreatePricebook('Bavarian Dólar');
        Id pbBavarianLocal = getOrCreatePricebook('Bavarian Local');
        Id pbOtobaiDolar   = getOrCreatePricebook('Otobai Dólares');
        Id pbOtobaiLocal   = getOrCreatePricebook('Otobai Local');

        upsertPbe(stdPbId,       mano.Id, 100);
        upsertPbe(stdPbId,       sumi.Id, 50);
        
        upsertPbe(pbBavarianDolar, mano.Id, 100);
        upsertPbe(pbBavarianDolar, sumi.Id, 50);
        upsertPbe(pbBavarianLocal, mano.Id, 100);
        upsertPbe(pbBavarianLocal, sumi.Id, 50);
        upsertPbe(pbOtobaiDolar,   mano.Id, 100);
        upsertPbe(pbOtobaiDolar,   sumi.Id, 50);
        upsertPbe(pbOtobaiLocal,   mano.Id, 100);
        upsertPbe(pbOtobaiLocal,   sumi.Id, 50);

        Set<Id> pbsYaCubiertos = new Set<Id>{
            stdPbId, pbBavarianDolar, pbBavarianLocal, pbOtobaiDolar, pbOtobaiLocal
        };
        for (Pricebook2 pb : [SELECT Id FROM Pricebook2 WHERE IsActive = true AND Id NOT IN :pbsYaCubiertos]) {
            upsertPbe(pb.Id, mano.Id, 100);
            upsertPbe(pb.Id, sumi.Id, 50);
        }

        Asset ast = new Asset(Name = 'AST', AccountId = a.Id, Tipo_de_veh_culo__c = 'Automóvil');
        insert ast;

        Case c = new Case(AccountId = a.Id, AssetId = ast.Id, Subject = 'CASE',
            Status = pickVal(Case.Status), Origin = pickVal(Case.Origin));
        insert c;

        WorkType wt = new WorkType(Name = 'WT', EstimatedDuration = 120);
        insert wt;

        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        currentUser.Crear_suministros_OT__c = false;
        update currentUser;

        tiposDeTrabajo__c tipoSumi = new tiposDeTrabajo__c(
            Name = 'Suministros', Identificador__c = 'SUMI-000', ManoDeObra__c = mano.Id
        );
        insert tipoSumi;

        WorkOrder wo = new WorkOrder(
            AccountId = a.Id, CaseId = c.Id, Subject = 'WO',
            Status = pickVal(WorkOrder.Status), Priority = pickVal(WorkOrder.Priority),
            Pricebook2Id = stdPbId, empresaFactura__c = 'RMBAVARIAN', WorkTypeId = wt.Id
        );
        insert wo;

        wo = [SELECT Id, Pricebook2Id FROM WorkOrder WHERE Id = :wo.Id LIMIT 1];

        if (wo.Pricebook2Id == null) {
            update new WorkOrder(Id = wo.Id, Pricebook2Id = stdPbId);
            wo.Pricebook2Id = stdPbId;
        }

        upsertPbe(wo.Pricebook2Id, mano.Id, 100);
        upsertPbe(wo.Pricebook2Id, sumi.Id, 50);

        Impuesto__c imp = new Impuesto__c(Name = '0108', codigoImpuesto__c = '0108');
        insert imp;

        TipoDeCargoConManoDeObra__c tc = new TipoDeCargoConManoDeObra__c(
            Empresa__c = 'RMBAVARIAN', TipoDeCargo__c = 'Cliente',
            TipoDeVehiculo__c = 'Automóvil', ManoDeObra__c = mano.Id
        );
        insert tc;

        insert new List<tiposDeTrabajo__c>{
            new tiposDeTrabajo__c(Name='Servicio 0000105', Identificador__c='0000105', ManoDeObra__c=mano.Id),
            new tiposDeTrabajo__c(Name='Servicio 0000612', Identificador__c='0000612', ManoDeObra__c=mano.Id),
            new tiposDeTrabajo__c(Name='Servicio 0000618', Identificador__c='0000618', ManoDeObra__c=mano.Id),
            new tiposDeTrabajo__c(Name='Servicio 0000999', Identificador__c='0000999', ManoDeObra__c=mano.Id)
        };
    }

    private static Id getCaseId()      { return [SELECT Id FROM Case      LIMIT 1].Id; }
    private static Id getWorkOrderId() { return [SELECT Id FROM WorkOrder LIMIT 1].Id; }

    private static Id createTrabajoPadreParaSubtrabajos() {
        tiposDeTrabajo__c tipoPadre = [SELECT Id FROM tiposDeTrabajo__c WHERE Identificador__c = '0000105' LIMIT 1];
        tiposDeTrabajoCaso__c padre = new tiposDeTrabajoCaso__c(
            Caso__c = getCaseId(),
            RM_WorkOrder__c = getWorkOrderId(),
            Tipotrabajo__c = tipoPadre.Id,
            Tipo_de_cargo__c = 'Cliente',
            UTS__c = 1
        );
        insert padre;
        return padre.Id;
    }

    private static void setMocks() {
        Test.setMock(WebServiceMock.class, new DummyWsMock());
        Test.setMock(HttpCalloutMock.class, new DummyHttpMock());
    }

    private static void ensurePbesForCurrentWO() {
        Id stdPbId   = Test.getStandardPricebookId();
        WorkOrder wo = [SELECT Id, Pricebook2Id FROM WorkOrder LIMIT 1];

        Set<Id> allManoIds = new Set<Id>();
        for (Product2 p : [SELECT Id FROM Product2 WHERE Codigo_de_Producto__c IN ('MO23','SUMI')]) {
            allManoIds.add(p.Id);
        }
        for (tiposDeTrabajo__c t : [SELECT ManoDeObra__c FROM tiposDeTrabajo__c WHERE ManoDeObra__c != null]) {
            allManoIds.add(t.ManoDeObra__c);
        }
        for (TipoDeCargoConManoDeObra__c t : [SELECT ManoDeObra__c FROM TipoDeCargoConManoDeObra__c WHERE ManoDeObra__c != null]) {
            allManoIds.add(t.ManoDeObra__c);
        }

        if (wo.Pricebook2Id == null) {
            update new WorkOrder(Id = wo.Id, Pricebook2Id = stdPbId);
            wo.Pricebook2Id = stdPbId;
        }

        ensurePricebookActive(stdPbId);
        for (Id prodId : allManoIds) upsertPbe(stdPbId, prodId, 100);

        if (wo.Pricebook2Id != stdPbId) {
            for (Id prodId : allManoIds) upsertPbe(wo.Pricebook2Id, prodId, 100);
        }

        for (Pricebook2 pb : [SELECT Id FROM Pricebook2 WHERE IsActive = true
                               AND Id != :stdPbId AND Id != :wo.Pricebook2Id]) {
            for (Id prodId : allManoIds) upsertPbe(pb.Id, prodId, 100);
        }

        Integer pbeCount = [
            SELECT COUNT() FROM PricebookEntry
            WHERE Pricebook2Id = :wo.Pricebook2Id
              AND Product2Id IN :allManoIds
              AND IsActive = true
        ];
        if (pbeCount == 0) {
            update new WorkOrder(Id = wo.Id, Pricebook2Id = stdPbId);
        }
    }

    private static void upsertPbe(Id pbId, Id prodId, Decimal price) {
        if (pbId == null || prodId == null) return;
        List<PricebookEntry> ex = [SELECT Id FROM PricebookEntry
                                   WHERE Pricebook2Id = :pbId AND Product2Id = :prodId LIMIT 1];
        if (ex.isEmpty()) {
            insert new PricebookEntry(
                Pricebook2Id = pbId, Product2Id = prodId, UnitPrice = price, IsActive = true
            );
        }
    }

    private static String jsonWrapped(List<String> nodes) {
        return '{"operationResult":{"services":[' + String.join(nodes, ',') + ']}}';
    }
    private static String jsonRoot(List<String> nodes) {
        return '{"services":[' + String.join(nodes, ',') + ']}';
    }
    private static String svc(String name, String num, String state, String adv, Integer qty) {
        return '{"name":"' + name + '","serviceNumber":"' + num + '","state":"' + state
             + '","advisoryText":"' + adv + '","quantity":{"value":' + qty + '}}';
    }
    private static String svcNullQty(String name, String num, String state) {
        return '{"name":"' + name + '","serviceNumber":"' + num + '","state":"' + state
             + '","advisoryText":"","quantity":null}';
    }

    @IsTest static void testNullCaseId() {
        setMocks(); Boolean threw = false;
        Test.startTest();
        try { BMWVinScanTrabajoGenerator.createTrabajosFromVinScan(null, getWorkOrderId(), '{}', 'Cliente'); }
        catch (AuraHandledException e) { threw = true; }
        Test.stopTest();
        System.assert(threw, 'Debe lanzar AuraHandledException cuando caseId es null');
    }

    @IsTest static void testNullWorkOrderId() {
        setMocks(); Boolean threw = false;
        Test.startTest();
        try { BMWVinScanTrabajoGenerator.createTrabajosFromVinScan(getCaseId(), null, '{}', 'Cliente'); }
        catch (AuraHandledException e) { threw = true; }
        Test.stopTest();
        System.assert(threw, 'Debe lanzar AuraHandledException cuando workOrderId es null');
    }

    @IsTest static void testBlankJson() {
        setMocks(); Boolean threw = false;
        Test.startTest();
        try { BMWVinScanTrabajoGenerator.createTrabajosFromVinScan(getCaseId(), getWorkOrderId(), '   ', 'Cliente'); }
        catch (AuraHandledException e) { threw = true; }
        Test.stopTest();
        System.assert(threw, 'Debe lanzar AuraHandledException cuando json es blank');
    }

    @IsTest static void testJsonSinServices() {
        setMocks(); Boolean threw = false;
        Test.startTest();
        try { BMWVinScanTrabajoGenerator.createTrabajosFromVinScan(getCaseId(), getWorkOrderId(),
                '{"operationResult":{"otherField":"x"}}', 'Cliente'); }
        catch (AuraHandledException e) { threw = true; }
        Test.stopTest();
        System.assert(threw, 'Debe lanzar AuraHandledException cuando no existe services[]');
    }

    @IsTest static void testServicesVacio() {
        setMocks(); Boolean threw = false;
        Test.startTest();
        try { BMWVinScanTrabajoGenerator.createTrabajosFromVinScan(getCaseId(), getWorkOrderId(),
                '{"operationResult":{"services":[]}}', 'Cliente'); }
        catch (AuraHandledException e) { threw = true; }
        Test.stopTest();
        System.assert(threw, 'Debe lanzar AuraHandledException cuando services esta vacio');
    }

    @IsTest static void testTodosSinIdentificador() {
        setMocks(); Boolean threw = false;
        String json = jsonWrapped(new List<String>{
            '{"name":"Sin num","serviceNumber":"","state":"GREEN","advisoryText":"","quantity":null}'
        });
        Test.startTest();
        try { BMWVinScanTrabajoGenerator.createTrabajosFromVinScan(getCaseId(), getWorkOrderId(), json, 'Cliente'); }
        catch (AuraHandledException e) { threw = true; }
        Test.stopTest();
        System.assert(threw, 'Debe lanzar AuraHandledException cuando no hay identificadores validos');
    }

    @IsTest static void testFlujoCompleto_TipoExistente_RED() {
        setMocks();
        String json = jsonWrapped(new List<String>{ svc('Servicio frenos', '0000105', 'RED', 'Frenos desgastados', 24) });
        ensurePbesForCurrentWO();
        Test.startTest();
        Map<String, Object> res = BMWVinScanTrabajoGenerator.createTrabajosFromVinScan(getCaseId(), getWorkOrderId(), json, 'Cliente');
        Test.stopTest();
        System.assert((Integer)res.get('createdTrabajosCaso') >= 1, 'Debe crear al menos 1 TTC');
        System.assert((Integer)res.get('createdTiposDeTrabajo') == 0, 'No debe crear tiposDeTrabajo nuevos');
        tiposDeTrabajoCaso__c ttc = [SELECT Categor_a_de_presupuesto__c FROM tiposDeTrabajoCaso__c WHERE Caso__c = :getCaseId() LIMIT 1];
        System.assertEquals('Necesario', ttc.Categor_a_de_presupuesto__c, 'RED debe mapear a Necesario');
    }

    @IsTest static void testStateYellow_Recomendado() {
        setMocks();
        String json = jsonWrapped(new List<String>{ svc('Cambio aceite', '0000612', 'YELLOW', 'Aceite viejo', 12) });
        ensurePbesForCurrentWO();
        Test.startTest();
        BMWVinScanTrabajoGenerator.createTrabajosFromVinScan(getCaseId(), getWorkOrderId(), json, 'Cliente');
        Test.stopTest();
        tiposDeTrabajoCaso__c ttc = [SELECT Categor_a_de_presupuesto__c FROM tiposDeTrabajoCaso__c WHERE Caso__c = :getCaseId() LIMIT 1];
        System.assertEquals('Recomendado', ttc.Categor_a_de_presupuesto__c, 'YELLOW debe mapear a Recomendado');
    }

    @IsTest static void testStateGreen_Sugerido() {
        setMocks();
        String json = jsonWrapped(new List<String>{ svc('Revision general', '0000618', 'GREEN', '', 6) });
        ensurePbesForCurrentWO();
        Test.startTest();
        BMWVinScanTrabajoGenerator.createTrabajosFromVinScan(getCaseId(), getWorkOrderId(), json, 'Cliente');
        Test.stopTest();
        tiposDeTrabajoCaso__c ttc = [SELECT Categor_a_de_presupuesto__c FROM tiposDeTrabajoCaso__c WHERE Caso__c = :getCaseId() LIMIT 1];
        System.assertEquals('Sugerido', ttc.Categor_a_de_presupuesto__c, 'GREEN debe mapear a Sugerido');
    }

    @IsTest static void testStateDesconocido_Sugerido() {
        setMocks();
        String json = jsonWrapped(new List<String>{ svc('Revision x', '0000999', 'UNKNOWN', '', 6) });
        ensurePbesForCurrentWO();
        Test.startTest();
        BMWVinScanTrabajoGenerator.createTrabajosFromVinScan(getCaseId(), getWorkOrderId(), json, 'Cliente');
        Test.stopTest();
        tiposDeTrabajoCaso__c ttc = [SELECT Categor_a_de_presupuesto__c FROM tiposDeTrabajoCaso__c WHERE Caso__c = :getCaseId() LIMIT 1];
        System.assertEquals('Sugerido', ttc.Categor_a_de_presupuesto__c, 'State desconocido debe mapear a Sugerido');
    }

    @IsTest static void testTTCYaExiste_EarlyReturn() {
        setMocks();
        tiposDeTrabajo__c tipo = [SELECT Id FROM tiposDeTrabajo__c WHERE Identificador__c = '0000105' LIMIT 1];
        insert new tiposDeTrabajoCaso__c(Caso__c = getCaseId(), RM_WorkOrder__c = getWorkOrderId(), Tipotrabajo__c = tipo.Id);
        String json = jsonWrapped(new List<String>{ svc('Ya existe', '0000105', 'RED', '', 12) });
        ensurePbesForCurrentWO();
        Test.startTest();
        Map<String, Object> res = BMWVinScanTrabajoGenerator.createTrabajosFromVinScan(getCaseId(), getWorkOrderId(), json, 'Cliente');
        Test.stopTest();
        System.assert((Integer)res.get('createdTrabajosCaso') == 0, 'No debe crear TTC si ya existe');
        System.assert(res.containsKey('emailSent'), 'Debe retornar emailSent');
    }

    @IsTest static void testTipoNuevo_CreaFallbackManoDeObra() {
        setMocks();
        String json = jsonWrapped(new List<String>{ svc('Servicio nuevo', 'SVC-NUEVO-001', 'GREEN', 'Nuevo', 12) });
        ensurePbesForCurrentWO();
        Test.startTest();
        Map<String, Object> res = BMWVinScanTrabajoGenerator.createTrabajosFromVinScan(getCaseId(), getWorkOrderId(), json, 'Cliente');
        Test.stopTest();
        System.assert((Integer)res.get('createdTiposDeTrabajo') >= 1, 'Debe haber creado tiposDeTrabajo__c nuevo');
        System.assert((Integer)res.get('createdTrabajosCaso')  >= 1, 'Debe haber creado TTC');
    }

    @IsTest static void testMultiplesServices_TresTTC() {
        setMocks();
        String json = jsonWrapped(new List<String>{
            svc('Servicio A', '0000105', 'RED',    'Adv A', 24),
            svc('Servicio B', '0000612', 'YELLOW', 'Adv B', 12),
            svc('Servicio C', '0000618', 'GREEN',  'Adv C', 6)
        });
        ensurePbesForCurrentWO();
        Test.startTest();
        Map<String, Object> res = BMWVinScanTrabajoGenerator.createTrabajosFromVinScan(getCaseId(), getWorkOrderId(), json, 'Cliente');
        Test.stopTest();
        System.assert((Integer)res.get('createdTrabajosCaso') == 3, 'Debe crear 3 TTC; got: ' + res.get('createdTrabajosCaso'));
        System.assert((Integer)res.get('servicesReceived') == 3, 'Debe reportar 3 recibidos');
    }

    @IsTest static void testMixedServices_Skipped() {
        setMocks();
        String json = jsonWrapped(new List<String>{
            svc('Con numero', '0000105', 'RED', '', 12),
            '{"name":"Sin numero","serviceNumber":"","state":"GREEN","advisoryText":"","quantity":null}'
        });
        ensurePbesForCurrentWO();
        Test.startTest();
        Map<String, Object> res = BMWVinScanTrabajoGenerator.createTrabajosFromVinScan(getCaseId(), getWorkOrderId(), json, 'Cliente');
        Test.stopTest();
        System.assert((Integer)res.get('servicesSkippedNoIdent') >= 1, 'Debe reportar 1 skipped');
        System.assert((Integer)res.get('servicesReceived') == 2, 'Debe reportar 2 recibidos');
    }

    @IsTest static void testUTSCalculado_24Unidades() {
        setMocks();
        String json = jsonWrapped(new List<String>{ svc('UTS test', '0000105', 'RED', '', 24) });
        ensurePbesForCurrentWO();
        Test.startTest();
        BMWVinScanTrabajoGenerator.createTrabajosFromVinScan(getCaseId(), getWorkOrderId(), json, 'Cliente');
        Test.stopTest();
        tiposDeTrabajoCaso__c ttc = [SELECT UTS__c, UTS_Real__c FROM tiposDeTrabajoCaso__c WHERE Caso__c = :getCaseId() LIMIT 1];
        System.assertEquals(2.0, ttc.UTS__c,               '24 unidades / 12 = 2.0 horas (UTS).');
        System.assertEquals(24,  ttc.UTS_Real__c.intValue(),'UTS_Real__c debe almacenar las unidades originales (24).');
    }

    @IsTest static void testJsonRootLevel_SinWrapper() {
        setMocks();
        String json = jsonRoot(new List<String>{ svc('Root service', '0000105', 'GREEN', '', 6) });
        ensurePbesForCurrentWO();
        Test.startTest();
        Map<String, Object> res = BMWVinScanTrabajoGenerator.createTrabajosFromVinScan(getCaseId(), getWorkOrderId(), json, 'Cliente');
        Test.stopTest();
        System.assert((Integer)res.get('createdTrabajosCaso') >= 1, 'Debe procesar JSON sin wrapper');
    }

    @IsTest static void testNombreLargo_Truncado() {
        setMocks();
        String nombreLargo = 'X'.repeat(100);
        String json = '{"operationResult":{"services":[{"name":"' + nombreLargo
            + '","serviceNumber":"SVC-LONG-777","state":"GREEN","advisoryText":"","quantity":{"value":6}}]}}';
        ensurePbesForCurrentWO();
        Test.startTest();
        BMWVinScanTrabajoGenerator.createTrabajosFromVinScan(getCaseId(), getWorkOrderId(), json, 'Cliente');
        Test.stopTest();
        tiposDeTrabajo__c tipo = [SELECT Name FROM tiposDeTrabajo__c WHERE Identificador__c = 'SVC-LONG-777' LIMIT 1];
        System.assert(tipo.Name.length() <= 80, 'Nombre debe estar truncado a 80 chars');
    }

    @IsTest static void testCampoNumberFallback() {
        setMocks();
        String json = '{"operationResult":{"services":[{"name":"Alt number","number":"0000105","state":"GREEN","advisoryText":"","quantity":{"value":12}}]}}';
        ensurePbesForCurrentWO();
        Test.startTest();
        Map<String, Object> res = BMWVinScanTrabajoGenerator.createTrabajosFromVinScan(getCaseId(), getWorkOrderId(), json, 'Cliente');
        Test.stopTest();
        System.assert((Integer)res.get('createdTrabajosCaso') >= 1, 'Debe leer campo "number" como fallback');
    }

    @IsTest static void testCampoNumeroTercerFallback() {
        setMocks();
        String json = '{"operationResult":{"services":[{"name":"Numero fallback","numero":"0000105","state":"GREEN","advisoryText":"","quantity":{"value":6}}]}}';
        ensurePbesForCurrentWO();
        Test.startTest();
        Map<String, Object> res = BMWVinScanTrabajoGenerator.createTrabajosFromVinScan(getCaseId(), getWorkOrderId(), json, 'Cliente');
        Test.stopTest();
        System.assert((Integer)res.get('createdTrabajosCaso') >= 1, 'Debe leer campo "numero" como tercer fallback');
    }

    @IsTest static void testSubtipoCreado_VinculadoWOLI() {
        setMocks();
        String json = jsonWrapped(new List<String>{ svc('Subtipo test', '0000105', 'RED', 'Advisory X', 12) });
        ensurePbesForCurrentWO();
        Test.startTest();
        BMWVinScanTrabajoGenerator.createTrabajosFromVinScan(getCaseId(), getWorkOrderId(), json, 'Cliente');
        Test.stopTest();
        List<Subtipo_de_trabajo_del_caso__c> subs = [SELECT Id, Articulo_Mano_de_Obra__c FROM Subtipo_de_trabajo_del_caso__c WHERE Caso__c = :getCaseId()];
        System.assertNotEquals(0, subs.size(),       'Debe haberse creado al menos 1 Subtipo_de_trabajo_del_caso__c.');
        System.assertNotEquals(null, subs[0].Articulo_Mano_de_Obra__c, 'Subtipo debe estar vinculado al WOLI (Articulo_Mano_de_Obra__c no debe ser null).');
    }

    @IsTest static void testCreateSubtrabajosFromVinScan_CreaBajoPadreSeleccionado() {
        setMocks();
        Id padreId = createTrabajoPadreParaSubtrabajos();
        String json = jsonWrapped(new List<String>{ svc('Subtrabajo desde llave', '0000612', 'YELLOW', 'Adv sub', 12) });
        ensurePbesForCurrentWO();

        Test.startTest();
        Map<String, Object> res = BMWVinScanTrabajoGenerator.createSubtrabajosFromVinScan(
            getCaseId(),
            getWorkOrderId(),
            padreId,
            json,
            'Cliente'
        );
        Test.stopTest();

        System.assertEquals(1, (Integer)res.get('createdSubtrabajos'), 'Debe crear 1 subtrabajo bajo el padre seleccionado.');
        Subtipo_de_trabajo_del_caso__c sub = [
            SELECT Id, Tipo_de_trabajo_del_caso__c, Articulo_Mano_de_Obra__c
            FROM Subtipo_de_trabajo_del_caso__c
            WHERE Tipo_de_trabajo_del_caso__c = :padreId
            LIMIT 1
        ];
        System.assertEquals(padreId, sub.Tipo_de_trabajo_del_caso__c, 'El subtrabajo debe quedar vinculado al padre seleccionado.');
        System.assertNotEquals(null, sub.Articulo_Mano_de_Obra__c, 'El subtrabajo debe quedar vinculado al WOLI.');
    }

    @IsTest static void testCreateSubtrabajosFromVinScan_NoDuplicaEnMismoPadre() {
        setMocks();
        Id padreId = createTrabajoPadreParaSubtrabajos();
        tiposDeTrabajo__c tipo = [SELECT Id, Name, ManoDeObra__c FROM tiposDeTrabajo__c WHERE Identificador__c = '0000612' LIMIT 1];

        insert new Subtipo_de_trabajo_del_caso__c(
            Tipo_de_trabajo_del_caso__c = padreId,
            Caso__c = getCaseId(),
            Orden_de_trabajo__c = getWorkOrderId(),
            Name = tipo.Name,
            Alias__c = tipo.Name,
            TipoDeTrabajo__c = tipo.Id,
            Mano_de_Obra__c = tipo.ManoDeObra__c,
            UTS__c = 1,
            Cantidad_de_horas__c = 1
        );

        String json = jsonWrapped(new List<String>{ svc('Subtrabajo existente', '0000612', 'YELLOW', 'Adv sub', 12) });
        ensurePbesForCurrentWO();

        Test.startTest();
        Map<String, Object> res = BMWVinScanTrabajoGenerator.createSubtrabajosFromVinScan(
            getCaseId(),
            getWorkOrderId(),
            padreId,
            json,
            'Cliente'
        );
        Test.stopTest();

        System.assertEquals(0, (Integer)res.get('createdSubtrabajos'), 'No debe duplicar subtrabajos ya presentes en el mismo padre.');
    }

    @IsTest static void testTTC_CamposCorrectos() {
        setMocks();
        String json = jsonWrapped(new List<String>{ svc('Test campos', '0000105', 'RED', 'Advisory TTC', 12) });
        ensurePbesForCurrentWO();
        Test.startTest();
        BMWVinScanTrabajoGenerator.createTrabajosFromVinScan(getCaseId(), getWorkOrderId(), json, 'Cliente');
        Test.stopTest();
        tiposDeTrabajoCaso__c ttc = [SELECT Tipo_de_cargo__c, Aprobador__c, RM_EsTrabajoAdicional__c, RM_WorkOrder__c
                                     FROM tiposDeTrabajoCaso__c WHERE Caso__c = :getCaseId() LIMIT 1];
        System.assertEquals('Cliente',        ttc.Tipo_de_cargo__c,         'Tipo de cargo debe ser Cliente.');
        System.assertEquals('Asesor',         ttc.Aprobador__c,             'Aprobador debe ser Asesor.');
        System.assertEquals(true,             ttc.RM_EsTrabajoAdicional__c, 'Debe marcarse como trabajo adicional.');
        System.assertEquals(getWorkOrderId(), ttc.RM_WorkOrder__c,          'TTC debe estar vinculado al WorkOrder correcto.');
    }

    @IsTest static void testResultadoContieneClaves() {
        setMocks();
        String json = jsonWrapped(new List<String>{ svc('Email test', '0000105', 'GREEN', '', 12) });
        ensurePbesForCurrentWO();
        Test.startTest();
        Map<String, Object> res = BMWVinScanTrabajoGenerator.createTrabajosFromVinScan(getCaseId(), getWorkOrderId(), json, 'Cliente');
        Test.stopTest();
        System.assert(res.containsKey('emailSent'),           'Resultado debe contener emailSent');
        System.assert(res.containsKey('servicesReceived'),    'Resultado debe contener servicesReceived');
        System.assert(res.containsKey('createdTrabajosCaso'), 'Resultado debe contener createdTrabajosCaso');
    }

    private static void ensurePricebookActive(Id pbId) {
        if (pbId == null) return;
        try { update new Pricebook2(Id = pbId, IsActive = true); } catch (Exception e) {}
    }

    private static Id getOrCreatePricebook(String name) {
        List<Pricebook2> existing = [SELECT Id FROM Pricebook2 WHERE Name = :name LIMIT 1];
        if (!existing.isEmpty()) {
            try { update new Pricebook2(Id = existing[0].Id, IsActive = true); } catch (Exception e) {}
            return existing[0].Id;
        }
        Pricebook2 pb = new Pricebook2(Name = name, IsActive = true);
        insert pb;
        return pb.Id;
    }

    private static String pickVal(Schema.SObjectField f) {
        for (Schema.PicklistEntry pe : f.getDescribe().getPicklistValues()) {
            if (pe.isActive()) return pe.getValue();
        }
        return null;
    }
}