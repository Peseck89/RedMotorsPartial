/*
  Creado por David Leon IS
  Fecha creacion: 03/02/2020
  Descripcion: clase test para la clase CotizacionTriggerHandler
*/

@isTest 
private class CotizacionTriggerHandler_Test {

	static{
		TestDataFactory.datosGenerales();
		TestDataFactory.crearCuentasAltica(1);
		TestDataFactory.crearOpFAltica(1);
		TestDataFactory.crearCotizacionAltica();
		TestDataFactory.crearDistribucionAltica();
		TestDataFactory.crearCargosAltica();
		TestDataFactory.crearTablaPagosAltica();
	}

	@isTest
	private static void testName() {
		Test.startTest();
			TestDataFactory.cotizacion.Oportunidad_de_Financiamiento__c = TestDataFactory.MapOpF.get(0).Id;
			TestDataFactory.cotizacion.Estado__c = 'Aceptada';

			update TestDataFactory.cotizacion;
		Test.stopTest();
	}
}