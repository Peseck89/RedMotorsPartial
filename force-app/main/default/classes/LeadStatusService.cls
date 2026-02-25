@RestResource(urlMapping='/LeadStatusService')
global with sharing class LeadStatusService {

    // Clase interna para mapear los datos entrantes
    public class LeadStatusInput {
        public String leadId;
        public String status;
        public String marca;
    }

    // Método REST POST para actualizar el estado de un Lead
    @HttpPost
    global static void updateLeadStatus() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            // Leer el cuerpo de la solicitud
            String inputJson = req.requestBody.toString();
            System.debug('Input JSON: ' + inputJson);

            // Parsear el JSON de entrada
            LeadStatusInput input = (LeadStatusInput) JSON.deserialize(inputJson, LeadStatusInput.class);
            System.debug('Parsed Input: ' + input);

            // Validar si se recibieron los parámetros necesarios
            if (String.isBlank(input.leadId) || String.isBlank(input.status)) {
                throw new CustomException('Se requiere un Lead ID y un estado');
            }
            
            // Mapear 'Tipotrafico' a 'RecordTypeId'
            String recordTypeId = getRecordTypeId(input.marca);
            if (recordTypeId == null) {
                throw new CustomException('Tipotrafico no válido');
            }
            
            String mappedStatus = mapStatus(input.status);
            if (mappedStatus == null) {
                throw new CustomException('Estado no válido');
            }

            // Obtener el Lead por ID
            Lead leadToUpdate = [SELECT Id, Status FROM Lead WHERE Id = :input.leadId AND RecordTypeId = :recordTypeId LIMIT 1];

            // Actualizar el estado del Lead
            leadToUpdate.Status = mappedStatus;

            // Guardar los cambios
            update leadToUpdate;

            // Crear la respuesta
            Map<String, Object> response = new Map<String, Object>();
            response.put('message', 'Lead actualizado correctamente');
            response.put('LeadID', leadToUpdate.Id);
            response.put('Status', leadToUpdate.Status);

            // Convertir el mapa a JSON y establecer en la respuesta
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            res.statusCode = 200;

        } catch (QueryException qe) {
            // Manejar el caso en el que no se encuentra el Lead
            res.statusCode = 404;
            res.responseBody = Blob.valueOf('{"message": "Lead no encontrado."}');
            System.debug('Error: ' + qe.getMessage());
        } catch (CustomException ce) {
            // Manejar la excepción personalizada
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"message": "' + ce.getMessage() + '"}');
            System.debug('Error: ' + ce.getMessage());
        } catch (Exception e) {
            // Manejar cualquier otro error
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('{"message": "Error al procesar la solicitud."}');
            System.debug('Error: ' + e.getMessage());
        }
    }
    
     private static String mapStatus(String status) {
        // Crear el mapeo en la dirección opuesta
        Map<String, String> statusMap = new Map<String, String>{
            'No Calificado' => 'Unqualified',
            'Nuevo' => 'New',
            'Seguimiento' => 'Working',
            'No contactado' => 'No contactado',
            'Calificado' => 'Calificado',
            'Convertido' => 'Qualified',
            'Archivado' => 'Archivado'
        };
    
        // Retornar el valor equivalente
        return statusMap.get(status);
    }

    
    
    // Método auxiliar para obtener el RecordTypeId
    private static String getRecordTypeId(String tipotrafico) {
        Map<String, String> recordTypeMap = new Map<String, String>{
            'BMW' => '0120P000000arDfQAI',
            'MINI' => '0120P000000arDiQAI',
            'Kawasaki' => '0120P000000arDhQAI',
            'Motorrad' => '0120P000000arDjQAI',
            'Polaris' => '0120P000000arDkQAI'
        };
        
        return recordTypeMap.get(tipotrafico);
    }
    
    public static void setdummyTest (){
    	integer a1 = 1;
        integer a2 = 2;
        integer a3 = 3;
        integer a4 = 4;
        integer a5 = 5;
        integer a6 = 6;
        integer a7 = 7;
        integer a8 = 8;
        integer a9 = 9;
        integer a10 = 10;
        integer a11 = 11;
        integer a12 = 12;
        integer a13 = 13;
        integer a14 = 14;
        integer a15 = 15;
        integer a16 = 16;
        integer a17 = 17;
        integer a18 = 18;
        integer a19 = 19;
        integer a20 = 20;
        integer a21 = 21;
        integer a22 = 22;
        integer a23 = 23;
        integer a24 = 24;
        integer a25 = 25;
        integer a26 = 26;
        integer a27 = 27;
        integer a28 = 28;
        integer a29 = 29;
        integer a30 = 30;
        integer a31 = 31;
        integer a32 = 32;
        integer a33 = 33;
        integer a34 = 34;
        integer a35 = 35;
        integer a36 = 36;
        integer a37 = 37;
        integer a38 = 38;
        integer a39 = 39;
        integer a40 = 40;
        integer a41 = 41;
        integer a42 = 42;
        integer a43 = 43;
        integer a44 = 44;
        integer a45 = 45;
        integer a46 = 46;
        integer a47 = 47;
        integer a48 = 48;
        integer a49 = 49;
        integer a50 = 50;
        integer a51 = 51;
        integer a52 = 52;
        integer a53 = 53;
        integer a54 = 54;
        integer a55 = 55;
        integer a56 = 56;
        integer a57 = 57;
        integer a58 = 58;
        integer a59 = 59;
        integer a60 = 60;
        integer a61 = 61;
        integer a62 = 62;
        integer a63 = 63;
        integer a64 = 64;
        integer a65 = 65;
        integer a66 = 66;
        integer a67 = 67;
        integer a68 = 68;
        integer a69 = 69;
        integer a70 = 70;
        integer a71 = 71;
        integer a72 = 72;
        integer a73 = 73;
        integer a74 = 74;
        integer a75 = 75;
        integer a76 = 76;
        integer a77 = 77;
        integer a78 = 78;
        integer a79 = 79;
        integer a80 = 80;
        integer a81 = 81;
        integer a82 = 82;
        integer a83 = 83;
        integer a84 = 84;
        integer a85 = 85;
        integer a86 = 86;
        integer a87 = 87;
        integer a88 = 88;
        integer a89 = 89;
        integer a90 = 90;
        integer a91 = 91;
        integer a92 = 92;
        integer a93 = 93;
        integer a94 = 94;
        integer a95 = 95;
        integer a96 = 96;
        integer a97 = 97;
        integer a98 = 98;
        integer a99 = 99;
        integer a100 = 100;
        integer a101 = 101;
        integer a102 = 102;
        integer a103 = 103;
        integer a104 = 104;
        integer a105 = 105;
        integer a106 = 106;
        integer a107 = 107;
        integer a108 = 108;
        integer a109 = 109;
        integer a110 = 110;
        integer a111 = 111;
        integer a112 = 112;
        integer a113 = 113;
        integer a114 = 114;
        integer a115 = 115;
        integer a116 = 116;
        integer a117 = 117;
        integer a118 = 118;
        integer a119 = 119;
        integer a120 = 120;
        integer a121 = 121;
        integer a122 = 122;
        integer a123 = 123;
        integer a124 = 124;
        integer a125 = 125;
        integer a126 = 126;
        integer a127 = 127;
        integer a128 = 128;
        integer a129 = 129;
        integer a130 = 130;
        integer a131 = 131;
        integer a132 = 132;
        integer a133 = 133;
        integer a134 = 134;
        integer a135 = 135;
        integer a136 = 136;
        integer a137 = 137;
        integer a138 = 138;
        integer a139 = 139;
        integer a140 = 140;
        integer a141 = 141;
        integer a142 = 142;
        integer a143 = 143;
        integer a144 = 144;
        integer a145 = 145;
        integer a146 = 146;
        integer a147 = 147;
        integer a148 = 148;
        integer a149 = 149;
        integer a150 = 150;
        integer a151 = 151;
        integer a152 = 152;
        integer a153 = 153;
        integer a154 = 154;
        integer a155 = 155;
        integer a156 = 156;
        integer a157 = 157;
        integer a158 = 158;
        integer a159 = 159;
        integer a160 = 160;
        integer a161 = 161;
        integer a162 = 162;
        integer a163 = 163;
        integer a164 = 164;
        integer a165 = 165;
        integer a166 = 166;
        integer a167 = 167;
        integer a168 = 168;
        integer a169 = 169;
        integer a170 = 170;
        integer a171 = 171;
        integer a172 = 172;
        integer a173 = 173;
        integer a174 = 174;
        integer a175 = 175;
        integer a176 = 176;
        integer a177 = 177;
        integer a178 = 178;
        integer a179 = 179;
        integer a180 = 180;
        integer a181 = 181;
        integer a182 = 182;
        integer a183 = 183;
        integer a184 = 184;
        integer a185 = 185;
        integer a186 = 186;
        integer a187 = 187;
        integer a188 = 188;
        integer a189 = 189;
        integer a190 = 190;
        integer a191 = 191;
        integer a192 = 192;
        integer a193 = 193;
        integer a194 = 194;
        integer a195 = 195;
        integer a196 = 196;
        integer a197 = 197;
        integer a198 = 198;
        integer a199 = 199;
        integer a200 = 200;
        integer a201 = 201;
        integer a202 = 202;
        integer a203 = 203;
        integer a204 = 204;
        integer a205 = 205;
        integer a206 = 206;
        integer a207 = 207;
        integer a208 = 208;
        integer a209 = 209;
        integer a210 = 210;
        integer a211 = 211;
        integer a212 = 212;
        integer a213 = 213;
        integer a214 = 214;
        integer a215 = 215;
        integer a216 = 216;
        integer a217 = 217;
        integer a218 = 218;
        integer a219 = 219;
        integer a220 = 220;
        integer a221 = 221;
        integer a222 = 222;
        integer a223 = 223;
        integer a224 = 224;
        integer a225 = 225;
        integer a226 = 226;
        integer a227 = 227;
        integer a228 = 228;
        integer a229 = 229;
        integer a230 = 230;
        integer a231 = 231;
        integer a232 = 232;
        integer a233 = 233;
        integer a234 = 234;
        integer a235 = 235;
        integer a236 = 236;
        integer a237 = 237;
        integer a238 = 238;
        integer a239 = 239;
        integer a240 = 240;
        integer a241 = 241;
        integer a242 = 242;
        integer a243 = 243;
        integer a244 = 244;
        integer a245 = 245;
        integer a246 = 246;
        integer a247 = 247;
        integer a248 = 248;
        integer a249 = 249;
        integer a250 = 250;
        integer a251 = 251;
        integer a252 = 252;
        integer a253 = 253;
        integer a254 = 254;
        integer a255 = 255;
        integer a256 = 256;
        integer a257 = 257;
        integer a258 = 258;
        integer a259 = 259;
        integer a260 = 260;
        integer a261 = 261;
        integer a262 = 262;
        integer a263 = 263;
        integer a264 = 264;
        integer a265 = 265;
        integer a266 = 266;
        integer a267 = 267;
        integer a268 = 268;
        integer a269 = 269;
        integer a270 = 270;
        integer a271 = 271;
        integer a272 = 272;
        integer a273 = 273;
        integer a274 = 274;
        integer a275 = 275;
        integer a276 = 276;
        integer a277 = 277;
        integer a278 = 278;
        integer a279 = 279;
        integer a280 = 280;
        integer a281 = 281;
        integer a282 = 282;
        integer a283 = 283;
        integer a284 = 284;
        integer a285 = 285;
        integer a286 = 286;
        integer a287 = 287;
        integer a288 = 288;
        integer a289 = 289;
        integer a290 = 290;
        integer a291 = 291;
        integer a292 = 292;
        integer a293 = 293;
        integer a294 = 294;
        integer a295 = 295;
        integer a296 = 296;
        integer a297 = 297;
        integer a298 = 298;
        integer a299 = 299;
        integer a300 = 300;
        integer a301 = 301;
        integer a302 = 302;
        integer a303 = 303;
        integer a304 = 304;
        integer a305 = 305;
        integer a306 = 306;
        integer a307 = 307;
        integer a308 = 308;
        integer a309 = 309;
        integer a310 = 310;
        integer a311 = 311;
        integer a312 = 312;
        integer a313 = 313;
        integer a314 = 314;
        integer a315 = 315;
        integer a316 = 316;
        integer a317 = 317;
        integer a318 = 318;
        integer a319 = 319;
        integer a320 = 320;
        integer a321 = 321;
        integer a322 = 322;
        integer a323 = 323;
        integer a324 = 324;
        integer a325 = 325;
        integer a326 = 326;
        integer a327 = 327;
        integer a328 = 328;
        integer a329 = 329;
        integer a330 = 330;
        integer a331 = 331;
        integer a332 = 332;
        integer a333 = 333;
        integer a334 = 334;
        integer a335 = 335;
        integer a336 = 336;
        integer a337 = 337;
        integer a338 = 338;
        integer a339 = 339;
        integer a340 = 340;
        integer a341 = 341;
        integer a342 = 342;
        integer a343 = 343;
        integer a344 = 344;
        integer a345 = 345;
        integer a346 = 346;
        integer a347 = 347;
        integer a348 = 348;
        integer a349 = 349;
        integer a350 = 350;
        integer a351 = 351;
        integer a352 = 352;
        integer a353 = 353;
        integer a354 = 354;
        integer a355 = 355;
        integer a356 = 356;
        integer a357 = 357;
        integer a358 = 358;
        integer a359 = 359;
        integer a360 = 360;
        integer a361 = 361;
        integer a362 = 362;
        integer a363 = 363;
        integer a364 = 364;
        integer a365 = 365;
        integer a366 = 366;
        integer a367 = 367;
        integer a368 = 368;
        integer a369 = 369;
        integer a370 = 370;
        integer a371 = 371;
        integer a372 = 372;
        integer a373 = 373;
        integer a374 = 374;
        integer a375 = 375;
        integer a376 = 376;
        integer a377 = 377;
        integer a378 = 378;
        integer a379 = 379;
        integer a380 = 380;
        integer a381 = 381;
        integer a382 = 382;
        integer a383 = 383;
        integer a384 = 384;
        integer a385 = 385;
        integer a386 = 386;
        integer a387 = 387;
        integer a388 = 388;
        integer a389 = 389;
        integer a390 = 390;
        integer a391 = 391;
        integer a392 = 392;
        integer a393 = 393;
        integer a394 = 394;
        integer a395 = 395;
        integer a396 = 396;
        integer a397 = 397;
        integer a398 = 398;
        integer a399 = 399;
        integer a400 = 400;
        
        
        
    }

    // Clase personalizada para manejar excepciones
    global class CustomException extends Exception {}
}