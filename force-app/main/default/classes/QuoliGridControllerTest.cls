@IsTest
public with sharing class QuoliGridControllerTest {
    @TestSetup
    static void setupData(){
        TestDataFactory.createQuoteWithItems();
        OperatingHours oh = new OperatingHours(Name = 'Normal');
        insert oh;      
        ServiceTerritory st = new ServiceTerritory(Name = 'Uruca - Mecánica General', IsActive = true, OperatingHoursId = oh.id);
        insert st;
        Bodega__c bodega = new Bodega__c(bodega__c = 'BR01', ID_EXTERNO_BODEGA__c = 'BR01', Name = 'BR01');
        insert bodega;   
        BodegaxTerritorio__c bxt = new BodegaxTerritorio__c(ServiceTerritory__c = st.Id, isPrincipal__c = true, Bodega__c = bodega.Id);
        insert bxt;
        
        List<ProductoXBodega__c> productoBodegaList = new List<ProductoXBodega__c>();
        for(Product2 p : [SELECT Id FROM Product2]) {
            productoBodegaList.add(new ProductoXBodega__c(Producto__c = p.Id, Bodega__c = bodega.Id));
        }
        
        insert productoBodegaList;
        
        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        for(Opportunity opp : oppList) {
            opp.BMW_TallerDeServicio__c = st.id;
        }
        
        update oppList;
        
        
        
        
    }
    @IsTest
    public static void test_setSyncedQuoteIdOnOpportunity(){
        List<Quote> quoteList = [SELECT Name,QuoteNumber,OpportunityId, Opportunity.BMW_TallerDeServicio__c FROM Quote LIMIT 1];
        system.debug('PRODUCTOS');
        System.debug([SELECT Id, Codigo_de_Producto__c , Name, costoLocal__c, tipoProducto__c, (SELECT Id, Bodega__r.Name, Bodega__c, Disponible__c, Bodega__r.bodega__c from Productos_por_Bodega__r Order by CreatedDate) FROM Product2 WHERE (Codigo_de_Producto__c LIKE '%Rack%')]);
        system.debug('PRODUCTOSXBODEGA');
        system.debug([SELECT Bodega__c, isPrincipal__c from BodegaxTerritorio__c]);
        system.debug('BODEGAS');
        system.debug([SELECT Name,QuoteNumber,OpportunityId, Opportunity.BMW_TallerDeServicio__c FROM Quote LIMIT 1]);
        
        Test.startTest();
        QuoliGridController.getQuolis('[]', quoteList[0].Id);
        QuoliGridController.searchProducts('Rack', quoteList[0].Id);
        QuoliGridController.saveQuantities(JSON.serialize(QuoliGridController.getQuolis('[]', quoteList[0].Id)), quoteList[0].Id);
        QuoliGridController.saveQuolis(JSON.serialize(QuoliGridController.getQuolis('[]', quoteList[0].Id)), quoteList[0].Id);
        QuoliGridController.getDepartamentos();
        List <QuoteLineItem> quolItemsIds=[Select id from QuoteLineItem ];
        List <String> ids= new List <String>();
        for(QuoteLineItem wids:quolItemsIds){
            ids.add(wids.Id);
        }
        QuoliGridController.deleteQuolis(ids);
        QuoliGridController.dummyMethod();        
        Test.stopTest();
    }
}