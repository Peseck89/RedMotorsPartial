@istest
private class AccountTriggerHandlerTest {
    @isTest
    private static void testEventTriggerHandler() {
        Impuesto__c im = new Impuesto__c();
        im.codigoImpuesto__c =  '0108';
        insert im;
        
        condicionPago__c condi = new condicionPago__c();
        condi.Name = 'CONTADO';
        condi.condicionPago__c = '0';
        insert condi;
        
        categoriaCliente__c cet = new categoriaCliente__c();
        cet.categoriaCliente__c = 'COM';
        insert cet;
            
        Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543220';
        acc.Tipo_de_Documento__c='02';
        acc.codigoSoftland__c = '1234';

        
        Account acc2= new Account();
        acc2.Name='Test account 2';
        acc2.Cedula__c='9876543210';
        acc2.Tipo_de_Documento__c='02';
        acc2.codigoSoftland__c = '1234';
        acc2.Impuesto__c = Im.Id;
        acc2.condicionPago__c = condi.Id;
        acc2.categoriaCliente__c = cet.Id;
        insert acc2;
    }
}