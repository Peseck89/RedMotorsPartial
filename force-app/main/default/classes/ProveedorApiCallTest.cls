@isTest
public class ProveedorApiCallTest {
    @isTest
	static void testPostCallout() {
        
         RestRequest req = new RestRequest(); 
         RestResponse res = new RestResponse();

         req.addHeader('Content-Type', 'application/json');
         req.requestUri = '/services/apexrest/proveedor/';       
         String postData = '{"Name":"Proveedor 1 test","SoftlandCode":"234324","activo":"true"}';
         String JsonMsg=JSON.serialize(postData);
         req.requestBody = Blob.valueof(JsonMsg);
         RestContext.request = req; 
         RestContext.response= res;
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new ProveedorAPICallMock());
         proveedorWS.createProveedor();
         Test.stopTest();
   
  
        /*
        Proveedor__c prov= new Proveedor__c();
        prov.Name='Test Proveedor Name';
        prov.SoftlandCode__c='9876543210';
        prov.activo__c=True;
        
        insert prov;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ProveedorAPICallMock());
        
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new ProveedorAPICallMock());
        
        //ProveedorJSON prov = new createProveedor('{"Name":"Proveedor 1 test","SoftlandCode":"234324","activo":"true"}');
        proveedorWS.createProveedor();
        */
	}
}