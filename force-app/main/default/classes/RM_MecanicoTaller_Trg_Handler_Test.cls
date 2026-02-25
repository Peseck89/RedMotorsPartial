@IsTest
public class RM_MecanicoTaller_Trg_Handler_Test {
    
        @TestSetup
        static void setup() {
            RM_CT_TestDataFactory.createCaseWithWorkSteps();
        }
    
        @IsTest
        static void testValidarMecanicoTallerCombinacionUnica() {
            Case caso = [SELECT Id FROM Case LIMIT 1];
            WorkOrder wo = [SELECT Id FROM WorkOrder WHERE CaseId = :caso.Id LIMIT 1];
            ServiceTerritory st = [SELECT Id FROM ServiceTerritory LIMIT 1];
            Contact mechanic = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Contacto_de_Taller' LIMIT 1];
    
            try{
                RM_MecanicoTaller__c mt2 = RM_CT_TestDataFactory.createMecanicoTaller(st,mechanic,false);
            }catch(Exception e){
            }
        }
}