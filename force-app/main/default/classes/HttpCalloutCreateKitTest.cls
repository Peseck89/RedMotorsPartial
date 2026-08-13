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
        
        
        Empresa__c bavarian = new Empresa__c(
            Name = 'Bavarian',
            Codigo__c = 'RMBAVARIAN',
            Codigo_ERP__c = 'RMBAVARIAN',
            Nombre_Legal__c = 'Bavarian Motors CR S.A.',
            Tipo_Kit_Softland__c = 'V',
            Activa__c = true
        );
        insert bavarian;

        // Create test data for Opportunity
        RecordType opportunityRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'BMW' LIMIT 1];
        List<Opportunity> opportunities = new List<Opportunity>();

        for (Integer i = 0; i < 2; i++) {
            Opportunity opp = new Opportunity(
                Name = 'Test Opportunity ' + i,
                StageName = 'Closed Won',
                CloseDate = Date.today(),
                RecordTypeId = opportunityRecordType.Id,
                Pricebook2Id = pricebookId,
                Empresa_Operadora__c = bavarian.Id
            );
            opportunities.add(opp);
        }

        insert opportunities;
        
        // Create test data for Product2
        List<Product2> products = new List<Product2>();
        
        for (Integer i = 0; i < 2; i++) {
            Product2 product = new Product2(
                Name = 'Test Product ' + i,
                Codigo_de_Producto__c = '456' + i // Distinct codes: a validation rule rejects duplicates
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

    private static Empresa__c buildEmpresa(String name, String codigo, String codigoErp, String tipoKit, Boolean activa) {
        return new Empresa__c(
            Name = name,
            Codigo__c = codigo,
            Codigo_ERP__c = codigoErp,
            Nombre_Legal__c = name + ' Test S.A.',
            Tipo_Kit_Softland__c = tipoKit,
            Activa__c = activa
        );
    }

    @isTest
    static void resolvesBavarianCompanyAndTipoByEmpresa() {
        // @testSetup ya insertó la Empresa Bavarian; se reutiliza en vez de duplicarla.
        Empresa__c bavarian = [SELECT Id, Codigo_ERP__c, Tipo_Kit_Softland__c FROM Empresa__c WHERE Codigo__c = 'RMBAVARIAN' LIMIT 1];
        Opportunity opp = new Opportunity(
            Empresa_Operadora__c = bavarian.Id,
            Empresa_Operadora__r = bavarian
        );

        Test.startTest();
        String erp = HttpCalloutCreateKit.resolveCompanyErpCode(opp);
        String tipo = HttpCalloutCreateKit.resolveTipoKitSoftland(opp);
        Test.stopTest();

        System.assertEquals('RMBAVARIAN', erp);
        System.assertEquals('V', tipo);
    }

    @isTest
    static void resolvesOtobaiCompanyAndTipoByEmpresa() {
        Empresa__c otobai = buildEmpresa('Otobai', 'RMOTOBAI', 'RMOTOBAI', 'M', true);
        insert otobai;
        Opportunity opp = new Opportunity(
            Empresa_Operadora__c = otobai.Id,
            Empresa_Operadora__r = otobai
        );

        Test.startTest();
        String erp = HttpCalloutCreateKit.resolveCompanyErpCode(opp);
        String tipo = HttpCalloutCreateKit.resolveTipoKitSoftland(opp);
        Test.stopTest();

        System.assertEquals('RMOTOBAI', erp);
        System.assertEquals('M', tipo);
    }

    @isTest
    static void resolvesPekingUsingProvisionalBavarianEquivalentTipo() {
        Empresa__c peking = buildEmpresa('PEKING', 'RMPEKING', 'RMPEKING', 'V', true);
        insert peking;
        Opportunity opp = new Opportunity(
            Empresa_Operadora__c = peking.Id,
            Empresa_Operadora__r = peking
        );

        Test.startTest();
        String erp = HttpCalloutCreateKit.resolveCompanyErpCode(opp);
        String tipo = HttpCalloutCreateKit.resolveTipoKitSoftland(opp);
        Test.stopTest();

        System.assertEquals('RMPEKING', erp);
        System.assertEquals('V', tipo);
    }

    @isTest
    static void resolvesFutureCompanyThroughConfigurationWithoutCodeChange() {
        Empresa__c futura = buildEmpresa('Futura', 'RMFUTURA', 'RMFUTURA', 'M', true);
        insert futura;
        Opportunity opp = new Opportunity(
            Empresa_Operadora__c = futura.Id,
            Empresa_Operadora__r = futura
        );

        Test.startTest();
        String erp = HttpCalloutCreateKit.resolveCompanyErpCode(opp);
        String tipo = HttpCalloutCreateKit.resolveTipoKitSoftland(opp);
        Test.stopTest();

        System.assertEquals('RMFUTURA', erp);
        System.assertEquals('M', tipo);
    }

    @isTest
    static void rejectsMissingEmpresaWithControlledErrorNoFallback() {
        Opportunity opp = new Opportunity(Empresa_Operadora__c = null);

        Test.startTest();
        Boolean threwOnCompany = false;
        try {
            HttpCalloutCreateKit.resolveCompanyErpCode(opp);
        } catch (AuraHandledException expected) {
            threwOnCompany = true;
        }

        Boolean threwOnTipo = false;
        try {
            HttpCalloutCreateKit.resolveTipoKitSoftland(opp);
        } catch (AuraHandledException expected) {
            threwOnTipo = true;
        }
        Test.stopTest();

        System.assert(threwOnCompany, 'Debió rechazar una Oportunidad sin Empresa configurada (compañía), no asumir Otobai.');
        System.assert(threwOnTipo, 'Debió rechazar una Oportunidad sin Empresa configurada (tipo), no asumir un default.');
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
}