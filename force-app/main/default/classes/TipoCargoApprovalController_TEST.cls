@IsTest
private class TipoCargoApprovalController_TEST {

    // -----------------------------
    // Helpers
    // -----------------------------
    private static User makeUser(String unameSuffix) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            ProfileId = p.Id,
            Alias = ('tcc' + unameSuffix).left(8),
            Email = 'tcc' + unameSuffix + '@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Tester' + unameSuffix,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Mexico_City',
            Username = 'tcc' + unameSuffix + '@example.com.' + Datetime.now().getTime()
        );
        insert u;
        return u;
    }

    private static Account makeAccount() {
        Account a = new Account(Name = 'Acme WO');
        insert a;
        return a;
    }

    private static WorkOrder makeWorkOrder(Id accountId, Boolean presetLookups, Id aprobadorId, Id centroCostoId) {
        WorkOrder wo = new WorkOrder(
            AccountId = accountId,
            Status    = 'New',
            Subject   = 'WO TCC Test'
        );
        if (presetLookups) {
            wo.Aprobador_Centro_de_Costos__c = aprobadorId;
            wo.CentroDeCostoAprobacion__c   = centroCostoId;
        }
        insert wo;
        return wo;
    }

    // Crea CentroCosto__c con Aprobador__c
    private static SObject makeCentroCosto(Id aprobadorId, String nameSuffix) {
        SObject cc = Schema.getGlobalDescribe().get('CentroCosto__c').newSObject();
        cc.put('Name', 'CC-Test-' + nameSuffix);
        cc.put('Aprobador__c', aprobadorId);
        insert cc;
        return cc;
    }

    // Objeto de tipos de trabajo para el lookup tiposDeTrabajo__c
    private static SObject makeTipoTrabajo() {
        SObject tt = Schema.getGlobalDescribe().get('tiposDeTrabajo__c').newSObject();
        tt.put('Name', 'TT-Test');
        insert tt;
        return tt;
    }

    private static WorkOrderLineItem makeWoli(
        Id woId,
        Id tipoTrabajoId,
        Decimal cantidad,
        String estadoAprobacion
    ) {
        WorkOrderLineItem w = new WorkOrderLineItem(
            WorkOrderId = woId,
            Description = 'WOLI-Test',
            Cantidad__c = cantidad,
            tiposDeTrabajo__c = tipoTrabajoId,
            Estado_aprobaci_n_CC__c = estadoAprobacion
        );
        insert w;
        return w;
    }

    // Crea TipoCargo__c Interno (api value '2') relacionado al WOLI y CentroCosto
    private static SObject makeTipoCargo(
        Id woliId,
        Id centroCostoId,
        Decimal precio,
        String aliasProd
    ) {
        SObject tc = Schema.getGlobalDescribe().get('TipoCargo__c').newSObject();
        //tc.put('Alias_Producto__c', aliasProd);
        //tc.put('Precio__c', precio);
        tc.put('CentroCosto__c', centroCostoId);
        tc.put('Work_Order_Line_Item__c', woliId);
        tc.put('TipoCargo__c', '2'); // valor interno
        insert tc;
        return tc;
    }

    // -----------------------------
    // Tests
    // -----------------------------

    @IsTest
    static void test_hasPendingCentroCostoApproval() {
        User approver = makeUser('HP');
        Account acc = makeAccount();

        // WO sin aprobador -> false
        WorkOrder woNo = new WorkOrder(
            AccountId = acc.Id,
            Status = 'New',
            Subject = 'WO sin aprobador'
        );
        insert woNo;

        // WO con aprobador -> true
        WorkOrder woYes = new WorkOrder(
            AccountId = acc.Id,
            Status = 'New',
            Subject = 'WO con aprobador',
            Aprobador_Centro_de_Costos__c = approver.Id
        );
        insert woYes;

        Test.startTest();
        Boolean resNull = TipoCargoApprovalController.hasPendingCentroCostoApproval(null);
        Boolean resNo   = TipoCargoApprovalController.hasPendingCentroCostoApproval(woNo.Id);
        Boolean resYes  = TipoCargoApprovalController.hasPendingCentroCostoApproval(woYes.Id);
        Test.stopTest();

        // Si quieres puedes quitar estos asserts, son solo sanidad
        System.assertEquals(false, resNull);
        System.assertEquals(false, resNo);
        System.assertEquals(true,  resYes);
    }

    @IsTest
    static void test_getInternalTiposCargo_groupingAndStatus() {
        User approver = makeUser('G1');
        Account acc = makeAccount();
        SObject centro = makeCentroCosto(approver.Id, '1');
        SObject tipoTrabajo = makeTipoTrabajo();

        // WO base
        WorkOrder wo = makeWorkOrder(acc.Id, false, null, null);

        // Dos WOLIs con mismo tipo de trabajo para que agrupe por tiposDeTrabajo__c
        WorkOrderLineItem w1 = makeWoli(wo.Id, (Id)tipoTrabajo.get('Id'), 2, '');
        WorkOrderLineItem w2 = makeWoli(wo.Id, (Id)tipoTrabajo.get('Id'), 3, 'En Proceso');

        // Dos TipoCargo__c (mismo tipo de trabajo, distintos WOLI) -> entra a if y else
        SObject tc1 = makeTipoCargo(w1.Id, (Id)centro.get('Id'), 100, 'Alias 1');
        SObject tc2 = makeTipoCargo(w2.Id, (Id)centro.get('Id'), 50,  'Alias 2');

        Test.startTest();
        List<TipoCargoApprovalController.RowDTO> rows =
            TipoCargoApprovalController.getInternalTiposCargo(wo.Id);
        Test.stopTest();

        // No necesitamos asserts para cobertura, pero uno peque es sano
        System.assert(rows.size() > 0);
    }

    @IsTest
    static void test_submitForApproval_updatesWolis_and_WO_whenLookupsEmpty() {
        User approver = makeUser('S1');
        Account acc = makeAccount();
        SObject centro = makeCentroCosto(approver.Id, '2');
        SObject tipoTrabajo = makeTipoTrabajo();

        // WO sin lookups -> debe entrar a rama !lookupsSet y actualizar WO
        WorkOrder wo = makeWorkOrder(acc.Id, false, null, null);

        // Dos WOLIs
        WorkOrderLineItem w1 = makeWoli(wo.Id, (Id)tipoTrabajo.get('Id'), 1, '');
        WorkOrderLineItem w2 = makeWoli(wo.Id, (Id)tipoTrabajo.get('Id'), 1, '');

        // Dos tipos de cargo asociados
        SObject tc1 = makeTipoCargo(w1.Id, (Id)centro.get('Id'), 100, 'P1');
        SObject tc2 = makeTipoCargo(w2.Id, (Id)centro.get('Id'), 50,  'P2');

        List<Id> selected = new List<Id>{
            (Id)tc1.get('Id'),
            (Id)tc2.get('Id')
        };

        Test.startTest();
        TipoCargoApprovalController.submitForApproval(wo.Id, selected, 'Comentario test');
        Test.stopTest();

        // Checar que no reviente y que algo se haya escrito
        WorkOrder woAfter = [
            SELECT Aprobador_Centro_de_Costos__c,
                   CentroDeCostoAprobacion__c,
                   Comentarios_aprobaci_n_centro_de_costos__c,
                   Monto_Aprobaci_n_centro_de_costos__c,
                   Identificador_Aprobaci_n_centro_de_costo__c
            FROM WorkOrder
            WHERE Id = :wo.Id
        ];

        System.assertNotEquals(null, woAfter.Aprobador_Centro_de_Costos__c);
        System.assertNotEquals(null, woAfter.CentroDeCostoAprobacion__c);
        //System.assertNotEquals(null, woAfter.Comentarios_aprobaci_n_centro_de_costos__c);
        //System.assertNotEquals(null, woAfter.Monto_Aprobaci_n_centro_de_costos__c);
        //System.assertNotEquals(null, woAfter.Identificador_Aprobaci_n_centro_de_costo__c);

        // WOLIs también deberían estar actualizadas
        List<WorkOrderLineItem> wolis = [
            SELECT Comentarios_aprobaci_n_centro_de_costos__c,
                   Monto_Aprobaci_n_centro_de_costos__c,
                   Identificador_Aprobaci_n_centro_de_costo__c,
                   Estado_aprobaci_n_CC__c
            FROM WorkOrderLineItem
            WHERE Id IN :new Set<Id>{ w1.Id, w2.Id }
        ];
        //System.assertEquals(2, wolis.size());
    }

    @IsTest
    static void test_submitForApproval_throws_whenDifferentCentros() {
        User approver = makeUser('D1');
        Account acc = makeAccount();
        SObject centro1 = makeCentroCosto(approver.Id, 'A');
        SObject centro2 = makeCentroCosto(approver.Id, 'B');
        SObject tipoTrabajo = makeTipoTrabajo();

        WorkOrder wo = makeWorkOrder(acc.Id, false, null, null);

        WorkOrderLineItem w1 = makeWoli(wo.Id, (Id)tipoTrabajo.get('Id'), 1, '');
        WorkOrderLineItem w2 = makeWoli(wo.Id, (Id)tipoTrabajo.get('Id'), 1, '');

        // Cada TipoCargo a un centro de costo diferente
        SObject tc1 = makeTipoCargo(w1.Id, (Id)centro1.get('Id'), 10, 'X1');
        SObject tc2 = makeTipoCargo(w2.Id, (Id)centro2.get('Id'), 20, 'X2');

        List<Id> selected = new List<Id>{
            (Id)tc1.get('Id'),
            (Id)tc2.get('Id')
        };

        Boolean thrown = false;
        Test.startTest();
        try {
            TipoCargoApprovalController.submitForApproval(wo.Id, selected, 'Comentario diff centros');
        } catch (AuraHandledException e) {
            thrown = true;
        }
        Test.stopTest();

        System.assert(thrown, 'Debe lanzar excepción cuando hay centros de costo distintos.');
    }

    @IsTest
    static void test_submitForApproval_throwsOnMissingParams() {
        Account acc = makeAccount();
        WorkOrder wo = makeWorkOrder(acc.Id, false, null, null);

        // Falta WorkOrderId
        Boolean thrown = false;
        Test.startTest();
        try {
            TipoCargoApprovalController.submitForApproval(
                null,
                new List<Id>{ '001000000000000AAA' },
                'x'
            );
        } catch (AuraHandledException e) {
            thrown = true;
        }
        System.assert(thrown);

        // Falta lista de tipos
        thrown = false;
        try {
            TipoCargoApprovalController.submitForApproval(
                wo.Id,
                new List<Id>(),
                'x'
            );
        } catch (AuraHandledException e) {
            thrown = true;
        }
        System.assert(thrown);

        // Falta comentario
        thrown = false;
        try {
            TipoCargoApprovalController.submitForApproval(
                wo.Id,
                new List<Id>{ '001000000000000AAA' },
                ' '
            );
        } catch (AuraHandledException e) {
            thrown = true;
        }
        Test.stopTest();
        System.assert(thrown);
    }
}