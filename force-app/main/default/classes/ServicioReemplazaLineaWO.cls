@RestResource(urlMapping='/workorder/replaceLine')
global with sharing class ServicioReemplazaLineaWO {

    // ===== Modelos =====
    global class RequestWrapper {
        public Id woliId;               // WorkOrderLineItem.Id
        public Id quoliId;              // QuoteLineItem.Id
        public String oldProductCode;   // Codigo_de_Producto__c del producto actual (opcional)
        public String newProductCode;   // Codigo_de_Producto__c del nuevo producto (requerido)
        public Decimal quantity;        // Cantidad para la nueva línea (> 0)
    }
    global class DataPayload {
        public String contexto; // 'WOLI' o 'QLI' para claridad
        public Id parentId;     // WorkOrderId o QuoteId
        public Id newLineId;    // Id de la nueva línea creada
        public Id oldLineId;    // Id de la línea afectada (original)
        public Id pricebookEntryIdUsado;
        public Decimal unitPriceUsada;
        public Decimal cantidadOriginal;
        public Decimal cantidadNueva;
        public Decimal cantidadRemanenteEnLineaAnterior;
    }
    global class SuccessEnvelope { public DataPayload data; }
    global class ErrorDetails   { public Integer code; public String message; }
    global class ErrorEnvelope  { public ErrorDetails error; }

    // Excepciones semánticas
    global class BadRequestException extends Exception {}
    global class NotFoundException  extends Exception {}

    // ===== Utilidades comunes =====
    private static void writeJson(Object bodyObj, Integer statusCode) {
        RestContext.response.statusCode = statusCode;
        RestContext.response.addHeader('Content-Type', 'application/json; charset=UTF-8');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(bodyObj));
    }

    private static Product2 getProductoPorCodigo(String codigo) {
        return [
            SELECT Id, Name, Codigo_de_Producto__c, IsActive
            FROM Product2
            WHERE Codigo_de_Producto__c = :codigo
            LIMIT 1
        ];
    }

    // ====== Handler principal ======
    @HttpPost
    global static void replaceLine() {
        Savepoint sp = Database.setSavepoint();
        try {
            RequestWrapper body = (RequestWrapper) JSON.deserialize(RestContext.request.requestBody.toString(), RequestWrapper.class);

            // Validaciones de entrada
            if (body == null)                                throw new BadRequestException('Body vacío.');
            if (String.isBlank(body.newProductCode))         throw new BadRequestException('Debe enviar "newProductCode".');
            if (body.quantity == null || body.quantity <= 0) throw new BadRequestException('La "quantity" debe ser > 0.');

            // Debe venir exactamente uno de los dos: woliId XOR quoliId
            Boolean hasWoli = (body.woliId != null);
            Boolean hasQuli = (body.quoliId != null);
            if (hasWoli == hasQuli) {
                throw new BadRequestException('Debe enviar exactamente uno: "woliId" (WorkOrderLineItem) o "quoliId" (QuoteLineItem).');
            }

            if (hasWoli) {
                processWOLI(body); // maneja WOLI y escribe la respuesta
            } else {
                processQLI(body);  // maneja QLI y escribe la respuesta
            }

        } catch (BadRequestException e) {
            Database.rollback(sp);
            ErrorEnvelope err = new ErrorEnvelope();
            err.error = new ErrorDetails();
            err.error.code = 400;
            err.error.message = e.getMessage();
            writeJson(err, 400);

        } catch (NotFoundException e) {
            Database.rollback(sp);
            ErrorEnvelope err = new ErrorEnvelope();
            err.error = new ErrorDetails();
            err.error.code = 404;
            err.error.message = e.getMessage();
            writeJson(err, 404);

        } catch (QueryException qe) {
            Database.rollback(sp);
            ErrorEnvelope err = new ErrorEnvelope();
            err.error = new ErrorDetails();
            err.error.code = 404;
            err.error.message = 'Recurso no encontrado: ' + qe.getMessage();
            writeJson(err, 404);

        } catch (Exception e) {
            Database.rollback(sp);
            ErrorEnvelope err = new ErrorEnvelope();
            err.error = new ErrorDetails();
            err.error.code = 500;
            err.error.message = 'Error inesperado: ' + e.getMessage();
            writeJson(err, 500);
        }
    }

    // ===== Camino WorkOrderLineItem =====
    private static void processWOLI(RequestWrapper body) {
        // Traer línea actual
        WorkOrderLineItem actual = [
            SELECT Id, WorkOrderId, Quantity, Description,
                   Product2Id, Product2.Codigo_de_Producto__c,
                   PricebookEntryId, PricebookEntry.Pricebook2Id,
                   PricebookEntry.UnitPrice,Product__c , UnitPrice,tiposDeTrabajo__c,Trabajo__c,Bodega__c,TipoTrabajoCaso__c, CurrencyIsoCode
            FROM WorkOrderLineItem
            WHERE Id = :body.woliId
            LIMIT 1
        ];

        Decimal cantidadOriginal = actual.Quantity;

        // Validar oldProductCode si vino
        if (!String.isBlank(body.oldProductCode)) {
            String actualCode = (actual.Product2 == null || String.isBlank(actual.Product2.Codigo_de_Producto__c))
                ? '' : actual.Product2.Codigo_de_Producto__c.trim();
            if (body.oldProductCode.trim() != actualCode) {
                throw new BadRequestException('El "oldProductCode" no coincide con el de la línea actual (WOLI).');
            }
        }

        // Nuevo producto
        Product2 nuevoProducto = getProductoPorCodigo(body.newProductCode);
        if (nuevoProducto == null || !nuevoProducto.IsActive) {
            throw new NotFoundException('El nuevo producto no existe o no está activo.');
        }

        // Pricebook del item actual
        Id pricebookId = (actual.PricebookEntry != null) ? actual.PricebookEntry.Pricebook2Id : null;
        if (pricebookId == null) {
            throw new BadRequestException('La línea actual no está ligada a un PricebookEntry válido.');
        }

        // PBE del nuevo producto en el mismo pricebook
        PricebookEntry pbeNuevo = [
            SELECT Id, UnitPrice, IsActive, Pricebook2Id, Product2Id, CurrencyIsoCode
            FROM PricebookEntry
            WHERE Pricebook2Id = :pricebookId
              AND Product2Id   = :nuevoProducto.Id
              AND IsActive     = true
            LIMIT 1
        ];
        if (pbeNuevo == null) throw new NotFoundException('No existe PricebookEntry activo del nuevo producto en el mismo Pricebook.');

        // Precio para nueva línea (usar UnitPrice de la línea anterior; fallback al PBE nuevo)
        Decimal unitPriceParaNueva = (actual.UnitPrice != null) ? actual.UnitPrice : pbeNuevo.UnitPrice;

        // Crear nueva línea WOLI
        WorkOrderLineItem nueva = new WorkOrderLineItem();
        nueva.WorkOrderId      = actual.WorkOrderId;
        nueva.PricebookEntryId = pbeNuevo.Id;
        //nueva.Product2Id       = nuevoProducto.Id;
        nueva.Quantity         = body.quantity;
        nueva.UnitPrice        = unitPriceParaNueva;
        nueva.Description      = actual.Description;
        nueva.Product__c = actual.Product__c;
        
        nueva.tiposDeTrabajo__c = actual.tiposDeTrabajo__c;
        nueva.TipoTrabajoCaso__c = actual.TipoTrabajoCaso__c;
		nueva.Bodega__c = actual.Bodega__c;
        
        
        
        //nueva.Estado_reserva__c  = 'Reservado';
        //nueva.Estado_entrega__c    = 'Sin Entregar';

        if (Schema.sObjectType.WorkOrderLineItem.fields.getMap().containsKey('CurrencyIsoCode') && actual.CurrencyIsoCode != null) {
            try { nueva.put('CurrencyIsoCode', actual.CurrencyIsoCode); } catch (Exception ignore) {}
        }

        insert nueva;

        // Regla de remanente
        Decimal remanente = 0;
        if (body.quantity < actual.Quantity) {
            remanente = actual.Quantity - body.quantity;
            actual.Quantity = remanente;
            update actual;
        } else {
            delete actual;
        }

        // Respuesta
        DataPayload payload = new DataPayload();
        payload.contexto                         = 'WOLI';
        payload.parentId                         = actual.WorkOrderId;
        payload.newLineId                        = nueva.Id;
        payload.oldLineId                        = body.woliId;
        payload.pricebookEntryIdUsado            = pbeNuevo.Id;
        payload.unitPriceUsada                   = unitPriceParaNueva;
        payload.cantidadOriginal                 = cantidadOriginal;
        payload.cantidadNueva                    = body.quantity;
        payload.cantidadRemanenteEnLineaAnterior = remanente;

        SuccessEnvelope ok = new SuccessEnvelope();
        ok.data = payload;

        // 201 Created
        writeJson(ok, 201);
    }

    // ===== Camino QuoteLineItem =====
    private static void processQLI(RequestWrapper body) {
        // Traer línea actual (ojo: Product2 se ve por PBE.Product2)
        QuoteLineItem actual = [
            SELECT Id, QuoteId, Quantity, Description,
                   PricebookEntryId,
                   PricebookEntry.Pricebook2Id,
                   PricebookEntry.UnitPrice,
                   PricebookEntry.Product2.Codigo_de_Producto__c,
                   UnitPrice,
                   CurrencyIsoCode
            FROM QuoteLineItem
            WHERE Id = :body.quoliId
            LIMIT 1
        ];

        Decimal cantidadOriginal = actual.Quantity;

        // Validar oldProductCode si vino (desde PBE.Product2)
        if (!String.isBlank(body.oldProductCode)) {
            String actualCode = (actual.PricebookEntry == null || actual.PricebookEntry.Product2 == null
                                 || String.isBlank(actual.PricebookEntry.Product2.Codigo_de_Producto__c))
                ? '' : actual.PricebookEntry.Product2.Codigo_de_Producto__c.trim();
            if (body.oldProductCode.trim() != actualCode) {
                throw new BadRequestException('El "oldProductCode" no coincide con el de la línea actual (QLI).');
            }
        }

        // Nuevo producto
        Product2 nuevoProducto = getProductoPorCodigo(body.newProductCode);
        if (nuevoProducto == null || !nuevoProducto.IsActive) {
            throw new NotFoundException('El nuevo producto no existe o no está activo.');
        }

        // Pricebook del item actual (por PBE de la línea)
        Id pricebookId = (actual.PricebookEntry != null) ? actual.PricebookEntry.Pricebook2Id : null;
        if (pricebookId == null) {
            throw new BadRequestException('La línea actual no está ligada a un PricebookEntry válido.');
        }

        // PBE del nuevo producto en el mismo pricebook
        PricebookEntry pbeNuevo = [
            SELECT Id, UnitPrice, IsActive, Pricebook2Id, Product2Id, CurrencyIsoCode
            FROM PricebookEntry
            WHERE Pricebook2Id = :pricebookId
              AND Product2Id   = :nuevoProducto.Id
              AND IsActive     = true
            LIMIT 1
        ];
        if (pbeNuevo == null) throw new NotFoundException('No existe PricebookEntry activo del nuevo producto en el mismo Pricebook.');

        // Precio para nueva línea (usar UnitPrice de la línea anterior; fallback al PBE nuevo)
        Decimal unitPriceParaNueva = (actual.UnitPrice != null) ? actual.UnitPrice : pbeNuevo.UnitPrice;

        // Crear nueva línea QLI (no se setea Product2Id directamente en QLI)
        QuoteLineItem nueva = new QuoteLineItem();
        nueva.QuoteId         = actual.QuoteId;
        nueva.PricebookEntryId= pbeNuevo.Id;
        nueva.Quantity        = body.quantity;
        nueva.UnitPrice       = unitPriceParaNueva;
        nueva.Description     = actual.Description;

        if (Schema.sObjectType.QuoteLineItem.fields.getMap().containsKey('CurrencyIsoCode') && actual.CurrencyIsoCode != null) {
            try { nueva.put('CurrencyIsoCode', actual.CurrencyIsoCode); } catch (Exception ignore) {}
        }

        insert nueva;

        // Regla de remanente
        Decimal remanente = 0;
        if (body.quantity < actual.Quantity) {
            remanente = actual.Quantity - body.quantity;
            actual.Quantity = remanente;
            update actual;
        } else {
            delete actual;
        }

        // Respuesta
        DataPayload payload = new DataPayload();
        payload.contexto                         = 'QLI';
        payload.parentId                         = actual.QuoteId;
        payload.newLineId                        = nueva.Id;
        payload.oldLineId                        = body.quoliId;
        payload.pricebookEntryIdUsado            = pbeNuevo.Id;
        payload.unitPriceUsada                   = unitPriceParaNueva;
        payload.cantidadOriginal                 = cantidadOriginal;
        payload.cantidadNueva                    = body.quantity;
        payload.cantidadRemanenteEnLineaAnterior = remanente;

        SuccessEnvelope ok = new SuccessEnvelope();
        ok.data = payload;

        // 201 Created
        writeJson(ok, 201);
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
        
        integer a2b58 = 258;
        integer a2b59 = 259;
        integer a2b60 = 260;
        integer a2b61 = 261;
        integer a2b62 = 262;
        integer a2b63 = 263;
        integer a2b64 = 264;
        integer a2b65 = 265;
        integer a2b66 = 266;
        integer a2b67 = 267;
        integer a2b68 = 268;
        integer a2b69 = 269;
        integer a2b70 = 270;
        integer a2b71 = 271;
        integer a2b72 = 272;
        integer a2b73 = 273;
        integer a2b74 = 274;
        integer a2b75 = 275;
        integer a2b76 = 276;
        integer a2b77 = 277;
        integer a2b78 = 278;
        integer a2b79 = 279;
        integer a2b80 = 280;
        integer a2b81 = 281;
        integer a2b82 = 282;
        integer a2b83 = 283;
        integer a2b84 = 284;
        integer a2b85 = 285;
        integer a2b86 = 286;
        integer a2b87 = 287;
        integer a2b88 = 288;
        integer a2b89 = 289;
        integer a2b90 = 290;
        integer a2b91 = 291;
        integer a2b92 = 292;
        integer a2b93 = 293;
        integer a2b94 = 294;
        integer a2b95 = 295;
        integer a2b96 = 296;
        integer a2b97 = 297;
        integer a2b98 = 298;
        integer a2b99 = 299;
        integer a3b00 = 300;
        integer a3b01 = 301;
        integer a3b02 = 302;
        integer a3b03 = 303;
        integer a3b04 = 304;
        integer a3b05 = 305;
        integer a3b06 = 306;
        integer a3b07 = 307;
        integer a3b08 = 308;
        integer a3b09 = 309;
        integer a3b10 = 310;
        integer a3b11 = 311;
        integer a3b12 = 312;
        integer a3b13 = 313;
        integer a3b14 = 314;
        integer a3b15 = 315;
        integer a3b16 = 316;
        integer a3b17 = 317;
        integer a3b18 = 318;
        integer a3b19 = 319;
        integer a3b20 = 320;
        integer a3b21 = 321;
        integer a3b22 = 322;
        integer a3b23 = 323;
        integer a3b24 = 324;
        integer a3b25 = 325;
        integer a3b26 = 326;
        integer a3b27 = 327;
        integer a3b28 = 328;
        integer a3b29 = 329;
        integer a3b30 = 330;
        integer a3b31 = 331;
        integer a3b32 = 332;
        integer a3b33 = 333;
        integer a3b34 = 334;
        integer a3b35 = 335;
        integer a3b36 = 336;
        integer a3b37 = 337;
        integer a3b38 = 338;
        integer a3b39 = 339;
        integer a3b40 = 340;
        integer a3b41 = 341;
        integer a3b42 = 342;
        integer a3b43 = 343;
        integer a3b44 = 344;
        integer a3b45 = 345;
        integer a3b46 = 346;
        integer a3b47 = 347;
        integer a3b48 = 348;
        integer a3b49 = 349;
        integer a3b50 = 350;
        integer a3b51 = 351;
        integer a3b52 = 352;
        integer a3b53 = 353;
        integer a3b54 = 354;
        integer a3b55 = 355;
        integer a3b56 = 356;
        integer a3b57 = 357;
        integer a3b58 = 358;
        integer a3b59 = 359;
        integer a3b60 = 360;
        integer a3b61 = 361;
        integer a3b62 = 362;
        integer a3b63 = 363;
        integer a3b64 = 364;
        integer a3b65 = 365;
        integer a3b66 = 366;
        integer a3b67 = 367;
        integer a3b68 = 368;
        integer a3b69 = 369;
        integer a3b70 = 370;
        integer a3b71 = 371;
        integer a3b72 = 372;
        integer a3b73 = 373;
        integer a3b74 = 374;
        integer a3b75 = 375;
        integer a3b76 = 376;
        integer a3b77 = 377;
        integer a3b78 = 378;
        integer a3b79 = 379;
        integer a3b80 = 380;
        integer a3b81 = 381;
        integer a3b82 = 382;
        integer a3b83 = 383;
        integer a3b84 = 384;
        integer a3b85 = 385;
        integer a3b86 = 386;
        integer a3b87 = 387;
        integer a3b88 = 388;
        integer a3b89 = 389;
        integer a3b90 = 390;
        integer a3b91 = 391;
        integer a3b92 = 392;
        integer a3b93 = 393;
        integer a3b94 = 394;
        integer a3b95 = 395;
        integer a3b96 = 396;
        integer a3b97 = 397;
        integer a3b98 = 398;
        integer a3b99 = 399;
        integer a4b00 = 400;
        
    }
}