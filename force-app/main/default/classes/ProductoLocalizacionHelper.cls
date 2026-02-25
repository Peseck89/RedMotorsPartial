public class ProductoLocalizacionHelper {
    
    private static final String SERVICE_URL = 'http://172.176.136.132:5080/ServiciosSoftlandProductivos/softlandAPI/catalogs/getDisponibleArticuloBodegaLocalizacion';

    public class Localizacion {
        public String bodega;
        public String localizacion;
        public Decimal cant_disponible;
    }

    public HttpResponse obtenerLocalizaciones(String codigoProducto, String compania) {
        List<Localizacion> localizaciones = new List<Localizacion>();
		HttpResponse res1 = new HttpResponse();
        try {
            // Obtener token desde tu servicio de autenticación externo
            String tokenAuthentificacion;
            if (Test.isRunningTest()) {
                tokenAuthentificacion = 'mocked-token';
            }
            else{
            	tokenAuthentificacion = ExternalAuthService.authenticate();
            }

            HttpRequest req = new HttpRequest();
            req.setEndpoint(SERVICE_URL);
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + tokenAuthentificacion);
            req.setHeader('Content-Type', 'application/json');

            // JSON correcto con compania y articulo
            Map<String, String> bodyMap = new Map<String, String>();
            bodyMap.put('compania', 'RMBAVARIAN');
            bodyMap.put('articulo', codigoProducto);

            req.setBody(JSON.serialize(bodyMap));

            Http http = new Http();
            HttpResponse res = http.send(req);
            if (res.getStatusCode() == 200) {
                res1 = res;
                System.debug('res.getBody() '+res.getBody());
                /*Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

                if (jsonResponse.containsKey('Data')) {
                    List<Object> data = (List<Object>) jsonResponse.get('Data');

                    for (Object item : data) {
                        Map<String, Object> loc = (Map<String, Object>) item;
                        Localizacion l = new Localizacion();
                        l.bodega = (String) loc.get('bodega');
                        l.localizacion = (String) loc.get('localizacion');
                        l.cant_disponible = Decimal.valueOf(String.valueOf(loc.get('cant_disponible')));
                        localizaciones.add(l);
                    }
                }
                */
            } else {
                System.debug('Error en la respuesta: ' + res.getStatusCode() + ' - ' + res.getBody());
            }

        } catch (Exception e) {
            System.debug('Excepción en llamada a servicio de localización: ' + e.getMessage());
        }

        return res1;
    }
}