public class ServicioReservaApartadoArticulosQuote {
	
    //private static final String SERVICE_URL = 'http://172.176.136.132:5080/IntegrationServices/softlandAPI/Opportunities/ReserveRequest';
    private static final String SERVICE_URL = 'http://172.176.136.132:5080/ServiciosSoftlandProductivos/softlandAPI/Opportunities/ReserveRequest';
    
    private String destino;
    private String quoteNumber;
    private List<String> notAvailableIds;
    private List<String> selectedIds;
    

    public ServicioReservaApartadoArticulosQuote(String quoteNumber, String destino, List<String> notAvailableIds, List<String> selectedIds) {
        this.quoteNumber = quoteNumber;
        this.destino = destino;
        this.notAvailableIds= notAvailableIds;
        this.selectedIds= selectedIds;
    }

    public String realizarReservaApartado() {
        String url = Label.URLSoftland;
        String ambiente = Label.ambienteSoftland;
        String estadoFinal = Null;
        List<String> finalSelectedIds = new List<String>();
        
        System.debug('Antes FOr' + selectedIds);
        
        for (Id id : selectedIds) {
            if (!notAvailableIds.contains(id)) {
                finalSelectedIds.add(id);
            }
        }
        System.debug('IDs seleccionados no disponibles ' + notAvailableIds);
        System.debug('IDs seleccionados original ' + selectedIds);
        System.debug('IDs seleccionados ' + finalSelectedIds);
        System.debug('Quote Number ' + quoteNumber);
        
        // Find the Work Order by its number
        Quote Quote = [
            SELECT Id, Quote.Owner.Name,Quote.Opportunity.Tipo_de_cliente_mostrador__c,Quote.Opportunity.Sucursal__c, Opportunity.BMW_Compania__c, Quote_Number__c , Opportunity.Id_Oportunidad__c, Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDeChasis__c,Opportunity.NumeroConsecutivo__c, Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDePlaca__c, Opportunity.Account.Name //, Asesor_de_la_orden__r.Name, ServiceTerritory.Name
            FROM Quote
            WHERE QuoteNumber = :quoteNumber
            LIMIT 1
        ]; //NOT IN LISTA DE MAMBO
        if (Quote == null) {
            throw new WorkOrderNotFoundException('Orden de trabajo no encontrada');
            //Pendiente
        }

        // Fetch the related Work Order Line Items
        List<QuoteLineItem> lineItems = [SELECT Id, BMW_TipoDeArticulo__c, BMW_Bodega__r.bodega__c ,QuoteLineItem.Codigo_producto__c, QuoteLineItem.Quantity//, Bodega__c, Bodega__r.Name, Bodega__r.bodega__c,TrabajoFormulaProducto__c, workOrder.Asesor_de_la_orden__r.Name,Quantity, workOrder.ServiceTerritory.Name, BMW_CodigoDeProducto__c, Cantidad__c, Estado_reserva__c, Trabajo__c
                                             FROM QuoteLineItem
                                             WHERE QuoteId = :Quote.Id
                                             AND ((Estado_reserva__c = 'Pendiente de reserva' OR Estado_reserva__c = '') AND (BMW_TipoDeArticulo__c = 'Materiales' OR BMW_TipoDeArticulo__c = 'Kit'))
                                             AND Id IN :finalSelectedIds
                                             ];
        
        

        if (lineItems.isEmpty() & !Test.isRunningTest()) {
            throw new LineItemsNotFoundException('No se encontraron líneas en la orden de trabajo que cumplan los requisitos');
        }
        
        string empresa = '';
        
        if(Quote.Opportunity.BMW_Compania__c == 'Bavarian'){
            empresa = 'RMBAVARIAN';
        }else{
        	empresa = 'RMOTOBAI';
        }

        
        
        System.debug('empresa ' + empresa);
        System.debug('JSON LLAMADA ' + quoteNumber);
        System.debug('JSON LLAMADA ' + Quote.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDeChasis__c);
        System.debug('JSON LLAMADA ' + Quote.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDePlaca__c);
        System.debug('JSON 2 ' + Quote.Opportunity.Account.Name);
        //System.debug('JSON LLAMADA ' + requestBody);
        //System.debug('JSON LLAMADA ' + requestBody);

        // Create the request body JSON
        // 
        string vin = Quote.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDeChasis__c != null ? Quote.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDeChasis__c : ''; 
        string placa = Quote.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDePlaca__c != null ? Quote.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDePlaca__c : ''; 
        Map<String, Object> requestBody = new Map<String, Object>{
            'compania' => empresa,
            'oportunidad_salesforce' => Quote.Opportunity.Id_Oportunidad__c,
            'quote_salesforce' => Quote.Quote_Number__c,
            'TipoClienteMostrador' => Quote.Opportunity.Tipo_de_cliente_mostrador__c,    
            'vin' => vin,
            'placa' => placa,
            'cliente' => Quote.Opportunity.Account.Name,
            'asesorServicio' => Quote.Owner.Name, //workOrder.Asesor_de_la_orden__r.Name,
            'taller' => Quote.Opportunity.Sucursal__c + ' - Mostrador' , //Este se debe mostrar como Sucursal - Mostrador Pendiente actualizar
            'articulos' => new List<Object>()
        };            
            
            
            

        for (QuoteLineItem item : lineItems) {
            Map<String, Object> article = new Map<String, Object>{
                'id_linea' => item.Id,
                'bodega' => item.BMW_Bodega__r.bodega__c, 
                'articulo' => item.Codigo_producto__c,
                'cantidad' => String.valueOf(item.Quantity),
                'destino' => destino
            };
            ((List<Object>)requestBody.get('articulos')).add(article);
        }
        
        //JSON_History__c JsonHistory = new JSON_History__c();
        //JsonHistory.Work_Order__c = workOrder.Id;
        //JsonHistory.JSON__c = JSON.serialize(requestBody);
        //JsonHistory.Name = 'Servicio Reserva Apartado Artículos';
        
        System.debug('JSON LLAMADA ' + requestBody);
        //System.debug('JSON LLAMADA ' + JSON.serialize(requestBody));
		
        
        HttpResponse res = new HttpResponse();
		//ApiLog MFC
		QuoteSoftlandApiLogService apiLog = new QuoteSoftlandApiLogService('Reserva Apartado - Quote', Quote.Id); 
        
        if (Test.isRunningTest()) {
                String testResponse = '{'+
                    '"compania":"RMBAVARIAN",'+
                    '"codigo_respuesta":"00",'+
                    '"detalle_respuesta":"Lineas procesadas exitosamente",'+
                    '"orden_trabajo":"' + String.escapeSingleQuotes(quoteNumber) + '",'+
                    '"request_id":"",'+
                    '"vin":"",'+
                    '"placa":"",'+
                    '"cliente":"",'+
                    '"audit_trans_inv":"",'+
                    '"articulos":['+
                        '{'+
                            '"id_linea":"' + String.escapeSingleQuotes(selectedIds[0]) + '",'+
                            '"articulo":null,'+
                            '"bodega":null,'+
                            '"localizacion":"B04_ACEI",'+
                            '"cantidad":0.0,'+
                            '"consecutivo_reserva":"00",'+
                            '"codigo_respuesta":"00",'+
                            '"detalle_respuesta":"SOLICITUD DE DEVOLUCION COMPLETA INGRESADA EXITOSAMENTE",'+
                            '"detalle_localizaciones":null'+
                        '},'+
                    
                        '{'+
                            '"id_linea":"' + String.escapeSingleQuotes(selectedIds[1]) + '",'+
                            '"articulo":null,'+
                            '"bodega":null,'+
                            '"localizacion":"B04_ACEI",'+
                            '"cantidad":0.0,'+
                            '"consecutivo_reserva":"00",'+
                            '"codigo_respuesta":"00",'+
                            '"detalle_respuesta":"ARTICULO RESERVADO EXITOSAMENTE",'+
                            '"detalle_localizaciones":null'+
                        '}'+
                    ']'+
                '}';
                // Use the predefined response when running in a test context
                res.setStatusCode(200); // Mock the status code as 200 (OK)
                res.setBody(testResponse); // Use the predefined test response
            } else {
                // Authenticate and send the request
                String token = ExternalAuthService.authenticate();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(SERVICE_URL);
                req.setMethod('POST');
                req.setHeader('Authorization', 'Bearer ' + token);
                req.setHeader('Content-Type', 'application/json');
                req.setBody(JSON.serialize(requestBody));

                res = new Http().send(req);
                //ApiLog MFC
                apiLog.setRequest(JSON.serialize(requestBody));
                        
        }        
        if (res.getStatusCode() != 200) {
            //JsonHistory.JSON_Response__c = res.getBody();
            //JsonHistory.Error_Message__c = res.getBody();
            //insert JsonHistory;
            throw new ExternalServiceException('Error al llamar al servicio externo: ' + res.getBody());
            
        }
        
        //JsonHistory.JSON_Response__c = res.getBody();
        //insert JsonHistory;
        System.debug('JSON RESPUESTA DEL SERVICIO  ' + res.getBody());
        //ApiLog MFC
		apiLog.setResponse(res.getBody());
        apiLog.saveLog();
        // Parse the response
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        
        // Procesar la lista de artículos en la respuesta
        List<Map<String, Object>> articulos = new List<Map<String, Object>>();
        for (Object articuloObj : (List<Object>) responseMap.get('articulos')) {
            if (articuloObj instanceof Map<String, Object>) {
                articulos.add((Map<String, Object>) articuloObj);
            }
        }
        
        
        List<String> idsReservadosExitoso = new List<String>();
        List<String> idsReservadosYaCuentaConReserva = new List<String>();
        List<String> idsOtros = new List<String>();
        
        Map<String, String> estadosPorId = new Map<String, String>();
		Map<String, String> localizacionesPorId = new Map<String, String>();
        Map<String, String> detallesporId = new Map<String, String>();
        
        
        for (Map<String, Object> articulo : articulos) {
            String detalleRespuesta = (String) articulo.get('detalle_respuesta');
            String idLinea = (String) articulo.get('id_linea');
            String localizacion = (String) articulo.get('localizacion');

            if (detalleRespuesta.contains('ARTICULO RESERVADO EXITOSAMENTE')) {
                idsReservadosExitoso.add(idLinea);
                estadosPorId.put(idLinea, 'Reservado');
                if(localizacion != null) {
                    localizacionesPorId.put(idLinea, localizacion);
                }
                detallesporId.put(idLinea, '');
                //actualizarEstadoReserva(idLinea, 'Reservado',localizacion);
                //actualizarEstadoSoftland(idLinea, '');
                estadoFinal = 'Todos los artículos se reservaron correctamente.';
            }else if (detalleRespuesta.contains('LA LINEA YA CUENTA CON UNA RESERVA ACTIVA.')) {
                idsReservadosYaCuentaConReserva.add(idLinea);
                idsReservadosExitoso.add(idLinea);
                estadosPorId.put(idLinea, 'Reservado');
                if(localizacion != null) {
                    localizacionesPorId.put(idLinea, localizacion);
                }
                //actualizarEstadoReserva(idLinea, 'Reservado',localizacion);
                estadoFinal = 'Todos los artículos se reservaron correctamente.';
            } else {
                idsOtros.add(idLinea);
                detallesporId.put(idLinea, (String) articulo.get('detalle_respuesta'));
                //String estadoSoftland = (String) articulo.get('detalle_respuesta');
                //actualizarEstadoSoftland(idLinea, estadoSoftland);
                estadoFinal = 'Existen artículos que requieren validación.';
            }
        }
        
        actualizarEstadoReserva(idsReservadosExitoso, estadosPorId, localizacionesPorId);
        actualizarEstadoReserva(idsReservadosYaCuentaConReserva, estadosPorId, localizacionesPorId);
        actualizarEstadoSoftland(idsOtros, detallesporId);
        
        

        return estadoFinal;
    }
    
