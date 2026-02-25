@isTest
public class CaseTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        RM_CT_TestDataFactory.createCaseWithWorkSteps();    
    }

    @isTest
    public static void testCompletarTrabajosYSubtrabajosCasoCerrado() {
        List<Case> cases = [SELECT Id, Status FROM Case LIMIT 1];
        cases[0].Status = 'Cerrado';

        List<WorkStep> workSteps = [SELECT Id, Status FROM WorkStep WHERE Caso__c = :cases[0].Id];
        System.debug('workSteps: ' + workSteps);
        update cases;

        // Case cs = new Case(Create_Orders_from_Workorders__c = true);
        // insert cs;
        
        // Test.startTest();
        // Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        // update cs;
        // Test.stopTest();
    }
    
    // public class ExampleCalloutMock implements HttpCalloutMock{
    //     public HttpResponse respond(HTTPRequest req){
    //         HttpResponse res = new HttpResponse();
    //         res.setStatus('OK');
    //         res.setStatusCode(200);
    //         res.setBody('{"access_token":"","token_type":""}');
    //         return res;
    //     }
    // }
}