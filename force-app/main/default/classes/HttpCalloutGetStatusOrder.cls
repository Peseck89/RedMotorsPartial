public class HttpCalloutGetStatusOrder extends HttpCallout {
    public HttpResponse getGetStatusOrderCallout(String BD,String ordenTrabajo,String tokenType, String token)
    {
        String url = Label.URLSoftland;
        String ambiente = Label.ambienteSoftland;
        String fullUrl = url+'/'+ambiente+'/softlandAPI/Orders/getStatus?compania='+BD+'&ordenTrabajo='+ordenTrabajo;
       
        HttpResponse res = super.callRequest('GET',fullUrl,tokenType,token);
        return res;
    }
}