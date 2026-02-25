@isTest(seeAllData = true)
public class ProveedorJSONTest {
	@isTest
    public static void testProveedorJSON() {
        Proveedor__c prov= new Proveedor__c();
        prov.Name='Test Proveedor Name';
        prov.SoftlandCode__c='9876543210';
        prov.activo__c=True;
        
        insert prov;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ProveedorAPICallMock());
        
        String jsonStr = '';
        ProveedorJSON.proveedorRequestJSON cntrl = new ProveedorJSON.proveedorRequestJSON();
        cntrl.Name = 'Test Proveedor Name';
        cntrl.SoftlandCode = '233242';
        cntrl.activo = 'true';
        
        jsonStr = JSON.serialize(cntrl);
        ProveedorJSON.createProveedor(jsonStr);
        
        
        
        String jsonStr2 = '';
        ProveedorJSON.proveedorRequestJSON cntrl2 = new ProveedorJSON.proveedorRequestJSON();
        cntrl2.Name = 'Test Proveedor Name 2';
        cntrl2.SoftlandCode = '9876543210';
        cntrl2.activo = 'true';
        
        jsonStr2 = JSON.serialize(cntrl2);
        ProveedorJSON.createProveedor(jsonStr);
        
        Test.stopTest();
    }
    
    public class ExampleCalloutMock implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{"access_token":"","token_type":""}');
            return res;
        }
    }
}