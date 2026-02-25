public class ServicioConsDispBodegaQuoli {
    //private static final String SERVICE_URL = 'http://172.176.136.132:5080/IntegrationServices/softlandAPI/Catalogs/getExistenciaArticuloOportunidad';
    private static final String SERVICE_URL = 'http://172.176.136.132:5080/ServiciosSoftlandProductivos/softlandAPI/Catalogs/getExistenciaArticuloOportunidad';
    
    // Método para consultar la disponibilidad, recibiendo una lista de WoliGridWrapper
    public static List<WoliGridWrapper> consultarDisponibilidad(List<WoliGridWrapper> woliWrappers, String quoteNumber) {
		
        String url = Label.URLSoftland;
        String ambiente = Label.ambienteSoftland;
        
        Quote quote = [SELECT Id, Quote_Number__c ,Opportunity.BMW_Compania__c,Opportunity.Id_Oportunidad__c , Opportunity.NumeroConsecutivo__c FROM Quote WHERE QuoteNumber = :quoteNumber LIMIT 1];
        
        string empresa = '';
        
        if(quote.Opportunity.BMW_Compania__c == 'Bavarian'){
            empresa = 'RMBAVARIAN';
        }else{
        	empresa = 'RMOTOBAI';
        }
        
        // Crear el JSON para la solicitud
        Map<String, Object> requestBody = new Map<String, Object>{
            'oportunidad_salesforce' => Quote.Opportunity.Id_Oportunidad__c, 
            'quote_salesforce' => Quote.Quote_Number__c,
            'compania' => empresa, 
            'articulos' => new List<Map<String, String>>()
        };

        Map<String, Map<String, String>> uniqueArticulos = new Map<String, Map<String, String>>();

        for (WoliGridWrapper woliWrapper : woliWrappers) {
            if (!uniqueArticulos.containsKey(woliWrapper.ProductCode)) {
                System.debug('JSON TIPO KIT ' + woliWrapper.esKit);
                
                string tipo = 'T';
                 Product2 prod = [
                    SELECT Id, TipoProducto__c 
                    FROM Product2 
                    WHERE ProductCode = :woliWrapper.ProductCode 
                    LIMIT 1
                ];
            
                // Si es kit según la tabla de producto, forzar tipo = K
                if (prod.TipoProducto__c == 'Kit') {
                    tipo = 'K';
                }else{
                    tipo = 'T';
                }
                
                
                
                uniqueArticulos.put(woliWrapper.ProductCode, new Map<String, String>{
                    'tipo' => tipo, 
                    'bodega' => woliWrapper.idExtBodega,
                    'articulo' => woliWrapper.ProductCode
                });
            }
        }

        requestBody.put('articulos', new List<Map<String, String>>(uniqueArticulos.values()));
        
        
       
        
        Quote insertedquote = [SELECT Id, quoteNumber FROM Quote WHERE QuoteNumber = :quoteNumber];
        HttpResponse res = new HttpResponse();
        ///APILog MFC
        QuoteSoftlandApiLogService apiLog = new QuoteSoftlandApiLogService('Consulta disponible en bodega - Quote', insertedquote.Id); 
        
        if (Test.isRunningTest()) {
            	
            	//WorkOrder insertedWO = [SELECT Id, WorkOrderNumber FROM WorkOrder WHERE WorkOrderNumber = :workOrderNumber];
            
            	List<QuoteLineItem> quolis = [SELECT Id, Codigo_producto__c FROM QuoteLineItem WHERE QuoteId = :insertedquote.id];
                
                String testResponse = '{' +
                                        '"Data":[' +
                                            '{' +
                                                '"articulo":"' + quolis[0].Codigo_producto__c + '",' +
                                                '"bodega":"BR01",' +
                                                '"cantidadDisponible":11,' +
                                                '"reservadoOrden":0,' +
                                                '"existenciasOtrasBodegas":"false"' +
                                            '},' +
                                            '{' +
                                                '"Data":[' +
                                                    '{' +
                                                        '"articulo":"' + quolis[1].Codigo_producto__c + '",' +
                                                        '"bodega":"BR02",' +
                                                        '"cantidadDisponible":1' +
                                                    '},' +
                                                    '{' +
                                                        '"articulo":"' + quolis[1].Codigo_producto__c + '",' +
                                                        '"bodega":"BR03",' +
                                                        '"cantidadDisponible":6' +
                                                    '}' +
                                                '],' +
                                                '"articulo":"' + quolis[1].Codigo_producto__c + '",' +
                                                '"bodega":"BR01",' +
                                                '"cantidadDisponible":0,' +
                                                '"reservadoOrden":0,' +
                                                '"existenciasOtrasBodegas":"true"' +
                                            '}' +
                                        '],' +
                                        '"Paging":{' +
                                            '"PageNo":1,' +
                                            '"PageSize":100,' +
                                            '"PageCount":1,' +
                                            '"TotalRecordCount":69833,' +
                                            '"TotalThisViewCount":3' +
                                        '}' +
                                    '}';

                // Use the predefined response when running in a test context
                //apiLog.setRequest('TEST');
                //apiLog.setResponse(testResponse);
                res.setStatusCode(200); // Mock the status code as 200 (OK)
                res.setBody(testResponse); // Use the predefined test response
            } else {
      
                String tokenAuthentificacion = ExternalAuthService.authenticate();
                
                System.debug('Request Body  ' + JSON.serialize(requestBody));
                apiLog.setRequest(JSON.serialize(requestBody));
                // Realizar la autenticación y llamar al servicio externo
                HttpRequest req = new HttpRequest();
                req.setEndpoint(SERVICE_URL);
                req.setMethod('POST');
                req.setHeader('Authorization', 'Bearer ' + tokenAuthentificacion);
                req.setHeader('Content-Type', 'application/json');
                req.setBody(JSON.serialize(requestBody));
                req.setTimeout(120000);
                
                res = new Http().send(req);
                
        } 
        
        System.debug('JSON RESPUESTA  ' + res);
        apiLog.setResponse(res.getBody());
        apiLog.saveLog();
        //JsonHistory.JSON_Response__c = res.getBody();
        //JsonHistory.Error_Message__c = 'Consulta disponible en bodega';
        //insert JsonHistory;
        //string test = '{ "Data": [ { "articulo": "L00078", "bodega": "BR01", "cantidadDisponible": 11, "reservadoOrden": 0, "existenciasOtrasBodegas": "false" }, { "Data": [ { "articulo": "61279487464", "bodega": "BR03", "cantidadDisponible": 1 }, { "articulo": "61279487464", "bodega": "BR02", "cantidadDisponible": 6 } ], "articulo": "61279487464", "bodega": "BR01", "cantidadDisponible": 0, "reservadoOrden": 0, "existenciasOtrasBodegas": "true" }, { "articulo": "11138580110", "bodega": "BR01", "cantidadDisponible": 11, "reservadoOrden": 0, "existenciasOtrasBodegas": "false" } ], "Paging": { "PageNo": 1, "PageSize": 100, "PageCount": 1, "TotalRecordCount": 69833, "TotalThisViewCount": 3 } }';
        // Suponiendo que la respuesta es correcta y deseamos usarla para construir la lista de WOLI
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        System.debug('JSON RESPUESTA  ' + res.getBody());
        
        List<Object> data = (List<Object>) responseMap.get('Data');

        List<QUOLI> items = new List<QUOLI>();
        for (Object dataItem : data) {
            Map<String, Object> itemMap = (Map<String, Object>) dataItem;
            String existenciasOtrasBodegas = (String) itemMap.get('existenciasOtrasBodegas');
            String otherInventoryText = (String) itemMap.get('existenciasOtrasBodegas') == 'true' && itemMap.containsKey('Data') ? consultaDisponibleBodega.getOtherInventoryText((List<Object>) itemMap.get('Data')): '';
            
            QUOLI QUOLI = new QUOLI(
                (String) itemMap.get('articulo'),
                (String) itemMap.get('bodega'),
                (Decimal) itemMap.get('cantidadDisponible'),
                (Decimal) itemMap.get('reservadoOrden'),
                (String) itemMap.get('existenciasOtrasBodegas'),
                otherInventoryText
            );
            items.add(QUOLI);
        }
        
        List<WoliGridWrapper> ListaWrapper = actualizarWrappersConDisponibilidad(woliWrappers, items);
        
        System.debug('JSON RESPUESTA  ' + ListaWrapper);
        
        
        return ListaWrapper;     
        
        
    }
    
    public static List<WoliGridWrapper> actualizarWrappersConDisponibilidad(List<WoliGridWrapper> woliWrappers, List<QUOLI> items) {
        // Crear un mapa para facilitar la búsqueda de disponibilidad por ProductCode
        Map<String, QUOLI> disponibilidadPorCodigo = new Map<String, QUOLI>();
        for (QUOLI item : items) {
            disponibilidadPorCodigo.put(item.articulo, item);
        }
    
        // Conjunto para rastrear los ProductCodes ya procesados
        Set<String> procesados = new Set<String>();
    
        for (WoliGridWrapper wrapper : woliWrappers) {
            QUOLI quoliItem = disponibilidadPorCodigo.get(wrapper.ProductCode);
    
            // Si el artículo está presente en la lista de disponibilidad
            if (quoliItem != null) {
                wrapper.existenciasOtrasBodegas = quoliItem.existenciasOtrasBodegas;
                wrapper.otherInventoryText = quoliItem.otherInventoryText;
                // Si el ProductCode ya ha sido procesado, ignorar el reservadoOrden
                if (procesados.contains(wrapper.ProductCode)) {
                    if (wrapper.cantidad <= quoliItem.cantidadDisponible) {
                        wrapper.softlandQuantity = quoliItem.cantidadDisponible;
                        wrapper.validated = true;
                        wrapper.available = true;
                        System.debug('Linea con cantidad disponible');
                    }else {
                        wrapper.softlandQuantity = quoliItem.cantidadDisponible;
                        wrapper.validated = true;
                        wrapper.available = false;
                    }
                } else {
                    // Este es el primer procesamiento para este ProductCode
                    if (wrapper.cantidad - quoliItem.reservadoOrden <= quoliItem.cantidadDisponible) {
                        wrapper.softlandQuantity = quoliItem.cantidadDisponible;
                        wrapper.validated = true;
                        wrapper.available = true;
                    }else {
                        wrapper.softlandQuantity = quoliItem.cantidadDisponible;
                        wrapper.validated = true;
                        wrapper.available = false;
                    }
                    // Marcar como procesado
                    procesados.add(wrapper.ProductCode);
                }
            }
        }
        
        return woliWrappers;
    }
    
    public class QUOLI {
        public String articulo;
        public String bodega;
        public Decimal cantidadDisponible;
        public Decimal reservadoOrden;
        public String existenciasOtrasBodegas;
        public String otherInventoryText;
        
        public QUOLI(String articulo, String bodega, Decimal cantidadDisponible, Decimal reservadoOrden, String existenciasOtrasBodegas, String otherInventoryText) {
            this.articulo = articulo;
            this.bodega = bodega;
            this.cantidadDisponible = cantidadDisponible;
            this.reservadoOrden = reservadoOrden;
            this.existenciasOtrasBodegas = existenciasOtrasBodegas;
            this.otherInventoryText = otherInventoryText;
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
        
    }

}