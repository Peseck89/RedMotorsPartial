public class HttpCalloutAuth {
    public String clientId;
    public String clientSecret;

    public HttpCalloutAuth(String clientId, String clientSecret)
    {
        this.clientId = clientId;
        this.clientSecret = clientSecret;
    }

    public HttpResponse getAuth()
    {
        String url = Label.URLSoftland;
        String ambiente = Label.ambienteSoftland;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url+'/'+ambiente+'/oauth/token');
        req.setBody('clientId='+clientId+'&clientSecret='+clientSecret+'&grant_type=password');
        req.setHeader('Content-Type', 'application/text');
        req.setMethod('GET');
        req.setTimeout(20000);
        HttpResponse res = h.send(req);
        return res;
    }
}