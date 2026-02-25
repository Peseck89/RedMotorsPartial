@isTest
public with sharing class CaseWorkTypeControllerTest {

 @IsTest
 static void testExisOrder(){
    
    Case caseOne = new Case();
    insert caseOne;  
    
    WorkOrder wo = new WorkOrder(
        CaseId = caseOne.Id 
    );
    insert wo;

    System.assert(CaseWorkTypeController.existWorkOrder(caseOne.Id)!=null);

    wo.CaseId = null;
    update wo;

    System.assert(CaseWorkTypeController.existWorkOrder(caseOne.Id)==null);

    System.assert(CaseWorkTypeController.existWorkOrder('ss')==null);

 }

}