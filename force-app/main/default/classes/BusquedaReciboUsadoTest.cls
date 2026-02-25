/*
Creado por : K. Rojas - IS
Fecha de creación:01/04/2019
Descripcion: clase test para el controlador controllerCrearOF
*/

@isTest 
private class BusquedaReciboUsadoTest {
    
    static{
        TestDataFactory.datosGenerales();
    }
    
    @isTest
    private static void test1() {
        TestDataFactory.crearCuentas(1);
        TestDataFactory.crearOportunidades(1, 'Oferta');
        TestDataFactory.crearReciboUsado(1);
        
        PageReference page = Page.VFBusquedaReciboUsado;
        Test.setCurrentPage(page);
        ApexPages.currentPage().getParameters().put('Id',TestDataFactory.MapReciboUsados.get(0).id);
        ApexPages.StandardController std = new ApexPages.StandardController(TestDataFactory.MapReciboUsados.get(0));
        controllerBusquedaReciboUsado conRU = new controllerBusquedaReciboUsado(std);
        
        Test.startTest();
        conRU.Buscar();
        Test.stopTest();
    }
    
    @isTest
    private static void test2() {
        TestDataFactory.crearCuentas(1);
        TestDataFactory.crearOportunidades(1, 'Oferta');
        ReciboUsado__c r = new ReciboUsado__c();
        
        PageReference page = Page.VFBusquedaReciboUsado;
        Test.setCurrentPage(page);
        ApexPages.StandardController std = new ApexPages.StandardController(r);
        controllerBusquedaReciboUsado conRU = new controllerBusquedaReciboUsado(std);
        
        Test.startTest();
        conRU.Buscar();
        conRU.recibo.Marca__c = 'BMW';
        conRU.Buscar();
        conRU.recibo.Ano__c = '2000';
        conRU.Buscar();
        conRU.recibo.Modelo__c = 'Prueba'; 
        conRU.Buscar();
        conRU.recibo.EstiloUsado__c = 'TODO TERRENO';
        conRU.Buscar();
        conRU.recibo.Trasmision__c = 'AUTOMATICA';
        conRU.Buscar();
        conRU.recibo.Combustible__c = 'GASOLINA';
        conRU.Buscar();
        conRU.recibo.Traccion__c = '4x4';
        conRU.Buscar();
        Test.stopTest();
    }
    
    @isTest
    private static void test3() {
        TestDataFactory.crearCuentas(1);
        TestDataFactory.crearOportunidades(1, 'Oferta');
        TestDataFactory.crearReciboUsado(1);
        
        PageReference page = Page.VFBusquedaReciboUsado;
        Test.setCurrentPage(page);
        ApexPages.StandardController std = new ApexPages.StandardController(TestDataFactory.MapReciboUsados.get(0));
        controllerBusquedaReciboUsado conRU = new controllerBusquedaReciboUsado(std);
        
        Test.startTest();
        conRU.Buscar();
        conRU.recibo.Marca__c = 'BMW';
        conRU.Buscar();
        conRU.recibo.Ano__c = '2017';
        conRU.Buscar();
        conRU.recibo.Modelo__c = '2017'; 
        conRU.Buscar();
        conRU.recibo.EstiloUsado__c = 'TODO TERRENO';
        conRU.Buscar();
        conRU.recibo.Trasmision__c = 'AUTOMATICA';
        conRU.Buscar();
        conRU.recibo.Combustible__c = 'GASOLINA';
        conRU.Buscar();
        conRU.recibo.Traccion__c = '4x4';
        conRU.Buscar();
        Test.stopTest();
    }
    
    @isTest
    private static void testgetMarcaValues() {
        Marca_Modelo__c marca = dataRecord();
        PageReference page = Page.VFBusquedaReciboUsado;
        Test.setCurrentPage(page);
        ReciboUsado__c reci = new ReciboUsado__c();
        reci.Name = 'TestReciboUsado';
        ApexPages.StandardController std = new ApexPages.StandardController(reci);
        controllerBusquedaReciboUsado controlBus = new controllerBusquedaReciboUsado(std);
        List<SelectOption> listOption = controlBus.getMarcaValues();
        System.assertEquals(2, listOption.size());
    }
    
    //updateLineaList
    @isTest
    private static void testupdateLineaList(){
        Marca_Modelo__c marca = dataRecord();
        PageReference page = Page.VFBusquedaReciboUsado;
        Test.setCurrentPage(page);
        ReciboUsado__c reci = new ReciboUsado__c();
        reci.Name = 'TestReciboUsado';
        ApexPages.StandardController std = new ApexPages.StandardController(reci);
        controllerBusquedaReciboUsado controlBus = new controllerBusquedaReciboUsado(std);
        controlBus.marcaValue = 'ASIA';
        controlBus.updateLineaList();		
        System.assertEquals(2, controlBus.lstLinea.size()); 
    }
    
