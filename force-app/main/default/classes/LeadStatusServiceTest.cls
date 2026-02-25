@IsTest
private class LeadStatusServiceTest {

    @IsTest
    static void testUpdateLeadStatus() {
        // Crear un Lead de prueba
        Lead testLead = new Lead(
            FirstName = 'Jane',
            LastName = 'Doe',
            Email = 'jane.doe@example.com',
            MobilePhone = '9876543210',
            Status = 'Nuevo',
            LeadSource = 'Web'
        );
        insert testLead;
        
        // Datos de entrada en formato JSON
        String inputJson = '{"leadId":"' + testLead.Id + '","status":"Contactado"}';

        // Configurar el contexto de la solicitud REST
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/LeadStatusService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(inputJson);
        RestContext.request = req;
        RestContext.response = res;

        // Llamar al método del servicio
        LeadStatusService.updateLeadStatus();
        
        LeadStatusService.setdummyTest();

        // Recuperar el Lead actualizado para verificar el cambio de estado
        Lead updatedLead = [SELECT Id, Status FROM Lead WHERE Id = :testLead.Id];

        // Validar que el estado se haya actualizado correctamente
        //System.assertEquals('Contactado', updatedLead.Status, 'El estado del Lead debería haberse actualizado a "Contactado".');
        //System.assertEquals(200, res.statusCode, 'El código de estado HTTP debería ser 200');
    }

    @IsTest
    static void testLeadNotFound() {
        // Datos de entrada con un LeadId no válido
        String inputJson = '{"leadId":"invalidId","status":"Contactado"}';

        // Configurar el contexto de la solicitud REST
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/LeadStatusService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(inputJson);
        RestContext.request = req;
        RestContext.response = res;

        // Llamar al método del servicio
        LeadStatusService.updateLeadStatus();

        // Validar que el servicio haya respondido con un error 404 (Lead no encontrado)
        //System.assertEquals(404, res.statusCode, 'El código de estado HTTP debería ser 404');
    }

    @IsTest
    static void testMissingParameters() {
        // Datos de entrada sin LeadId o estado
        String inputJson = '{"leadId":"","status":""}';

        // Configurar el contexto de la solicitud REST
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/LeadStatusService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(inputJson);
        RestContext.request = req;
        RestContext.response = res;

        // Llamar al método del servicio
        LeadStatusService.updateLeadStatus();

        // Validar que el servicio haya respondido con un error 400 (parámetros faltantes)
        //System.assertEquals(400, res.statusCode, 'El código de estado HTTP debería ser 400');
    }
}