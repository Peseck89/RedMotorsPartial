@IsTest
private class VN_RQ106_OppOverviewCtrlTest {
    private static Opportunity createOpportunity() {
        Account account = new Account(Name = 'Cliente Pantalla 1 VN-RQ106');
        insert account;

        Opportunity opp = new Opportunity(
            Name = 'Opportunity Pantalla 1 VN-RQ106',
            AccountId = account.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10),
            Pricebook2Id = Test.getStandardPricebookId(),
            CurrencyIsoCode = 'USD',
            Estado_Anticipo__c = 'Pendiente',
            Tiene_Vehiculos_Reservados__c = true,
            Vehiculos_Reservados__c = 'Vehiculo reservado de prueba'
        );
        insert opp;
        return opp;
    }

    private static Product2 createVehicle() {
        Product2 product = new Product2(
            Name = 'BMW VN-RQ106',
            IsActive = true,
            Producto_Reservado__c = false,
            esVehiculo__c = true,
            vin__c = 'VINPANTALLA1',
            Codigo_de_Producto__c = 'VN-RQ106-P1'
        );

        Map<String, Schema.RecordTypeInfo> recordTypes =
            Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName();
        if (recordTypes.containsKey('Vehiculos')) {
            product.RecordTypeId = recordTypes.get('Vehiculos').getRecordTypeId();
        }

        insert product;
        return product;
    }

    private static void relateProduct(Opportunity opp, Product2 product) {
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

        insert new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = entry.Id,
            Quantity = 1,
            UnitPrice = 10000
        );
    }

    @IsTest
    static void getOverviewReturnsOpportunityAnticiposAndPlaceholders() {
        Opportunity opp = createOpportunity();
        Product2 product = createVehicle();

        Anticipo__c solicitud = new Anticipo__c(
            Oportunidad__c = opp.Id,
            Producto__c = product.Id,
            Tipo_Ingreso__c = 'Reserva de vehículo',
            Medio_Pago__c = 'Transferencia',
            Fecha_Ingreso__c = Date.today(),
            Referencia_Comprobante__c = 'REF-P1',
            Depositante__c = 'Cliente Pantalla 1',
            Monto__c = 1500,
            CurrencyIsoCode = 'USD',
            Estatus__c = 'Confirmada por Tesorería',
            Comentarios_Asesor__c = 'Comentario asesor',
            Comentarios_Aprobacion_Rechazo__c = 'Aprobado por Tesorería'
        );
        insert solicitud;

        ContentVersion evidence = new ContentVersion(
            Title = 'Evidencia Pantalla 1',
            PathOnClient = 'evidencia-pantalla-1.txt',
            VersionData = Blob.valueOf('Evidencia Pantalla 1 VN-RQ106'),
            FirstPublishLocationId = solicitud.Id
        );
        insert evidence;

        Test.startTest();
        VN_RQ106_OpportunityOverviewController.Overview overview =
            VN_RQ106_OpportunityOverviewController.getOverview(opp.Id);
        Test.stopTest();

        System.assertEquals(opp.Id, overview.opportunityId);
        System.assertEquals('Cliente Pantalla 1 VN-RQ106', overview.accountName);
        System.assertEquals('Prospecting', overview.stageName);
        System.assertEquals('Pendiente de integración Softland', overview.pdfStatus);
        System.assertEquals('No disponible todavía', overview.retryStatus);
        System.assertEquals('Vehiculo reservado de prueba', overview.reservaStatus);
        System.assertEquals(0, overview.vehicles.size());
        System.assertEquals(1, overview.solicitudes.size());
        System.assertEquals('VINPANTALLA1', overview.solicitudes[0].vin);
        System.assertEquals(1, overview.anticiposAprobados.size());
        System.assertEquals(1, overview.historial.size());
        System.assertEquals('Con evidencia', overview.solicitudes[0].evidenceStatus);
        System.assertEquals(true, overview.solicitudes[0].isApprovedOrApplied);
        System.assertEquals('Aprobado por Tesorería', overview.historial[0].comentario);
    }

    @IsTest
    static void getOverviewFlagsCorrectionAndIntegrationError() {
        Opportunity opp = createOpportunity();

        insert new List<Anticipo__c>{
            new Anticipo__c(
                Oportunidad__c = opp.Id,
                Tipo_Ingreso__c = 'Abono',
                Medio_Pago__c = 'Transferencia',
                Fecha_Ingreso__c = Date.today(),
                Referencia_Comprobante__c = 'CORR',
                Depositante__c = 'Cliente',
                Monto__c = 100,
                CurrencyIsoCode = 'USD',
                Estatus__c = 'Corrección requerida por Tesorería'
            ),
            new Anticipo__c(
                Oportunidad__c = opp.Id,
                Tipo_Ingreso__c = 'Abono',
                Medio_Pago__c = 'Transferencia',
                Fecha_Ingreso__c = Date.today(),
                Referencia_Comprobante__c = 'ERR',
                Depositante__c = 'Cliente',
                Monto__c = 200,
                CurrencyIsoCode = 'USD',
                Estatus__c = 'Error de integración'
            )
        };

        Test.startTest();
        VN_RQ106_OpportunityOverviewController.Overview overview =
            VN_RQ106_OpportunityOverviewController.getOverview(opp.Id);
        Test.stopTest();

        System.assertEquals(true, overview.correccionSolicitada);
        System.assertEquals(true, overview.errorIntegracion);
        System.assertEquals(false, overview.reintentoAutorizado);
        System.assertEquals(2, overview.solicitudes.size());
    }

    @IsTest
    static void getOverviewWithNullOpportunityFails() {
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            VN_RQ106_OpportunityOverviewController.getOverview(null);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown);
    }
}
