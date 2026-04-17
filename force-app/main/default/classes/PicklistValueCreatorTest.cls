@isTest
public class PicklistValueCreatorTest {

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
            } else if (req.getEndpoint().contains('/ui-api/object-info/')) {
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
    static void testMakePatchRecordtypeCallout() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());

        String recordTypeId = '012xx0000001xyz';
        String picklistFieldName = 'TestPicklist';
        String patchData = '{"Metadata": {"picklistValues": [{"picklist": "TestPicklist", "values": [{"valueName": "NewValue"}]}]}}';

        Test.startTest();
        PicklistValueCreator.makePatchRecordtypeCallout(recordTypeId, picklistFieldName, patchData);
        Test.stopTest();
    }

    @isTest
    static void testAddPicklistValueToRecordType() {
    	Test.setMock(HttpCalloutMock.class, new MockHttpCallout_AddPicklist());
        String objectName = 'Lead';
        String recordTypeId = '012xx0000001xyz';
        String picklistName = 'TestPicklist';
        String newField = 'NewValue';
        String recordTypeDescripton = 'Test Description';
        String label = 'Test Label';
        String recordTypeApiName = 'Test_Api_Name';

        Test.startTest();
        PicklistValueCreator.addPicklistValueToRecordType(objectName, recordTypeId, picklistName, newField, recordTypeDescripton, label, recordTypeApiName);
        Test.stopTest();
    }
    
     // Test method for addPicklistValue
    @isTest
    static void testAddPicklistValue() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());

        String objectName = 'TestObject';
        String fieldName = 'TestField';
        String newValue = 'NewValue';
        String controllingFieldValue = 'ControllingValue';

        Test.startTest();
        Boolean result = PicklistValueCreator.addPicklistValue(objectName, fieldName, newValue, controllingFieldValue);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Debe retornar un Boolean');
    }
     @isTest
    static void testGetPicklistValuesForRecordType() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());

        String recordTypeId = '012xx0000001xyz';
        String picklistFieldName = 'Status';
        String objectName = 'Lead';

        Test.startTest();
        List<String> picklistValues = PicklistValueCreator.getPicklistValuesForRecordType(recordTypeId, picklistFieldName);
        List<String> picklistValues2 = PicklistValueCreator.getPicklistValues(objectName, picklistFieldName);

        Test.stopTest();

        System.assertNotEquals(null, picklistValues, 'La lista no debe ser nula');
    }
    
    // Test method for addPicklistValueWithoutControllingField
    @isTest
    static void testAddPicklistValueWithoutControllingField() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());

        String objectName = 'TestObject';
        String fieldName = 'TestField';
        String newValue = 'NewValue';

        Test.startTest();
        PicklistValueCreator.addPicklistValueWithoutControllingField(objectName, fieldName, newValue);
        Test.stopTest();
    }

    // Test method for getControllingAndDependentValues
    @isTest
    static void testGetControllingAndDependentValues() {
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());

        String objectName = 'Product2';
        String fieldName = 'Familia__c';

        Test.startTest();
        Map<String, List<String>> result = PicklistValueCreator.getControllingAndDependentValues(objectName, '0120P000000ENW0QAO', fieldName);
        Test.stopTest();

        // Output the result to debug for inspection
        System.debug('Result: ' + result);
    }
}