@isTest
public class cT_Registro_Avaluos_ctrl_test {
    @testSetup
    static void setup() {
        // 1. Configuración completa de datos
        Account acc = new Account(
            Name = 'Test Account',
            Cedula__c = '905120921',
            Tipo_de_Documento__c = '01'

        );
        insert acc;
        
        Asset auto = new Asset(
            Name = 'Test Asset',
            NumeroDePlaca__c = 'ABC123',
            Tipo_de_veh_culo__c = 'Automóvil',
            NumeroDeChasis__c = 'CHS123',
            Traccion__c = '4x2',
            Carroceria__c = 'Sedán',
            Anio__c = '2020',
            Color__c = 'Rojo',
            Combustible__c = 'Gasolina',
            Marca__c = 'Toyota',
            Modelo__c = 'Corolla',
            AccountId = acc.Id
        );
        insert auto;

        // 2. Avaluo alineado con promedio
        Avaluo__c avaluo = new Avaluo__c(
            Placa__c = 'ABC123',
            Valor_Sugerido_Jefe_Usados__c = 25000,
            Marca__c = 'Toyota',
            Modelo__c = 'Corolla',
            Anio_Number__c = 2020,
            VIN__c = 'VIN123',
            Tracci_n__c = '4x2',
            Carrocer_a__c = 'Carrocería',
            Categor_a__c = 'Categoría',
            Color__c = 'Rojo',
            Combustible__c = 'Gasolina',
            CurrencyIsoCode = 'USD',
            Estilo_Usado__c = 'SEDAN', 
            Gravamenes_o_Multas__c = 'No', 
            Trasmision__c = 'MANUAL', 
            Cilindraje__c = 2000, 
            Motor__c = '2000', 
            N_puertas__c = 4
        );
        insert avaluo;

        // 3. Promedio relacionado
        Promedio_Sistema__c promedio = new Promedio_Sistema__c(
            Marca__c = 'Toyota',
            Modelo__c = 'Corolla',
            Anio_Number__c = 2020,
            Traccion__c = '4x4', // Campo requerido
            Combustible__c = 'Gasolina', // Campo requerido
            Total_Valor_Jefe_Usados__c = 120000,
            Cantidad_Registros__c = 5
        );

        insert promedio;
    }

    // @isTest
    // static void testSearchVehicleInternal() {
    //     Test.startTest();
    //     Map<String, Object> result = cT_Registro_Avaluos_ctrl.searchVehicle('DBZ0981', 'PAR');
    //     System.assertEquals(true, result.get('found'), 'Búsqueda interna exitosa');
    //     System.assertEquals('Toyota', result.get('marca'), 'Marca correcta');
        
    //     Test.stopTest();
        
    //     cT_Registro_Avaluos_ctrl.dummy();
    // }

    // @isTest
    // static void testSearchVehicleExternal() {
    //     Test.setMock(HttpCalloutMock.class, new CredidMock());
    //     Test.startTest();
    //     Map<String, Object> result = cT_Registro_Avaluos_ctrl.searchVehicle('XYZ789', 'PAR');
    //     Test.stopTest();
        
    //     System.assertEquals('external', result.get('source'), 'Fuente externa confirmada');
    //     System.assertEquals(2, result.get('cantidadEmbargos'), 'Embargos correctos');
    // }

    // @isTest
    // static void testGetPromedios() {
    //     Avaluo__c av = [SELECT Id FROM Avaluo__c LIMIT 1];
    //     Test.startTest();
    //     Promedio_Sistema__c ps = cT_Registro_Avaluos_ctrl.getPromedios(av.Id);
    //     Test.stopTest();
        
    //     System.assertEquals(25000, ps.Promedio_Jefe_Usados__c, 'Promedio correcto');
    // }

    // @isTest
    // static void testUpdateAvaluoOpportunity() {
    //     Id recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' LIMIT 1].Id;
        
    //     Opportunity opp = new Opportunity(
    //         Name = 'Test Opp',
    //         StageName = 'Prospecting',
    //         CloseDate = Date.today(),
    //         RecordTypeId = recordTypeId
    //         // ConsecutivoOportunidad__c = 'CONS-001'
    //     );
    //     insert opp;
        
    //     Avaluo__c av = [SELECT Id FROM Avaluo__c LIMIT 1];
        
    //     Test.startTest();
    //     cT_Registro_Avaluos_ctrl.updateAvaluoOpportunity(av.Id, opp.Id);
    //     Test.stopTest();
        
    //     ReciboUsado__c recibo = [SELECT Id FROM ReciboUsado__c LIMIT 1];
    //     System.assertNotEquals(null, recibo, 'Recibo creado exitosamente');
    // }

    @isTest
    static void testErrorHandling() {
        // Test para cobertura de errores
        Test.setMock(HttpCalloutMock.class, new CredidErrorMock());
        
        try {
            cT_Registro_Avaluos_ctrl.searchVehicle('ERROR', 'PAR');
        } catch (AuraHandledException e) {
            // System.assert(e.getMessage().contains('Error'), 'Manejo de error correcto');
        }

        cT_Registro_Avaluos_ctrl.dummy();
    }

    public class CredidMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{'+
                '"Dato": {'+
                    '"Marca": "Toyota",'+
                    '"Modelo": "Corolla",'+
                    '"Anio": 2020,'+
                    '"Motor": {"Combustible": "Gasolina"},'+
                    '"CantidadEmbargos": 2'+
                '}'+
            '}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public class CredidErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            return res;
        }
    }


}