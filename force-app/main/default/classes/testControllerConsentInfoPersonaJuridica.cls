/*
	Creado por: David Leon Sanchez IS
	fecha: 07/03/2018
	Descripcion: clase test para el controlador controllerConsentInfoPersonaJuridica
*/

@isTest 
private class testControllerConsentInfoPersonaJuridica {

	@isTest
	private static void testName() {
		String idTipoRegistro;

		idTipoRegistro = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente Jurídico').getRecordTypeId();
		Account act = new Account();
			act.RecordTypeId = idTipoRegistro;
			act.Name = 'Prueba';
			act.Tipo_de_Documento__c = 'Cedula';
			act.Cedula__c = '402080760';
			act.CorreoElectronicoEmpresarial__c = 'david.leon@i-solutionsinc.com';
			act.Vendedorasignado__c = UserInfo.getUserId();
		insert act;

		Test.startTest();
			controllerConsentInfoPersonaJuridica controller = new controllerConsentInfoPersonaJuridica();
			//controller.idCuenta = act.Id;
		Test.stopTest();
	}
}