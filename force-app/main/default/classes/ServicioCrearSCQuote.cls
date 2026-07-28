public class ServicioCrearSCQuote {
    //private static final String SERVICE_URL = 'http://172.176.136.132:5080/IntegrationServices/softlandAPI/Purchase/OrderRequest';
    private static final String SERVICE_URL = 'http://172.176.136.132:5080/ServiciosSoftlandProductivos/softlandAPI/Purchase/OrderRequest';
    // Método para crear la solicitud de compra, recibiendo el número de cotización
    public static string crearSolicitudCompra(String quoteNumber, String departamento, String prioridad, String anticipo, List<String> idsToSC) {
        // Obtener la cotización y las líneas de la cotización
        Quote quote = [SELECT Id,AccountId,Opportunity.Owner.Email, Opportunity.BMW_TallerDeServicio__r.Name ,Opportunity.Owner.Name,Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDeChasis__c,quote.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDePlaca__c, Adjunto_Solicitud_Compra__c,OpportunityId,Quote_Number__c, Opportunity.Id_Oportunidad__c,Opportunity.Account.codigoSoftland__c,Opportunity.Opportunity_ID__c ,Opportunity.Sucursal__c, Opportunity.Empresa_Operadora__c, Opportunity.BMW_Compania__c FROM Quote WHERE Id = :quoteNumber LIMIT 1];
        List<QuoteLineItem> quoteLineItems = [SELECT Codigo_producto__c, Quantity, Description, UnitPrice, BMW_Bodega__r.Name FROM QuoteLineItem WHERE QuoteId = :quote.Id AND Id IN :idsToSC];
		
        String empresa = resolveCompanyCode(quote);
        validateSupportedCompany(empresa);

        String url = Label.URLSoftland;
        String clientId = Label.ClientIdSoftland;
        String clientSecret = Label.clientSecretSoftland;
        Account accToUpdate;
        Boolean shouldUpdateAccount = false;
        try{

            Quote wo =  quote;
            Account actualAccount = cls_DMLHelper.getAccount(wo.AccountId);
            //Account actualAccount = cls_DMLHelper.getAccount(wo.AccountId);

            String jsonStr;
            HttpCalloutAuth htppAuth = new HttpCalloutAuth(clientId,clientSecret);
            HttpResponse res = htppAuth.getAuth();
            jsonStr = res.getBody();
            cls_AuthorizationJSON auth = cls_AuthorizationJSON.parseAutorizationResponse(jsonStr);
            System.debug('Access Token: '+auth.access_token);
            HttpCalloutGetClient htppGetClient = new HttpCalloutGetClient();
            res = htppGetClient.getGetClientCallout(actualAccount.Cedula__c, auth.token_type, auth.access_token);
            jsonStr = res.getBody();
            System.debug(res.getStatusCode());
            System.debug('jsonStr de cuentaaaaaa');
            System.debug(jsonStr);

            

            if(res.getStatusCode()==200)
            {
                cls_ClientJSON ActualClient = cls_ClientJSON.parseClientJSON(jsonStr);
                System.debug('Softland Account Response');
                cls_Client softlandClient;
                System.debug(ActualClient);
                String strCuenta;
                Boolean crearClienta;
                if(ActualClient.Data.size()==0)
                {
                    //Creando cliente
                    strCuenta = http_Helper.generateAccountJSON(actualAccount,true);
                    crearClienta = true;
                } else {
                    softlandClient=ActualClient.Data[0];
                    System.debug('CodigoSoftlandSalesforce-->'+actualAccount.codigoSoftland__c); 
                    System.debug('CodigoRespuestaSoftland---->'+softlandClient.cliente); 
                    
                    strCuenta = http_Helper.generateAccountJSON(actualAccount,false);
                    crearClienta = false;
                }
                System.debug('JSON CUENTAAAAAAA');
                System.debug(strCuenta);
                String blobJSONAccount = EncodingUtil.urlEncode(strCuenta,'UTF-8');
                if(crearClienta)
                {
                	HttpCalloutCreateClient httpCreateClient = new HttpCalloutCreateClient();
                	res = httpCreateClient.getCreateClientCallout(blobJSONAccount, auth.token_type, auth.access_token);
                    System.debug('CREANDO CUENTA');
                    System.debug(res);
                } else{
                    HttpCalloutUpdateClient HttpUpdateClient = new HttpCalloutUpdateClient();
                    res = HttpUpdateClient.getUpdateClientCallout(blobJSONAccount, auth.token_type, auth.access_token);
                }
                jsonStr = res.getBody();
                System.debug(jsonStr);
                cls_ClientJSONResponse clientResponse = cls_ClientJSONResponse.parseClientResponseJSON(jsonStr); 
                if(actualAccount.codigoSoftland__c==null || actualAccount.codigoSoftland__c.toLowerCase()=='null'){
                        if(softlandClient != null && String.valueOf(softlandClient.cliente).toLowerCase()!='null'){
                            accToUpdate = new Account (Id=actualAccount.Id,codigoSoftland__c=softlandClient.cliente);
                            shouldUpdateAccount = true;
                        }
                }  
            }
            else{
            	System.debug('Error consultando cliente '+res.getStatus());
        	} 
        }
        catch(System.CalloutException e) {
            SYSTEM.debug('CallOut Error! ');
        	System.Debug(e.getMessage()+' - '+e.getLineNumber());
    	}
        
        
        string prioridadTransporte = '';
        
        if(prioridad == 'Aereo'){
            prioridadTransporte = 'aereo';
        }else if (prioridad == 'Maritimo') {
        	prioridadTransporte = 'maritimo';
        }else if (prioridad == 'VOR') {
        	prioridadTransporte = 'vor';
        }
        
        
        // Preparar los datos para el JSON de solicitud
        List<Map<String, Object>> articulos = new List<Map<String, Object>>();
        for (QuoteLineItem item : quoteLineItems) {
            articulos.add(new Map<String, Object>{
                'cantidad' => String.valueOf(item.Quantity),
                'articulo' => item.Codigo_producto__c,
                'bodega' => item.BMW_Bodega__r.Name, // Ejemplo de bodega, cambiar según lógica
                'id_linea' => item.Id
            });
        }
        WoliGridQueryService consultaArchivos = new WoliGridQueryService(quote.Id, true);
		
        
        List<String> listaarchivos = new List<String>();
		listaarchivos = consultaArchivos.getFileUrlsFromQuote();
        
        
        // Archivos
        List<Map<String, Object>> archivos = new List<Map<String, Object>>();
        for (String item : listaarchivos) {
            archivos.add(new Map<String, Object>{
                'archivo' => String.valueOf(item)
            });
        }
        
        Map<String, Object> requestBody = new Map<String, Object>{
            'articulos' => articulos,
            'sucursal' => quote.Opportunity.BMW_TallerDeServicio__r.Name,
            'oportunidad' => quote.Opportunity.Id_Oportunidad__c ,//quote.OpportunityId ,
            'quote_salesforce' => quote.Quote_Number__c ,
            'cliente' => quote.Opportunity.Account.codigoSoftland__c != null && quote.Opportunity.Account.codigoSoftland__c != ''  ? quote.Opportunity.Account.codigoSoftland__c : accToUpdate.codigoSoftland__c, 
            'departamento' => departamento, 
            'prioridad' => prioridadTransporte, 
            'anticipo' => anticipo, 
            'url-adjunto' => archivos,
            'vin' => quote.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDeChasis__c,
            'placa' => quote.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDePlaca__c,
            'asesorServicio' => quote.Opportunity.Owner.Name, //Mapear este campo
            'vendedor' => quote.Opportunity.Owner.Email, //Mapear este campo
            'compania' => empresa 
        };
            
		System.debug('Consulta : ' + JSON.serialize(requestBody));
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(SERVICE_URL);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(requestBody));
        req.setTimeout(120000);

        // Enviar la solicitud y manejar la respuesta
        HttpResponse res = new Http().send(req);
        
        System.debug('Respuesta ' + res);

        if (res.getStatusCode() == 200) {
            System.debug('Respuesta exitosa: ' + res.getBody());
            
            String responseBody = res.getBody();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            Map<String, Object> operationResult = (Map<String, Object>) responseMap.get('operationResult');
            String description = (String) operationResult.get('description');
            String codigo = (String) operationResult.get('code');

            List<QuoteLineItem> articulosActualizar = new List<QuoteLineItem>();
            
            System.debug('Quote Items: ' + quoteLineItems);
            
            for (QuoteLineItem item : quoteLineItems) {
                item.Estado_Solicitud_Compra__c= 'Ingresada';
                item.Identificador_solicitud_de_compra__c= description;
                articulosActualizar.add(item);
            }
            
            consultaArchivos.updateDocsAsSend();
            
            Update articulosActualizar;
            
            if (shouldUpdateAccount && accToUpdate != null) {
                update accToUpdate;
            }
            
            if (codigo == '00') {
            	return '00';
            }else if (codigo == '01'){
                return '01';
            }else{
                return 'error';
            }
            
            
        } else {
            // Manejar errores
            System.debug('Error en la respuesta: ' + res.getBody());
            if (shouldUpdateAccount && accToUpdate != null) {
                update accToUpdate;
            }
            return 'error';
        }
        
        
        
        
        
        
    } 

    private static String resolveCompanyCode(Quote quote) {
        try {
            if (quote.Opportunity.Empresa_Operadora__c != null) {
                return EmpresaResolver.resolve(quote.Opportunity.Empresa_Operadora__c).codigo;
            }
        } catch (EmpresaConfigurationException e) {
            throw new AuraHandledException(e.getMessage());
        }

        String legacyCompany = quote.Opportunity.BMW_Compania__c;
        if (String.isBlank(legacyCompany)) {
            throw new AuraHandledException('No existe empresa configurada para crear la solicitud de compra.');
        }

        String normalizedCompany = legacyCompany.trim().toUpperCase();
        if (normalizedCompany == 'BAVARIAN' || normalizedCompany == 'RMBAVARIAN') {
            return 'RMBAVARIAN';
        }
        if (normalizedCompany == 'OTOBAI' || normalizedCompany == 'RMOTOBAI') {
            return 'RMOTOBAI';
        }
        if (normalizedCompany == 'RMPEKING') {
            return 'RMPEKING';
        }

        throw new AuraHandledException('Empresa no soportada para crear la solicitud de compra.');
    }

    private static void validateSupportedCompany(String companyCode) {
        if (companyCode == 'RMBAVARIAN' || companyCode == 'RMOTOBAI') {
            return;
        }
        if (companyCode == 'RMPEKING') {
            throw new AuraHandledException('RMPEKING no tiene configuración externa confirmada para crear solicitud de compra de Quote.');
        }
        throw new AuraHandledException('Empresa no soportada para crear la solicitud de compra.');
    }

    
    
}
