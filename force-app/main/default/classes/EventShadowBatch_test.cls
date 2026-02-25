@isTest(seeAllData=true)
public class EventShadowBatch_test {

    @isTest
    static void test() {
            Test.startTest();
    			Event_Shadow__c newEvent = new Event_Shadow__c();
        		newEvent.StartDateTime__c = date.today()+20;
               	newEvent.EndDateTime__c = date.today() + 21;
        		List<Asset> contacto = [Select Id,Name,ContactId from Asset where ContactId != null];
                String idContacto = '';
                String idAsset = '';
                String nombreAsset = '';
                if(contacto.size()>0){
                    nombreAsset = contacto[0].Name;
                    idContacto = contacto[0].ContactId;
                    idAsset = contacto[0].id;
                }
        		newEvent.OrigenEvento__c = 'Formulario Web';
        		newEvent.Description__c = 'test';
        		newEvent.Activo__c = idAsset;
        		newEvent.ToBeProcessed__c = true;
        		newEvent.Asesor__c = '0050P0000074BeWQAU';
        		newEvent.Calendar__c = '0054U000009hipBQAQ';
        		newEvent.Description2__c = 'prueba2';
        		Insert newEvent;
                EventShadowBatch obj = new EventShadowBatch();
                DataBase.executeBatch(obj, 10 ); 
                List<Event_Shadow__c> lsttrig = [Select Id, CreatedDate, LastModifiedDate, StartDateTime__c, EndDateTime__c, Activo__c, Description__c, Description2__c, Estado2__c, OrigenEvento__c, Asesor__c, Calendar__c, OriginalEventId__c, Subject__c, WhatId__c FROM Event_Shadow__c WHERE ToBeProcessed__c = true LIMIT 5];
        		Database.BatchableContext bc;
		        obj.execute(bc,lsttrig);
        		newEvent.Description__c = 'test2';
	        	Update newEvent;
                DataBase.executeBatch(obj, 10 ); 
                List<Event_Shadow__c> lsttrig2 = [Select Id, CreatedDate, LastModifiedDate, StartDateTime__c, EndDateTime__c, Activo__c, Description__c, Description2__c, Estado2__c, OrigenEvento__c, Asesor__c, Calendar__c, OriginalEventId__c, Subject__c, WhatId__c FROM Event_Shadow__c WHERE ToBeProcessed__c = true LIMIT 5];
        		if(lsttrig2.size() > 0){
                    lsttrig2[0].Description__c = 'test';
                    update lsttrig2;
                }
	        	
		        obj.execute(bc,lsttrig2);
            Test.stopTest();
	}
    @isTest
    static void testSchedule() {
        	String CRON_EXP = '0 6 * * * ?';
            Test.startTest();
        
    			String jobId = System.schedule('Test Sched', CRON_EXP, new EventShadowBatch());
                CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
                System.assertEquals(CRON_EXP, ct.CronExpression);
                System.assertEquals(0, ct.TimesTriggered);
            Test.stopTest();
	}
}