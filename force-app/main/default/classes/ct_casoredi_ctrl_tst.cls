@isTest(seeAllData=true)
public class ct_casoredi_ctrl_tst {
@IsTest
    static void testGetData(){
        List<Case> lstCase = [Select Id from Case Where Owner.Name != '' LIMIT 1];
        List<AssetWarranty> warrantyRecord = [SELECT Id,WarrantyName__c,Details_Warranty__c,EndDate,Vigencia__c,Cambio_de_owner__c,WarrantyType,AssetId FROM AssetWarranty WHERE AssetId != null LIMIT 1];
        ct_casoredi_ctrl.getCaseData(lstCase[0].Id);
        ct_casoredi_ctrl.getAssetWarranty(warrantyRecord[0].AssetId+'');
        ct_casoredi_ctrl.getAssetWarranty(warrantyRecord[0].AssetId+'');
       	List<Case> lstContactCase = [Select Id From Case Where Contact.Email != null AND AccountId != null AND Status != 'Cerrado' LIMIT 1];
        ct_casoredi_ctrl.updateCaseFacturacion(lstContactCase[0].Id+'');
        ct_casoredi_ctrl.saveDetalleAsesor(lstContactCase[0].Id+'', 'Test');
        ct_casoredi_ctrl.updateCaseKilometraje(lstContactCase[0].Id,10000000);
        //ct_casoredi_ctrl.updateAssetkilometraje(warrantyRecord[0].AssetId+'',10000000);
        ct_casoredi_ctrl.updateAssetComment(warrantyRecord[0].AssetId+'','Test');
        ct_casoredi_ctrl.getAsset(warrantyRecord[0].AssetId+'');
        ct_casoredi_ctrl.saveNumeroGuia(lstContactCase[0].Id+'', 'Test');
        ct_casoredi_ctrl.saveColorGuia(lstContactCase[0].Id+'', 'Test');
        ct_casoredi_ctrl.saveObjetoValorText(lstContactCase[0].Id+'', 'Test');
        ct_casoredi_ctrl.saveRepuestos(lstContactCase[0].Id,true);
        ct_casoredi_ctrl.saveLavado(lstContactCase[0].Id,true);
        ct_casoredi_ctrl.saveObjetoValor(lstContactCase[0].Id,true);
        
        
        ct_casoredi_ctrl.getTrabajos(lstCase[0].Id+'');
        ct_casoredi_ctrl.getWO(lstCase[0].Id+'');
        
        List<Subtipo_de_trabajo_del_caso__c> subTrabajos = [Select Id,
        Name,
        Tipo_de_trabajo_del_caso__c, 
        Tipo_de_trabajo_del_caso__r.Name,
        Cantidad_de_horas__c,Caso__c,
        Articulo_Mano_de_Obra__c,
        Articulo_Mano_de_Obra__r.NombreProducto__c,
        Articulo_Mano_de_Obra__r.BMW_CodigoDeProducto__c,
        Tipo_de_trabajo_del_caso__r.Tipo_de_cargo__c,
        Articulo_Mano_de_Obra__r.Cantidad__c,
        Articulo_Mano_de_Obra__r.TotalPrice,Articulo_Mano_de_Obra__r.CurrencyIsoCode
        from  Subtipo_de_trabajo_del_caso__c WHERE Caso__c != null LIMIT 1];
        ct_casoredi_ctrl.getTrabajosOld(subTrabajos[0].Caso__c+'');
        ct_casoredi_ctrl.dummy();
    }
}