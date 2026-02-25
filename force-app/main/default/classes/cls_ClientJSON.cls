public class cls_ClientJSON {
    public List<cls_Client> Data;

    public static cls_ClientJSON parseClientJSON(String json) {
        return(cls_ClientJSON) System.JSON.deserialize(json, cls_ClientJSON.class);
    }
}