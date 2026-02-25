public class ConsultaCredid {
	private static final String API_ENDPOINT = 'https://api.credid.net/api/score/obtener?identificacion=';
    private static final String AUTHORIZATION = '81f79c93-2d34-47ed-a1c0-ba07801249fb';

    public static String obtenerConfidenceResult(String identificacionCliente) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setEndpoint(API_ENDPOINT + identificacionCliente);
        request.setMethod('POST');
        request.setHeader('Authorization', AUTHORIZATION);
		request.setHeader('Content-Length', '0');
        
        HttpResponse response = http.send(request);
        System.debug('Endpoint ' + response.getBody());
        System.debug('Response ' + response);
        
        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Map<String, Object> data = (Map<String, Object>) results.get('data');
            Integer confidenceResult = (Integer) data.get('confidenceResult');

            return String.valueOf(confidenceResult);
        } else {
            System.debug('HTTP request failed with status code ' + response.getStatusCode());
            return null;
        }
    }
}