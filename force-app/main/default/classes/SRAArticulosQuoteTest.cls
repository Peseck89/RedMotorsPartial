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
            opp.BMW_Compania__c = 'Bavarian';
            opp.Empresa_Operadora__c = null;
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
        System.assertEquals(false, resultado == null);
        
        QuoliGridController.requestDespacho(quote.QuoteNumber,notselected, selectedIds);
        QuoliGridController.requestApartar(quote.QuoteNumber,notselected, selectedIds);
        

        Test.stopTest();

        
    }

    @IsTest
    static void lookupPekingDoesNotFallbackToOtobai() {
        Empresa__c peking = createEmpresa('RMPEKING');
        Quote quote = [SELECT Id, QuoteNumber, OpportunityId FROM Quote LIMIT 1];
        update new Opportunity(
            Id = quote.OpportunityId,
            BMW_Compania__c = 'Bavarian',
            Empresa_Operadora__c = peking.Id
        );

        List<String> selectedIds = getQuoteLineItemIds(quote.Id);
        List<String> notAvailableIds = new List<String>();

        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            new ServicioReservaApartadoArticulosQuote(
                quote.QuoteNumber,
                'Uruca - Mostrador',
                notAvailableIds,
                selectedIds
            ).realizarReservaApartado();
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown, 'RMPEKING debe detenerse con error controlado y no caer a Otobai.');
        System.assertEquals(0, [SELECT COUNT() FROM QuoteLineItem WHERE QuoteId = :quote.Id AND Estado_reserva__c = 'Reservado'], 'No debe reservar líneas cuando la empresa no tiene contrato Softland confirmado.');
    }

    @IsTest
    static void emptyCompanyDoesNotFallbackToOtobai() {
        Quote quote = [SELECT Id, QuoteNumber, OpportunityId FROM Quote LIMIT 1];
        update new Opportunity(
            Id = quote.OpportunityId,
            BMW_Compania__c = null,
            Empresa_Operadora__c = null
        );

        List<String> selectedIds = getQuoteLineItemIds(quote.Id);
        List<String> notAvailableIds = new List<String>();

        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            new ServicioReservaApartadoArticulosQuote(
                quote.QuoteNumber,
                'Uruca - Mostrador',
                notAvailableIds,
                selectedIds
            ).realizarReservaApartado();
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown, 'Una empresa vacía debe detenerse con error controlado y no caer a Otobai.');
        System.assertEquals(0, [SELECT COUNT() FROM QuoteLineItem WHERE QuoteId = :quote.Id AND Estado_reserva__c = 'Reservado'], 'No debe reservar líneas cuando la empresa está vacía.');
    }

    @IsTest
    static void unsupportedLookupCompanyDoesNotFallbackToOtobai() {
        Empresa__c unsupported = createEmpresa('RMUNKNOWN');
        Quote quote = [SELECT Id, QuoteNumber, OpportunityId FROM Quote LIMIT 1];
        update new Opportunity(
            Id = quote.OpportunityId,
            BMW_Compania__c = 'Bavarian',
            Empresa_Operadora__c = unsupported.Id
        );

        List<String> selectedIds = getQuoteLineItemIds(quote.Id);
        List<String> notAvailableIds = new List<String>();

        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            new ServicioReservaApartadoArticulosQuote(
                quote.QuoteNumber,
                'Uruca - Mostrador',
                notAvailableIds,
                selectedIds
            ).realizarReservaApartado();
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown, 'Una empresa no soportada debe detenerse con error controlado y no caer a Otobai.');
        System.assertEquals(0, [SELECT COUNT() FROM QuoteLineItem WHERE QuoteId = :quote.Id AND Estado_reserva__c = 'Reservado'], 'No debe reservar líneas cuando la empresa no está soportada.');
    }

    private static Empresa__c createEmpresa(String codigo) {
        Empresa__c empresa = new Empresa__c(
            Name = 'Empresa ' + codigo,
            Codigo__c = codigo,
            Codigo_ERP__c = codigo,
            Nombre_Legal__c = 'Empresa ' + codigo,
            Activa__c = true
        );
        insert empresa;
        return empresa;
    }

    private static List<String> getQuoteLineItemIds(Id quoteId) {
        List<String> selectedIds = new List<String>();
        for (QuoteLineItem qli : [
            SELECT Id
            FROM QuoteLineItem
            WHERE QuoteId = :quoteId
            ORDER BY CreatedDate ASC
        ]) {
            selectedIds.add(qli.Id);
        }
        return selectedIds;
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
