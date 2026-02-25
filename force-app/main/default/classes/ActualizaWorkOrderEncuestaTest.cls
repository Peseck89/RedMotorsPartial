@isTest
private class ActualizaWorkOrderEncuestaTest {

    @isTest static void testActualizaWOEncuesta() {
        // Crear Work Order
        Account a = new Account();
        a.Name = 'Test Account';
        a.Cedula__c = '1231231232';
        insert a;
    
        Product2 p = new Product2();
        p.Name = ' Test Product ';
        p.Description='Test Product Entry 1';
        p.productCode = 'ABC';
        p.isActive = true;
        p.Codigo_de_Producto__c = '123';
        insert p;
    
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = [select id from PricebookEntry limit 1];
        
        Case cs = new Case();
        insert cs;
        
        WorkOrder wo = new WorkOrder();
        wo.CaseId=cs.Id;
        wo.AccountId=a.Id;
        insert wo;
        
        List<WorkOrder> wo2 = [select id, WorkOrderNumber, CaseId from WorkOrder where id = :wo.id LIMIT 1];

        // Preparar datos de entrada conforme al nuevo formato
        String jsonBody = '{"encuestas":[{"nombre":"Test Encuesta","ConsecutivoWorkOrder":"' + wo2[0].WorkOrderNumber + '","repuestas":[{"pregunta":"Test Pregunta 1","respuesta":"Test Respuesta 1","tipo":"texto"},{"pregunta":"Test Pregunta 2","respuesta":"Test Respuesta 2","tipo":"numero"}]}]}';

        // Preparar la solicitud
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(jsonBody);
        req.requestURI = '/services/apexrest/ActualizaWOEncuesta';
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        // Llamar al servicio
        String result = ActualizaWorkOrderEncuesta.actualizaWOEncuesta();

        // Afirmaciones para verificar la lógica
        //System.assert(result.contains('actualizada con éxito'), 'Resultado inesperado: ' + result);
        
        // Verificar la creación de encuestas
        //List<Encuesta__c> encuestasList = [SELECT Id, Name FROM Encuesta__c WHERE WorkOrder__c = :wo2[0].Id];
        //System.assertEquals(1, encuestasList.size(), 'Debería haber una encuesta creada.');
        
        // Verificar la creación de respuestas para la encuesta
        //List<Respuesta__c> respuestasList = [SELECT Id, Pregunta__c FROM Respuesta__c WHERE Encuesta__c = :encuestasList[0].Id];
        //System.assertEquals(2, respuestasList.size(), 'Debería haber dos respuestas creadas para la encuesta.');
    }
}