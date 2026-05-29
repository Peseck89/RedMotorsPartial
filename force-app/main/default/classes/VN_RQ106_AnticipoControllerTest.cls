@IsTest
private class VN_RQ106_AnticipoControllerTest {
    private static Opportunity createOpportunity() {
        return createOpportunity('USD');
    }

    private static Opportunity createOpportunity(String currencyIsoCode) {
        Account account = new Account(Name = 'Cliente VN RQ106');
        insert account;

        Id standardPricebookId = Test.getStandardPricebookId();
        Opportunity opp = new Opportunity(
            Name = 'Oportunidad VN RQ106',
            AccountId = account.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(15),
            Pricebook2Id = standardPricebookId,
            CurrencyIsoCode = currencyIsoCode
        );
        insert opp;

        Quote quote = new Quote(
            Name = 'Presupuesto VN RQ106',
            OpportunityId = opp.Id,
            Pricebook2Id = standardPricebookId,
            CurrencyIsoCode = currencyIsoCode,
            Status = 'Draft'
        );
        insert quote;

        opp.Synced_Quote__c = quote.Id;
        update opp;
        return opp;
    }

    private static Product2 createVehicleProduct() {
        Product2 product = new Product2(
            Name = 'Vehiculo VN RQ106',
            IsActive = true,
            Producto_Reservado__c = false,
            esVehiculo__c = true,
            es_Vehiculo_usado__c = true,
            vin__c = 'VINVN106TEST',
            Codigo_de_Producto__c = 'VN-RQ106'
        );

        Map<String, Schema.RecordTypeInfo> recordTypes =
            Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName();
        if (recordTypes.containsKey('Vehiculos')) {
            product.RecordTypeId = recordTypes.get('Vehiculos').getRecordTypeId();
        }

        insert product;
        return product;
    }

    private static Product2 createInvalidVehicleCandidateProduct() {
        Product2 product = new Product2(
            Name = 'Producto no reservable VN RQ106',
            IsActive = true,
            Producto_Reservado__c = false,
            esVehiculo__c = false,
            es_Vehiculo_usado__c = false,
            Codigo_de_Producto__c = 'VN-RQ106-NO-RESERVA'
        );

        Map<String, Schema.RecordTypeInfo> recordTypes =
            Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName();
        if (recordTypes.containsKey('Vehiculos')) {
            product.RecordTypeId = recordTypes.get('Vehiculos').getRecordTypeId();
        }

        insert product;
        return product;
    }

