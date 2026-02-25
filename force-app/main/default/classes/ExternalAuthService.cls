public class ExternalAuthService {
    private static final String AUTH_URL = 'http://172.176.136.132:5080/ServiciosSoftlandProductivos/oauth/token';

    public static String authenticate() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(AUTH_URL);
        req.setMethod('GET');
        req.setBody('clientId=interfaz&clientSecret=1nt3gr@c1on&grant_type=password');
        HttpResponse res = new Http().send(req);
        
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        System.debug('Service AccessToken: ' + responseMap.get('access_token'));
        
        return (String) responseMap.get('access_token');
    }
}