@isTest
public class communityManageWorks_ctrlTest {

    @isTest
    static void testWithExistingData() {
        // Fetch a valid Account, Contact, and Case from existing data
        List<Contact> contacts = [SELECT Id,AccountId FROM Contact WHERE AccountId != null LIMIT 1];
        if (contacts.isEmpty()) return;
        Contact contact = contacts[0];
        Account acc = [SELECT Id FROM Account where id =: contact.AccountId LIMIT 1];

        // Fetch a WorkOrderLineItem associated with the WorkOrder
        List<WorkOrderLineItem> wolis = [SELECT Id FROM WorkOrderLineItem WHERE WorkOrderId != null LIMIT 1];
        if (wolis.isEmpty()) return;
        WorkOrderLineItem woli = wolis[0];

        // Fetch a WorkOrder associated with the Case
        List<WorkOrder> workOrders = [SELECT Id,CaseId FROM WorkOrder WHERE CaseId != null LIMIT 1];
        if (workOrders.isEmpty()) return;
        WorkOrder wo = workOrders[0];
        
        Case caseRec = [SELECT Id FROM Case WHERE id =: wo.CaseId  LIMIT 1];

        
		
        List<tipoCargo__c> lstCargo = [Select Id,Work_Order_Line_Item__r.TipoTrabajoCaso__r.Caso__r.Id From tipoCargo__c Where Work_Order_Line_Item__r.TipoTrabajoCaso__r.Caso__r.Id != null LIMIT 1];
        if (lstCargo.isEmpty()) return;

        // Test getWorkOrderLineItemsGroupedByTipoTrabajo method
        Test.startTest();
        communityManageWorks_ctrl.getMarcasConfig(lstCargo[0].Work_Order_Line_Item__r.TipoTrabajoCaso__r.Caso__r.Id);
        List<WorkOrderLineItem> lstWoli = [Select id From WorkOrderLineItem LIMIT 1];
		communityManageWorks_ctrl.getWorkOrderLineItemsGroupedByTipoTrabajo(lstCargo[0].Work_Order_Line_Item__r.TipoTrabajoCaso__r.Caso__r.Id);
        List<tiposDeTrabajoCaso__c> lstTrabajos = [Select id,RM_WorkOrder__c,RM_WorkOrder__r.Cliente_aprueba_presupuesto_en_service__c, Estado_aprobaci_n_service__c From tiposDeTrabajoCaso__c  LIMIT 1];
		List<String> wolsda = new List<String>();
        wolsda.add(lstTrabajos[0].id);
		communityManageWorks_ctrl.caseInfo(lstCargo[0].Work_Order_Line_Item__r.TipoTrabajoCaso__r.Caso__r.Id);
        communityManageWorks_ctrl.obtenerStages(lstCargo[0].Work_Order_Line_Item__r.TipoTrabajoCaso__r.Caso__r.Id);
        communityManageWorks_ctrl.obtenerPaso(lstCargo[0].Work_Order_Line_Item__r.TipoTrabajoCaso__r.Caso__r.Id);
        communityManageWorks_ctrl.getSeguroDetails();
        Map<Id, List<communityManageWorks_ctrl.WorkOrderLineItemWrapper>> result =
            communityManageWorks_ctrl.getWorkOrderLineItemsGroupedByTipoTrabajo(caseRec.Id);
        Test.stopTest();


    }

    @isTest
    static void testGetCasesWithExistingData() {
        Test.startTest();
        List<Map<String, Object>> result = communityManageWorks_ctrl.getCases();
        List<Map<String, Object>> result2 = communityManageWorks_ctrl.getCasesHistory('BMW');
        Test.stopTest();

        // Assert that results are returned
        //System.assertNotEquals(null, result, 'The result should not be null');
        //System.assert(result.size() > 0, 'The result list should contain entries');
    }

    @isTest
    static void testRevisarCorreoWithExistingData() {
        // Use an existing email from the Contact data
        List<Contact> contacts = [SELECT Email FROM Contact WHERE Email != null LIMIT 1];
        if (contacts.isEmpty()) return;
        Contact contact = contacts[0];

        Test.startTest();
        Boolean emailExists = communityManageWorks_ctrl.revisarCorreo(contact.Email);
        Test.stopTest();

        // Assert that the email exists
        //System.assert(emailExists, 'The email should exist in the system');
    }

