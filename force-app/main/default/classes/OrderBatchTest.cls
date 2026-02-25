@isTest
private class OrderBatchTest {
    
	@testSetup
    static void testSetup() {
        List<Account> accounts = new List<Account>();
        List<Contact> contacts = new List<Contact>();
        List<ActividadComercial__c> actividadComercial = new List<ActividadComercial__c>();
        List<condicionPago__c> condicionPago = new List<condicionPago__c>();
        List<Pricebook2> pricebook = new List<Pricebook2>();
        List<Product2> products = new List<Product2>();
        List<Order> pedidos = new List<Order>();
        
        // Insert 10 accounts
        for (Integer i=0;i<10;i++) {
            accounts.add(new Account(Name='Account ' + i));
        }
        insert accounts;
        
        // find the account just inserted. add contact for each
        for (Account account : [SELECT Id FROM Account]) {
            contacts.add(new Contact(firstname='first',
                lastname='last', accountId=account.id));
        }
        insert contacts;
        
        //Insert Actividad comercial
        for (Integer i=0;i<5;i++) {
            actividadComercial.add(new ActividadComercial__c(Name='Actividad ' + i));
        }
        insert actividadComercial;
        
        //Insert Condicio de Pago
        for (Integer i=0;i<5;i++) {
            condicionPago.add(new condicionPago__c(Name='Condicion ' + i));
        }
        insert condicionPago;
        
        //Insert Pricebook
        for(Integer i=0;i<5;i++) {
            pricebook.add(new Pricebook2(Name='Pricebook ' + i));
        }
        insert pricebook;
        
        //Insert Product
        /*
        for (Product2 product : [SELECT Id FROM Pricebook2]) {
            products.add(new Product2(Name='Producto Test', Codigo_de_Producto__c='0001', CurrencyIsoCode='USD'));
        }
        insert products;
*/
        
        //Insert Pedido        
        List<Account> insertedAccount = [SELECT Id FROM Account LIMIT 1];
        List<ActividadComercial__c> insertedActividadComercial = [SELECT Id FROM ActividadComercial__c LIMIT 1];
        List<condicionPago__c> insertedCondicionPago = [SELECT Id FROM condicionPago__c LIMIT 1];
        List<Pricebook2> insertedPricebook = [SELECT Id FROM Pricebook2 LIMIT 1];
        
        for(Integer i=0;i<5;i++) {
            pedidos.add(new Order(AccountId = insertedAccount[0].Id,
                                  ActividadComercial__c = insertedActividadComercial[0].Id,
                                  condicionPago__c = insertedCondicionPago[0].Id,
                                  Pricebook2Id = insertedPricebook[0].Id,
                                  Status = 'Draft',
                                  EffectiveDate = Date.today()));
        }
        insert pedidos;
    }
    
    @isTest
    static void testCallout() {        
        Test.setMock(HttpCalloutMock.class, new OrderBatchMock());
        
        OrderBatch orderBatch = new OrderBatch();
        //ScheduleOrderBatch scheduleBatch = new ScheduleOrderBatch();
        
        
        Test.startTest();
        database.executeBatch(orderBatch,200);
         /*
        String jobId = System.schedule('testBasicScheduledApex',
                                       ScheduleOrderBatch.CRON_EXP, 
                                       new TestScheduledApexFromTestMethod());
        */
        Test.stopTest();
    }
}