public without sharing class Registrar_Anticipo_Controller {
    
    //private static final String SERVICE_URL = 'http://172.176.136.132:5080/IntegrationServices/softlandAPI/Catalogs/addVehiculeOpportunity';
    private static final String SERVICE_URL = 'http://172.176.136.132:5080/ServiciosSoftlandProductivos/softlandAPI/Catalogs/addVehiculeOpportunity';
    
    @AuraEnabled 
    public static Boolean findAnticipos(String oppId){
        list<Anticipo__c> lstAnticipos = [SELECT Id, Name, Identificador__c, Oportunidad__c, Estatus__c, Monto__c,Producto__c FROM Anticipo__c WHERE Oportunidad__c =: oppId];
        if(lstAnticipos.size() > 0){
            return true;
        }else{
            return false;
        }
        
    }

    @AuraEnabled(cacheable=true)
    public static Boolean findQuote(String oppId){
        Boolean isSync = false;
        List<Opportunity> lstOppActual = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName IN ('Autos_Usados','Motos_Usados') AND Id =: oppId ];
        if(lstOppActual.size() > 0){
            List<Quote> lstQuotes = [SELECT Id, IsSyncing FROM Quote WHERE OpportunityId =: oppId and IsSyncing = true];
            if(lstQuotes.size() > 0){
                isSync =  true;
            }
        }else{
            isSync =  false;
        }
        
        return isSync;
    }

    @AuraEnabled 
    public static Map<String,Object> findPayment(String identifier, String oppId){
        String pricebookname = 'RMBAVARIAN';
        System.debug('oppId '+oppId);
        if(oppId != null && oppId != ''){
            try{
                Opportunity opp = [Select Id,Pricebook2Id from opportunity Where Id=:oppId];
                if(opp.Pricebook2Id != null){
                    Pricebook2 pb = [Select Id,Name from Pricebook2 Where Id=: opp.Pricebook2Id];
                    if(pb!=null){
                        if(pb.Name.contains('Otobai')){
                            pricebookname = 'RMOTOBAI';
                        }
                    }
                }
            }catch(Exception e){
                System.debug('Error--'+e.getMessage());
            }
            
        }
        if (String.isEmpty(identifier)) {
            throw new AuraHandledException('El identificador del pago es requerido.');
        }

        Map<String,Object> responseMap = new Map<String,Object>();
        try {
            Http http = new Http();        
            HttpRequest request = new HttpRequest();

            AuthResponse authResponse = getAuth();

            String jsonRequestBody = '{"compania":"'+ pricebookname +'", "cod_anticipo": "' + identifier + '"}';            
            request.setEndpoint( Label.URLSoftland + '/ServiciosSoftlandProductivos/softlandAPI/catalogs/getReceipt?json='+EncodingUtil.urlEncode(jsonRequestBody,'UTF-8'));
            request.setHeader('Authorization', 'Bearer '+authResponse.access_token);

			System.debug('Consulta: '+ jsonRequestBody);            
            request.setMethod('GET');   
            HttpResponse response = http.send(request);
            String jsonString =  response.getBody();
            
            Log_servicios__c log = new Log_servicios__c();
			log.Llamada_servicio__c = '/ServiciosSoftlandProductivos/softlandAPI/catalogs/getReceipt?json=';
			log.JSON_Enviado__c = jsonRequestBody;
			log.JSON_Respuesta__c = response.getBody();
            log.Oportunidad__c = oppId;
			Insert log;             
            
            if ((response.getStatusCode() == 200 && jsonString != null)) {
                WSOperationResult  wsOperationResult =  (WSOperationResult) System.JSON.deserialize(jsonString, WSOperationResult.class);
				
                if (wsOperationResult == null || wsOperationResult.operationResult == null) {
                    throw new AuraHandledException('La respuesta del servicio eesta vacia o no pudo interpretarse.');
                }
                
				System.debug('Respuesta: '+ wsOperationResult);
                
                if (wsOperationResult.operationResult.code != null && wsOperationResult.operationResult.code == '00') {
                    WSOperationResultValues wsORValues = wsOperationResult.operationResult;
                    responseMap.put('wsORValues',wsORValues);     
                    responseMap.put('monto_anticipo',wsORValues != null ? wsORValues.monto_anticipo : 0);                        
                    responseMap.put('code',(wsORValues != null) ? wsORValues.code : '');
                    responseMap.put('oportunidad',wsORValues != null ? wsORValues.oportunidad : '');
                    responseMap.put('cod_anticipo',wsORValues != null ? wsORValues.cod_anticipo : '');
                }else{
                    throw new AuraHandledException(wsOperationResult.operationResult.description);
                }
            }else{
                throw new AuraHandledException('El servicio de Softland no ha respondio correctamente.');
            }
        } catch (System.CalloutException e) {
            System.debug('@@@error@@@');
            System.debug(e.getMessage());
        }
        return responseMap;
    }

    @AuraEnabled 
    public static Map<String,Object> addReceiptOportunity(String oppId,String productId,String identifier,Decimal monto){
        if (String.isEmpty(oppId)) {
            throw new AuraHandledException('La oportunidad es requerida.');
        }
        if (String.isEmpty(productId)) {
            throw new AuraHandledException('El vehiculo es requerido.');
        }
        if (String.isEmpty(identifier)) {
            throw new AuraHandledException('El identificador del anticipo es requerido.');
        }

        Map<String,Object> responseMap = new Map<String,Object>();
        try {
        	String pricebookname = 'RMBAVARIAN';
            
            List<Opportunity> oppList = [SELECT Id,Id_Oportunidad__c, Pricebook2Id , Name, Account.Name, Account.codigoSoftland__c,ConsecutivoOportunidad__c FROM Opportunity WHERE Id =:oppId LIMIT 1];
			if(oppList[0].Pricebook2Id != null){
                Pricebook2 pb = [Select Id,Name from Pricebook2 Where Id=: oppList[0].Pricebook2Id];
                if(pb!=null){
                    if(pb.Name.contains('Otobai')){
                        pricebookname = 'RMOTOBAI';
                    }
                }
            }
            
            if (oppList.isEmpty() && !Test.isRunningTest()) {
                throw new AuraHandledException('La oportunidad no existe.');
            } 

            List<Product2> prodList = [SELECT Id,Producto_Reservado__c,vin__c,Empresa__c,RM_Reportado__c FROM Product2 WHERE Id =:productId LIMIT 1];
            if (prodList.isEmpty() && !Test.isRunningTest()) {
                throw new AuraHandledException('El vehiculo es requerido.');
            }

            if (prodList[0].Producto_Reservado__c) {
                throw new AuraHandledException('El vehiculo ya se encuentra reservado.');
            }

            if (prodList[0].RM_Reportado__c) {
                throw new AuraHandledException('El vehiculo no puede ser reservado ya que tiene el check de reportado.');
            }

            Http http = new Http();        
            HttpRequest request = new HttpRequest();
            AuthResponse authResponse = getAuth();
        
            request.setEndpoint(Label.URLSoftland + '/'+Label.AmbienteSoftland+'/softlandAPI/catalogs/addReceiptOportunity?json='+EncodingUtil.urlEncode('{"compania":"'+ pricebookname +'", "cod_anticipo": "'+identifier+'", "oportunidad": "'+oppList[0].Id_Oportunidad__c+'", "vin": "'+prodList[0].vin__c+'" }','UTF-8'));
            request.setHeader('Authorization', 'Bearer '+authResponse.access_token);            
            request.setMethod('GET');   
            HttpResponse response = http.send(request);
            String jsonString = response.getBody();
            
            String jsonrequest = '{"compania":"'+ pricebookname +'", "cod_anticipo": "'+identifier+'", "oportunidad": "'+oppList[0].Id_Oportunidad__c+'", "vin": "'+prodList[0].vin__c+'" }';
            
            String jsonrespuesta =    response.getBody();

            WSRelANTResult respuesta = (WSRelANTResult) JSON.deserialize(jsonString, WSRelANTResult.class);

            if (response.getStatusCode() == 200 && jsonString != null && respuesta != null && respuesta.operationResult != null) { 
                if (respuesta.operationResult.code != null && respuesta.operationResult.code == '00') {
                    
                    String compania = prodList[0].Empresa__c;
                    String VIN = prodList[0].vin__c;
                    String OppName =oppList[0].Name;
                    String ConsecutivoOpp = oppList[0].ConsecutivoOportunidad__c;
                    String Account = oppList[0].Account.Name; 
                    String codigoSoftland =  oppList[0].Account.codigoSoftland__c;
                    
                    String jsonString2 = '{' +
                        '"compania": "' + compania + '",' +
                        '"VIN": "' + VIN + '",' +
                        '"OppName": "' + OppName + '",' +
                        '"ConsecutivoOpp": "' + ConsecutivoOpp + '",' +
                        '"Account": "' + Account + '",' +
                        '"codigoSoftland": "' + codigoSoftland + '"' +
                    '}';
                    
                    System.debug(jsonString2);
                    
                    
                    //Http http = new Http();
                    HttpResponse res = new HttpResponse();
                    String token = ExternalAuthService.authenticate();
                    HttpRequest req = new HttpRequest();
                    req.setEndpoint(SERVICE_URL);
                    req.setMethod('POST');
                    req.setHeader('Authorization', 'Bearer ' + token);
                    req.setHeader('Content-Type', 'application/json');
                    req.setBody(jsonString);
                    res = new Http().send(req);
                    System.debug(res.getBody());
                    System.debug(jsonString);
                    
                    
                    
                    
                    Anticipo__c newAnticipo = new Anticipo__c(
                        Oportunidad__c = oppId,
                        Producto__c = productId,
                        Identificador__c = identifier,
                        Monto__c = monto,
                        Estatus__c = 'Aplicado'
                    );
                    insert newAnticipo;
                    if (newAnticipo.Id != null && !Test.isRunningTest()) {
                        ReservaOportunidadController.reservarVehiculo(oppId, productId);
                    }
                    
                    Log_servicios__c log3 = new Log_servicios__c();
                    log3.Llamada_servicio__c = 'http://172.176.136.132:5080/ServiciosSoftlandProductivos/softlandAPI/Catalogs/addVehiculeOpportunity';
                    log3.JSON_Enviado__c = jsonrequest;
                    log3.JSON_Respuesta__c = response.getBody();
                    log3.Oportunidad__c = oppId;
                    Insert log3;  
                    
                    
                    Log_servicios__c log2 = new Log_servicios__c();
                    log2.Llamada_servicio__c = '/softlandAPI/catalogs/addReceiptOportunity?json=';
                    log2.JSON_Enviado__c = jsonrequest;
                    log2.JSON_Respuesta__c = jsonrespuesta;
                    log2.Oportunidad__c = oppId;
                    Insert log2; 

                    responseMap.put('anticipoId', newAnticipo.Id);
                }else{
                    throw new AuraHandledException(respuesta.operationResult.description);
                }
            }else{
                throw new AuraHandledException('El servicio no respondio de manera correcta.');
            }            
        } catch (System.CalloutException e) {
            System.debug(e.getMessage());
            // throw new AuraHandledException(e.getMessage());
        }
        return responseMap;
    }

    public class WSRelANTResult {
        public WSRelacionaAnticipoRespuesta operationResult;
    }

    public class WSRelacionaAnticipoRespuesta{
        public String code;
        public String description;
    }

    public class WSOperationResult {
        public WSOperationResultValues operationResult;    
    }

    public class WSOperationResultValues{
        public Decimal monto_anticipo;
        public String oportunidad;
        public String code;
        public String cod_anticipo;
        public String description;
    }

    public static AuthResponse getAuth(){
        Http http = new Http();        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Label.URLSoftland+'/'+Label.ambienteSoftland+'/oauth/token');
        request.setBody('clientId='+Label.ClientIdSoftland+'&clientSecret='+Label.clientSecretSoftland+'&grant_type=password');
        request.setHeader('Content-Type', 'application/text');
        request.setMethod('GET');
        request.setTimeout(20000);
        
        HttpResponse response = http.send(request);

        return (AuthResponse) System.JSON.deserialize(response.getBody(), AuthResponse.class);
    }

    public class AuthResponse
    {
        public String access_token;
        public String token_type;
    }

    @AuraEnabled(cacheable=true)
    public static List<OpportunityLineItem> getOpportunityRelatedProductsUsados(String oppId){
        if (String.isEmpty(oppId)) {
            throw new AuraHandledException('El id de la oportunidad es requerido.');
        }
        try {            
            return [SELECT Id,Product2.Id,Product2.Name,Product2.Modelo_De_Inter_s__c,Product2.Marca__c,Product2.vin__c FROM OpportunityLineItem WHERE OpportunityId = :oppId  AND Product2.es_Vehiculo_usado__c = true AND Product2.Producto_Reservado__c = false ORDER BY Product2.Name];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }        
    }

    @AuraEnabled(cacheable=true)
    public static List<OpportunityLineItem> getOpportunityRelatedProducts(String oppId){
        if (String.isEmpty(oppId)) {
            throw new AuraHandledException('El id de la oportunidad es requerido.');
        }
        try {            
            return [SELECT Id,Product2.Id,Product2.Name,Product2.Modelo_De_Inter_s__c,Product2.Marca__c,Product2.vin__c FROM OpportunityLineItem WHERE OpportunityId = :oppId  AND Product2.esVehiculo__c = true AND Product2.Producto_Reservado__c = false ORDER BY Product2.Name];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }        
    }
    
    @AuraEnabled (cacheable=true)
    public static list<Anticipo__c> getAnticipos(String oppId){
        
        return [SELECT Id, Name, Identificador__c, Oportunidad__c, Estatus__c, Monto__c FROM Anticipo__c WHERE Oportunidad__c =: oppId];
    }

  
}