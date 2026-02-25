@IsTest
public class TestServiciosQuote {
    
    @IsTest
    static void testRequestSoftlandQuotePedido() {
        
        ApiCallSoftland.Method();
        cls_QuoteJSONResponse.Method();
        QuoteSoftlandQueryService.Method();
        QuoteSoftlandPayload.Method();
        AccountSoftlandService.Method();
    	QuoteSoftlandPedidoService.dummyMethod();
        QuoliGridController.dummyMethod();
        ServicioEliminarReservaArticuloQuote.dummyMethod();
        QuoteSoftlandApiLogService.dummyMethod();
        ServicioCrearSCQuote.dummyMethod();
        ServicioReservaApartadoArticulosQuote.dummyMethod();
        ServicioRestActualizarImpuestoCuenta.dummyMethod();
        
	}

}