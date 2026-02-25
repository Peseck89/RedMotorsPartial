/*
	Creado por: David Leon Sanchez IS
	fecha: 07/03/2018
	Descripcion: clase test para el controlador controllerConsentInfoPersonaFisica
*/

@isTest 
private class testControllerConsentInfoPersonaFisica {

	@isTest
	private static void testName() {
		String idTipoRegistro;

		idTipoRegistro = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente Físico').getRecordTypeId();
		Account act = new Account();
			act.FirstName = 'Test';
			act.LastName = 'Test';
			act.Tipo_de_Documento__c = 'Cedula';
			act.Cedula__c = '402080760';
			act.PersonEmail = 'david.leon@i-solutionsinc.com';
			act.Monedas_Iden__c = 'Colones';
			act.Monto_Ingreso__c = 2500;
			act.Direccion_Residencial__c = 'Prueba Prueba Prueba';
			act.Vendedorasignado__c = UserInfo.getUserId();
			act.RecordTypeId = idTipoRegistro;
		insert act;

		Test.startTest();
			controllerConsentInfoPersonaFisica controller = new controllerConsentInfoPersonaFisica();
			//controller.idCuenta = act.Id;
		Test.stopTest();
	}
}