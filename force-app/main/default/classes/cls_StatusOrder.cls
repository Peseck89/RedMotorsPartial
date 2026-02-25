public class cls_StatusOrder {
    public String code;
    public String detail;

    public static cls_StatusOrder parseStatusJSON(String json) {
        return(cls_StatusOrder) System.JSON.deserialize(json, cls_StatusOrder.class);
    }
}