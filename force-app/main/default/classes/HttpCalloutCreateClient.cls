public class HttpCalloutCreateClient extends HttpCallout{
    public HttpResponse getCreateClientCallout(String blobJSONAccount,String tokenType, String token)
    {
        String url = Label.URLSoftland;
        String ambiente = Label.ambienteSoftland;
        String fullUrl = url+'/'+ambiente+'/softlandAPI/addClient?json='+blobJSONAccount;
       
        HttpResponse res = super.callRequest('GET',fullUrl,tokenType,token);
        return res;
    }
}