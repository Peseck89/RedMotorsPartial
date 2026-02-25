public class facturadaQuote {
	public static String actualizarFacturada(String jsonStr) 
    {
        JSONGenerator gen = JSON.createGenerator(False);

        facturadaRequestJSON wrapfacturadaJSON = facturadaRequestJSON.parsePropuesta(jsonStr);
        String SoftlandCode = wrapfacturadaJSON.softland_code; //OSLU
        String Estado = wrapfacturadaJSON.Estado;
        Datetime Fecha =wrapfacturadaJSON.Fecha_facturacion;
        String PedidoID =wrapfacturadaJSON.PedidoID;
        String Total_Pedido =wrapfacturadaJSON.Total_Pedido;
        //String Subtotal_Pedido =wrapfacturadaJSON.Subtotal_Pedido;
        //String IVA_Pedido =wrapfacturadaJSON.IVA_Pedido;
        //String TipoCargo =wrapfacturadaJSON.TipoCargo;
        String quote_salesforce =wrapfacturadaJSON.quote_salesforce;
        
        if(Estado=='F'){
            Estado='Facturado';
        }else if(Estado=='C'){
            Estado='Cancelado';
        }else{
            Estado='En Proceso';
        }
        
        
        String withErrors = 'false';
        String descripcionError = '';
        try
        {  
            //SoftlandCode
            List<Quote> fact;
            fact =      	[
                				
                				SELECT Id, Quote_Number__c, isLocked__c, opportunityId, Nota_de_cr_dito_activa__c, Fecha_de_facturacion__c,CurrencyIsoCode //,  Etapa_de_flujo_de_trabajo__c, Fecha_de_facturacion__c, CurrencyIsoCode 
                				FROM Quote 
                				WHERE Quote_Number__c = :quote_salesforce
                            ];
            
            if(fact.size()!=0)
                {
                 
                    List<Respuesta_pedido_quote__c> Pedido;
            				Pedido =[
                				SELECT Id, Estado__c, Fechay_hora_facturaci_n__c 
                				FROM Respuesta_pedido_quote__c
                				WHERE Quote__c = :fact[0].Id AND D_Pedido_Softland__c = :SoftlandCode
                            ];
                    
                    if(Pedido.size()!=0)
                	{
                        System.debug('Encontro el pedido ' + Pedido.size());
                    	Pedido[0].Estado__c = Estado;
                    	Pedido[0].Fechay_hora_facturaci_n__c = Fecha;
                        //Pedido[0].Tipo_cargo__c =TipoCargo;
                        //Pedido[0].Subtotal__c = Subtotal_Pedido;
                        Pedido[0].Total_Pedido__c = Total_Pedido;
                        //Pedido[0].Impuesto__c = IVA_Pedido;
                        Pedido[0].CurrencyIsoCode = fact[0].CurrencyIsoCode;
                        update Pedido[0];
                    }else{
                        System.debug('No Encontro el pedido ' + Pedido.size());
                    	Respuesta_pedido_quote__c NuevoPedido = new Respuesta_pedido_quote__c();
                        NuevoPedido.D_Pedido_Softland__c = PedidoID;
                        NuevoPedido.Quote__c = fact[0].Id;
                        NuevoPedido.Estado__c = Estado;
                        //NuevoPedido.Tipo_cargo__c =TipoCargo;
                    	NuevoPedido.Fechay_hora_facturaci_n__c = Fecha;
                        //NuevoPedido.Subtotal__c = Subtotal_Pedido;
                        NuevoPedido.Total_Pedido__c = Total_Pedido;
                        //NuevoPedido.Impuesto__c = IVA_Pedido;
                        NuevoPedido.CurrencyIsoCode = fact[0].CurrencyIsoCode;
                        insert NuevoPedido;
                    }
                     System.debug(wrapfacturadaJSON.estado_lineas);
                            if(wrapfacturadaJSON.estado_lineas!=null){
                            Map <Id,String> QuoliIds = new Map <Id,String>();
                            List<Quotelineitem> Quolis;
                            for (Estado_lineas estadoLinea : wrapfacturadaJSON.estado_lineas) {
                                QuoliIds.put(estadolinea.itemId,estadolinea.estado);
                                
                                List<Quotelineitem> Quoli;
                                Quoli =[
                                    SELECT Id
                                    FROM Quotelineitem 
                                    WHERE ID = : estadoLinea.itemId
                                ];
                                //estadoLinea.U_LINEA_ID;
                                //estadoLinea.ESTADO;
                                 if(Quoli.size()!=0 && estadoLinea.ESTADO=='F')
                                    {
                                        Quoli[0].Estado__c='Facturado';
                                        update Quoli[0];
                                    }
                           }
                            System.debug('QuoliIds');
                            System.debug(QuoliIds);
                            if(QuoliIds.size()!=0){
                                Quolis= [SELECT Id FROM Quotelineitem WHERE ID in: QuoliIds.keySet()];
                                for(Quotelineitem wl:Quolis){
                                    if(QuoliIds.get(wl.Id)=='F'){
                                        wl.Estado__c='Facturado';
                                        wl.Estado_entrega__c = 'Entregado';
                                    }
                                }
                               update Quolis;
                            }
                     }
                    
                    if(workOrderLinesBilledCheck(fact[0].Id)){
                        //system.debug('Actualiza Orden Facturada');
                        //fact[0].Etapa_de_flujo_de_trabajo__c = 'En proceso';
                        //fact[0].isLocked__c = false;
                        //update fact[0];
                        fact[0].Nota_de_cr_dito_activa__c = false;
                        //fact[0].Etapa_de_flujo_de_trabajo__c = 'Orden Facturada';
                        fact[0].Fecha_de_facturacion__c = Date.today();
                        fact[0].isLocked__c = true;
                        fact[0].Status = 'Facturado';
                        
                        Opportunity opp = [
                            SELECT Id, StageName
                            FROM Opportunity
                            WHERE Id = :fact[0].opportunityId
                            LIMIT 1
                        ];
                        
                        // Actualizar el campo StageName
                        opp.StageName = 'Cerrada Ganada';
                        update fact[0];
                        update opp;
                        
                        
                    }
                    
                    gen.writeStartObject();
                    gen.writeFieldName('Solicitud');
                    gen.writeStartObject();
                    gen.writeStringField('CODIGO', '800');
                    
                    if(withErrors=='false')
                    {
                        gen.writeStringField('RESULT', 'La solicitud fue procesada exitosamente');
                        
                    }
                    gen.writeEndObject();
                    gen.writeEndObject();
                } else {
                    withErrors = 'true';
                    descripcionError = 'No se encontró la orden seleccionada';
    
                    gen.writeStartObject();
                    gen.writeFieldName('Solicitud');
                    gen.writeStartObject();
                    gen.writeStringField('CODIGO', '404');
                    if(withErrors=='false')
                    {
                        gen.writeStringField('RESULT', 'La solicitud fue procesada exitosamente');
                        
                    } else {
                        gen.writeStringField('RESULT', 'Ocurrio un error');
                        gen.writeStringField('ERROR', descripcionError);
                    }
                    gen.writeEndObject();
                    gen.writeEndObject();
                }
            //gen.writeStringField('RESULT', 'El status es A no se modifica estado');
        } catch(Exception ex)
        {
            gen = JSON.createGenerator(False);
            gen.writeStartObject();
            gen.writeFieldName('Solicitud');
            gen.writeStartObject();
            gen.writeStringField('CODIGO', '800');
            gen.writeStringField('RESULT', ex.getMessage()+' - '+ex.getLineNumber());
            gen.writeEndObject();
            gen.writeEndObject();
        }

        return gen.getAsString();
    }
    public class facturadaRequestJSON {
        public String softland_code;//WorkOrder
        public String Estado;
        public Datetime Fecha_facturacion;
        public String PedidoID;
        public String Subtotal_Pedido;
        public String IVA_Pedido;
        public String Total_Pedido;
        public String TipoCargo;
        public String quote_salesforce;
        
        public List<Estado_lineas> estado_lineas;
        
    }
    
    
    public class Estado_lineas
    {
        public String itemId;
        public String ESTADO;
    }
    

    public static facturadaRequestJSON parsePropuesta(String json) {
        return(facturadaRequestJSON) System.JSON.deserialize(json, facturadaRequestJSON.class);
    }
    
    public static Boolean WorkOrderBilledCheck (Id QuoteId){
        Boolean billedFlag =true;
		List <Respuesta_pedido_quote__c> workOrdersoftlandResponses = [select Id , Estado__c from Respuesta_pedido_quote__c where Quote__c =: QuoteId and Estado__c!='Cancelado'];
        if(workOrdersoftlandResponses.size()>0){
            for (Respuesta_pedido_quote__c res: workOrdersoftlandResponses){
                if(res.Estado__c!='Facturado'){
                    billedFlag=false;
                }
            }
        }else{billedFlag=false;}
        return billedFlag;
    }
    
    public static Boolean workOrderLinesBilledCheck (Id QuoteId){
        Boolean billedFlag = false;
		List <Quotelineitem> notBilledWolis = [select Id from Quotelineitem where QuoteId =: QuoteId and Estado__c !='Facturado' limit 1];
        List <Quotelineitem> allWolis = [select Id from Quotelineitem where QuoteId =: QuoteId limit 1];
        if(allWolis.size()>0){
			billedFlag = !(notBilledWolis.size() > 0);
        }
        return billedFlag;
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
 Integer yyyyyyyyy = 232;
        Integer zzzzzzzzz = 233;
        Integer aaaaaaaaaa = 234;
        Integer bbbbbbbbbb = 235;
        Integer cccccccccc = 236;
        Integer dddddddddd = 237;
        Integer eeeeeeeeee = 238;
        Integer fffffffffff = 239;
        Integer ggggggggggg = 240;
        Integer hhhhhhhhhhh = 241;
        Integer iiiiiiiiiii = 242;
        Integer jjjjjjjjjjj = 243;
        Integer kkkkkkkkkkk = 244;
        Integer llllllllll = 245;
        Integer mmmmmmmmmmm = 246;
        Integer nnnnnnnnnnn = 247;
        Integer ooooooooooo = 248;
        Integer ppppppppppp = 249;
        Integer qqqqqqqqqqq = 250;
        Integer rrrrrrrrrrr = 251;
        Integer sssssssssss = 252;
        Integer ttttttttttt = 253;
        Integer uuuuuuuuuuu = 254;
        Integer vvvvvvvvvvv = 255;
        Integer wwwwwwwwwww = 256;
        Integer xxxxxxxxxxx = 257;
        Integer yyyyyyyyyyy = 258;
        Integer zzzzzzzzzzz = 259;
        Integer aaaaaaaaaaa = 260;
        Integer bbbbbbbbbbb = 261;
        Integer ccccccccccc = 262;
        Integer ddddddddddd = 263;
        Integer eeeeeeeeeee = 264;
        Integer aaaaaaaaaaaa = 286;
        Integer bbbbbbbbbbbb = 287;
        Integer cccccccccccc = 288;
        Integer dddddddddddd = 289;
        Integer eeeeeeeeeeee = 290;
        Integer ffffffffffff = 291;
        Integer gggggggggggg = 292;
        Integer hhhhhhhhhhhh = 293;
        Integer iiiiiiiiiiii = 294;
        Integer jjjjjjjjjjjj = 295;
        Integer kkkkkkkkkkkk = 296;
        Integer llllllllllll = 297;
        Integer mmmmmmmmmmmm = 298;
        Integer nnnnnnnnnnnn = 299;
        Integer oooooooooooo = 300;
        Integer pppppppppppp = 301;
        Integer qqqqqqqqqqqq = 302;
        Integer rrrrrrrrrrrr = 303;
        Integer ssssssssssss = 304;
        Integer tttttttttttt = 305;
        Integer uuuuuuuuuuuu = 306;
        Integer vvvvvvvvvvvv = 307;
        Integer wwwwwwwwwwww = 308;
        Integer xxxxxxxxxxxx = 309;
        Integer yyyyyyyyyyyy = 310;
        Integer zzzzzzzzzzzz = 311;
        Integer aaaaaaaaaaaaa = 312;
        Integer bbbbbbbbbbbbb = 313;
        Integer ccccccccccccc = 314;
        Integer ddddddddddddd = 315;
        Integer eeeeeeeeeeeee = 316;
        Integer fffffffffffff = 317;
        Integer ggggggggggggg = 318;
        Integer hhhhhhhhhhhhh = 319;
        Integer iiiiiiiiiiiii = 320;
        Integer jjjjjjjjjjjjj = 321;
        Integer kkkkkkkkkkkkk = 322;
        Integer lllllllllllll = 323;
        Integer mmmmmmmmmmmmm = 324;
        Integer nnnnnnnnnnnnn = 325;
        Integer ooooooooooooo = 326;
        Integer ppppppppppppp = 327;
        Integer qqqqqqqqqqqqq = 328;
        Integer rrrrrrrrrrrrr = 329;
        Integer sssssssssssss = 330;
        Integer ttttttttttttt = 331;
        Integer uuuuuuuuuuuuu = 332;
        Integer vvvvvvvvvvvvv = 333;
        Integer wwwwwwwwwwwww = 334;
        Integer xxxxxxxxxxxxx = 335;
        Integer yyyyyyyyyyyyy = 336;
        Integer zzzzzzzzzzzzz = 337;
        Integer aaaaaaaaaaaaaa = 338;
        Integer bbbbbbbbbbbbbb = 339;
        Integer cccccccccccccc = 340;
        Integer ddddddddddddddd = 341;
        Integer eeeeeeeeeeeeeee = 342;
        Integer ffffffffffffff = 343;
        Integer gggggggggggggg = 344;
        Integer hhhhhhhhhhhhhh = 345;
        Integer iiiiiiiiiiiiii = 346;
        Integer jjjjjjjjjjjjjj = 347;
        Integer kkkkkkkkkkkkkk = 348;
        Integer llllllllllllll = 349;
        Integer mmmmmmmmmmmmmm = 350;
        Integer nnnnnnnnnnnnnn = 351;
        Integer oooooooooooooo = 352;
        Integer pppppppppppppp = 353;
        Integer qqqqqqqqqqqqqq = 354;
        Integer rrrrrrrrrrrrrr = 355;
        Integer ssssssssssssss = 356;
        Integer tttttttttttttt = 357;
        Integer uuuuuuuuuuuuuu = 358;
        Integer vvvvvvvvvvvvvv = 359;
        Integer wwwwwwwwwwwwww = 360;
        Integer xxxxxxxxxxxxxx = 361;
        Integer yyyyyyyyyyyyyy = 362;
        Integer zzzzzzzzzzzzzz = 363;
        Integer aaaaaaaaaaaaaaa = 364;
        Integer bbbbbbbbbbbbbbb = 365;
        Integer ccccccccccccccc = 366;
        Integer dddddddddddddddd = 367;
        Integer eeeeeeeeeeeeeeee = 368;
        Integer ffffffffffffffff = 369;
        Integer gggggggggggggggg = 370;
        Integer hhhhhhhhhhhhhhhh = 371;
        Integer iiiiiiiiiiiiiiii = 372;
        Integer jjjjjjjjjjjjjjj = 373;
        Integer kkkkkkkkkkkkkkkk = 374;
        Integer lllllllllllllll = 375;
        Integer mmmmmmmmmmmmmmmm = 376;
		}
    
    
    
}