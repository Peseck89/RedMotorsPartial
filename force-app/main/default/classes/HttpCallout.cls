public virtual class HttpCallout {
    public virtual HttpResponse callRequest(String method,String fullUrl,String tokenType, String token)
    {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        System.debug(fullUrl);
        req.setEndpoint(fullUrl);
        req.setHeader('Authorization', tokenType+' '+token);
        req.setMethod(method);
        req.setTimeout(20000);
        HttpResponse res = h.send(req);
        return res;
    }
}