@IsTest
public with sharing class RM_VU_Inventario_Ctrl_Test {

    @TestSetup
    static void makeData(){
        RM_VU_TestDataFactory.prepareRecords();
    }

    @IsTest
    static void TestGetRecords(){
        RM_Config__mdt cfgMdtDPLVU = RM_Config__mdt.getInstance('Default_Price_List_VU');
        RM_Config__mdt cfgMdtDPLVUCC = RM_Config__mdt.getInstance('Default_Price_List_VU_Currency_Code');

        String currencyCode, brand, year, model, productCode, bodegaId, vin, internalColor, externalColor, tipoCombustible, placa;        
        Integer pageNumber = 1;

        Id priceBookId = [SELECT Id FROM Pricebook2 WHERE Name = :cfgMdtDPLVU.Value__c AND IsActive = TRUE].Id;

        List<Product2> productList = [SELECT Id,Anno__c,marcaVehiculo__c,modelo__c,ProductCode,combustible__c,Color__c,Color_Externo__c,vin__c,Codigo_de_Producto__c FROM Product2 WHERE IsActive = TRUE AND es_Vehiculo_usado__c = true];
        System.debug(productList);
        Map<String,Object> responseMap = RM_VU_Inventario_Ctrl.getRecords('Autos_Usados',productList[0].marcaVehiculo__c, productList[0].Anno__c, productList[0].modelo__c,productList[0].ProductCode, placa , internalColor, externalColor , tipoCombustible,  pageNumber,false,priceBookId);

        Map<String,Object> responseMap2 = RM_VU_Inventario_Ctrl.getRecords('','', '', '','', '' , '', '' , '',  1,false ,priceBookId);

		List<Pricebook2> pbList = RM_VU_Inventario_Ctrl.getPriceBooks();

        Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        Opportunity opp= RM_VU_Inventario_Ctrl.getOpportunity(oppId);
    }

    @IsTest
    static void testGetRecords_SinPriceBookId_RetornaVacio(){
        Map<String,Object> responseMap = RM_VU_Inventario_Ctrl.getRecords('','', '', '','', '' , '', '' , '',  1,false, null);
        System.assertEquals(0, responseMap.size(), 'Sin priceBookId no debe consultar registros ni lanzar error.');
    }

    @IsTest
    static void TestGetTipoGasolina(){
        List<RM_SelectOption_Wrapper> options = RM_VU_Inventario_Ctrl.getTipoGasolina();
    }


    @IsTest
    static void testGetUsadoRecordTypeOptions() {
        // Call the method
        List<Map<String, String>> options = RM_VU_Inventario_Ctrl.getUsadoRecordTypeOptions();

        // Assert that the returned list is not empty
        System.assertNotEquals(0, options.size(), 'No options returned');
    }

    private static Empresa__c createEmpresaActiva(String codigo) {
        Empresa__c empresa = new Empresa__c(Name = codigo, Codigo__c = codigo, Activa__c = true);
        insert empresa;
        return empresa;
    }

    private static Campaign createCampanna() {
        String rtId = TestDataFactory.getRecordTypeId('Campaign', 'Campana_Red_Motors');
        return TestDataFactory.createCampanna('RM VU Test Campaign', rtId, true);
    }

    @IsTest
    static void testGetPricebookOptions_SinOportunidad_RetornaError() {
        Map<String, Object> response = RM_VU_Inventario_Ctrl.getPricebookOptions(null);
        System.assertEquals(EmpresaPricebookResolver.STATUS_ERROR, response.get('status'));
    }

    @IsTest
    static void testGetPricebookOptions_SinEmpresaEnOportunidad_RetornaNoConfigurado() {
        Account acc = TestDataFactory.createAccount('Cuenta Sin Empresa', true);
        Campaign campanna = createCampanna();
        Opportunity opp = TestDataFactory.createOpportunity(acc, 'Oportunidad Sin Empresa', campanna, null, true);

        Map<String, Object> response = RM_VU_Inventario_Ctrl.getPricebookOptions(opp.Id);
        System.assertEquals(EmpresaPricebookResolver.STATUS_NO_CONFIGURADO, response.get('status'));
        System.assertEquals(null, response.get('selectedPricebookId'));
    }

    @IsTest
    static void testGetPricebookOptions_UnaOpcionValida_SeleccionaAutomaticamente() {
        Empresa__c empresa = createEmpresaActiva('RM_VU_EMPRESA_UNA_OPCION');
        Pricebook2 pb = new Pricebook2(Name = 'RM VU Empresa Local', Empresa__c = empresa.Id, CurrencyIsoCode = 'CRC', IsActive = true);
        insert pb;

        Account acc = TestDataFactory.createAccount('Cuenta Una Opcion', true);
        Campaign campanna = createCampanna();
        Opportunity opp = TestDataFactory.createOpportunity(acc, 'Oportunidad Una Opcion', campanna, null, false);
        opp.Empresa_Operadora__c = empresa.Id;
        insert opp;

        Map<String, Object> response = RM_VU_Inventario_Ctrl.getPricebookOptions(opp.Id);
        System.assertEquals(EmpresaPricebookResolver.STATUS_EXITO, response.get('status'));
        System.assertEquals(pb.Id, response.get('selectedPricebookId'));
        List<Object> options = (List<Object>) response.get('options');
        System.assertEquals(1, options.size());
    }

    @IsTest
    static void testGetPricebookOptions_PricebookActualDeOtraEmpresa_NoSeConserva() {
        Empresa__c empresaA = createEmpresaActiva('RM_VU_EMPRESA_A');
        Empresa__c empresaB = createEmpresaActiva('RM_VU_EMPRESA_B');
        Pricebook2 pbB = new Pricebook2(Name = 'RM VU Empresa B Local', Empresa__c = empresaB.Id, CurrencyIsoCode = 'CRC', IsActive = true);
        insert pbB;
        Pricebook2 pbA = new Pricebook2(Name = 'RM VU Empresa A Local', Empresa__c = empresaA.Id, CurrencyIsoCode = 'CRC', IsActive = true);
        insert pbA;

        Account acc = TestDataFactory.createAccount('Cuenta Incompatible', true);
        Campaign campanna = createCampanna();
        Opportunity opp = TestDataFactory.createOpportunity(acc, 'Oportunidad Incompatible', campanna, null, false);
        opp.Empresa_Operadora__c = empresaA.Id;
        opp.Pricebook2Id = pbB.Id;
        insert opp;

        Map<String, Object> response = RM_VU_Inventario_Ctrl.getPricebookOptions(opp.Id);
        System.assertEquals(EmpresaPricebookResolver.STATUS_EXITO, response.get('status'));
        System.assertEquals(pbA.Id, response.get('selectedPricebookId'), 'No debe conservar el Pricebook de otra Empresa.');
    }

}