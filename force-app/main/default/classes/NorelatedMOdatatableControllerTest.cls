@isTest
public class NorelatedMOdatatableControllerTest {

	static testMethod void NorelatedMOdatatableControllerTest() {
       		
        ActividadComercial__c act = new ActividadComercial__c();
        act.Name = 'VENTA DE REPUESTOS NUEVOS PARA AUTOMOVIL';
        insert act;
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

        Id pricebookId = pb.Id;
        
        CentroCosto__c cc = new CentroCosto__c();
        insert cc;
        
        WorkOrder wo = new WorkOrder(subject ='title2', Pricebook2Id=pricebookId, tipoDeGasto__c='Cliente', AssetId=asset.Id,AccountId=acc.Id);
        insert wo;
        
        WorkOrder tmp = [Select PriceBook2Id from WorkOrder Where Id = :wo.id];
        //system.assertEquals(pricebookId,tmp.PriceBook2Id,'The workorder price book was modified after it was inserted');

        //Insert product        
        Product2 prod= new Product2(IsActive=true, Name='Test product2', ProductCode='00012', Codigo_de_Producto__c='0012');
        insert prod;
        
        Product2 prodMO= new Product2(IsActive=true, Name='Mano de Obra',tipoProducto__c='Mano de Obra', ProductCode='00012', Codigo_de_Producto__c='0012');
        // and created_From__c != 'caseWorkTypes' and isRelatedToCase__c = false
        insert prodMO;

        // Insert PricebookEntry

        //Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id =pricebookId, Product2Id = prod.Id, UnitPrice = 2000, IsActive = true);
        insert standardPBE;
        
       
		Case caseTest = new Case();
        caseTest.Description='Test';
        caseTest.Subject = 'Test';
        caseTest.AccountId=acc.Id;
        insert caseTest;
        NorelatedMOdatatableControllerTest.staticWolisHelper(wo.Id,15,standardPBE.Id,cc.Id,prodMO.Id);
        
        tiposDeTrabajo__c tipotraba = new tiposDeTrabajo__c(Name='Mantenimiento');
        insert tipotraba;
        
        wo.Etapa_de_flujo_de_trabajo__c='Aprobación de presupuesto';
        wo.AccountId=acc.Id;
        wo.ActividadComercial__c = act.Id;
        wo.Tipo_de_Cargo__c = 'x';
        //update wo;
        
        ProductConsumed pc = new ProductConsumed(WorkorderId = wo.Id,PriceBookEntryId = standardPBE.Id,QuantityConsumed = 1);
        insert pc;
        

    
        List<NorelatedMOdatatableController.mowrapper> wrappers = NorelatedMOdatatableController.getNoRelatedMOs(wo.id);
        for(NorelatedMOdatatableController.mowrapper wrapper: wrappers){
            wrapper.workTypeID=(tipotraba.id);
            wrapper.caseId=caseTest.id;
        }
        NorelatedMOdatatableController.saveUnrelatedMOs(JSON.serialize(wrappers), wo.id,null);
        System.debug(NorelatedMOdatatableController.getWorkTypeName(tipotraba.id));
    }
    
    private static void staticWolisHelper(id Workorder,integer wolisQuantity,id pricebook,id centroCosto,id product){
        List <WorkOrderLineItem> wolis = new List <WorkOrderLineItem>();
        for(integer i= 0;i<wolisQuantity; i++ ){
             WorkOrderLineItem woli = new WorkOrderLineItem(workOrderId = Workorder, description = 'abcd2', Quantity=i+1, PricebookEntryId=pricebook, centroCosto__c =centroCosto,Product__c=product,
                                                       Trabajo__c ='Mano de Obra',Alias_Articulo__c='Alias'+i,porcentajeDescuento__c=i+2);
            wolis.add(woli);
            
        }
        insert wolis;
    }
}