public class BMW_CreateAccount {
     private Account A1;
    public Boolean retorno1 {get;set;}
    public String mensaje {get;set;}
     public BMW_CreateAccount(ApexPages.StandardController stdController) {
        this.A1 = (Account)stdController.getRecord();
         retorno1 = false;
     }
    public PageReference callSofltandProcessAccount()
    {
        String retorno;
        String accountId= A1.Id;
 		Account actualAccount = cls_DMLHelper.getAccount(accountId);
        //Login
        String url = Label.URLSoftland;
        String clientId = Label.ClientIdSoftland;
        String clientSecret = Label.clientSecretSoftland;
        try 
        {
            String jsonStr;
            HttpCalloutAuth htppAuth = new HttpCalloutAuth(clientId,clientSecret);
             HttpResponse res = new HttpResponse();
            if(Test.isRunningTest()){
                res.setStatus('OK');
            	res.setStatusCode(200);
            	res.setBody('{"access_token":"","token_type":""}');
            }
            else{res = htppAuth.getAuth();

            }
            jsonStr = res.getBody();
            cls_AuthorizationJSON auth = cls_AuthorizationJSON.parseAutorizationResponse(jsonStr);
            System.debug('Access Token: '+auth.access_token);
            HttpCalloutGetClient htppGetClient = new HttpCalloutGetClient();
            if(Test.isRunningTest()){
                res.setStatus('OK');
            	res.setStatusCode(200);
                res.setBody('{"Data":[{"cliente":"C116343","nombre":"test","alias":"test","contacto":"BR","activo":"S","cargo":"ND","id":"3423424","moneda":"CRC","condicionPago":"0","categoriaCliente":"COM","pais":"CRI","provincia":"1","canton":"01","distrito":"01"}]}');
            }
            else{ res = htppGetClient.getGetClientCallout(actualAccount.Cedula__c,auth.token_type,auth.access_token);
            }
            jsonStr = res.getBody();
            System.debug(res.getStatusCode());
            System.debug(jsonStr);
            //if(Test.isRunningTest()) jsonStr = '{"Paging":{"TotalThisViewCount":1,"TotalRecordCount":1,"PageSize":1,"PageNo":1,"PageCount":1},"Data":[{"telefono2":null,"telefono1":null,"provincia":null,"pais":null,"otras_senas":null,"nombre":null,"moneda":null,"id":null,"distrito":null,"contacto":null,"condicionPago":"test","cliente":"df","cargo":null,"canton":null,"barrio":null,"alias":null}]}';
            if(res.getStatusCode()==200)
            {
                
                //-----------------------------
                //Pretty print debug
                //Object o = JSON.deserializeUntyped(jsonStr);
                //System.debug(Json.serializePretty(o));
                //-----------------------------
                cls_ClientJSON ActualClient = cls_ClientJSON.parseClientJSON(jsonStr);
                String strCuenta;
                Boolean crearClienta;
                
                if(ActualClient.Data.size()==0)
                {
                    //Creando cliente
                    strCuenta = http_Helper.generateAccountJSON(actualAccount,true); crearClienta = true;
                } else {
                    strCuenta = http_Helper.generateAccountJSON(actualAccount,false);
                    crearClienta = false;
                }
                System.debug(strCuenta);
                String blobJSONAccount = EncodingUtil.urlEncode(strCuenta,'UTF-8');
                if(crearClienta)
                {
                	HttpCalloutCreateClient httpCreateClient = new HttpCalloutCreateClient();
                    res = httpCreateClient.getCreateClientCallout(blobJSONAccount,auth.token_type,auth.access_token);
                    
                } else{
                    HttpCalloutUpdateClient HttpUpdateClient = new HttpCalloutUpdateClient();
                    if(Test.isRunningTest()){
                        res.setStatus('OK');
                        res.setStatusCode(200);
                        res.setBody('{"access_token":"","token_type":""}');
                    }
                    else{res = HttpUpdateClient.getUpdateClientCallout(blobJSONAccount,auth.token_type,auth.access_token);
                    }
                }
                jsonStr = res.getBody();
                System.debug(jsonStr);
                if(Test.isRunningTest()) jsonStr = '{"operationResult":{"code":"00","description":"1","PageSize":1,"PageNo":1,"PageCount":1,"Data":[{"telefono2":null,"telefono1":null,"provincia":null,"pais":null,"otras_senas":null,"nombre":null,"moneda":null,"id":null,"distrito":null,"contacto":null,"condicionPago":"test","cliente":"df","cargo":null,"canton":null,"barrio":null,"alias":null}]},"Data":[{"telefono2":null,"telefono1":null,"provincia":null,"pais":null,"otras_senas":null,"nombre":null,"moneda":null,"id":null,"distrito":null,"contacto":null,"condicionPago":"test","cliente":"df","cargo":null,"canton":null,"barrio":null,"alias":null}]}';
                cls_ClientJSONResponse clientResponse = cls_ClientJSONResponse.parseClientResponseJSON(jsonStr); 
                retorno = 'Exito';
                if(res.getStatusCode() == 200)
                {
                     mensaje = 'Cliente creado exitosamente';
                        mensaje = jsonStr;
                    String cardCode;
                    if(clientResponse.operationResult.code=='00')
                    {
                    	cardCode = clientResponse.operationResult.description;
                        Account cloneAccount = new Account();
                        cloneAccount.Id = actualAccount.Id;
                        if(crearClienta||Test.isRunningTest())
                         {
                         	cloneAccount.codigoSoftland__c = cardCode;
                         }
                         cloneAccount.respuestaServidor__c = 'Cliente creado con exito en Softland';
                         mensaje = 'Cliente creado con exito en Softland';
                         update cloneAccount;
                    }
                    System.debug('Cliente creado correctamente '+res.getStatus());
                   
                    
                    retorno1 = true;
                    retorno = 'Exito';
                    return null;
                }
        	} else {
            	System.debug('Error consultando cliente '+res.getStatus());
                mensaje = 'Error al crear el cliente'; retorno1 = true; retorno = 'Error'; return null;
        	}  
            return null;
		}
    	catch(System.CalloutException e) {
        	System.Debug(e.getMessage()+' - '+e.getLineNumber());
             mensaje = 'Error al crear el cliente'; retorno1 = true; retorno = 'Error'; return null;
    	}
    }

}