public class cls_BodegaJSON {
    public List<cls_Bodega> Data;
    public cls_Paging Paging;

    public static cls_BodegaJSON parseBodegaResponse(String json) {
        return(cls_BodegaJSON) System.JSON.deserialize(json, cls_BodegaJSON.class);
    }
}