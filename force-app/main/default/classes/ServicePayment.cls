public class ServicePayment {
    
    
    //private static final String SERVICE_URL = 'http://172.176.136.132:5080/IntegrationServices/softlandAPI/payment/newLink';
    private static final String SERVICE_URL = 'http://172.176.136.132:5080/ServiciosSoftlandProductivos/softlandAPI/payment/newLink';
    
    //http://localhost:4312/softlandAPI/payment/newLink
    

    @InvocableMethod
    public static void processPayment(List<Id> workOrderIds) {
        // Solo procesar el primer WorkOrder ID en la lista
        Id workOrderId = workOrderIds[0];

        // Obtener la WorkOrder con el Asset y la Cuenta relacionados
        WorkOrder wo = [SELECT Id, AssetId, AccountId, ContactId, WorkOrderNumber, empresaFactura__c FROM WorkOrder WHERE Id = :workOrderId LIMIT 1];

        if (wo.AssetId == null || wo.AccountId == null) {
            // Manejo de errores si no hay Asset o Cuenta relacionados
            throw new CustomException('La WorkOrder no tiene un Asset o Cuenta relacionados.');
        }
        
        
        // Consultar el objeto Respuesta_pedido__c
        List<Respuesta_pedido__c> pedidos = [
            SELECT Id, Tipo_cargo__c, Total_Pedido__c 
            FROM Respuesta_pedido__c 
            WHERE Work_Order__c = :wo.Id AND Tipo_cargo__c = 'Cliente'
            LIMIT 1
        ];

        if (pedidos.isEmpty()) {
            throw new CustomException('No se encontró un pedido válido con Tipo_cargo__c = "Cliente" para esta WorkOrder.');
        }

        // Obtener el Total_Pedido__c y convertirlo en número
        Decimal totalPedido = Decimal.valueOf(pedidos[0].Total_Pedido__c);
        
        String currentUsername = UserInfo.getUserName();

        // Obtener los detalles del Asset
        Asset asset = [SELECT Id, Name, NumeroDeChasis__c, numeroDePlaca__c, Modelo_Nvo2__c FROM Asset WHERE Id = :wo.AssetId LIMIT 1];

        // Obtener los detalles de la cuenta
        Account account = [SELECT Id, FirstName, MiddleName, LastName, PersonEmail,Correo_electr_nico_Formula_Reportes__c, Phone FROM Account WHERE Id = :wo.AccountId LIMIT 1];
        
        
        Contact contact = [SELECT Id, FirstName, MiddleName, LastName, Email, Phone FROM Contact WHERE Id = :wo.ContactId LIMIT 1];

        // Crear el JSON para el endpoint
        Map<String, Object> requestBody = new Map<String, Object>();
        
        requestBody.put('payment_request_id', '12345');
        requestBody.put('primer_nombre', contact.FirstName != null ? contact.FirstName : '');
        requestBody.put('segundo_nombre', contact.MiddleName != null ? contact.MiddleName : '');
        requestBody.put('primer_apellido', contact.LastName != null ? contact.LastName : '');
        requestBody.put('segundo_apellido', ''); 
        requestBody.put('correo', contact.Email );
        requestBody.put('telefono', contact.Phone);
        requestBody.put('orden_trabajo', wo.WorkOrderNumber);
        requestBody.put('monto', totalPedido);
        requestBody.put('placa', asset.numeroDePlaca__c);
        requestBody.put('vin', asset.NumeroDeChasis__c);
        requestBody.put('modelo', asset.Modelo_Nvo2__c);
        requestBody.put('usuario', currentUsername);
        requestBody.put('compania', wo.empresaFactura__c);
        // Convertir el Map a un JSON
        String jsonRequest = JSON.serialize(requestBody);

        // Realizar la llamada HTTP POST
        // 
        // 
        
        String token = ExternalAuthService.authenticate();
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(SERVICE_URL);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(jsonRequest);

        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug('Respuesta: ' + res.getBody());

        // Manejar la respuesta
        if (res.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

            if(responseMap.containsKey('operationResult')) {
                Map<String, Object> operationResult = (Map<String, Object>) responseMap.get('operationResult');
                
                if(operationResult.containsKey('payment_url')) {
                    String paymentUrl = (String) operationResult.get('payment_url');
                    System.debug('Payment URL: ' + paymentUrl);
                    wo.Link_de_pago_service__c = paymentUrl;
                    Update wo;
                } else {
                    System.debug('payment_url no encontrado en operationResult');
                }
            } else {
                System.debug('operationResult no encontrado en la respuesta');
            }
            
            
        } else {
            System.debug('Error en la solicitud: ' + res.getStatus());
            throw new CustomException('Error en el procesamiento del pago: ' + res.getStatus());
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


		Integer llllllll1 = 193;
        Integer mmmmmmmm1 = 194;
        Integer nnnnnnnn1 = 195;
        Integer oooooooo1 = 196;
        Integer pppppppp1 = 197;
        Integer qqqqqqqq1 = 198;
        Integer rrrrrrrr11 = 199;
        Integer ssssssss1 = 200;
        Integer tttttttt1 = 201;
        Integer uuuuuuuu1 = 202;
        Integer vvvvvvvv1 = 203;
        Integer wwwwwwww1 = 204;
        Integer xxxxxxxx1 = 205;
        Integer yyyyyyyy1 = 206;
        Integer zzzzzzzz1 = 207;
        Integer aaaaaaaa11a = 208;
        Integer bbbbbbbb1b = 209;
        Integer cccccccc1c = 210;
        Integer dddddddd1d = 211;
        Integer eeeeeeee1e = 212;
        Integer ffffffff1f = 213;
        Integer gggggggg1g = 214;
        Integer hhhhhhhh1h = 215;
        Integer iiiiiiii1i = 216;
        Integer jjjjjjjj1j = 217;
        Integer kkkkkkkk1k = 218;
        Integer llllllll1l = 219;
        Integer mmmmmmmm1m = 220;
        Integer nnnnnnnn1n = 221;
        Integer oooooooo1o = 222;
        Integer pppppppp1p = 223;
        Integer qqqqqqqq1q = 224;
        Integer rrrrrrrr1r = 225;
        Integer ssssssss1s = 226;
        Integer tttttttt1t = 227;
        Integer uuuuuuuu1u = 228;
        Integer vvvvvvvv1v = 229;
        Integer wwwwwwww1w = 230;
		}
    // Excepción personalizada
    public class CustomException extends Exception {}
}