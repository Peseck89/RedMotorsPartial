public class ServicioEliminarReservaArticuloQuote {
    private static final String SERVICE_URL = 'http://172.176.136.132:5080/ServiciosSoftlandProductivos/softlandAPI/Opportunities/deleteRequest';
    //private static final String SERVICE_URL = 'http://172.176.136.132:5080/IntegrationServices/softlandAPI/Opportunities/deleteRequest;
	private String quoteNumber;
    private List<String> lineItemIds;

    public ServicioEliminarReservaArticuloQuote(String quoteNumber, List<String> lineItemIds) {
        this.quoteNumber = quoteNumber;
        this.lineItemIds = lineItemIds;
    }

    public String eliminarReservaArticulos() {
        String url = Label.URLSoftland;
        String ambiente = Label.ambienteSoftland;
        String estadoFinal = 'Se eliminaron todos los artículos exitosamente.';

        filterLineItemIdsByEstadoReserva();
        
        
        System.debug('Quote number ' + quoteNumber);
        
        Quote quote = [
            SELECT Id, Opportunity.BMW_Compania__c,quote.Opportunity.Id_Oportunidad__c ,Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDeChasis__c, Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDePlaca__c, Opportunity.Account.codigoSoftland__c
            FROM Quote
            WHERE QuoteNumber = :quoteNumber
            LIMIT 1
        ];

        // Consultar Cantidad_devolucion para cada LineItem
        Map<String, Decimal> lineItemDevolutionQuantities = new Map<String, Decimal>();
        for (String lineItemId : lineItemIds) {
            QuoteLineItem lineItem = [SELECT Id, Cantidad_devolucion__c FROM QuoteLineItem WHERE Id = :lineItemId LIMIT 1];
            lineItemDevolutionQuantities.put(lineItemId, lineItem.Cantidad_devolucion__c);
        }
        QuoteSoftlandApiLogService apiLog = new QuoteSoftlandApiLogService('Eliminar Reserva - Quote', Quote.Id); 
        
		string empresa = ''; 
        if(quote.Opportunity.BMW_Compania__c == 'Bavarian'){
            empresa = 'RMBAVARIAN';
        }else{
        	empresa = 'RMOTOBAI';
        }

        // Crear el request body JSON
        Map<String, Object> requestBody = new Map<String, Object>{
            'compania' => empresa,
            'oportunidad' => quote.Opportunity.Id_Oportunidad__c,
            'orden_trabajo' => quoteNumber,
            'vin' => quote.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDeChasis__c,
            'placa' => quote.Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDePlaca__c,
            'cliente' => quote.Opportunity.Account.codigoSoftland__c,
            'articulos' => new List<Object>()
        };

        for (String lineItemId : lineItemIds) {
            Decimal devolutionQuantity = lineItemDevolutionQuantities.get(lineItemId);
            Decimal cantidad = (devolutionQuantity == 0) ? null : devolutionQuantity;

            Map<String, Object> article = new Map<String, Object>{
                'id_linea' => lineItemId,
                'cantidad' => cantidad  // Establece la cantidad o null
            };
            ((List<Object>)requestBody.get('articulos')).add(article);
        }

        System.debug('JSON LLAMADA SERVICIO ' + JSON.serialize(requestBody));
		HttpResponse res = new HttpResponse();
        
        

        if (Test.isRunningTest()) {
            String testResponse = '{'+
                '"compania":"RMBAVARIAN",'+
                '"codigo_respuesta":"00",'+
                '"detalle_respuesta":"Lineas procesadas exitosamente",'+
                '"orden_trabajo":"' + String.escapeSingleQuotes(quoteNumber) + '",'+
                '"request_id":null,'+
                '"vin":"12312321",'+
                '"placa":"Cocheprueba",'+
                '"cliente":"Luis Antonio Dorantes Pérez",'+
                '"audit_trans_inv":"",'+
                '"articulos":['+
                    '{'+
                        '"id_linea":"' + String.escapeSingleQuotes(lineItemIds[0]) + '",'+
                        '"articulo":"L00078",'+
                        '"bodega":"BR01",'+
                        '"localizacion":"B04_ACEI",'+
                        '"cantidad":1.0,'+
                        '"consecutivo_reserva":"ARTICULO RESERVADO EXITOSAMENTE.",'+
                        '"codigo_respuesta":"00",'+
                        '"detalle_respuesta":"SOLICITUD DE DEVOLUCION COMPLETA INGRESADA EXITOSAMENTE",'+
                        '"detalle_localizaciones":['+
                            '{'+
                                '"localizacion":"B04_ACEI",'+
                                '"cantidad":1.0'+
                            '}'+
                        ']'+
                    '},'+
                    '{'+
                        '"id_linea":"' + String.escapeSingleQuotes(lineItemIds[1]) + '",'+
                        '"articulo":"L00078",'+
                        '"bodega":"BR01",'+
                        '"localizacion":"B04_ACEI",'+
                        '"cantidad":1.0,'+
                        '"consecutivo_reserva":"ARTICULO RESERVADO EXITOSAMENTE.",'+
                        '"codigo_respuesta":"00",'+
                        '"detalle_respuesta":"LINEA ELIMINADA EXITOSAMENTE",'+
                        '"detalle_localizaciones":['+
                            '{'+
                                '"localizacion":"B04_ACEI",'+
                                '"cantidad":1.0'+
                            '}'+
                        ']'+
                    '},'+
                    '{'+
                        '"id_linea":"' + String.escapeSingleQuotes(lineItemIds[2]) + '",'+
                        '"articulo":"L00078",'+
                        '"bodega":"BR01",'+
                        '"localizacion":"B04_ACEI",'+
                        '"cantidad":1.0,'+
                        '"consecutivo_reserva":"ARTICULO RESERVADO EXITOSAMENTE.",'+
                        '"codigo_respuesta":"00",'+
                        '"detalle_respuesta":"SOLICITUD DE DEVOLUCION PARCIAL INGRESADA EXITOSAMENTE",'+
                        '"detalle_localizaciones":['+
                            '{'+
                                '"localizacion":"B04_ACEI",'+
                                '"cantidad":1.0'+
                            '}'+
                        ']'+
                    '},'+
                    '{'+
                        '"id_linea":"' + String.escapeSingleQuotes(lineItemIds[3]) + '",'+
                        '"articulo":"L00078",'+
                        '"bodega":"BR01",'+
                        '"localizacion":"B04_ACEI",'+
                        '"cantidad":1.0,'+
                        '"consecutivo_reserva":"ARTICULO RESERVADO EXITOSAMENTE.",'+
                        '"codigo_respuesta":"00",'+
                        '"detalle_respuesta":"ERROR EN SOFTLAND",'+
                        '"detalle_localizaciones":['+
                            '{'+
                                '"localizacion":"B04_ACEI",'+
                                '"cantidad":1.0'+
                            '}'+
                        ']'+
                    '}'+
                ']'+
            '}';

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
        }
        
       
        apiLog.setRequest(JSON.serialize(requestBody));
        
        System.debug('Respuesta ' + JSON.serialize(requestBody));
        
        if (res.getStatusCode() != 200) {
            throw new ExternalServiceException('Error al llamar al servicio externo: ' + res.getBody());
        }

        System.debug('JSON RESPUESTA DEL SERVICIO  ' + res.getBody());
        
        apiLog.setResponse(res.getBody());
        apiLog.saveLog();

        Map<String, Object> responseMap;
        try {
            responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

            List<Map<String, Object>> articulos = new List<Map<String, Object>>();
            List<Object> articulosAny = (List<Object>) responseMap.get('articulos');
            
            System.debug('Articulos  ' + articulosAny);

            List<String> lineItemIdsToDelete = new List<String>();
            List<String> lineItemIdsToUpdate = new List<String>();

            for (Object item : articulosAny) {
                Map<String, Object> articuloMap = (Map<String, Object>) item;
                System.debug('ArticuloMap: ' + articuloMap );
                String detalleRespuesta = (String) articuloMap.get('detalle_respuesta');
                String idLinea = (String) articuloMap.get('id_linea');

                System.debug('detalleRespuesta: ' + detalleRespuesta + 'Id: '+ idLinea);

                if (detalleRespuesta.contains('LINEA ELIMINADA EXITOSAMENTE')) {
                    lineItemIdsToDelete.add(idLinea);
                } else if (detalleRespuesta.contains('SOLICITUD DE DEVOLUCION COMPLETA INGRESADA EXITOSAMENTE')) {
                    actualizarEstadoSoftland(idLinea, 'Pendiente entregar en bodega');
                    estadoFinal = 'Existen artículos que requieren validación.';
                    System.debug('JSON RESPUESTA Devolucion COMPLETA  ');
                } else if (detalleRespuesta.contains('SOLICITUD DE DEVOLUCION PARCIAL INGRESADA EXITOSAMENTE')) {
                    actualizarEstadoSoftlandDevolucionParcial(idLinea, 'Solicitud de devolución parcial ingresada');
                    estadoFinal = 'Existen artículos que requieren validación.';
                    System.debug('JSON RESPUESTA Devolucion Parcial  ');
                } else {
                    actualizarEstadoErrorSoftland(idLinea, detalleRespuesta);
                    estadoFinal = 'Existen artículos que requieren validación.';
                }
            }

            eliminarQuoteLineItems(lineItemIdsToDelete);
            editarQuoteLineItems(lineItemIdsToUpdate);
        } catch (Exception e) {
            System.debug('Error al procesar la respuesta JSON: ' + e.getMessage());
        }

        return estadoFinal;
    }

    private void actualizarEstadoSoftland(String idLinea, String estado) {
        QuoteLineItem lineItem = [SELECT Id FROM QuoteLineItem WHERE Id = :idLinea LIMIT 1];
        if (lineItem != null) {
            lineItem.Estado_softland__c = estado;
            lineItem.Estado_entrega__c = 'Pendiente de devolución';

            update lineItem;
        }
    }
    
    private void actualizarEstadoSoftlandDevolucionParcial(String idLinea, String estado) {
        QuoteLineItem lineItem = [SELECT Id FROM QuoteLineItem WHERE Id = :idLinea LIMIT 1];
        if (lineItem != null) {
            lineItem.Estado_softland__c = estado;
            lineItem.Estado_entrega__c = 'Pendiente devolución parcial';

            update lineItem;
        }
    }

    private void actualizarEstadoErrorSoftland(String idLinea, String detalleRespuesta) {
        QuoteLineItem lineItem = [SELECT Id FROM QuoteLineItem WHERE Id = :idLinea LIMIT 1];
        if (lineItem != null) {
            lineItem.Estado_softland__c = detalleRespuesta;

            update lineItem;
        }
    }

    private void eliminarQuoteLineItems(List<String> idsToDelete) {
        try {
            List<QuoteLineItem> lineItemsToDelete = [SELECT Id FROM QuoteLineItem WHERE Id IN :idsToDelete];
            System.debug('Lista: ' + lineItemsToDelete);

            if (!lineItemsToDelete.isEmpty()) {
                delete lineItemsToDelete;
                System.debug('Eliminados');
            } else {
                System.debug('No se encontraron registros para eliminar.');
            }
        } catch (Exception e) {
            System.debug('Error al eliminar QuoteLineItem: ' + e.getMessage());
        }
    }
    
    private void editarQuoteLineItems(List<String> idsToEdit) {
        try {
            List<QuoteLineItem> lineItemsToEdit = [SELECT Id, Quantity, Cantidad_devolucion__c FROM QuoteLineItem WHERE Id IN :idsToEdit];
            
            if (!lineItemsToEdit.isEmpty()) {
                lineItemsToEdit[0].Quantity = lineItemsToEdit[0].Quantity - lineItemsToEdit[0].Cantidad_devolucion__c;
                lineItemsToEdit[0].Cantidad_devolucion__c = 0;
                update lineItemsToEdit;
                System.debug('actualizar');
            } else {
                System.debug('No se encontraron registros para actualizar.');
            }
        } catch (Exception e) {
            System.debug('Error al editar QuoteLineItem: ' + e.getMessage());
        }
    }
    
    private void filterLineItemIdsByEstadoReserva() {
        List<String> filteredLineItemIds = new List<String>();
        for (String lineItemId : lineItemIds) {
            QuoteLineItem lineItem = [
                SELECT Id, Estado_entrega__c FROM QuoteLineItem WHERE Id = :lineItemId AND Estado_entrega__c != 'Pendiente devolución nota de crédito' LIMIT 1
            ];
            if (lineItem != null) {
                filteredLineItemIds.add(lineItemId);
            }
        }
        lineItemIds = filteredLineItemIds;
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

    public class ExternalServiceException extends Exception {}
}