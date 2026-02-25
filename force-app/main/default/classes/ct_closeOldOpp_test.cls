@isTest(SeeAllData=true)
public with sharing class ct_closeOldOpp_test {

	private static testmethod void getFilteredDateTest(){   
        Test.startTest();
        ct_closeOldOpp_batch obj = new ct_closeOldOpp_batch();
       	id jobid = DataBase.executeBatch(obj); 
        List<Opportunity> lstOpp = [Select Id, fechaentrega__c, FechaEstimadaEntrega__c, StageName, DiasCreada__c, Departamento__c, RazonVentaPerdida__c, Tipo_de_Cliente__c, Days_Changed__c,RecordType.name   From Opportunity WHERE ((DiasCreada__c >= 180 AND Days_Changed__c >= 180) OR (DiasCreada__c = 180 AND Days_Changed__c = null)) AND RecordType.name IN ('BMW','MINI') AND StageName != 'Cerrada Ganada' AND StageName != 'Cerrada Perdida' LIMIT 1];
	    obj.execute(null,lstOpp);
        System.debug(jobid);
        Test.stopTest();

    }

    @isTest static void testExecute() {
        // Create a test instance of SchedulableContext
        Test.startTest();
        String jobName = 'TestJob';
        String cronExp = '0 0 * * * ?'; // Set your desired cron expression
        ct_closeOldOpp_schedule jobInstance = new ct_closeOldOpp_schedule();
        String jobId = System.schedule(jobName, cronExp, jobInstance);


        // Ensure the scheduled job has been added to the queue
        List<CronTrigger> jobList = [SELECT Id, CronJobDetail.Name FROM CronTrigger];

        // Pause the test to allow the job to execute
        Test.stopTest();

    }
    
}