public with sharing class QuoteService {

    public static final String PRICEBOOK_NAME = 'Bavarian Dólar';
    private static final String OTOBAI_BODEGA_CODE = 'BR02';
    private static final String OTOBAI_BODEGA_EXTERNAL_ID = 'RMOTOBAIBR02';
    private static final String PEKING_BODEGA_MESSAGE = 'No existe bodega principal confirmada para RMPEKING.';

    // Bodegas principales permitidas (por código)
    private static final Set<String> PRINCIPAL_BODEGAS = new Set<String>{ 'BR01', OTOBAI_BODEGA_CODE, 'RM01' };

    private static Boolean isPrincipalBodega(ProductoXBodega__c pxb) {
        String code = (pxb != null && pxb.Bodega__r != null) ? pxb.Bodega__r.Bodega__c : null;
        if (String.isBlank(code) || !PRINCIPAL_BODEGAS.contains(code)) return false;
        if (code == OTOBAI_BODEGA_CODE) {
            return pxb.Bodega__r.ID_EXTERNO_BODEGA__c == OTOBAI_BODEGA_EXTERNAL_ID;
        }
        return true;
    }

    // =========================================================
    // Helpers para soportar "Todos"
    // =========================================================
    private static Boolean usesOtobaiPavasBodega(String brandOrRecordType) {
        String value = String.isBlank(brandOrRecordType) ? '' : brandOrRecordType.toLowerCase();
        return value.contains('kawa')
            || value.contains('kawasaki')
            || value.contains('indian')
            || value.contains('polaris');
    }

    private static Boolean isMotoBrand(String brand) {
        String b = String.isBlank(brand) ? '' : brand.toLowerCase();
        return b.contains('moto')
            || b.contains('otobai');
    }

    private static String normalizeCompanyCode(String value) {
        return String.isBlank(value) ? null : value.trim().toUpperCase();
    }

    private static Boolean isBavarianBrand(String brandOrRecordType) {
        String value = String.isBlank(brandOrRecordType) ? '' : brandOrRecordType.toLowerCase();
        return value.contains('bmw') || value.contains('mini') || value.contains('bavarian');
    }

    private static Boolean isPekingBrand(String brandOrRecordType) {
        String value = String.isBlank(brandOrRecordType) ? '' : brandOrRecordType.toLowerCase();
        return value.contains('omoda') || value.contains('jaecoo') || value.contains('peking');
    }

    private static String resolveSupportedCompanyCode(
        Id empresaOperadoraId,
        String legacyCompany,
        String recordTypeOrBrand,
        String pricebookName
    ) {
        if (empresaOperadoraId != null) {
            try {
                return EmpresaResolver.resolve(empresaOperadoraId).codigo;
            } catch (EmpresaConfigurationException e) {
                throw new AuraHandledException(e.getMessage());
            }
        }

        String normalizedLegacy = normalizeCompanyCode(legacyCompany);
        if (normalizedLegacy == 'RMBAVARIAN' || normalizedLegacy == 'BAVARIAN') {
            return 'RMBAVARIAN';
        }
        if (normalizedLegacy == 'RMOTOBAI' || normalizedLegacy == 'OTOBAI') {
            return 'RMOTOBAI';
        }
        if (normalizedLegacy == 'RMPEKING' || normalizedLegacy == 'PEKING') {
            return 'RMPEKING';
        }

        if (isBavarianBrand(recordTypeOrBrand) || isBavarianBrand(pricebookName)) {
            return 'RMBAVARIAN';
        }
        if (
            usesOtobaiPavasBodega(recordTypeOrBrand) ||
            usesOtobaiPavasBodega(pricebookName) ||
            isMotoBrand(recordTypeOrBrand)
        ) {
            return 'RMOTOBAI';
        }
        if (isPekingBrand(recordTypeOrBrand) || isPekingBrand(pricebookName)) {
            return 'RMPEKING';
        }

        throw new AuraHandledException('No existe empresa soportada para determinar la bodega de entrega.');
    }

    private static void ensureCompanyHasConfiguredBodega(String companyCode) {
        if (companyCode == 'RMPEKING') {
            throw new AuraHandledException(PEKING_BODEGA_MESSAGE);
        }
        if (companyCode != 'RMBAVARIAN' && companyCode != 'RMOTOBAI') {
            throw new AuraHandledException('La empresa ' + companyCode + ' no está soportada para determinar bodega.');
        }
    }

    private static Id getBodegaIdByCode(String code) {
        if (String.isBlank(code)) return null;
        List<Bodega__c> bods = [
            SELECT Id, Name, ID_EXTERNO_BODEGA__c
            FROM Bodega__c
            WHERE Bodega__c = :code
            LIMIT 20
        ];
        if (bods.isEmpty()) return null;

        if (code == OTOBAI_BODEGA_CODE) {
            for (Bodega__c bod : bods) {
                if (bod.ID_EXTERNO_BODEGA__c == OTOBAI_BODEGA_EXTERNAL_ID) {
                    return bod.Id;
                }
            }
        }
        return bods[0].Id;
    }

    // Para extras/regalías: decide bodega principal por el Quote (RT de Opportunity)
    private static String getDefaultDeliveryBodegaCodeFromQuote(Id quoteId) {
        Quote q = [
            SELECT Id, Pricebook2.Name, Opportunity.Empresa_Operadora__c,
                Opportunity.BMW_Compania__c, Opportunity.RecordType.DeveloperName
            FROM Quote
            WHERE Id = :quoteId
            LIMIT 1
        ];

        String rt = (q.Opportunity != null && q.Opportunity.RecordType != null)
            ? q.Opportunity.RecordType.DeveloperName
            : null;

        String companyCode = resolveSupportedCompanyCode(
            q.Opportunity != null ? q.Opportunity.Empresa_Operadora__c : null,
            q.Opportunity != null ? q.Opportunity.BMW_Compania__c : null,
            rt,
            q.Pricebook2 != null ? q.Pricebook2.Name : null
        );
        ensureCompanyHasConfiguredBodega(companyCode);
        if (companyCode == 'RMOTOBAI') return OTOBAI_BODEGA_CODE;
        return 'BR01';
    }

    private static Id resolveDeliveryBodegaIdForQuote(Id quoteId, ProductoXBodega__c selectedPxb) {
        String code = getDefaultDeliveryBodegaCodeFromQuote(quoteId);

        // Si ya es principal, úsala después de validar que la empresa sí tiene bodega confirmada.
        if (isPrincipalBodega(selectedPxb)) return selectedPxb.Bodega__c;

        // Si no es principal (por "Todos"), fuerza BR01/BR02/RM01 según quote
        Id bodId = getBodegaIdByCode(code);

        if (bodId == null) {
            throw new AuraHandledException('No existe un registro Bodega__c con código ' + code + '.');
        }
        return bodId;
    }

    // Para vehículos: decide principal por marca del producto (auto/moto)
    private static Id resolveDeliveryBodegaIdForVehicle(ProductoXBodega__c selectedPxb) {
        String brand = selectedPxb.Producto__r != null ? selectedPxb.Producto__r.marcaVehiculo__c : null;
        String companyCode = resolveSupportedCompanyCode(
            null,
            selectedPxb.Producto__r != null ? selectedPxb.Producto__r.Empresa__c : null,
            brand,
            null
        );
        ensureCompanyHasConfiguredBodega(companyCode);

        if (isPrincipalBodega(selectedPxb)) return selectedPxb.Bodega__c;

        String code = companyCode == 'RMOTOBAI' ? OTOBAI_BODEGA_CODE : (isMotoBrand(brand) ? 'RM01' : 'BR01');

        Id bodId = getBodegaIdByCode(code);
        if (bodId == null) {
            throw new AuraHandledException('No existe un registro Bodega__c con código ' + code + '.');
        }
        return bodId;
    }

    // =========================================================

    public static String getSoftlandPriceBookId(String marca, String anio) {
        String marcaLike = '%' + marca + '%';
        String anioLike = '%' + anio + '%';

        List<Configuracion_de_ventas__c> configVtas = [
            SELECT Id, RM_ListaPrecioSoftland__c
            FROM Configuracion_de_ventas__c
            WHERE Listas_de_Precios_Vigente__c != NULL
              AND Listas_de_Precios_Vigente__c LIKE :marcaLike
              AND Listas_de_Precios_Vigente__c LIKE :anioLike
              AND RM_ListaPrecioSoftland__c != null
              AND RM_ListaPrecioSoftland__r.IsActive = true
            LIMIT 1
        ];

        return configVtas.isEmpty() ? null : configVtas[0].RM_ListaPrecioSoftland__c;
    }

    public static Map<String,Object> addVehicle(String oppId,String oppProdIntId,String prodXBodegaId,String existingQuoteId) {
        Map<String,Object> responseMap = new Map<String,Object>{'success' => false };

        if (String.isBlank(oppId)) {
            responseMap.put('message', 'El id del presupuesto es requerido.');
            return responseMap;
        }
        if (String.isBlank(oppProdIntId)) {
            responseMap.put('message', 'El id del registro oportunidad producto de interes es requerido.');
            return responseMap;
        }
        if (String.isBlank(prodXBodegaId)) {
            responseMap.put('message', 'El id del registro  de producto por bodega es requerido.');
            return responseMap;
        }

        List<ProductoXBodega__c> prodXBodList = [
            SELECT Id,Producto__c,Bodega__c,Bodega__r.Bodega__c,Bodega__r.ID_EXTERNO_BODEGA__c,Disponible__c,
                   Producto__r.Name,Producto__r.vin__c,Producto__r.marcaVehiculo__c,
                   Producto__r.Anno__c,Producto__r.modelo__c,Producto__r.Empresa__c
            FROM ProductoXBodega__c
            WHERE Id =:prodXBodegaId
            LIMIT 1
        ];
        if (prodXBodList.isEmpty()) {
            responseMap.put('message', 'El registro del producto por bodega no fue encontrado.');
            return responseMap;
        }

        // FIX: si viene de una bodega NO principal (por "Todos"), forzamos bodega de entrega BR01/BR02/RM01
        Id deliveryBodegaId = resolveDeliveryBodegaIdForVehicle(prodXBodList[0]);

        List<Oportunidad_Producto_Interes__c> oppsProdsInteres = [
            SELECT Id, Producto__c, Precio_Unitario__c, Marca__c, Anio__c, Modelo_Interes__c,
                   Familia__c,Oportunidad__c,Oportunidad__r.Pricebook2Id,Costo_Fijo__c,
                   Comision_Porcentaje_Vendedor__c,Comision_Porcentaje_Jefe__c,Comision_Porcentaje_Gerente__c,
                   PricebookEntryId__c
            FROM Oportunidad_Producto_Interes__c
            WHERE Id =:oppProdIntId
            LIMIT 1
        ];
        if (oppsProdsInteres.isEmpty()) {
            responseMap.put('message', 'El registro de producto de interes no existe.');
            return responseMap;
        }

        Oportunidad_Producto_Interes__c oppProdInteres = oppsProdsInteres[0];

        if (String.isBlank(oppProdInteres.Marca__c)) {
            responseMap.put('message', 'El año del producto de interes esta vacio.');
            return responseMap;
        }
        if (String.isBlank(oppProdInteres.Anio__c)) {
            responseMap.put('message', 'El año del producto de interes esta vacio.');
            return responseMap;
        }
        if (oppProdInteres.Oportunidad__c == null) {
            responseMap.put('message', 'La oportunidad en el registro de oportunidad producto de interes esta vacio.');
            return responseMap;
        }

        String brand;
        String year;
        String model;

        if (String.isNotBlank(prodXBodList[0].Producto__r.marcaVehiculo__c)) {
            brand = prodXBodList[0].Producto__r.marcaVehiculo__c;
        }
        if (String.isNotBlank(prodXBodList[0].Producto__r.Anno__c)) {
            year = String.valueOf(prodXBodList[0].Producto__r.Anno__c);
        }
        if (String.isNotBlank(prodXBodList[0].Producto__r.modelo__c)) {
            model = prodXBodList[0].Producto__r.modelo__c;
        }

        String softlandPriceBookId = getSoftlandPriceBookId(brand,year);
        if (String.isBlank(softlandPriceBookId)) {
            responseMap.put('message', 'No se identifico la lista de precios de softland.');
            return responseMap;
        }

        List<Product2> productList = [
            SELECT Id,
                (SELECT Id, Pricebook2Id, IsActive, UnitPrice, CurrencyIsoCode, Pricebook2.CurrencyIsoCode
                 FROM PricebookEntries
                 WHERE IsActive = true AND Pricebook2.IsActive = true AND Pricebook2Id = :softlandPriceBookId
                 ORDER BY UnitPrice DESC
                 LIMIT 1)
            FROM Product2
            WHERE Id = :prodXBodList[0].Producto__c
            LIMIT 1
        ];
        if (productList.isEmpty()) {
            responseMap.put('message', 'El vehiculo no fue encontrado.');
            return responseMap;
        }

        Product2 product = productList[0];

        if (product.PricebookEntries.isEmpty()) {
            responseMap.put('message', 'No se encontro el precio relacionado al vehiculo '+softlandPriceBookId+'.');
            return responseMap;
        }

        PricebookEntry softlandPriceBook = product.PricebookEntries[0];

        List<PricebookEntry> pbeFantasiaList;
        Decimal comisionVendedor = 0;
        Decimal comisionJefe = 0;
        Decimal comisionGerente = 0;
        Decimal precioVentaFantasia = 0;

        if (checkIfDifferentModel(oppProdInteres,prodXBodList[0])) {
            String brandLike = '%' + oppProdInteres.Marca__c + '%';
            String yearLike = '%' + oppProdInteres.Anio__c + '%';
            pbeFantasiaList = [
                SELECT Id, Product2Id, Pricebook2Id, Jefe__c, Gerente__c, Vendedor__c, Familia__c, Costo_Fijo__c,
                       pricebookEntryId__c, UnitPrice
                FROM PricebookEntry
                WHERE Pricebook2.Name LIKE :brandLike
                  AND Pricebook2.Name LIKE :yearLike
                  AND IsActive = true
                  AND Pricebook2.IsActive = true
                  AND CurrencyIsoCode = 'USD'
                  AND Product2.Modelo_De_Inter_s__c LIKE :model
                LIMIT 1
            ];

            if (pbeFantasiaList.isEmpty()) {
                brandLike = '%' + brand + '%';
                yearLike = '%' + year + '%';
                pbeFantasiaList = [
                    SELECT Id, Product2Id, Pricebook2Id, Jefe__c, Gerente__c, Vendedor__c, Familia__c, Costo_Fijo__c,
                           pricebookEntryId__c, UnitPrice
                    FROM PricebookEntry
                    WHERE Pricebook2.Name LIKE :brandLike
                      AND Pricebook2.Name LIKE :yearLike
                      AND IsActive = true
                      AND Pricebook2.IsActive = true
                      AND CurrencyIsoCode = 'USD'
                      AND Product2.Modelo_De_Inter_s__c LIKE :model
                    LIMIT 1
                ];
                if (pbeFantasiaList.isEmpty()) {
                    throw new AuraHandledException('No se encontro el precio de fantasia.');
                }
            }

            if (pbeFantasiaList[0].UnitPrice <= 0) {
                throw new AuraHandledException('El precio de fantasia debe ser mayor a 0.');
            }

            Oportunidad_Producto_Interes__c newOPI = crearOportunidadProductoInteresDiferenteModelo(oppId,prodXBodList[0].Producto__r,pbeFantasiaList[0]);
            oppProdIntId = newOPI.Id;

            comisionVendedor = ((pbeFantasiaList[0].Vendedor__c != null && pbeFantasiaList[0].UnitPrice != null && pbeFantasiaList[0].UnitPrice > 0) ? ((pbeFantasiaList[0].Vendedor__c * pbeFantasiaList[0].UnitPrice)/100) : 0);
            comisionJefe = ((pbeFantasiaList[0].Jefe__c != null && pbeFantasiaList[0].UnitPrice != null && pbeFantasiaList[0].UnitPrice > 0) ? ((pbeFantasiaList[0].Jefe__c * pbeFantasiaList[0].UnitPrice)/100) : 0);
            comisionGerente = ((pbeFantasiaList[0].Gerente__c != null && pbeFantasiaList[0].UnitPrice != null && pbeFantasiaList[0].UnitPrice > 0) ? ((pbeFantasiaList[0].Gerente__c * pbeFantasiaList[0].UnitPrice)/100) : 0);
            precioVentaFantasia = pbeFantasiaList[0].UnitPrice;
        } else {
            comisionVendedor = ((oppProdInteres.Comision_Porcentaje_Vendedor__c != null && oppProdInteres.Precio_Unitario__c != null && oppProdInteres.Precio_Unitario__c > 0) ? ((oppProdInteres.Comision_Porcentaje_Vendedor__c * oppProdInteres.Precio_Unitario__c)/100) : 0);
            comisionJefe = ((oppProdInteres.Comision_Porcentaje_Jefe__c != null && oppProdInteres.Precio_Unitario__c != null && oppProdInteres.Precio_Unitario__c > 0) ? ((oppProdInteres.Comision_Porcentaje_Jefe__c * oppProdInteres.Precio_Unitario__c)/100) : 0);
            comisionGerente = ((oppProdInteres.Comision_Porcentaje_Gerente__c != null && oppProdInteres.Precio_Unitario__c != null && oppProdInteres.Precio_Unitario__c > 0) ? ((oppProdInteres.Comision_Porcentaje_Gerente__c * oppProdInteres.Precio_Unitario__c)/100) : 0);
            precioVentaFantasia = oppProdInteres.Precio_Unitario__c;
        }

        if (precioVentaFantasia == null || precioVentaFantasia < 1) {
            responseMap.put('message', 'El precio de la lista de fantasia debe ser mayor que 0.');
            return responseMap;
        }

        try {
            if(oppProdInteres.Oportunidad__r.Pricebook2Id != null && oppProdInteres.Oportunidad__r.Pricebook2Id != softlandPriceBook.Pricebook2Id){
                List<Opportunity> opps = [SELECT Id,Pricebook2Id,(SELECT Id FROM OpportunityLineItems) FROM Opportunity WHERE Id = :oppProdInteres.Oportunidad__c LIMIT 1];

                if (opps.isEmpty()) {
                    responseMap.put('message', 'La oportunidad no fue encontrada.');
                    return responseMap;
                }

                Opportunity opp = opps[0];

                if (opp.OpportunityLineItems.size() > 0) {
                    DELETE opp.OpportunityLineItems;
                }

                opp.Pricebook2Id = softlandPriceBook.Pricebook2Id;
                UPDATE opp;
            }

            if (String.isBlank(existingQuoteId)) {
                Quote newQuote = new Quote(
                    Name = 'Quote Name',
                    OpportunityId = oppId,
                    Pricebook2Id = softlandPriceBook.Pricebook2Id,
                    CurrencyIsoCode = softlandPriceBook.CurrencyIsoCode
                );
                insert newQuote;
                existingQuoteId = newQuote.Id;
            }

            insert createAndInsertQuoteLineItem(
                existingQuoteId,
                prodXBodList[0].Producto__c,
                deliveryBodegaId, // ✅ aquí va la bodega de entrega forzada
                softlandPriceBook.Id,
                precioVentaFantasia,
                oppProdIntId,
                comisionVendedor,
                comisionJefe,
                comisionGerente
            );

            responseMap.put('success', true);
        } catch(Exception e) {
            responseMap.put('message', e.getMessage());
        }
        return responseMap;
    }

    private static QuoteLineItem createAndInsertQuoteLineItem(
        String existingQuoteId,
        Id productId,
        Id bodegaId,
        Id pricebookEntryId,
        Decimal unitPrice,
        Id oppProdIntId,
        Decimal comisionVendedor,
        Decimal comisionJefe,
        Decimal comisionGerente
    ) {
        QuoteLineItem newQLI = new QuoteLineItem(
            QuoteId = existingQuoteId,
            Product2Id = productId,
            Quantity = 1,
            BMW_Bodega__c = bodegaId,
            PricebookEntryId = pricebookEntryId,
            UnitPrice = unitPrice,
            Oportunidad_Producto_Interes__c = oppProdIntId,
            Comision_Vendedor__c = comisionVendedor,
            Comision_Jefe__c = comisionJefe,
            Comision_Gerente__c = comisionGerente
        );
        return newQLI;
    }

    public static Map<String,Object> addLineItem(String quoteId,String prodXBodId,String qliId,Boolean esRegalia,Boolean esExtra,String productType,String productAlias,Decimal productQuantity,Decimal productUnitPrice){
        Map<String,Object> responseMap = new Map<String,Object>{'success' => false };

        if (productType == 'mano obra' && (productQuantity == null || productQuantity <=0)) {
            responseMap.put('message', 'La cantidad tiene que ser mayor a 0.');
            return responseMap;
        }

        if ((productType == 'mano obra' || productType == 'extra') && (productUnitPrice == null || productUnitPrice <=0)) {
            responseMap.put('message', 'El precio tiene que ser mayor a 0.');
            return responseMap;
        }

        Id productId;
        Id bodegaId;

        ProductoXBodega__c selectedPxb;
        List<Quote> pptos = [SELECT Id,Pricebook2Id FROM Quote WHERE Id = :quoteId LIMIT 1];
        if (pptos.isEmpty()) {
            responseMap.put('message', 'El presupuesto no fue encontrado.');
            return responseMap;
        }

        Quote ppto = pptos[0];

        if (productType == 'mano obra') {
            productId = (Id)prodXBodId;
        } else {
            List<ProductoXBodega__c> prodXBodList = [
                SELECT Id,Producto__c,Bodega__c,Bodega__r.Bodega__c,Bodega__r.ID_EXTERNO_BODEGA__c,Disponible__c,
                       Producto__r.vin__c,Producto__r.Marca__c,Producto__r.Modelo_De_Inter_s__c,
                       Producto__r.marcaVehiculo__c,Producto__r.Empresa__c
                FROM ProductoXBodega__c
                WHERE Id =:prodXBodId
                LIMIT 1
            ];
            if (prodXBodList.isEmpty()) {
                responseMap.put('message', 'No se encontro el producto');
                return responseMap;
            }

            selectedPxb = prodXBodList[0];
            productId = selectedPxb.Producto__c;

            // FIX: si viene de bodega no principal (por "Todos"), forzar bodega de entrega BR01/BR02/RM01
            bodegaId = resolveDeliveryBodegaIdForQuote((Id)quoteId, selectedPxb);
        }

        List<PricebookEntry> pricebookEntryList = [
            SELECT Id,UnitPrice,Product2.Name,CurrencyIsoCode,Pricebook2Id,Pricebook2.CurrencyIsoCode,Costo_Fijo__c
            FROM PricebookEntry
            WHERE IsActive = true
              AND Pricebook2.IsActive = true
              AND Pricebook2.Id = :ppto.Pricebook2Id
              AND Product2Id = :productId
            LIMIT 1
        ];
        if (pricebookEntryList.isEmpty()) {
            responseMap.put('message', 'No se encontro el precio relacionado al producto.');
            return responseMap;
        } else if (productType == 'extra'){
            productUnitPrice = esRegalia ? pricebookEntryList[0].Costo_Fijo__c : pricebookEntryList[0].UnitPrice;
        }

        productQuantity = productQuantity == null ? 1 : productQuantity;
        Decimal total = productQuantity * productUnitPrice;

        try {
            QuoteLineItem newQLI = new QuoteLineItem(
                QuoteId = quoteId,
                Product2Id = productId,
                BMW_Alias__c = productAlias,
                Quantity = productQuantity,
                PricebookEntryId = pricebookEntryList[0].Id,
                UnitPrice = productUnitPrice,
                esRegalia__c = esRegalia,
                esExtra__c = esExtra,
                Quote_Line_Item__c = qliId,
                BMW_Bodega__c = bodegaId,
                Total_Extra__c = esExtra ? total : 0,
                Total_Regalia__c = esRegalia ? total : 0
            );

            insert newQLI;
            responseMap.put('success', true);
        } catch (DmlException e) {
            responseMap.put('message', e.getMessage());
        }
        return responseMap;
    }

    public static Boolean checkIfDifferentModel(Oportunidad_Producto_Interes__c oppProdInteres, ProductoXBodega__c prodXBodega) {
        if (String.isNotBlank(oppProdInteres.Marca__c) && String.isNotBlank(prodXBodega.Producto__r.marcaVehiculo__c) && oppProdInteres.Marca__c != prodXBodega.Producto__r.marcaVehiculo__c) {
            return true;
        }
        if (String.isNotBlank(oppProdInteres.Anio__c) && String.isNotBlank(prodXBodega.Producto__r.Anno__c) && oppProdInteres.Anio__c != String.valueOf(prodXBodega.Producto__r.Anno__c)) {
            return true;
        }
        if (String.isNotBlank(oppProdInteres.Modelo_Interes__c) && String.isNotBlank(prodXBodega.Producto__r.modelo__c) && oppProdInteres.Modelo_Interes__c != prodXBodega.Producto__r.modelo__c) {
            return true;
        }
        return false;
    }

    public static Oportunidad_Producto_Interes__c crearOportunidadProductoInteresDiferenteModelo(String oppId,Product2 prod,PricebookEntry pbe){
        List<Oportunidad_Producto_Interes__c> oppProdInteresList = [
            SELECT Id, Bodega__c, Cantidad__c, Familia__c, Gerente__c,
                   Jefe__c, Marca__c, Modelo_Interes__c, Oportunidad__c,
                   Precio_Unitario__c, Producto__c, Vendedor__c, Anio__c, PricebookEntryId__c,
                   Comision_Porcentaje_Gerente__c, Comision_Porcentaje_Jefe__c
            FROM Oportunidad_Producto_Interes__c
            WHERE Oportunidad__c = :oppId
              AND Producto__c = :pbe.Product2Id
            LIMIT 1
        ];
        if (oppProdInteresList.size()>0) {
            return oppProdInteresList[0];
        } else {
            Oportunidad_Producto_Interes__c newRecord = new Oportunidad_Producto_Interes__c(
                Oportunidad__c = oppId,
                Producto__c = pbe.Product2Id,
                Precio_Unitario__c = pbe.UnitPrice,
                Costo_Fijo__c = pbe.Costo_Fijo__c,
                Cantidad__c = 1,
                Comision_Porcentaje_Vendedor__c = pbe.Vendedor__c,
                Comision_Porcentaje_Gerente__c = pbe.Gerente__c,
                Comision_Porcentaje_Jefe__c = pbe.Jefe__c,
                PricebookEntryId__c = pbe.Id,
                Marca__c = prod.marcaVehiculo__c,
                Modelo_Interes__c = prod.modelo__c,
                Anio__c =  String.valueOf(prod.Anno__c)
            );
            insert newRecord;
            return newRecord;
        }
    }

}
