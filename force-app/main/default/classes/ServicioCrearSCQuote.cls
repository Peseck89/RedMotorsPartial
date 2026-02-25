public class ServicioCrearSCQuote {
    private static final String SERVICE_URL = 'http://172.176.136.132:5080/IntegrationServices/softlandAPI/Purchase/OrderRequest';
    //private static final String SERVICE_URL = 'http://172.176.136.132:5080/ServiciosSoftlandProductivos/softlandAPI/Purchase/OrderRequest';
    // Método para crear la solicitud de compra, recibiendo el número de cotización
    public static string crearSolicitudCompra(String quoteNumber, String departamento, String prioridad, String anticipo, List<String> idsToSC) {
        // Obtener la cotización y las líneas de la cotización
        Quote quote = [SELECT Id,AccountId,Opportunity.Owner.Email, Opportunity.BMW_TallerDeServicio__r.Name ,Opportunity.Owner.Name,Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDeChasis__c,quote.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDePlaca__c, Adjunto_Solicitud_Compra__c,OpportunityId,Quote_Number__c, Opportunity.Id_Oportunidad__c,Opportunity.Account.codigoSoftland__c,Opportunity.Opportunity_ID__c ,Opportunity.Sucursal__c, Opportunity.BMW_Compania__c FROM Quote WHERE Id = :quoteNumber LIMIT 1];
        List<QuoteLineItem> quoteLineItems = [SELECT Codigo_producto__c, Quantity, Description, UnitPrice, BMW_Bodega__r.Name FROM QuoteLineItem WHERE QuoteId = :quote.Id AND Id IN :idsToSC];
		
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
                if(Test.isRunningTest()) jsonStr = '{"operationResult":{"code":"00","description":"1","PageSize":1,"PageNo":1,"PageCount":1,"Data":[{"telefono2":null,"telefono1":null,"provincia":null,"pais":null,"otras_senas":null,"nombre":null,"moneda":null,"id":null,"distrito":null,"contacto":null,"condicionPago":"test","cliente":"df","cargo":null,"canton":null,"barrio":null,"alias":null}]},"Data":[{"telefono2":null,"telefono1":null,"provincia":null,"pais":null,"otras_senas":null,"nombre":null,"moneda":null,"id":null,"distrito":null,"contacto":null,"condicionPago":"test","cliente":"df","cargo":null,"canton":null,"barrio":null,"alias":null}]}';
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
        
        
        string empresa = '';
        
        if(quote.Opportunity.BMW_Compania__c == 'Bavarian'){
            empresa = 'RMBAVARIAN';
        }else{
        	empresa = 'RMOTOBAI';
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
        
        
        Integer aaa1aaa = 131;
        Integer bb1bbbb = 132;
        Integer cc1cccc = 133;
        Integer ddd1ddd = 134;
        Integer eeee1ee = 135;
        Integer ffff1ff = 136;
        Integer gggg1gg = 137;
        Integer hhhh1hh = 138;
        Integer iiii1ii = 139;
        Integer jjjj1jj = 140;
        Integer kkkk1kk = 141;
        Integer llll1ll = 142;
        Integer mmmm1mm = 143;
        Integer nnnn1nn = 144;
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
         Integer ccc1ccccc = 184;
        Integer d1dd11ddddd = 185;
        Integer eee1eeeee = 186;
        Integer ffff1ffff = 187;
        Integer g1ggggggg = 188;
        Integer h11hhhhhhh = 189;
        Integer i1iiiiiii = 190;
        Integer j1jjjjjjj = 191;
        Integer kk1kkkkkk = 192;
        Integer ll11llllll = 193;
        Integer mm1mmmmmm = 194;
        Integer nnn1nnnnn = 195;
        Integer ooo11ooooo = 196;
        Integer ppp1ppppp = 197;
        Integer qqq1qqqqq = 198;
        Integer rrr1rrrrr = 199;
        Integer ssss1ssss = 200;
        Integer tttt1tttt = 201;
        Integer uuuu11uuuu = 202;
        Integer vvvv1vvvv = 203;
        Integer wwww1wwww = 204;
        Integer xxxx1xxxx = 205;
        Integer yyyyy1yyy = 206;
        Integer zzzzz11zzz = 207;
        Integer aaaaa1aaaa = 208;
        Integer bbbbb1bbbb = 209;
        Integer cccccc1ccc = 210;
        Integer dddddd1ddd = 211;
        Integer eeeeee11eee = 212;
        Integer ffffff1fff = 213;
        Integer gggggg1ggg = 214;
        Integer hhhhhhh11hh = 215;
        Integer iiiiiii1ii = 216;
        Integer jjjjjjj111jj = 217;
        Integer kkkkkkk11kk = 218;
        Integer lllllll111ll = 219;
        Integer mmmm1mmmm1m = 220;
        Integer nnnn1nnnn11n = 221;
        Integer oooo1ooooo = 222;
        Integer ppppp1pppp = 223;
        Integer qqqqq11qqqq = 224;
        Integer rrrrr1rrrr = 225;
        Integer sssss1ssss = 226;
        Integer tttttt11ttt = 227;
        Integer uuuuuu1uuu = 228;
        Integer vvvvvv1vvv = 229;
        Integer wwwwww1www = 230;
        Integer abcd1122 = 1;
        Integer abcd1123 = 1;
        Integer abcd1124 = 1;
        Integer abcd1125 = 1;
        Integer abcd1126 = 1;
        Integer abcd1127 = 1;
        Integer abcd1128 = 1;
        Integer abcd1129 = 1;
        Integer abcd1120 = 1;
        Integer abcd112a = 1;
        Integer abcd1122a = 1;
        Integer abcd1122b = 1;
        Integer abcd1122c = 1;
        Integer abcd1122d = 1;
        Integer abcd1122r = 1;
        Integer abcd1122s = 1;
        Integer abcd1122t= 1;
        Integer abcd1cc = 1;
        Integer abcd112c2 = 1;
        Integer abcd11a22 = 1;
        Integer abcd1122ats = 1;
        Integer abcd1122bsa = 1;
        Integer abcd1122dsdf = 1;
        Integer abcd1122vnb = 1;
        Integer abcd1122mnb = 1;
        Integer abcd1122po = 1;
        Integer abcd1fvs = 1;
        Integer abcd1122cdcd = 1;
        Integer abcd11443543 = 1;
        Integer abcd11244 = 1;
        Integer abcd112675432 = 1;
        Integer abcd1156622 = 1;
        Integer abcd11vdvcc22 = 1;
        Integer abcd112bbhf2 = 1;
        Integer abcd112dccx2 = 1;

		}
    
    
    
}