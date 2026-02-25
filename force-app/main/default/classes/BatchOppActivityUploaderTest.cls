@istest
public class BatchOppActivityUploaderTest {
    @istest
    public static void testmethod1 (){
        Id idBMW = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
        Id idMini = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('MINI').getRecordTypeId();
        Id idMotorrad = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Motorrad').getRecordTypeId();
        Id recordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Campana_Red_Motors').getRecordTypeId();
        
        Campaign campanna = new Campaign(Name='Campaign',RecordTypeId = recordTypeId);
        insert campanna;
        
        
        Opportunity op = new Opportunity(
            Name = 'TestNameXF',
            CloseDate = System.today().AddMonths(3),
            StageName = 'Oportunidad Calificada',
            Campana__c = campanna.Id,
            RT_Lead__c = 'MINI'
        );      
        insert op;
        System.debug('Opp Full '+op);
         List<Opportunity> oppList = [Select Id,Name,RecordType.Name From Opportunity where Name = 'TestNameXF'];
        system.debug('OPP2 : '+oppList);
        
        Task t = new Task();
        t.WhatId = op.id;
        t.TaskSubtype = 'Task';
        t.Subject = 'Call';
        insert t;
        
        Event et = new Event();
        et.WhatId = op.Id;
        et.DurationInMinutes = 1;
        et.ActivityDateTime = Datetime.now();
        insert et;
        
        Datetime dtTime=System.now();
        date dt= date.newinstance(dtTime.year(), dtTime.month(), dtTime.day());
        date last6Month = dt.addMonths(-6);
        //Test.setCreatedDate(op.Id, last6Month); 
        
        Test.startTest();
        BatchOppActivityUploader obj = new BatchOppActivityUploader(system.today());
        DataBase.executeBatch(obj);
        
        obj = new BatchOppActivityUploader(system.today(), true);
        DataBase.executeBatch(obj);
        Test.stopTest();
    }
    
    @istest
    public static void testmethod3 (){
        Id idBMW = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
        Id idMini = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('MINI').getRecordTypeId();
        Id idMotorrad = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Motorrad').getRecordTypeId();
        Id recordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Campana_Red_Motors').getRecordTypeId();
        
        Campaign campanna = new Campaign(Name='Campaign',RecordTypeId = recordTypeId);
        insert campanna;
        
        
        Opportunity op = new Opportunity(
            Name = 'TestNameXF',
            CloseDate = System.today().AddMonths(3),
            StageName = 'Oportunidad Calificada',
            Campana__c = campanna.Id,
            RT_Lead__c = 'MINI'
        );      
        insert op;
        System.debug('Opp Full '+op);
         List<Opportunity> oppList = [Select Id,Name,RecordType.Name From Opportunity where Name = 'TestNameXF'];
        system.debug('OPP2 : '+oppList);
        
        Datetime dtTime=System.now();
        date dt= date.newinstance(dtTime.year(), dtTime.month(), dtTime.day());
        date last6Month = dt.addMonths(-6);
        //Test.setCreatedDate(op.Id, last6Month); 
        
        Test.startTest();
        BatchOppActivityUploader obj = new BatchOppActivityUploader(system.today());
        DataBase.executeBatch(obj);
        
        obj = new BatchOppActivityUploader(system.today(), false);
        DataBase.executeBatch(obj);
        Test.stopTest();
    }
    
    @istest
    public static void testmethod2 (){
         Id idBMW = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
        Id idMini = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('MINI').getRecordTypeId();
        Id idMotorrad = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Motorrad').getRecordTypeId();
        
        Id recordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Campana_Red_Motors').getRecordTypeId();
        
        Campaign campanna = new Campaign(Name='Campaign',RecordTypeId = recordTypeId);
        insert campanna;
        
        contact con = new contact ();
        con.FirstName='test';
        con.LastName='test';
        insert con;
        
        Opportunity op = new Opportunity(
            Name = 'TestNameXC',
            CloseDate = System.today().AddMonths(3),
            StageName = 'Oportunidad Calificada',
            Campana__c = campanna.Id,
            RT_Lead__c = 'BMW'
            
        );      
        insert op;
        
        List<Opportunity> oppList = [Select Id,Name,RecordType.Name From Opportunity where Name = 'TestNameXC'];
        system.debug('OPP : '+oppList);
        
        
        Datetime dtTime=System.now();
        date dt= date.newinstance(dtTime.year(), dtTime.month(), dtTime.day());
        date last6Month = dt.addMonths(-6);
        //Test.setCreatedDate(op.Id, last6Month); 
        
        Test.startTest();
        BatchOppActivityUploader obj = new BatchOppActivityUploader(system.today());
        DataBase.executeBatch(obj);
        Test.stopTest();
    }
    @istest
    public static void runtest1(){
         Id idBMW = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
        Id idMini = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('MINI').getRecordTypeId();
        Id idMotorrad = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Motorrad').getRecordTypeId();
        
        contact con = new contact();
        con.FirstName='test';
        con.LastName='test';
        insert con;
        
        Id recordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Campana_Red_Motors').getRecordTypeId();
        
        Campaign campanna = new Campaign(Name='Campaign',RecordTypeId = recordTypeId);
        insert campanna;
        
        
        Opportunity op = new Opportunity(
            Name = 'TestNameXE',
            CloseDate = System.today().AddMonths(3),
            StageName = 'Oportunidad Calificada',
            Campana__c = campanna.Id,
            RT_Lead__c = 'BMW'
        ); 
        List<Opportunity> oppList = [Select Id,Name,RecordType.Name From Opportunity where Name = 'TestNameXE'];
        system.debug('OPP3 : '+oppList);
        insert op;
        
        Task t = new Task();
        t.WhatId = op.id;
        t.TaskSubtype = 'Task';
        t.Subject = 'Llamada';
        insert t;
        
        Event et = new Event();
        et.WhatId = op.Id;
        et.DurationInMinutes = 1;
        et.Subject = 'Call';
        et.ActivityDateTime = Datetime.now();
        insert et;
        
        Test.startTest();
        String cronexpression = '0 0 0 15 3 ? *';
        String jobId = System.schedule('ScheduleBatchApexClass',  cronexpression, new OppActivityUploader());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(cronexpression, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
        
    }
    
        public static void runtest2(){
         Id idBMW = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
        Id idMini = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('MINI').getRecordTypeId();
        Id idMotorrad = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Motorrad').getRecordTypeId();
        
        contact con = new contact();
        con.FirstName='test';
        con.LastName='test';
        insert con;
        
        Id recordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Campana_Red_Motors').getRecordTypeId();
        
        Campaign campanna = new Campaign(Name='Campaign',RecordTypeId = recordTypeId);
        insert campanna;
        
        
        Opportunity op = new Opportunity(
            Name = 'TestNameXE2',
            CloseDate = System.today().AddMonths(3),
            StageName = 'Oportunidad Calificada',
            Campana__c = campanna.Id,
            RT_Lead__c = 'Polaris'
        ); 
        List<Opportunity> oppList = [Select Id,Name,RecordType.Name From Opportunity where Name = 'TestNameXE2'];
        system.debug('OPP3 : '+oppList);
        insert op;
        
        Event et = new Event();
        et.WhatId = op.Id;
        et.Subject = 'Call';
        et.DurationInMinutes = 1;
        et.ActivityDateTime = Datetime.now();
        insert et;
        
        Test.startTest();
        String cronexpression = '0 0 0 15 3 ? *';
        String jobId = System.schedule('ScheduleBatchApexClass',  cronexpression, new OppActivityUploader());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(cronexpression, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
        
    }
}