public class cls_InventoryJSON {
    public List<cls_ProductSoftland> Data;
    public cls_Paging Paging;

    public static cls_InventoryJSON parseInventoryResponse(String json) {
        return(cls_InventoryJSON) System.JSON.deserialize(json, cls_InventoryJSON.class);
    }
}