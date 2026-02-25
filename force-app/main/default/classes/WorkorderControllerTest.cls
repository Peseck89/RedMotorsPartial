@isTest(SeeAllData=false)
public class WorkorderControllerTest {
    @isTest
    public static void testWorkorderController(){
        
        Pricebook2 pb = new Pricebook2();
        pb.Name='Dolar';
        pb.IsActive=true;
        //pb.IsStandard=true;
        insert pb;
        
        Test.startTest();

        Id pricebookId = Test.getStandardPricebookId();
        
        CentroCosto__c cc = new CentroCosto__c();
        insert cc;
        
        WorkOrder wo = new WorkOrder();
        wo.subject ='title';
        wo.Pricebook2Id=pricebookId;
        wo.tipoDeGasto__c='Cliente';
        //wo.Etapa_de_flujo_de_trabajo__c='Aprobación de presupuesto';
        
        insert wo;
        WorkOrder tmp = [Select PriceBook2Id from WorkOrder Where Id = :wo.id];
        //system.assertEquals(pricebookId,tmp.PriceBook2Id,'The workorder price book was modified after it was inserted');

        
        //Insert product        
        Product2 prod= new Product2();
        prod.IsActive=true;
        prod.Name='Test product';
        prod.ProductCode='00012';
        prod.Codigo_de_Producto__c='0012';
        insert prod;

        // Insert PricebookEntry

        //Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id =pricebookId, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;
        
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id =  tmp.Pricebook2Id;
        standardPrice.Product2Id = prod.Id;
        standardPrice.UnitPrice = 1;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        //insert standardPrice ;
        
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.workOrderId = wo.Id;
        woli.description = 'abcd';
        woli.Quantity=2;
        woli.PricebookEntryId=standardPBE.Id;
        woli.centroCosto__c = cc.Id;
        
        insert woli;

        //insert account:
        
        condicionPago__c condicionPago = new condicionPago__c();
        condicionPago.condicionPago__c='test cp';
        condicionPago.Descripcion__c='test desc';
        condicionPago.Name='test cp';
        insert condicionPago;
        
        Impuesto__c Impuesto = new Impuesto__c();
        Impuesto.codigoImpuesto__c='test imp';
        Impuesto.descripcion__c='test desc';
        Impuesto.Impuesto__c=2;
        Impuesto.Name='test imp';
        Impuesto.porcentaje__c=3;
        insert Impuesto;
        
        Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        acc.condicionPago__c=condicionPago.Id;
        acc.Impuesto__c=Impuesto.Id;
        insert acc;
        
        //update work Order:
        //

        wo.Etapa_de_flujo_de_trabajo__c='Aprobación de presupuesto';
        wo.AccountId=acc.Id;
        //wo.Pricebook2Id=pricebookId;
        
        WorkOrder tmp1 = [Select PriceBook2Id from WorkOrder Where Id = :wo.id];
        WorkOrderLineItem tmp2 = [Select PricebookEntry.pricebook2Id from WorkOrderLineItem Where Id = :woli.id];
        system.debug('zzzz:'+tmp1.Pricebook2Id);
        system.debug('zz:'+tmp2.PricebookEntry.pricebook2Id);
        system.debug('dolar pricebook id:'+pb.Id);
        
        update wo;
        
        ProductConsumed pc = new ProductConsumed();
        pc.WorkorderId = wo.Id;
        pc.PriceBookEntryId = standardPBE.Id;
        pc.QuantityConsumed = 1;
        insert pc;
        
        ApexPages.StandardController controller = new ApexPages.StandardController(wo);
        ApexPages.currentPage().getParameters().put('id', wo.Id);
        WorkorderController cntrl = new WorkorderController(controller);
        cntrl.saveProductsConsumed();
        cntrl.submit();
        Test.stopTest();
    }
}