@RestResource(urlMapping='/proveedor/')
global class proveedorWS {
	@HttpPost
    global static void createProveedor()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String jsonStr = RestContext.request.requestBody.toString();
        System.debug('JSON Recieved ' + jsonStr);
        try {
            String Response = ProveedorJSON.createProveedor(jsonStr);
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
}