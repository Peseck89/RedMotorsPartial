@isTest(seeAllData = true)
public class EventTriggerHandlerTest {
    @isTest
    public static void testEventTriggerHandler() {
        Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        acc.codigoSoftland__c = '1234';
        
        insert acc;
        
        Case cs = new Case(Create_Orders_from_Workorders__c = true);
        insert cs;
        
        Asset asset = new Asset(Name = 'Teswtes',numeroDePlaca__c='ASDss3',NumeroDeChasis__c = '1234567890asdfghj',
                                AccountId = acc.Id);
        insert asset;
        
        List<Calendar> calendarList = [SELECT Id FROM Calendar LIMIT 1];
        
        WorkType wt = new WorkType(Name = 'Mecánica Rapida',
                                   EstimatedDuration = 100);
        insert wt;
        
        Event event = new Event(StartDateTime = System.now().addDays(1),
                                EndDateTime = System.now().addDays(3),
                                tipoCargoAseguradora__c = true,
                                Activo__c = asset.Id,
                                OwnerId = calendarList[0].Id);
        
        try{insert event;}catch(Exception ex){}
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        update cs;
        Test.stopTest();
    }
    
    @isTest
    public static void testEventTriggerHandlerWithUser() {
        Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        acc.codigoSoftland__c = '1234';
        
        insert acc;
        
        Case cs = new Case(Create_Orders_from_Workorders__c = true);
        insert cs;
        
        Asset asset = new Asset(Name = 'Testese',numeroDePlaca__c='SSD1S3',NumeroDeChasis__c = '1234567890asddghj',
                                AccountId = acc.Id);
        insert asset;
        
        List<Calendar> calendarList = [SELECT Id FROM Calendar LIMIT 1];
        
        WorkType wt = new WorkType(Name = 'Mecánica Rapida',
                                   EstimatedDuration = 100);
        insert wt;
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id,
            LastName = 'Calendario Pavas - Mecánica Rápida',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u;
        Event event = new Event(StartDateTime = System.now().addDays(1),
                                EndDateTime = System.now().addDays(3),
                                tipoCargoAseguradora__c = true,
                                Activo__c = asset.Id,
                                OwnerId = u.id);
        insert event;
        
        try {
            event.StartDateTime = System.now().addDays(-1);
            update event;
            // If no error is thrown, fail the test
            System.assert(false, 'Expected an error when inserting an event with a past start date.');
        } catch (DmlException e) {
            // Verify the error message
            System.assert(e.getMessage().contains('No se puede crear un evento en el pasado.'));
        }
        
        //try{insert event;}catch(Exception ex){}
        // Create an event with a start date in the past
        Event pastEvent = new Event(
            StartDateTime = System.now().addDays(-1),  // 1 day in the past
            EndDateTime = System.now().addDays(1)      // 1 day in the future to ensure end date is valid
        );

        // Try to insert the event
        try {
            insert pastEvent;
            // If no error is thrown, fail the test
            System.assert(false, 'Expected an error when inserting an event with a past start date.');
        } catch (DmlException e) {
            // Verify the error message
            System.assert(e.getMessage().contains('No se puede crear un evento en el pasado.'));
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        update cs;
        event.StartDateTime = System.now()+1;
        //update event;
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