@IsTest
public class RM_CT_MecanicosCasos_Ctrl_Test {

    @TestSetup
    static void makeData(){
        RM_CT_TestDataFactory.createCaseWithWorkSteps();
    }

    @IsTest
    static void testGetData(){
        List<Case> cases = [
            SELECT Id,
                (
                    SELECT Id
                    FROM Tipos_de_Trabajo__r
                )
            FROM Case
            LIMIT 1];

        tiposDeTrabajoCaso__c ttc = cases[0].Tipos_de_Trabajo__r[0];

        List<Contact> mechanics = [SELECT Id FROM Contact WHERE RecordTypeId = :RM_CT_TestDataFactory.getMechanicRecordTypeId() LIMIT 2];

        String mechanicId = (String) mechanics[0].Id;

        RM_CT_GestionTareas_Ctrl.asignarMechanico(ttc.Id, mechanicId);

        Test.startTest();
            RM_CT_MecanicosCasos_Ctrl.getData(mechanicId);
        Test.stopTest();
    }
}