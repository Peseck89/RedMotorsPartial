@isTest
public class HttpCalloutGetProductAvailabilityTest {
    @isTest
	static void testPostCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new HttpCalloutGetProductAvailabilityMock()); 
        HttpCalloutGetProductAvailability availability= new HttpCalloutGetProductAvailability('RMBAVARIAN');
        availability.addToRequest('L00078','BR01','K');
        availability.addToRequest('L00098','BR01','T');
        availability.addToRequest('L000102','BR01','T');
       // productos pds2= new productos('L00098','BR01');
       // productos pds3= new productos('L000102','BR01');
        HttpResponse response = availability.getExistencias();
        availability.deserialize();
        // Verify that the response received contains fake values
        String contentType = response.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = response.getBody();
        System.debug(response.getBody());
        /*String expectedValue = '{"animals": ["majestic badger", "fluffy bunny", "scary bear", "chicken", "mighty moose"]}';
        System.assertEquals(expectedValue, actualValue);
        System.assertEquals(200, response.getStatusCode());*/
	}
}