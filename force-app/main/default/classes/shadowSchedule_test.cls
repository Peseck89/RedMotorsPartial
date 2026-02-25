@isTest(seeAllData = true)
public with sharing class shadowSchedule_test {
    @isTest
    static void testExecute() {
        
        List<AsesorxCalendario__c> lstAsecCal = [Select Id,Asesor__c,Calendario__c From AsesorxCalendario__c WHERE Calendario__c = '0054U000009hiwHQAQ'];
        
        Event_Shadow__c testEventShadow = new Event_Shadow__c(
            Asesor__c = lstAsecCal[0].Calendario__c,
            Calendar__c = lstAsecCal[0].Calendario__c,
            StartDateTime__c = Date.today()
        );
        insert testEventShadow;
        
        // Call the scheduled job
        Test.startTest();
        shadowSchedule job = new shadowSchedule();
        String jobId = System.schedule('Test shadowSchedule', '0 0 0 * * ?', job);
        Test.stopTest();
                
    }
}