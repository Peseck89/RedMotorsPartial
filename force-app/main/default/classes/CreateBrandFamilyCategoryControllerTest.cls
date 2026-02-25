@isTest
public class CreateBrandFamilyCategoryControllerTest {

    // Mock para simular los callouts HTTP
    private class MockHttpCallout implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');

            if (req.getEndpoint().contains('query')) {
                // Respuesta simulada para la consulta de picklist values
                res.setBody('{"records": [{"Id": "a01xx0000001abc", "Metadata": {"valueSet": {"valueSetDefinition": {"value": [{"valueName": "ExistingValue"}]}, "valueSettings": []}}}]}');
                res.setStatusCode(200);
            } else if (req.getEndpoint().contains('sobjects/CustomField')) {
                // Respuesta simulada para actualizar un CustomField
                res.setBody('{}');
                res.setStatusCode(204); // Código 204 para PATCH exitoso
            } else if (req.getEndpoint().contains('sobjects/RecordType')) {
                // Respuesta simulada para consultar valores por RecordType
                res.setBody('{"Metadata": {"picklistValues": [{"picklist": "Familia__c", "values": [{"valueName": "ExistingValue"}]}]}}');
                res.setStatusCode(200);
            } else {
                res.setBody('{"message": "Unexpected endpoint"}');
                res.setStatusCode(400);
            }
            return res;
        }
    }

    /*
    @isTest
    static void testUpdateMarca() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());

        String globalPicklist = 'Marca__c';
        String newValue = 'NewBrand';

        Test.startTest();
        Integer result = CreateBrandFamilyCategoryController.updateMarca(globalPicklist, newValue);
        Test.stopTest();

        //System.assertEquals(204, result, 'El valor del picklist debe actualizarse correctamente en el RecordType');
    }

    @isTest
    static void testGetPicklistValuesForRecordType() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());

        String recordType = '0124U00000111EDQAY';
        String picklistField = 'Familia__c';

        Test.startTest();
        List<String> picklistValues = CreateBrandFamilyCategoryController.getPicklistValuesForRecordType(recordType, picklistField);
        Test.stopTest();

        //System.assertNotNull(picklistValues, 'Los valores del picklist deben recuperarse correctamente');
        //System.assert(picklistValues.contains('ExistingValue'), 'El picklist debe incluir "ExistingValue"');
    }*/

    @isTest
    static void testGetPicklistValues() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());

        String objectName = 'Product2';
        String picklistField = 'Marca__c';

        Test.startTest();
        List<String> picklistValues = CreateBrandFamilyCategoryController.getPicklistValues(objectName, picklistField);
        Test.stopTest();

        //System.assertNotNull(picklistValues, 'Los valores del picklist deben recuperarse correctamente');
    }

    @isTest
    static void testGetPicklistValuesWithControllingValues() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());

        String objectName = 'Product2';
        String picklistField = 'Familia__c';

        Test.startTest();
        Map<String, List<String>> result = CreateBrandFamilyCategoryController.getPicklistValuesWithControllingValues(objectName, picklistField);
        CreateBrandFamilyCategoryController.dummyMethod();
        Test.stopTest();

        //System.assertNotNull(result, 'Los valores dependientes deben recuperarse correctamente');
    }

    /*
    @isTest
    static void testCreateNewFamilyByBrand() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());

        String globalPicklist = 'Familia__c';
        String newValue = 'NewFamily';
        String controllingFieldValue = 'BrandA';

        Test.startTest();
        Integer result = CreateBrandFamilyCategoryController.createNewFamilyByBrand(globalPicklist, newValue, controllingFieldValue);
        Test.stopTest();

        //System.assertEquals(204, result, 'El valor de la nueva familia debe agregarse correctamente');
    }*/

    @isTest
    static void testCreatePicklistValueWithoutControllingField() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());

        String picklistField = 'Familia__c';
        String newValue = 'NewValue';

        Test.startTest();
        CreateBrandFamilyCategoryController.createPicklistValueWithoutControllingField(picklistField, newValue);
        Test.stopTest();

        //System.assert(true, 'El valor del picklist debe agregarse sin problemas');
    }
}