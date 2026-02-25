public  class servicioEliminarReserva {
    
    public static String getEliminarReservaById(Id OppId, Id ProdId){
        String url = Label.URLSoftland;
        String ambiente = Label.ambienteSoftland;
        String clientId = Label.ClientIdSoftland;
        String clientSecret = Label.clientSecretSoftland;
        String jsonTknStr, eliminarReservaResponse;
        
        Http http = new Http();
        
        //Try callout to get token access
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url+'/'+ambiente+'/oauth/token');
        System.debug('request.setEndpoint: '+url+'/'+ambiente+'/oauth/token');
        request.setBody('clientId='+clientId+'&clientSecret='+clientSecret+'&grant_type=password');
        request.setHeader('Content-Type', 'application/text');
        request.setMethod('GET');
        request.setTimeout(20000);
        
        if(Test.isRunningTest()) jsonTknStr = 'Tkn01';
        else {
            HttpResponse response = http.send(request);
            jsonTknStr = response.getBody();
        }
        
        try {
            System.debug(jsonTknStr);
            
            // BatchGetImpuestoSoftland.AuthorizationJSON auth = BatchGetImpuestoSoftland.AuthorizationJSON.parseAutorizationResponse(jsonStr);
            //Codigo_de_Producto__c
            System.debug('--------- Start Process ---------');
            Opportunity thisOpportunity = [SELECT Id, Name, BMW_Compania__c, ModelosProductos__c FROM Opportunity WHERE Id =: OppId];
            Product2 thisProduct = [SELECT Id, vin__c, Empresa__c FROM Product2 WHERE Id =: ProdId ];
            if (thisProduct.Empresa__c == 'Bavarian') thisProduct.Empresa__c = 'RMBAVARIAN';
            //thisProduct.Empresa__c = 'RMBAVARIAN';
            if (thisProduct.Empresa__c == 'RMBAVARIAN'){
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                String json = EncodingUtil.urlEncode('{"compania":"'+ thisProduct.Empresa__c +'", "codArticulo": "' + thisProduct.vin__c + '" ,"oportunidad": "' + thisOpportunity.Name + '" }','UTF-8');
                System.debug(url + '/ServiciosSoftlandProductivos/softlandAPI/catalogs/unreserveVehicule?json=' + json);
                
                req.setEndpoint(url + '/ServiciosSoftlandProductivos/softlandAPI/catalogs/unreserveVehicule?json=' + json);
                req.setHeader('Authorization', 'Bearer ' + jsonTknStr);
                req.setMethod('GET');
                req.setTimeout(20000);
                HttpResponse resp = new HttpResponse();
                resp = h.send(req);
                
                eliminarReservaResponse = resp.getBody();
                if(resp.getStatusCode() == 200){
                    System.debug('************** codigo: ' + resp.getStatusCode() + ' -> ' + resp.getBody());
                    return eliminarReservaResponse;
                }
            }
        }
        catch(System.CalloutException e) {
            System.Debug(e);
        }
        return eliminarReservaResponse;
    }
}