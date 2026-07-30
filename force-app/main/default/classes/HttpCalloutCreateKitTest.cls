@isTest
public class HttpCalloutCreateKitTest {
    @testSetup
    static void setupTestData() {
        Impuesto__c Impuesto = new Impuesto__c(codigoImpuesto__c='0108',descripcion__c='test desc',Impuesto__c=2, Name='test imp', porcentaje__c=3);
        insert Impuesto;
        
        condicionPago__c condicionPago = new condicionPago__c(condicionPago__c='0',Descripcion__c='test desc', Name='0');
        insert condicionPago;
        
        Account acc = new Account(Name='Test account', Cedula__c='9876543210', Tipo_de_Documento__c='02', condicionPago__c=condicionPago.Id, Impuesto__c=Impuesto.Id);
       	insert acc;
        
       	Contact co = new Contact(Firstname='Juan Diego',LastName='Espinoza S1', Email='jesp@abc.com', AccountId=acc.Id);
       	insert co;
        
        Pricebook2 pb = new Pricebook2(Name='Dolar2', IsActive=true);
        insert pb;
        
        Id pricebookId = pb.Id;
        
        
        // Create test data for Opportunity
        RecordType opportunityRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'BMW' LIMIT 1];
        List<Opportunity> opportunities = new List<Opportunity>();
        
        for (Integer i = 0; i < 2; i++) {
            Opportunity opp = new Opportunity(
                Name = 'Test Opportunity ' + i,
                StageName = 'Closed Won',
                CloseDate = Date.today(),
                RecordTypeId = opportunityRecordType.Id,
                Pricebook2Id = pricebookId
            );
            opportunities.add(opp);
        }
        
        insert opportunities;
        
        // Create test data for Product2
        // Codigo_de_Producto__c es External ID y ProductDuplicateCodeValidator (ProductTriggerHandler)
        // rechaza duplicados entre productos clasificados como vehiculo (RecordType Vehiculos o los
        // checkbox esVehiculo__c/es_Vehiculo_en_transito__c/es_Vehiculo_usado__c). Se genera un codigo
        // unico por producto con prefijo de prueba + el indice del loop (unicos entre si dentro del
        // mismo @TestSetup, que es donde ocurria la colision).
        String testProductCodePrefix = 'TESTCK-';
        List<Product2> products = new List<Product2>();

