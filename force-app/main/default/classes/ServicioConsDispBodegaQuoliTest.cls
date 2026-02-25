@IsTest
public class ServicioConsDispBodegaQuoliTest {

    @TestSetup
    static void setupData() {
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
    static void testConsultarDisponibilidad() {
        Quote quote = [SELECT Id, QuoteNumber FROM Quote LIMIT 1];
        List<QuoteLineItem> quolis = [SELECT Id,Product2Id,Product2.Name,ListPrice,BMW_Bodega__c,CantidadSC__c, Codigo_producto__c FROM QuoteLineItem WHERE QuoteId = :quote.Id];

         // Crear una lista de QuoliGridWrapper para la prueba
        List<WoliGridWrapper> quoliWrappers = new List<WoliGridWrapper>();
        for (QuoteLineItem qli : quolis) {
            
            
            WoliGridWrapper wrapper1 = new WoliGridWrapper(
            qli.Id, // WorkOrderLineItem ID for wrapper1
            qli.Product2Id, // Product ID
            qli.Codigo_producto__c, // Product Code
            qli.Product2.Name, // Product Name
            qli.ListPrice, // Unit Price
            qli.BMW_Bodega__c, // Bodega Name
            qli.CantidadSC__c, // Cantidad Disponible
            'Materiales', // Product Type
            'Alias1', // Alias
            'Mantenimiento', // Tipo de Trabajo
            'test', // PriceBookEntry Id
            'USD', // Currency Code
            'test', // Bodega ID
            'BodegaExtID1', // External Bodega ID
            'test' // ProductXBodega ID
        );
            
			quoliWrappers.add(wrapper1);            
        }

        // Simulación de respuesta del servicio externo para el entorno de pruebas
        Test.startTest();
        
        // Simulación de la respuesta HTTP
        HttpResponse res = new HttpResponse();
        String testResponse = '{'+
                '"Data":['+
                    '{"articulo":"L00078","bodega":"BR01","cantidadDisponible":569.00000000,"reservadoOrden":0.0}'+
                '],'+
                '"Paging":{'+
                    '"PageNo":1,'+
                    '"PageSize":100,'+
                    '"PageCount":1,'+
                    '"TotalRecordCount":39419,'+
                    '"TotalThisViewCount":1'+
                '}'+
            '}';
        res.setStatusCode(200);
        res.setBody(testResponse);

        // Simulación de la llamada al servicio en el método consultarDisponibilidad
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(res));

        // Llamar al método consultarDisponibilidad
        List<WoliGridWrapper> result = ServicioConsDispBodegaQuoli.consultarDisponibilidad(quoliWrappers, quote.QuoteNumber);
        
        
        
        QuoliGridController.consultarDisponibilidad(JSON.serialize(quoliWrappers),Quote.Id, Quote.QuoteNumber);
        
        

        Test.stopTest();

        
    }

    // Clase auxiliar para simular respuestas HTTP en pruebas
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        private HttpResponse response;
        
        public MockHttpResponseGenerator(HttpResponse res) {
            this.response = res;
        }
        
        public HttpResponse respond(HttpRequest req) {
            // Validar que la solicitud sea correcta
            Map<String, Object> requestBody = (Map<String, Object>) JSON.deserializeUntyped(req.getBody());
            System.assertEquals('RMBAVARIAN', requestBody.get('compania'), 'La compañía debería ser RMBAVARIAN');
            System.assertEquals('OP0000039191', requestBody.get('oportunidad_salesforce'), 'El ID de la oportunidad debería ser OP0000039191');
            System.assertEquals('QT-00012447', requestBody.get('quote_salesforce'), 'El número de la cotización debería ser QT-00012447');
            
            List<Object> articulos = (List<Object>) requestBody.get('articulos');
            System.assertEquals(2, articulos.size(), 'Debería haber 2 artículos en la solicitud');
            
            Map<String, Object> articulo1 = (Map<String, Object>) articulos[0];
            System.assertEquals('L00078', articulo1.get('articulo'), 'El código del primer artículo debería ser L00078');
            System.assertEquals('BR01', articulo1.get('bodega'), 'La bodega del primer artículo debería ser BR01');
            System.assertEquals('T', articulo1.get('tipo'), 'El tipo del primer artículo debería ser T');
            
            Map<String, Object> articulo2 = (Map<String, Object>) articulos[1];
            System.assertEquals('L00076', articulo2.get('articulo'), 'El código del segundo artículo debería ser L00076');
            System.assertEquals('BR01', articulo2.get('bodega'), 'La bodega del segundo artículo debería ser BR01');
            System.assertEquals('T', articulo2.get('tipo'), 'El tipo del segundo artículo debería ser T');

            return this.response;
        }
    }
}