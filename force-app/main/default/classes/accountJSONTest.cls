@isTest
public class accountJSONTest {
    @isTest
    public static void testaccountJSON() {
        Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        acc.codigoSoftland__c = '1234';
        
        insert acc;
        
        condicionPago__c cp = new condicionPago__c(condicionPago__c = 'test');
        insert cp;
        
        categoriaCliente__c cc = new categoriaCliente__c(categoriaCliente__c = 'test');
        insert cc;
        
        impuesto__c impuesto = new impuesto__c(codigoImpuesto__c = 'test');
        insert impuesto;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        
        String jsonStr = '';
        accountJSON.accountRequestJSON cntrl = new accountJSON.accountRequestJSON();
        cntrl.condicionPago = 'test';
        cntrl.categoriaCliente = 'test';
        cntrl.impuesto = 'test';
        
        jsonStr = JSON.serialize(cntrl);
        accountJSON.createAccount(jsonStr);
        
        cntrl.cliente = '1234';
        jsonStr = JSON.serialize(cntrl);
        accountJSON.createAccount(jsonStr);
        
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