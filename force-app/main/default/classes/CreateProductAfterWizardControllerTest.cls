@isTest
public class CreateProductAfterWizardControllerTest {

    // JSON strings provided as examples (not final, so they can be updated)
    private static String PRODUCT_JSON = '{"RecordTypeId":"0120P000000ENW0QAO","Marca__c":"BMW","Codigo_de_Producto__c":"CodProd","Name":"Name-ModeloInteresmini","Codigo_Info__c":"CodInfo","Description":"Descr","Se_Muestra_en_Sitio__c":true,"Nombre_Digital__c":"3","Orden_Sitio_Web__c":"3"}';
    private static String PRICEBOOK_JSON = '{"Description":"BMW - 2025","Name":"BMW - 2025","IsActive":true}';
    private static String PRICEBOOK_ENTRY_JSON = '{"Vendedor__c":"3","Gerente__c":"2","Jefe__c":"2","Costo_Fijo__c":"200","UnitPrice":"100","Pricebook2Id":null,"Product2Id":null,"IsActive":true}';
	private class MockHttpCallout implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            if (req.getEndpoint().contains('query')) {
                res.setBody('{"records": [{"Id": "a01xx0000001abc", "Metadata": {"valueSet": {"valueSetDefinition": {"value": [{"valueName": "ExistingValue"}]}, "valueSettings": []}}}]}');
                res.setStatusCode(200);
            } else if (req.getEndpoint().contains('sobjects/CustomField')) {
                res.setBody('{}');
                res.setStatusCode(204);
            } else if (req.getEndpoint().contains('sobjects/RecordType')) {
                res.setBody('{"Metadata": {"picklistValues": [{"picklist": "TestPicklist", "values": [{"valueName": "ExistingValue"}]}]}}');
                res.setStatusCode(200);
            } else if (req.getEndpoint().contains('/services/data/v48.0/ui-api/object-info/')) {
                res.setBody('{' +
                    '"controllerValues": {' +
                        '"BMW": 0,' +
                        '"Kawasaki": 1' +
                    '},' +
                    '"values": [' +
                        '{"value": "Heritage", "validFor": [1]},' +
                        '{"value": "Jet Ski", "validFor": [1]},' +
                        '{"value": "X6", "validFor": [0]},' +
                        '{"value": "X3", "validFor": [0]}' +
                    ']' +
                '}');
                res.setStatusCode(200);
            } else {
                res.setBody('{"message": "Unexpected endpoint"}');
                res.setStatusCode(400);
            }
            return res;
        }
    }
    @testSetup
    static void setupTestData() {
        // Create a Product2 record
        Product2 testProduct = (Product2) JSON.deserialize(PRODUCT_JSON, Product2.class);
        insert testProduct;

        // Create a Pricebook2 record
        Pricebook2 testPricebook = (Pricebook2) JSON.deserialize(PRICEBOOK_JSON, Pricebook2.class);
        insert testPricebook;
    }

    @isTest
    static void testCreateProduct() {
        Test.startTest();
        Map<String, Object> result = CreateProductAfterWizardController.createProduct(PRODUCT_JSON);
        Test.stopTest();

    }

    @isTest
    static void testCreatePBEntryWithNewPricebook() {
        // Query the Product2 record created in setup
        Product2 testProduct = [SELECT Id FROM Product2 LIMIT 1];

        // Deserialize the PricebookEntry JSON and update the Product2Id
        PricebookEntry pentry = (PricebookEntry) JSON.deserialize(PRICEBOOK_ENTRY_JSON, PricebookEntry.class);
        pentry.Product2Id = testProduct.Id;

        // Serialize the updated PricebookEntry back to JSON
        String updatedPentryJson = JSON.serialize(pentry);

        // Call the method to test
        Test.startTest();
        Id pentryId = CreateProductAfterWizardController.createPBEntry(PRICEBOOK_JSON, updatedPentryJson, true);
        Test.stopTest();

        // Verify the results
        System.assertNotEquals(null, pentryId, 'PricebookEntry ID should not be null');
        PricebookEntry createdPEntry = [SELECT Id, Pricebook2Id FROM PricebookEntry WHERE Id = :pentryId];
        System.assertNotEquals(null, createdPEntry, 'PricebookEntry should be created');
        System.assertNotEquals(null, createdPEntry.Pricebook2Id, 'Pricebook2Id should be set');
    }

    @isTest
    static void testCreatePBEntryWithExistingPricebook() {
        // Query the Product2 and Pricebook2 records created in setup
        Product2 testProduct = [SELECT Id FROM Product2 LIMIT 1];
        Pricebook2 testPricebook = [SELECT Id FROM Pricebook2 LIMIT 1];

        // Deserialize the PricebookEntry JSON and update the Product2Id and Pricebook2Id
        PricebookEntry pentry = (PricebookEntry) JSON.deserialize(PRICEBOOK_ENTRY_JSON, PricebookEntry.class);
        pentry.Product2Id = testProduct.Id;
        pentry.Pricebook2Id = testPricebook.Id;

        // Serialize the updated PricebookEntry back to JSON
        String updatedPentryJson = JSON.serialize(pentry);

        // Call the method to test
        Test.startTest();
        Id pentryId = CreateProductAfterWizardController.createPBEntry(null, updatedPentryJson, false);
        Test.stopTest();

        // Verify the results
        System.assertNotEquals(null, pentryId, 'PricebookEntry ID should not be null');
        PricebookEntry createdPEntry = [SELECT Id, Pricebook2Id FROM PricebookEntry WHERE Id = :pentryId];
        System.assertNotEquals(null, createdPEntry, 'PricebookEntry should be created');
        System.assertEquals(testPricebook.Id, createdPEntry.Pricebook2Id, 'Pricebook2Id should match the existing Pricebook');
    }

    @isTest
    static void testGetPricebook() {
        // Query the Pricebook2 record created in setup
        Pricebook2 testPricebook = [SELECT Id, Name FROM Pricebook2 LIMIT 1];

        // Extract the brand from the Pricebook2 name
        String brand = testPricebook.Name.split(' - ')[0];

        // Call the method to test
        Test.startTest();
        String retrievedPricebookId = CreateProductAfterWizardController.getPricebook(brand);
        Test.stopTest();

        // Verify the results
        System.assertNotEquals('null', retrievedPricebookId, 'Pricebook ID should not be null');
        System.assertEquals(testPricebook.Id, retrievedPricebookId, 'Pricebook ID should match the created Pricebook');
    }

    @isTest
    static void testGetPricebookNotFound() {
        // Use a non-existent brand
        String brand = 'NON_EXISTENT_BRAND';

        // Call the method to test
        Test.startTest();
        String pricebookId = CreateProductAfterWizardController.getPricebook(brand);
        Test.stopTest();

        // Verify the results
        System.assertEquals('null', pricebookId, 'Pricebook ID should be null for non-existent brand');
    }
    private class MockHttpCallout_AddPicklist implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
    
            // Devuelve lo que espera transformJson
            if (req.getEndpoint().contains('/ui-api/object-info/')) {
                res.setBody('{"values": [{"value": "ExistingValue1"}, {"value": "ExistingValue2"}]}');
                res.setStatusCode(200);
            } else if (req.getMethod() == 'PATCH') {
                // Simula el PATCH del record type
                res.setStatusCode(204);
                res.setBody('');
            } else {
                res.setStatusCode(400);
                res.setBody('{"message": "Unhandled endpoint"}');
            }
    
            return res;
        }
    }
     @isTest
    static void testCreateNewModeloByFamilia() {
        // Datos de prueba
        String globalPicklist = 'Modelo_De_Inter_s__c';
        String newValue = 'NuevoModelo123';
        String controllingFieldValue = 'CategoriaX';
        String recordTypeId = '012XXXXXXXXXXXX'; 
        String recordTypeDescripton = 'Descripción de prueba';
        String label = 'Label de prueba';
        String recordTypeApiName = 'RecordType_API';

        // Llamada al método a probar
    	Test.setMock(HttpCalloutMock.class, new MockHttpCallout_AddPicklist());
        Test.startTest();
        Integer result = CreateProductAfterWizardController.createNewModeloByFamilia(
            'BMW',
            globalPicklist,
            newValue,
            controllingFieldValue,
            recordTypeId,
            recordTypeDescripton,
            label,
            recordTypeApiName
        );
        Integer result2 = CreateProductAfterWizardController.createNewModeloByFamilia(
            'MINI',
            globalPicklist,
            newValue,
            controllingFieldValue,
            recordTypeId,
            recordTypeDescripton,
            label,
            recordTypeApiName
        );
        Integer result3 = CreateProductAfterWizardController.createNewModeloByFamilia(
            'Kawasaki',
            globalPicklist,
            newValue,
            controllingFieldValue,
            recordTypeId,
            recordTypeDescripton,
            label,
            recordTypeApiName
        );
        Integer result4 = CreateProductAfterWizardController.createNewModeloByFamilia(
            'Motorrad',
            globalPicklist,
            newValue,
            controllingFieldValue,
            recordTypeId,
            recordTypeDescripton,
            label,
            recordTypeApiName
        );
        Integer result5 = CreateProductAfterWizardController.createNewModeloByFamilia(
            'Polaris',
            globalPicklist,
            newValue,
            controllingFieldValue,
            recordTypeId,
            recordTypeDescripton,
            label,
            recordTypeApiName
        );
        
        Test.stopTest();

        // Verificación mínima
        System.assertNotEquals(null, result, 'El resultado no debe ser null');
    }
    @isTest
    static void testCreateNewModeloByFamilia2() {
         String globalPicklist = 'Modelo_De_Inter_s__c';
        String newValue = 'NuevoModelo123';
        String controllingFieldValue = 'CategoriaX';
        String recordTypeId = '012XXXXXXXXXXXX'; 
        String recordTypeDescripton = 'Descripción de prueba';
        String label = 'Label de prueba';
        String recordTypeApiName = 'RecordType_API';

        // Llamada al método a probar
    	Test.setMock(HttpCalloutMock.class, new MockHttpCallout_AddPicklist());
        Test.startTest();
        Integer result7 = CreateProductAfterWizardController.createNewModeloByFamilia(
            'Macas 2 Ruedas',
            globalPicklist,
            newValue,
            controllingFieldValue,
            recordTypeId,
            recordTypeDescripton,
            label,
            recordTypeApiName
        );
        Test.stopTest();
    }
    @isTest
    static void testCreateNewModeloByFamilia4() {
         String globalPicklist = 'Modelo_De_Inter_s__c';
        String newValue = 'NuevoModelo123';
        String controllingFieldValue = 'CategoriaX';
        String recordTypeId = '012XXXXXXXXXXXX'; 
        String recordTypeDescripton = 'Descripción de prueba';
        String label = 'Label de prueba';
        String recordTypeApiName = 'RecordType_API';

        // Llamada al método a probar
    	Test.setMock(HttpCalloutMock.class, new MockHttpCallout_AddPicklist());
        Test.startTest();
        Integer result6 = CreateProductAfterWizardController.createNewModeloByFamilia(
            'Todas',
            globalPicklist,
            newValue,
            controllingFieldValue,
            recordTypeId,
            recordTypeDescripton,
            label,
            recordTypeApiName
        );
        Test.stopTest();
    }
    @isTest
    static void testCreateNewModeloByFamilia3() {
         String globalPicklist = 'Modelo_De_Inter_s__c';
        String newValue = 'NuevoModelo123';
        String controllingFieldValue = 'CategoriaX';
        String recordTypeId = '012XXXXXXXXXXXX'; 
        String recordTypeDescripton = 'Descripción de prueba';
        String label = 'Label de prueba';
        String recordTypeApiName = 'RecordType_API';

        // Llamada al método a probar
    	Test.setMock(HttpCalloutMock.class, new MockHttpCallout_AddPicklist());
        Test.startTest();
        	Integer result8 = CreateProductAfterWizardController.createNewModeloByFamilia(
            'Marcas Vehículos',
            globalPicklist,
            newValue,
            controllingFieldValue,
            recordTypeId,
            recordTypeDescripton,
            label,
            recordTypeApiName
        );
        Integer result9 = CreateProductAfterWizardController.createNewModeloByFamilia(
            'Harley-Davidson',
            globalPicklist,
            newValue,
            controllingFieldValue,
            recordTypeId,
            recordTypeDescripton,
            label,
            recordTypeApiName
        );
        Integer result10 = CreateProductAfterWizardController.createNewModeloByFamilia(
            'Indian',
            globalPicklist,
            newValue,
            controllingFieldValue,
            recordTypeId,
            recordTypeDescripton,
            label,
            recordTypeApiName
        );
        Test.stopTest();
    }
}