public with sharing class HttpCalloutGetProductFreshRefPrices {
    String url = Label.URLSoftland;            // ej: http://172.16.69.16
    String ambiente = Label.ambienteSoftland;  // ej: ServiciosSoftlandProductivos

    public HttpCalloutGetProductFreshRefPrices() {}

    public HttpResponse getProductFreshRefPricesPOST(String articulo, String compania) {
        // 1) Auth (igual que tu otro servicio)
        HttpCalloutAuth httpAuth = new HttpCalloutAuth(Label.ClientIdSoftland, Label.ClientSecretSoftland);
        HttpResponse resAuth = httpAuth.getAuth();
        cls_AuthorizationJSON auth = cls_AuthorizationJSON.parseAutorizationResponse(resAuth.getBody());

        // 2) Payload (JSON Request)
        String companiaFinal = String.isBlank(compania) ? 'RMBAVARIAN' : compania;

        Map<String, Object> payloadObj = new Map<String, Object>{
            'articulo' => articulo,
            'compania' => companiaFinal
        };
        String payload = JSON.serialize(payloadObj);

        // ✅ OPCIÓN 1: Debug del JSON completo que vas a mandar (en partes si es largo)
        debugLongString('FreshRefPrices REQUEST payload', payload, 3500);

        // 3) Endpoint nuevo
        String fullUrl = this.url + '/' + this.ambiente + '/softlandAPI/Catalogs/getProductFreshRefPrices';
        System.debug(LoggingLevel.ERROR, 'FreshRefPrices REQUEST endpoint => ' + fullUrl);

        // 4) Request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(fullUrl);
        req.setMethod('POST');
        req.setHeader('Authorization', auth.token_type + ' ' + auth.access_token);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(payload);

        Http http = new Http();
        HttpResponse res = http.send(req);

        // (Opcional) Debug de respuesta (también en partes)
        debugLongString('FreshRefPrices RESPONSE body', res != null ? res.getBody() : null, 3500);

        return res;
    }

    /**
     * Imprime strings largos en varias partes para que NO se corten en el Debug Log.
     * chunkSize recomendado: 2000 - 4000.
     */
    private static void debugLongString(String label, String value, Integer chunkSize) {
        if (String.isBlank(value)) {
            System.debug(LoggingLevel.ERROR, label + ' => (null/empty)');
            return;
        }
        if (chunkSize == null || chunkSize <= 0) chunkSize = 3500;

        Integer total = value.length();
        Integer part = 1;

        for (Integer i = 0; i < total; i += chunkSize) {
            Integer endIdx = Math.min(i + chunkSize, total);
            String piece = value.substring(i, endIdx);
            System.debug(LoggingLevel.ERROR, label + ' (part ' + part + ') => ' + piece);
            part++;
        }
    }
}