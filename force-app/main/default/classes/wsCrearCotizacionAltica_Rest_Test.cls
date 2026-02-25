/*
  Creado por David Leon IS
  Fecha creacion: 03/02/2020
  Descripcion: clase test para el web service wsCrearCotizacionAltica_Rest
*/

@isTest 
private class wsCrearCotizacionAltica_Rest_Test {

	@isTest
	private static void test1(){
		String JsonMsg = '{}';

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/AlticaCotizaciones/';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueof(JsonMsg);

		//RestContext.request = req;
		RestContext.response = res;

		Test.startTest();
		wsCrearCotizacionAltica_Rest.responseCotizacion results = wsCrearCotizacionAltica_Rest.crearCotizacion();
		Test.stopTest();
	}

	@isTest
	private static void test2(){
		String jsonMsg;

		jsonMsg = '{' +
						'"assetYear": 2020,' +
						'"clientName": "Roberto",' +
						'"clientLastName": "Hernandez Montoya",' +
						'"clientEmail": "roberto.hern83@gmail.com",' +
						'"clientPhoneNumber": "87307606",' +
						'"clientEmployment": "Independiente",' +
						'"clientEmploymentName": "Independiente",' +
						'"company": "6",' +
						'"companyName": "Altica",' +
						'"asset": "17",' +
						'"assetName": "Automovil",' +
						'"assetCondition": "8",' +
						'"assetConditionName": "Nuevo",' +
						'"product": "11",' +
						'"productName": "Leasing operativo en función financiera",' +
						'"price": "85000",' +
						'"currency": "15",' +
						'"currencyName": "USD",' +
						'"currencyValue": "USD",' +
						'"fixedInsurance": 0,' +
						'"insuranceAmount": 0,' +
						'"realAmount": 72380.50,' +
						'"campaign": "47",' +
						'"campaignName": "PRUEBA GERARDO",' +
						'"futureValue" : 50000,' +
						'"residualValue" : 10,' +
						'"creditDistribution": [' +
							'{' +
								'"initialMonth": 1,' +
								'"finalMonth": 24,' +
								'"baseRate": {' +
									'"baseRateID": 21,' +
									'"baseRateDescription": "Tasa_Vehículos",' +
									'"baseRatePercentage": 10.75,' +
									'"baseRateVariable": 0' +
								'},' +
								'"spread": 0,' +
								'"fee": 1470.02' +
							'},' +
							'{' +
								'"initialMonth": 25,' +
								'"finalMonth": 60,' +
								'"baseRate": {' +
									'"baseRateID": 27,' +
									'"baseRateDescription": "Tasa Vehiculos Variable",' +
									'"baseRatePercentage": 2,' +
									'"baseRateVariable": 1' +
								'},' +
								'"spread": 10,' +
								'"fee": 1496.78' +
							'}' +
						'],' +
						'"period": 31,' +
						'"periodValue": 60,' +
						'"premium": 20,' +
						'"creditCharges": [' +
							'{' +
								'"chargeId": 185,' +
								'"charge": {' +
									'"id": 11,' +
									'"description": "GPS",' +
									'"taxes": 0' +
								'},' +
								'"amount": 2000,' +
								'"paymentTypeId": 2,' +
								'"paymentTypeDescription": "Se suma al monto del crédito",' +
								'"chargesFinancing": []' +
							'},' +
							'{' +
								'"chargeId": 186,' +
								'"charge": {' +
									'"id": 14,' +
									'"description": "Comisión_Sin_IVA",' +
									'"taxes": 0' +
								'},' +
								'"creditPercentage": 3.5,' +
								'"amount": 2380,' +
								'"paymentTypeId": 2,' +
								'"paymentTypeDescription": "Se suma al monto del crédito",' +
								'"chargesFinancing": []' +
							'},' +
							'{' +
								'"chargeId": 187,' +
								'"charge": {' +
									'"id": 10,' +
									'"description": "Administrativo",' +
									'"taxes": 13' +
								'},' +
								'"amount": 0,' +
								'"paymentTypeId": 4,' +
								'"paymentTypeDescription": "Se paga un porcentaje mensual del monto del crédito",' +
								'"chargesFinancing": [' +
									'{' +
										'"initialMonth": 1,' +
										'"finalMonth": 24,' +
										'"percentage": 2.35,' +
										'"interest": 0,' +
										'"fixedAmount": 0' +
									'},' +
									'{' +
										'"initialMonth": 25,' +
										'"finalMonth": 60,' +
										'"percentage": 2.42,' +
										'"interest": 0,' +
										'"fixedAmount": 0' +
									'}' +
								']' +
							'},' +
							'{' +
								'"chargeId": 188,' +
								'"charge": {' +
									'"id": 13,' +
									'"description": "Seguro_Monto_Fijo",' +
									'"taxes": 0' +
								'},' +
								'"amount": 0,' +
								'"paymentTypeId": 5,' +
								'"paymentTypeDescription": "Se paga un monto fijo por rangos del plazo",' +
								'"chargesFinancing": [' +
									'{' +
										'"initialMonth": 1,' +
										'"finalMonth": 60,' +
										'"percentage": 0,' +
										'"interest": 0,' +
										'"fixedAmount": 44.11' +
									'}' +
								']' +
							'}' +
						'],' +
						'"paymentsTable": [' +
							'{' +
								'"amount": 1564.71,' +
								'"interest": 648.4,' +
								'"principal": 916.3,' +
								'"charges": {' +
									'"Administrativo": 141.74,' +
									'"Seguro_Monto_Fijo": 44.11' +
								'},' +
								'"totalAmount": 1768.99,' +
								'"taxes": 18.43,' +
								'"balance": 71463.7,' +
								'"index": 1' +
							'},' +
							'{' +
								'"amount": 1564.71,' +
								'"interest": 640.2,' +
								'"principal": 924.51,' +
								'"charges": {' +
									'"Administrativo": 141.74,' +
									'"Seguro_Monto_Fijo": 44.11' +
								'},' +
								'"totalAmount": 1768.99,' +
								'"taxes": 18.43,' +
								'"balance": 70539.18,' +
								'"index": 2' +
							'}' +
						']' +
					'}';

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/AlticaCotizaciones';
		req.httpMethod = 'POST';
		req.requestBody  = Blob.valueOf(jsonMsg);

		RestContext.request = req;
		RestContext.response = res;

		Test.startTest();
			wsCrearCotizacionAltica_Rest.responseCotizacion results = wsCrearCotizacionAltica_Rest.crearCotizacion();
			System.debug(' ** resultado ** ' + results);
		Test.stopTest();
	}
}