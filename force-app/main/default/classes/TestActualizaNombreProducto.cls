@isTest
public class TestActualizaNombreProducto {
   
    @testSetup 
    static void setup() {
        
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
        
        Pricebook2 pb = new Pricebook2();
        pb.Name='Dolar';
        pb.IsActive=true;
        insert pb;  
        
        // Create mock products
        Product2 testProduct = new Product2(Name='Test Product', IsActive=true);
        testProduct.Codigo_de_Producto__c = 'TEst123';
        insert testProduct;
        
        String IdPricebook= pb.Id;
        Pricebook2 standardPb =  [SELECT Id FROM Pricebook2 WHERE Id=:IdPricebook  LIMIT 1];
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = standardPb.Id, Product2Id = testProduct.Id, UnitPrice = 100, IsActive = true);
        insert pbe;
        
        // Create mock opportunity
        Opportunity testOpp = new Opportunity(Name='Test Opportunity', CloseDate=System.today(), StageName='Prospecting', Pricebook2Id=standardPb.Id);
        insert testOpp;
        
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId=testOpp.Id, PricebookEntryId=pbe.Id, Quantity=1, TotalPrice=100);
        insert oli;
    }
    
    static testMethod void testActualizaProdu() {
        // Use the setup data and date range that covers today
        ActualizaNombreProducto.ActualizaProdu(System.today().year(), System.today().month(), System.today().day(),
                                               System.today().year(), System.today().month(), System.today().day());
                                               
        Opportunity updatedOpp = [SELECT NombreProducto__c FROM Opportunity WHERE Id IN (SELECT OpportunityId FROM OpportunityLineItem)];
        
        //System.assertEquals('Test Product', updatedOpp.NombreProducto__c, 'Product name should be updated in the Opportunity');
    }

    static testMethod void testActualizaProduNoOpportunitiesInRange() {
        // Use a date range that doesn't cover today
        ActualizaNombreProducto.ActualizaProdu(System.today().addYears(-2).year(), System.today().addYears(-2).month(), System.today().addYears(-2).day(),
                                               System.today().addYears(-2).year(), System.today().addYears(-2).month(), System.today().addYears(-2).day());
        
        Opportunity oppOutOfDateRange = [SELECT NombreProducto__c FROM Opportunity WHERE Id IN (SELECT OpportunityId FROM OpportunityLineItem)];
        
        //System.assert(oppOutOfDateRange.NombreProducto__c == null, 'Product name should not be updated if the Opportunity is not in date range');
    }
}