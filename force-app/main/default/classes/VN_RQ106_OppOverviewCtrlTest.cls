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
        System.assertEquals('PDF Softland pendiente (evidencia: columna Evidencia)', overview.pdfStatus);
        System.assertEquals('No disponible todavía', overview.retryStatus);
        System.assertEquals('Vehiculo reservado de prueba', overview.reservaStatus);
        System.assertEquals(0, overview.vehicles.size());
        System.assertEquals(1, overview.solicitudes.size());
        System.assertEquals('VINPANTALLA1', overview.solicitudes[0].vin);
        System.assertEquals(0, overview.anticiposAprobados.size());
        System.assertEquals(1, overview.historial.size());
        System.assertEquals('Con evidencia', overview.solicitudes[0].evidenceStatus);
        System.assertEquals('Aprobado por Tesorería', overview.solicitudes[0].comentariosDisplay);
        System.assertEquals(false, overview.solicitudes[0].isApprovedOrApplied);
        System.assertEquals('Aprobado por Tesorería', overview.historial[0].comentario);
    }

    @IsTest
    static void getOverviewUsesAdvisorCommentWhenApprovalCommentIsBlank() {
        Opportunity opp = createOpportunity();

        insert new Anticipo__c(
            Oportunidad__c = opp.Id,
            Tipo_Ingreso__c = 'Abono',
            Medio_Pago__c = 'Transferencia',
            Fecha_Ingreso__c = Date.today(),
            Referencia_Comprobante__c = 'REF-ASESOR',
            Depositante__c = 'Cliente Pantalla 1',
            Monto__c = 1500,
            CurrencyIsoCode = 'USD',
            Estatus__c = 'En validación de Tesorería',
            Comentarios_Asesor__c = 'Comentario asesor visible'
        );

        Test.startTest();
        VN_RQ106_OpportunityOverviewController.Overview overview =
            VN_RQ106_OpportunityOverviewController.getOverview(opp.Id);
        Test.stopTest();

        System.assertEquals(1, overview.solicitudes.size());
        System.assertEquals('Comentario asesor visible', overview.solicitudes[0].comentariosDisplay);
        System.assertEquals('Comentario asesor visible', overview.historial[0].comentario);
    }

    @IsTest
    static void getOverviewOnlyShowsAppliedAndReservedAsMoneyAnticipos() {
        Opportunity opp = createOpportunity();

        insert new List<Anticipo__c>{
            new Anticipo__c(
                Oportunidad__c = opp.Id,
                Tipo_Ingreso__c = 'Abono',
                Medio_Pago__c = 'Transferencia',
                Fecha_Ingreso__c = Date.today(),
                Referencia_Comprobante__c = 'APL',
                Depositante__c = 'Cliente',
                Monto__c = 100,
                CurrencyIsoCode = 'USD',
                Estatus__c = 'Aplicado'
            ),
            new Anticipo__c(
                Oportunidad__c = opp.Id,
                Tipo_Ingreso__c = 'Reserva de vehículo',
                Medio_Pago__c = 'Transferencia',
                Fecha_Ingreso__c = Date.today(),
                Referencia_Comprobante__c = 'RES',
                Depositante__c = 'Cliente',
                Monto__c = 200,
                CurrencyIsoCode = 'USD',
                Estatus__c = 'Vehículo reservado'
            ),
            new Anticipo__c(
                Oportunidad__c = opp.Id,
                Tipo_Ingreso__c = 'Abono',
                Medio_Pago__c = 'Transferencia',
                Fecha_Ingreso__c = Date.today(),
                Referencia_Comprobante__c = 'TES',
                Depositante__c = 'Cliente',
                Monto__c = 300,
                CurrencyIsoCode = 'USD',
                Estatus__c = 'Confirmada por Tesorería'
            ),
            new Anticipo__c(
                Oportunidad__c = opp.Id,
                Tipo_Ingreso__c = 'Abono',
                Medio_Pago__c = 'Transferencia',
                Fecha_Ingreso__c = Date.today(),
                Referencia_Comprobante__c = 'CRE',
                Depositante__c = 'Cliente',
                Monto__c = 400,
                CurrencyIsoCode = 'USD',
                Estatus__c = 'Anticipo creado'
            )
        };

        Test.startTest();
        VN_RQ106_OpportunityOverviewController.Overview overview =
            VN_RQ106_OpportunityOverviewController.getOverview(opp.Id);
        Test.stopTest();

        System.assertEquals(4, overview.solicitudes.size());
        System.assertEquals(4, overview.historial.size());
        System.assertEquals(2, overview.anticiposAprobados.size());

        Set<String> moneyAnticipoStatuses = new Set<String>();
        for (VN_RQ106_OpportunityOverviewController.AnticipoSummary anticipo : overview.anticiposAprobados) {
            moneyAnticipoStatuses.add(anticipo.estatus);
            System.assertEquals(true, anticipo.isApprovedOrApplied);
        }

        System.assertEquals(true, moneyAnticipoStatuses.contains('Aplicado'));
        System.assertEquals(true, moneyAnticipoStatuses.contains('Vehículo reservado'));
        System.assertEquals(false, moneyAnticipoStatuses.contains('Confirmada por Tesorería'));
        System.assertEquals(false, moneyAnticipoStatuses.contains('Anticipo creado'));
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

    @IsTest
    static void getOverviewShowsReservationActionsOnlyForJefeSucursal() {
        Opportunity opp = createOpportunity();
        opp.JefeSucursal__c = UserInfo.getUserId();
        update opp;

        insert new Anticipo__c(
            Oportunidad__c = opp.Id,
            Tipo_Ingreso__c = 'Reserva de vehículo',
            Medio_Pago__c = 'Transferencia',
            Fecha_Ingreso__c = Date.today(),
            Referencia_Comprobante__c = 'RES-ACT',
            Depositante__c = 'Cliente',
            Monto__c = 100,
            CurrencyIsoCode = 'USD',
            Estatus__c = 'Confirmada por Tesorería',
            Estado_Aprobacion_Producto__c = 'Pendiente'
        );

        Test.startTest();
        VN_RQ106_OpportunityOverviewController.Overview overview =
            VN_RQ106_OpportunityOverviewController.getOverview(opp.Id);
        Test.stopTest();

        System.assertEquals(UserInfo.getUserId(), String.valueOf(overview.jefeSucursalId));
        System.assertEquals(1, overview.solicitudes.size());
        System.assertEquals(true, overview.solicitudes[0].canApproveReservation);
        System.assertEquals(true, overview.solicitudes[0].canRejectReservation);
        System.assertEquals(false, overview.solicitudes[0].canResendReservation);
        System.assertEquals('Pendiente', overview.solicitudes[0].estadoAprobacionProducto);
    }

    @IsTest
    static void getOverviewShowsResendOnlyForRejectedReservation() {
        Opportunity opp = createOpportunity();
        opp.JefeSucursal__c = UserInfo.getUserId();
        update opp;

        insert new Anticipo__c(
            Oportunidad__c = opp.Id,
            Tipo_Ingreso__c = 'Reserva de vehículo',
            Medio_Pago__c = 'Transferencia',
            Fecha_Ingreso__c = Date.today(),
            Referencia_Comprobante__c = 'RES-RECH',
            Depositante__c = 'Cliente',
            Monto__c = 100,
            CurrencyIsoCode = 'USD',
            Estatus__c = 'Confirmada por Tesorería',
            Estado_Aprobacion_Producto__c = 'Rechazada'
        );

        Test.startTest();
        VN_RQ106_OpportunityOverviewController.Overview overview =
            VN_RQ106_OpportunityOverviewController.getOverview(opp.Id);
        Test.stopTest();

        System.assertEquals(false, overview.solicitudes[0].canApproveReservation);
        System.assertEquals(false, overview.solicitudes[0].canRejectReservation);
        System.assertEquals(true, overview.solicitudes[0].canResendReservation);
    }

    @IsTest
    static void getOverviewHidesReservationActionsForNonJefeAndNonReservation() {
        Opportunity opp = createOpportunity();

        insert new List<Anticipo__c>{
            new Anticipo__c(
                Oportunidad__c = opp.Id,
                Tipo_Ingreso__c = 'Reserva de vehículo',
                Medio_Pago__c = 'Transferencia',
                Fecha_Ingreso__c = Date.today(),
                Referencia_Comprobante__c = 'RES-NO-JEFE',
                Depositante__c = 'Cliente',
                Monto__c = 100,
                CurrencyIsoCode = 'USD',
                Estatus__c = 'Confirmada por Tesorería',
                Estado_Aprobacion_Producto__c = 'Pendiente'
            ),
            new Anticipo__c(
                Oportunidad__c = opp.Id,
                Tipo_Ingreso__c = 'Abono',
                Medio_Pago__c = 'Transferencia',
                Fecha_Ingreso__c = Date.today(),
                Referencia_Comprobante__c = 'ABO-NO-ACT',
                Depositante__c = 'Cliente',
                Monto__c = 200,
                CurrencyIsoCode = 'USD',
                Estatus__c = 'Confirmada por Tesorería',
                Estado_Aprobacion_Producto__c = 'Pendiente'
            )
        };

        Test.startTest();
        VN_RQ106_OpportunityOverviewController.Overview overview =
            VN_RQ106_OpportunityOverviewController.getOverview(opp.Id);
        Test.stopTest();

        for (VN_RQ106_OpportunityOverviewController.AnticipoSummary solicitud : overview.solicitudes) {
            System.assertEquals(false, solicitud.canApproveReservation);
            System.assertEquals(false, solicitud.canRejectReservation);
            System.assertEquals(false, solicitud.canResendReservation);
        }
    }
}
