public virtual class HttpCalloutPost {
	public  HttpResponse callRequest(String fullUrl,String tokenType, String token,String body)
    {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        System.debug(fullUrl);
        req.setEndpoint(fullUrl);
        req.setHeader('Authorization', tokenType+' '+token);
        
        req.setBody(body);
        req.setMethod('POST');
        //120000
        //
        req.setTimeout(120000);
        HttpResponse res = h.send(req);
        System.debug(req.toString());
        return res;
    }
}