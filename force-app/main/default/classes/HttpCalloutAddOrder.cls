public class HttpCalloutAddOrder extends HttpCalloutPost {
    public HttpResponse getAddOrderCallout(String idOrder,String tokenType, String token,String cardCode,String request_id)
    {
        String url = Label.URLSoftland;
        String ambiente = Label.ambienteSoftland;
        String fullUrl = url+'/'+ambiente+'/softlandAPI/orders/add';
       	orderSoftlandWrapper bodyRequest = orderJSONData.getJSONFromOrder(idOrder,cardCode, request_id);
        String body = JSON.serialize(bodyRequest);
         //Pretty print debug
        Object o = JSON.deserializeUntyped(body);
        System.debug(Json.serializePretty(o));
        //-----------------------------
        //ProductController.setSoftlandConfirmation('request',bodyRequest.request_id,workOrder);
        HttpResponse res = super.callRequest(fullUrl,tokenType,token,body);
        APIServiceLog sofltanProcesServiceLog = new APIServiceLog(request_id);
        sofltanProcesServiceLog.setRequest(body);
        return res;
    } 
}