    private static void relateProductToOpportunity(Opportunity opp, Product2 product) {
        Id standardPricebookId = Test.getStandardPricebookId();
        List<PricebookEntry> existingEntries = [
            SELECT Id, IsActive
            FROM PricebookEntry
            WHERE Pricebook2Id = :standardPricebookId
                AND Product2Id = :product.Id
                AND CurrencyIsoCode = :opp.CurrencyIsoCode
            LIMIT 1
        ];

        PricebookEntry entry;
        if (existingEntries.isEmpty()) {
            entry = new PricebookEntry(
                Pricebook2Id = standardPricebookId,
                Product2Id = product.Id,
                UnitPrice = 10000,
                CurrencyIsoCode = opp.CurrencyIsoCode,
                IsActive = true
            );
            insert entry;
        } else {
            entry = existingEntries[0];
            if (!entry.IsActive) {
                entry.IsActive = true;
                update entry;
            }
        }

        OpportunityLineItem line = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = entry.Id,
            Quantity = 1,
            UnitPrice = 10000
        );
        insert line;
    }

    private static VN_RQ106_AnticipoController.DraftSolicitudRequest buildRequest(Id oppId) {
        VN_RQ106_AnticipoController.DraftSolicitudRequest request =
            new VN_RQ106_AnticipoController.DraftSolicitudRequest();
        request.opportunityId = oppId;
        request.monto = 2000;
        request.tipoIngreso = 'Abono';
        request.medioPago = 'Transferencia';
        request.fechaIngreso = Date.today();
        request.referenciaComprobante = 'REF-001';
        request.depositante = 'Cliente de Prueba';
        request.identificacionDepositante = '123456789';
        request.comentariosAsesor = 'Solicitud de prueba VN-RQ106';
        return request;
    }

    private static Id createDraftAnticipo(Id oppId) {
        VN_RQ106_AnticipoController.DraftSolicitudResult result =
            VN_RQ106_AnticipoController.createDraftSolicitud(buildRequest(oppId));
        return result.anticipoId;
    }

    private static void attachEvidence(Id anticipoId) {
        ContentVersion evidence = new ContentVersion(
            Title = 'Evidencia VN RQ106',
            PathOnClient = 'evidencia-vn-rq106.txt',
            VersionData = Blob.valueOf('Evidencia de prueba VN-RQ106'),
            FirstPublishLocationId = anticipoId
        );
        insert evidence;
    }

    @IsTest
    static void getOpportunityContextReturnsBasicData() {
        Opportunity opp = createOpportunity();
        Product2 product = createVehicleProduct();
        relateProductToOpportunity(opp, product);

        Test.startTest();
        VN_RQ106_AnticipoController.OpportunityContext context =
            VN_RQ106_AnticipoController.getOpportunityContext(opp.Id);
        Test.stopTest();

        Opportunity expectedOpportunity = [
            SELECT CurrencyIsoCode, Valor_Total_Oportunidad_FX__c,
                Total_Anticipos_Aprobados__c, Saldo_Pendiente__c
            FROM Opportunity
            WHERE Id = :opp.Id
        ];

        System.assertEquals(opp.Id, context.opportunityId);
        System.assertEquals('Oportunidad VN RQ106', context.opportunityName);
        System.assertEquals(opp.AccountId, context.accountId);
        System.assertNotEquals(null, context.ownerId);
        System.assertEquals(opp.CurrencyIsoCode, context.currencyIsoCode);
        System.assertEquals(
            expectedOpportunity.Valor_Total_Oportunidad_FX__c,
            context.valorTotalOportunidad
        );
        System.assertEquals(
            expectedOpportunity.Total_Anticipos_Aprobados__c,
            context.totalAnticiposAprobados
        );
        System.assertEquals(expectedOpportunity.Saldo_Pendiente__c, context.saldoPendiente);
        System.assertEquals(1, context.products.size());
        System.assertEquals(product.Id, context.products[0].productId);
    }

    @IsTest
    static void getOpportunityContextExcludesProductsThatDoNotMatchLookupFilter() {
        Opportunity opp = createOpportunity();
        Product2 validProduct = createVehicleProduct();
        Product2 invalidProduct = createInvalidVehicleCandidateProduct();
        relateProductToOpportunity(opp, validProduct);
        relateProductToOpportunity(opp, invalidProduct);

        Test.startTest();
        VN_RQ106_AnticipoController.OpportunityContext context =
            VN_RQ106_AnticipoController.getOpportunityContext(opp.Id);
        Test.stopTest();

        Set<Id> productIds = new Set<Id>();
        for (VN_RQ106_AnticipoController.ProductOption product : context.products) {
            productIds.add(product.productId);
        }

        System.assertEquals(1, context.products.size());
        System.assertEquals(true, productIds.contains(validProduct.Id));
        System.assertEquals(false, productIds.contains(invalidProduct.Id));
    }

    @IsTest
    static void createDraftSolicitudCreatesBorrador() {
        Opportunity opp = createOpportunity();
        VN_RQ106_AnticipoController.DraftSolicitudRequest request = buildRequest(opp.Id);

        Test.startTest();
        VN_RQ106_AnticipoController.DraftSolicitudResult result =
            VN_RQ106_AnticipoController.createDraftSolicitud(request);
        Test.stopTest();

        Anticipo__c inserted = [
            SELECT Id, Oportunidad__c, Monto__c, Tipo_Ingreso__c, Medio_Pago__c,
                Fecha_Ingreso__c, Referencia_Comprobante__c, Depositante__c,
                Identificacion_Depositante__c, Comentarios_Asesor__c, Estatus__c,
                Producto__c, CurrencyIsoCode
            FROM Anticipo__c
            WHERE Id = :result.anticipoId
        ];

        System.assertEquals(opp.Id, inserted.Oportunidad__c);
        System.assertEquals(2000, inserted.Monto__c);
        System.assertEquals('Abono', inserted.Tipo_Ingreso__c);
        System.assertEquals('Transferencia', inserted.Medio_Pago__c);
        System.assertEquals('REF-001', inserted.Referencia_Comprobante__c);
        System.assertEquals('Borrador', inserted.Estatus__c);
        System.assertNotEquals('Aplicado', inserted.Estatus__c);
        System.assertEquals(null, inserted.Producto__c);
        System.assertEquals(opp.CurrencyIsoCode, inserted.CurrencyIsoCode);
        System.assertEquals('Borrador', result.estatus);
    }

    @IsTest
    static void createDraftSolicitudUsesOpportunityCurrency() {
        Opportunity opp = createOpportunity('CRC');
        VN_RQ106_AnticipoController.DraftSolicitudRequest request = buildRequest(opp.Id);

        Test.startTest();
        VN_RQ106_AnticipoController.DraftSolicitudResult result =
            VN_RQ106_AnticipoController.createDraftSolicitud(request);
        Test.stopTest();

        Anticipo__c inserted = [
            SELECT Id, CurrencyIsoCode, Estatus__c
            FROM Anticipo__c
            WHERE Id = :result.anticipoId
        ];

        System.assertEquals('CRC', inserted.CurrencyIsoCode);
        System.assertEquals('Borrador', inserted.Estatus__c);
        System.assertNotEquals('Aplicado', inserted.Estatus__c);
    }

    @IsTest
    static void createDraftSolicitudWithReservaStoresProduct() {
        Opportunity opp = createOpportunity();
        Product2 product = createVehicleProduct();
        relateProductToOpportunity(opp, product);

        VN_RQ106_AnticipoController.DraftSolicitudRequest request = buildRequest(opp.Id);
        request.tipoIngreso = 'Reserva de vehículo';
        request.productoId = product.Id;

        Test.startTest();
        VN_RQ106_AnticipoController.DraftSolicitudResult result =
            VN_RQ106_AnticipoController.createDraftSolicitud(request);
        Test.stopTest();

        Anticipo__c inserted = [
            SELECT Id, Estatus__c, Tipo_Ingreso__c, Producto__c, CurrencyIsoCode
            FROM Anticipo__c
            WHERE Id = :result.anticipoId
        ];

        System.assertEquals('Borrador', inserted.Estatus__c);
        System.assertNotEquals('Aplicado', inserted.Estatus__c);
        System.assertEquals('Reserva de vehículo', inserted.Tipo_Ingreso__c);
        System.assertEquals(product.Id, inserted.Producto__c);
        System.assertEquals(opp.CurrencyIsoCode, inserted.CurrencyIsoCode);
    }

    @IsTest
    static void createDraftSolicitudWithReservaWithoutProductFails() {
        Opportunity opp = createOpportunity();

        VN_RQ106_AnticipoController.DraftSolicitudRequest request = buildRequest(opp.Id);
        request.tipoIngreso = 'Reserva de vehículo';

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            VN_RQ106_AnticipoController.createDraftSolicitud(request);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown, 'Reserva de vehículo debe requerir Producto__c.');
        System.assertEquals(0, [SELECT COUNT() FROM Anticipo__c WHERE Oportunidad__c = :opp.Id]);
    }

    @IsTest
    static void sendToTreasuryWithEvidenceChangesStatus() {
        Opportunity opp = createOpportunity();
        Id anticipoId = createDraftAnticipo(opp.Id);
        attachEvidence(anticipoId);

        System.assert(
            [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :anticipoId] > 0,
            'Debe existir evidencia relacionada antes de enviar a Tesorería.'
        );

        Test.startTest();
        VN_RQ106_AnticipoController.DraftSolicitudResult result =
            VN_RQ106_AnticipoController.sendToTreasury(anticipoId);
        Test.stopTest();

        Anticipo__c updated = [
            SELECT Id, Estatus__c
            FROM Anticipo__c
            WHERE Id = :anticipoId
        ];

        System.assertEquals(anticipoId, result.anticipoId);
        System.assertEquals('En validación de Tesorería', result.estatus);
        System.assertEquals('En validación de Tesorería', updated.Estatus__c);
        System.assertNotEquals('Aplicado', updated.Estatus__c);
    }

    @IsTest
    static void sendToTreasuryWithoutEvidenceFailsAndKeepsBorrador() {
        Opportunity opp = createOpportunity();
        Id anticipoId = createDraftAnticipo(opp.Id);

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            VN_RQ106_AnticipoController.sendToTreasury(anticipoId);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        Anticipo__c solicitud = [
            SELECT Id, Estatus__c
            FROM Anticipo__c
            WHERE Id = :anticipoId
        ];

        System.assertEquals(true, exceptionThrown, 'No debe enviar a Tesorería sin evidencia.');
        System.assertEquals('Borrador', solicitud.Estatus__c);
        System.assertNotEquals('Aplicado', solicitud.Estatus__c);
    }

    @IsTest
    static void sendToTreasuryWithNullFails() {
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            VN_RQ106_AnticipoController.sendToTreasury(null);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown, 'La solicitud es obligatoria para enviar a Tesorería.');
    }

    @IsTest
    static void sendToTreasuryWhenStatusIsNotBorradorFails() {
        Opportunity opp = createOpportunity();
        Id anticipoId = createDraftAnticipo(opp.Id);
        attachEvidence(anticipoId);

        Anticipo__c solicitud = new Anticipo__c(
            Id = anticipoId,
            Estatus__c = 'En validación de Tesorería'
        );
        update solicitud;

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            VN_RQ106_AnticipoController.sendToTreasury(anticipoId);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        Anticipo__c unchanged = [
            SELECT Id, Estatus__c
            FROM Anticipo__c
            WHERE Id = :anticipoId
        ];

        System.assertEquals(true, exceptionThrown, 'Solo Borrador debe poder enviarse a Tesorería.');
        System.assertEquals('En validación de Tesorería', unchanged.Estatus__c);
        System.assertNotEquals('Aplicado', unchanged.Estatus__c);
    }
}
