public with sharing class HttpCalloutGetProductRefPrices {
    String url = Label.URLSoftland;
    String ambiente = Label.ambienteSoftland;
    public HttpCalloutGetProductRefPrices() {

    }

    public HttpResponse getProductRefPricesPOST(String articulo, String compania) {
        String codigoEmpresa = requireCodigoEmpresa(compania);

        // Get authentication token
        HttpCalloutAuth httpAuth = new HttpCalloutAuth(Label.ClientIdSoftland, Label.ClientSecretSoftland);
        HttpResponse resAuth = httpAuth.getAuth();

        // Parse the authentication response
        String authResponse = resAuth.getBody();
        cls_AuthorizationJSON auth = cls_AuthorizationJSON.parseAutorizationResponse(authResponse);

        // El consumidor entrega el Código Softland de la Empresa. No seleccionar
        // una compañía por defecto: una Empresa nueva debe viajar por configuración.
        String payload = JSON.serialize(new Map<String, String>{
            'articulo' => articulo,
            'compania' => codigoEmpresa
        });

        // Build the full URL
        String fullUrl = this.url + '/' + this.ambiente + '/softlandAPI/Catalogs/getProductRefPrices';

        // Perform the POST request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(fullUrl);
        req.setMethod('POST');
        req.setHeader('Authorization', auth.token_type + ' ' + auth.access_token);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(payload);

        Http http = new Http();
        HttpResponse res = http.send(req);

        System.debug(res.getBody());
        // Return the response
        return res;
    }

    private static String requireCodigoEmpresa(String compania) {
        if (String.isBlank(compania)) {
            String errorMessage = 'Debe indicar el Código Softland de la Empresa para consultar precios de referencia.';
            AuraHandledException ex = new AuraHandledException(errorMessage);
            ex.setMessage(errorMessage);
            throw ex;
        }
        return compania.trim().toUpperCase();
    }
    
    
}
