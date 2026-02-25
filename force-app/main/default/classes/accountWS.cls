@RestResource(urlMapping='/account/')
global class accountWS {
    @HttpPost
    global static void createAccount()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String jsonStr = RestContext.request.requestBody.toString();
        System.debug('JSON Recieved ' + jsonStr);

        try {
            String Response = accountJSON.createAccount(jsonStr);
            RestContext.response.statusCode = 200;
            RestContext.response.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.ValueOf(Response);
        } 
        catch (Exception e) {
            System.debug('Error on WebService ' + e.getMessage()+ ' on ' + e.getStackTraceString());
            RestContext.response.statusCode = 500;
            RestContext.response.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.ValueOf('[{"Estado":'+e.getMessage()+',"Mensaje":'+e.getLineNumber()+'}]');
        }
    }

    // @HttpPut
    // global static void updateAccount()
    // {
    //     RestRequest req = RestContext.request;
    //     RestResponse res = RestContext.response;
    //     String jsonStr = RestContext.request.requestBody.toString();
    //     System.debug('JSON Recieved ' + jsonStr);

    //     try {
    //         String Response = 'update';//accountJSON.updateAccount(jsonStr);
    //         RestContext.response.statusCode = 200;
    //         RestContext.response.addHeader('Content-Type', 'application/json');
    //         res.responseBody = Blob.ValueOf(Response);
    //     } 
    //     catch (Exception e) {
    //         System.debug('Error on WebServiceProducts ' + e.getMessage()+ ' on ' + e.getStackTraceString());
    //         RestContext.response.statusCode = 500;
    //         RestContext.response.addHeader('Content-Type', 'application/json');
    //         res.responseBody = Blob.ValueOf('[{"Estado":'+e.getMessage()+',"Mensaje":'+e.getLineNumber()+'}]');
    //     }
    // }

    // @HttpGet
    // global static void getAccount()
    // {
    //     RestRequest req = RestContext.request;
    //     RestResponse res = RestContext.response;
    //     String jsonStr = RestContext.request.requestBody.toString();
    //     System.debug('JSON Recieved ' + jsonStr);

    //     try {
    //         String Response = 'obtener cuenta';//preguntasJSON.retonarPreguntas(jsonStr);
    //         RestContext.response.statusCode = 200;
    //         RestContext.response.addHeader('Content-Type', 'application/json');
    //         res.responseBody = Blob.ValueOf(Response);
    //     } 
    //     catch (Exception e) {
    //         System.debug('Error on WebServiceProducts ' + e.getMessage()+ ' on ' + e.getStackTraceString());
    //         RestContext.response.statusCode = 500;
    //         RestContext.response.addHeader('Content-Type', 'application/json');
    //         res.responseBody = Blob.ValueOf('[{"Estado":'+e.getMessage()+',"Mensaje":'+e.getLineNumber()+'}]');
    //     }
    // }
}