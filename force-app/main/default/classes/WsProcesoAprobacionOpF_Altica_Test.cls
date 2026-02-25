@isTest 
private class WsProcesoAprobacionOpF_Altica_Test {

	static{
		TestDataFactory.datosGenerales();
		TestDataFactory.crearCuentasAltica(1);
		TestDataFactory.crearOpFAltica(1);
	}

	@isTest
	private static void test1() {
		Test.startTest();
		String resultado = WsProcesoAprobacionOpF_Altica.aprobacionOpF(TestDataFactory.MapOpF.get(0).Id);
		Test.stopTest();
	}

	@isTest
	private static void test2() {
		TestDataFactory.MapOpF.get(0).Valor_Altica__c = 100000;
		TestDataFactory.MapOpF.get(0).Prima_Altica__c = 20000;
		TestDataFactory.MapOpF.get(0).GPS__c = 100;
		TestDataFactory.MapOpF.get(0).Comision__c = 3;

		update TestDataFactory.MapOpF.values();

		Test.startTest();
		String resultado = WsProcesoAprobacionOpF_Altica.aprobacionOpF(TestDataFactory.MapOpF.get(0).Id);
		Test.stopTest();
	}
}