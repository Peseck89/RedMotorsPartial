public with sharing class HttpCalloutGetProductRefPrices {
    String url = Label.URLSoftland;
    String ambiente = Label.ambienteSoftland;
    public HttpCalloutGetProductRefPrices() {

    }

    public HttpResponse getProductRefPricesPOST(String articulo, String compania) {
        // Get authentication token
        HttpCalloutAuth httpAuth = new HttpCalloutAuth(Label.ClientIdSoftland, Label.ClientSecretSoftland);
        HttpResponse resAuth = httpAuth.getAuth();

        // Parse the authentication response
        String authResponse = resAuth.getBody();
        cls_AuthorizationJSON auth = cls_AuthorizationJSON.parseAutorizationResponse(authResponse);

        // Prepare the JSON payload
        String payload = '{ "articulo": "' + articulo + '", "compania": "' + 'RMBAVARIAN' + '" }';
        //String payload = '{ "articulo": "' + articulo + '", "compania": "' + compania + '" }';

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
    
    
}