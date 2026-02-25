public class cls_AseguradoraJSON {
    public List<cls_Aseguradora> Data;
    public cls_Paging Paging;

    public static cls_AseguradoraJSON parseAseguradoraResponse(String json) {
        return(cls_AseguradoraJSON) System.JSON.deserialize(json, cls_AseguradoraJSON.class);
    }
}