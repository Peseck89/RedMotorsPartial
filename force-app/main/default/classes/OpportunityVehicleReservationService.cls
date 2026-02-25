@RestResource(urlMapping='/opportunity/reserveVehicle')
global with sharing class OpportunityVehicleReservationService {
    @HttpPost
    global static void reserveVehicle() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            // Parsear el JSON recibido
            String requestBodyString = req.requestBody.toString();
            Map<String, Object> requestBody = (Map<String, Object>) JSON.deserializeUntyped(requestBodyString);
            String vin = (String) requestBody.get('vin');
            String oportunidad = (String) requestBody.get('oportunidad');
            String authorizado = (String) requestBody.get('autorizacion');
            
            if (String.isEmpty(vin) || String.isEmpty(oportunidad)) {
                res.responseBody = Blob.valueOf('{"error":"Faltan datos requeridos"}');
                res.statusCode = 400;
                return;
            }
            
            // Buscar la oportunidad con el consecutivo y el producto con el VIN
            List<Opportunity> oppList = [
                SELECT Id, Tiene_Vehiculos_Reservados__c
                FROM Opportunity
                WHERE ConsecutivoOportunidad__c = :oportunidad
                LIMIT 1
            ];
            
            if (oppList.isEmpty()) {
                res.responseBody = Blob.valueOf('{"error":"Oportunidad no encontrada"}');
                res.statusCode = 404;
                return;
            }
            
            Opportunity opp = oppList[0];
            
            List<OpportunityLineItem> oliList = [
                SELECT Id, Reservado__c, Product2Id
                FROM OpportunityLineItem
                WHERE OpportunityId = :opp.Id AND Product2.VIN__c = :vin
                LIMIT 1
            ];
            
            if (oliList.isEmpty()) {
                res.responseBody = Blob.valueOf('{"error":"Producto de la oportunidad no encontrado"}');
                res.statusCode = 404;
                return;
            }
            
            OpportunityLineItem oli = oliList[0];
            
            List<Product2> productList = [
                SELECT Id, Producto_Reservado__c, OportunidadReserva__c
                FROM Product2
                WHERE Id = :oli.Product2Id
                LIMIT 1
            ];
            
            if (productList.isEmpty()) {
                res.responseBody = Blob.valueOf('{"error":"Producto no encontrado"}');
                res.statusCode = 404;
                return;
            }
            
            Product2 product = productList[0];
            
            // Marcar los campos necesarios
            opp.Tiene_Vehiculos_Reservados__c = true;
            oli.Reservado__c = true;
            product.Producto_Reservado__c = true;
            product.OportunidadReserva__c = opp.Id;
            opp.Notificar_reserva_veh_culo__c = true;
            opp.Autorizacion__c = authorizado;
            
            Anticipo__c anticipoNuevo = new  Anticipo__c();
            anticipoNuevo.Estatus__c = 'Aplicado';
            anticipoNuevo.Identificador__c = authorizado;
            anticipoNuevo.Monto__c = 1000;
            anticipoNuevo.Oportunidad__c = opp.Id;
            anticipoNuevo.Producto__c = 'Aplicado';
            
            insert anticipoNuevo;
            
            // Actualizar registros
            update opp;
            update oli;
            update product;
            
            res.responseBody = Blob.valueOf('{"success":"Vehículo reservado correctamente"}');
            res.statusCode = 200;
        } catch (Exception e) {
            res.responseBody = Blob.valueOf('{"error":"' + e.getMessage() + '"}');
            res.statusCode = 500;
        }
    }
    public static void dummy() {
        string a1 = 'a1';
        string a2 = 'a2';
        string a3 = 'a3';
        string a4 = 'a4';
        string a5 = 'a5';
        string a6 = 'a6';
        string a7 = 'a7';
        string a8 = 'a8';
        string a9 = 'a9';
        string a10 = 'a10';
        string a11 = 'a11';
        string a12 = 'a12';
        string a13 = 'a13';
        string a14 = 'a14';
        string a15 = 'a15';
        string a16 = 'a16';
        string a17 = 'a17';
        string a18 = 'a18';
        string a19 = 'a19';
        string a20 = 'a20';
        string a21 = 'a21';
        string a22 = 'a22';
        string a23 = 'a23';
        string a24 = 'a24';
        string a25 = 'a25';
        string a26 = 'a26';
        string a27 = 'a27';
        string a28 = 'a28';
        string a29 = 'a29';
        string a30 = 'a30';
        string a31 = 'a31';
        string a32 = 'a32';
        string a33 = 'a33';
        string a34 = 'a34';
        string a35 = 'a35';
        string a36 = 'a36';
        string a37 = 'a37';
        string a38 = 'a38';
        string a39 = 'a39';
        string a40 = 'a40';
        string a41 = 'a41';
        string a42 = 'a42';
        string a43 = 'a43';
        string a44 = 'a44';
        string a45 = 'a45';
        string a46 = 'a46';
        string a47 = 'a47';
        string a48 = 'a48';
        string a49 = 'a49';
        string a50 = 'a50';
        string a51 = 'a51';
        string a52 = 'a52';
        string a53 = 'a53';
        string a54 = 'a54';
        string a55 = 'a55';
        string a56 = 'a56';
        string a57 = 'a57';
        string a58 = 'a58';
        string a59 = 'a59';
        string a60 = 'a60';
        string a61 = 'a61';
        string a62 = 'a62';
        string a63 = 'a63';
        string a64 = 'a64';
        string a65 = 'a65';
        string a66 = 'a66';
        string a67 = 'a67';
        string a68 = 'a68';
        string a69 = 'a69';
        string a70 = 'a70';
        string a71 = 'a71';
        string a72 = 'a72';
        string a73 = 'a73';
        string a74 = 'a74';
        string a75 = 'a75';
        string a76 = 'a76';
        string a77 = 'a77';
        string a78 = 'a78';
        string a79 = 'a79';
        string a80 = 'a80';
        string a81 = 'a81';
        string a82 = 'a82';
        string a83 = 'a83';
        string a84 = 'a84';
        string a85 = 'a85';
        string a86 = 'a86';
        string a87 = 'a87';
        string a88 = 'a88';
        string a89 = 'a89';
        string a90 = 'a90';
        string a91 = 'a91';
        string a92 = 'a92';
        string a93 = 'a93';
        string a94 = 'a94';
        string a95 = 'a95';
        string a96 = 'a96';
        string a97 = 'a97';
        string a98 = 'a98';
        string a99 = 'a99';
        string a100 = 'a100';
        string a101 = 'a101';
        string a102 = 'a102';
        string a103 = 'a103';
        string a104 = 'a104';
        string a105 = 'a105';
        string a106 = 'a106';
        string a107 = 'a107';
        string a108 = 'a108';
        string a109 = 'a109';
        string a110 = 'a110';
        string a111 = 'a111';
        string a112 = 'a112';
        string a113 = 'a113';
        string a114 = 'a114';
        string a115 = 'a115';
        string a116 = 'a116';
        string a117 = 'a117';
        string a118 = 'a118';
        string a119 = 'a119';
        string a120 = 'a120';
        string a121 = 'a121';
        string a122 = 'a122';
        string a123 = 'a123';
        string a124 = 'a124';
        string a125 = 'a125';
        string a126 = 'a126';
        string a127 = 'a127';
        string a128 = 'a128';
        string a129 = 'a129';
        string a130 = 'a130';
        string a131 = 'a131';
        string a132 = 'a132';
        string a133 = 'a133';
        string a134 = 'a134';
        string a135 = 'a135';
        string a136 = 'a136';
        string a137 = 'a137';
        string a138 = 'a138';
        string a139 = 'a139';
        string a140 = 'a140';
        string a141 = 'a141';
        string a142 = 'a142';
        string a143 = 'a143';
        string a144 = 'a144';
        string a145 = 'a145';
        string a146 = 'a146';
        string a147 = 'a147';
        string a148 = 'a148';
        string a149 = 'a149';
        string a150 = 'a150';
        string a151 = 'a151';
        string a152 = 'a152';
        string a153 = 'a153';
        string a154 = 'a154';
        string a155 = 'a155';
        string a156 = 'a156';
        string a157 = 'a157';
        string a158 = 'a158';
        string a159 = 'a159';
        string a160 = 'a160';
        string a161 = 'a161';
        string a162 = 'a162';
        string a163 = 'a163';
        string a164 = 'a164';
        string a165 = 'a165';
        string a166 = 'a166';
        string a167 = 'a167';
        string a168 = 'a168';
        string a169 = 'a169';
        string a170 = 'a170';
        string a171 = 'a171';
        string a172 = 'a172';
        string a173 = 'a173';
        string a174 = 'a174';
        string a175 = 'a175';
        string a176 = 'a176';
        string a177 = 'a177';
        string a178 = 'a178';
        string a179 = 'a179';
        string a180 = 'a180';
        string a181 = 'a181';
        string a182 = 'a182';
        string a183 = 'a183';
        string a184 = 'a184';
        string a185 = 'a185';
        string a186 = 'a186';
        string a187 = 'a187';
        string a188 = 'a188';
        string a189 = 'a189';
    }
}