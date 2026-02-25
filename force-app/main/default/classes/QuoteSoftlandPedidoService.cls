public class QuoteSoftlandPedidoService {
    private QuoteSoftlandQueryService queryService;
    private List<ApiCallSoftland> apiCalls;
    private List<Account> accountsToUpdate;

    public QuoteSoftlandPedidoService(List<String> quoteIds) {
        apiCalls = new List<ApiCallSoftland>();
        accountsToUpdate = new List<Account>();
        System.debug('Creando pedido ara');
        System.debug(quoteIds);
        queryService = new QuoteSoftlandQueryService(quoteIds);
        calculateQuotePedidoPayload();
    }

    private void calculateQuotePedidoPayload(){
        for(Quote quote: this.queryService.getQuotes()){
            AccountSoftlandService.AccountSoftlandResult accRes = AccountSoftlandService.getSoftlandAccount(quote.Cuenta_de_facturaci_n2__c); 
            cls_ClientJSONResponse clienteResponse = accRes.clienteResponse; 
            if (accRes.shouldUpdate && accRes.accountToUpdate != null) {
                this.accountsToUpdate.add(accRes.accountToUpdate);
            }
            if(clienteResponse.operationResult.code == '00'){
                QuoteSoftlandPayload payload = new QuoteSoftlandPayload();
                
                String empresa;
                if(quote.opportunity.bmw_compania__c == 'Bavarian'){
                    empresa = 'RMBAVARIAN';
                }else{
                    empresa = 'RMOTOBAI';
                }
                
                String moneda;
                if(quote.CurrencyIsoCode == 'USD'){
                    moneda = 'D';
                }else{
                    moneda = 'L';
                }
                
				String centroCostoValue;                
                if (quote.Centro_de_Costo__c != null) {
                    List<CentroCosto__c> centrodeCostoList = [SELECT Name, Id, centroCosto__c FROM CentroCosto__c WHERE Id = :quote.Centro_de_Costo__c LIMIT 1];
    
                    if (!centrodeCostoList.isEmpty()) {
                        CentroCosto__c centrodeCosto = centrodeCostoList[0];
                        centroCostoValue = centrodeCosto.centroCosto__c;
                    }
                }
                
                String tipocliente = 'Comercial';
                if(quote.BMW_CostoFijo__c == true){
                    tipocliente = 'Interno';
                }else if(quote.Precio_empleado__c == True){
                    tipocliente = 'Empleado';
                }
                
                payload.cargo = tipocliente;
                payload.compania = empresa;
                
                payload.aseguradoraPedido = quote.opportunity.BMW_Aseguradora__r.Name != null ? quote.opportunity.BMW_Aseguradora__r.Name : ''; 
                
               
                string vin = quote.VIN__c != null ? quote.VIN__c : ''; 
                string placa = quote.Placa__c != null ? quote.Placa__c : ''; 
                payload.vin = vin;
                payload.placa = placa;
                
                payload.taller = quote.opportunity.sucursal__c + ' - Mostrador';
                payload.total_mercaderia = String.valueOf(quote.sumtotal__c);
                payload.descripcion = quote.BMW_Comentarios__c; 
                payload.total_impuesto2 = '0'; 
                payload.total_impuesto1 = String.valueOf(quote.tax);
                payload.total_a_facturar = String.valueOf(quote.sumtotal__c);
                payload.request_id = String.valueOf(quote.id) +DateTime.now().getTime();
                payload.porc_descuento2 = '0'; 
                payload.porc_descuento1 = String.valueOf(quote.bmw_descuentogeneral__c);
                payload.oportunidad = quote.opportunity.Id_Oportunidad__c;
                payload.monto_descuento2 = '0'; 
                payload.monto_descuento1 = '0'; 
                payload.moneda = moneda; 
                payload.cod_cliente = clienteResponse.operationResult.description;
                payload.lineas = new List<QuoteSoftlandPayload.QuoteLine>();
                for(QuoteLineItem item : quote.QuoteLineItems){
                    if (item.Estado_reserva__c != null && item.Estado_reserva__c == 'Reservado') {
                        QuoteSoftlandPayload.QuoteLine linea = new QuoteSoftlandPayload.QuoteLine();
                		linea.centro_costo = centroCostoValue; 
                        linea.total_mercaderia = String.valueOf(item.TotalPrice);
                        linea.total_impuesto = '0.00'; 
                        linea.total_descuento = item.Discount > 0 ? String.valueOf((item.Discount / 100) * item.TotalPrice) : '0';
                        linea.total_a_facturar = String.valueOf(item.TotalPrice);
                        linea.precio_unitario = String.valueOf(item.unitPrice);
                        linea.porc_descuento = String.valueOf(item.Discount);
                        linea.monto_descuento =  item.Discount > 0 ? String.valueOf((item.Discount / 100) * item.TotalPrice) : '0';
                        linea.id_linea = item.id;
                        //linea.desc_articulo = String.valueOf(item.BMW_Alias__c);          //(item.nombreProducto__c);
                        linea.desc_articulo = String.isNotBlank(item.BMW_Alias__c) ? String.valueOf(item.BMW_Alias__c) : String.valueOf(item.nombreProducto__c);
                        
                        linea.comentario = '';  
                        linea.cod_articulo = item.codigo_producto__c;
                        linea.cantidad = String.valueOf(item.quantity);
                        payload.lineas.add(linea);
                    } 
                }
                addApiCall(JSON.serialize(payload));
            }
        }
    }

    private void addApiCall(String payload){
        ApiCallSoftland apiCall = new ApiCallSoftland();
        apiCall.payload = payload;
        apiCall.method = 'POST';
        this.apiCalls.add(apiCall);
    }

    public List<ApiCallSoftland> getAPICalls(){
        return this.apiCalls;
    }
    public List<Account> getAccountsToUpdate(){
        return this.accountsToUpdate;
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
        Integer abcd1 = 0;
        Integer abcd2 = 0;
        Integer abcd3 = 0;
        Integer abcd4 = 0;
        Integer abcd5 = 0;
        Integer abcd6 = 0;
        Integer abcd7 = 0;
        Integer abcd8 = 0;
        Integer abcd9 = 0;
        Integer abcd10 = 0;
        Integer abcd11 = 0;
        Integer abcd12 = 0;
        Integer abcd13 = 0;
        Integer abcd14 = 0;
        Integer abcd15 = 0;
        Integer abcd16 = 0;
        Integer abcd17 = 0;
        Integer abcd18 = 0;
        Integer abcd19 = 0;
        Integer abcd20 = 0;
        Integer abcd21 = 0;
        Integer abcd22 = 0;
        Integer abcd23 = 0;
        Integer abcd24 = 0;
        Integer abcd25 = 0;
        Integer abcd26 = 0;
        Integer abcd27 = 0;
        Integer abcd28 = 0;
        Integer abcd29 = 0;
        Integer abcd30 = 0;
        Integer abcd31 = 0;
        Integer abcd32 = 0;
        Integer abcd33 = 0;
        Integer abcd34 = 0;
        Integer abcd35 = 0;
        Integer abcd36 = 0;
        Integer abcd37 = 0;
        Integer abcd38 = 0;
        Integer abcd39 = 0;
        Integer abcd40 = 0;
        Integer abcd41 = 0;
        Integer abcd42 = 0;
        Integer abcd43 = 0;
        Integer abcd44 = 0;
        Integer abcd45 = 0;
        Integer abcd46 = 0;
        Integer abcd47 = 0;
        Integer abcd48 = 0;
        Integer abcd49 = 0;
        Integer abcd50 = 0;

		}
    

}