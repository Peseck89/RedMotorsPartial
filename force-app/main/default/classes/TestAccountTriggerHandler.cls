/*
	Creado por: David Leon Sanche IS
	Fecha: 13/03/2018
	Descripcion: Clase test para la clase AccountTriggerHandler
*/

@isTest 
private class TestAccountTriggerHandler {

	//Metodo para validar si una cuenta ya existe en salesforce, esto por medio de la cedula
	@isTest
	private static void duplicidadCuenta() {
		String idClienteFisico;

		idClienteFisico = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente Físico').getRecordTypeId();
		Account act1 = new Account();
			act1.FirstName = 'Prueba';
			act1.LastName = 'Prueba';
			act1.Tipo_de_Documento__c = 'Cedula';
			act1.Cedula__c = '402080760';
			act1.PersonEmail = 'prueba@prueba.com';
			act1.Monedas_Iden__c = 'Dólares';
			act1.Monto_Ingreso__c = 2500;
			act1.RecordTypeId = idClienteFisico;
		insert act1;

		Account act2 = new Account();
			act2.FirstName = 'Prueba 2';
			act2.LastName = 'Prueba 2';
			act2.Tipo_de_Documento__c = 'Cedula';
			act2.Cedula__c = '402080760';
			act2.PersonEmail = 'prueba2@prueba2.com';
			act2.Monedas_Iden__c = 'Dólares';
			act2.Monto_Ingreso__c = 2500;
			act2.RecordTypeId = idClienteFisico;

		Test.startTest();
			try{
				insert act2;
			}catch(Exception e){
				Boolean msjError = e.getMessage().contains('El cliente con el nombre ' + act2.FirstName + ' ' + act2.LastName + ' ya existe en salesforce. Por favor verificar.') ? true : false;
				System.assertEquals(msjError, true);
			}
		Test.stopTest();
	}
}