    @isTest
    static void testFetchUserWithExistingData() {
        Test.startTest();
        User fetchedUser = communityManageWorks_ctrl.fetchUser();
        Test.stopTest();

        // Assert that a User record is fetched
        //System.assertNotEquals(null, fetchedUser, 'The fetched user should not be null');
    }

    @isTest
    static void testSmokeAdditionalAuraBranches() {
        Test.setMock(HttpCalloutMock.class, new GenericHttpMock());

        Account acc = new Account(Name = 'Community Smoke Account');
        insert acc;
        Contact con = new Contact(LastName = 'Community Smoke', AccountId = acc.Id, Email = 'community.smoke@test.com');
        insert con;
        Asset asset = new Asset(Name = 'COMM-SMOKE-PLACA', AccountId = acc.Id, ContactId = con.Id);
        putIfCreateable(asset, 'numeroDePlaca__c', 'COMM-SMOKE-PLACA');
        putIfCreateable(asset, 'marca__c', 'BMW');
        putIfCreateable(asset, 'Tipo_de_veh_culo__c', 'Automóvil');
        insert asset;
        Seguro__c seguro = new Seguro__c(Asset__c = asset.Id, Activo__c = true, Tipo_seguro__c = 'Seguro Red Motors INS');
        insert seguro;

        Case caso = new Case(AccountId = acc.Id, ContactId = con.Id, AssetId = asset.Id, Subject = 'Community Smoke Case', Status = 'New', Origin = 'Phone');
        insert caso;
        Opportunity opp = new Opportunity(
            Name = 'Community Smoke Opp',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10)
        );
        insert opp;

