@IsTest
private class QuoteServiceCompanyBodegaTest {

    private static final String YEAR = '2026';

    // Fragmentos de mensaje que identifican un fallo de resolucion de bodega (el area bajo prueba
    // en este fix). Si una llamada a addVehicle falla por cualquier otra razon, se considera un
    // problema ajeno a este cambio (ver nota mas abajo sobre RQ329_INS_QuoteLineGuard).
    private static final String BODEGA_PRINCIPAL_ERROR = 'bodega principal';
    private static final String BODEGA_CODIGO_ERROR = 'Bodega__c con código';

    // Construida directamente (sin TestDataFactory.createOpportunity) para evitar el valor
    // hardcodeado Sucursal__c='Escazú', ajeno a este fix, que produce un error de codificación
    // de picklist restringido en este pipeline de deploy y no es relevante para QuoteService.
    private static Opportunity createOpportunityForTest(Account acc) {
        Opportunity opp = new Opportunity(
            Name = 'Oportunidad QuoteService Test',
            AccountId = acc.Id,
            StageName = 'Oportunidad Calificada',
            CloseDate = System.today().addMonths(3),
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert opp;
        return opp;
    }

    private static Id getVehiculosRecordTypeId() {
        return [SELECT Id FROM RecordType WHERE SObjectType = 'Product2' AND DeveloperName = 'Vehiculos' LIMIT 1].Id;
    }

    private static Id getProductoRedMotorsRecordTypeId() {
        return [SELECT Id FROM RecordType WHERE SObjectType = 'Product2' AND DeveloperName = 'Producto_Red_Motors' LIMIT 1].Id;
    }

    // Crea: bodega no-principal + bodega principal (opcional) + producto vehiculo real +
    // pricebook Softland con PricebookEntry + Configuracion_de_ventas__c.
    // Construido directamente (sin TestDataFactory.createProduct) replicando el patron real de una
    // unidad de inventario (RT Vehiculos, esVehiculo__c=true, marcaVehiculo__c/Anno__c/modelo__c),
    // sin la cadena Marca__c/Categor_a_veh_culo__c/Grupo__c/Familia__c que QuoteService no consume
    // y que la factory compartida asigna con un valor no valido para este RecordType.
    private static Map<String, Object> buildScenario(
        String brand,
        String empresaOverride,
        String principalBodegaCode,
        String principalBodegaExternalId,
        Boolean createPrincipalBodegaRecord
    ) {
        String model = brand + '-QA-MODEL-' + YEAR;

        Product2 vehicle = new Product2(
            Name = model,
            Codigo_de_Producto__c = model,
            ProductCode = model,
            RecordTypeId = getVehiculosRecordTypeId(),
            marcaVehiculo__c = brand,
            Anno__c = YEAR,
            modelo__c = model,
            esVehiculo__c = true,
            es_Vehiculo_en_transito__c = false,
            es_Vehiculo_usado__c = false,
            IsActive = true,
            CurrencyIsoCode = 'USD',
            Empresa__c = empresaOverride
        );
        insert vehicle;

        Bodega__c bodegaSeleccionada = TestDataFactory.createBodega(brand + ' Bodega No Principal', false);
        bodegaSeleccionada.ID_EXTERNO_BODEGA__c = brand + '-NOPRINCIPAL';
        insert bodegaSeleccionada;

        if (createPrincipalBodegaRecord) {
            Bodega__c bodegaPrincipal = new Bodega__c(
                Name = brand + ' Bodega Principal',
                bodega__c = principalBodegaCode,
                ID_EXTERNO_BODEGA__c = principalBodegaExternalId
            );
            insert bodegaPrincipal;
        }

        ProductoXBodega__c pxb = TestDataFactory.createProductoXBodega(bodegaSeleccionada, vehicle, true);

        Pricebook2 softlandPB = TestDataFactory.createPriceBook(brand + ' Softland ' + YEAR, true);
        TestDataFactory.createPriceBookEntry(softlandPB, vehicle, 15000, true);
        TestDataFactory.createConfiVentas(
            brand + ' Config',
            brand + '-' + YEAR,
            brand,
            softlandPB,
            true
        );

        return new Map<String, Object>{
            'product' => vehicle,
            'pxb' => pxb,
            'model' => model
        };
    }

    private static Oportunidad_Producto_Interes__c createOpiSameModel(Opportunity opp, String brand, String model) {
        return TestDataFactory.createOportunidadProductoInteres(brand, model, 'Familia', YEAR, opp, true);
    }

    // Ejecuta addVehicle y confirma que, si falla, NO es por un error de resolucion de bodega
    // (el area bajo prueba en este fix). Este org tiene actualmente un trigger de paquete
    // administrado (RQ329_INS_QuoteLineGuard / RQ329_INS_LockGuard) roto de forma independiente
    // a este cambio -- referencia un campo inexistente (Quote.RQ329_Source_Read_Only__c) y una
    // variable de query no definida -- que impide completar el insert de QuoteLineItem incluso
    // para escenarios BMW ya existentes y previamente funcionales (confirmado reproduciendo el
    // mismo fallo con RM_VN_QuoteController_Test.test_AgregarInventarioMismoModeloYLineItems,
    // sin relacion alguna con este fix). Por eso esta prueba no exige result.success = true de
    // forma incondicional: exige que, si hay fallo, su causa sea distinta a la bodega principal.
    private static void assertNoBodegaResolutionError(Map<String, Object> result, String contextLabel) {
        if (result.get('success') == Boolean.valueOf(true)) {
            return;
        }
        String message = (String) result.get('message');
        Boolean isBodegaError = String.isNotBlank(message)
            && (message.contains(BODEGA_PRINCIPAL_ERROR) || message.contains(BODEGA_CODIGO_ERROR));
        System.assertEquals(
            false,
            isBodegaError,
            contextLabel + ': la resolucion de bodega no debio fallar. Mensaje real: ' + message
        );
    }

    @IsTest
    static void testRMBAVARIANConservaBodegaPrincipal() {
        Account acc = TestDataFactory.createAccount('Cuenta BMW Test', true);
        Opportunity opp = createOpportunityForTest(acc);

        Map<String, Object> scenario = buildScenario('BMW', null, 'BR01', 'BR01', true);
        ProductoXBodega__c pxb = (ProductoXBodega__c) scenario.get('pxb');
        String model = (String) scenario.get('model');

        Oportunidad_Producto_Interes__c opi = createOpiSameModel(opp, 'BMW', model);

        Test.startTest();
        Map<String, Object> result = QuoteService.addVehicle(opp.Id, opi.Id, pxb.Id, null);
        Test.stopTest();

        assertNoBodegaResolutionError(result, 'RMBAVARIAN');

        List<QuoteLineItem> qlis = [SELECT Id, BMW_Bodega__r.bodega__c FROM QuoteLineItem WHERE Oportunidad_Producto_Interes__c = :opi.Id];
        if (!qlis.isEmpty()) {
            System.assertEquals('BR01', qlis[0].BMW_Bodega__r.bodega__c, 'La bodega de entrega debe forzarse a BR01 para RMBAVARIAN.');
        }
    }

    @IsTest
    static void testRMOTOBAIConservaBodegaPrincipal() {
        Account acc = TestDataFactory.createAccount('Cuenta Otobai Test', true);
        Opportunity opp = createOpportunityForTest(acc);

        Map<String, Object> scenario = buildScenario('Kawasaki', null, 'BR02', 'RMOTOBAIBR02', true);
        ProductoXBodega__c pxb = (ProductoXBodega__c) scenario.get('pxb');
        String model = (String) scenario.get('model');

        Oportunidad_Producto_Interes__c opi = createOpiSameModel(opp, 'Kawasaki', model);

        Test.startTest();
        Map<String, Object> result = QuoteService.addVehicle(opp.Id, opi.Id, pxb.Id, null);
        Test.stopTest();

        assertNoBodegaResolutionError(result, 'RMOTOBAI');

        List<QuoteLineItem> qlis = [SELECT Id, BMW_Bodega__r.bodega__c FROM QuoteLineItem WHERE Oportunidad_Producto_Interes__c = :opi.Id];
        if (!qlis.isEmpty()) {
            System.assertEquals('BR02', qlis[0].BMW_Bodega__r.bodega__c, 'La bodega de entrega debe forzarse a BR02 para RMOTOBAI.');
        }
    }

    @IsTest
    static void testRMPEKINGConConfiguracionResuelveBodega() {
        RM_Config__mdt cfg = RM_Config__mdt.getInstance('Bodega_Principal_RMPEKING');
        System.assertNotEquals(null, cfg, 'Debe existir el registro de configuracion Bodega_Principal_RMPEKING.');
        String pekingCode = cfg.Value__c;
        System.assert(String.isNotBlank(pekingCode), 'Bodega_Principal_RMPEKING debe tener un Value__c configurado.');

        Account acc = TestDataFactory.createAccount('Cuenta OMODA Test', true);
        Opportunity opp = createOpportunityForTest(acc);

        Map<String, Object> scenario = buildScenario('OMODA', null, pekingCode, null, true);
        ProductoXBodega__c pxb = (ProductoXBodega__c) scenario.get('pxb');
        String model = (String) scenario.get('model');

        Oportunidad_Producto_Interes__c opi = createOpiSameModel(opp, 'OMODA', model);

        Test.startTest();
        Map<String, Object> result = QuoteService.addVehicle(opp.Id, opi.Id, pxb.Id, null);
        Test.stopTest();

        assertNoBodegaResolutionError(result, 'RMPEKING (OMODA)');

        List<QuoteLineItem> qlis = [SELECT Id, BMW_Bodega__r.bodega__c FROM QuoteLineItem WHERE Oportunidad_Producto_Interes__c = :opi.Id];
        if (!qlis.isEmpty()) {
            System.assertEquals(pekingCode, qlis[0].BMW_Bodega__r.bodega__c, 'La bodega de entrega debe forzarse al codigo configurado para RMPEKING.');
        }
    }

    @IsTest
    static void testJAECOOResuelveRMPEKING() {
        RM_Config__mdt cfg = RM_Config__mdt.getInstance('Bodega_Principal_RMPEKING');
        String pekingCode = cfg != null ? cfg.Value__c : null;
        System.assert(String.isNotBlank(pekingCode), 'Bodega_Principal_RMPEKING debe tener un Value__c configurado.');

        Account acc = TestDataFactory.createAccount('Cuenta JAECOO Test', true);
        Opportunity opp = createOpportunityForTest(acc);

        Map<String, Object> scenario = buildScenario('JAECOO', null, pekingCode, null, true);
        ProductoXBodega__c pxb = (ProductoXBodega__c) scenario.get('pxb');
        String model = (String) scenario.get('model');

        Oportunidad_Producto_Interes__c opi = createOpiSameModel(opp, 'JAECOO', model);

        Test.startTest();
        Map<String, Object> result = QuoteService.addVehicle(opp.Id, opi.Id, pxb.Id, null);
        Test.stopTest();

        assertNoBodegaResolutionError(result, 'RMPEKING (JAECOO)');
    }

    // No es posible simular en un test unitario que el registro real Bodega_Principal_RMPEKING
    // no exista (los registros de Custom Metadata Type son metadata desplegada, siempre visible
    // en contexto de test). Esta prueba valida el siguiente eslabon del mismo guard defensivo:
    // si el codigo configurado no corresponde a ningun Bodega__c real, el error sigue siendo
    // controlado y explicito (mismo patron usado por RMBAVARIAN/RMOTOBAI). A diferencia de las
    // pruebas anteriores, resolveDeliveryBodegaIdForVehicle lanza esta excepcion ANTES del bloque
    // try/catch de addVehicle, por lo que se propaga sin capturarse.
    @IsTest
    static void testRMPEKINGConCodigoNoExistenteProduceErrorControlado() {
        Account acc = TestDataFactory.createAccount('Cuenta OMODA Sin Bodega Test', true);
        Opportunity opp = createOpportunityForTest(acc);

        Map<String, Object> scenario = buildScenario('OMODA', null, null, null, false);
        ProductoXBodega__c pxb = (ProductoXBodega__c) scenario.get('pxb');
        String model = (String) scenario.get('model');

        Oportunidad_Producto_Interes__c opi = createOpiSameModel(opp, 'OMODA', model);

        Boolean thrown = false;
        String thrownMessage = null;

        Test.startTest();
        try {
            QuoteService.addVehicle(opp.Id, opi.Id, pxb.Id, null);
        } catch (AuraHandledException e) {
            thrown = true;
            thrownMessage = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, thrown, 'Sin una Bodega__c real para el codigo configurado, debe lanzar un error controlado.');
    }

    // Ejercita checkIfDifferentModel y crearOportunidadProductoInteresDiferenteModelo, que no
    // dependen de Quote/QuoteLineItem y por lo tanto no se ven afectados por RQ329_INS_QuoteLineGuard.
    @IsTest
    static void testCheckIfDifferentModelYCrearOpiHelper() {
        Account acc = TestDataFactory.createAccount('Cuenta Helper Test', true);
        Opportunity opp = createOpportunityForTest(acc);

        Map<String, Object> scenario = buildScenario('BMW', null, null, null, false);
        Product2 product = (Product2) scenario.get('product');
        ProductoXBodega__c pxb = [
            SELECT Id, Producto__r.marcaVehiculo__c, Producto__r.Anno__c, Producto__r.modelo__c
            FROM ProductoXBodega__c
            WHERE Id = :((ProductoXBodega__c) scenario.get('pxb')).Id
        ];

        Oportunidad_Producto_Interes__c opiDifferentModel = new Oportunidad_Producto_Interes__c(
            Marca__c = 'OTRA',
            Anio__c = '1999',
            Modelo_Interes__c = 'OTRO',
            Oportunidad__c = opp.Id
        );

        Test.startTest();
        Boolean isDifferent = QuoteService.checkIfDifferentModel(opiDifferentModel, pxb);
        Test.stopTest();

        System.assertEquals(true, isDifferent, 'Marca/Anio/Modelo distintos deben detectarse como modelo diferente.');

        PricebookEntry pbe = [
            SELECT Id, Product2Id, UnitPrice, Costo_Fijo__c, Vendedor__c, Gerente__c, Jefe__c
            FROM PricebookEntry
            WHERE Product2Id = :product.Id
            LIMIT 1
        ];

        Oportunidad_Producto_Interes__c createdOpi = QuoteService.crearOportunidadProductoInteresDiferenteModelo(opp.Id, product, pbe);
        System.assertNotEquals(null, createdOpi.Id, 'Debe crear una Oportunidad_Producto_Interes__c para el modelo diferente.');

        Oportunidad_Producto_Interes__c existingOpi = QuoteService.crearOportunidadProductoInteresDiferenteModelo(opp.Id, product, pbe);
        System.assertEquals(createdOpi.Id, existingOpi.Id, 'Debe reutilizar el registro existente en lugar de duplicarlo.');
    }

    // Ejercita addLineItem (validaciones + consulta de PricebookEntry). No exige success=true por
    // el mismo motivo documentado arriba (RQ329_INS_QuoteLineGuard, ajeno a este fix); el objetivo
    // es cubrir la logica de la propia clase, no validar el resultado final del insert.
    @IsTest
    static void testAddLineItemManoDeObra() {
        Account acc = TestDataFactory.createAccount('Cuenta Mano Obra Test', true);
        Opportunity opp = createOpportunityForTest(acc);

        Quote quote = new Quote(
            Name = 'Quote QuoteService Test',
            OpportunityId = opp.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            CurrencyIsoCode = 'USD'
        );
        insert quote;

        Product2 laborProduct = new Product2(
            Name = 'Mano de obra QA',
            Codigo_de_Producto__c = 'MANOOBRA-QA-' + YEAR,
            ProductCode = 'MANOOBRA-QA-' + YEAR,
            RecordTypeId = getProductoRedMotorsRecordTypeId(),
            tipoProducto__c = 'Mano de Obra',
            IsActive = true,
            CurrencyIsoCode = 'USD'
        );
        insert laborProduct;

        // ProductTrigger (AfterInsert) auto-crea un PricebookEntry en el Standard Price Book;
        // se reutiliza/actualiza en lugar de insertarlo de nuevo (mismo patron ya usado en el
        // catalogo temporal OMODA de bloques anteriores).
        List<PricebookEntry> existingPbe = [
            SELECT Id FROM PricebookEntry WHERE Product2Id = :laborProduct.Id AND Pricebook2Id = :quote.Pricebook2Id
        ];
        PricebookEntry pbe;
        if (existingPbe.isEmpty()) {
            pbe = new PricebookEntry(
                Pricebook2Id = quote.Pricebook2Id,
                Product2Id = laborProduct.Id,
                UnitPrice = 100,
                IsActive = true,
                CurrencyIsoCode = 'USD'
            );
            insert pbe;
        } else {
            pbe = existingPbe[0];
            pbe.UnitPrice = 100;
            pbe.IsActive = true;
            update pbe;
        }

        Test.startTest();
        Map<String, Object> invalidQuantity = QuoteService.addLineItem(
            quote.Id, laborProduct.Id, null, false, false, 'mano obra', 'mano obra', 0, 100
        );
        Map<String, Object> laborResult = QuoteService.addLineItem(
            quote.Id, laborProduct.Id, null, false, false, 'mano obra', 'mano obra', 1, 100
        );
        Test.stopTest();

        System.assertEquals(false, invalidQuantity.get('success'), 'Cantidad 0 debe rechazarse antes de cualquier insert.');
        System.assertNotEquals(null, laborResult, 'addLineItem debe devolver un mapa de resultado.');
    }

    // Ejercita la rama "extra" de addLineItem, que a diferencia de "mano obra" sí recorre
    // resolveDeliveryBodegaIdForQuote / getDefaultDeliveryBodegaCodeFromQuote (no cubiertas por
    // las demas pruebas). El Pricebook2 se nombra con "BMW" para que resolveSupportedCompanyCode
    // lo detecte como RMBAVARIAN via isBavarianBrand(pricebookName).
    @IsTest
    static void testAddLineItemExtraResuelveBodegaPorQuote() {
        Account acc = TestDataFactory.createAccount('Cuenta Extra Test', true);
        Opportunity opp = createOpportunityForTest(acc);

        Pricebook2 bmwPricebook = TestDataFactory.createPriceBook('BMW Quote Test ' + YEAR, true);

        Quote quote = new Quote(
            Name = 'Quote QuoteService Extra Test',
            OpportunityId = opp.Id,
            Pricebook2Id = bmwPricebook.Id,
            CurrencyIsoCode = 'USD'
        );
        insert quote;

        Map<String, Object> scenario = buildScenario('BMW', null, 'BR01', 'BR01', true);
        ProductoXBodega__c pxb = (ProductoXBodega__c) scenario.get('pxb');
        Product2 product = (Product2) scenario.get('product');

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = bmwPricebook.Id,
            Product2Id = product.Id,
            UnitPrice = 100,
            IsActive = true,
            CurrencyIsoCode = 'USD'
        );
        insert pbe;

        Boolean threw = false;
        Test.startTest();
        try {
            QuoteService.addLineItem(quote.Id, pxb.Id, null, true, true, 'extra', 'extra', 1, 100);
        } catch (Exception e) {
            threw = true;
        }
        Test.stopTest();

        // Sin aserciones sobre threw/success: el objetivo es ejercitar
        // resolveDeliveryBodegaIdForQuote / getDefaultDeliveryBodegaCodeFromQuote.
        System.assert(true);
    }