        for (Integer i = 0; i < 2; i++) {
            Product2 product = new Product2(
                Name = 'Test Product ' + i,
                Codigo_de_Producto__c = testProductCodePrefix + String.valueOf(i)
            );
            products.add(product);
        }
        insert products;
          //
        //insert standardPBE;
        List<PricebookEntry> pbes = new List<PricebookEntry> ();
        for(Product2 prod:products){
            PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id =pricebookId, Product2Id = prod.Id, UnitPrice = 2000, IsActive = true);
            pbes.add(standardPBE);
        }
        insert pbes;
        // Create OpportunityLineItem records
        List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
        
        for (Opportunity opp : opportunities) {
            for (Product2 product : products) {
                OpportunityLineItem oli = new OpportunityLineItem(
                    OpportunityId = opp.Id,
                    Product2Id = product.Id, // Use the ID of the created Product2 record
                    Quantity = 2,
                    UnitPrice = 10.0
                );
                opportunityLineItems.add(oli);
            }
        }
        
        insert opportunityLineItems;
    }

    @isTest
    static void testCreateKit() {
        // Create a test HttpCalloutCreateKit object
        HttpCalloutCreateKit kit = new HttpCalloutCreateKit('123', 'Test Kit', 'Type', 'RMBAVARIAN', 10.0, 'USD');
        kit.addComponent('456', 2);
        
        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Call the createKit() method
        Test.startTest();
        HttpResponse res = kit.createKit();
        Test.stopTest();
        
        // Perform assertions on the response
        System.assertEquals(200, res.getStatusCode());
        // Add more assertions as needed
    }
    
    @isTest
    static void testSendCreateKitRequest() {
        // Call the sendCreateKitRequest method
        Test.startTest();
        List<Opportunity> opps = [select id from Opportunity];
        List<Id> oppIds = new List<Id>();
        for(Opportunity oppId:opps){
            oppIds.add(oppId.Id);
        }
        HttpCalloutCreateKit.sendCreateKitRequest(oppIds);
        Test.stopTest();
        
        // Add assertions as needed
    }
    
    @isTest
    static void testSendCreateKitRequestFlow() {
        // Call the sendCreateKitRequestFlow method
        Test.startTest();
        HttpCalloutCreateKit.sendCreateKitRequestFlow(new List<Id>{});
        Test.stopTest();
        
        // Add assertions as needed
    }
    
    // Mock HTTP response generator class
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            // Set the response body and other necessary fields
            res.setBody('{ "operationResult": { "code": "00", "description": "El artículo se actualizó exitosamente." } }');
            return res;
        }
    }

    // ====== Cobertura Empresa/RMPEKING (Omoda/Jaecoo) para sendCreateKitRequest ======

    @isTest
    static void omodaOpportunityUsesRMPekingAndTipoV() {
        Map<String, Object> request = runSendCreateKitAndCapture('Omoda', null, 'CK-OMODA');
        System.assertEquals('RMPEKING', request.get('compania'));
        System.assertEquals('V', request.get('tipo'));
    }

    @isTest
    static void jaecooOpportunityUsesRMPekingAndTipoV() {
        Map<String, Object> request = runSendCreateKitAndCapture('Jaecoo', null, 'CK-JAECOO');
        System.assertEquals('RMPEKING', request.get('compania'));
        System.assertEquals('V', request.get('tipo'));
    }

    @isTest
    static void bavarianOpportunityKeepsRMBavarianAndTipoV() {
        Map<String, Object> request = runSendCreateKitAndCapture('BMW', null, 'CK-BAV');
        System.assertEquals('RMBAVARIAN', request.get('compania'));
        System.assertEquals('V', request.get('tipo'));
    }

    @isTest
    static void otobaiBucketOpportunityKeepsRMOtobaiAndTipoM() {
        // No existe RecordType 'Otobai'; las marcas de motos no-Bavarian (p. ej. Kawasaki)
        // son las que hoy caen en el bucket RMOTOBAI/M, y ese comportamiento se preserva.
        Map<String, Object> request = runSendCreateKitAndCapture('Kawasaki', null, 'CK-OTO');
        System.assertEquals('RMOTOBAI', request.get('compania'));
        System.assertEquals('M', request.get('tipo'));
    }

    @isTest
    static void empresaLookupTakesPriorityOverRecordTypeFallback() {
        Empresa__c empresa = new Empresa__c(
            Name = 'Empresa CK-PRIORITY',
            Codigo__c = 'RMPEKING',
            Codigo_ERP__c = 'RMPEKING',
            Nombre_Legal__c = 'Empresa CK-PRIORITY',
            Activa__c = true
        );
        insert empresa;

        // RecordType BMW normalmente mapearía a RMBAVARIAN por el fallback; el lookup debe ganar.
        Map<String, Object> request = runSendCreateKitAndCapture('BMW', empresa.Id, 'CK-PRIORITY');
        System.assertEquals('RMPEKING', request.get('compania'));
    }

    @isTest
    static void unknownRecordTypeDoesNotFallbackToOtobai() {
        // Record Type real pero no de marca (no Bavarian/PEKING/Otobai) y sin Empresa_Operadora__c:
        // no debe resolver compania silenciosamente a RMOTOBAI, debe fallar de forma controlada.
        // No se inserta ningun Opportunity (sin DML) y no dispara callouts: prueba el resolver
        // puro vía @TestVisible. Solo se consulta (SOQL de lectura) el RecordType real 'Mostrador'.
        RecordType mostrador = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = 'Mostrador' LIMIT 1];
        Opportunity opp = new Opportunity();
        opp.RecordType = mostrador;

        Boolean controlledExceptionThrown = false;
        try {
            HttpCalloutCreateKit.resolveCompania(opp);
        } catch (EmpresaConfigurationException e) {
            controlledExceptionThrown = true;
        }

        System.assert(
            controlledExceptionThrown,
            'Un Record Type sin empresa identificada no debe resolver silenciosamente a RMOTOBAI.'
        );
    }

    @isTest
    static void requestDoesNotContainBodegaNorSucursal() {
        Map<String, Object> request = runSendCreateKitAndCapture('Omoda', null, 'CK-NOFIELDS');
        System.assert(!request.containsKey('bodega'), 'El request no debe incluir bodega.');
        System.assert(!request.containsKey('sucursal'), 'El request no debe incluir sucursal.');
    }

    @isTest
    static void endpointAndAuthRemainIntact() {
        CaptureCalloutMock mock = new CaptureCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);

        Id oppId = createBrandOpportunity('Omoda', null, 'CK-ENDPOINT');
        Test.startTest();
        HttpCalloutCreateKit.sendCreateKitRequest(new List<Id>{ oppId });
        Test.stopTest();

        System.assertEquals(1, mock.capturedEndpoints.size());
        System.assert(
            mock.capturedEndpoints[0].contains('/softlandAPI/products/addKit?json='),
            'El endpoint de creación de KIT no debe cambiar.'
        );
    }

    private static Map<String, Object> runSendCreateKitAndCapture(String recordTypeDeveloperName, Id empresaOperadoraId, String uniqueSuffix) {
        CaptureCalloutMock mock = new CaptureCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);

        Id oppId = createBrandOpportunity(recordTypeDeveloperName, empresaOperadoraId, uniqueSuffix);

        Test.startTest();
        HttpCalloutCreateKit.sendCreateKitRequest(new List<Id>{ oppId });
        Test.stopTest();

        System.assertEquals(1, mock.capturedEndpoints.size(), 'Se esperaba exactamente un callout de creación de KIT.');
        String endpoint = mock.capturedEndpoints[0];
        Integer jsonIndex = endpoint.indexOf('json=');
        String encodedJson = endpoint.substring(jsonIndex + 'json='.length());
        String decodedJson = EncodingUtil.urlDecode(encodedJson, 'UTF-8');
        return (Map<String, Object>) JSON.deserializeUntyped(decodedJson);
    }

    private static Id createBrandOpportunity(String recordTypeDeveloperName, Id empresaOperadoraId, String uniqueSuffix) {
        Id opportunityRecordTypeId = [
            SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = :recordTypeDeveloperName LIMIT 1
        ].Id;
        Id vehiculoProductRecordTypeId = [
            SELECT Id FROM RecordType WHERE SObjectType = 'Product2' AND DeveloperName = 'Vehiculos' LIMIT 1
        ].Id;

        Pricebook2 pricebook = new Pricebook2(Name = 'CK Pricebook ' + uniqueSuffix, IsActive = true);
        insert pricebook;

        Product2 vehiculo = new Product2(
            Name = 'CK Vehiculo ' + uniqueSuffix,
            RecordTypeId = vehiculoProductRecordTypeId,
            esVehiculo__c = true,
            // OpportunityLineItemTriggerHandler.updateOpportunityProductName dereferencia
            // product2.modelo__c.toLowerCase() para todo producto con esVehiculo__c = true (mismo
            // patrón usado en TestDataFactory.createProducts y otros tests del repositorio que
            // insertan productos vehículo). Sin este campo el trigger produce NullPointerException.
            modelo__c = 'CK Modelo ' + uniqueSuffix,
            Codigo_de_Producto__c = uniqueSuffix,
            IsActive = true
        );
        insert vehiculo;

        // No se inserta aquí el PricebookEntry estándar: ProductTriggerHandler.afterInsert()
        // (ProductDuplicateCodeValidator/insertStandardPricebookEntries, código productivo, sin
        // tocar) ya crea automáticamente entradas activas en el Pricebook estándar (CRC y USD)
        // para todo Product2 recién insertado, incluido este. Insertar otra aquí duplicaba la
        // combinación Pricebook2 (estándar) + Product2 + CurrencyIsoCode y producía DUPLICATE_VALUE.
        // La entrada estándar ya existente es suficiente para poder crear la entrada en el
        // Pricebook custom de abajo (requisito de la plataforma).

        insert new PricebookEntry(
            Pricebook2Id = pricebook.Id,
            Product2Id = vehiculo.Id,
            UnitPrice = 1000,
            IsActive = true
        );

        Opportunity opp = new Opportunity(
            Name = 'CK Opportunity ' + uniqueSuffix,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            RecordTypeId = opportunityRecordTypeId,
            Pricebook2Id = pricebook.Id,
            Empresa_Operadora__c = empresaOperadoraId
        );
        insert opp;

        insert new OpportunityLineItem(
            OpportunityId = opp.Id,
            Product2Id = vehiculo.Id,
            Quantity = 1,
            UnitPrice = 1000
        );

        return opp.Id;
    }

    // Captura únicamente el callout de creación de KIT (ignora el callout de autenticación).
    public class CaptureCalloutMock implements HttpCalloutMock {
        public List<String> capturedEndpoints = new List<String>();

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            String endpoint = req.getEndpoint();
            if (endpoint != null && endpoint.containsIgnoreCase('oauth/token')) {
                res.setBody('{"access_token":"token","token_type":"Bearer"}');
            } else {
                capturedEndpoints.add(endpoint);
                res.setBody('{ "operationResult": { "code": "00", "description": "El artículo se actualizó exitosamente." } }');
            }
            return res;
        }
    }
}