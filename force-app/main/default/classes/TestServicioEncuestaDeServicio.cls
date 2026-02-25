@isTest
private class TestServicioEncuestaDeServicio {

    @isTest
    static void testInsertarEncuestaExito() {
        // Obtener un caso existente en la base de datos (simplificación)
        Case caso = [SELECT Id, CaseNumber FROM Case LIMIT 1];

        // Crear el cuerpo del request como JSON
        String requestBody = JSON.serialize(new Map<String, Object>{
            'CaseNumber' => caso.CaseNumber,
            'ComentariosServicio' => 'Excelente atención',
            'MarcaVehiculo' => 'BMW',
            'MotivoPuntuacionServicio' => 'Personal amable y rápido',
            'PosibilidadMejorarServicio' => 'Sí',
            'ProbabilidadRecomendacionServicio' => '9',
            'Servicio' => 'Taller'
        });

        // Simular el request
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestUri = '/services/apexrest/encuesta/servicio';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(requestBody);

        // Ejecutar el servicio
        Test.startTest();
        ServicioEncuestaDeServicio.insertarEncuesta();
        Test.stopTest();

        // Validar la respuesta
        String responseBody = RestContext.response.responseBody != null ?
            RestContext.response.responseBody.toString() : '';

        System.assertEquals(201, RestContext.response.statusCode, 'El código de respuesta debe ser 201');
        System.assert(responseBody.contains('"status":"CREATED"'), 'Debe indicar éxito');
        System.assert(responseBody.contains('"encuestaId":"'), 'Debe incluir el ID de la encuesta creada');
    }

    @isTest
    static void testInsertarEncuestaCaseInvalido() {
        String requestBody = JSON.serialize(new Map<String, Object>{
            'CaseNumber' => 'CASO_NO_EXISTENTE',
            'ComentariosServicio' => 'Comentario de prueba',
            'MarcaVehiculo' => 'MINI',
            'MotivoPuntuacionServicio' => 'Motivo',
            'PosibilidadMejorarServicio' => 'No',
            'ProbabilidadRecomendacionServicio' => '5',
            'Servicio' => 'Ventas'
        });

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestUri = '/services/apexrest/encuesta/servicio';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(requestBody);

        Test.startTest();
        ServicioEncuestaDeServicio.insertarEncuesta();
        Test.stopTest();

        System.assertEquals(404, RestContext.response.statusCode, 'Debe devolver 404 si el caso no existe');
        System.assert(RestContext.response.responseBody.toString().contains('ERR_CASE_NOT_FOUND'));
    }

    @isTest
    static void testInsertarEncuestaSinCaseNumber() {
        String requestBody = JSON.serialize(new Map<String, Object>{
            'ComentariosServicio' => 'Comentario sin CaseNumber'
        });

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestUri = '/services/apexrest/encuesta/servicio';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(requestBody);

        Test.startTest();
        ServicioEncuestaDeServicio.insertarEncuesta();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode, 'Debe devolver 400 si falta el CaseNumber');
        System.assert(RestContext.response.responseBody.toString().contains('ERR_MISSING_CASENUMBER'));
    }
}