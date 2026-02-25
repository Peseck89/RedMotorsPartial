@isTest
private class UpdateCurrencySchedulerTest {
    static testmethod void updateProduct_Otobai_Local(){
        Product2 prdt = new Product2(Name = 'test', Codigo_de_Producto__c='75689778568975434', CurrencyIsoCode='USD');
        insert prdt;
        
        Pricebook2 pb = new Pricebook2(Name = 'Otobai Local');
        insert pb;
        
        PricebookEntry pbe = new PricebookEntry(Product2Id = prdt.Id, Pricebook2Id = pb.Id, UnitPrice = 2.0, CurrencyIsoCode = 'USD');
        insert pbe;
        
        Test.startTest();
        String s = '0 0 23 * * ?';
        String JobId = System.Schedule('Test Sched', s, new UpdateCurrencyScheduler());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(s, ct.CronExpression);
        Test.stopTest();
        
        System.assertEquals('Otobai Local', [Select Name from Pricebook2 where Name = :'Otobai Local'].Name);   
    }
    
    static testmethod void updateProduct_Otobai_Dolares(){
        Product2 prdt = new Product2(Name = 'test', Codigo_de_Producto__c='75689778568975434', CurrencyIsoCode='USD');
        insert prdt;
        
        Pricebook2 pb = new Pricebook2(Name = 'Otobai Dólares');
        insert pb;
        
        PricebookEntry pbe = new PricebookEntry(Product2Id = prdt.Id, Pricebook2Id = pb.Id, UnitPrice = 2.0, CurrencyIsoCode = 'CRC');
        insert pbe;
        
        Test.startTest();
        String s = '0 0 23 * * ?';
        String JobId = System.Schedule('Test Sched', s, new UpdateCurrencyScheduler());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(s, ct.CronExpression);
        Test.stopTest();
        
        System.assertEquals('Otobai Dólares', [Select Name from Pricebook2 where Name = :'Otobai Dólares'].Name);
    }
    
    static testmethod void updateProduct_Bavarian_Local(){
        Product2 prdt = new Product2(Name = 'test', Codigo_de_Producto__c='75689778568975434', CurrencyIsoCode='USD');
        insert prdt;
        
        Pricebook2 pb = new Pricebook2(Name = 'Bavarian Local');
        insert pb;
        
        PricebookEntry pbe = new PricebookEntry(Product2Id = prdt.Id, Pricebook2Id = pb.Id, UnitPrice = 2.0, CurrencyIsoCode = 'USD');
        insert pbe;
        
        Test.startTest();
        String s = '0 0 23 * * ?';
        String JobId = System.Schedule('Test Sched', s, new UpdateCurrencyScheduler());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(s, ct.CronExpression);
        Test.stopTest();
        
        System.assertEquals('Bavarian Local', [Select Name from Pricebook2 where Name = :'Bavarian Local'].Name);
    }
    
    static testmethod void updateProduct_Bavarian_Dolar(){
        
        Product2 prdt = new Product2(Name = 'test', Codigo_de_Producto__c='75689778568975434', CurrencyIsoCode='USD');
        insert prdt;
        
        Pricebook2 pb = new Pricebook2(Name = 'Bavarian Dólar');
        insert pb;
        
        PricebookEntry pbe = new PricebookEntry(Product2Id = prdt.Id, Pricebook2Id = pb.Id, UnitPrice = 2.0, CurrencyIsoCode = 'CRC');
        insert pbe;
        
        Test.startTest();
        String s = '0 0 23 * * ?';
        String JobId = System.Schedule('Test Sched', s, new UpdateCurrencyScheduler());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(s, ct.CronExpression);
        Test.stopTest();
        
        System.assertEquals('Bavarian Dólar', [Select Name from Pricebook2 where Name = :'Bavarian Dólar'].Name);
    }
}