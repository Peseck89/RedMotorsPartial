@isTest 
private class workOrderHistoryTest {
    
    static testMethod void workOrderHistoryTest() {
        
       	/*Account acc = new Account(Name='Test');
       	insert acc;
       	Contact co = new Contact(Firstname='Juan Diego',LastName='Espinoza S1', Email='jesp@abc.com', AccountId=acc.Id);
       	insert co;
       	Asset asset = new Asset(Name='BMW X6', ContactId=co.Id, AccountId=acc.Id);
       	insert asset;
        
       	
        
        Product2 prod = new Product2(Name='Parabrisas', Ano__c =2022, Codigo_de_Producto__c='AD32F');
        insert prod;
        
        Pricebook2 pb2 = new Pricebook2(Name='Parabrisas2', IsActive=True);
        insert pb2;
        
        PricebookEntry pb = new PricebookEntry(Product2Id=prod.Id, IsActive=True, UnitPrice =10000);
        insert pb;
        
        Workorder wo = new Workorder(ContactId=co.Id, AssetId=asset.Id, Status='Nuevo', tipoDeGasto__c='Cliente', Pricebook2Id=pb2.Id);
       	insert wo;
        
       	WorkOrderLineItem woli1 = new WorkOrderLineItem (WorkOrderId=wo.Id, AssetId=asset.Id, Description='1', PricebookEntryId=pb.Id, Product__c=prod.Id);
        WorkOrderLineItem woli2 = new WorkOrderLineItem (WorkOrderId=wo.Id, AssetId=asset.Id, Description='2', PricebookEntryId=pb.Id, Product__c=prod.Id);
        WorkOrderLineItem woli3 = new WorkOrderLineItem (WorkOrderId=wo.Id, AssetId=asset.Id, Description='3', PricebookEntryId=pb.Id, Product__c=prod.Id);
        insert woli1;
        insert woli2;
        insert woli3;*/
        
        Pricebook2 pb = new Pricebook2(Name='Dolar2', IsActive=true);
        insert pb;
        
        condicionPago__c condicionPago = new condicionPago__c(condicionPago__c='0',Descripcion__c='test desc', Name='0');
        insert condicionPago;
        
        Impuesto__c Impuesto = new Impuesto__c(codigoImpuesto__c='0108',descripcion__c='test desc',Impuesto__c=2, Name='test imp', porcentaje__c=3);
        insert Impuesto;
        
        Account acc = new Account(Name='Test account', Cedula__c='9876543210', Tipo_de_Documento__c='02', condicionPago__c=condicionPago.Id, Impuesto__c=Impuesto.Id);
       	insert acc;
        
       	Contact co = new Contact(Firstname='Juan Diego',LastName='Espinoza S1', Email='jesp@abc.com', AccountId=acc.Id);
       	insert co;
        
       	Asset asset = new Asset(Name='BMW X6', ContactId=co.Id, AccountId=acc.Id);
       	insert asset;
        
        Case caso = new Case();
        caso.AssetId = asset.id;
        insert caso;
        
       	Test.startTest();

        Id pricebookId = pb.Id;
        
        CentroCosto__c cc = new CentroCosto__c();
        insert cc;
        
        ActividadComercial__c actividad = new ActividadComercial__c(Name = 'VENTA DE REPUESTOS NUEVOS PARA AUTOMOVIL');
        insert actividad;
        
        
        //Insert product        
        Product2 prod= new Product2(IsActive=true, Name='Test product2', ProductCode='00012', Codigo_de_Producto__c='0012');
        insert prod;

        // Insert PricebookEntry 

        //Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id =pb.Id, Product2Id = prod.Id, UnitPrice = 2000, IsActive = true);
        insert standardPBE;
        System.debug('standardPBE-------------');
        System.debug(standardPBE.id);
        String spbe = standardPBE.id;
        
        
        System.debug('Antes de insertar wo');
        System.debug(pb.Id);
        WorkOrder wo = new WorkOrder(subject ='title2', Pricebook2Id=pb.Id, tipoDeGasto__c='Cliente', AssetId=asset.Id);
        //wo.Etapa_de_flujo_de_trabajo__c='Aprobación de presupuesto';
        wo.AccountId=acc.Id;
        wo.ActividadComercial__c = actividad.Id;
        wo.Tipo_de_Cargo__c = 'x';
        wo.caseId = caso.Id;
        insert wo;
        
        WorkOrder tmp = [Select PriceBook2Id from WorkOrder Where Id = :wo.id];
        System.debug('tmp');
        System.debug(tmp);
        //system.assertEquals(pricebookId,tmp.PriceBook2Id,'The workorder price book was modified after it was inserted');

        

        WorkOrderLineItem woli = new WorkOrderLineItem(workOrderId = wo.Id, description = 'abcd2', Quantity=2, PricebookEntryId=spbe, centroCosto__c = cc.Id);        
        //insert woli;

        //ProductConsumed pc = new ProductConsumed(WorkorderId = wo.Id,PriceBookEntryId = standardPBE.Id,QuantityConsumed = 1);
        //insert pc;
        
       	ApexPages.StandardController controller = new ApexPages.StandardController(wo);
        ApexPages.currentPage().getParameters().put('id', wo.AssetId);
       	WorkorderHistory woh = new WorkorderHistory(controller);
    }

}