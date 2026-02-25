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
        List<Product2> products = new List<Product2>();
        
        for (Integer i = 0; i < 2; i++) {
            Product2 product = new Product2(
                Name = 'Test Product ' + i,
                Codigo_de_Producto__c = '456' // Use the correct external ID field for the Product2 object
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
}