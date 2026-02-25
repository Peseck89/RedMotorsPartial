@isTest
public class AvaluoTriggerTest {
    
    private static final String MARCA = 'Toyota';
    private static final String MODELO = 'Corolla';
    private static final Decimal ANIO = 2020;
    private static final String TRACCION = '4x4';
    private static final String COMBUSTIBLE = 'GASOLINA';
    private static final String TRANSMISION = 'AUTOMATICA';
    private static final String ESTILO = 'HATCHBACK';
    private static final String GRAVAMENES = 'No';
    private static final Decimal CILINDRAJE = 1800;
    private static final String MOTOR = 'ABC123';
    private static final Decimal PUERTAS = 4;
    
    @testSetup
    static void setup() {
        insert new Promedio_Sistema__c(
            Marca__c = MARCA,
            Modelo__c = MODELO,
            Anio_Number__c = ANIO,
            Traccion__c = TRACCION,
            Combustible__c = COMBUSTIBLE,
            Transmision__c = TRANSMISION,
            Total_Valor_Jefe_Usados__c = 50000,
            Cantidad_Registros__c = 2
        );
    }

    private static Avaluo__c createTestAvaluo(String marca, String modelo, Decimal anio, 
                                            String traccion, String combustible, 
                                            Decimal valorSugerido) {
        return new Avaluo__c(
            Marca__c = marca,
            Modelo__c = modelo,
            Anio_Number__c = anio,
            Tracci_n__c = traccion,
            Combustible__c = combustible,
            Trasmision__c = TRANSMISION,
            Estilo_Usado__c = ESTILO,
            Gravamenes_o_Multas__c = GRAVAMENES,
            Cilindraje__c = CILINDRAJE,
            Motor__c = MOTOR,
            N_puertas__c = PUERTAS,
            Valor_Sugerido_Jefe_Usados__c = valorSugerido
        );
    }
    
    @isTest
    static void testBulkOperations() {
        List<Avaluo__c> avaluos = new List<Avaluo__c>();
        for(Integer i=0; i<200; i++) {
            avaluos.add(createTestAvaluo(
                MARCA, MODELO, ANIO, TRACCION, COMBUSTIBLE, 1000 + i
            ));
        }
        
        Test.startTest();
        insert avaluos;
        Test.stopTest();
        
        Promedio_Sistema__c promedio = [SELECT Cantidad_Registros__c FROM Promedio_Sistema__c LIMIT 1];
        System.assertEquals(202, promedio.Cantidad_Registros__c, 'Bulk insert falló');
    }
    
    @isTest
    static void testInsertAvaluoValido() {
        Integer promediosIniciales = [SELECT COUNT() FROM Promedio_Sistema__c];

        List<Avaluo__c> avaluos = new List<Avaluo__c>{
            createTestAvaluo('Nissan', 'Sentra', 2021, '4x2', 'Diésel', 15000),
            createTestAvaluo('Honda', 'Civic', 2019, '4x2', 'Gasolina', 18000),
            createTestAvaluo(MARCA, MODELO, ANIO, TRACCION, COMBUSTIBLE, 20000)
        };
        
        Test.startTest();
        insert avaluos;
        Test.stopTest();
        
        List<Promedio_Sistema__c> promedios = [SELECT Id FROM Promedio_Sistema__c];
        System.assertEquals(3, promedios.size(), 'Creación de promedios falló');
    }
    
    @isTest
    static void testUpdateAvaluoValido() {
        Avaluo__c avaluo = createTestAvaluo(
            MARCA, MODELO, ANIO, TRACCION, COMBUSTIBLE, 20000
        );
        insert avaluo;
        
        Test.startTest();
        avaluo.Valor_Sugerido_Jefe_Usados__c = 25000;
        update avaluo;
        Test.stopTest();
        
        Promedio_Sistema__c promedio = [SELECT Total_Valor_Jefe_Usados__c FROM Promedio_Sistema__c LIMIT 1];
        System.assertEquals(75000, promedio.Total_Valor_Jefe_Usados__c, 'Update falló');
    }
    
    // @isTest
    // static void testDeleteAvaluo() {
    //     Avaluo__c avaluo = createTestAvaluo(
    //         MARCA, MODELO, ANIO, TRACCION, COMBUSTIBLE, 20000
    //     );
    //     insert avaluo;
        
    //     Test.startTest();
    //     delete avaluo;
    //     Test.stopTest();
        
    //     Promedio_Sistema__c promedio = [SELECT Cantidad_Registros__c FROM Promedio_Sistema__c LIMIT 1];
    //     System.assertEquals(2, promedio.Cantidad_Registros__c, 'Delete falló');
    // }
}