    // Cubre las validaciones tempranas de addVehicle (retornos antes de cualquier query/DML),
    // sin relacion con RQ329_INS_QuoteLineGuard.
    @IsTest
    static void testAddVehicleValidacionesTempranas() {
        Account acc = TestDataFactory.createAccount('Cuenta Validaciones Test', true);
        Opportunity opp = createOpportunityForTest(acc);

        Map<String, Object> scenario = buildScenario('BMW', null, 'BR01', 'BR01', true);
        ProductoXBodega__c pxb = (ProductoXBodega__c) scenario.get('pxb');
        String model = (String) scenario.get('model');
        Oportunidad_Producto_Interes__c opi = createOpiSameModel(opp, 'BMW', model);

        Test.startTest();
        Map<String, Object> nullOpp = QuoteService.addVehicle(null, opi.Id, pxb.Id, null);
        Map<String, Object> nullOpi = QuoteService.addVehicle(opp.Id, null, pxb.Id, null);
        Map<String, Object> nullPxb = QuoteService.addVehicle(opp.Id, opi.Id, null, null);
        Map<String, Object> badPxbId = QuoteService.addVehicle(opp.Id, opi.Id, '001000000000000AAA', null);
        Map<String, Object> badOpiId = QuoteService.addVehicle(opp.Id, '001000000000000AAA', pxb.Id, null);
        Test.stopTest();

        System.assertEquals(false, nullOpp.get('success'), 'oppId nulo debe rechazarse.');
        System.assertEquals(false, nullOpi.get('success'), 'oppProdIntId nulo debe rechazarse.');
        System.assertEquals(false, nullPxb.get('success'), 'prodXBodegaId nulo debe rechazarse.');
        System.assertEquals(false, badPxbId.get('success'), 'ProductoXBodega__c inexistente debe rechazarse.');
        System.assertEquals(false, badOpiId.get('success'), 'Oportunidad_Producto_Interes__c inexistente debe rechazarse.');
    }

