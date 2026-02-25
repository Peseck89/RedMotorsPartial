@isTest
public class facturadaApiCallTest {
@isTest
    static void testPostCallout() {
        
         RestRequest req = new RestRequest(); 
         RestResponse res = new RestResponse();

         req.addHeader('Content-Type', 'application/json');
         req.requestUri = '/services/apexrest/facturadas/';       
         String postData = '{"SoftlandCode":"asdqwe1231","Estado":"F"}';
         String JsonMsg=JSON.serialize(postData);
         req.requestBody = Blob.valueof(JsonMsg);
         RestContext.request = req; 
         RestContext.response= res;
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new facturadaAPICallMock());
         facturadasWS.actualizarOrdenFacturada();
         Test.stopTest();
   
	}
    
    
}