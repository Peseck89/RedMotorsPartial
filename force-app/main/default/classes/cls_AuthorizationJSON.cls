public class cls_AuthorizationJSON {
    public String access_token;
    public String token_type;

    public static cls_AuthorizationJSON parseAutorizationResponse(String json) {
        return(cls_AuthorizationJSON) System.JSON.deserialize(json, cls_AuthorizationJSON.class);
    }
}