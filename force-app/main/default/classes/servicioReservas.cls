/**
 * @description       : 
 * @author            : martin.alvrz.grcs@gmail.com
 * @group             : 
 * @last modified on  : 01-19-2023
 * @last modified by  : martin.alvrz.grcs@gmail.com
**/

public class servicioReservas {
    static final String url = Label.URLSoftland;
    static final String ambiente = Label.ambienteSoftland;
    static final String clientId = Label.ClientIdSoftland;
    static final String clientSecret = Label.clientSecretSoftland;

    private static Map<String,Object> getToken() {
        Map<String,Object> responseMap = new Map<String,Object>{'success'=>false};
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url+'/'+ambiente+'/oauth/token');
        System.debug('request.setEndpoint: '+url+'/'+ambiente+'/oauth/token');
        request.setBody('clientId='+clientId+'&clientSecret='+clientSecret+'&grant_type=password');
        request.setHeader('Content-Type', 'application/text');
        request.setMethod('GET');
        request.setTimeout(20000);
        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                responseMap.put('token', response.getBody());
                responseMap.put('success', true);
            } else {
                responseMap.put('error', response.getBody());   
            }
        } catch (System.CalloutException e) {
            responseMap.put('error', e.getMessage());
        }
        return responseMap;
    }
    
    public static Map<String,Object> getReservaById(Id OppId, Id ProdId){
        Map<String,Object> responseMap = new Map<String,Object>{'success'=>false};
        Map<String,Object> tokenResponseMap = getToken();
        Boolean success = (Boolean)tokenResponseMap.get('success');
        if(!success){
            responseMap.put('error', ((String) tokenResponseMap.get('error')));
            return responseMap;
        }

        String token = (String) tokenResponseMap.get('token');

        try {
            //Codigo_de_Producto__c
            System.debug('--------- Start Process ---------');
            Opportunity thisOpportunity = [SELECT Id, Name, BMW_Compania__c, ModelosProductos__c FROM Opportunity WHERE Id =: OppId];
            Product2 thisProduct = [SELECT Id, vin__c, Empresa__c FROM Product2 WHERE Id =: ProdId ];
            if (thisProduct.Empresa__c == 'Bavarian') thisProduct.Empresa__c = 'RMBAVARIAN';
            if (thisProduct.Empresa__c == 'Otobai') thisProduct.Empresa__c = 'RMOTOBAI';

            if (thisProduct.Empresa__c == 'RMBAVARIAN' || thisProduct.Empresa__c == 'RMOTOBAI'){
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                String json = EncodingUtil.urlEncode('{"compania":"'+ thisProduct.Empresa__c +'", "codArticulo": "' + thisProduct.vin__c + '" ,"oportunidad": "' + thisOpportunity.Name + '" }','UTF-8');
  
                req.setEndpoint(url + '/ServiciosSoftlandProductivos/softlandAPI/catalogs/reserveVehicule?json=' + json);
                req.setHeader('Authorization', 'Bearer ' + token);
                req.setMethod('GET');
                req.setTimeout(20000);
                HttpResponse response = new HttpResponse();
                response = http.send(req);

                System.debug('response.getBody: '+response.getBody());
                ReservaResponseWrapper reservaResponse = (ReservaResponseWrapper) System.JSON.deserialize(response.getBody(), ReservaResponseWrapper.class);

                if (response.getStatusCode() == 200 && reservaResponse.operationResult.code == '00') {
                    responseMap.put('success', true);
                }else{
                    responseMap.put('error', reservaResponse.operationResult.description);
                }
            }else{
                responseMap.put('error', 'Empresa no válida');
            }
        }
        catch(System.CalloutException e) {
            responseMap.put('error', e.getMessage());
        }
        return responseMap;
    }

    // Respuesta del web service cuando existe algun error
    // {
    //     "operationResult": {
    //         "code": "01",
    //         "description": "EL ARTICULO INDICADO ES INVALIDO.001"
    //     }
    // }

    //crear la clase wrapper para la respuesta del web service
    public class ReservaResponse {
        public String code;
        public String description;
    }
    //crear la clase wrapper para la respuesta del web service
    public class ReservaResponseWrapper {
        public ReservaResponse operationResult;
    }
    
}