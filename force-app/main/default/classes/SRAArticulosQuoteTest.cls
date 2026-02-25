@IsTest
public class SRAArticulosQuoteTest {
    
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
    static void testRealizarReservaApartado() {
        // Recuperar la cotización de prueba
        Quote quote = [SELECT Id, QuoteNumber FROM Quote LIMIT 1];
        
        // IDs de QuoteLineItem para simular la selección de líneas
        List<QuoteLineItem> quoteLineItems = [SELECT Id FROM QuoteLineItem WHERE QuoteId = :quote.Id];
        List<String> notselected = new List<String>();
        List<String> selectedIds = new List<String>();
        for (QuoteLineItem qli : quoteLineItems) {
            selectedIds.add(qli.Id);
        }

        // Definir IDs no disponibles
        List<String> notAvailableIds = new List<String>{ selectedIds[1] };

        // Crear instancia del servicio a probar
        ServicioReservaApartadoArticulosQuote servicio = new ServicioReservaApartadoArticulosQuote(
            quote.QuoteNumber,
            'Uruca - Mostrador',  // destino
            notAvailableIds,
            selectedIds
        );

        // Simulación de respuesta del servicio externo para el entorno de pruebas
        Test.startTest();
        
        WoliGridQueryService service = new WoliGridQueryService(quote.id,true);
        
        service.getQuolis();
        service.getFileUrlsFromQuote();
        
        // Simulación de la respuesta HTTP
        HttpResponse res = new HttpResponse();
        String testResponse = '{'+
                '"compania":"RMBAVARIAN",'+
                '"codigo_respuesta":"00",'+
                '"detalle_respuesta":"Lineas procesadas exitosamente",'+
                '"orden_trabajo":"' + String.escapeSingleQuotes(quote.QuoteNumber) + '",'+
                '"articulos":['+
                    '{'+
                        '"id_linea":"' + String.escapeSingleQuotes(selectedIds[0]) + '",'+
                        '"detalle_respuesta":"ARTICULO RESERVADO EXITOSAMENTE"'+
                    '},'+
                    '{'+
                        '"id_linea":"' + String.escapeSingleQuotes(selectedIds[1]) + '",'+
                        '"detalle_respuesta":"LA LINEA YA CUENTA CON UNA RESERVA ACTIVA."'+
                    '}'+
                ']'+
            '}';
        res.setStatusCode(200);
        res.setBody(testResponse);

        // Simulación de la llamada al servicio en el método realizarReservaApartado
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(res));

        // Llamar al método realizarReservaApartado
        String resultado = servicio.realizarReservaApartado();
        
        QuoliGridController.requestDespacho(quote.QuoteNumber,notselected, selectedIds);
        QuoliGridController.requestApartar(quote.QuoteNumber,notselected, selectedIds);
        

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
            

            return this.response;
        }
    }
}