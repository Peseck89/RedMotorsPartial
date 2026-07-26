@isTest
public class ProductSearcherControllerTest {

    private static final String OPP_NAME_PREFIX = 'Bloque18-';
    private static final String PROD_BAVARIAN = 'Bloque18-MO-Bavarian';
    private static final String PROD_OTOBAI = 'Bloque18-MO-Otobai';
    private static final String PROD_PEKING = 'Bloque18-MO-Peking';
    private static final String PROD_BAVARIAN_INACTIVE = 'Bloque18-MO-Bavarian-Inactive';

    @TestSetup
    static void makeData(){
        TestDataFactory.createQuoteWithItems();

        Account acc = [SELECT Id FROM Account WHERE Name = 'Account Test Juan C.' LIMIT 1];
        String campaignRtId = TestDataFactory.getRecordTypeId('Campaign','Campana_Red_Motors');
        Campaign camp = TestDataFactory.createCampanna('Campaign Bloque18', campaignRtId, true);
        Id standardPricebookId = Test.getStandardPricebookId();

        List<String> mappedRecordTypes = new List<String>{'BMW','MINI','Polaris','Kawasaki','Omoda','Jaecoo'};
        List<Opportunity> opps = new List<Opportunity>();
        for (String rt : mappedRecordTypes) {
            opps.add(buildOpportunity(rt, acc.Id, camp.Id, standardPricebookId));
        }

        // Para el escenario de "Record Type no reconocido" se usa un RecordType de Opportunity
        // real y activo que exista en el org pero que no este en el mapeo de empresas, en vez de
        // dejar RecordTypeId vacio (lo cual dispara un NPE preexistente fuera del alcance de este bloque).
        List<RecordType> unmappedRts = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND IsActive = true AND DeveloperName NOT IN :mappedRecordTypes LIMIT 1];
        System.assert(!unmappedRts.isEmpty(), 'No se encontro un RecordType de Opportunity activo fuera del mapeo de empresas para probar el caso "no reconocido"');
        opps.add(buildUnmappedOpportunity(acc.Id, camp.Id, standardPricebookId, unmappedRts[0].Id));
        insert opps;

        List<Quote> quotes = new List<Quote>();
        for (Opportunity o : opps) {
            if (o.RT_Lead__c != 'Unmapped') {
                Quote q = TestDataFactory.createQuote(o, false);
                q.Pricebook2Id = standardPricebookId;
                quotes.add(q);
            }
        }
        insert quotes;

        List<Product2> products = new List<Product2>();
        products.add(buildManoObraProduct(PROD_BAVARIAN, 'RMBAVARIAN', true));
        products.add(buildManoObraProduct(PROD_OTOBAI, 'RMOTOBAI', true));
        products.add(buildManoObraProduct(PROD_PEKING, 'RMPEKING', true));
        products.add(buildManoObraProduct(PROD_BAVARIAN_INACTIVE, 'RMBAVARIAN', false));
        insert products;

        // El org puede autogenerar un PricebookEntry estandar al insertar un Product2 activo;
        // por eso se hace upsert manual (buscar existente -> update, si no -> insert) en vez de
        // asumir que siempre hay que insertar.
        List<Id> activeProductIds = new List<Id>();
        for (Product2 p : products) {
            if (p.IsActive) {
                activeProductIds.add(p.Id);
            }
        }
        Map<Id,PricebookEntry> existingPbeByProductId = new Map<Id,PricebookEntry>();
        for (PricebookEntry existing : [SELECT Id, Product2Id, UnitPrice, IsActive FROM PricebookEntry WHERE Pricebook2Id = :standardPricebookId AND Product2Id IN :activeProductIds]) {
            existingPbeByProductId.put(existing.Product2Id, existing);
        }

