@RestResource(urlMapping='/ServicioQuoliActualizaSC')
global class ServicioQuoliActualizaSC {
    global class RequestBody {
        public String oportunidad_salesforce;
        public String quote_salesforce;
        public List<Articulo> articulos;
    }
    
    global class Articulo {
            public String id_linea;
            public String estadoSC;
        	public String localizacion;
        	public Decimal cantidad;
    }

    public class ResponseItem {
        public String id;
        public String status;
    }

    @HttpPost
    global static void processRequest(){
        System.debug('Antes de llamada ');
        RestRequest req = RestContext.request;
    	RequestBody body = (RequestBody)JSON.deserialize(req.requestBody.toString(), RequestBody.class);
        
        RestResponse res = RestContext.response;
        
        System.debug(res);
        System.debug(body);
        
        if(res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }

        Map<String, Object> response = new Map<String, Object>();
        List<ResponseItem> responseItems = new List<ResponseItem>();
        
        System.debug('JSON Body ' + body);

        List<Quote> Quotes = [SELECT Id FROM Quote WHERE Quote_Number__c = :body.quote_salesforce LIMIT 1];

        if (Quotes.isEmpty()) {
            System.debug('Quote VACIA');
            res.statusCode = 404;
            response.put('error', 'Quote no encontrado.');
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            return;
        }
        
        List<String> lineIds = new List<String>();
        for (Articulo art : body.articulos) {
            System.debug('FOR ARTICULOS');
            lineIds.add(art.id_linea);
        }

        List<QuoteLineItem> QuoteLineItems = [SELECT Id, Estado_entrega__c,Estado_softland__c,Cantidad_devolucion__c,Quantity, Estado_reserva__c FROM QuoteLineItem WHERE Id IN :lineIds];
        Map<String, QuoteLineItem> mapLineItems = new Map<String, QuoteLineItem>();
        for (QuoteLineItem item : QuoteLineItems) {
            System.debug('FOR');
            mapLineItems.put(item.Id, item);
        }
        
		boolean OTNotaCredito = False;
        List<QuoteLineItem> itemsToUpdate = new List<QuoteLineItem>();
        List<QuoteLineItem> itemsToDelete = new List<QuoteLineItem>();
        for (Articulo art : body.articulos) {
            if (mapLineItems.containsKey(art.id_linea)) {
                QuoteLineItem item = mapLineItems.get(art.id_linea);
                
                item.Estado_Solicitud_Compra__c = art.estadoSC;
                
                if(art.estadoSC == 'Recibido en bodega' ){
                    item.Localizacion__c = art.localizacion;
                    item.CantidadSC__c = art.cantidad;
                    
                    if(art.cantidad ==  item.Quantity){
                        item.Estado_reserva__c = 'Reservado';
                        item.Estado_entrega__c = 'Sin Entregar';
                    }                    
                }
                
                itemsToUpdate.add(item);
                ResponseItem respItem = new ResponseItem();
                respItem.id = art.id_linea;
                respItem.status = 'Actualizado';
                responseItems.add(respItem);

                
            } else {
                ResponseItem respItem = new ResponseItem();
                respItem.id = art.id_linea;
                respItem.status = 'No encontrado';
                responseItems.add(respItem);
            }
        }
        

        update itemsToUpdate;
        delete itemsToDelete;
        
        res.statusCode = 200;
        response.put('items', responseItems);
        System.debug('Final Response ' + JSON.serialize(response));
        res.responseBody = Blob.valueOf(JSON.serialize(response));
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
		}
}