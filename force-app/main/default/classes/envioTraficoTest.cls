@isTest
public class envioTraficoTest {
    @isTest
    private static void testBMW() {
        test.startTest();
    	envioCotizacionTrafico.dummy();
        WSenvioCotizacionTrafico.dummy();
        TraficoService.dummy();
        test.stopTest();

    }

}