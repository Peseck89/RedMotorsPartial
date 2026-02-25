public class WorkOrderCancelOrder {
    
    // URL del servicio de autenticación
    private static final String AUTH_URL = 'http://172.176.136.132:5080/ServiciosSoftlandProductivos/oauth/token';
    private static final String CLIENT_ID = 'interfaz';
    private static final String CLIENT_SECRET = '1nt3gr@c1on';
    private static final String GRANT_TYPE = 'password';
    
    // URL del servicio de cancelar orden
    private static final String CANCEL_ORDER_URL = 'http://172.176.136.132:5080/ServiciosSoftlandProductivos/softlandAPI/orders/cancelOrder';
    
    // Método para autenticarse y obtener el token
    public static String authenticate() {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        // Configurar la solicitud de autenticación
        req.setEndpoint(AUTH_URL);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String requestBody = 'clientId=' + CLIENT_ID + '&clientSecret=' + CLIENT_SECRET + '&grant_type=' + GRANT_TYPE;
        req.setBody(requestBody);
        
        HttpResponse res = http.send(req);
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        
        // Devolver el token de acceso
        return (String) responseMap.get('access_token');
    }
    
    // Método para cancelar una orden de trabajo
    public static void cancelWorkOrder(String orderId, String companyType) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        // Configurar la solicitud para cancelar la orden de trabajo
        req.setEndpoint(CANCEL_ORDER_URL + '?compania=' + companyType + '&OrdenTrabajo=' + orderId);
        System.debug('Link de llamada externa: ' + CANCEL_ORDER_URL + '?compania=' + companyType + '&OrdenTrabajo=' + orderId);
        req.setMethod('GET');
        
        // Obtener el token de autenticación
        String accessToken = authenticate();
        
        // Configurar el encabezado de autorización
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        
        // Realizar la llamada al servicio de cancelar orden
         if (!Test.isRunningTest()) {
			HttpResponse res = http.send(req);             
             
        }      
    }
}