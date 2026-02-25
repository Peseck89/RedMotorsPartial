/*
    Creado por David Leon IS
    Fecha 01/03/2019
    Descripcion: Clase test para el funcionamiento del web service wsCrearGestion_Rest
*/

@isTest
public with sharing class wsCrearGestion_Rest_Test
{
	static{
		TestDataFactory.datosGenerales();
		TestDataFactory.crearCuentasAltica(1);
		TestDataFactory.crearOpFAltica(1);
	}
	//Test cuando el request viene sin datos
	@isTest
	private static void test1()
	{
		String jsonMsg = '{}';

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/AlticaGestiones';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueOf(jsonMsg);

		RestContext.response = res;

		Test.startTest();
			wsCrearGestion_Rest.responseGestion results = wsCrearGestion_Rest.crearGestion();
			System.debug(' ** resultado ** ' + results); 
		Test.stopTest();
	}

	//Test cuando el cliente no existe en salesforce y es un cliente fisico
	@isTest
	private static void test2(){
		String jsonMsg;

		jsonMsg = '{' +
				'"cedula_cliente":"000000000",' +
				'"numero_operacion":"Prueba",' +
				'"nuevo_email":"Prueba",' +
				'"fecha_nacimiento":"Prueba",' +
				'"telefono":"prueba@prueba.com",' +
				'"email":"00000000",' +
				'"canton":"10000",' +
				'"provincia":"BMW",' +
				'"tipo_gestion":"X6"' +
				'}';

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/AlticaGestiones';
		req.httpMethod = 'POST';
		req.requestBody  = Blob.valueOf(jsonMsg);

		RestContext.request = req;
		RestContext.response = res;

		Test.startTest();
			wsCrearGestion_Rest.responseGestion results = wsCrearGestion_Rest.crearGestion();
			System.debug(' ** resultado ** ' + results);
		Test.stopTest();
	}

	//Test cuando el cliente existe en salesforce y tiene una oportunidad de financiamiento
	//Gestion Cambio Email Facturacion
	@isTest
	private static void test3(){
		String jsonMsg;

		jsonMsg = '{' +
				'"cedula_cliente":"222222222",' +
				'"numero_operacion":"234",' +
				'"nuevo_email":"prueba@prueba.com",' +
				'"fecha_nacimiento":"1990-12-15",' +
				'"telefono":"88888888",' +
				'"email":"prueba@prueba1.com",' +
				'"canton":"ABANGARES",' +
				'"provincia":"GUANACASTE",' +
				'"tipo_gestion":"cambio email facturacion"' +
				'}';

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/AlticaGestiones';
		req.httpMethod = 'POST';
		req.requestBody  = Blob.valueOf(jsonMsg);

		RestContext.request = req;
		RestContext.response = res;

		Test.startTest();
			wsCrearGestion_Rest.responseGestion results = wsCrearGestion_Rest.crearGestion();
			System.debug(' ** resultado ** ' + results);
		Test.stopTest();
	}

	//Test cuando el cliente existe en salesforce y tiene una oportunidad de financiamiento
	//Gestion Saldos Proyectados
	@isTest
	private static void test4(){
		String jsonMsg;

		jsonMsg = '{' +
				'"cedula_cliente":"222222222",' +
				'"numero_operacion":"234",' +
				'"nombre_completo":"prueba@prueba.com",' +
				'"fecha_proyeccion":"2019-01-01",' +
				'"comentarios_cliente":"prueba",' +
				'"fecha_nacimiento":"1990-12-15",' +
				'"telefono":"88888888",' +
				'"email":"prueba@prueba1.com",' +
				'"canton":"ABANGARES",' +
				'"provincia":"GUANACASTE",' +
				'"tipo_gestion":"saldos proyectados"' +
				'}';

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/AlticaGestiones';
		req.httpMethod = 'POST';
		req.requestBody  = Blob.valueOf(jsonMsg);

		RestContext.request = req;
		RestContext.response = res;

		Test.startTest();
			wsCrearGestion_Rest.responseGestion results = wsCrearGestion_Rest.crearGestion();
			System.debug(' ** resultado ** ' + results);
		Test.stopTest();
	}

	//Test cuando el cliente existe en salesforce y tiene una oportunidad de financiamiento
	//Gestion Tabla Pagos
	@isTest
	private static void test5(){
		String jsonMsg;

		jsonMsg = '{' +
				'"cedula_cliente":"222222222",' +
				'"numero_operacion":"234",' +
				'"nombre_completo":"prueba@prueba.com",' +
				'"comentarios_cliente":"prueba",' +
				'"fecha_nacimiento":"1990-12-15",' +
				'"telefono":"88888888",' +
				'"email":"prueba@prueba1.com",' +
				'"canton":"ABANGARES",' +
				'"provincia":"GUANACASTE",' +
				'"tipo_gestion":"tabla pagos"' +
				'}';

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/AlticaGestiones';
		req.httpMethod = 'POST';
		req.requestBody  = Blob.valueOf(jsonMsg);

		RestContext.request = req;
		RestContext.response = res;

		Test.startTest();
			wsCrearGestion_Rest.responseGestion results = wsCrearGestion_Rest.crearGestion();
			System.debug(' ** resultado ** ' + results);
		Test.stopTest();
	}

	//Test cuando el cliente existe en salesforce y tiene una oportunidad de financiamiento
	//Gestion Cuenta Bancaria
	@isTest
	private static void test6(){
		String jsonMsg;

		jsonMsg = '{' +
				'"cedula_cliente":"222222222",' +
				'"numero_operacion":"234",' +
				'"nombre_completo":"prueba@prueba.com",' +
				'"nuevo_numero_cuenta":"0000000",' +
				'"moneda":"colones",' +
				'"fecha_nacimiento":"1990-12-15",' +
				'"telefono":"88888888",' +
				'"email":"prueba@prueba1.com",' +
				'"canton":"ABANGARES",' +
				'"provincia":"GUANACASTE",' +
				'"tipo_gestion":"cambio cuenta bancaria"' +
				'}';

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/AlticaGestiones';
		req.httpMethod = 'POST';
		req.requestBody  = Blob.valueOf(jsonMsg);

		RestContext.request = req;
		RestContext.response = res;

		Test.startTest();
			wsCrearGestion_Rest.responseGestion results = wsCrearGestion_Rest.crearGestion();
			System.debug(' ** resultado ** ' + results);
		Test.stopTest();
	}
}