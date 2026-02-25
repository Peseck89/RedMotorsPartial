@IsTest
public  class WorkStepTriggerHandlerTest {
    public static String USER_EMAIL = 'marcotest@test.com';
    public static String WORK_STEP_NAME = 'cambio de aceite test';
    public static String VEHICLE_PLATE = 'ABCTEST01';   

    @TestSetup
    static void makeData(){
        RM_CT_TestDataFactory.createCaseWithWorkSteps();
    }

    @IsTest
    public static void testValidarTareaEnCurso(){
        Contact mechanic = TestDataFactory.createContact('Robot','Mechanic',null,'Contacto de Taller', true);
        List<WorkStep> workStepList = [SELECT Id,Name,RM_Mecanico__c,Status FROM WorkStep WHERE RM_Mecanico__c = null];        
       
        workStepList[0].RM_Mecanico__c = mechanic.Id;
        workStepList[1].RM_Mecanico__c = mechanic.Id;
        update workStepList;            

        workStepList[0].Status = 'En curso';
        update workStepList;      

        try {
            workStepList[1].Status = 'En curso';
            update workStepList;            
        } catch (DmlException e) {
            System.assertEquals(true, e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
            System.assertEquals(true, e.getMessage().contains('El mecánico ya tiene una tarea'));
        }
    }
}