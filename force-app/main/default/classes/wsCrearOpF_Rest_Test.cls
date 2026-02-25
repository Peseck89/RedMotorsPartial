/*
    Creado por David Leon IS
    Fecha 04/03/2019
    Descripcion: Clase test para el funcionamiento del web service wsCrearOpF_Rest
*/

@isTest
private with sharing class wsCrearOpF_Rest_Test
{
	static{
		TestDataFactory.datosGenerales();
		TestDataFactory.crearCuentasAltica(1);
	}

	//Test cuando el request viene sin datos
	@isTest
	private static void test1()
	{
		String jsonMsg = '{}';

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/Altica';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf(jsonMsg);

		RestContext.response = res;

		Test.startTest();
			wsCrearOpF_Rest.responseOpF results = wsCrearOpF_Rest.crearOpF();
			System.debug(' ** resultado ** ' + results);
		Test.stopTest();
	}

	//Test cuando el cliente no existe en salesforce y es un cliente fisico
	@isTest
	private static void test2(){
		String jsonMsg;

		jsonMsg = '{' +
				'"cedula":"000000000",' +
				'"nombre":"Prueba",' +
				'"primerApellido":"Prueba",' +
				'"segundoApellido":"Prueba",' +
				'"email":"prueba@prueba.com",' +
				'"telefono":"+50622626262",' +
				'"valorVehiculo":"10000",' +
				'"marca":"BMW",' +
				'"modelo":"X6",' +
				'"anno":"0000"' +
				'}';

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/Altica';
		req.httpMethod = 'POST';
		req.requestBody  = Blob.valueOf(jsonMsg);

		RestContext.request = req;
		RestContext.response = res;

		Test.startTest();
			wsCrearOpF_Rest.responseOpF results = wsCrearOpF_Rest.crearOpF();
			System.debug(' ** resultado ** ' + results);
		Test.stopTest();
	}

	//Test cuando el cliente si existe en salesforce y es un cliente fisico
	@isTest
	private static void test3(){
		String jsonMsg;
		List<Account> listAct = new List<Account>();

		listAct = TestDataFactory.MapCuentasAltica.values();
		jsonMsg = '{' +
				'"cedula":"222222222",' +
				'"nombre":"Prueba",' +
				'"primerApellido":"Prueba",' +
				'"segundoApellido":"Prueba",' +
				'"email":"prueba@prueba.com",' +
				'"telefono":"+50683838383",' +
				'"valorVehiculo":"10000",' +
				'"marca":"BMW",' +
				'"modelo":"X6",' +
				'"anno":"0000"' +
				'}';

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/Altica';
		req.httpMethod = 'POST';
		req.requestBody  = Blob.valueOf(jsonMsg);

		RestContext.request = req;
		RestContext.response = res;

		Test.startTest();
			wsCrearOpF_Rest.responseOpF results = wsCrearOpF_Rest.crearOpF();
			System.debug(' ** resultado ** ' + results);
		Test.stopTest();
	}

	//Test cuando el cliente no existe en salesforce y es un cliente juridico
	@isTest
	private static void test4(){
		String jsonMsg;

		jsonMsg = '{' +
				'"cedula":"0000000000",' +
				'"nombre":"Prueba",' +
				'"primerApellido":"Prueba",' +
				'"segundoApellido":"Prueba",' +
				'"email":"prueba@prueba.com",' +
				'"telefono":"+50623232323",' +
				'"valorVehiculo":"10000",' +
				'"marca":"BMW",' +
				'"modelo":"X6",' +
				'"anno":"0000"' +
				'}';

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/Altica';
		req.httpMethod = 'POST';
		req.requestBody  = Blob.valueOf(jsonMsg);

		RestContext.request = req;
		RestContext.response = res;

		Test.startTest();
			wsCrearOpF_Rest.responseOpF results = wsCrearOpF_Rest.crearOpF();
			System.debug(' ** resultado ** ' + results);
		Test.stopTest();
	}
}