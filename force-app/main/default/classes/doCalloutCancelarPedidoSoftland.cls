public class doCalloutCancelarPedidoSoftland {
    @AuraEnabled
    public static string sendCheckOrderSoftland(String orderId)
    {
        Order actualOrder = cls_DMLHelper.getOrder(orderId);
        //Opportunity actualOpp = [SELECT Id FROM Opportunity WHERE pedidoRelacionado__c = :OrderId];
        String response;
        String url = Label.URLSoftland;
        String clientId = Label.ClientIdSoftland;
        String clientSecret = Label.clientSecretSoftland;
        try {
            String jsonStr;
            HttpCalloutAuth htppAuth = new HttpCalloutAuth(clientId,clientSecret);
            HttpResponse res = htppAuth.getAuth();
            jsonStr = res.getBody();
            cls_AuthorizationJSON auth = cls_AuthorizationJSON.parseAutorizationResponse(jsonStr);
            System.debug('Access Token: '+auth.access_token);
            HttpCalloutGetStatusOrder htppGetStatus = new HttpCalloutGetStatusOrder();
            res = htppGetStatus.getGetStatusOrderCallout(actualOrder.empresaQueFactura__c,actualOrder.Id,auth.token_type,auth.access_token);
            jsonStr = res.getBody();
                        
            System.debug(jsonStr);
           
            if(res.getStatusCode()==200)
            {
                cls_StatusOrder statusOrder = cls_StatusOrder.parseStatusJSON(jsonStr);
                
                if(statusOrder.detail=='Modificable')
                {
                    HttpCalloutCancelOrder htppCancelOrder = new HttpCalloutCancelOrder();
                    res = htppCancelOrder.getCancelOrderCallout(actualOrder.empresaQueFactura__c,actualOrder.Id,auth.token_type,auth.access_token);
                    jsonStr = res.getBody();
                    response = 'Orden cancelada exitosamente';
                } else {
                    response = 'No se puede cancelar la orden en Salesforce ya que se encuentra en estado: '+statusOrder.code;
                }
                    
            }
        }
        catch(System.CalloutException e) {
            System.Debug(e);
            response = e.getMessage();
        }
        
        
        
        return response;
        
    }
}