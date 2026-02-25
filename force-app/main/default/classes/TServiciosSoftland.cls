@isTest
private class TServiciosSoftland {
    
    @isTest static void test() {
        ServicioQuoliActualizaER servicio1 = new ServicioQuoliActualizaER();
        servicio1.dummyMethod();
        
        facturadaQuote servicio2 = new facturadaQuote();
        facturadaQuote.dummyMethod();
        
        
        ActualizarEstadoQuote servicio3 = new ActualizarEstadoQuote();
        ActualizarEstadoQuote.dummyMethod();

		ServiceActualizarEstadoQuote servicio4 = new ServiceActualizarEstadoQuote();
        ServiceActualizarEstadoQuote.dummyMethod();
        
        ServicioCrearSCQuote servicio5 = new ServicioCrearSCQuote();
        ServicioCrearSCQuote.dummyMethod();

		ServicioQuoliActualizaSC servicio6 = new ServicioQuoliActualizaSC();
        ServicioQuoliActualizaSC.dummyMethod();
        
        
        ServicioConsDispBodegaQuoli.dummyMethod();
        BMW_GetTipoDeCambio.dummyMethod();
        ServicioReservaApartadoArticulosQuote.dummyMethod();
        
    }
    
    
}