        List<PricebookEntry> pbesToInsert = new List<PricebookEntry>();
        List<PricebookEntry> pbesToUpdate = new List<PricebookEntry>();
        for (Product2 p : products) {
            if (!p.IsActive) {
                continue;
            }
            if (existingPbeByProductId.containsKey(p.Id)) {
                PricebookEntry existing = existingPbeByProductId.get(p.Id);
                existing.UnitPrice = 100;
                existing.IsActive = true;
                pbesToUpdate.add(existing);
            } else {
                pbesToInsert.add(TestDataFactory.createPriceBookEntry(new Pricebook2(Id = standardPricebookId), p, 100, false));
            }
        }
        if (!pbesToInsert.isEmpty()) {
            insert pbesToInsert;
        }
        if (!pbesToUpdate.isEmpty()) {
            update pbesToUpdate;
        }
    }

    private static Opportunity buildOpportunity(String recordTypeDeveloperName, Id accountId, Id campaignId, Id pricebookId) {
        Id rtId = TestDataFactory.getRecordTypeId('Opportunity', recordTypeDeveloperName);
        System.assert(rtId != null, 'RecordType de Opportunity no encontrado en el org conectado: ' + recordTypeDeveloperName);
        return new Opportunity(
            Name = OPP_NAME_PREFIX + recordTypeDeveloperName,
            AccountId = accountId,
            CloseDate = System.today().addMonths(3),
            StageName = 'Oportunidad Calificada',
            Campana__c = campaignId,
            Sucursal__c = 'Escazú',
            IngresoAproximado__c = 1500,
            RT_Lead__c = recordTypeDeveloperName,
            Pricebook2Id = pricebookId,
            RecordTypeId = rtId
        );
    }

    private static Opportunity buildUnmappedOpportunity(Id accountId, Id campaignId, Id pricebookId, Id unmappedRecordTypeId) {
        return new Opportunity(
            Name = OPP_NAME_PREFIX + 'Unmapped',
            AccountId = accountId,
            CloseDate = System.today().addMonths(3),
            StageName = 'Oportunidad Calificada',
            Campana__c = campaignId,
            Sucursal__c = 'Escazú',
            IngresoAproximado__c = 1500,
            RT_Lead__c = 'Unmapped',
            Pricebook2Id = pricebookId,
            RecordTypeId = unmappedRecordTypeId
        );
    }

    private static Product2 buildManoObraProduct(String name, String empresaCode, Boolean isActive) {
        // Reutiliza el patron ya probado de TestDataFactory.createProduct (el mismo que usa
        // createQuoteWithItems() para productos de "Mano de Obra"), y solo ajusta Empresa__c,
        // IsActive y RM_VN_EsActivo__c, sin tocar la resolucion de Categor_a_veh_culo__c/RecordTypeId.
        Product2 prod = TestDataFactory.createProduct(
            name, name, null, null, 'BMW', null, null, '2023', 'Rojo', 'Negro', 'Mano de Obra', false, false
        );
        prod.Empresa__c = empresaCode;
        prod.IsActive = isActive;
        prod.RM_VN_EsActivo__c = true;
        return prod;
    }

    private static Id getBloque18CampaignId() {
        List<Campaign> camps = [SELECT Id FROM Campaign WHERE Name = 'Campaign Bloque18' LIMIT 1];
        System.assert(!camps.isEmpty(), 'No se encontro la Campaign Bloque18');
        return camps[0].Id;
    }

    // Se identifica por Campana__c (unica para este bloque) + RT_Lead__c en vez de por Name,
    // porque el Name de Opportunity puede ser recalculado por automatizaciones del org.
    private static Id getOpportunityIdByRecordType(String recordTypeDeveloperName) {
        Id campaignId = getBloque18CampaignId();
        List<Opportunity> opps = [SELECT Id, Name FROM Opportunity WHERE Campana__c = :campaignId AND RT_Lead__c = :recordTypeDeveloperName LIMIT 1];
        Integer totalUnderCampaign = [SELECT COUNT() FROM Opportunity WHERE Campana__c = :campaignId];
        System.assert(!opps.isEmpty(), 'No se encontro Opportunity para RT_Lead__c=' + recordTypeDeveloperName + '. Total de Opportunities bajo la Campaign Bloque18: ' + totalUnderCampaign);
        return opps[0].Id;
    }

    private static Id getQuoteIdByRecordType(String recordTypeDeveloperName) {
        Id oppId = getOpportunityIdByRecordType(recordTypeDeveloperName);
        List<Quote> quotes = [SELECT Id FROM Quote WHERE OpportunityId = :oppId LIMIT 1];
        System.assert(!quotes.isEmpty(), 'No se encontro Quote para la Opportunity de RT_Lead__c=' + recordTypeDeveloperName);
        return quotes[0].Id;
    }

    private static Set<String> extractProductNames(Map<String,Object> responseMap) {
        Set<String> names = new Set<String>();
        if (responseMap.containsKey('products')) {
            for (Product2 p : (List<Product2>) responseMap.get('products')) {
                names.add(p.Name);
            }
        }
        return names;
    }

    private static void assertOnlyExpectedProduct(String scenarioLabel, Id recordId, String expectedProductName, Id standardPricebookId) {
        Test.startTest();
        // 'MO' es substring comun a todos los productos de prueba (Bloque18-MO-*),
        // asi que ejercita los filtros opcionales de productName/vin sin excluir al esperado.
        Map<String,Object> responseMap = ProductSearcherController.getProducts('mano obra', 'MO', null, null, '2023', 'MO', 'BMW', null, null, null, 'Test', recordId, null, 1);
        Test.stopTest();

        System.assert(!responseMap.containsKey('message'), 'No debe haber error para ' + scenarioLabel + ': ' + responseMap.get('message'));

        Set<String> names = extractProductNames(responseMap);
        System.assert(names.contains(expectedProductName), scenarioLabel + ' debe incluir ' + expectedProductName);
        System.assert(!names.contains(PROD_BAVARIAN_INACTIVE), scenarioLabel + ' no debe incluir producto inactivo');

        for (String other : new List<String>{PROD_BAVARIAN, PROD_OTOBAI, PROD_PEKING}) {
            if (other != expectedProductName) {
                System.assert(!names.contains(other), scenarioLabel + ' no debe incluir producto de otra empresa: ' + other);
            }
        }

        System.assert(responseMap.containsKey('prices'), 'Debe incluir prices para ' + scenarioLabel);
        Object pricesObj = responseMap.get('prices');
        System.assert(pricesObj instanceof List<PricebookEntry>, 'prices debe ser una lista de PricebookEntry para ' + scenarioLabel);
        List<PricebookEntry> prices = (List<PricebookEntry>) pricesObj;
        System.assert(!prices.isEmpty(), 'Debe existir al menos un precio para ' + scenarioLabel);

        // La consulta productiva no trae Pricebook2Id en el SELECT, asi que se verifica de forma
        // indirecta: el PricebookEntry devuelto debe ser uno de los que realmente pertenecen al
        // Pricebook efectivo de la Quote (el Pricebook estandar) para el producto esperado.
        Set<Id> expectedPbeIds = new Set<Id>();
        for (PricebookEntry expected : [SELECT Id FROM PricebookEntry WHERE Pricebook2Id = :standardPricebookId AND Product2.Name = :expectedProductName]) {
            expectedPbeIds.add(expected.Id);
        }
        System.assert(!expectedPbeIds.isEmpty(), 'No se encontro PricebookEntry esperado para ' + expectedProductName + ' en el Pricebook estandar');
        for (PricebookEntry pbe : prices) {
            System.assert(expectedPbeIds.contains(pbe.Id), scenarioLabel + ' el precio devuelto debe pertenecer al Pricebook efectivo de la Quote');
        }
    }

    @IsTest
    static void testManoObra_BMW_ReturnsOnlyBavarian(){
        Id standardPricebookId = Test.getStandardPricebookId();
        Id quoteId = getQuoteIdByRecordType('BMW');
        assertOnlyExpectedProduct('BMW (via Quote)', quoteId, PROD_BAVARIAN, standardPricebookId);
    }

    @IsTest
    static void testManoObra_MINI_ReturnsOnlyBavarian(){
        Id standardPricebookId = Test.getStandardPricebookId();
        Id quoteId = getQuoteIdByRecordType('MINI');
        assertOnlyExpectedProduct('MINI (via Quote)', quoteId, PROD_BAVARIAN, standardPricebookId);
    }

    @IsTest
    static void testManoObra_Polaris_ReturnsOnlyOtobai(){
        Id standardPricebookId = Test.getStandardPricebookId();
        Id quoteId = getQuoteIdByRecordType('Polaris');
        assertOnlyExpectedProduct('Polaris (via Quote)', quoteId, PROD_OTOBAI, standardPricebookId);
    }

    @IsTest
    static void testManoObra_Kawasaki_ReturnsOnlyOtobai(){
        Id standardPricebookId = Test.getStandardPricebookId();
        Id quoteId = getQuoteIdByRecordType('Kawasaki');
        assertOnlyExpectedProduct('Kawasaki (via Quote)', quoteId, PROD_OTOBAI, standardPricebookId);
    }

    @IsTest
    static void testManoObra_Omoda_ReturnsOnlyPeking(){
        Id standardPricebookId = Test.getStandardPricebookId();
        Id quoteId = getQuoteIdByRecordType('Omoda');
        assertOnlyExpectedProduct('Omoda (via Quote)', quoteId, PROD_PEKING, standardPricebookId);
    }

    @IsTest
    static void testManoObra_Jaecoo_ReturnsOnlyPeking(){
        Id standardPricebookId = Test.getStandardPricebookId();
        Id quoteId = getQuoteIdByRecordType('Jaecoo');
        assertOnlyExpectedProduct('Jaecoo (via Quote)', quoteId, PROD_PEKING, standardPricebookId);
    }

    @IsTest
    static void testManoObra_UnknownRecordType_ReturnsEmptyResult_ViaOpportunity(){
        Id oppId = getOpportunityIdByRecordType('Unmapped');

        Test.startTest();
        Map<String,Object> responseMap = ProductSearcherController.getProducts('mano obra', null, null, null, '2023', null, 'BMW', null, null, null, 'Test', oppId, null, 1);
        Test.stopTest();

        System.assert(!responseMap.containsKey('message'), 'No debe generar error para Record Type no reconocido');
        System.assert(!responseMap.containsKey('products'), 'No debe devolver productos para Record Type no reconocido (sin seleccion por descarte)');
    }

    @IsTest
    static void testManoObra_NoMatchingProductName_ReturnsEmptyProductsList(){
        Id quoteId = getQuoteIdByRecordType('BMW');

        Test.startTest();
        Map<String,Object> responseMap = ProductSearcherController.getProducts('mano obra', 'NombreQueNoExiste', null, null, '2023', null, 'BMW', null, null, null, 'Test', quoteId, null, 1);
        Test.stopTest();

        System.assert(!responseMap.containsKey('message'), 'No debe haber error cuando el filtro de nombre no encuentra productos');
        Set<String> names = extractProductNames(responseMap);
        System.assert(names.isEmpty(), 'No debe devolver productos cuando el filtro de nombre no coincide con ninguno');
    }

    @IsTest
    static void testGetProducts_ValidationMessages(){
        Test.startTest();
        Map<String,Object> blankBrand = ProductSearcherController.getProducts('mano obra', null, null, null, '2023', null, null, null, null, null, 'Test', null, null, 1);
        Map<String,Object> blankYear = ProductSearcherController.getProducts('mano obra', null, null, null, null, null, 'BMW', null, null, null, 'Test', null, null, 1);
        Map<String,Object> blankModel = ProductSearcherController.getProducts('mano obra', null, null, null, '2023', null, 'BMW', null, null, null, null, null, null, 1);
        Test.stopTest();

        System.assertEquals('La marca es requerida.', blankBrand.get('message'), 'Debe pedir marca cuando esta en blanco');
        System.assertEquals('El año es requerido.', blankYear.get('message'), 'Debe pedir año cuando esta en blanco');
        System.assertEquals('El modelo es requerido.', blankModel.get('message'), 'Debe pedir modelo cuando esta en blanco para tipos distintos de vehiculo');
    }

    @IsTest
    static void testGetProducts_ManoObra_RequiresRecordId(){
        Test.startTest();
        Map<String,Object> blankRecordId = ProductSearcherController.getProducts('mano obra', null, null, null, '2023', null, 'BMW', null, null, null, 'Test', null, null, 1);
        Test.stopTest();

        System.assertEquals('El id es requerido.', blankRecordId.get('message'), 'Debe pedir el id cuando es mano de obra y recordId esta en blanco');
    }

    @IsTest
    static void testGetWorkSteps(){
        Test.startTest();

        List<Product2> productList = [SELECT Id,Name,Anno__c,vin__c,Color__c,ProductCode,modelo__c,Marca__c,Familia__c FROM Product2];
        List<Quote> quoteList = [SELECT Id FROM Quote LIMIT 1];

        List<ProductoXBodega__c> prodXBodList = [SELECT Id,Name,Producto__c,Bodega__c FROM ProductoXBodega__c];
        ProductSearcherController.getProducts(null, null, null, null, null, null, null, null, null, null, null, null,null,1);
        Map<String,Object> responseMap = new Map<String,Object>();
        // Variantes del filtro vehiculoTransito/recordId (rama vehiculo ya existente, sin modificarla)
        responseMap = ProductSearcherController.getProducts('vehiculo', null, null, 'bodegaTest', '2023', 'vinTest', 'BMW', null, null,null, 'MW-X1-SDRIVE18D-XLINE',quoteList[0].Id,'Si', 1);
        responseMap = ProductSearcherController.getProducts('vehiculo', null, null, null, '2023', null, 'BMW', null, null,null, 'MW-X1-SDRIVE18D-XLINE',null,'No', 1);
        responseMap = ProductSearcherController.getProducts('vehiculo', null, null, null, '2023', null, 'BMW', null, null,null, 'MW-X1-SDRIVE18D-XLINE',null,null, 1);
        responseMap = ProductSearcherController.getProducts('extra', 'nombreTest', null, null, '2023', 'vinTest', 'BMW', null, null,null, 'MW-X1-SDRIVE18D-XLINE',null,null, 1);
        responseMap = ProductSearcherController.getProducts('mano obra', null, null, null, null, null, 'BMW', null, null,null, 'MW-X1-SDRIVE18D-XLINE',quoteList[0].Id,null, 1);
        Test.stopTest();
    }

    @IsTest
    static void test_GetProductDataFromOLI(){
        Id oppId = getOpportunityIdByRecordType('BMW');
        Oportunidad_Producto_Interes__c oppProdInt = TestDataFactory.createOportunidadProductoInteres('BMW','ABC MODEL','X1','2023',new Opportunity(Id = oppId),true);
        Map<String,Object> responseMap = ProductSearcherController.getProductDataFromOLI(oppProdInt.Id);
    }

    @IsTest
    static void test_GetOpportunityByQuote(){
        List<Quote> quoteList = [SELECT Id FROM Quote LIMIT 1];
        if (quoteList.size() > 0) {
            Map<String,Object> responseMap = ProductSearcherController.getProductByQuoteId(quoteList[0].Id);
        }
    }

    // ==========================================================================================
    // Laboratorio de cobertura (Bloque 18, analysis/pc/redmotors-block18-coverage-lab-20260726)
    // ==========================================================================================
    // La rama 'vehiculo' de getProducts() nunca completa su recorrido con los fixtures existentes:
    // getPricesGroupByModelFantasia(brand,year) no encuentra ningun Pricebook2 cuyo Name contenga
    // a la vez la marca y el anio (solo existe el Pricebook estandar en este TestSetup), por lo que
    // getProducts() lanza la AuraHandledException de "No se encontraron precios de fantasia..."
    // antes de construir el resto de la busqueda. Este fixture agrega, unicamente para esta prueba:
    // - dos Producto2 "modelo de interes" (Marca__c/Modelo_De_Inter_s__c) con su Pricebook2/
    //   PricebookEntry de fantasia (mismo modelo, distinto precio, para ejercitar tambien la
    //   comparacion de "precio mas alto" de getPricesGroupByModelFantasia);
    // - la Configuracion_de_ventas__c y el Pricebook2/PricebookEntry "Softland" que
    //   RM_VN_Service.getSoftlandPriceBookId/gePBEBavarian necesitan para resolver el vehiculo
    //   real ya insertado por TestDataFactory.createQuoteWithItems() en el @TestSetup de esta clase;
    // - el Pricebook2 "<marca> - <anio>" (nombre exacto que getProducts() arma para el precio final).
    // No se modifica metadata, Record Types, picklists ni codigo productivo: todo se construye
    // reutilizando helpers ya existentes de TestDataFactory y el vehiculo/Bodega ya creados en el
    // @TestSetup. Cobertura teorica: no confirmada por Tooling API, pendiente de dry-run real.
    private static Product2 getSetupVehicle() {
        return [
            SELECT Id, Name, ProductCode, modelo__c, marcaVehiculo__c, Anno__c, Color__c, Color_Externo__c, vin__c
            FROM Product2
            WHERE Name = 'BM166 - X1 sDrive18d'
            LIMIT 1
        ];
    }

    @IsTest
    static void testGetProducts_Vehiculo_BMW_FullSearchReturnsExpectedVehicle(){
        Product2 vehiculo = getSetupVehicle();
        String brand = vehiculo.marcaVehiculo__c;
        String year = vehiculo.Anno__c;
        String modelo = vehiculo.modelo__c;

        // Dos productos de "modelo de interes" con el MISMO modelo, para que
        // getPricesGroupByModelFantasia() agrupe por modelKey y compare precios.
        Product2 fantasiaA = TestDataFactory.createProduct(
            'CoverageLab Fantasia A ' + modelo, modelo, null, null, brand, null, modelo, year, 'Rojo', 'Negro', 'Vehiculo', false, true
        );
        Product2 fantasiaB = TestDataFactory.createProduct(
            'CoverageLab Fantasia B ' + modelo, modelo, null, null, brand, null, modelo, year, 'Rojo', 'Negro', 'Vehiculo', false, true
        );
        Pricebook2 fantasiaPB = TestDataFactory.createPriceBook(brand + '-' + year + ' CoverageLab Fantasia', true);
        TestDataFactory.createPriceBookEntry(fantasiaPB, fantasiaA, 15000, true);
        TestDataFactory.createPriceBookEntry(fantasiaPB, fantasiaB, 9000, true);

        // Pricebook "Softland" + Configuracion_de_ventas__c que resuelven el vehiculo real
        // via RM_VN_Service.getSoftlandPriceBookId/gePBEBavarian.
        Pricebook2 softlandPB = TestDataFactory.createPriceBook('Softland ' + brand + ' CoverageLab', true);
        softlandPB.CurrencyIsoCode = 'USD';
        update softlandPB;
        TestDataFactory.createConfiVentas('ConfVentas CoverageLab ' + brand, brand + '-' + year, brand, softlandPB, true);
        TestDataFactory.createPriceBookEntry(softlandPB, vehiculo, 42000, true);

        // Pricebook "<marca> - <anio>" (nombre exacto que getProducts() usa para el precio final).
        Pricebook2 finalPricePB = TestDataFactory.createPriceBook(brand + ' - ' + year, true);
        TestDataFactory.createPriceBookEntry(finalPricePB, vehiculo, 45000, true);

        Test.startTest();
        Map<String,Object> responseMap = ProductSearcherController.getProducts(
            'vehiculo',
            vehiculo.Name.left(5),
            vehiculo.ProductCode.left(5),
            null,
            year,
            vehiculo.vin__c,
            brand,
            null,
            vehiculo.Color__c,
            vehiculo.Color_Externo__c,
            modelo,
            null,
            null,
            1
        );
        Test.stopTest();

        System.assert(!responseMap.containsKey('message'), 'No debe haber error en la busqueda de vehiculo completa: ' + responseMap.get('message'));
        System.assertEquals(1, responseMap.get('totalRecords'), 'Debe encontrar exactamente el vehiculo de prueba.');

        System.assert(responseMap.containsKey('products'), 'Debe incluir products.');
        List<ProductoXBodega__c> products = (List<ProductoXBodega__c>) responseMap.get('products');
        System.assertEquals(1, products.size(), 'Debe devolver un solo registro ProductoXBodega.');
        System.assertEquals(vehiculo.Id, products[0].Producto__c, 'Debe ser el vehiculo del TestSetup.');

        System.assert(responseMap.containsKey('preciosFantasia'), 'Debe incluir preciosFantasia.');
        List<PricebookEntry> preciosFantasia = (List<PricebookEntry>) responseMap.get('preciosFantasia');
        System.assertEquals(1, preciosFantasia.size(), 'Debe agrupar un solo precio de fantasia por modelo.');
        System.assertEquals(15000, preciosFantasia[0].UnitPrice, 'Debe conservar el precio de fantasia mas alto del modelo.');

        System.assert(responseMap.containsKey('preciosBavarian'), 'Debe incluir preciosBavarian.');
        List<PricebookEntry> preciosBavarian = (List<PricebookEntry>) responseMap.get('preciosBavarian');
        System.assertEquals(1, preciosBavarian.size(), 'Debe traer un precio Softland para el vehiculo.');
        System.assertEquals(vehiculo.Id, preciosBavarian[0].Product2Id, 'El precio Softland debe pertenecer al vehiculo.');

        System.assert(responseMap.containsKey('prices'), 'Debe incluir prices.');
        Object pricesObj = responseMap.get('prices');
        System.assert(pricesObj instanceof List<PricebookEntry>, 'prices debe ser una lista de PricebookEntry.');
        List<PricebookEntry> prices = (List<PricebookEntry>) pricesObj;
        System.assertEquals(1, prices.size(), 'Debe existir un precio final para el vehiculo.');
        System.assertEquals(vehiculo.Id, prices[0].Product2Id, 'El precio final debe pertenecer al vehiculo buscado.');
        System.assertEquals(45000, prices[0].UnitPrice, 'Debe ser el precio del Pricebook "<marca> - <anio>".');
    }
}
