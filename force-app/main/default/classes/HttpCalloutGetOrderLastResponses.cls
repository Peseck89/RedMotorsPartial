public class HttpCalloutGetOrderLastResponses {
	 public static HttpResponse getOrderLastResponses(String num_Presupuesto, String compania,Id workOrder) {
        String fullUrl = Label.URLSoftland + '/' + Label.ambienteSoftland + '/softlandAPI/orders/getOTorders';
        String jsonStr;
        HttpCalloutAuth htppAuth = new HttpCalloutAuth(Label.ClientIdSoftland, Label.ClientSecretSoftland);
        HttpResponse resauth = htppAuth.getAuth();
        jsonStr = resauth.getBody();
        System.debug(Label.URLSoftland + Label.ambienteSoftland);
        System.debug(jsonStr);
        cls_AuthorizationJSON auth = cls_AuthorizationJSON.parseAutorizationResponse(jsonStr);

        Http http = new Http();
        HttpRequest httpRequest = new HttpRequest();
        System.debug(fullUrl);
        httpRequest.setEndpoint(fullUrl);
        httpRequest.setHeader('Authorization', auth.token_type + ' ' + auth.access_token);
        httpRequest.setMethod('POST');
        httpRequest.setTimeout(20000);
        httpRequest.setBody('{"num_Presupuesto": "' + num_Presupuesto + '", "compania": "' + compania + '"}');
        System.debug(httpRequest.getBody());
        
        HttpResponse httpResponse = http.send(httpRequest);
        System.debug(httpResponse.getBody());
         if(!Test.isRunningTest()){
             cls_OrderJSONResponse.createResponses(cls_OrderJSONResponse.parseOrderResponseJSON(httpResponse.getBody()),workOrder);
         }

        return httpResponse;
    }
}