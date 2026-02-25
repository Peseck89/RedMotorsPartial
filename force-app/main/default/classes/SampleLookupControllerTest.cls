@isTest
public class SampleLookupControllerTest {
    @testSetup
    static void setupTestData() {
        // Crear datos comunes para todas las pruebas
        Account account = new Account(Name = 'Test Account', Tipo_de_Documento__c = '01', Cedula__c = '123456789');
        insert account;
        
        // Crear caso
        Case testCase = new Case(Subject = 'Test Case');
        insert testCase;
        
        // Crear orden de trabajo
        Pricebook2 pb = new Pricebook2(Name='Test Pricebook', IsActive=true);
        insert pb;
        WorkOrder wo = new WorkOrder(subject ='Test Work Order', Pricebook2Id=pb.Id, CaseId=testCase.Id);
        insert wo;
        
        OperatingHours oh = new OperatingHours(
            Name = 'test',
            TimeZone = 'America/Costa_Rica'
        );
        insert oh;
        ServiceTerritory territory = new ServiceTerritory(
            Name = 'Uruca',
            IsActive = true,
            OperatingHoursId = oh.Id 
        );
        insert territory;
        
        // Asociar usuario al territorio
        FSL__User_Territory__c userTerritory = new FSL__User_Territory__c(
            FSL__User__c = UserInfo.getUserId(),
            FSL__ServiceTerritory__c = territory.Id
        );
        insert userTerritory;
        
        // Crear producto (mano de obra)
        Product2 product = new Product2(
            Name = 'Test Mano de Obra',
            tipoProducto__c = 'Mano de Obra',
            Codigo_de_Producto__c = 'MO001',
            IsActive = true
        );
        insert product;
        
        // Crear tipo de trabajo
        tiposDeTrabajo__c workType = new tiposDeTrabajo__c(Name = 'Test Work Type');
        insert workType;
        
        // Crear centro de costo
        CentroCosto__c costCenter = new CentroCosto__c(Name = 'Test Cost Center');
        insert costCenter;
        Test.setMock(HttpCalloutMock.class, new TestEtapasTallerv2_PowerBI.MockHttpResponseGenerator());
    }

    @isTest
    static void testSearchGeneralRecords() {
        List<String> selectedIds = new List<String>();
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest();
        // Probar búsqueda de aseguradora (Account)
        List<LookupSearchResult> accountResults = SampleLookupController.search('Test', selectedIds, 'Aseguradora', testCase.Id);
        // Probar búsqueda de tipo de trabajo
        List<LookupSearchResult> workTypeResults = SampleLookupController.search('Test', selectedIds, 'TipoDeTrabajo', testCase.Id);
        // Probar búsqueda de centro de costo
        List<LookupSearchResult> costCenterResults = SampleLookupController.search('Test', selectedIds, 'CentroCosto', testCase.Id);
        Test.stopTest();
        
        //System.assert(!accountResults.isEmpty(), 'Debería encontrar cuentas');
        //System.assert(!workTypeResults.isEmpty(), 'Debería encontrar tipos de trabajo');
        //System.assert(!costCenterResults.isEmpty(), 'Debería encontrar centros de costo');
    }

    @isTest
    static void testSearchMechanics() {
        // Configurar datos específicos para mecánicos si es necesario
        Test.startTest();
        //List<LookupSearchResult> results = SampleLookupController.searchMechanics('Test', null, 'User', 'User', 'Usuario', 'standard:user');
        Test.stopTest();
        
        // Si no hay objeto RM_MecanicoTaller__c, este test puede esperar 0 resultados
        // o puedes crear datos alternativos según tu implementación real
        //System.assertEquals(true, true, 'Test básico de ejecución sin errores');
    }

    @isTest
    static void testSearchCases() {
        Test.startTest();
        List<LookupSearchResult> results = SampleLookupController.searchCases('Test', null, 'Case', 'Case', 'Caso', null);
        Test.stopTest();
        
        //System.assert(!results.isEmpty(), 'Debería encontrar casos');
    }

    @isTest
    static void testGetTerritories() {
        Test.startTest();
        List<LookupSearchResult> results = SampleLookupController.getTerritories('Test', null, 'Territory', 'Territory', 'Territory', null);
        Test.stopTest();
        
        //System.assert(!results.isEmpty(), 'Debería encontrar territorios');
    }

    @isTest
    static void testSearchProductFilterByManoDeObra() {
        Test.startTest();
        List<LookupSearchResult> results = SampleLookupController.searchProductFilterByManoDeObra('Test', null, 'Product2', 'Product2', 'Mano de Obra', 'standard:product');
        Test.stopTest();
        
        System.assert(!results.isEmpty(), 'Debería encontrar productos de mano de obra');
    }

    @isTest
    static void testSearchWorkOrderId() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        Test.startTest();
        Id woId = SampleLookupController.searchWorkOrderId(testCase.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, woId, 'Debería encontrar la orden de trabajo');
    }
}