public class cls_ActividadComercialJSON {
    public List<cls_ActividadComercial> Data;
    public cls_Paging Paging;

    public static cls_ActividadComercialJSON parseActividadComercialResponse(String json) {
        return(cls_ActividadComercialJSON) System.JSON.deserialize(json, cls_ActividadComercialJSON.class);
    }
}