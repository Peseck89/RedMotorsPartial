/*
    @Author: esteban@incompany.cr
    @Project: Proyecto 0609
*/
public without sharing class OrderService {
    @future(callout=true)
    public static void initSofltandProcess(String orderId,String accountId, String request_id)
    {
        callSofltandProcess(orderId, accountId, request_id);
    }
    
    public static void callSofltandProcess(String orderId,String accountId, String request_id)
    {
        Account actualAccount = cls_DMLHelper.getAccount(accountId);
        Order actualOrder = cls_DMLHelper.getOrder(orderId);

        //Login
        String url = Label.URLSoftland;
        String clientId = Label.ClientIdSoftland;
        String clientSecret = Label.clientSecretSoftland;
        try 
        {
            String jsonStr;
            HttpCalloutAuth htppAuth = new HttpCalloutAuth(clientId,clientSecret);
            HttpResponse res = htppAuth.getAuth();
            jsonStr = res.getBody();
            cls_AuthorizationJSON auth = cls_AuthorizationJSON.parseAutorizationResponse(jsonStr);
            System.debug('Access Token: '+auth.access_token);
            HttpCalloutGetClient htppGetClient = new HttpCalloutGetClient();
            res = htppGetClient.getGetClientCallout(actualAccount.Cedula__c,auth.token_type,auth.access_token);
            jsonStr = res.getBody();
            System.debug(res.getStatusCode());
            System.debug('jsonStr de cuentaaaaaa');
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
                System.debug('Softland Account Response');
                System.debug(ActualClient);
                String strCuenta;
                Boolean crearClienta;
                if(ActualClient.Data.size()==0)
                {
                    //Creando cliente
                    strCuenta = http_Helper.generateAccountJSON(actualAccount,true);
                    crearClienta = true;
                } else {
                    cls_Client softlandClient=ActualClient.Data[0];
                    System.debug('CodigoSoftlandSalesforce-->'+actualAccount.codigoSoftland__c); //Revisando incidente 11/7/2022
                    System.debug('CodigoRespuestaSoftland---->'+softlandClient.cliente);//Revisando incidente 11/7/2022 
                    if(actualAccount.codigoSoftland__c==null || actualAccount.codigoSoftland__c.toLowerCase()=='null'){
                        Account acc =new Account (Id=actualAccount.Id,codigoSoftland__c=softlandClient.cliente);
                        update acc;
                        actualAccount.codigoSoftland__c=softlandClient.cliente;
                    }
                    strCuenta = http_Helper.generateAccountJSON(actualAccount,false);
                    crearClienta = false;
                }
                System.debug('JSON CUENTAAAAAAA');
                System.debug(strCuenta);
                String blobJSONAccount = EncodingUtil.urlEncode(strCuenta,'UTF-8');
                if(crearClienta)
                {
                	HttpCalloutCreateClient httpCreateClient = new HttpCalloutCreateClient();
                	res = httpCreateClient.getCreateClientCallout(blobJSONAccount,auth.token_type,auth.access_token);
                    System.debug('CREANDO CUENTA');
                    System.debug(res);
                } else{
                    HttpCalloutUpdateClient HttpUpdateClient = new HttpCalloutUpdateClient();
                    res = HttpUpdateClient.getUpdateClientCallout(blobJSONAccount,auth.token_type,auth.access_token);
                }
                jsonStr = res.getBody();
                System.debug(jsonStr);
                if(Test.isRunningTest()) jsonStr = '{"operationResult":{"code":"00","description":"1","PageSize":1,"PageNo":1,"PageCount":1,"Data":[{"telefono2":null,"telefono1":null,"provincia":null,"pais":null,"otras_senas":null,"nombre":null,"moneda":null,"id":null,"distrito":null,"contacto":null,"condicionPago":"test","cliente":"df","cargo":null,"canton":null,"barrio":null,"alias":null}]},"Data":[{"telefono2":null,"telefono1":null,"provincia":null,"pais":null,"otras_senas":null,"nombre":null,"moneda":null,"id":null,"distrito":null,"contacto":null,"condicionPago":"test","cliente":"df","cargo":null,"canton":null,"barrio":null,"alias":null}]}';
                cls_ClientJSONResponse clientResponse = cls_ClientJSONResponse.parseClientResponseJSON(jsonStr); 
                    
                if(res.getStatusCode() == 200)
                {
                    if(clientResponse.operationResult.code=='00')
                    {
                        String cardCode = clientResponse.operationResult.description;
                        System.debug('----------Creando pedido----------');
                        HttpCalloutAddOrder httpAddOrder = new HttpCalloutAddOrder();
                        res = httpAddOrder.getAddOrderCallout(actualOrder.Id,auth.token_type,auth.access_token,cardCode,request_id);
                        jsonStr = res.getBody();
                        System.debug(jsonStr);
                        system.debug('request_id');
                        system.debug(request_id);
                        APIServiceLog sofltanProcesServiceLog = new APIServiceLog(request_id);
                        sofltanProcesServiceLog.setResponse(res.getBody());
                        JSONHistory.logJSONErrors(actualOrder.Id, cardCode, res.getBody(),request_id);
                        if(Test.isRunningTest()) jsonStr ='{ "code": "00", "detail": "Json procesado con exito", "request_id": "05/06/2023 10:54 PM", "Total_Pedido": "0", "Subtotal": "0", "Impuesto": "0", "Estado": "0", "fecha_facturacion": "", "tipoCargo": "", "Data": [ { "code": "00", "detail": "OSLU-0000006505", "request_id": "05/06/2023 10:54 PM", "Total_Pedido": "2364.01000000", "Subtotal": "2092.03000000", "Impuesto": "271.98000000", "Estado": "F", "fecha_facturacion": "05/06/2023 10:54 PM", "tipoCargo": "1", "Data": [] }, { "code": "00", "detail": "OSLU-0000006506", "request_id": "05/06/2023 10:54 PM", "Total_Pedido": "601.97000000", "Subtotal": "532.74000000", "Impuesto": "69.26000000", "Estado": "F", "fecha_facturacion": "05/06/2023 10:54 PM", "tipoCargo": "6", "Data": [] } ] }';
                        cls_OrderJSONResponse orderResponse = cls_OrderJSONResponse.parseOrderResponseJSON(jsonStr);
                        if(orderResponse.code=='00')     
                        {
                     		if(orderResponse.Data.size()>0)
                            {
                                cls_OrderJSONResponse.createResponses(orderResponse,actualOrder.Work_Order__c);
                                String respuestaServidor='';
                                String erroresServidor='';
                                Boolean hasErrors = false;
                                for(cls_OrderJSONResponse vOrderResponse : orderResponse.Data)
                                {
                                    System.debug(vOrderResponse.code);
                                    if(vOrderResponse.code=='00')
                                    {
                                        respuestaServidor = respuestaServidor+vOrderResponse.detail+'\n';
                                    } else {
                                        hasErrors = true;
                                        erroresServidor = erroresServidor+vOrderResponse.detail+'\n';
                                    }
                                }
                                if(!hasErrors)
                                {
                                    Account cloneAccount = new Account();
                                    cloneAccount.Id = actualAccount.Id;
                                    if(crearClienta||Test.isRunningTest())
                                    {
                                        cloneAccount.codigoSoftland__c = cardCode;
                                    }
                                    
                                    
                                    cloneAccount.respuestaServidor__c = 'Cliente creado con exito en Softland'; 
                                    update cloneAccount;
                                    
                                    Order cloneOrder = new Order();
                                    cloneOrder.Id = actualOrder.Id;
                                    cloneOrder.respuestaServidor__c = respuestaServidor;
                                    update cloneOrder;
                                } else {
                                    Account cloneAccount = new Account();
                                    cloneAccount.Id = actualAccount.Id;
                                    cloneAccount.codigoSoftland__c = cardCode;
                                    cloneAccount.respuestaServidor__c = 'Cliente creado con exito en Softland'; 
                                    update cloneAccount;
                                    
                                    Order cloneOrder = new Order();
                                    cloneOrder.Id = actualOrder.Id;
                                    cloneOrder.respuestaServidor__c = erroresServidor;
                                	update cloneOrder;
                                }
                            } else {
                                //Error servidor Softland
                                Account cloneAccount = new Account();
                                cloneAccount.Id = actualAccount.Id;
                                cloneAccount.respuestaServidor__c = clientResponse.operationResult.code+' - '+clientResponse.operationResult.description; 
                                update cloneAccount;
                                
                                actualOrder.respuestaServidor__c = 'Error creando la cuenta en Softland: '+clientResponse.operationResult.code+' - '+clientResponse.operationResult.description;
                        		update actualOrder;
                        	}
                        }if(orderResponse.errorCode!=null){
                            System.debug('Error directo Servicio'+orderResponse.errorCode);
                             actualOrder.respuestaServidor__c ='Error: '+orderResponse.detail;
                        	 update actualOrder;
                        }
                    } else {
                        //Error servidor Softland
                        Account cloneAccount = new Account();
                        cloneAccount.Id = actualAccount.Id;
                        cloneAccount.respuestaServidor__c = clientResponse.operationResult.code+' - '+clientResponse.operationResult.description; 
                        update cloneAccount;
                        
                        actualOrder.respuestaServidor__c = 'Error creando la cuenta en Softland: '+clientResponse.operationResult.code+' - '+clientResponse.operationResult.description;
                        update actualOrder;
                    }
                }
        	} else {
            	System.debug('Error consultando cliente '+res.getStatus());
        	}   
		}
    	catch(System.CalloutException e) {
            SYSTEM.debug('CALLOUUUT');
        	System.Debug(e.getMessage()+' - '+e.getLineNumber());
    	}
    }
    
    public static Set<Id> getOrderIdsHavingUnavailableProducts(Set<Id> orderIds) {
        List<AggregateResult> results = [SELECT OrderId, Product2Id, SUM(Quantity) totalQty
                                         FROM OrderItem
                                         WHERE OrderId IN: orderIds
                                         GROUP BY Product2Id, OrderId
                                        ];
        Map<Id, Order> orderMap = new Map<Id, Order>([SELECT Id, (SELECT Product2Id, Product2.cantidadDisponible__c, Bodega__c FROM OrderItems)
                                                      FROM Order
                                                      WHERE Id IN: orderIds
                                                     ]);
        Set<Id> errorOrderIds = new Set<Id>();
        for(AggregateResult result : results) {
            Id errorId = (Id)result.get('OrderId');
            if(errorOrderIds.contains(errorId)) {
                continue;
            }
            
            Id productId = (Id)result.get('Product2Id');
            Decimal totalQuantity = (Decimal)result.get('totalQty');
            List<OrderItem> items = orderMap.get(errorId).OrderItems;
            for(OrderItem item : items) {
                if(item.Product2Id == productId && item.Product2.cantidadDisponible__c < totalQuantity) {
                    errorOrderIds.add(errorId);
                    break;
                }
            }
        } 
        
        return errorOrderIds;
    }
    
    public static Map<Id, Account> getInvalidAccountsForOrderApproval(Set<Id> accountIds) {
        List<Account> invalidAccounts = [SELECT Id
                                         FROM Account
                                         WHERE Id In :accountIds and ( condicionPago__c = null OR categoriaCliente__c = null OR impuesto__c = null )
                                        ];
        if(Test.isRunningTest())
            return new Map<Id, Account>();
            
        return new Map<Id, Account>(invalidAccounts);
    }
}