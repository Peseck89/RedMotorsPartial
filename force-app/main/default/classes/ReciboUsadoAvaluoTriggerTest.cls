@isTest
public class ReciboUsadoAvaluoTriggerTest {

    // Método para generar los datos base que se usan en los tests
    private static Opportunity createBaseOportunidad() {
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

        return opp;
    }

    private static Avaluo__c createAvaluo() {
        Avaluo__c avaluo = new Avaluo__c(Name = 'Test Avaluo');
        insert avaluo;
        return avaluo;
    }

    @isTest
    static void testInsertReciboCompleto() {
        Opportunity opp = createBaseOportunidad();
        Avaluo__c avaluo = createAvaluo();

        ReciboUsado__c recibo = new ReciboUsado__c(
            ReciboJefeUsados__c = 2000,
            Marca__c = 'BMW',
            Modelo__c = 'X5',
            Ano__c = '2023',
            Placa__c = 'TEST123',
            Traccion__c = '4x4',
            Oportunidad__c = opp.Id,
            Combustible__c = 'Gasolina',
            Fecha_de_recibo__c = Date.today(),
            Fecha_de_venta__c = Date.today().addDays(10),
            Kilometraje__c = 10000,
            ValorReciboCliente__c = 15000,
            Serecibevehiculo__c = true,
            VehiculoRecibido__c = true,
            Aval_o_de_Veh_culo__c = avaluo.Id
        );

        Test.startTest();
        insert recibo;
        Test.stopTest();

        System.assertNotEquals(null, recibo.Id, 'El recibo debería haberse insertado correctamente.');
    }

    @isTest
    static void testInsertReciboDuplicadoError() {
        Opportunity opp = createBaseOportunidad();
        Avaluo__c avaluo = createAvaluo();

        ReciboUsado__c recibo1 = new ReciboUsado__c(
            ReciboJefeUsados__c = 2000,
            Marca__c = 'BMW',
            Modelo__c = 'X5',
            Ano__c = '2023',
            Placa__c = 'TEST124',
            Traccion__c = '4x4',
            Oportunidad__c = opp.Id,
            Combustible__c = 'Gasolina',
            Fecha_de_recibo__c = Date.today(),
            Fecha_de_venta__c = Date.today().addDays(10),
            Kilometraje__c = 10000,
            ValorReciboCliente__c = 15000,
            Serecibevehiculo__c = true,
            VehiculoRecibido__c = true,
            Aval_o_de_Veh_culo__c = avaluo.Id
        );
        insert recibo1;

        ReciboUsado__c recibo2 = recibo1.clone(false);
        recibo2.Placa__c = 'TEST125';

        Test.startTest();
        try {
            insert recibo2;
            System.assert(false, 'Debería lanzar error por avaluo duplicado.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Este avalúo ya fue marcado'), 'Se esperaba error de validación.');
        }
        Test.stopTest();
    }

    @isTest
    static void testUpdateMarcaComoRecibido() {
        Opportunity opp = createBaseOportunidad();
        Avaluo__c avaluo = createAvaluo();

        ReciboUsado__c recibo = new ReciboUsado__c(
            ReciboJefeUsados__c = 2000,
            Marca__c = 'BMW',
            Modelo__c = 'X5',
            Ano__c = '2023',
            Placa__c = 'TEST126',
            Traccion__c = '4x4',
            Oportunidad__c = opp.Id,
            Combustible__c = 'Gasolina',
            Fecha_de_recibo__c = Date.today(),
            Fecha_de_venta__c = Date.today().addDays(10),
            Kilometraje__c = 10000,
            ValorReciboCliente__c = 15000,
            Serecibevehiculo__c = false,
            VehiculoRecibido__c = false,
            Aval_o_de_Veh_culo__c = avaluo.Id
        );
        insert recibo;

        recibo.Serecibevehiculo__c = true;
        recibo.VehiculoRecibido__c = true;

        Test.startTest();
        update recibo;
        Test.stopTest();

        System.assertEquals(true, recibo.Serecibevehiculo__c);
    }
}