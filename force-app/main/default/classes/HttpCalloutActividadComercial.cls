public class HttpCalloutActividadComercial extends HttpCallout {
    public HttpResponse getActividadComercialCallout(String company,String tokenType, String token, Integer actualPage)
    {
        String url = Label.URLSoftland;
        String ambiente = Label.ambienteSoftland;
        String fullUrl = url+'/'+ambiente+'/softlandAPI/Catalogs/getActividadComercial?compania='+company+'&pageNo='+actualPage+'&pageSize=20';
       
        HttpResponse res = super.callRequest('GET',fullUrl,tokenType,token);
        return res;
    }
}