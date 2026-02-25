public class HttpCalloutUpdateClient extends HttpCallout{
    public HttpResponse getUpdateClientCallout(String blobJSONAccount,String tokenType, String token)
    {
        String url = Label.URLSoftland;
        String ambiente = Label.ambienteSoftland;
        String fullUrl = url+'/'+ambiente+'/softlandAPI/updateClient?json='+blobJSONAccount;
       
        HttpResponse res = super.callRequest('PATCH',fullUrl,tokenType,token);
        return res;
    }
}