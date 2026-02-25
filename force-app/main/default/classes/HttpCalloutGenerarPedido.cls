public class HttpCalloutGenerarPedido extends HttpCalloutPost{
    
    public HttpResponse getGenerarPedidoCallout(WorkOrder wo,String tokenType, String token,String cardCode,String request_id, id workorderId){
        
        String url = Label.URLSoftland;
        String ambiente = Label.ambienteSoftland;
        String fullUrl = url+'/'+ambiente+'/softlandAPI/reserve/requestOrder';

        orderSoftlandWrapper bodyRequest = generarPedidoJSONData.createWraper( wo, cardCode, request_id);
        String body = JSON.serialize(bodyRequest);
        
        JSON_History__c JsonHistory = new JSON_History__c();
        JsonHistory.Work_Order__c = workorderId;
        
        if (body.length() <= 32768) {
            JsonHistory.JSON__c = body;
        }else{
            JsonHistory.JSON__c = body.substring(0, 32768);
            
        }
        
        
        JsonHistory.Name = 'Servicio generar pedido';
        
        
        //Pretty print debug
        Object o = JSON.deserializeUntyped(body);
        System.debug(Json.serializePretty(o));
        System.debug(fullUrl);
        System.debug(tokenType);
        System.debug(token);
        System.debug(body);
        HttpResponse res = super.callRequest(fullUrl,tokenType,token,body);
        
        //APIServiceLog sofltanProcesServiceLog = new APIServiceLog(request_id);
        //sofltanProcesServiceLog.setRequest(body);
        //
        //
        //
        string response = res.getBody();
        
        if (response.length() <= 32768) {
            JsonHistory.JSON_Response__c = response;
        }else{
            JsonHistory.JSON_Response__c = response.substring(0, 32768);
            
        }
        JsonHistory.JSON_Response__c = res.getBody();
        JsonHistory.Error_Message__c = 'Servicio generar pedido';
        insert JsonHistory;
        

        return res;
    }
}