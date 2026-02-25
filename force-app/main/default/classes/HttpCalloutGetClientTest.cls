@isTest
public class HttpCalloutGetClientTest {
    @isTest
    public static void testHttpCalloutGetClient() {
        condicionPago__c cp = new condicionPago__c(condicionPago__c = 'test');
        insert cp;
        
        HttpCalloutGetClient bgv = new HttpCalloutGetClient();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        bgv.getGetClientCallout('','','');
        Test.stopTest();
    }
    
    @isTest
    public static void testgetSoftlandAccount() {
        
        HttpCalloutGetClient bgv = new HttpCalloutGetClient();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GetClientMock());
        bgv.getSoftlandAccount('C116571');
        Test.stopTest();
    }
    
    @isTest
    public static void testupdateSoftlandClient() {
        
        HttpCalloutGetClient bgv = new HttpCalloutGetClient();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new updateSoftlandClientMock());
        bgv.updateSoftlandClient('');
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
    
    public class GetClientMock implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{ "cliente": "C116571", "nombre": "DESARROLLOS E INVERSIONES M Y C", "alias": "DESARROLLOS E INVERSIONES M Y C", "contacto": " ", "activo": "S", "cargo": " ", "id": "3101171751", "moneda": "CRC", "condicionPago": "0", "categoriaCliente": "COM", "pais": "CRI", "provincia": "4", "canton": "07", "distrito": "01", "barrio": "01", "otras_senas": null, "telefono1": "fewsfeaef", "telefono2": "88978376", "email": "mar09f@gmail.hom", "email_doc_electronico": "mar09f@gmail.hom", "email_doc_electronico_copia": "mar09f@gmail.hom", "contribuyente": [], "categoria": [], "impuesto": [] } ');
            return res;
        }
    }
    
    public class updateSoftlandClientMock implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{ "operationResult": { "code": "00", "description": "Cliente actualizado exitosamente" } }');
            return res;
        }
    }
}