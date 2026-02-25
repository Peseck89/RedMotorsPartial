public class HttpCalloutGetClient extends HttpCallout{
    	String url = Label.URLSoftland;
        String ambiente = Label.ambienteSoftland;
    public HttpResponse getGetClientCallout(String cedula,String tokenType, String token)
    {
        String fullUrl = this.url+'/'+this.ambiente+'/softlandAPI/getListPaged?key=&nombre=&id='+cedula+'&email=&pageNo=1&pageSize=10';
        HttpResponse res = super.callRequest('GET',fullUrl,tokenType,token);
        return res;
    }
    
    public HttpResponse getSoftlandAccount(String softlandId)
    {
       String jsonStr;
       HttpCalloutAuth htppAuth= new HttpCalloutAuth(label.ClientIdSoftland,label.ClientSecretSoftland);//cambiar por custom label
       HttpResponse resauth = htppAuth.getAuth();
       jsonStr = resauth.getBody();
       cls_AuthorizationJSON auth = cls_AuthorizationJSON.parseAutorizationResponse(jsonStr);
       String fullUrl = this.url+'/'+this.ambiente+'/softlandAPI/getContactInformationDetails?cliente='+softlandId;
       HttpResponse res = super.callRequest('GET',fullUrl,auth.token_type,auth.access_token);
       system.debug(res.getBodyAsBlob());
	   system.debug(res.getBody());
       return res;
    }

     public HttpResponse updateSoftlandClient(String jsonAccount)
    {
       system.debug('Info por actualizar');
       system.debug(jsonAccount);
       String jsonStr;
       HttpCalloutAuth htppAuth= new HttpCalloutAuth(label.ClientIdSoftland,label.ClientSecretSoftland);//cambiar por custom label
       HttpResponse resauth = htppAuth.getAuth();
       jsonStr = resauth.getBody();
       cls_AuthorizationJSON auth = cls_AuthorizationJSON.parseAutorizationResponse(jsonStr);
       //String JSONClient='{ "cliente": "C078258", "telefono1": "60461074", "telefono2": "60461075", "email": "odette.aparicio@gmail.com1", "email_doc_electronico": "odette.aparicio@gmail.com2", "email_doc_electronico_copia": "odette.aparicio@gmail.com3" }';
       jsonAccount= EncodingUtil.urlEncode(jsonAccount,'UTF-8');
       String fullUrl = this.url+'/'+this.ambiente+'/softlandAPI/updateClientContactInformation?json='+jsonAccount;
       system.debug(fullUrl);
       HttpResponse res = super.callRequest('GET',fullUrl,auth.token_type,auth.access_token);
	   system.debug(res.getBody());
       return res;
    }
}