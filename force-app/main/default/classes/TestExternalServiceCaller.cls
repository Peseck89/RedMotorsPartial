@isTest
public class TestExternalServiceCaller {

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success":true,"message":"Record processed successfully"}');  // Adjust this body to match the actual service's response if needed
            res.setStatusCode(200);
            return res; 
        }
    }
    
    // Helper method to generate test data
    public static ReciboUsado__c createTestData() {
        // Assuming you have a RecordType named 'Automóvil'
        Id recordTypeIdAuto = Schema.SObjectType.ReciboUsado__c.getRecordTypeInfosByName().get('Automóvil').getRecordTypeId();
        
		Account a = new Account
            (
                FirstName = 'Test',
                LastName    =   'test',
                PersonEmail = 'correo@email.com',
                Tipo_de_Documento__c = 'Cedula',
                Cedula__c = '222222222',
                PersonMobilePhone = '+50687878787'
            );
        
        insert a;

        Opportunity op = new Opportunity(
                AccountId = a.Id,
                CloseDate = System.today().AddMonths(3),
                StageName = 'Nuevo',
                IngresoAproximado__c = 1500,
                RT_Lead__c = 'BMW'
            );
        
        insert op;

        ReciboUsado__c testRecord = new ReciboUsado__c(
            RecordTypeId = recordTypeIdAuto,
            Fecha_de_recibo__c = System.today(),
            Marca__c = 'AUDI',
            Modelo__c = 'A1',
            Estilo__c = 'FULL',
            Ano__c = '2024',
            Color__c = 'BLANCO',
            N_puertas__c = 5,
            Combustible__c = 'GASOLINA',
            Traccion__c = '4x4',
            Trasmision__c = 'AUTOMATICA',
            EstiloUsado__c = 'CABRIOLET',
            Kilometraje__c = 60700,
            Cilindraje__c = 2600,
            Placa__c = 'AXX123',
            ValorReciboCliente__c = 30000,
            ReciboJefeUsados__c = 18000,
            Motor__c = '2500',
            Empresa__c = 'RMBAVARIAN',
            VIN__c = 'TYUFGFGH3456789AM',
            Oportunidad__c = op.id
            // Set other fields if necessary
        );
        
        //Oportunidad__c
        
     
        
        insert testRecord;
        return testRecord;
    }

    @isTest static void testServiceCallout() {
        // Bind the mock class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Generate test data
        ReciboUsado__c testRecord = createTestData();
        
        Test.startTest();
        
        // Call the method
        ExternalServiceCallerController.sendDataFromTrigger(testRecord.Id);
        
        ExternalServiceCallerController.sendDataFromTrigger('a016C000005itrDQAQ');
        
        Test.stopTest();
        
        // Asserts: Add further checks as per your requirements
        // For this example, you can check debug logs for the expected outputs, or modify methods to return values which can then be asserted.
    }
}