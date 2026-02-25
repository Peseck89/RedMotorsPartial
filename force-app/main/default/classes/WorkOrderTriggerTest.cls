@isTest(SeeAllData=false)
public class WorkOrderTriggerTest {
    @isTest
    public static void testWorkOrderTrigger(){
        
        ActividadComercial__c act = new ActividadComercial__c();
        act.Name = 'VENTA DE REPUESTOS NUEVOS PARA AUTOMOVIL';
        insert act;
        //Se inserta antes para evitar error
        condicionPago__c condicionPago = new condicionPago__c();
        condicionPago.condicionPago__c='0';
        condicionPago.Descripcion__c='test desc';
        condicionPago.Name='CONTADO';
        insert condicionPago;
           //Insert product        
        Product2 prod= new Product2();
        prod.IsActive=true;
        prod.Name='Test product';
        prod.ProductCode='00012';
        prod.Codigo_de_Producto__c='0012';
        insert prod;
        
        //Pricebook2 pb = new Pricebook2();
        //pb.Name='Dolar';
        //pb.IsActive=true;
        //pb.IsStandard=true;
        //insert pb;
        
        //Test.startTest();

        Id pricebookId = Test.getStandardPricebookId();
        
        CentroCosto__c cc = new CentroCosto__c();
        insert cc;
        
        WorkOrder wo = new WorkOrder();
        wo.subject ='title';
        wo.Pricebook2Id=pricebookId;
        wo.tipoDeGasto__c='Cliente';
        WO.CurrencyIsoCode = 'CRC';
        //wo.Etapa_de_flujo_de_trabajo__c='Aprobación de presupuesto';
        
        insert wo;
        WorkOrder tmp = [Select PriceBook2Id from WorkOrder Where Id = :wo.id];
        //system.assertEquals(pricebookId,tmp.PriceBook2Id,'The workorder price book was modified after it was inserted');

        
     

        // Insert PricebookEntry

        //Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        PricebookEntry standardPBE = [select id from PricebookEntry limit 1];//new PricebookEntry(Pricebook2Id =pricebookId, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        //insert standardPBE;
        
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
        
        
        Impuesto__c Impuesto = new Impuesto__c();
        Impuesto.codigoImpuesto__c='0108';
        Impuesto.descripcion__c='test desc';
        Impuesto.Impuesto__c=2;
        Impuesto.Name='test imp';
        Impuesto.porcentaje__c=3;
        insert Impuesto;
        
        
        
        categoriaCliente__c cet = new categoriaCliente__c();
        cet.categoriaCliente__c = 'COM';
        insert cet;
        
        Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        //acc.condicionPago__c=condicionPago.Id;
        //acc.Impuesto__c=Impuesto.Id;
        
        insert acc;
        
        //update work Order:
        //

        wo.Etapa_de_flujo_de_trabajo__c='Enviar a facturar';
        wo.AccountId=acc.Id;
        wo.Realizar_encuesta__c = 'Si';
        wo.SyncSoftlandFlag__c = true;
        wo.tipoDeGasto__c = 'BCI';
        //wo.Pricebook2Id=pricebookId;
        
        WorkOrder tmp1 = [Select PriceBook2Id from WorkOrder Where Id = :wo.id];
        WorkOrderLineItem tmp2 = [Select PricebookEntry.pricebook2Id from WorkOrderLineItem Where Id = :woli.id];
        system.debug('zzzz:'+tmp1.Pricebook2Id);
        system.debug('zz:'+tmp2.PricebookEntry.pricebook2Id);
        //system.debug('dolar pricebook id:'+pb.Id);
        
        
        update wo;
        wo.tipoDeGasto__c = 'Aseguradora';
        //wo.BMW_Aseguradora__c =
        //update wo;
        WorkOrder wo2 = new WorkOrder();
        wo2.subject ='title';
        wo2.Pricebook2Id=pricebookId;
        wo2.tipoDeGasto__c='Garantia';
        WO2.CurrencyIsoCode = 'CRC';

		insert wo2;
        WorkOrder tmpWO2 = [Select PriceBook2Id from WorkOrder Where Id = :wo2.id];
        
        PricebookEntry standardPBEWO2 = [select id from PricebookEntry limit 1];
        
        PricebookEntry standardPriceWO2 = new PricebookEntry();
        standardPriceWO2.Pricebook2Id =  tmpWO2.Pricebook2Id;
        standardPriceWO2.Product2Id = prod.Id;
        standardPriceWO2.UnitPrice = 1;
        standardPriceWO2.IsActive = true;
        standardPriceWO2.UseStandardPrice = false;
        
        WorkOrderLineItem woliWO2 = new WorkOrderLineItem();
        woliWO2.workOrderId = wo2.Id;
        woliWO2.description = 'abcd';
        woliWO2.Quantity=2;
        woliWO2.PricebookEntryId=standardPBEWO2.Id;
        woliWO2.centroCosto__c = cc.Id;
        insert woliWO2;
        
        condicionPago__c condicionPagoWO2 = new condicionPago__c();
        condicionPagoWO2.condicionPago__c='0';
        condicionPagoWO2.Descripcion__c='test desc';
        condicionPagoWO2.Name='CONTADO';
        insert condicionPagoWO2;
        
        Impuesto__c ImpuestoWO2 = new Impuesto__c();
        ImpuestoWO2.codigoImpuesto__c='0108';
        ImpuestoWO2.descripcion__c='test desc';
        ImpuestoWO2.Impuesto__c=2;
        ImpuestoWO2.Name='test imp';
        ImpuestoWO2.porcentaje__c=3;
        insert ImpuestoWO2;
        
        WorkOrder wo3 = new WorkOrder();
        wo3.subject ='title';
        wo3.Pricebook2Id=pricebookId;
        wo3.tipoDeGasto__c='BCI';
        WO3.CurrencyIsoCode = 'CRC';
        
        insert wo3;
        Test.startTest();
        WorkOrder tmpWO3 = [Select PriceBook2Id from WorkOrder Where Id = :wo3.id];
        
        PricebookEntry standardPBEWO3 = [select id from PricebookEntry limit 1];
        
        PricebookEntry standardPriceWO3 = new PricebookEntry();
        standardPriceWO3.Pricebook2Id =  tmpWO3.Pricebook2Id;
        standardPriceWO3.Product2Id = prod.Id;
        standardPriceWO3.UnitPrice = 1;
        standardPriceWO3.IsActive = true;
        standardPriceWO3.UseStandardPrice = false;
        
        WorkOrderLineItem woliWO3 = new WorkOrderLineItem();
        woliWO3.workOrderId = wo3.Id;
        woliWO3.description = 'abcd';
        woliWO3.Quantity=2;
        woliWO3.PricebookEntryId=standardPBEWO2.Id;
        woliWO3.centroCosto__c = cc.Id;
        insert woliWO3;
        
        condicionPago__c condicionPagoWO3 = new condicionPago__c();
        condicionPagoWO3.condicionPago__c='0';
        condicionPagoWO3.Descripcion__c='test desc';
        condicionPagoWO3.Name='CONTADO';
        insert condicionPagoWO3;
        
        Impuesto__c ImpuestoWO3 = new Impuesto__c();
        ImpuestoWO3.codigoImpuesto__c='0108';
        ImpuestoWO3.descripcion__c='test desc';
        ImpuestoWO3.Impuesto__c=2;
        ImpuestoWO3.Name='test imp';
        ImpuestoWO3.porcentaje__c=3;
        insert ImpuestoWO3;
        
        Delete wo2;
        Delete wo3;
        
        

        Test.stopTest();
    }
}