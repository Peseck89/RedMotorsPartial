/**
 * Clase cliente para el consumo de servicios de Softland
 * ejemplo de respuesta en el cambio de bodega {"operationResult":{"code":"02","description":"El codigo del articulo no es valido."}}
 * @author Redmotors
 * @since 09-09-2024
 */
public with sharing class RM_SoftlandClient {

    final Integer HTTP_OK = 200;
    final Integer HTTP_CREATED = 201;
    final Integer HTTP_BAD_REQUEST = 400;
    final Integer HTTP_CLIENT_ERROR = 499;

    private static final String BASE_URL = Label.URLSoftland + '/' + Label.ambienteSoftland;
    private static final String CLIENT_ID = Label.ClientIdSoftland;
    private static final String CLIENT_SECRET = Label.clientSecretSoftland;
    private static final String ENVIROMENT = Label.ambienteSoftland;

    private String accessToken;

    public RM_SoftlandClient() {
        this.accessToken = authenticate();
    }

    private String authenticate() {
        HttpRequest request = new HttpRequest();
        String url = BASE_URL + '/oauth/token';
        request.setEndpoint(url);
        request.setBody('clientId=' + CLIENT_ID + '&clientSecret=' + CLIENT_SECRET + '&grant_type=password');
        request.setHeader('Content-Type', 'application/text');
        request.setMethod('GET');
        request.setTimeout(20000);

        Http http = new Http();
        try {
            HttpResponse response = http.send(request);
            String jsonResponse = response.getBody();
            System.debug('************** jsonResponse **************');
            System.debug(jsonResponse);
            if (response.getStatusCode() == HTTP_OK) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
                return (String) result.get('access_token');
            } else {
                throw new RM_CalloutException('Error en la autenticación: ' + response.getStatusCode() + ' - ' + response.getStatus());
            }
        } catch (Exception e) {
            System.debug('Excepción en la autenticación: ' + e.getMessage());
            throw new RM_CalloutException('No se pudo autenticar: ' + e.getMessage());
        }
    }

    // Método para realizar una solicitud GET
    // public Map<String, Object> getData(String endpointUrl) {
    //     Map<String, Object> result = new Map<String, Object>{'success' => false, 'data' => null};
    //     HttpRequest request = new HttpRequest();
    //     request.setEndpoint(BASE_URL + endpointUrl);
    //     request.setMethod('GET');
    //     request.setHeader('Content-Type', 'application/json');
    //     request.setHeader('Authorization', 'Bearer ' + this.accessToken);

    //     Http http = new Http();
    //     HttpResponse response;
    //     try {
    //         response = http.send(request);
    //         Integer statusCode = response.getStatusCode();
    //         String responseBody = response.getBody();

    //         if (statusCode == HTTP_OK || statusCode == HTTP_CREATED) {
    //             result.put('success', true);
    //             result.put('data', responseBody);
    //         } else if (statusCode >= HTTP_BAD_REQUEST && statusCode <= HTTP_CLIENT_ERROR) {
    //             result.put('data', responseBody);
    //         } else {
    //             throw new RM_CalloutException('Error en la solicitud GET: ' + statusCode + ' - ' + response.getStatus());
    //         }
    //     } catch (Exception e) {
    //         System.debug('Excepción en la solicitud GET: ' + e.getMessage());
    //         throw new RM_CalloutException('No se pudo obtener la data: ' + e.getMessage());
    //     }
    //     return result;
    // }

    // Método para realizar una solicitud POST
    public Map<String, Object> postData(String endpointUrl, String jsonBody) {

        Map<String, Object> result = new Map<String, Object>{'success' => false, 'data' => null};
        HttpRequest request = new HttpRequest();
        request.setEndpoint(BASE_URL + endpointUrl);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + this.accessToken);
        request.setBody(jsonBody);
    
        Http http = new Http();
        HttpResponse response;
        try {
            response = http.send(request);
            String jsonResponse = response.getBody();
            Integer statusCode = response.getStatusCode();
    
            if (statusCode == HTTP_OK || statusCode == HTTP_CREATED) {
                result.put('success', true);
                result.put('data', jsonResponse);
            } else if (statusCode >= HTTP_BAD_REQUEST && statusCode <= HTTP_CLIENT_ERROR) {
                result.put('data', jsonResponse);
            } else {
                throw new RM_CalloutException('Error in POST request: ' + statusCode + ' - ' + response.getStatus());
            }
        } catch (Exception e) {
            System.debug('Exception in POST request: ' + e.getMessage());
            throw new RM_CalloutException('Failed to send data: ' + e.getMessage());
        }
        return result;
    }


}