    //getModelValues
    @isTest
    private static void testgetModelValues(){
        Marca_Modelo__c marca = dataRecord();
        PageReference page = Page.VFBusquedaReciboUsado;
        Test.setCurrentPage(page);
        ReciboUsado__c reci = new ReciboUsado__c();
        reci.Name = 'TestReciboUsado';
        ApexPages.StandardController std = new ApexPages.StandardController(reci);
        controllerBusquedaReciboUsado controlBus = new controllerBusquedaReciboUsado(std);
        List<SelectOption> listOption = controlBus.getModelValues();
        System.assertEquals(2, listOption.size());
    }
    
    //getTransmissionValues
    @isTest
    private static void testgetTransmissionValues(){
        Marca_Modelo__c marca = dataRecord(); 
        PageReference page = Page.VFBusquedaReciboUsado;
        Test.setCurrentPage(page);
        ReciboUsado__c reci = new ReciboUsado__c();
        reci.Name = 'TestReciboUsado';
        ApexPages.StandardController std = new ApexPages.StandardController(reci);
        controllerBusquedaReciboUsado controlBus = new controllerBusquedaReciboUsado(std);
        List<SelectOption> listOption = controlBus.getTransmissionValues();
        System.assertEquals(2, listOption.size());
    }
    
    //getCombustibleValues
    @isTest
    private static void testgetCombustibleValues(){
        Marca_Modelo__c marca = dataRecord(); 
        PageReference page = Page.VFBusquedaReciboUsado;
        Test.setCurrentPage(page);
        ReciboUsado__c reci = new ReciboUsado__c();
        reci.Name = 'TestReciboUsado';
        ApexPages.StandardController std = new ApexPages.StandardController(reci);
        controllerBusquedaReciboUsado controlBus = new controllerBusquedaReciboUsado(std);
        List<SelectOption> listOption = controlBus.getCombustibleValues();
        System.assertEquals(2, listOption.size());
    }
    
    //getEstiloValues
    @isTest
    private static void testgetEstiloValues(){
        Marca_Modelo__c marca = dataRecord(); 
        PageReference page = Page.VFBusquedaReciboUsado;
        Test.setCurrentPage(page);
        ReciboUsado__c reci = new ReciboUsado__c();
        reci.Name = 'TestReciboUsado';
        ApexPages.StandardController std = new ApexPages.StandardController(reci);
        controllerBusquedaReciboUsado controlBus = new controllerBusquedaReciboUsado(std);
        List<SelectOption> listOption = controlBus.getEstiloValues();
        System.assertEquals(2, listOption.size());
    }
    
