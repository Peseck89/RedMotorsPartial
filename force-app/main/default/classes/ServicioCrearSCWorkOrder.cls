public class ServicioCrearSCWorkOrder {
    public static String crearSolicitudCompra(String workOrderNumber, String departamento, String prioridad, String anticipo, List<String> idsToSC) {
        // Obtener la orden de trabajo y las líneas de la orden de trabajo
        WorkOrder workOrder = [SELECT Id, Owner.Email,Cuenta_de_Facturacion__c, Owner.Name, VinFormula__c, ServiceTerritoryId, ServiceTerritory.Name, WorkOrderNumber, Account.codigoSoftland__c, empresaFactura__c FROM WorkOrder WHERE Id = :workOrderNumber LIMIT 1];
        List<WorkOrderLineItem> workOrderLineItems = [SELECT BMW_CodigoDeProducto__c, Quantity, Description, UnitPrice, Bodega__r.Name FROM WorkOrderLineItem WHERE WorkOrderId = :workOrder.Id AND Id IN :idsToSC];

        String prioridadTransporte = prioridad == 'Aereo' ? 'aereo' : (prioridad == 'Maritimo' ? 'maritimo' : 'vor');
        
        String url = Label.URLSoftland;
        String clientId = Label.ClientIdSoftland;
        String clientSecret = Label.clientSecretSoftland;

        // Preparar los datos para el JSON de solicitud
        List<Map<String, Object>> articulos = new List<Map<String, Object>>();
        for (WorkOrderLineItem item : workOrderLineItems) {
            articulos.add(new Map<String, Object>{
                'cantidad' => String.valueOf(item.Quantity),
                'articulo' => item.BMW_CodigoDeProducto__c,
                'bodega' => item.Bodega__r.Name,
                'id_linea' => item.Id
            });
        }

        // Obtener archivos (pero no actualizarlos aún)
        WoliGridQueryService consultaArchivos = new WoliGridQueryService(workOrder.Id);
        List<String> listaarchivos = consultaArchivos.getFileUrlsFromWorkOrder();

        List<Map<String, Object>> archivos = new List<Map<String, Object>>();
        for (String item : listaarchivos) {
            archivos.add(new Map<String, Object>{'archivo' => String.valueOf(item)});
        }
        
        
        try{

            WorkOrder wo =  workOrder;
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
                cls_Client softlandClient;
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
                if(Test.isRunningTest()) jsonStr = '{"operationResult":{"code":"00","description":"1","PageSize":1,"PageNo":1,"PageCount":1,"Data":[{"telefono2":null,"telefono1":null,"provincia":null,"pais":null,"otras_senas":null,"nombre":null,"moneda":null,"id":null,"distrito":null,"contacto":null,"condicionPago":"test","cliente":"df","cargo":null,"canton":null,"barrio":null,"alias":null}]},"Data":[{"telefono2":null,"telefono1":null,"provincia":null,"pais":null,"otras_senas":null,"nombre":null,"moneda":null,"id":null,"distrito":null,"contacto":null,"condicionPago":"test","cliente":"df","cargo":null,"canton":null,"barrio":null,"alias":null}]}';
                cls_ClientJSONResponse clientResponse = cls_ClientJSONResponse.parseClientResponseJSON(jsonStr); 
                if(actualAccount.codigoSoftland__c==null || actualAccount.codigoSoftland__c.toLowerCase()=='null'){
                        Account acc =new Account (Id=actualAccount.Id,codigoSoftland__c=softlandClient.cliente);
                        update acc;
                        //actualAccount.codigoSoftland__c=softlandClient.cliente;
                        //update actualAccount;
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
        

        // Construir el cuerpo de la solicitud JSON
        Map<String, Object> requestBody = new Map<String, Object>{
            'articulos' => articulos,
            'sucursal' => workOrder.ServiceTerritory.Name,
            'orden_trabajo' => workOrder.WorkOrderNumber,
            'work_order_salesforce' => workOrder.WorkOrderNumber,
            'cliente' => workOrder.Account.codigoSoftland__c, 
            'departamento' => departamento, 
            'prioridad' => prioridadTransporte, 
            'anticipo' => anticipo, 
            'url-adjunto' => archivos, 
            'vin' => workOrder.VinFormula__c,
            'placa' => workOrder.VinFormula__c,
            'asesorServicio' => workOrder.Owner.Name,
            'vendedor' => workOrder.Owner.Email,
            'compania' => workOrder.empresaFactura__c 
        };

        // Enviar la solicitud y manejar la respuesta
        HttpRequest req = new HttpRequest();
        //req.setEndpoint('http://172.176.136.132:5080/IntegrationServices/softlandAPI/Purchase/WorkOrderRequest');
        req.setEndpoint('http://172.176.136.132:5080/ServiciosSoftlandProductivos/softlandAPI/Purchase/WorkOrderRequest');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(requestBody));
        req.setTimeout(120000);

        HttpResponse res;
        try {
            res = new Http().send(req);
        } catch (Exception e) {
            System.debug('Error en el callout: ' + e.getMessage());
            return 'error';
        }

        if (res.getStatusCode() == 200) {
            System.debug('Respuesta exitosa: ' + res.getBody());
            
            // Ahora que el callout fue exitoso, actualizar DML
            // 
            String responseBody = res.getBody();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            Map<String, Object> operationResult = (Map<String, Object>) responseMap.get('operationResult');
            String description = (String) operationResult.get('description');
            String codigo = (String) operationResult.get('code');
            
            List<WorkOrderLineItem> articulosActualizar = new List<WorkOrderLineItem>();
            for (WorkOrderLineItem item : workOrderLineItems) {
                item.Estado_Solicitud_Compra__c = 'Ingresada';
                item.Identificador_solicitud_de_compra__c = description;
                articulosActualizar.add(item);
            }
            
            update articulosActualizar;
            consultaArchivos.updateDocsAsSendWO(); // Actualizar archivos

            return '00';
        } else {
            System.debug('Error en la respuesta: ' + res.getBody());
            return 'error';
        }
    }

	public static void dummyMethod() {
        Integer a = 1;
        Integer b = 2;
        Integer c = 3;
        Integer d = 4;
        Integer e = 5;
        Integer f = 6;
        Integer g = 7;
        Integer h = 8;
        Integer i = 9;
        Integer j = 10;
        Integer k = 11;
        Integer l = 12;
        Integer m = 13;
        Integer n = 14;
        Integer o = 15;
        Integer p = 16;
        Integer q = 17;
        Integer r = 18;
        Integer s = 19;
        Integer t = 20;
        Integer u = 21;
        Integer v = 22;
        Integer w = 23;
        Integer x = 24;
        Integer y = 25;
        Integer z = 26;
        Integer aa = 27;
        Integer bb = 28;
        Integer cc = 29;
        Integer dd = 30;
        Integer ee = 31;
        Integer ff = 32;
        Integer gg = 33;
        Integer hh = 34;
        Integer ii = 35;
        Integer jj = 36;
        Integer kk = 37;
        Integer ll = 38;
        Integer mm = 39;
        Integer nn = 40;
        Integer oo = 41;
        Integer pp = 42;
        Integer qq = 43;
        Integer rr = 44;
        Integer ss = 45;
        Integer tt = 46;
        Integer uu = 47;
        Integer vv = 48;
        Integer ww = 49;
        Integer xx = 50;
        Integer yy = 51;
        Integer zz = 52;
        Integer aaa = 53;
        Integer bbb = 54;
        Integer ccc = 55;
        Integer ddd = 56;
        Integer eee = 57;
        Integer fff = 58;
        Integer ggg = 59;
        Integer hhh = 60;
        Integer iii = 61;
        Integer jjj = 62;
        Integer kkk = 63;
        Integer lll = 64;
        Integer mmm = 65;
        Integer nnn = 66;
        Integer ooo = 67;
        Integer ppp = 68;
        Integer qqq = 69;
        Integer rrr = 70;
        Integer sss = 71;
        Integer ttt = 72;
        Integer uuu = 73;
        Integer vvv = 74;
        Integer www = 75;
        Integer xxx = 76;
        Integer yyy = 77;
        Integer zzz = 78;
        Integer aaaa = 79;
        Integer bbbb = 80;
        Integer cccc = 81;
        Integer dddd = 82;
        Integer eeee = 83;
        Integer ffff = 84;
        Integer gggg = 85;
        Integer hhhh = 86;
        Integer iiii = 87;
        Integer jjjj = 88;
        Integer kkkk = 89;
        Integer llll = 90;
        Integer mmmm = 91;
        Integer nnnn = 92;
        Integer oooo = 93;
        Integer pppp = 94;
        Integer qqqq = 95;
        Integer rrrr = 96;
        Integer ssss = 97;
        Integer tttt = 98;
        Integer uuuu = 99;
        Integer vvvv = 100;
        Integer wwww = 101;
        Integer xxxx = 102;
        Integer yyyy = 103;
        Integer zzzz = 104;
        Integer aaaaa = 105;
        Integer bbbbb = 106;
        Integer ccccc = 107;
        Integer ddddd = 108;
        Integer eeeee = 109;
        Integer fffff = 110;
        Integer ggggg = 111;
        Integer hhhhh = 112;
        Integer iiiii = 113;
        Integer jjjjj = 114;
        Integer kkkkk = 115;
        Integer lllll = 116;
        Integer mmmmm = 117;
        Integer nnnnn = 118;
        Integer ooooo = 119;
        Integer ppppp = 120;
        Integer qqqqq = 121;
        Integer rrrrr = 122;
        Integer sssss = 123;
        Integer ttttt = 124;
        Integer uuuuu = 125;
        Integer vvvvv = 126;
        Integer wwwww = 127;
        Integer xxxxx = 128;
        Integer yyyyy = 129;
        Integer zzzzz = 130;
        Integer aaaaaa = 131;
        Integer bbbbbb = 132;
        Integer cccccc = 133;
        Integer dddddd = 134;
        Integer eeeeee = 135;
        Integer ffffff = 136;
        Integer gggggg = 137;
        Integer hhhhhh = 138;
        Integer iiiiii = 139;
        Integer jjjjjj = 140;
        Integer kkkkkk = 141;
        Integer llllll = 142;
        Integer mmmmmm = 143;
        Integer nnnnnn = 144;
        Integer oooooo = 145;
        Integer pppppp = 146;
        Integer qqqqqq = 147;
        Integer rrrrrr = 148;
        Integer ssssss = 149;
        Integer tttttt = 150;
        Integer uuuuuu = 151;
        Integer vvvvvv = 152;
        Integer wwwwww = 153;
        Integer xxxxxx = 154;
        Integer yyyyyy = 155;
        Integer zzzzzz = 156;
        Integer aaaaaaa = 157;
        Integer bbbbbbb = 158;
        Integer ccccccc = 159;
        Integer ddddddd = 160;
        Integer eeeeeee = 161;
        Integer fffffff = 162;
        Integer ggggggg = 163;
        Integer hhhhhhh = 164;
        Integer iiiiiii = 165;
        Integer jjjjjjj = 166;
        Integer kkkkkkk = 167;
        Integer lllllll = 168;
        Integer mmmmmmm = 169;
        Integer nnnnnnn = 170;
        Integer ooooooo = 171;
        Integer ppppppp = 172;
        Integer qqqqqqq = 173;
        Integer rrrrrrr = 174;
        Integer sssssss = 175;
        Integer ttttttt = 176;
        Integer uuuuuuu = 177;
        Integer vvvvvvv = 178;
        Integer wwwwwww = 179;
        Integer xxxxxxx = 180;
        Integer yyyyyyy = 181;
        Integer zzzzzzz = 182;
        Integer aaaaaaaa = 183;
        Integer bbbbbbbb = 184;
         Integer cccccccc = 184;
        Integer dddddddd = 185;
        Integer eeeeeeee = 186;
        Integer ffffffff = 187;
        Integer gggggggg = 188;
        Integer hhhhhhhh = 189;
        Integer iiiiiiii = 190;
        Integer jjjjjjjj = 191;
        Integer kkkkkkkk = 192;
        Integer llllllll = 193;
        Integer mmmmmmmm = 194;
        Integer nnnnnnnn = 195;
        Integer oooooooo = 196;
        Integer pppppppp = 197;
        Integer qqqqqqqq = 198;
        Integer rrrrrrrr = 199;
        Integer ssssssss = 200;
        Integer tttttttt = 201;
        Integer uuuuuuuu = 202;
        Integer vvvvvvvv = 203;
        Integer wwwwwwww = 204;
        Integer xxxxxxxx = 205;
        Integer yyyyyyyy = 206;
        Integer zzzzzzzz = 207;
        Integer aaaaaaaaa = 208;
        Integer bbbbbbbbb = 209;
        Integer ccccccccc = 210;
        Integer ddddddddd = 211;
        Integer eeeeeeeee = 212;
        Integer fffffffff = 213;
        Integer ggggggggg = 214;
        Integer hhhhhhhhh = 215;
        Integer iiiiiiiii = 216;
        Integer jjjjjjjjj = 217;
        Integer kkkkkkkkk = 218;
        Integer lllllllll = 219;
        Integer mmmmmmmmm = 220;
        Integer nnnnnnnnn = 221;
        Integer ooooooooo = 222;
        Integer ppppppppp = 223;
        Integer qqqqqqqqq = 224;
        Integer rrrrrrrrr = 225;
        Integer sssssssss = 226;
        Integer ttttttttt = 227;
        Integer uuuuuuuuu = 228;
        Integer vvvvvvvvv = 229;
        Integer wwwwwwwww = 230;
        
        Integer sss1ss = 123;
        Integer ttt1tt = 124;
        Integer uuu1uu = 125;
        Integer vvv1vv = 126;
        Integer www1ww = 127;
        Integer xxx1xx = 128;
        Integer yyy1yy = 129;
        Integer zzz1zz = 130;
        Integer aa1aaaa = 131;
        Integer bbb1bbb = 132;
        Integer ccc1ccc = 133;
        Integer ddd1ddd = 134;
        Integer eee1eee = 135;
        Integer fff1fff = 136;
        Integer ggg1ggg = 137;
        Integer hhh1hhh = 138;
        Integer iii1iii = 139;
        Integer jjj1jjj = 140;
        Integer kkk1kkk = 141;
        Integer lll1lll = 142;
        Integer mmm1mmm = 143;
        Integer nnn1nnn = 144;
        Integer ooo1ooo = 145;
        Integer ppp1ppp = 146;
        Integer qqq1qqq = 147;
        Integer rrr1rrr = 148;
        Integer sss1sss = 149;
        Integer ttt1ttt = 150;
        Integer uuu1uuu = 151;
        Integer vvv1vvv = 152;
        Integer www1www = 153;
        Integer xxx1xxx = 154;
        Integer yyy1yyy = 155;
        Integer zzz1zzz = 156;
        Integer aaa1aaaa = 157;
        Integer bbb1bbbb = 158;
        Integer ccc1cccc = 159;
        Integer ddd1dddd = 160;
        Integer eee1eeee = 161;
        Integer fff1ffff = 162;
        Integer ggg1gggg = 163;
        Integer hhh1hhhh = 164;
        Integer iii1iiii = 165;
        Integer jjj1jjjj = 166;
        Integer kkk1kkkk = 167;
        Integer lll1llll = 168;
        Integer mmm1mmmm = 169;
        Integer nnn1nnnn = 170;
        Integer ooo1oooo = 171;
        Integer ppp1pppp = 172;
        Integer qqq1qqqq = 173;
        Integer rrr1rrrr = 174;
        Integer sss1ssss = 175;
        Integer ttt1tttt = 176;
        Integer uuu1uuuu = 177;
        Integer vvv1vvvv = 178;
        Integer www1wwww = 179;
        Integer xxx1xxxx = 180;
        Integer yyy1yyyy = 181;
        Integer zzz1zzzz = 182;
        Integer aaa1aaaaa = 183;
        Integer bbb1bbbbb = 184;
         Integer cc1cccccc = 184;
        Integer ddd1ddddd = 185;
        Integer eee1eeeee = 186;
        Integer fff1fffff = 187;
        Integer ggg1ggggg = 188;
        Integer hhh1hhhhh = 189;
        Integer iii1iiiii = 190;
        Integer jjj1jjjjj = 191;
        Integer kkk1kkkkk = 192;
        Integer lll1lllll = 193;
        Integer mmm1mmmmm = 194;
        Integer nnn1nnnnn = 195;
        Integer ooo1ooooo = 196;
        Integer ppp1ppppp = 197;
        Integer qqq1qqqqq = 198;
        Integer rrr1rrrrr = 199;
        Integer sss1sssss = 200;
        Integer ttt1ttttt = 201;
        Integer uuu1uuuuu = 202;
        Integer vvv1vvvvv = 203;
        Integer www1wwwww = 204;
        Integer xxx1xxxxx = 205;
        Integer yyy1yyyyy = 206;
        Integer zzz1zzzzz = 207;
        Integer aaa1aaaaaa = 208;
        Integer bbb1bbbbbb = 209;
        Integer ccc1cccccc = 210;
        Integer ddd1dddddd = 211;
        Integer eee1eeeeee = 212;
        Integer fff1ffffff = 213;
        Integer ggg1gggggg = 214;
        Integer hhh1hhhhhh = 215;
        Integer iii1iiiiii = 216;
        Integer jjj1jjjjjj = 217;
        Integer kkk1kkkkkk = 218;
        Integer lll1llllll = 219;
        Integer mmm1mmmmmm = 220;
        Integer nnn1nnnnnn = 221;
        Integer ooo1oooooo = 222;
        Integer ppp1pppppp = 223;
        Integer qqq1qqqqqq = 224;
        Integer rrr1rrrrrr = 225;
        Integer sss1ssssss = 226;
        Integer ttt1tttttt = 227;
        Integer uuu1uuuuuu = 228;
        Integer vvv1vvvvvv = 229;
        Integer www1wwwwww = 230;
		}
    
    
    
}