/*
	creado por : David Leon Sanchez IS
	fecha: 07/03/2018
	descripcion: clase test para el controlador controllerCrearOF
*/

@isTest 
private class testControllerCrearOF {

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
			//act.Monedas_Iden__c = 'Colones';
			act.Monto_Ingreso__c = 2500;
			act.Direccion_Residencial__c = 'Prueba Prueba Prueba';
			act.Vendedorasignado__c = UserInfo.getUserId();
			act.RecordTypeId = idTipoRegistro;
		insert act;

		Product2 prod = new Product2();
		prod.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Producto Altica').getRecordTypeId();
		prod.Name = 'Test';
		prod.Codigo_de_Producto__c = 'Test';
		prod.Modelo_Altica__c = 'Test';
		insert prod;

		Oportunidad_de_Financiamiento__c opF = new Oportunidad_de_Financiamiento__c();
		ApexPages.StandardController std = new ApexPages.StandardController(opF);
		controllerCrearOF con = new controllerCrearOF(std);

		con.opF.Vendedor_Externo__c = 'Test';
        con.opF.Vendedor_Altica__c = '0054U000009i0CoQAI';
		con.opF.Nombre_Cliente_Altica__c = act.Id;
		con.Marca = prod.Name;

		Test.startTest();
			con.getListMarcas();
			con.actualizarModelos();
			con.buscarCliente();
			con.guardar();
        	con.buscarSucursalVendedor();
            con.showRecordNew('0054U000009i0CoQAI');
        
		Test.stopTest();
	}
}