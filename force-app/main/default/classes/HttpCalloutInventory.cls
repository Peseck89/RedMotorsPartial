public class HttpCalloutInventory {
    public String groupParam;

    public HttpCalloutInventory(String groupParam)
    {
        this.groupParam = groupParam;
    }

    public HttpResponse getInventoryCallout(String moneda,String tokenType, String token, Integer actualPage)
    {
        String url = Label.URLSoftland;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        System.debug(url+'/IntegrationServices/softlandAPI/products/'+moneda+'?codGrupo1='+groupParam+'&codGrupo2=&codGrupo3=&codGrupo4=&codGrupo5=&codGrupo6=&pageNo='+actualPage+'&pageSize=3500');
        req.setEndpoint(url+'/IntegrationServices/softlandAPI/products/'+moneda+'?codGrupo1='+groupParam+'&codGrupo2=&codGrupo3=&codGrupo4=&codGrupo5=&codGrupo6=&pageNo='+actualPage+'&pageSize=3500');
        req.setHeader('Authorization', tokenType+' '+token);
        req.setMethod('GET');
        req.setTimeout(20000);
        HttpResponse res = h.send(req);
        return res;
    }
}