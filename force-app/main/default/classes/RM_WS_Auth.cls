/**
 * @description       : Web Service autenticacion
 * @author            : marcohernandezhp@gmail.com
 * @group             : Redmotors
 * @last modified on  : 03-05-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
public abstract class RM_WS_Auth {
    
    public class AuthResponse
    {
        public String access_token;
        public String token_type;
    }

    public static AuthResponse getAuth(){
        Http http = new Http();        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Label.URLSoftland+'/'+Label.ambienteSoftland+'/oauth/token');
        request.setBody('clientId='+Label.ClientIdSoftland+'&clientSecret='+Label.clientSecretSoftland+'&grant_type=password');
        request.setHeader('Content-Type', 'application/text');
        request.setMethod('GET');
        request.setTimeout(20000);
        
        HttpResponse response = http.send(request);
        return (AuthResponse) System.JSON.deserialize(response.getBody(), AuthResponse.class);
    }  
}