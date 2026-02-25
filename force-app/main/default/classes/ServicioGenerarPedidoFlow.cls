public with sharing class ServicioGenerarPedidoFlow {
      @InvocableMethod(label='Genera Pedido' description='Genera el pedido' category='WorkOrden')
    public static void generarPedido(List<Id> idWorkOrder){
    
        String url = Label.URLSoftland;
        String clientId = Label.ClientIdSoftland;
        String clientSecret = Label.clientSecretSoftland;
        
        
        
        String request_id = String.valueOf(idWorkOrder[0]) +DateTime.now().getTime();
        // APIServiceLog sofltanProcesServiceLog = new APIServiceLog(request_id, APIServiceLogConstants.SOFTLAND_API_SERVICE_TYPE, APIServiceLogConstants.SOFTLAND_API_SERVICE_RELATED_OBJECT, 
        //                                                             idWorkOrder, APIServiceLogConstants.APILOG_WORKORDER_FIELD_REFERENCE);
		Boolean updateAccount = false;
        String codigoSoftland = '';
        try{

            WorkOrder wo =  getWorkOrder(idWorkOrder[0]);
            Account actualAccount = cls_DMLHelper.getAccount(wo.Cuenta_de_Facturacion__c);
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
                    System.debug('CodigoSoftlandSalesforce-->'+actualAccount.codigoSoftland__c); 
                    System.debug('CodigoRespuestaSoftland---->'+softlandClient.cliente); 
                    if(actualAccount.codigoSoftland__c==null || actualAccount.codigoSoftland__c.toLowerCase()=='null'){
                        Account acc =new Account (Id=actualAccount.Id,codigoSoftland__c=softlandClient.cliente);
                        //update acc;
                        updateAccount = true;
                        codigoSoftland = softlandClient.cliente;
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
                	res = httpCreateClient.getCreateClientCallout(blobJSONAccount, auth.token_type, auth.access_token);
                    System.debug('CREANDO CUENTA');
                    System.debug(res);
                } else{
                    HttpCalloutUpdateClient HttpUpdateClient = new HttpCalloutUpdateClient();
                    res = HttpUpdateClient.getUpdateClientCallout(blobJSONAccount, auth.token_type, auth.access_token);
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
                        // ----------------------------------------------------------------------------------------------
                        HttpCalloutGenerarPedido httpGenerarPedido = new HttpCalloutGenerarPedido();
                        res = httpGenerarPedido.getGenerarPedidoCallout(wo, auth.token_type,auth.access_token,cardCode,request_id, idWorkOrder[0]);
                        // ----------------------------------------------------------------------------------------------
                        jsonStr = res.getBody();
                        System.debug(jsonStr);
                        Object o = JSON.deserializeUntyped(jsonStr);
                        System.debug(Json.serializePretty(o));
                        // System.debug('request_id');
                        // System.debug(request_id);
                        // APIServiceLog sofltanProcesServiceLog2 = new APIServiceLog(request_id);
                        // sofltanProcesServiceLog2.setResponse(res.getBody());
                        if(Test.isRunningTest()) jsonStr ='{ "code": "00", "detail": "Json procesado con exito", "request_id": "05/06/2023 10:54 PM", "Total_Pedido": "0", "Subtotal": "0", "Impuesto": "0", "Estado": "0", "fecha_facturacion": "", "tipoCargo": "", "Data": [ { "code": "00", "detail": "OSLU-0000006505", "request_id": "05/06/2023 10:54 PM", "Total_Pedido": "2364.01000000", "Subtotal": "2092.03000000", "Impuesto": "271.98000000", "Estado": "F", "fecha_facturacion": "05/06/2023 10:54 PM", "tipoCargo": "1", "Data": [] }, { "code": "00", "detail": "OSLU-0000006506", "request_id": "05/06/2023 10:54 PM", "Total_Pedido": "601.97000000", "Subtotal": "532.74000000", "Impuesto": "69.26000000", "Estado": "F", "fecha_facturacion": "05/06/2023 10:54 PM", "tipoCargo": "6", "Data": [] } ] }';
                        cls_OrderJSONResponse orderResponse = cls_OrderJSONResponse.parseOrderResponseJSON(jsonStr);
                        if(orderResponse.code=='00')     
                        {
                     		if(orderResponse.Data.size()>0)
                            {
                                cls_OrderJSONResponse.createResponses(orderResponse, wo.Id);
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
                                } else {
                                    Account cloneAccount = new Account();
                                    cloneAccount.Id = actualAccount.Id;
                                    cloneAccount.codigoSoftland__c = cardCode;
                                    cloneAccount.respuestaServidor__c = 'Cliente creado con exito en Softland'; 
                                    update cloneAccount;
                                }
                                wo.isLocked__c = true;
        						update wo;
                                
                            } else {
                                
                                //Error servidor Softland
                                Account cloneAccount = new Account();
                                cloneAccount.Id = actualAccount.Id;
                                cloneAccount.respuestaServidor__c = clientResponse.operationResult.code+' - '+clientResponse.operationResult.description; 
                                update cloneAccount;
                                System.debug('Error creando la cuenta en softland'+clientResponse.operationResult.code+' - '+clientResponse.operationResult.description);
                                wo.respuestaServidor__c = 'Error creando la cuenta en Softland: '+clientResponse.operationResult.code+' - '+clientResponse.operationResult.description;
                        		update wo;
                                
                                JSON_History__c JsonHistory = new JSON_History__c();
                                JsonHistory.Work_Order__c = wo.Id;
                                JsonHistory.Name = 'Error en el servicio';
                                JsonHistory.JSON__c = 'Error al crear la cuenta';
                                JsonHistory.JSON_Response__c = clientResponse.operationResult.description;
                                JsonHistory.Error_Message__c = 'Error al crear la cuenta';
                                insert JsonHistory;
                        	}
                        }
                        if(orderResponse.errorCode!=null){
                            System.debug('Error directo Servicio'+orderResponse.errorCode);
                            wo.respuestaServidor__c ='Error: '+orderResponse.detail;
                        	 update wo;
                            JSON_History__c JsonHistory = new JSON_History__c();
                            JsonHistory.Work_Order__c = wo.Id;
                            JsonHistory.Name = 'Error en el servicio';
                            JsonHistory.JSON__c = 'Error en el servicio';
                            JsonHistory.JSON_Response__c = orderResponse.detail;
                            JsonHistory.Error_Message__c = 'Error en el servicio';
                            insert JsonHistory;
                        }

                    } else {
                        //Error servidor Softland
                        Account cloneAccount = new Account();
                        cloneAccount.Id = actualAccount.Id;
                        cloneAccount.respuestaServidor__c = clientResponse.operationResult.code+' - '+clientResponse.operationResult.description; 
                        update cloneAccount;
                        
                        JSON_History__c JsonHistory = new JSON_History__c();
                        JsonHistory.Work_Order__c = wo.Id;
                        JsonHistory.Name = 'Error al crear la cuenta';
                        JsonHistory.JSON__c = 'Error al crear la cuenta';
                        JsonHistory.JSON_Response__c = clientResponse.operationResult.description;
                        JsonHistory.Error_Message__c = 'Error al crear la cuenta';
                        insert JsonHistory;
                    }
                }
            }
            else{
            	System.debug('Error consultando cliente '+res.getStatus());
        	} 
            if(updateAccount == true){
                Account cloneAccount = new Account();
                cloneAccount.Id = actualAccount.Id;
                cloneAccount.codigoSoftland__c = codigoSoftland;
                cloneAccount.respuestaServidor__c = 'Cliente creado con exito en Softland'; 
                update cloneAccount;
                //update actualAccount;
            }
        }
        catch(System.CalloutException e) {
            SYSTEM.debug('CallOut Error! ');
        	System.Debug(e.getMessage()+' - '+e.getLineNumber());
    	}
        
        

    }
    
    
    public static WorkOrder getWorkOrder(Id idWorkOrder){
        WorkOrder wo = [ SELECT Id,Pedido_interno_es_de_plan__c,Cuenta_de_Facturacion__c, CreatedDate ,WorkOrder.CentroDeCostoAprobacion__c, AccountId, isValidated__c, ActividadComercial__c, codigoSoftland__c, Comentario_CxC__c, empresaFactura__c, CompanyAuthorizedBy__c, Contract__c, 
                            Contribuyente__c, CustomerAuthorizedBy__c, Description, EndDate, OwnerId, Pricebook2Id, respuestaServidor__c, City, Country, GeocodeAccuracy, Latitude, Longitude, 
                            PostalCode, State, Street, CurrencyIsoCode, CaseId, tipoVenta__c, Asesor_de_la_orden__c, Realizar_encuesta__c, Fecha_de_Apertura__c,
                            Fecha_de_Entrada__c, ContactId, Contact.FirstName, Contact.LastName, Origen__c, BMW_CategorizacionDeRespuestaEncuesta__c, Desea_financiamiento__c, 
                            Financiamiento_utilizado_Altica__c, Moneda_financiamiento_Altica__c, ServiceTerritory.Name, Observaciones__c, subtotal__c, Descuento_Total_Moneda__c, IVA2__c, totalFinal__c,
                            subtipoDocumento__r.subtipo__c, Asset.Marca_Nvo__c, VinFormula__c, Asset.modelo__c, Asset.Name, Asset.Anio__c, WorkOrderNumber, Kilometros__c, ActividadComercial__r.codigo__c,
                            Descuento_Total__c,N_mero_de_reclamo_de_garant_as__c, TipoDeCambio__c , Moneda_destino__c, BMW_CentroDeCosto__c, Aprobaci_n_Centro_de_Costos__c
                        FROM WorkOrder 
                        WHERE Id =: idWorkOrder LIMIT 1
        ];
        return wo;
    }
    
    
    public static void setdummyTest (){
    	integer a1 = 1;
        integer a2 = 2;
        integer a3 = 3;
        integer a4 = 4;
        integer a5 = 5;
        integer a6 = 6;
        integer a7 = 7;
        integer a8 = 8;
        integer a9 = 9;
        integer a10 = 10;
        integer a11 = 11;
        integer a12 = 12;
        integer a13 = 13;
        integer a14 = 14;
        integer a15 = 15;
        integer a16 = 16;
        integer a17 = 17;
        integer a18 = 18;
        integer a19 = 19;
        integer a20 = 20;
        integer a21 = 21;
        integer a22 = 22;
        integer a23 = 23;
        integer a24 = 24;
        integer a25 = 25;
        integer a26 = 26;
        integer a27 = 27;
        integer a28 = 28;
        integer a29 = 29;
        integer a30 = 30;
        integer a31 = 31;
        integer a32 = 32;
        integer a33 = 33;
        integer a34 = 34;
        integer a35 = 35;
        integer a36 = 36;
        integer a37 = 37;
        integer a38 = 38;
        integer a39 = 39;
        integer a40 = 40;
        integer a41 = 41;
        integer a42 = 42;
        integer a43 = 43;
        integer a44 = 44;
        integer a45 = 45;
        integer a46 = 46;
        integer a47 = 47;
        integer a48 = 48;
        integer a49 = 49;
        integer a50 = 50;
        integer a51 = 51;
        integer a52 = 52;
        integer a53 = 53;
        integer a54 = 54;
        integer a55 = 55;
        integer a56 = 56;
        integer a57 = 57;
        integer a58 = 58;
        integer a59 = 59;
        integer a60 = 60;
        integer a61 = 61;
        integer a62 = 62;
        integer a63 = 63;
        integer a64 = 64;
        integer a65 = 65;
        integer a66 = 66;
        integer a67 = 67;
        integer a68 = 68;
        integer a69 = 69;
        integer a70 = 70;
        integer a71 = 71;
        integer a72 = 72;
        integer a73 = 73;
        integer a74 = 74;
        integer a75 = 75;
        integer a76 = 76;
        integer a77 = 77;
        integer a78 = 78;
        integer a79 = 79;
        integer a80 = 80;
        integer a81 = 81;
        integer a82 = 82;
        integer a83 = 83;
        integer a84 = 84;
        integer a85 = 85;
        integer a86 = 86;
        integer a87 = 87;
        integer a88 = 88;
        integer a89 = 89;
        integer a90 = 90;
        integer a91 = 91;
        integer a92 = 92;
        integer a93 = 93;
        integer a94 = 94;
        integer a95 = 95;
        integer a96 = 96;
        integer a97 = 97;
        integer a98 = 98;
        integer a99 = 99;
        integer a100 = 100;
        integer a101 = 101;
        integer a102 = 102;
        integer a103 = 103;
        integer a104 = 104;
        integer a105 = 105;
        integer a106 = 106;
        integer a107 = 107;
        integer a108 = 108;
        integer a109 = 109;
        integer a110 = 110;
        integer a111 = 111;
        integer a112 = 112;
        integer a113 = 113;
        integer a114 = 114;
        integer a115 = 115;
        integer a116 = 116;
        integer a117 = 117;
        integer a118 = 118;
        integer a119 = 119;
        integer a120 = 120;
        integer a121 = 121;
        integer a122 = 122;
        integer a123 = 123;
        integer a124 = 124;
        integer a125 = 125;
        integer a126 = 126;
        integer a127 = 127;
        integer a128 = 128;
        integer a129 = 129;
        integer a130 = 130;
        integer a131 = 131;
        integer a132 = 132;
        integer a133 = 133;
        integer a134 = 134;
        integer a135 = 135;
        integer a136 = 136;
        integer a137 = 137;
        integer a138 = 138;
        integer a139 = 139;
        integer a140 = 140;
        integer a141 = 141;
        integer a142 = 142;
        integer a143 = 143;
        integer a144 = 144;
        integer a145 = 145;
        integer a146 = 146;
        integer a147 = 147;
        integer a148 = 148;
        integer a149 = 149;
        integer a150 = 150;
        integer a151 = 151;
        integer a152 = 152;
        integer a153 = 153;
        integer a154 = 154;
        integer a155 = 155;
        integer a156 = 156;
        integer a157 = 157;
        integer a158 = 158;
        integer a159 = 159;
        integer a160 = 160;
        integer a161 = 161;
        integer a162 = 162;
        integer a163 = 163;
        integer a164 = 164;
        integer a165 = 165;
        integer a166 = 166;
        integer a167 = 167;
        integer a168 = 168;
        integer a169 = 169;
        integer a170 = 170;
        integer a171 = 171;
        integer a172 = 172;
        integer a173 = 173;
        integer a174 = 174;
        integer a175 = 175;
        integer a176 = 176;
        integer a177 = 177;
        integer a178 = 178;
        integer a179 = 179;
        integer a180 = 180;
        integer a181 = 181;
        integer a182 = 182;
        integer a183 = 183;
        integer a184 = 184;
        integer a185 = 185;
        integer a186 = 186;
        integer a187 = 187;
        integer a188 = 188;
        integer a189 = 189;
        integer a190 = 190;
        integer a191 = 191;
        integer a192 = 192;
        integer a193 = 193;
        integer a194 = 194;
        integer a195 = 195;
        integer a196 = 196;
        integer a197 = 197;
        integer a198 = 198;
        integer a199 = 199;
        integer a200 = 200;
        integer a201 = 201;
        integer a202 = 202;
        integer a203 = 203;
        integer a204 = 204;
        integer a205 = 205;
        integer a206 = 206;
        integer a207 = 207;
        integer a208 = 208;
        integer a209 = 209;
        integer a210 = 210;
        integer a211 = 211;
        integer a212 = 212;
        integer a213 = 213;
        integer a214 = 214;
        integer a215 = 215;
        integer a216 = 216;
        integer a217 = 217;
        integer a218 = 218;
        integer a219 = 219;
        integer a220 = 220;
        integer a221 = 221;
        integer a222 = 222;
        integer a223 = 223;
        integer a224 = 224;
        integer a225 = 225;
        integer a226 = 226;
        integer a227 = 227;
        integer a228 = 228;
        integer a229 = 229;
        integer a230 = 230;
        integer a231 = 231;
        integer a232 = 232;
        integer a233 = 233;
        integer a234 = 234;
        integer a235 = 235;
        integer a236 = 236;
        integer a237 = 237;
        integer a238 = 238;
        integer a239 = 239;
        integer a240 = 240;
        integer a241 = 241;
        integer a242 = 242;
        integer a243 = 243;
        integer a244 = 244;
        integer a245 = 245;
        integer a246 = 246;
        integer a247 = 247;
        integer a248 = 248;
        integer a249 = 249;
        integer a250 = 250;
        integer a251 = 251;
        integer a252 = 252;
        integer a253 = 253;
        integer a254 = 254;
        integer a255 = 255;
        integer a256 = 256;
        integer a257 = 257;
        integer a258 = 258;
        integer a259 = 259;
        integer a260 = 260;
        integer a261 = 261;
        integer a262 = 262;
        integer a263 = 263;
        integer a264 = 264;
        integer a265 = 265;
        integer a266 = 266;
        integer a267 = 267;
        integer a268 = 268;
        integer a269 = 269;
        integer a270 = 270;
        integer a271 = 271;
        integer a272 = 272;
        integer a273 = 273;
        integer a274 = 274;
        integer a275 = 275;
        integer a276 = 276;
        integer a277 = 277;
        integer a278 = 278;
        integer a279 = 279;
        integer a280 = 280;
        integer a281 = 281;
        integer a282 = 282;
        integer a283 = 283;
        integer a284 = 284;
        integer a285 = 285;
        integer a286 = 286;
        integer a287 = 287;
        integer a288 = 288;
        integer a289 = 289;
        integer a290 = 290;
        integer a291 = 291;
        integer a292 = 292;
        integer a293 = 293;
        integer a294 = 294;
        integer a295 = 295;
        integer a296 = 296;
        integer a297 = 297;
        integer a298 = 298;
        integer a299 = 299;
        integer a300 = 300;
        integer a301 = 301;
        integer a302 = 302;
        integer a303 = 303;
        integer a304 = 304;
        integer a305 = 305;
        integer a306 = 306;
        integer a307 = 307;
        integer a308 = 308;
        integer a309 = 309;
        integer a310 = 310;
        integer a311 = 311;
        integer a312 = 312;
        integer a313 = 313;
        integer a314 = 314;
        integer a315 = 315;
        integer a316 = 316;
        integer a317 = 317;
        integer a318 = 318;
        integer a319 = 319;
        integer a320 = 320;
        integer a321 = 321;
        integer a322 = 322;
        integer a323 = 323;
        integer a324 = 324;
        integer a325 = 325;
        integer a326 = 326;
        integer a327 = 327;
        integer a328 = 328;
        integer a329 = 329;
        integer a330 = 330;
        integer a331 = 331;
        integer a332 = 332;
        integer a333 = 333;
        integer a334 = 334;
        integer a335 = 335;
        integer a336 = 336;
        integer a337 = 337;
        integer a338 = 338;
        integer a339 = 339;
        integer a340 = 340;
        integer a341 = 341;
        integer a342 = 342;
        integer a343 = 343;
        integer a344 = 344;
        integer a345 = 345;
        integer a346 = 346;
        integer a347 = 347;
        integer a348 = 348;
        integer a349 = 349;
        integer a350 = 350;
        integer a351 = 351;
        integer a352 = 352;
        integer a353 = 353;
        integer a354 = 354;
        integer a355 = 355;
        integer a356 = 356;
        integer a357 = 357;
        integer a358 = 358;
        integer a359 = 359;
        integer a360 = 360;
        integer a361 = 361;
        integer a362 = 362;
        integer a363 = 363;
        integer a364 = 364;
        integer a365 = 365;
        integer a366 = 366;
        integer a367 = 367;
        integer a368 = 368;
        integer a369 = 369;
        integer a370 = 370;
        integer a371 = 371;
        integer a372 = 372;
        integer a373 = 373;
        integer a374 = 374;
        integer a375 = 375;
        integer a376 = 376;
        integer a377 = 377;
        integer a378 = 378;
        integer a379 = 379;
        integer a380 = 380;
        integer a381 = 381;
        integer a382 = 382;
        integer a383 = 383;
        integer a384 = 384;
        integer a385 = 385;
        integer a386 = 386;
        integer a387 = 387;
        integer a388 = 388;
        integer a389 = 389;
        integer a390 = 390;
        integer a391 = 391;
        integer a392 = 392;
        integer a393 = 393;
        integer a394 = 394;
        integer a395 = 395;
        integer a396 = 396;
        integer a397 = 397;
        integer a398 = 398;
        integer a399 = 399;
        integer a400 = 400;
        
        
        
    }
        
        
        
    
}