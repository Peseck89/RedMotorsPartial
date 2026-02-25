public class cls_ClientJSONResponse {
	public cls_OperationResult operationResult;

    public static cls_ClientJSONResponse parseClientResponseJSON(String json) {
        return(cls_ClientJSONResponse) System.JSON.deserialize(json, cls_ClientJSONResponse.class);
    }
}