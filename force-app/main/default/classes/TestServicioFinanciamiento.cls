@isTest
private class TestServicioFinanciamiento {
    
    @isTest static void testProcesarJSON() {
        // Crear un objeto JSON que será el body del request
        String jsonString = '{'+
            '"id": 29,'+
            '"tipoIdentificacion": "Cédula Juridica",'+
            '"calculationId": 187,'+
            '"selectedResults": {'+
                '"name": "COTIZADOR NUEVOS 20%",' +
                '"deposit": 9500,' +
            	'"plazo": 96,' +
            	'"primeracuota": 9500,' +
                '"periods": ['+
                    '{'+
                        '"end": 36,'+
                        '"begin": 1,'+
                        '"period": 1,'+
                        '"taxRate": 0.099,'+
                        '"paymentAmount": 1627.431295111841'+
                    '},'+
                    '{'+
                        '"end": 48,'+
                        '"begin": 37,'+
                        '"period": 2,'+
                        '"taxRate": 0.175,'+
                        '"paymentAmount": 1877.0144465398848'+
                    '},'+
                    '{'+
                        '"end": 96,'+
                        '"begin": 49,'+
                        '"period": 3,'+
                        '"taxRate": 0.26,'+
                        '"paymentAmount": 2129.614716882395'+
                    '}'+
                '],'+
                '"tirUsura": 16.58,'+
                '"typeCredit": "Leasing Financiero",'+
                '"tirBussines": 0.1625,'+
                '"idCalculator": 183'+
            '},'+
            '"syncedWithSalesForce": false,'+
            '"createdAt": "2023-07-03T15:32:04.991Z",'+
            '"updatedAt": "2023-07-03T15:32:04.991Z",'+
            '"active": true,'+
            '"client": ['+
                '{'+
                    '"id": 29,'+
                    '"personalID": "1142306011",'+
                    '"name": "Jhon",'+
                    '"lastName": "Doe",'+
                    '"email": "jhondoe@gmail.com",'+
                    '"phone": "+50665457834",'+
                    '"idOportunity": 29'+
                '}'+
            '],'+
            '"vendedor": ['+
                '{'+
                    '"id": 29,'+
                    '"name": "Jhon",'+
                    '"lastName": "Doe",'+
                    '"email": "jhondoe@gmail.com"'+
                '}'+
            '],'+
            '"calculation": {'+
                '"brand": {'+
                    '"name": "Toyota",'+
            		'"modelo": "Land Cruizer",'+
            		'"distribuidor": "Purdy motors"'+
                '},'+
                '"initialAmount": 95000,'+
                '"parameters": ['+
                    '{'+
                        '"value": "Nuevo",'+
                        '"idParameter": 39'+
                    '},'+
                    '{'+
                        '"value": "Combustión",'+
                        '"idParameter": 38'+
                    '},'+
                    '{'+
                        '"value": "Automóvil",'+
                        '"idParameter": 20'+
                    '}'+
                ']'+
            '}'+
        '}';

        // Crear un RestRequest y un RestResponse
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        // Poner el JSON creado anteriormente como body del request
        request.requestBody = Blob.valueOf(jsonString);
        
        // Configurar RestContext
        RestContext.request = request;
        RestContext.response = response;

        // Llamar al método a probar
        String result = ServicioFinanciamiento.procesarJSON();
        
        
        String result2 = ServicioFinanciamiento.procesarJSON();
        // Verificar resultado
        //System.assertEquals('Procesado correctamente.', result);

        // Verificar que se hayan insertado los registros
        //System.assertEquals(1, [SELECT COUNT() FROM Account WHERE Cedula__pc = '0010203041234C']);
        //System.assertEquals(1, [SELECT COUNT() FROM Oportunidad_de_Financiamiento__c WHERE Marca_Altica__c = 'Susuki']);
    }
}