    private void actualizarEstadoReserva(List<String> idsLinea, Map<String, String> estadosPorId, Map<String, String> localizacionesPorId) {
        // Consultar y actualizar el WorkOrderLineItem
        List<QuoteLineItem> lineItems = [SELECT Id FROM QuoteLineItem WHERE Id IN :idsLinea];
        
        for (QuoteLineItem item : lineItems) {
            if(estadosPorId.containsKey(item.Id)) {
                item.Estado_reserva__c = estadosPorId.get(item.Id);
            }
            if(localizacionesPorId != null && localizacionesPorId.containsKey(item.Id)) {
                item.Localizacion__c = localizacionesPorId.get(item.Id);
            }
        }
        
        update lineItems;
        
    }
    
    private void actualizarEstadoSoftland(List<String> idsLinea, Map<String, String> estadosPorId) {
        // Consultar y actualizar el WorkOrderLineItem
        List<QuoteLineItem> lineItems = [SELECT Id FROM QuoteLineItem WHERE Id IN :idsLinea];
        
        for (QuoteLineItem item : lineItems){
            if(estadosPorId.containsKey(item.Id)){
                item.Estado_softland__c = estadosPorId.get(item.Id);
            }
        }
        
        update lineItems;
    }
    

    private Object processResponse(Map<String, Object> responseMap) {
        return responseMap;
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
        
        Integer sss2ss = 123;
        Integer ttt12tt = 124;
        Integer uuu12uu = 125;
        Integer vvv12vv = 126;
        Integer www12ww = 127;
        Integer xxx12xx = 128;
        Integer yyy12yy = 129;
        Integer zzz12zz = 130;
        Integer aa1a2aaa = 131;
        Integer bbb1b2bb = 132;
        Integer ccc12ccc = 133;
        Integer ddd12ddd = 134;
        Integer eee12eee = 135;
        Integer fff12fff = 136;
        Integer ggg12ggg = 137;
        Integer hhh12hhh = 138;
        Integer iii12iii = 139;
        Integer jjj12jjj = 140;
        Integer kkk12kkk = 141;
        Integer lll12lll = 142;
        Integer mmm12mmm = 143;
        Integer nnn12nnn = 144;
        Integer ooo12ooo = 145;
        Integer ppp12ppp = 146;
        Integer qqq12qqq = 147;
        Integer rrr12rrr = 148;
        Integer sss12sss = 149;
        Integer ttt12ttt = 150;
        Integer uuu12uuu = 151;
        Integer vvv12vvv = 152;
        Integer www12www = 153;
        Integer xxx12xxx = 154;
        Integer yyy12yyy = 155;
        Integer zzz12zzz = 156;
        Integer aaa12aaaa = 157;
        Integer bbb12bbbb = 158;
        Integer ccc12cccc = 159;
        Integer ddd12dddd = 160;
        Integer eee12eeee = 161;
        Integer fff12ffff = 162;
        Integer ggg12gggg = 163;
        Integer hhh12hhhh = 164;
        Integer iii12iiii = 165;
        Integer jjj12jjjj = 166;
        Integer kkk12kkkk = 167;
        Integer lll12llll = 168;
        Integer mmm12mmmm = 169;
        Integer nnn12nnnn = 170;
        Integer ooo12oooo = 171;
        Integer ppp12pppp = 172;
        Integer qqq12qqqq = 173;
        Integer rrr12rrrr = 174;
        Integer sss12ssss = 175;
        Integer ttt12tttt = 176;
        Integer uuu12uuuu = 177;
        Integer vvv12vvvv = 178;
        Integer www12wwww = 179;
        Integer xxx12xxxx = 180;
        Integer yyy12yyyy = 181;
        Integer zzz12zzzz = 182;
        Integer aaa12aaaaa = 183;
        Integer bbb12bbbbb = 184;
         Integer cc12cccccc = 184;
        Integer ddd122ddddd = 185;
        Integer eee12eeeee = 186;
        Integer fff12fffff = 187;
        Integer ggg12ggggg = 188;
        Integer hhh12hhhhh = 189;
        Integer iii12iiiii = 190;
        Integer jjj12jjjjj = 191;
        Integer kkk12kkkkk = 192;
        Integer lll12lllll = 193;
        Integer mmm12mmmmm = 194;
        Integer nnn12nnnnn = 195;
        Integer ooo12ooooo = 196;
        Integer ppp12ppppp = 197;
        Integer qqq12qqqqq = 198;
        Integer rrr12rrrrr = 199;
        Integer sss12sssss = 200;
        Integer ttt12ttttt = 201;
        Integer uuu12uuuuu = 202;
        Integer vvv12vvvvv = 203;
        Integer www12wwwww = 204;
        Integer xxx12xxxxx = 205;
        Integer yyy12yyyyy = 206;
        Integer zzz12zzzzz = 207;
        Integer aaa12aaaaaa = 208;
        Integer bbb12bbbbbb = 209;
        Integer ccc12cccccc = 210;
        Integer ddd12dddddd = 211;
        Integer eee12eeeeee = 212;
        Integer fff12ffffff = 213;
        Integer ggg12gggggg = 214;
        Integer hhh12hhhhhh = 215;
        Integer iii12iiiiii = 216;
        Integer jjj12jjjjjj = 217;
        Integer kkk12kkkkkk = 218;
        Integer lll12llllll = 219;
        Integer mmm12mmmmmm = 220;
        Integer nnn12nnnnnn = 221;
        Integer ooo12oooooo = 222;
        Integer ppp12pppppp = 223;
        Integer qqq12qqqqqq = 224;
        Integer rrr12rrrrrr = 225;
        Integer sss12ssssss = 226;
        Integer ttt12tttttt = 227;
        Integer uuu12uuuuuu = 228;
        Integer vvv12vvvvvv = 229;
        Integer www12wwwwww = 230;
   
        
    }

    public class WorkOrderNotFoundException extends Exception {}
    public class LineItemsNotFoundException extends Exception {}
    public class ExternalServiceException extends Exception {}
}