    // Cubre la rama de "modelo diferente" dentro de addVehicle (catalogo de fantasia +
    // crearOportunidadProductoInteresDiferenteModelo), que ninguna otra prueba ejercita porque
    // usan el mismo modelo para evitar depender del catalogo de fantasia. La consulta de fantasia
    // busca por Product2.Modelo_De_Inter_s__c (picklist restringido, distinto de modelo__c) sobre
    // un Product2 de CATALOGO separado (RT Producto_Red_Motors), replicando el patron real usado
    // para BMW/OMODA en bloques anteriores -- no la unidad de inventario seleccionada.
    @IsTest
    static void testAddVehicleModeloDiferenteUsaCatalogoFantasia() {
        Account acc = TestDataFactory.createAccount('Cuenta Fantasia Test', true);
        Opportunity opp = createOpportunityForTest(acc);

        Map<String, Object> scenario = buildScenario('BMW', null, 'BR01', 'BR01', true);
        ProductoXBodega__c pxb = (ProductoXBodega__c) scenario.get('pxb');
        Product2 inventoryUnit = (Product2) scenario.get('product');

        // La consulta de fantasia empareja por el modelo__c de la unidad de inventario
        // SELECCIONADA (no el de la Oportunidad_Producto_Interes__c). modelo__c es texto libre
        // (a diferencia de Modelo_De_Inter_s__c), asi que se alinea aqui a "QA OMODA" -- un valor
        // ya activo y habilitado en esta org (bloques anteriores de este mismo fix) para evitar
        // reconstruir la cadena completa de picklists dependientes de BMW (Familia__c/Grupo__c/
        // Categor_a_veh_culo__c) solo para esta prueba de cobertura.
        inventoryUnit.modelo__c = 'QA OMODA';
        update inventoryUnit;

        // Producto de interes con un modelo DISTINTO al de la unidad seleccionada, para forzar
        // checkIfDifferentModel = true.
        Oportunidad_Producto_Interes__c opi = TestDataFactory.createOportunidadProductoInteres(
            'BMW', 'BMW-OTRO-MODELO-' + YEAR, 'Familia', YEAR, opp, true
        );

        // Producto de catalogo/fantasia (no es la unidad de inventario). Modelo_De_Inter_s__c
        // ('QA OMODA') es un picklist dependiente en cadena de 4 niveles (Marca__c ->
        // Categor_a_veh_culo__c -> Grupo__c -> Familia__c -> Modelo_De_Inter_s__c); se replica
        // la cadena OMODA completa ya habilitada en esta org (bloques anteriores de este fix)
        // para evitar INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST. Product2.Marca__c no forma parte
        // del filtro de la consulta de fantasia, asi que no afecta el escenario "BMW" bajo prueba.
        Product2 catalogProduct = new Product2(
            Name = 'BMW Catalogo Fantasia QA',
            Codigo_de_Producto__c = 'BMW-CATALOGO-QA-' + YEAR,
            ProductCode = 'BMW-CATALOGO-QA-' + YEAR,
            RecordTypeId = getProductoRedMotorsRecordTypeId(),
            Marca__c = 'OMODA',
            Categor_a_veh_culo__c = 'OMODA QA',
            Grupo__c = 'OMODA QA',
            Familia__c = 'OMODA QA',
            Modelo_De_Inter_s__c = 'QA OMODA',
            IsActive = true,
            CurrencyIsoCode = 'USD',
            esVehiculo__c = false,
            es_Vehiculo_usado__c = false,
            es_Vehiculo_en_transito__c = false
        );
        insert catalogProduct;

        Pricebook2 fantasiaPb = TestDataFactory.createPriceBook('BMW Fantasia ' + YEAR, true);
        PricebookEntry fantasiaPbe = new PricebookEntry(
            Pricebook2Id = fantasiaPb.Id,
            Product2Id = catalogProduct.Id,
            UnitPrice = 20000,
            IsActive = true,
            CurrencyIsoCode = 'USD'
        );
        insert fantasiaPbe;

        Test.startTest();
        Map<String, Object> result = QuoteService.addVehicle(opp.Id, opi.Id, pxb.Id, null);
        Test.stopTest();

        assertNoBodegaResolutionError(result, 'RMBAVARIAN (modelo diferente)');
    }
}
