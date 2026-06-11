@IsTest
private class VN_RQ106_AnticipoControllerTest {
    private class TreasuryHttpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');

            String body = req.getBody();
            if (body != null && body.contains('"cliente"')) {
                res.setBody('{"operationResult":{"code":"00","description":"HELIOS-TEST-001"}}');
            } else {
                res.setBody('{"access_token":"TOKEN_TEST","token_type":"Bearer","expires_in":3600}');
            }

            return res;
        }
    }

    private static Opportunity createOpportunity() {
        return createOpportunity('USD');
    }

    private static Opportunity createOpportunity(String currencyIsoCode) {
        Account account = new Account(
            Name = 'Cliente VN RQ106',
            codigoSoftland__c = 'C126750'
        );
        insert account;

        Id standardPricebookId = Test.getStandardPricebookId();
        Opportunity opp = new Opportunity(
            Name = 'Oportunidad VN RQ106',
            AccountId = account.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(15),
            Pricebook2Id = standardPricebookId,
            CurrencyIsoCode = currencyIsoCode,
            empresaQueFactura__c = 'Bavarian'
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

    private static Opportunity createOpportunityWithoutAccount() {
        Opportunity opp = new Opportunity(
            Name = 'Oportunidad VN RQ106 Sin Cliente',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(15),
            Pricebook2Id = Test.getStandardPricebookId(),
            CurrencyIsoCode = 'USD'
        );
        insert opp;
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
        request.comentariosAsesor = 'Solicitud de prueba VN-RQ106';
        return request;
    }

    private static Id createDraftAnticipo(Id oppId) {
        VN_RQ106_AnticipoController.DraftSolicitudResult result =
            VN_RQ106_AnticipoController.createDraftSolicitud(buildRequest(oppId));
        return result.anticipoId;
    }

    private static Id createReservationAnticipo(Id oppId, String estadoAprobacionProducto) {
        Product2 product = createVehicleProduct();
        relateProductToOpportunity(new Opportunity(Id = oppId, CurrencyIsoCode = 'USD'), product);

        Anticipo__c solicitud = new Anticipo__c(
            Oportunidad__c = oppId,
            Producto__c = product.Id,
            Tipo_Ingreso__c = 'Reserva de vehículo',
            Medio_Pago__c = 'Transferencia',
            Fecha_Ingreso__c = Date.today(),
            Referencia_Comprobante__c = 'RES-B',
            Depositante__c = 'Cliente Reserva',
            Monto__c = 2000,
            CurrencyIsoCode = 'USD',
            Estatus__c = 'Confirmada por Tesorería',
            Estado_Aprobacion_Producto__c = estadoAprobacionProducto,
            Comentarios_Asesor__c = 'Reserva confirmada por Tesorería'
        );
        insert solicitud;
        return solicitud.Id;
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
        Id draftId = createDraftAnticipo(opp.Id);

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
        System.assertNotEquals(null, context.existingDraft);
        System.assertEquals(draftId, context.existingDraft.anticipoId);
        System.assertEquals('Solicitud de prueba VN-RQ106', context.existingDraft.comentariosAsesor);
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
        System.assertEquals(null, inserted.Identificacion_Depositante__c);
        System.assertEquals(opp.CurrencyIsoCode, inserted.CurrencyIsoCode);
        System.assertEquals('Borrador', result.estatus);
    }

    @IsTest
    static void createDraftSolicitudWithoutRelatedClientFails() {
        Opportunity opp = createOpportunityWithoutAccount();
        VN_RQ106_AnticipoController.DraftSolicitudRequest request = buildRequest(opp.Id);

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            VN_RQ106_AnticipoController.createDraftSolicitud(request);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown, 'La oportunidad debe requerir AccountId.');
        System.assertEquals(0, [SELECT COUNT() FROM Anticipo__c WHERE Oportunidad__c = :opp.Id]);
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
    static void createDraftSolicitudWithoutCommentsFails() {
        Opportunity opp = createOpportunity();
        VN_RQ106_AnticipoController.DraftSolicitudRequest request = buildRequest(opp.Id);
        request.comentariosAsesor = null;

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            VN_RQ106_AnticipoController.createDraftSolicitud(request);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown, 'Comentarios asesor debe ser obligatorio al crear.');
        System.assertEquals(0, [SELECT COUNT() FROM Anticipo__c WHERE Oportunidad__c = :opp.Id]);
    }

    @IsTest
    static void updateDraftSolicitudUpdatesExistingDraftWithoutDuplicate() {
        Opportunity opp = createOpportunity();
        Id anticipoId = createDraftAnticipo(opp.Id);
        attachEvidence(anticipoId);

        VN_RQ106_AnticipoController.DraftSolicitudRequest request = buildRequest(opp.Id);
        request.anticipoId = anticipoId;
        request.comentariosAsesor = 'Comentario actualizado';

        Test.startTest();
        VN_RQ106_AnticipoController.DraftSolicitudResult result =
            VN_RQ106_AnticipoController.updateDraftSolicitud(request);
        Test.stopTest();

        Anticipo__c updated = [
            SELECT Monto__c, Referencia_Comprobante__c, Comentarios_Asesor__c, Estatus__c
            FROM Anticipo__c
            WHERE Id = :anticipoId
        ];

        System.assertEquals(anticipoId, result.anticipoId);
        System.assertEquals(2000, updated.Monto__c);
        System.assertEquals('REF-001', updated.Referencia_Comprobante__c);
        System.assertEquals('Comentario actualizado', updated.Comentarios_Asesor__c);
        System.assertEquals('Borrador', updated.Estatus__c);
        System.assertEquals(1, [SELECT COUNT() FROM Anticipo__c WHERE Oportunidad__c = :opp.Id]);
        System.assertEquals(1, [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :anticipoId]);
    }

    @IsTest
    static void updateDraftSolicitudWithoutCommentsFails() {
        Opportunity opp = createOpportunity();
        Id anticipoId = createDraftAnticipo(opp.Id);

        VN_RQ106_AnticipoController.DraftSolicitudRequest request = buildRequest(opp.Id);
        request.anticipoId = anticipoId;
        request.comentariosAsesor = '';

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            VN_RQ106_AnticipoController.updateDraftSolicitud(request);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown, 'Comentarios asesor debe ser obligatorio al actualizar.');
    }

    @IsTest
    static void updateDraftSolicitudForAnotherOpportunityFails() {
        Opportunity originalOpp = createOpportunity();
        Opportunity anotherOpp = createOpportunity();
        Id anticipoId = createDraftAnticipo(originalOpp.Id);

        VN_RQ106_AnticipoController.DraftSolicitudRequest request = buildRequest(anotherOpp.Id);
        request.anticipoId = anticipoId;

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            VN_RQ106_AnticipoController.updateDraftSolicitud(request);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown, 'No debe actualizar borradores de otra oportunidad.');
    }

    @IsTest
    static void buildTreasuryRequestMapsBavarianCompanyAndOpportunityId() {
        Opportunity opp = createOpportunity();
        opp.empresaQueFactura__c = 'Bavarian';
        update opp;
        Id anticipoId = createDraftAnticipo(opp.Id);
        opp = [
            SELECT Id_Oportunidad__c
            FROM Opportunity
            WHERE Id = :opp.Id
        ];

        Anticipo__c solicitud = getSolicitudForTreasuryBuild(anticipoId);

        SolicitudAprobacionTesoreria request =
            VN_RQ106_AnticipoController.buildTreasuryRequest(solicitud);

        System.assertEquals('RMBAVARIAN', request.compania);
        System.assertEquals('C126750', request.codigoSoftland);
        System.assertEquals('C126750', request.cliente);
        System.assertEquals(opp.Id_Oportunidad__c, request.consecutivoOpportunidad);
        System.assertEquals(null, request.identificationDepositante);
    }

    @IsTest
    static void buildTreasuryRequestMapsOtobayCompany() {
        Opportunity opp = createOpportunity();
        opp.empresaQueFactura__c = 'Otobay';
        update opp;
        Id anticipoId = createDraftAnticipo(opp.Id);

        SolicitudAprobacionTesoreria request =
            VN_RQ106_AnticipoController.buildTreasuryRequest(getSolicitudForTreasuryBuild(anticipoId));

        System.assertEquals('RMOTOBAI', request.compania);
    }

    @IsTest
    static void buildTreasuryRequestWithoutCompanyFails() {
        Opportunity opp = createOpportunity();
        opp.empresaQueFactura__c = null;
        update opp;
        Id anticipoId = createDraftAnticipo(opp.Id);

        Boolean exceptionThrown = false;

        try {
            VN_RQ106_AnticipoController.buildTreasuryRequest(getSolicitudForTreasuryBuild(anticipoId));
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }

        System.assertEquals(true, exceptionThrown, 'Empresa que Factura debe ser obligatoria para payload.');
    }

    @IsTest
    static void solicitudAprobacionTesoreriaKeepsClienteInPayloadShape() {
        String payload = '{"salesforceRequestId":"a4JTEST","codigoSoftland":"C126750","cliente":"C126750",' +
            '"consecutivoOpportunidad":"OPP-001","monto":"1.00","moneda":"USD","fechaPago":"2026-06-10",' +
            '"metodoPago":"Depósito","referenciaBancaria":"REF-001","diferenteCliente":"false",' +
            '"tipoIngreso":"Reserva de vehículo","comentarios":"Comentario","compania":"RMBAVARIAN"}';

        SolicitudAprobacionTesoreria request = SolicitudAprobacionTesoreria.parse(payload);

        System.assertEquals('C126750', request.codigoSoftland);
        System.assertEquals('C126750', request.cliente);
        System.assertEquals('RMBAVARIAN', request.compania);
    }

    @IsTest
    static void solicitudAprobacionTesoreriaCalloutIncludesClienteAndReturnsSuccess() {
        SolicitudAprobacionTesoreria request = new SolicitudAprobacionTesoreria();
        request.codigoSoftland = 'C126750';
        request.cliente = 'C126750';
        request.consecutivoOpportunidad = 'OPP-001';
        request.monto = '1.00';
        request.moneda = 'USD';
        request.fechaPago = '2026-06-10';
        request.metodoPago = 'Depósito';
        request.referenciaBancaria = 'REF-001';
        request.diferenteCliente = 'false';
        request.tipoIngreso = 'Reserva de vehículo';
        request.comentarios = 'Comentario';
        request.compania = 'RMBAVARIAN';

        Test.setMock(HttpCalloutMock.class, new TreasuryHttpMock());

        Test.startTest();
        SolicitudAprobacionTesoreria.RespuestaEstandar response = request.realizarLlamada();
        Test.stopTest();

        System.assertEquals(200, response.codigo);
        System.assertEquals('Éxito', response.estado);
        System.assert(response.mensaje.contains('operationResult'));
    }

    @IsTest
    static void solicitudAprobacionTesoreriaCalloutLoadsEvidenceAndStoresHeliosId() {
        Opportunity opp = createOpportunity();
        Id anticipoId = createDraftAnticipo(opp.Id);
        attachEvidence(anticipoId);

        SolicitudAprobacionTesoreria request = new SolicitudAprobacionTesoreria();
        request.salesforceRequestId = String.valueOf(anticipoId);
        request.codigoSoftland = 'C126750';
        request.cliente = 'C126750';
        request.consecutivoOpportunidad = 'OPP-001';
        request.monto = '1.00';
        request.moneda = 'USD';
        request.fechaPago = '2026-06-10';
        request.metodoPago = 'Depósito';
        request.referenciaBancaria = 'REF-001';
        request.diferenteCliente = 'false';
        request.tipoIngreso = 'Reserva de vehículo';
        request.comentarios = 'Comentario';
        request.compania = 'RMBAVARIAN';

        Test.setMock(HttpCalloutMock.class, new TreasuryHttpMock());

        Test.startTest();
        SolicitudAprobacionTesoreria.RespuestaEstandar response = request.realizarLlamada();
        Test.stopTest();

        Anticipo__c updated = [
            SELECT Identificador_Helios__c
            FROM Anticipo__c
            WHERE Id = :anticipoId
        ];

        System.assertEquals(200, response.codigo);
        System.assertEquals('HELIOS-TEST-001', updated.Identificador_Helios__c);
        System.assertNotEquals(null, request.nombreArchivo);
        System.assertNotEquals(null, request.archivo);
    }

    @IsTest
    static void solicitudAprobacionTesoreriaLegacyEnviarReturnsIdentifier() {
        Opportunity opp = createOpportunity();
        Id anticipoId = createDraftAnticipo(opp.Id);

        Test.setMock(HttpCalloutMock.class, new TreasuryHttpMock());

        Test.startTest();
        String heliosId = SolicitudAprobacionTesoreria.enviar(anticipoId);
        Test.stopTest();

        Anticipo__c updated = [
            SELECT Identificador_Helios__c
            FROM Anticipo__c
            WHERE Id = :anticipoId
        ];

        System.assertEquals('HELIOS-TEST-001', heliosId);
        System.assertEquals('HELIOS-TEST-001', updated.Identificador_Helios__c);
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
            SELECT Id, Estatus__c, Identificador__c, Identificador_Helios__c
            FROM Anticipo__c
            WHERE Id = :anticipoId
        ];

        System.assertEquals(anticipoId, result.anticipoId);
        System.assertEquals('En validación de Tesorería', result.estatus);
        System.assertEquals('En validación de Tesorería', updated.Estatus__c);
        System.assertEquals('HELIOS-TEST-001', updated.Identificador_Helios__c);
        System.assertNotEquals('Aplicado', updated.Estatus__c);
        System.assertEquals(null, updated.Identificador__c, 'No debe guardar idTransaccion en campos legacy.');
    }

    @IsTest
    static void sendToTreasuryWithClientEmailDoesNotCreateMissingEmailTask() {
        Opportunity opp = createOpportunity();
        opp.CorreoElectronicoCliente__c = 'cliente.vn.rq106@example.com';
        update opp;

        Id anticipoId = createDraftAnticipo(opp.Id);
        attachEvidence(anticipoId);

        Test.startTest();
        VN_RQ106_AnticipoController.DraftSolicitudResult result =
            VN_RQ106_AnticipoController.sendToTreasury(anticipoId);
        Test.stopTest();

        System.assertEquals('En validación de Tesorería', result.estatus);
        System.assertEquals(
            0,
            [
                SELECT COUNT()
                FROM Task
                WHERE WhatId = :opp.Id
                    AND Subject = :VN_RQ106_AnticipoController.MISSING_CLIENT_EMAIL_TASK_SUBJECT
            ],
            'No debe crear incidente si Opportunity.CorreoElectronicoCliente__c tiene valor.'
        );
    }

    @IsTest
    static void sendToTreasuryUsesContactEmailWhenOpportunityEmailIsBlank() {
        Opportunity opp = createOpportunity();
        Contact contact = new Contact(
            AccountId = opp.AccountId,
            LastName = 'Contacto VN RQ106',
            Email = 'contacto.vn.rq106@example.com'
        );
        insert contact;

        opp.CorreoElectronicoCliente__c = null;
        opp.contacto__c = contact.Id;
        update opp;

        Id anticipoId = createDraftAnticipo(opp.Id);
        attachEvidence(anticipoId);

        Test.startTest();
        VN_RQ106_AnticipoController.DraftSolicitudResult result =
            VN_RQ106_AnticipoController.sendToTreasury(anticipoId);
        Test.stopTest();

        System.assertEquals('En validación de Tesorería', result.estatus);
        System.assertEquals(
            0,
            [
                SELECT COUNT()
                FROM Task
                WHERE WhatId = :opp.Id
                    AND Subject = :VN_RQ106_AnticipoController.MISSING_CLIENT_EMAIL_TASK_SUBJECT
            ],
            'No debe crear incidente si el contacto de la oportunidad tiene Email.'
        );
    }

    @IsTest
    static void sendToTreasuryWithoutClientEmailCreatesTaskAndContinues() {
        Opportunity opp = createOpportunity();
        opp.CorreoElectronicoCliente__c = null;
        opp.contacto__c = null;
        update opp;

        Id anticipoId = createDraftAnticipo(opp.Id);
        attachEvidence(anticipoId);

        Test.startTest();
        VN_RQ106_AnticipoController.DraftSolicitudResult result =
            VN_RQ106_AnticipoController.sendToTreasury(anticipoId);
        Test.stopTest();

        Opportunity updatedOpp = [
            SELECT OwnerId
            FROM Opportunity
            WHERE Id = :opp.Id
        ];
        Anticipo__c updatedAnticipo = [
            SELECT Estatus__c
            FROM Anticipo__c
            WHERE Id = :anticipoId
        ];
        Task incident = [
            SELECT OwnerId, WhatId, Subject, Description, Status, Priority
            FROM Task
            WHERE WhatId = :opp.Id
                AND Subject = :VN_RQ106_AnticipoController.MISSING_CLIENT_EMAIL_TASK_SUBJECT
            LIMIT 1
        ];

        System.assertEquals('En validación de Tesorería', result.estatus);
        System.assertEquals('En validación de Tesorería', updatedAnticipo.Estatus__c);
        System.assertEquals(updatedOpp.OwnerId, incident.OwnerId);
        System.assertEquals(opp.Id, incident.WhatId);
        System.assertEquals('Open', incident.Status);
        System.assertEquals('Normal', incident.Priority);
        System.assert(
            incident.Description.contains(String.valueOf(opp.Id)),
            'La descripcion debe referenciar la Opportunity.'
        );
        System.assert(
            incident.Description.contains(String.valueOf(anticipoId)),
            'La descripcion debe referenciar el Anticipo.'
        );
        System.assert(
            incident.Description.contains('corregir correo'),
            'La descripcion debe pedir corregir correo.'
        );
    }

    @IsTest
    static void sendToTreasuryWithoutClientEmailDoesNotDuplicateExistingTask() {
        Opportunity opp = createOpportunity();
        opp.CorreoElectronicoCliente__c = null;
        opp.contacto__c = null;
        update opp;

        Id anticipoId = createDraftAnticipo(opp.Id);
        attachEvidence(anticipoId);

        Opportunity currentOpp = [
            SELECT OwnerId
            FROM Opportunity
            WHERE Id = :opp.Id
        ];
        insert new Task(
            WhatId = opp.Id,
            OwnerId = currentOpp.OwnerId,
            Subject = VN_RQ106_AnticipoController.MISSING_CLIENT_EMAIL_TASK_SUBJECT,
            Description = 'Anticipo existente: ' + String.valueOf(anticipoId),
            Status = 'Open',
            Priority = 'Normal'
        );

        Test.startTest();
        VN_RQ106_AnticipoController.DraftSolicitudResult result =
            VN_RQ106_AnticipoController.sendToTreasury(anticipoId);
        Test.stopTest();

        System.assertEquals('En validación de Tesorería', result.estatus);
        System.assertEquals(
            1,
            [
                SELECT COUNT()
                FROM Task
                WHERE WhatId = :opp.Id
                    AND Subject = :VN_RQ106_AnticipoController.MISSING_CLIENT_EMAIL_TASK_SUBJECT
            ],
            'No debe duplicar la Task si ya referencia el mismo Anticipo.'
        );
    }

    @IsTest
    static void sendToTreasuryWhenTreasuryRequestFailsKeepsBorrador() {
        Opportunity opp = createOpportunity();
        Id anticipoId = createDraftAnticipo(opp.Id);
        attachEvidence(anticipoId);

        Boolean exceptionThrown = false;

        Test.startTest();
        VN_RQ106_AnticipoController.simulateTreasuryFailure = true;
        try {
            VN_RQ106_AnticipoController.sendToTreasury(anticipoId);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        } finally {
            VN_RQ106_AnticipoController.simulateTreasuryFailure = false;
        }
        Test.stopTest();

        Anticipo__c unchanged = [
            SELECT Id, Estatus__c
            FROM Anticipo__c
            WHERE Id = :anticipoId
        ];

        System.assertEquals(true, exceptionThrown, 'Debe fallar si Tesorería no responde 200.');
        System.assertEquals('Borrador', unchanged.Estatus__c);
    }

    @IsTest
    static void sendToTreasuryWhenTreasuryResponseIsNotSuccessfulKeepsBorrador() {
        Opportunity opp = createOpportunity();
        Id anticipoId = createDraftAnticipo(opp.Id);
        attachEvidence(anticipoId);

        Boolean exceptionThrown = false;

        Test.startTest();
        VN_RQ106_AnticipoController.simulatedTreasuryStatusCode = 503;
        VN_RQ106_AnticipoController.simulatedTreasuryMessage = 'Service Unavailable';
        try {
            VN_RQ106_AnticipoController.sendToTreasury(anticipoId);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        } finally {
            VN_RQ106_AnticipoController.simulatedTreasuryStatusCode = 200;
            VN_RQ106_AnticipoController.simulatedTreasuryMessage = 'Solicitud validada en test.';
        }
        Test.stopTest();

        Anticipo__c unchanged = [
            SELECT Id, Estatus__c, Identificador_Helios__c
            FROM Anticipo__c
            WHERE Id = :anticipoId
        ];

        System.assertEquals(true, exceptionThrown, 'Debe fallar si Tesorería no confirma éxito.');
        System.assertEquals('Borrador', unchanged.Estatus__c);
        System.assertEquals(null, unchanged.Identificador_Helios__c);
    }

    @IsTest
    static void sendToTreasuryWhenHeliosIdIsMissingKeepsBorrador() {
        Opportunity opp = createOpportunity();
        Id anticipoId = createDraftAnticipo(opp.Id);
        attachEvidence(anticipoId);

        Boolean exceptionThrown = false;

        Test.startTest();
        VN_RQ106_AnticipoController.simulatedHeliosIdentifier = null;
        try {
            VN_RQ106_AnticipoController.sendToTreasury(anticipoId);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        } finally {
            VN_RQ106_AnticipoController.simulatedHeliosIdentifier = 'HELIOS-TEST-001';
        }
        Test.stopTest();

        Anticipo__c unchanged = [
            SELECT Id, Estatus__c, Identificador_Helios__c
            FROM Anticipo__c
            WHERE Id = :anticipoId
        ];

        System.assertEquals(true, exceptionThrown, 'Debe fallar si Helios no devuelve identificador.');
        System.assertEquals('Borrador', unchanged.Estatus__c);
        System.assertEquals(null, unchanged.Identificador_Helios__c);
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
    static void sendToTreasuryWithoutCommentsFailsAndKeepsBorrador() {
        Opportunity opp = createOpportunity();
        Id anticipoId = createDraftAnticipo(opp.Id);
        attachEvidence(anticipoId);
        update new Anticipo__c(Id = anticipoId, Comentarios_Asesor__c = null);

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

        System.assertEquals(true, exceptionThrown, 'No debe enviar sin comentarios.');
        System.assertEquals('Borrador', solicitud.Estatus__c);
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

    @IsTest
    static void approveReservationByJefeUpdatesProductApprovalAndStatus() {
        Opportunity opp = createOpportunity();
        opp.JefeSucursal__c = UserInfo.getUserId();
        update opp;
        Id anticipoId = createReservationAnticipo(opp.Id, null);

        Test.startTest();
        VN_RQ106_AnticipoController.DraftSolicitudResult result =
            VN_RQ106_AnticipoController.approveReservation(anticipoId, 'Aprobado producto');
        Test.stopTest();

        Anticipo__c updated = [
            SELECT Estatus__c, Estado_Aprobacion_Producto__c, Comentarios_Aprobacion_Rechazo__c
            FROM Anticipo__c
            WHERE Id = :anticipoId
        ];

        System.assertEquals('Vehículo reservado', result.estatus);
        System.assertEquals('Aprobada', result.estadoAprobacionProducto);
        System.assertEquals('Vehículo reservado', updated.Estatus__c);
        System.assertEquals('Aprobada', updated.Estado_Aprobacion_Producto__c);
        System.assertEquals('Aprobado producto', updated.Comentarios_Aprobacion_Rechazo__c);
    }

    @IsTest
    static void rejectReservationByJefeKeepsTreasuryStatusAndRequiresComment() {
        Opportunity opp = createOpportunity();
        opp.JefeSucursal__c = UserInfo.getUserId();
        update opp;
        Id anticipoId = createReservationAnticipo(opp.Id, 'Pendiente');

        Test.startTest();
        VN_RQ106_AnticipoController.DraftSolicitudResult result =
            VN_RQ106_AnticipoController.rejectReservation(anticipoId, 'Rechazo por validacion producto');
        Test.stopTest();

        Anticipo__c updated = [
            SELECT Estatus__c, Estado_Aprobacion_Producto__c, Comentarios_Aprobacion_Rechazo__c
            FROM Anticipo__c
            WHERE Id = :anticipoId
        ];

        System.assertEquals('Confirmada por Tesorería', result.estatus);
        System.assertEquals('Rechazada', result.estadoAprobacionProducto);
        System.assertEquals('Confirmada por Tesorería', updated.Estatus__c);
        System.assertEquals('Rechazada', updated.Estado_Aprobacion_Producto__c);
        System.assertEquals('Rechazo por validacion producto', updated.Comentarios_Aprobacion_Rechazo__c);
    }

    @IsTest
    static void rejectReservationWithoutCommentFails() {
        Opportunity opp = createOpportunity();
        opp.JefeSucursal__c = UserInfo.getUserId();
        update opp;
        Id anticipoId = createReservationAnticipo(opp.Id, 'Pendiente');

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            VN_RQ106_AnticipoController.rejectReservation(anticipoId, '');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        Anticipo__c unchanged = [
            SELECT Estatus__c, Estado_Aprobacion_Producto__c
            FROM Anticipo__c
            WHERE Id = :anticipoId
        ];

        System.assertEquals(true, exceptionThrown, 'El rechazo debe exigir comentario.');
        System.assertEquals('Confirmada por Tesorería', unchanged.Estatus__c);
        System.assertEquals('Pendiente', unchanged.Estado_Aprobacion_Producto__c);
    }

    @IsTest
    static void resendReservationRequestResetsProductApprovalToPending() {
        Opportunity opp = createOpportunity();
        opp.JefeSucursal__c = UserInfo.getUserId();
        update opp;
        Id anticipoId = createReservationAnticipo(opp.Id, 'Rechazada');

        Test.startTest();
        VN_RQ106_AnticipoController.DraftSolicitudResult result =
            VN_RQ106_AnticipoController.resendReservationRequest(anticipoId, 'Reenvio solicitado');
        Test.stopTest();

        Anticipo__c updated = [
            SELECT Estatus__c, Estado_Aprobacion_Producto__c, Comentarios_Aprobacion_Rechazo__c
            FROM Anticipo__c
            WHERE Id = :anticipoId
        ];

        System.assertEquals('Confirmada por Tesorería', result.estatus);
        System.assertEquals('Pendiente', result.estadoAprobacionProducto);
        System.assertEquals('Confirmada por Tesorería', updated.Estatus__c);
        System.assertEquals('Pendiente', updated.Estado_Aprobacion_Producto__c);
        System.assertEquals('Reenvio solicitado', updated.Comentarios_Aprobacion_Rechazo__c);
    }

    @IsTest
    static void reservationDecisionByNonJefeFails() {
        Opportunity opp = createOpportunity();
        Id anticipoId = createReservationAnticipo(opp.Id, 'Pendiente');

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            VN_RQ106_AnticipoController.approveReservation(anticipoId, null);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        Anticipo__c unchanged = [
            SELECT Estatus__c, Estado_Aprobacion_Producto__c
            FROM Anticipo__c
            WHERE Id = :anticipoId
        ];

        System.assertEquals(true, exceptionThrown, 'Solo JefeSucursal__c debe decidir reservas.');
        System.assertEquals('Confirmada por Tesorería', unchanged.Estatus__c);
        System.assertEquals('Pendiente', unchanged.Estado_Aprobacion_Producto__c);
    }

    private static Anticipo__c getSolicitudForTreasuryBuild(Id anticipoId) {
        return [
            SELECT Id, Name, Estatus__c, Monto__c, CurrencyIsoCode, Fecha_Ingreso__c,
                Medio_Pago__c, Referencia_Comprobante__c, Tipo_Ingreso__c,
                Comentarios_Asesor__c, Oportunidad__c, Oportunidad__r.Name,
                Oportunidad__r.Id_Oportunidad__c, Oportunidad__r.empresaQueFactura__c,
                Oportunidad__r.Account.Name, Oportunidad__r.Account.codigoSoftland__c
            FROM Anticipo__c
            WHERE Id = :anticipoId
        ];
    }
}
