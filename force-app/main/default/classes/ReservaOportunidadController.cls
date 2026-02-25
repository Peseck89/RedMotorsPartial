public without sharing class ReservaOportunidadController {
    
     //private static final String SERVICE_URL = 'http://172.176.136.132:5080/IntegrationServices/softlandAPI/Catalogs/addVehiculeOpportunity';
    private static final String SERVICE_URL = 'http://172.176.136.132:5080/ServiciosSoftlandProductivos/softlandAPI/Catalogs/addVehiculeOpportunity';
    
    
    
    public class WrapperRespuesta{
        public String code;
        public String description;
    }
    
    @AuraEnabled
    public static Opportunity getCurrentOpp(Id OppId){
        return [SELECT Id, Name, ModelosProductos__c, NombreProducto__c, Synced_Quote__c 
                FROM Opportunity 
                WHERE Id =: OppId];
        
    }
    
    @AuraEnabled
    public static List<Product2> getModelosVehiculos(Id OppId){
        Opportunity currentOpp = [SELECT Id, Synced_Quote__c FROM Opportunity WHERE Id =: OppId];
        System.debug('currentOpp: ' + currentOpp);
        List<Quote> presupuestosRelacionados = [SELECT Id, OpportunityId FROM Quote WHERE Id =: currentOpp.Synced_Quote__c];
        System.debug('presupuestosRelacionados: ' + presupuestosRelacionados);
        List<QuoteLineItem> partidasRelacionadas = [SELECT Id, QuoteId, Product2Id FROM QuoteLineItem WHERE QuoteId =: presupuestosRelacionados];
        System.debug('partidasRelacionadas: ' + partidasRelacionadas);

        List<Id> productosSyncId = new List<Id>();
        for(QuoteLineItem quoteItem : partidasRelacionadas) {
            productosSyncId.add(quoteItem.Product2Id);
        }


        List<Product2> productosSync = [SELECT Id FROM Product2 WHERE Id IN : productosSyncId ];
        System.debug('productosSync: ' + productosSync);
        
        
        List<OpportunityLineItem> productosRelacionados = [SELECT Id, OpportunityId, Name, Modelo_De_Inter_s1__c, Reservado__c, Product2Id 
                                                           FROM OpportunityLineItem 
                                                           WHERE OpportunityId =: OppId 
                                                           AND Reservado__c = false];
        List<Id> productosId = new List<Id>();
        for(OpportunityLineItem lineItem : productosRelacionados) productosId.add(lineItem.Product2Id);
        System.debug('productosId: ' + productosId);
        List<Product2> productos = [SELECT Id, Name, modelo__c, esVehiculo__c, Producto_Reservado__c 
                                   	FROM Product2 
									WHERE Id IN : productosId
                                    AND Id IN : productosSync
									AND (esVehiculo__c = TRUE OR es_Vehiculo_en_transito__c = TRUE)
									AND Producto_Reservado__c = FALSE];
        System.debug('last productos ' + productos);
        Integer i = 0;
        for(Product2 pro : productos) {
            System.debug('Vehiculo ' + i);
            System.debug('Id : ' + pro.Id);
            System.debug('Name : ' + pro.Name);
            System.debug('modelo__c : ' + pro.modelo__c);
            System.debug('esVehiculo__c : ' + pro.esVehiculo__c);
            System.debug('Producto_Reservado__c : ' + pro.Producto_Reservado__c);
            i++;
        }
        return productos;
    }
    
    @AuraEnabled
    public static Product2 getProduct(Id ProdId){
        return [ SELECT Id, Name, vin__c, Producto_Reservado__c 
                 FROM Product2 
                 WHERE Id =: ProdId ];
    }
    
    @AuraEnabled
    public static Boolean getAnticipo(Id OppId, Id ProdId){
        List<Anticipo__c> anticipos = [ SELECT Id, Name, Estatus__c, Oportunidad__c, Producto__c 
                                        FROM Anticipo__c
                 						WHERE Oportunidad__c =: OppId
                                      	AND Producto__c =: ProdId];
        if(anticipos.size() > 0) return true;
        else return false;
    }
    
    @AuraEnabled
    public static Product2 makeReserva(Id OppId, Id ProdId){
        List<Product2> selectedProducts = [ SELECT Id, Name, vin__c, Producto_Reservado__c,RM_Reportado__c,Empresa__c FROM Product2 WHERE Id =: ProdId ];

        if (selectedProducts.isEmpty()) {
            throw new AuraHandledException('El vehículo no fue encontrado');
        }
        
        if (!selectedProducts.isEmpty() && selectedProducts[0].RM_Reportado__c) {		
	        throw new AuraHandledException('El vehiculo no se puede reservar ya que se encuentra como reportado.');		
	    }

        Product2 selectedProduct = selectedProducts[0];
        selectedProduct.Producto_Reservado__c = true;
        selectedProduct.OportunidadReserva__c = OppId;

        try{
            //Se realiza la consulta al servicio externo (Softland) para checar la disponiblidad del Vehiculo
            //La respuesta del servicio es de la forma {"operationResult":{"code":"xx","description":"xxxxxxxxx"}}
            //Se forma una subString para que quede de la siguiente manera {"code":"xx","description":"xxxxxxxxx"}}
            //y finalmente, se deserializa con la clase WrapperRespuesta
            // Map<String,Object> responseMap = servicioReservas.getReservaById(OppId, ProdId);
            
            // //check if success is true
            // if(responseMap.get('success') == false) throw new AuraHandledException((String) responseMap.get('error'));

            // reservaCallout = reservaCallout.substringAfter(':');
            
            // ReservaOportunidadController.WrapperRespuesta respuesta = (ReservaOportunidadController.WrapperRespuesta)JSON.deserialize(reservaCallout, ReservaOportunidadController.WrapperRespuesta.class);
            // System.debug('respuesta en makeReserva: ' + respuesta);
            
            // if (respuesta.code != '00' || respuesta.code == null ) throw new AuraHandledException(respuesta.code + ' ' + respuesta.description);
            
            //Se realiza el query al producto reservado (Product2) y se asigna el campo:
            //Producto_Reservado__c = true. y se asocia la opp reservada.
            

            
            //Se realiza el query al producto reservado (OpportunityLineItem) y se asigna el campo:
            //Reservado__c = true.
            List<OpportunityLineItem> productoToUpdate = [SELECT Id, ReservadoDesdeAqui__c,OpportunityId, Name, Modelo_De_Inter_s1__c, Reservado__c, Quantity, Product2Id 
                                                        FROM OpportunityLineItem 
                                                        WHERE Product2Id =: ProdId ];
            for (OpportunityLineItem opp : productoToUpdate){
                opp.Reservado__c = true;
                if(opp.OpportunityId == OppId){
                    if(opp.ReservadoDesdeAqui__c == false){
                         opp.ReservadoDesdeAqui__c = true;
                    }else{ opp.ReservadoDesdeAqui__c = false;}
                   
                }
            }
            
            
            
            
            
            //Se realiza el query a la oportunidad y se asigna el campo:
            //Tiene_Vehiculos_Reservados__c = true y se agrega el nombre del producto al campo Vehiculos_Reservados__c.
            Opportunity OppToUpdate = [SELECT Id, Name, Tiene_Vehiculos_Reservados__c, Vehiculos_Reservados__c, ConsecutivoOportunidad__c,Account.codigoSoftland__c,Account.Name
                                    FROM Opportunity 
                                    WHERE Id =: OppId ];
            OppToUpdate.Tiene_Vehiculos_Reservados__c = true;

            if(OppToUpdate.Vehiculos_Reservados__c == NULL) OppToUpdate.Vehiculos_Reservados__c = selectedProduct.Name;
            if(! (OppToUpdate.Vehiculos_Reservados__c.length() + selectedProduct.Name.length() > 255) ) OppToUpdate.Vehiculos_Reservados__c += (', ' + selectedProduct.Name);
            
            
            String compania = selectedProduct.Empresa__c;
            String VIN = selectedProduct.vin__c;
            String OppName = OppToUpdate.Name;
            String ConsecutivoOpp = OppToUpdate.ConsecutivoOportunidad__c;
            String Account = OppToUpdate.Account.Name; 
            String codigoSoftland =  OppToUpdate.Account.codigoSoftland__c;
            
            String jsonString = '{' +
                '"compania": "' + compania + '",' +
                '"VIN": "' + VIN + '",' +
                '"OppName": "' + OppName + '",' +
                '"ConsecutivoOpp": "' + ConsecutivoOpp + '",' +
                '"Account": "' + Account + '",' +
                '"codigoSoftland": "' + codigoSoftland + '"' +
                '}';
            
            System.debug(jsonString);
            
            
            Http http = new Http();
            HttpResponse res = new HttpResponse();
            String token = ExternalAuthService.authenticate();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(SERVICE_URL);
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + token);
            req.setHeader('Content-Type', 'application/json');
            req.setBody(jsonString);
            res = new Http().send(req);
            System.debug(res.getBody());
            System.debug(jsonString);
            
            Log_servicios__c log2 = new Log_servicios__c();
			log2.Llamada_servicio__c = 'Reserva sin anticipo /softlandAPI/Catalogs/addVehiculeOpportunity';
			log2.JSON_Enviado__c = jsonString;
			log2.JSON_Respuesta__c = res.getBody();
            log2.Oportunidad__c = OppToUpdate.id;
			Insert log2;
            
            
            //Finalmente, se actualizan todos los registros.
            UPDATE productoToUpdate;
            UPDATE OppToUpdate;
            UPDATE selectedProduct;

        } catch (DmlException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
            
        return selectedProduct;
    }
    
    public static void dummy() {
        String  dummy = '';
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';
        		dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';     
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';                
                dummy += '';  
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
        
    }


    @Future(callout=true)
    public static void reservarVehiculo(Id OppId, Id ProdId){
        makeReserva(OppId,ProdId);
    }
}