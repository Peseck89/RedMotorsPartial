@isTest(seeAllData=true)
public class ct_otRedis_ctrl_tst {
@IsTest
    static void testGetData(){
        List<WorkOrder> lstWorkOrder = [Select Id From WorkOrder LIMIT 1];
        ct_otRedis_ctrl.getWorkOrderData(lstWorkOrder[0].id);
        List<Case> lstContactCase = [Select Id From Case Where Contact.Email != null AND AccountId != null AND Status != 'Cerrado' LIMIT 1];
        List<WorkOrder> lstCase = [SELECT Id, Detalle_Asesor__c,caseId FROM WorkOrder WHERE caseId != null LIMIT 1];
        ct_otRedis_ctrl.saveDetalleAsesor(lstCase[0].Id,'Test');
		List<AssetWarranty> warrantyRecord = [SELECT Id,WarrantyName__c,Details_Warranty__c,EndDate,Vigencia__c,Cambio_de_owner__c,WarrantyType,AssetId FROM AssetWarranty WHERE AssetId != null LIMIT 1];
        ct_otRedis_ctrl.getAsset(warrantyRecord[0].AssetId); 
        List<Subtipo_de_trabajo_del_caso__c> subTrabajos = [Select Id From Subtipo_de_trabajo_del_caso__c Where Orden_de_trabajo__c != null Limit 1];
        ct_otRedis_ctrl.getTrabajos(subTrabajos[0].id);
        List<Account> lstAcc = [SELECT Id, Comentario__c FROM Account LIMIT 1];
        ct_otRedis_ctrl.updateAccountComment(lstAcc[0].id,'Test');
        ct_otRedis_ctrl.updateAssetComment(warrantyRecord[0].AssetId,'Test');
        ct_otRedis_ctrl.getWorkOrderLineItems(lstContactCase[0].id);
        ct_otRedis_ctrl.getCaseIdFromWorkOrder(lstWorkOrder[0].id);
        ct_otRedis_ctrl.getWorkOrderDetails(lstWorkOrder[0].id);
        ct_otRedis_ctrl.dummy();
    }
}