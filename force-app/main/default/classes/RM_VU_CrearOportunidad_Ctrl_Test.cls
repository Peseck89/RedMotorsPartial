@IsTest
public with sharing class RM_VU_CrearOportunidad_Ctrl_Test {
    @TestSetup
    static void makeData(){
        RM_VU_TestDataFactory.prepareRecords();
    }

    @IsTest
    static void testCreateOpportunityUsed(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        ProductoXBodega__c prodXBod = [SELECT Id, Producto__c,Producto__r.Name,Bodega__c,Producto__r.ProductCode,Producto__r.Anno__c,Producto__r.marcaVehiculo__c,Producto__r.modelo__c,Producto__r.Color__c,Producto__r.Color_Externo__c,Producto__r.vin__c FROM ProductoXBodega__c WHERE Producto__r.es_Vehiculo_usado__c = true AND Producto__r.Producto_Reservado__c = FALSE AND Disponible__c > 0 AND Bodega__c != null LIMIT 1];
        
        List<RM_VU_CrearOportunidad_Ctrl.RM_VN_SelectedItem_Wrapper> selectedItems = new List<RM_VU_CrearOportunidad_Ctrl.RM_VN_SelectedItem_Wrapper>();

        PricebookEntry pbe = [SELECT Id,UnitPrice,Costo_Fijo__c,Pricebook2.Name,Product2.Name,Product2Id,Pricebook2Id,Jefe__c, Vendedor__c, Gerente__c FROM PricebookEntry WHERE Product2Id = :prodXBod.Producto__c AND Pricebook2.Name = :RM_VU_CrearOportunidad_Ctrl.PRICEBOOK_NAME AND IsActive = TRUE AND Pricebook2.IsActive = TRUE AND Product2.IsActive = TRUE LIMIT 1];        

        
        RM_VU_CrearOportunidad_Ctrl.RM_VN_SelectedItem_Wrapper selItem = new RM_VU_CrearOportunidad_Ctrl.RM_VN_SelectedItem_Wrapper();
        selItem.prodXBodId = prodXBod.Id;
        selItem.pbeId = pbe.Id;
        
        selectedItems.add(selItem);
         RM_VU_CrearOportunidad_Ctrl.validarCuenta(acc.id);
        RM_VU_CrearOportunidad_Ctrl.crearCuenta(acc.id, 'Tester', 'Tester','064421212','antonio.test@decs.com','antonio.test@decs.com');
        //RM_VU_CrearOportunidad_Ctrl.createOpportunity(acc.Id, selectedItems,null,null,null,null,null,null,null,null,null,null,null,null,null);
        RM_VU_CrearOportunidad_Ctrl.getRecordTypes();
        RM_VU_CrearOportunidad_Ctrl.dummy();
    }
}