    //getAPIValues
    @isTest
    private static void testgetAPIValues(){
        Marca_Modelo__c marca = dataRecord(); 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new calloutMock.controllerBusquedaReciboUsadoMock());
        PageReference page = Page.VFBusquedaReciboUsado;
        Test.setCurrentPage(page);
        ReciboUsado__c reci = new ReciboUsado__c();
        reci.Name = 'TestReciboUsado';
        ApexPages.StandardController std = new ApexPages.StandardController(reci);
        controllerBusquedaReciboUsado controlBus = new controllerBusquedaReciboUsado(std);
        controlBus.marcaValue = 'ASIA';
        controlBus.lineaValue = 'TOWNER';
        controlBus.modelValue = '1998';
        controlBus.combustibleValue = 'Gasolina';
        controlBus.transmissionValue = 'Manual';
        controlBus.estiloValue = 'Hatchback';
        controlBus.getAPIValues();
        Test.stopTest();
        System.assertEquals('No se encontraron resultados', controlBus.showMessage);
    }  
    
    @isTest
    private static void testgetAPIValuesforInnerElse(){
        Marca_Modelo__c marca = dataRecord(); 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new calloutMock.controllerBusquedaReciboUsadoMockInnerElse());
        PageReference page = Page.VFBusquedaReciboUsado;
        Test.setCurrentPage(page);
        ReciboUsado__c reci = new ReciboUsado__c();
        reci.Name = 'TestReciboUsado';
        ApexPages.StandardController std = new ApexPages.StandardController(reci);
        controllerBusquedaReciboUsado controlBus = new controllerBusquedaReciboUsado(std);
        controlBus.getAPIValues();
        Test.stopTest();
        System.assert(controlBus.showMessage.contains('Monto Colones'));
    }
    
    @isTest
    private static void testgetAPIValuesforOuterElse(){
        Marca_Modelo__c marca = dataRecord(); 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new calloutMock.controllerBusquedaReciboUsadoMockOuterElse());
        PageReference page = Page.VFBusquedaReciboUsado;
        Test.setCurrentPage(page);
        ReciboUsado__c reci = new ReciboUsado__c();
        reci.Name = 'TestReciboUsado';
        ApexPages.StandardController std = new ApexPages.StandardController(reci);
        controllerBusquedaReciboUsado controlBus = new controllerBusquedaReciboUsado(std);
        controlBus.getAPIValues();
        Test.stopTest();
        System.assertEquals('Esta marca o modelo de vehículo está sujeto a valoración física', controlBus.apiResponse.description);
    }
    
    @isTest
    private static void testgetAPIValuesforCatchBlock(){
        Marca_Modelo__c marca = dataRecord(); 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new calloutMock.controllerBusquedaReciboUsadoMockCatchBlock());
        PageReference page = Page.VFBusquedaReciboUsado;
        Test.setCurrentPage(page);
        ReciboUsado__c reci = new ReciboUsado__c();
        reci.Name = 'TestReciboUsado';
        ApexPages.StandardController std = new ApexPages.StandardController(reci);
        controllerBusquedaReciboUsado controlBus = new controllerBusquedaReciboUsado(std);
        controlBus.getAPIValues();
        Test.stopTest();
        System.assert(controlBus.showMessage == null);
    }
    
    //getAPIListValues
    @isTest
    private static void testgetAPIListValues(){
        Marca_Modelo__c marca = dataRecord(); 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new calloutMock.controllerBusquedaReciboUsadoMockGetAPIValues());
        PageReference page = Page.VFBusquedaReciboUsado;
        Test.setCurrentPage(page);
        ReciboUsado__c reci = new ReciboUsado__c();
        reci.Name = 'TestReciboUsado';
        ApexPages.StandardController std = new ApexPages.StandardController(reci);
        controllerBusquedaReciboUsado controlBus = new controllerBusquedaReciboUsado(std);
        
        controlBus.getAPIListValues();
        Test.stopTest();
        List<Marca_Modelo__c> marcaList = [Select id from Marca_Modelo__c];
        System.assertEquals(1, marcaList.size());
    }
    
    @isTest
    private static void testgetAPIListValuesforCatchBlock(){ 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new calloutMock.controllerBusquedaReciboUsadoMockCatchBlock());
        PageReference page = Page.VFBusquedaReciboUsado;
        Test.setCurrentPage(page);
        ReciboUsado__c reci = new ReciboUsado__c();
        reci.Name = 'TestReciboUsado';
        ApexPages.StandardController std = new ApexPages.StandardController(reci);
        controllerBusquedaReciboUsado controlBus = new controllerBusquedaReciboUsado(std);  
        controlBus.getAPIListValues();
        Test.stopTest();
        List<Marca_Modelo__c> marcaList = [Select id from Marca_Modelo__c];
        System.assertEquals(0, marcaList.size());
    }
    
    @isTest
    private static void testshowSearchBlock(){ 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new calloutMock.controllerBusquedaReciboUsadoMockCatchBlock());
        PageReference page = Page.VFBusquedaReciboUsado;
        Test.setCurrentPage(page);
        ReciboUsado__c reci = new ReciboUsado__c();
        reci.Name = 'TestReciboUsado';
        ApexPages.StandardController std = new ApexPages.StandardController(reci);
        controllerBusquedaReciboUsado controlBus = new controllerBusquedaReciboUsado(std);
        controlBus.tipoVehiculo = 'Automóvil';
        controlBus.showSearchBlock();
        controlBus.tipoVehiculo = 'Motocicleta';
        controlBus.showSearchBlock();
        controlBus.tipoVehiculo = 'test';
        controlBus.showSearchBlock();
        Test.stopTest();
    }
    
    /*********BusMoto Method coverage******/
    @isTest
    private static void test11() {
        TestDataFactory.crearCuentas(1);
        TestDataFactory.crearOportunidades(1, 'Oferta');
        TestDataFactory.crearReciboUsado(1);
        
        PageReference page = Page.VFBusquedaReciboUsado;
        Test.setCurrentPage(page);
        ApexPages.currentPage().getParameters().put('Id',TestDataFactory.MapReciboUsados.get(0).id);
        ApexPages.StandardController std = new ApexPages.StandardController(TestDataFactory.MapReciboUsados.get(0));
        controllerBusquedaReciboUsado conRU = new controllerBusquedaReciboUsado(std);
        
        Test.startTest();
        conRU.BuscarMoto();
        Test.stopTest();
    }
    
    @isTest
    private static void test21() {
        TestDataFactory.crearCuentas(1);
        TestDataFactory.crearOportunidades(1, 'Oferta');
        ReciboUsado__c r = new ReciboUsado__c();
        
        PageReference page = Page.VFBusquedaReciboUsado;
        Test.setCurrentPage(page);
        ApexPages.StandardController std = new ApexPages.StandardController(r);
        controllerBusquedaReciboUsado conRU = new controllerBusquedaReciboUsado(std);
        
        Test.startTest();
        conRU.BuscarMoto();
        conRU.recibo.Marca__c = 'BMW';
        conRU.BuscarMoto();
        conRU.recibo.Ano__c = '2000';
        conRU.BuscarMoto();
        conRU.recibo.Modelo__c = 'Prueba'; 
        conRU.BuscarMoto();
        conRU.recibo.EstiloUsado__c = 'TODO TERRENO';
        conRU.BuscarMoto();
        conRU.recibo.Trasmision__c = 'AUTOMATICA';
        conRU.BuscarMoto();
        conRU.recibo.Combustible__c = 'GASOLINA';
        conRU.BuscarMoto();
        conRU.recibo.Traccion__c = '4x4';
        conRU.BuscarMoto();
        Test.stopTest();
    }
    
    @isTest
    private static void test31() {
        TestDataFactory.crearCuentas(1);
        TestDataFactory.crearOportunidades(1, 'Oferta');
        TestDataFactory.crearReciboUsado(1);
        
        PageReference page = Page.VFBusquedaReciboUsado;
        Test.setCurrentPage(page);
        ApexPages.StandardController std = new ApexPages.StandardController(TestDataFactory.MapReciboUsados.get(0));
        controllerBusquedaReciboUsado conRU = new controllerBusquedaReciboUsado(std);
        
        Test.startTest();
        conRU.BuscarMoto();
        conRU.recibo.Marca__c = 'BMW';
        conRU.BuscarMoto();
        conRU.recibo.Ano__c = '2017';
        conRU.BuscarMoto();
        conRU.recibo.Modelo__c = '2017'; 
        conRU.BuscarMoto();
        conRU.recibo.EstiloUsado__c = 'TODO TERRENO';
        conRU.BuscarMoto();
        conRU.recibo.Trasmision__c = 'AUTOMATICA';
        conRU.BuscarMoto();
        conRU.recibo.Combustible__c = 'GASOLINA';
        conRU.BuscarMoto();
        conRU.recibo.Traccion__c = '4x4';
        conRU.BuscarMoto();
        Test.stopTest();
    }

    @isTest
    private static void test41() {
        TestDataFactory.crearCuentas(1);
        TestDataFactory.crearOportunidades(1, 'Oferta');
        TestDataFactory.crearReciboUsado(1);
        
        PageReference page = Page.VFBusquedaReciboUsado;
        Test.setCurrentPage(page);
        ApexPages.StandardController std = new ApexPages.StandardController(TestDataFactory.MapReciboUsados.get(0));
        controllerBusquedaReciboUsado conRU = new controllerBusquedaReciboUsado(std);
        
        Test.startTest();
        conRU.BuscarMoto();
        conRU.recibo.Marca__c = 'BMW';
        conRU.BuscarMoto();
        conRU.recibo.Ano__c = '2017';
        conRU.BuscarMoto();
        conRU.recibo.Modelo__c = '2017'; 
        conRU.BuscarMoto();
        conRU.recibo.EstiloUsado__c = 'TODO TERRENO';
        conRU.BuscarMoto();
        conRU.recibo.Trasmision__c = 'AUTOMATICA';
        conRU.BuscarMoto();
        conRU.recibo.Combustible__c = 'GASOLINA';
        conRU.BuscarMoto();
        conRU.recibo.Traccion__c = '4x4';
        
        conRU.recibo.Cilindraje__c = 565;
        conRU.BuscarMoto();
        conRU.recibo.Segmento__c =  'Adventure';
        conRU.BuscarMoto();
        conRU.recibo.Gama__c =  'Alta';
        conRU.recibo.Valor_final__c =  50000.00;
        conRU.BuscarMoto();
        Test.stopTest();
    }
    
    private static Marca_Modelo__c dataRecord(){
        Marca_Modelo__c marca = new Marca_Modelo__c();
        marca.Combustible__c = 'Gasolina';
        marca.Estilo__c = 'Hatchback';
        marca.Linea__c = 'TOWNER';
        marca.Marca__c = 'ASIA';
        marca.Modelo__c='1998';
        marca.Transmission__c='Manual';
        insert marca;
        return marca;
    }
}