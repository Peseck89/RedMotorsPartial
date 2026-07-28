public  class servicioEliminarReserva {
    
    public static String getEliminarReservaById(Id OppId, Id ProdId){
        String url = Label.URLSoftland;
        String ambiente = Label.ambienteSoftland;
        String clientId = Label.ClientIdSoftland;
        String clientSecret = Label.clientSecretSoftland;
        String jsonTknStr, eliminarReservaResponse;

        try {
            // BatchGetImpuestoSoftland.AuthorizationJSON auth = BatchGetImpuestoSoftland.AuthorizationJSON.parseAutorizationResponse(jsonStr);
            //Codigo_de_Producto__c
            System.debug('--------- Start Process ---------');
            Opportunity thisOpportunity = [SELECT Id, Name, BMW_Compania__c, ModelosProductos__c FROM Opportunity WHERE Id =: OppId];
            Product2 thisProduct = [SELECT Id, vin__c, Empresa__c FROM Product2 WHERE Id =: ProdId ];
            String companyCode = resolveProductCompany(thisProduct.Empresa__c);

            if (companyCode == 'RMOTOBAI') {
                return 'No existe configuración confirmada de eliminación de reserva Softland para RMOTOBAI.';
            }
            if (companyCode == 'RMPEKING') {
                return 'No existe configuración confirmada de eliminación de reserva Softland para RMPEKING.';
            }

            Http http = new Http();

            //Try callout to get token access
            HttpRequest request = new HttpRequest();
            request.setEndpoint(url+'/'+ambiente+'/oauth/token');
            System.debug('request.setEndpoint: '+url+'/'+ambiente+'/oauth/token');
            request.setBody('clientId='+clientId+'&clientSecret='+clientSecret+'&grant_type=password');
            request.setHeader('Content-Type', 'application/text');
            request.setMethod('GET');
            request.setTimeout(20000);
            HttpResponse response = http.send(request);
            jsonTknStr = response.getBody();
            System.debug(jsonTknStr);

            if (companyCode == 'RMBAVARIAN'){
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                String json = EncodingUtil.urlEncode('{"compania":"'+ companyCode +'", "codArticulo": "' + thisProduct.vin__c + '" ,"oportunidad": "' + thisOpportunity.Name + '" }','UTF-8');
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
        catch(EmpresaConfigurationException e) {
            return e.getMessage();
        }
        catch(System.CalloutException e) {
            System.Debug(e);
        }
        return eliminarReservaResponse;
    }

    private static String resolveProductCompany(String productCompany) {
        if (String.isBlank(productCompany)) {
            throw new EmpresaConfigurationException('No existe empresa configurada para eliminar la reserva del vehículo.');
        }

        String normalizedCompany = productCompany.trim().toUpperCase();

        if (normalizedCompany == 'BAVARIAN' || normalizedCompany == 'RMBAVARIAN') {
            return 'RMBAVARIAN';
        }
        if (normalizedCompany == 'OTOBAI' || normalizedCompany == 'RMOTOBAI') {
            return 'RMOTOBAI';
        }
        if (normalizedCompany == 'RMPEKING') {
            return 'RMPEKING';
        }

        throw new EmpresaConfigurationException('Empresa no soportada para eliminar la reserva del vehículo: ' + productCompany);
    }
}