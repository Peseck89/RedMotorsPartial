@IsTest
public with sharing class RM_CT_VistaKanbanWorkOrder_Ctrl_Test {

    @TestSetup
    static void makeData(){
        RM_CT_TestDataFactory.createCaseWithWorkSteps();
    }
    
    @IsTest
    static void testGetRecords(){
        Case caso = [SELECT Id,StatusDetail__c,CaseNumber FROM Case  LIMIT 1];
        Asset asset = [SELECT Id,Name FROM Asset  LIMIT 1];
        WorkOrder workOrder = [SELECT Id,WorkOrderNumber FROM WorkOrder  LIMIT 1];
        ServiceTerritory st = [SELECT Id FROM ServiceTerritory LIMIT 1];
        
        Map<String,Object> responseMap1 = RM_CT_VistaKanbanWorkOrder_Ctrl.getRecords('',caso.StatusDetail__c,workOrder.WorkOrderNumber,caso.CaseNumber,asset.Name,null,null,null,1);
        Map<String,Object> responseMap2 = RM_CT_VistaKanbanWorkOrder_Ctrl.getRecords(st.Id,'',workOrder.WorkOrderNumber,caso.CaseNumber,asset.Name,null,null,null,1);
        Map<String,Object> responseMap3 = RM_CT_VistaKanbanWorkOrder_Ctrl.getRecords(st.Id,caso.StatusDetail__c,workOrder.WorkOrderNumber,caso.CaseNumber,asset.Name,null,null,null,1);

    }
}