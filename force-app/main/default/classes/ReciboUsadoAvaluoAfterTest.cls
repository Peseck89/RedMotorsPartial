@isTest
public class ReciboUsadoAvaluoAfterTest {
    @isTest static void testReciboUsadoAfterInsertUpdateDelete() {
        Account acc = new Account(
            Name = 'Test Account',
            Cedula__c = '905120921',
            Tipo_de_Documento__c = '01'
        );
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = acc.Id
        );
        insert opp;

        Avaluo__c avaluo = new Avaluo__c(Name = 'Test Avaluo');
        insert avaluo;

        // Insert con marca activa
        ReciboUsado__c r1 = new ReciboUsado__c(
            Aval_o_de_Veh_culo__c = avaluo.Id,
            Serecibevehiculo__c = true,
            VehiculoRecibido__c = true,
            Placa__c = 'TEST123',
            Oportunidad__c = opp.Id,
            Marca__c = 'Nissan',
            Modelo__c = 'Note',
            Ano__c = '2023',
            Traccion__c = '4x4',
            Combustible__c = 'Gasolina',
            Kilometraje__c = 5000,
            Fecha_de_recibo__c = Date.today(),
            Fecha_de_venta__c = Date.today().addDays(15),
            ValorReciboCliente__c = 17000
        );
        insert r1;

        // Desmarcar por update
        r1.Serecibevehiculo__c = false;
        r1.VehiculoRecibido__c = false;
        update r1;

        // Insert otro válido para evitar desmarque
        ReciboUsado__c r2 = r1.clone(false);
        r2.Serecibevehiculo__c = true;
        r2.VehiculoRecibido__c = true;
        r2.Placa__c = 'TEST456';
        insert r2;

        // Delete uno → aún debe quedar otro
        delete r2;

        // Delete final → ahora sí puede desmarcar
        delete r1;
    }
}