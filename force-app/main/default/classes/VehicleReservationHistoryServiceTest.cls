@IsTest
private class VehicleReservationHistoryServiceTest {
    @IsTest
    static void startAndCompleteReservation() {
        Product2 product = new Product2(
            Name = 'Vehiculo Test',
            ProductCode = 'RV-TEST',
            Codigo_de_Producto__c = 'RV-TEST',
            vin__c = 'VIN-RV-TEST'
        );
        insert product;

        Opportunity opportunity = new Opportunity(
            Name = 'Reserva Test',
            BMW_Compania__c = 'Bavarian',
            StageName = 'Oportunidad Calificada',
            CloseDate = Date.today()
        );
        insert opportunity;

        Test.startTest();
        VehicleReservationHistoryService.startReservation(
            product.Id,
            opportunity.Id,
            VehicleReservationHistoryService.ORIGEN_PORTALNET
        );
        VehicleReservationHistoryService.startReservation(
            product.Id,
            opportunity.Id,
            VehicleReservationHistoryService.ORIGEN_PORTALNET
        );
        VehicleReservationHistoryService.completeReservation(
            product.Id,
            opportunity.Id,
            VehicleReservationHistoryService.ORIGEN_PORTALNET,
            'Reingreso de prueba'
        );
        Test.stopTest();

        List<Reserva_vehiculo__c> reservations = [
            SELECT Estado__c, Fecha_Inicio__c, Fecha_Fin__c, Comentarios_Reingreso__c
            FROM Reserva_vehiculo__c
            WHERE Vehiculo__c = :product.Id
        ];
        System.assertEquals(1, reservations.size(), 'No debe duplicar reservas activas.');
        System.assertEquals('Completada', reservations[0].Estado__c);
        System.assertNotEquals(null, reservations[0].Fecha_Inicio__c);
        System.assertNotEquals(null, reservations[0].Fecha_Fin__c);
        System.assertEquals('Reingreso de prueba', reservations[0].Comentarios_Reingreso__c);
    }

    @IsTest
    static void productTriggerCreatesAndCompletesReservationHistory() {
        Product2 product = new Product2(
            Name = 'Vehiculo Trigger Test',
            ProductCode = 'RV-TRIGGER',
            Codigo_de_Producto__c = 'RV-TRIGGER',
            vin__c = 'VIN-RV-TRIGGER',
            es_Vehiculo_usado__c = true,
            IsActive = true,
            Producto_Reservado__c = false
        );
        insert product;

        Opportunity firstOpportunity = new Opportunity(
            Name = 'Reserva Trigger 1',
            BMW_Compania__c = 'Bavarian',
            StageName = 'Oportunidad Calificada',
            CloseDate = Date.today()
        );
        insert firstOpportunity;

        Opportunity secondOpportunity = new Opportunity(
            Name = 'Reserva Trigger 2',
            BMW_Compania__c = 'Bavarian',
            StageName = 'Oportunidad Calificada',
            CloseDate = Date.today()
        );
        insert secondOpportunity;

        Test.startTest();
        product.Producto_Reservado__c = true;
        product.OportunidadReserva__c = firstOpportunity.Id;
        update product;

        product.Producto_Reservado__c = true;
        product.OportunidadReserva__c = secondOpportunity.Id;
        update product;

        product.Producto_Reservado__c = false;
        update product;
        Test.stopTest();

        List<Reserva_vehiculo__c> reservations = [
            SELECT Oportunidad__c, Estado__c, Fecha_Fin__c
            FROM Reserva_vehiculo__c
            WHERE Vehiculo__c = :product.Id
            ORDER BY CreatedDate ASC
        ];

        System.assertEquals(2, reservations.size(), 'Debe existir un historial por cada oportunidad reservada.');
        System.assertEquals(firstOpportunity.Id, reservations[0].Oportunidad__c);
        System.assertEquals('Completada', reservations[0].Estado__c);
        System.assertNotEquals(null, reservations[0].Fecha_Fin__c);
        System.assertEquals(secondOpportunity.Id, reservations[1].Oportunidad__c);
        System.assertEquals('Completada', reservations[1].Estado__c);
        System.assertNotEquals(null, reservations[1].Fecha_Fin__c);
    }
}