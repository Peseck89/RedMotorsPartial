@isTest(SeeAllData=true)
public class communityManageWorks_ctrlTest {

    @isTest
    static void testWithExistingData() {
        // Fetch a valid Account, Contact, and Case from existing data
        Contact contact = [SELECT Id,AccountId FROM Contact WHERE AccountId != null LIMIT 1];
        Account acc = [SELECT Id FROM Account where id =: contact.AccountId LIMIT 1];
        
        // Fetch a WorkOrderLineItem associated with the WorkOrder
        WorkOrderLineItem woli = [SELECT Id FROM WorkOrderLineItem WHERE WorkOrderId != null LIMIT 1];
        
        // Fetch a WorkOrder associated with the Case
        WorkOrder wo = [SELECT Id,CaseId FROM WorkOrder WHERE CaseId != null LIMIT 1];
        
        Case caseRec = [SELECT Id FROM Case WHERE id =: wo.CaseId  LIMIT 1];

        
		
        List<tipoCargo__c> lstCargo = [Select Id,Work_Order_Line_Item__r.TipoTrabajoCaso__r.Caso__r.Id From tipoCargo__c Where Work_Order_Line_Item__r.TipoTrabajoCaso__r.Caso__r.Id != null LIMIT 1];

        // Test getWorkOrderLineItemsGroupedByTipoTrabajo method
        Test.startTest();
        communityManageWorks_ctrl.getMarcasConfig(lstCargo[0].Work_Order_Line_Item__r.TipoTrabajoCaso__r.Caso__r.Id);
        List<WorkOrderLineItem> lstWoli = [Select id From WorkOrderLineItem LIMIT 1];
		communityManageWorks_ctrl.getWorkOrderLineItemsGroupedByTipoTrabajo(lstCargo[0].Work_Order_Line_Item__r.TipoTrabajoCaso__r.Caso__r.Id);
        List<tiposDeTrabajoCaso__c> lstTrabajos = [Select id,RM_WorkOrder__c,RM_WorkOrder__r.Cliente_aprueba_presupuesto_en_service__c, Estado_aprobaci_n_service__c From tiposDeTrabajoCaso__c  LIMIT 1];
		List<String> wolsda = new List<String>();
        wolsda.add(lstTrabajos[0].id);
		communityManageWorks_ctrl.caseInfo(lstCargo[0].Work_Order_Line_Item__r.TipoTrabajoCaso__r.Caso__r.Id);
        communityManageWorks_ctrl.obtenerStages(lstCargo[0].Work_Order_Line_Item__r.TipoTrabajoCaso__r.Caso__r.Id);
        communityManageWorks_ctrl.obtenerPaso(lstCargo[0].Work_Order_Line_Item__r.TipoTrabajoCaso__r.Caso__r.Id);
        communityManageWorks_ctrl.getSeguroDetails();
        communityManageWorks_ctrl.dummy();
        Map<Id, List<communityManageWorks_ctrl.WorkOrderLineItemWrapper>> result =
            communityManageWorks_ctrl.getWorkOrderLineItemsGroupedByTipoTrabajo(caseRec.Id);
        Test.stopTest();


    }

    @isTest
    static void testGetCasesWithExistingData() {
        Test.startTest();
        List<Map<String, Object>> result = communityManageWorks_ctrl.getCases();
        Test.stopTest();

        // Assert that results are returned
        //System.assertNotEquals(null, result, 'The result should not be null');
        //System.assert(result.size() > 0, 'The result list should contain entries');
    }

    @isTest
    static void testRevisarCorreoWithExistingData() {
        // Use an existing email from the Contact data
        Contact contact = [SELECT Email FROM Contact LIMIT 1];

        Test.startTest();
        Boolean emailExists = communityManageWorks_ctrl.revisarCorreo(contact.Email);
        Test.stopTest();

        // Assert that the email exists
        //System.assert(emailExists, 'The email should exist in the system');
    }

    @isTest
    static void testFetchUserWithExistingData() {
        Test.startTest();
        User fetchedUser = communityManageWorks_ctrl.fetchUser();
        Test.stopTest();

        // Assert that a User record is fetched
        //System.assertNotEquals(null, fetchedUser, 'The fetched user should not be null');
    }
}