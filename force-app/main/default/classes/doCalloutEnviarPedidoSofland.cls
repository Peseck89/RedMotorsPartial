public class doCalloutEnviarPedidoSofland {
    @AuraEnabled
    public static string sendOrderSoftland(String oportunidadFinanciamientoId)
    {
        try 
        {
            List<Order> orderList = [SELECT Id, AccountId 
                                     FROM Order
                                     WHERE Id =: oportunidadFinanciamientoId];
                
            OrderService.callSofltandProcess(orderList[0].Id, orderList[0].AccountId);
            return 'Success';
        }
        catch(Exception e) {
            return 'Error: ' + e.getMessage();
        }
        
        /*String url = Label.URLSoftland;
        
        Http h = new Http();
        string response = '';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(url+'/IntegrationServices/oauth/token');
        req.setBody('clientId=pruebas&clientSecret=user123456&grant_type=password');
        req.setHeader('Content-Type', 'application/text');
        req.setMethod('GET');
        req.setTimeout(20000);
        try {
            String jsonStr;
            if(!Test.isRunningTest())
            {
                HttpResponse res = h.send(req);
                System.debug(res.getStatus());
                jsonStr = res.getBody();
            }
            else {
                StaticResource resource = [SELECT Id, Body FROM StaticResource WHERE Name = 'clienteResource' LIMIT 1];
                jsonStr = resource.Body.toString();
            }
            System.debug(jsonStr);
            response = jsonStr;
            //response = obtenerClienteJSON.updateCliente(jsonStr, oportunidadFinanciamiento);
                
        }
        catch(System.CalloutException e) {
            System.Debug(e);
            return 'Error, verifique los datos del cliente';
        }
        return response;*/
        
    }
}