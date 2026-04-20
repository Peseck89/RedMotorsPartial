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
        nueva.Quantity         = body.quantity;
        nueva.UnitPrice        = unitPriceParaNueva;
        nueva.Description      = actual.Description;
        nueva.Product__c = actual.Product__c;

        nueva.tiposDeTrabajo__c = actual.tiposDeTrabajo__c;
        nueva.TipoTrabajoCaso__c = actual.TipoTrabajoCaso__c;
		nueva.Bodega__c = actual.Bodega__c;

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
}