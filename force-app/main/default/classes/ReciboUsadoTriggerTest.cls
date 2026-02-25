@isTest
public class ReciboUsadoTriggerTest {
    
    private static final String MARCA = 'Toyota';
    private static final String MODELO = 'Hilux';
    private static final String ANO = '2023';
    private static final String TRACCION = '4x4';
    private static final String COMBUSTIBLE = 'GASOLINA';
    private static final String TRANSMISION = 'AUTOMATICA';
    private static final String ESTILO = 'SEDAN';
    private static final String PLACA = 'ABC123';
    private static final Decimal VALOR_RECIBO = 50000;
    
    @testSetup
    static void setup() {
        // Crear Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(10)
        );
        insert opp;
        
        // Crear promedio existente
        insert new Promedio_Sistema__c(
            Marca__c = MARCA,
            Modelo__c = MODELO,
            Anio_Number__c = Decimal.valueOf(ANO),
            Traccion__c = TRACCION,
            Combustible__c = COMBUSTIBLE,
            Transmision__c = TRANSMISION,
            Total_Valor_Jefe_Usados__c = 150000,
            Cantidad_Registros__c = 2
        );
    }
    
    private static ReciboUsado__c createTestRecibo(Id oppId, String marca, String modelo, String ano, 
                                                 String traccion, String combustible, 
                                                 String transmision, Decimal valor) {
        return new ReciboUsado__c(
            Placa__c = PLACA,
            Serecibevehiculo__c = true,
            ReciboJefeUsados__c = valor,
            Marca__c = marca,
            Modelo__c = modelo,
            Ano__c = ano,
            Oportunidad__c = oppId,
            Fecha_de_recibo__c = Date.today(),
            Traccion__c = traccion,
            Combustible__c = combustible,
            Trasmision__c = transmision,
            EstiloUsado__c = ESTILO,
            N_puertas__c = 4,
            Kilometraje__c = 15000,
            Color__c = 'Blanco',
            Version__c = '2.0'
        );
    }
    
    // @isTest
    // static void testAllTriggerOperations() {
    //     Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        
    //     // Test Insert
    //     ReciboUsado__c recibo = createTestRecibo(
    //         oppId, MARCA, MODELO, ANO, TRACCION, COMBUSTIBLE, TRANSMISION, VALOR_RECIBO
    //     );
        
    //     Test.startTest();
    //     insert recibo;
    //     Test.stopTest();
        
    //     // Verificar que se actualizó el promedio
    //     Promedio_Sistema__c promedio = [
    //         SELECT Cantidad_Registros__c, Total_Valor_Jefe_Usados__c 
    //         FROM Promedio_Sistema__c 
    //         WHERE Marca__c = :MARCA AND Modelo__c = :MODELO AND Anio_Number__c = :Decimal.valueOf(ANO)
    //         LIMIT 1
    //     ];
    //     System.assertEquals(2, promedio.Cantidad_Registros__c, 'Insert falló - Cantidad');
    //     System.assertEquals(150000 + VALOR_RECIBO, promedio.Total_Valor_Jefe_Usados__c, 'Insert falló - Valor');
    // }
    
    // @isTest
    // static void testUpdateOperation() {
    //     Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        
    //     // Insertar recibo primero
    //     ReciboUsado__c recibo = createTestRecibo(
    //         oppId, MARCA, MODELO, ANO, TRACCION, COMBUSTIBLE, TRANSMISION, VALOR_RECIBO
    //     );
    //     insert recibo;
        
    //     // Test Update
    //     Decimal nuevoValor = 60000;
    //     recibo.ReciboJefeUsados__c = nuevoValor;
        
    //     Test.startTest();
    //     update recibo;
    //     Test.stopTest();
        
    //     // Verificar actualización
    //     Promedio_Sistema__c promedio = [
    //         SELECT Cantidad_Registros__c, Total_Valor_Jefe_Usados__c 
    //         FROM Promedio_Sistema__c 
    //         WHERE Marca__c = :MARCA AND Modelo__c = :MODELO AND Anio_Number__c = :Decimal.valueOf(ANO)
    //         LIMIT 1
    //     ];
    //     System.assertEquals(3, promedio.Cantidad_Registros__c, 'Update falló - Cantidad');
    //     System.assertEquals(100000 + nuevoValor, promedio.Total_Valor_Jefe_Usados__c, 'Update falló - Valor');
    // }
    
    @isTest
    static void testDeleteOperation() {
        Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        
        // Insertar recibo primero
        ReciboUsado__c recibo = createTestRecibo(
            oppId, MARCA, MODELO, ANO, TRACCION, COMBUSTIBLE, TRANSMISION, VALOR_RECIBO
        );
        insert recibo;
        
        // Test Delete
        Test.startTest();
        delete recibo;
        Test.stopTest();
        
        // Verificar eliminación
        Promedio_Sistema__c promedio = [
            SELECT Cantidad_Registros__c, Total_Valor_Jefe_Usados__c 
            FROM Promedio_Sistema__c 
            WHERE Marca__c = :MARCA AND Modelo__c = :MODELO AND Anio_Number__c = :Decimal.valueOf(ANO)
            LIMIT 1
        ];
        System.assertEquals(3, promedio.Cantidad_Registros__c, 'Delete falló - Cantidad');
        System.assertEquals(200000, promedio.Total_Valor_Jefe_Usados__c, 'Delete falló - Valor');
    }
    
    @isTest
    static void testBulkOperations() {
        Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        List<ReciboUsado__c> recibos = new List<ReciboUsado__c>();
        
        for(Integer i = 0; i < 200; i++) {
            recibos.add(new ReciboUsado__c(
                Placa__c = 'BULK' + i,
                Serecibevehiculo__c = true,
                ReciboJefeUsados__c = VALOR_RECIBO + i,
                Marca__c = MARCA,
                Modelo__c = MODELO,
                Ano__c = ANO,
                Oportunidad__c = oppId,
                Fecha_de_recibo__c = Date.today(),
                Traccion__c = TRACCION,
                Combustible__c = COMBUSTIBLE,
                Trasmision__c = TRANSMISION,
                EstiloUsado__c = ESTILO,
                N_puertas__c = 4,
                Kilometraje__c = 15000,
                Color__c = 'Blanco',
                Version__c = '2.0'
            ));
        }
        
        Test.startTest();
        insert recibos;
        Test.stopTest();
        
        // Verificar bulk insert
        Promedio_Sistema__c promedio = [
            SELECT Cantidad_Registros__c 
            FROM Promedio_Sistema__c 
            WHERE Marca__c = :MARCA AND Modelo__c = :MODELO AND Anio_Number__c = :Decimal.valueOf(ANO)
            LIMIT 1
        ];
        System.assertEquals(202, promedio.Cantidad_Registros__c, 'Bulk insert falló');
    }
    
    // @isTest
    // static void testRegistrosFueraDePeriodo() {
    //     Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        
    //     // Crear recibo con fecha antigua (fuera del período de 6 meses)
    //     ReciboUsado__c recibo = createTestRecibo(
    //         oppId, MARCA, MODELO, ANO, TRACCION, COMBUSTIBLE, TRANSMISION, VALOR_RECIBO
    //     );
        
    //     // Configurar fecha antigua ANTES de insertar
    //     recibo.CreatedDate = DateTime.now().addMonths(-7);
        
    //     Test.startTest();
    //     insert recibo;
    //     Test.stopTest();
        
    //     // Verificar que NO se actualizó el promedio
    //     Promedio_Sistema__c promedio = [
    //         SELECT Cantidad_Registros__c 
    //         FROM Promedio_Sistema__c 
    //         WHERE Marca__c = :MARCA AND Modelo__c = :MODELO AND Anio_Number__c = :Decimal.valueOf(ANO)
    //         LIMIT 1
    //     ];
    //     System.assertEquals(2, promedio.Cantidad_Registros__c, 'Registro fuera de período no debería afectar promedio');
    // }
}