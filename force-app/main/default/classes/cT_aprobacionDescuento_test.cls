@isTest(SeeAllData=True)
public class cT_aprobacionDescuento_test {
	private static testmethod void getFilteredDateTest(){   
        
        Pricebook2 PriceBook = new Pricebook2(Name='TestPB');
        Insert PriceBook;
        
        Account Acc = new Account(Name='Test Acc');
        Acc.Name='Test account';
        Acc.Cedula__c='9876543210';
        Acc.Tipo_de_Documento__c='02';
        Acc.codigoSoftland__c = '1234';        
        insert Acc;
        
        WorkOrder ordenTest = new WorkOrder();
        ordenTest.AccountId = Acc.id;
        ordenTest.Asesor_de_la_orden__c = UserInfo.getUserId();
        insert ordenTest;             
                
        Product2 Prod = new Product2(Name='Test Prod', Codigo_de_Producto__c='TestProd', tipoProducto__c='Mano de Obra');
        Insert Prod;
        PricebookEntry PBE = new PricebookEntry(Pricebook2Id=PriceBook.Id, Product2Id=Prod.Id, UnitPrice=5, IsActive=true); 
        Insert PBE;
        		
        
        Aprobaci_n_Descuento__c aprobDesc = new Aprobaci_n_Descuento__c();
        aprobDesc.Aprobador_Nivel_2__c = UserInfo.getUserId();
        aprobDesc.Aprobador_Nivel_3__c = UserInfo.getUserId();
        aprobDesc.Nivel_de_aprobaci_n__c = 'Nivel 3';
		insert aprobDesc;
        
         WorkOrderLineItem Woli = [SELECT Id, WorkOrderId FROM WorkOrderLineItem WHERE WorkOrderId!=null LIMIT 1];

        
        Descuento_por_linea__c  nuevoDesc = new Descuento_por_linea__c();
        nuevoDesc.Descuento__c = 100;
        nuevoDesc.Work_Order_Line_Item__c = Woli.id;
        nuevoDesc.Aprobaci_n_Descuento__c = aprobDesc.id;
        insert nuevoDesc;
        

        aprobDesc.Estado_nivel_1__c = 'Aprobado';
        try {
            update aprobDesc;
        } catch (Exception ex) {
        }
    }
    
    private static testmethod void getFilteredDateTest2(){   
        
        Pricebook2 PriceBook = new Pricebook2(Name='TestPB');
        Insert PriceBook;
        
        Account Acc = new Account(Name='Test Acc');
        Acc.Name='Test account';
        Acc.Cedula__c='9876543210';
        Acc.Tipo_de_Documento__c='02';
        Acc.codigoSoftland__c = '1234';        
        insert Acc;
        
        WorkOrder ordenTest = new WorkOrder();
        ordenTest.AccountId = Acc.id;
        ordenTest.Asesor_de_la_orden__c = UserInfo.getUserId();
        insert ordenTest;               
        
        Product2 Prod = new Product2(Name='Test Prod', Codigo_de_Producto__c='TestProd', tipoProducto__c='Mano de Obra');
        Insert Prod;
        PricebookEntry PBE = new PricebookEntry(Pricebook2Id=PriceBook.Id, Product2Id=Prod.Id, UnitPrice=5, IsActive=true); 
        Insert PBE;
        
        Aprobaci_n_Descuento__c aprobDesc = new Aprobaci_n_Descuento__c();
        aprobDesc.Aprobador_Nivel_2__c = UserInfo.getUserId();
        aprobDesc.Aprobador_Nivel_3__c = UserInfo.getUserId();
        aprobDesc.Nivel_de_aprobaci_n__c = 'Nivel 2';
		insert aprobDesc;
        
        WorkOrderLineItem Woli = [SELECT Id, WorkOrderId FROM WorkOrderLineItem WHERE WorkOrderId!=null LIMIT 1];

        
        Descuento_por_linea__c  nuevoDesc = new Descuento_por_linea__c();
        nuevoDesc.Descuento__c = 100;
        nuevoDesc.Work_Order_Line_Item__c = Woli.id;
        nuevoDesc.Aprobaci_n_Descuento__c = aprobDesc.id;
        insert nuevoDesc;
        
        aprobDesc.Estado_nivel_1__c = 'Aprobado';

         try {
            update aprobDesc;
        } catch (Exception ex) {
        }

        Descuento_por_linea__c  nuevoDesc2 = new Descuento_por_linea__c();
        nuevoDesc2.Descuento__c = 100;
        nuevoDesc2.Work_Order_Line_Item__c = Woli.id;
        nuevoDesc2.Aprobaci_n_Descuento__c = aprobDesc.id;
        insert nuevoDesc2;
        aprobDesc.Nivel_de_aprobaci_n__c = 'Nivel 3';
        aprobDesc.Estado_nivel_3__c = 'Aprobado';
        try {
            update aprobDesc;
        } catch (Exception ex) {
        }
    }    
}