@isTest
public class ServicioNotaCreditoQuoteTest {
    @isTest static void testProcessRequest() {
        // Set up test data
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
        
        
        // Recuperar la cotización de prueba
        Quote quote = [SELECT Id, QuoteNumber,Quote_Number__c FROM Quote LIMIT 1];
        
        // IDs de QuoteLineItem para simular la selección de líneas
        List<QuoteLineItem> quoteLineItems = [SELECT Id FROM QuoteLineItem WHERE QuoteId = :quote.Id];
       
        // Prepare the request body
        ServicioNotaCreditoQuote.RequestBody requestBody = new ServicioNotaCreditoQuote.RequestBody();
        
        
        
        
        requestBody.quote_salesforce = quote.Quote_Number__c;
        requestBody.articulos = new List<ServicioNotaCreditoQuote.QUOLI>();

        ServicioNotaCreditoQuote.QUOLI articulo1 = new ServicioNotaCreditoQuote.QUOLI();
        articulo1.id_linea = quoteLineItems[0].Id;
        articulo1.cantidad = '1';

        ServicioNotaCreditoQuote.QUOLI articulo2 = new ServicioNotaCreditoQuote.QUOLI();
        articulo2.id_linea = quoteLineItems[1].Id;
        articulo2.cantidad = '0';
        
        ServicioNotaCreditoQuote.QUOLI articulo3 = new ServicioNotaCreditoQuote.QUOLI();
        articulo3.id_linea = quoteLineItems[3].Id;


        requestBody.articulos.add(articulo1);
        requestBody.articulos.add(articulo2);
        requestBody.articulos.add(articulo3);

        // Mock HTTP request and response
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        ServicioNotaCreditoQuote.doPost();
        Test.stopTest();

    }

}