public class HttpCalloutAseguradora extends HttpCallout {
    public HttpResponse getAseguradoraCallout(String company,String tokenType, String token, Integer actualPage)
    {
        String url = Label.URLSoftland;
        String ambiente = Label.ambienteSoftland;
        String fullUrl = url+'/'+ambiente+'/softlandAPI/Catalogs/getClientesAseguradoras?compania='+company+'&pageNo='+actualPage+'&pageSize=20';
       
        HttpResponse res = super.callRequest('GET',fullUrl,tokenType,token);
        return res;
    }
}