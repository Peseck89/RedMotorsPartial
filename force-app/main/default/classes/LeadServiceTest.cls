@IsTest
private class LeadServiceTest {
    
    @IsTest
    static void testCreateLead() {
        // Datos de prueba
        String inputJson = '{"FirstName":"John","LastName":"Doe","Email":"john.doe@example.com","MobilePhone":"1234567890","Tipotrafico":"BMW","FechaPosibleCompra":"1 a 3 meses","Sucursal":"Escazú","Marca":"BMW","Familia1":"iX","Modelo_De_Inter_s1":"BMW-IX40-VR-PREMIUM","Ano1__c":"2024"}';
        
          // Configurar el contexto de la solicitud REST
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/CreateLeadService';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(inputJson);
        RestContext.request = req;
        RestContext.response = res;
        
        // Llamar al método del servicio
        LeadService.createLead();
        
        LeadService.dummy();
        
    }
    
    // Método auxiliar para obtener el nombre del Tipotrafico a partir del RecordTypeId
    private static String getTipotrafico(String recordTypeId) {
        Map<String, String> recordTypeMap = new Map<String, String>{
            '0120P000000arDfQAI' => 'BMW',
            '0120P000000arDiQAI' => 'MINI',
            '0120P000000arDhQAI' => 'Kawasaki',
            '0120P000000arDjQAI' => 'Motorrad',
            '0120P000000arDkQAI' => 'Polaris'
        };
        
        return recordTypeMap.get(recordTypeId);
    }

	
}