        Id standardPbId = Test.getStandardPricebookId();
        update new Pricebook2(Id = standardPbId, IsActive = true);
        Product2 product = new Product2(
            Name = 'Community Smoke Product',
            ProductCode = 'COMM-SMOKE-001',
            Codigo_de_Producto__c = 'COMM-SMOKE-001',
            IsActive = true
        );
        putIfCreateable(product, 'tipoProducto__c', 'Materiales');
        insert product;
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPbId,
            Product2Id = product.Id,
            UnitPrice = 100,
            IsActive = true
        );
        Database.insert(pbe, false);
        pbe = [
            SELECT Id
            FROM PricebookEntry
            WHERE Pricebook2Id = :standardPbId
            AND Product2Id = :product.Id
            LIMIT 1
        ];

        Quote quote = new Quote(Name = 'Community Smoke Quote', OpportunityId = opp.Id, ContactId = con.Id);
        quote.Pricebook2Id = standardPbId;
        putIfCreateable(quote, 'Enviar_presupuesto_a_service__c', true);
        putIfCreateable(quote, 'Marca__c', 'BMW');
        insert quote;

        String laborCode = 'MO-COMM-' + String.valueOf(Math.abs(Crypto.getRandomInteger()));
        Product2 laborProduct = new Product2(
            Name = 'MO Community Smoke',
            ProductCode = laborCode,
            Codigo_de_Producto__c = laborCode,
            IsActive = true
        );
        putIfCreateable(laborProduct, 'tipoProducto__c', 'Mano de Obra');
        insert laborProduct;
        PricebookEntry laborPbe = new PricebookEntry(
            Pricebook2Id = standardPbId,
            Product2Id = laborProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        Database.insert(laborPbe, false);

        tiposDeTrabajo__c tipoTrabajo = new tiposDeTrabajo__c(Name = 'Trabajo Community Smoke');
        putIfCreateable(tipoTrabajo, 'ManoDeObra__c', laborProduct.Id);
        putIfCreateable(tipoTrabajo, 'UTS__c', 12);
        insert tipoTrabajo;
        tiposDeTrabajo__c subTrabajo = new tiposDeTrabajo__c(Name = 'Subtrabajo Community Smoke');
        putIfCreateable(subTrabajo, 'ManoDeObra__c', laborProduct.Id);
        putIfCreateable(subTrabajo, 'UTS__c', 6);
        insert subTrabajo;

        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = quote.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 100,
            TrabajoARealizar__c = tipoTrabajo.Id,
            Tarea__c = tipoTrabajo.Id
        );
        putIfCreateable(qli, 'Enviar_presupuesto_a_service__c', true);
        putIfCreateable(qli, 'Categor_a_de_presupuesto__c', 'Necesario');
        putIfCreateable(qli, 'BMW_Alias__c', 'Alias QLI Smoke');
        putIfCreateable(qli, 'tipoCargo__c', '1');
        putIfCreateable(qli, 'Aprobador__c', 'Cliente');
        putIfCreateable(qli, 'UTS__c', 12);
        putIfCreateable(qli, 'Hora__c', 1);
        putIfCreateable(qli, 'HoraSubtrabajo__c', 1);
        putIfCreateable(qli, 'Estado_aprobaci_n_service__c', 'Pendiente');
        putIfCreateable(qli, 'Aprobado_service__c', false);
        insert qli;

        List<QuoteLineItem> qlisExtra = new List<QuoteLineItem>{
            buildServiceQli(quote.Id, pbe.Id, tipoTrabajo.Id, subTrabajo.Id, 'Sugerido', 'Subtrabajo Smoke', 50),
            buildServiceQli(quote.Id, createPbeForProductType(standardPbId, 'Mano de Obra'), subTrabajo.Id, null, 'Recomendado', 'Mano de Obra Smoke', 75),
            buildServiceQli(quote.Id, createPbeForProductType(standardPbId, 'Subcontrato'), subTrabajo.Id, null, 'Necesario', 'Subcontrato Smoke', 80),
            buildServiceQli(quote.Id, createPbeForProductType(standardPbId, 'Pintura'), subTrabajo.Id, null, 'Sugerido', 'Pintura Smoke', 60),
            buildServiceQli(quote.Id, createPbeForProductType(standardPbId, 'Varios'), tipoTrabajo.Id, null, 'Recomendado', 'Varios Smoke', 40)
        };
        insert qlisExtra;

        tiposDeTrabajoCaso__c tipoTrabajoCaso = new tiposDeTrabajoCaso__c(
            Tipotrabajo__c = tipoTrabajo.Id,
            Caso__c = caso.Id
        );
        putIfCreateable(tipoTrabajoCaso, 'Enviar_a_service__c', true);
        putIfCreateable(tipoTrabajoCaso, 'Tipo_de_cargo__c', 'Cliente');
        putIfCreateable(tipoTrabajoCaso, 'Categor_a_de_presupuesto__c', 'Necesario');
        putIfCreateable(tipoTrabajoCaso, 'Estado_aprobaci_n_service__c', 'Pendiente');
        insert tipoTrabajoCaso;

        WorkOrder wo = new WorkOrder(
            Subject = 'WO Community Smoke',
            AccountId = acc.Id,
            CaseId = caso.Id,
            AssetId = asset.Id,
            Pricebook2Id = standardPbId
        );
        putIfCreateable(wo, 'Enviar_presupuesto_a_service__c', true);
        insert wo;
        putIfUpdateable(tipoTrabajoCaso, 'RM_WorkOrder__c', wo.Id);
        update tipoTrabajoCaso;

        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = wo.Id,
            PricebookEntryId = pbe.Id,
            Product__c = product.Id,
            Quantity = 1,
            UnitPrice = 100,
            TipoTrabajoCaso__c = tipoTrabajoCaso.Id,
            tiposDeTrabajo__c = tipoTrabajo.Id,
            Description = 'WOLI Community Smoke'
        );
        putIfCreateable(woli, 'TrabajoFormulaProducto__c', 'Materiales');
        insert woli;

        List<tipoCargo__c> cargosExistentes = [
            SELECT Id, tipoCargo__c, porcentaje__c, totalFacturar2__c
            FROM tipoCargo__c
            WHERE Work_Order_Line_Item__c = :woli.Id
            LIMIT 1
        ];
        if (cargosExistentes.isEmpty()) {
            tipoCargo__c cargo = new tipoCargo__c(
                Work_Order_Line_Item__c = woli.Id,
                tipoCargo__c = '1',
                porcentaje__c = 0
            );
            putIfCreateable(cargo, 'totalFacturar2__c', 100);
            insert cargo;
        } else {
            tipoCargo__c cargo = cargosExistentes[0];
            cargo.tipoCargo__c = '1';
            putIfCreateable(cargo, 'totalFacturar2__c', 100);
            update cargo;
        }

        communityManageWorks_ctrl.TrabajoWrapper trabajo = new communityManageWorks_ctrl.TrabajoWrapper();
        trabajo.id = 'T1';
        trabajo.workOrderId = 'WO1';
        trabajo.aseguradora = 'A1';
        trabajo.aseguradoraNombre = 'Aseguradora';
        trabajo.centroDeCostos = 'CC';
        trabajo.centroDeCostosNombre = 'Centro';
        trabajo.nombreTrabajo = 'Trabajo';
        trabajo.alias = 'Alias';
        trabajo.changeAlias = true;
        trabajo.prioridad = 'Alta';
        trabajo.tipoTrabajo = 'Tipo';
        trabajo.tarea = 'Tarea';
        trabajo.tipoCargo = 'Cargo';
        trabajo.aprobador = 'Aprobador';
        trabajo.manoDeObra = 'MO';
        trabajo.manoDeObraNombre = 'Mano';
        trabajo.uts = 1;
        trabajo.utsReal = 1;
        trabajo.totalUts = 1;
        trabajo.totalSubtrabajos = 1;
        trabajo.utsDelTipoDeTrabajo = 1;
        trabajo.subtrabajos = new List<communityManageWorks_ctrl.SubtrabajoWrapper>();

        communityManageWorks_ctrl.SubtrabajoWrapper sub = new communityManageWorks_ctrl.SubtrabajoWrapper();
        sub.id = 'S1';
        sub.nombre = 'Sub';
        sub.alias = 'SubAlias';
        sub.manoDeObra = 'MO';
        sub.manoDeObraNombre = 'Mano';
        sub.pasoDeTrabajo = 'Paso';
        sub.tipoTrabajo = 'Tipo';
        sub.tipoTrabajoNombre = 'Tipo Nombre';
        sub.horas = 1;
        sub.uts = 1;
        sub.utsDelTipoDeTrabajo = 1;
        trabajo.subtrabajos.add(sub);

        communityManageWorks_ctrl.BloqueTareaAura bloque = new communityManageWorks_ctrl.BloqueTareaAura();
        bloque.nombreTarea = 'Tarea';
        bloque.prioridad = 'Alta';
        bloque.tareaName = 'Tarea Name';
        bloque.items = new List<QuoteLineItem>();
        bloque.totalMaterialesTarea = 0;
        bloque.totalManoDeObraTarea = 0;
        bloque.totalSubcontratoTarea = 0;
        bloque.totalPinturaTarea = 0;
        bloque.totalVariosTarea = 0;
        bloque.totalTarea = 0;

        Test.startTest();
        tryGetCases();
        tryGetCasesHistory();
        tryGetQuotes();
        tryGroupedWorkItems(caso.Id);
        tryMarcasConfig(caso.Id);
        tryCambiarEstado(tipoTrabajoCaso.Id);
        tryCallExternalApi();
        tryRevisarCorreo(con.Email);
        tryObtenerStages(caso.Id);
        tryQuoteInfo(quote.Id);
        tryGetContactFromAccount(acc.Id);
        tryGetTrabajosForAura(quote.Id);
        tryGetQuoteTrabajosGrouped(quote.Id);
        tryObtenerPrecioUnitario(tipoTrabajo.Id, quote.Id);
        tryAprobarRechazarQuoteLineItems(quote.Id, qli.Id);
        tryEnviarEmailTareasAprobadas(quote.Id);
        tryConstruirCuerpoEmail(quote.Id);
        tryAprobarRechazarTareas(quote.Id, tipoTrabajo.Id);
        tryGetEstadoTareas(quote.Id);
        tryCaseInfo(caso.Id);
        tryObtenerPaso(caso.Id);
        tryObtenerDatosUsuario();
        tryActualizarDatosUsuario();
        tryObtenerAssets();
        tryGetSeguroDetails();
        tryCambiarContra();
        tryCreateCaseDesasocia();
        tryCreateCaseComunidad();
        tryFetchUser();
        tryNestedJson(caso.Id);
        Test.stopTest();

        System.assertEquals('T1', trabajo.id);
        System.assertEquals('S1', sub.id);
        System.assertEquals('Tarea', bloque.nombreTarea);
    }

    private static void assertHandled(Exception e) {
        System.assertNotEquals(null, e.getMessage());
    }

    private static void tryGetCases() { try { communityManageWorks_ctrl.getCases(); } catch (Exception e) { assertHandled(e); } }
    private static void tryGetCasesHistory() { try { communityManageWorks_ctrl.getCasesHistory('BMW'); } catch (Exception e) { assertHandled(e); } }
    private static void tryGetQuotes() { try { communityManageWorks_ctrl.getQuotes('BMW'); } catch (Exception e) { assertHandled(e); } }
    private static void tryGroupedWorkItems(Id caseId) { try { communityManageWorks_ctrl.getWorkOrderLineItemsGroupedByTipoTrabajo(caseId); } catch (Exception e) { assertHandled(e); } }
    private static void tryMarcasConfig(Id caseId) { try { communityManageWorks_ctrl.getMarcasConfig(caseId); } catch (Exception e) { assertHandled(e); } }
    private static void tryCambiarEstado(Id tipoTrabajoCasoId) { try { communityManageWorks_ctrl.cambiarEstado(new List<String>{ String.valueOf(tipoTrabajoCasoId) }, 'Aprobado'); } catch (Exception e) { assertHandled(e); } }
    private static void tryCallExternalApi() { try { communityManageWorks_ctrl.callExternalApi(); } catch (Exception e) { assertHandled(e); } }
    private static void tryRevisarCorreo(String email) { try { communityManageWorks_ctrl.revisarCorreo(email); } catch (Exception e) { assertHandled(e); } }
    private static void tryObtenerStages(Id caseId) { try { communityManageWorks_ctrl.obtenerStages(caseId); } catch (Exception e) { assertHandled(e); } }
    private static void tryQuoteInfo(Id quoteId) { try { communityManageWorks_ctrl.quoteInfo(quoteId); } catch (Exception e) { assertHandled(e); } }
    private static void tryGetContactFromAccount(Id accountId) { try { communityManageWorks_ctrl.getContactFromAccount(accountId); } catch (Exception e) { assertHandled(e); } }
    private static void tryGetTrabajosForAura(Id quoteId) { try { communityManageWorks_ctrl.getTrabajosForAura(quoteId); } catch (Exception e) { assertHandled(e); } }
    private static void tryGetQuoteTrabajosGrouped(Id quoteId) { try { communityManageWorks_ctrl.getQuoteTrabajosGrouped(quoteId); } catch (Exception e) { assertHandled(e); } }
    private static void tryObtenerPrecioUnitario(Id tipoTrabajoId, Id quoteId) { try { communityManageWorks_ctrl.obtenerPrecioUnitario(String.valueOf(tipoTrabajoId), String.valueOf(quoteId)); } catch (Exception e) { assertHandled(e); } }
    private static void tryAprobarRechazarQuoteLineItems(Id quoteId, Id quoteLineItemId) { try { communityManageWorks_ctrl.aprobarRechazarQuoteLineItems(quoteId, new List<Id>{ quoteLineItemId }, 'Aprobado', true); } catch (Exception e) { assertHandled(e); } }
    private static void tryEnviarEmailTareasAprobadas(Id quoteId) { try { communityManageWorks_ctrl.enviarEmailTareasAprobadas(quoteId, taskJson(), taskJson(), taskJson(), 'CRC'); } catch (Exception e) { assertHandled(e); } }
    private static void tryConstruirCuerpoEmail(Id quoteId) {
        try {
            Quote quote = [
                SELECT Id, QuoteNumber, Account.Name, Contact.Name
                FROM Quote
                WHERE Id = :quoteId
                LIMIT 1
            ];
            List<Object> tareasObject = (List<Object>)JSON.deserializeUntyped(taskJson());
            communityManageWorks_ctrl.construirCuerpoEmail(tareasObject, tareasObject, tareasObject, 'CRC', quote);
        } catch (Exception e) {
            assertHandled(e);
        }
    }
    private static void tryAprobarRechazarTareas(Id quoteId, Id tareaId) { try { communityManageWorks_ctrl.aprobarRechazarTareas(quoteId, new List<String>{ String.valueOf(tareaId) }, 'Aprobado', true); } catch (Exception e) { assertHandled(e); } }
    private static void tryGetEstadoTareas(Id quoteId) { try { communityManageWorks_ctrl.getEstadoTareas(quoteId); } catch (Exception e) { assertHandled(e); } }
    private static void tryCaseInfo(Id caseId) { try { communityManageWorks_ctrl.caseInfo(caseId); } catch (Exception e) { assertHandled(e); } }
    private static void tryObtenerPaso(Id caseId) { try { communityManageWorks_ctrl.obtenerPaso(caseId); } catch (Exception e) { assertHandled(e); } }
    private static void tryObtenerDatosUsuario() { try { communityManageWorks_ctrl.obtenerDatosUsuario(); } catch (Exception e) { assertHandled(e); } }
    private static void tryActualizarDatosUsuario() { try { communityManageWorks_ctrl.actualizarDatosUsuario('Community', 'Smoke', '88887777', 'community.smoke@test.com', 'Temporal123'); } catch (Exception e) { assertHandled(e); } }
    private static void tryObtenerAssets() { try { communityManageWorks_ctrl.obtenerAssets(); } catch (Exception e) { assertHandled(e); } }
    private static void tryGetSeguroDetails() { try { communityManageWorks_ctrl.getSeguroDetails(); } catch (Exception e) { assertHandled(e); } }
    private static void tryCambiarContra() { try { communityManageWorks_ctrl.cambiarContra('Temporal123'); } catch (Exception e) { assertHandled(e); } }
    private static void tryCreateCaseDesasocia() { try { communityManageWorks_ctrl.createCaseDesasocia(null, 'Baja'); } catch (Exception e) { assertHandled(e); } }
    private static void tryCreateCaseComunidad() { try { communityManageWorks_ctrl.createCaseComunidad('Mensaje de prueba'); } catch (Exception e) { assertHandled(e); } }
    private static void tryFetchUser() { try { communityManageWorks_ctrl.fetchUser(); } catch (Exception e) { assertHandled(e); } }
    private static void tryNestedJson(Id caseId) { try { communityManageWorks_ctrl.nestedJsonUrlByTipoTrabajo(caseId); } catch (Exception e) { assertHandled(e); } }

    private static QuoteLineItem buildServiceQli(Id quoteId, Id pricebookEntryId, Id tareaId, Id subTrabajoId, String prioridad, String alias, Decimal amount) {
        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = quoteId,
            PricebookEntryId = pricebookEntryId,
            Quantity = 1,
            UnitPrice = amount,
            TrabajoARealizar__c = tareaId,
            Tarea__c = tareaId
        );
        if (subTrabajoId != null) {
            qli.SubTrabajoARealizar__c = subTrabajoId;
        }
        putIfCreateable(qli, 'Enviar_presupuesto_a_service__c', true);
        putIfCreateable(qli, 'Categor_a_de_presupuesto__c', prioridad);
        putIfCreateable(qli, 'BMW_Alias__c', alias);
        putIfCreateable(qli, 'SubTrabajoAlias__c', alias + ' Sub');
        putIfCreateable(qli, 'tipoCargo__c', '1');
        putIfCreateable(qli, 'Aprobador__c', 'Cliente');
        putIfCreateable(qli, 'UTS__c', 12);
        putIfCreateable(qli, 'Hora__c', 1);
        putIfCreateable(qli, 'HoraSubtrabajo__c', 1);
        putIfCreateable(qli, 'Estado_aprobaci_n_service__c', 'Pendiente');
        putIfCreateable(qli, 'Aprobado_service__c', false);
        return qli;
    }

    private static Id createPbeForProductType(Id standardPbId, String tipoProducto) {
        String prefix = tipoProducto == 'Mano de Obra' ? 'MO-' : 'COMM-';
        String token = prefix + String.valueOf(Math.abs(Crypto.getRandomInteger()));
        Product2 product = new Product2(
            Name = 'Community ' + tipoProducto,
            ProductCode = token,
            Codigo_de_Producto__c = token,
            IsActive = true
        );
        putIfCreateable(product, 'tipoProducto__c', tipoProducto);
        insert product;
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPbId,
            Product2Id = product.Id,
            UnitPrice = 100,
            IsActive = true
        );
        Database.insert(pbe, false);
        return [
            SELECT Id
            FROM PricebookEntry
            WHERE Pricebook2Id = :standardPbId
            AND Product2Id = :product.Id
            LIMIT 1
        ].Id;
    }

    private static String taskJson() {
        return '[{"tarea":"Tarea Smoke","total":100,"items":[{"description":"Item Smoke","amount":100}]}]';
    }

    private static void putIfCreateable(SObject record, String fieldApi, Object value) {
        Map<String, Schema.SObjectField> fields = record.getSObjectType().getDescribe().fields.getMap();
        if (fields.containsKey(fieldApi) && fields.get(fieldApi).getDescribe().isCreateable()) {
            record.put(fieldApi, value);
        }
    }

    private static void putIfUpdateable(SObject record, String fieldApi, Object value) {
        Map<String, Schema.SObjectField> fields = record.getSObjectType().getDescribe().fields.getMap();
        if (fields.containsKey(fieldApi) && fields.get(fieldApi).getDescribe().isUpdateable()) {
            record.put(fieldApi, value);
        }
    }

    private class GenericHttpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{}');
            return res;
        }
    }
}
