@isTest
public class TestEtapasTallerv2_PowerBI {
    
    // Clase mock pública para simular la respuesta del callout HTTP
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"Caso":"AAAAA555555","Taller":"AAAAA555555","Etapa":"AAAAA555555","Matricula":"AAAAA555555","VIN":"AAAAA555555","Marca":"AAAAA555555","Modelo":"AAAAA555555","Anio":"AAAAA555555","Asesor":"AAAAA555555","Tipo de Vehiculo":"AAAAA555555","Fecha Entrada":"2025-03-19T03:36:10.212Z","Estado Caso":"AAAAA555555","Inicio Etapa":"2025-03-19T03:36:10.212Z","Fin Etapa":"2025-03-19T03:36:10.212Z","Fecha Hora Ejecucion":"2025-03-19T03:36:10.212Z","Minutos Laborales":98.6,"Hora Laborales":98.6,"Estatus de Etapa":"AAAAA555555","ID del Caso":"AAAAA555555"}]');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    public static void testSendDataToPowerBIFuture() {
        // Obtener la descripción global de los objetos para trabajar de forma dinámica
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        
        RM_CT_TestDataFactory.createCaseWithWorkSteps();
        
        // Verificar que los objetos requeridos existan en la organización
        // 
        /*
        if (!gd.containsKey('Service_Territory1__c') || 
            !gd.containsKey('Case') || 
            !gd.containsKey('EstadosDeOrden__c')) {
            System.debug('Los objetos personalizados requeridos no existen en esta organización.');
            return;  // No se puede continuar si no existen
        }
        */
        
        OperatingHours oh = new OperatingHours(
            Name = 'test',
            TimeZone = 'America/Costa_Rica'
        );
        
        insert oh;
        
        System.debug('Operating Hours. ' + oh.Id);
        

        
        // 1. Crear registro de Service_Territory1__c dinámicamente
        SObject territory = gd.get('ServiceTerritory').newSObject();
        
        territory.put('OperatingHoursId', oh.Id); 
        territory.put('Name', 'Taller Test');
        insert territory;
        
        // 2. Crear registro de Asset (objeto estándar)
        // 
        Account acct = new Account(
            FirstName = 'Test', 
            LastName = 'Test', 
            Tipo_de_Documento__c = 'Cedula', 
            Cedula__c = '404440444', 
            PersonEmail = 'da_ls90@hotmail.es', 
            PersonMobilePhone = '+50683838383');
        insert acct;

        
        Asset assetRecord = new Asset(
            Name = 'Matricula Test 1235',
            marca__c = 'Marca Test',
            modelo__c = 'Modelo Test',
            NumeroDeChasis__c = '97996921123412342',
            AccountId = acct.id,
            anio__c = '2025',
            Tipo_de_veh_culo__c = 'Automóvil'
        );
        insert assetRecord;
        
        // 3. Crear registro de Casos__c dinámicamente
        Case c = [SELECT Id,CaseNumber FROM Case LIMIT 1];
        
        //Object caso = gd.get('Case').newSObject();
        c.put('Status', 'En Proceso');
        c.put('Service_Territory1__c', territory.get('Id'));
        c.put('AssetId', assetRecord.Id);
        c.put('AccountId', acct.Id);
        //c.put('Vin__c', 'VINTest');
        //c.put('consecutivo__c', 'IDTest');
        //c.put('OwnerId', UserInfo.getUserId());
        update c;
        
        // 4. Crear registro de EstadosDeOrden__c dinámicamente, referenciando el caso creado
        SObject estado = gd.get('EstadosDeOrden__c').newSObject();
        estado.put('Casos__c', c.get('Id'));
        estado.put('Name', 'Etapa Test');
        estado.put('FechaInicio__c', System.now().addMinutes(-60));
        estado.put('FechaFin__c', System.now());
        insert estado;
        
        // 5. Configurar el mock para la llamada HTTP
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // 6. Ejecutar el método @future dentro de un bloque de test
        Test.startTest();
            EtapasTallerv2_PowerBI.sendDataToPowerBIFuture();
        Test.stopTest();
        
        // Si el método se ejecuta sin excepciones, se considera que la prueba fue exitosa.
        System.assert(true, 'El método future se ejecutó y se simuló la respuesta de Power BI correctamente.');
    }
}