@IsTest
public class RM_CT_GestionMecanicos_Ctrl_Test {

    @TestSetup
    static void setup() {
        RM_CT_TestDataFactory.createCaseWithWorkSteps();
    }

    @IsTest
    static void testGetData() {
        
        Case c = [SELECT Id,CaseNumber FROM Case LIMIT 1];
        
        String caseId = (String) c.Id;
        
        Map<String,Object> result = RM_CT_GestionMecanicos_Ctrl.getData(null, null, null);
        
        RM_CT_GestionMecanicos_Ctrl.getTipoValues();

        String mechanicId = RM_CT_TestDataFactory.getMechanicRecordTypeId();

        Contact mechanic = [SELECT Id FROM Contact WHERE RecordTypeId = :mechanicId LIMIT 1];

        ServiceTerritory st = [SELECT Id FROM ServiceTerritory LIMIT 1];

        Test.startTest();
        
        RM_CT_GestionMecanicos_Ctrl.crearActividad(mechanic.Id,st.Id,'Salida Taller');

        RM_CT_GestionMecanicos_Ctrl.getTerritoriesByContactId(mechanic.Id);

        RM_CT_GestionMecanicos_Ctrl.getTerritoriesByUserId(UserInfo.getUserId());

        Test.stopTest();
    
    }
}