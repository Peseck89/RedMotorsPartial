/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class WsProcesosAprobacion_Test {

    static Integer iTotReg = 1;
    
    static {
        TestDataFactory.datosGenerales();
        
        TestDataFactory.createProducts(iTotReg);
        
        TestDataFactory.createPriceBookEntries(iTotReg, Test.getStandardPricebookId());
        
        TestDataFactory.crearCuentas(iTotReg);
        
        TestDataFactory.crearOportunidades(iTotReg,'Oportunidad Calificada');
        
        TestDataFactory.crearProductosOP(iTotReg);
        
        TestDataFactory.crearReciboUsado(iTotReg);
    }
    
	//No se encontró la oportunidad o no hay descuento para aprobar
    static testMethod void AprobacionDescuentoTest00() {
        List<Opportunity> Oportunidades = TestDataFactory.MapOportunidades.values();
        List<OpportunityLineItem> productosOp = TestDataFactory.MapOpItems.values();
        
        test.startTest();
			
			String resultado = WsProcesosAprobacion.AprobacionDescuento('0064B000004####');
			
        test.stopTest();
        
    }
    
    //Vendedor
    static testMethod void AprobacionDescuentoTest01() {
        List<Opportunity> Oportunidades = TestDataFactory.MapOportunidades.values();
        List<OpportunityLineItem> productosOp = TestDataFactory.MapOpItems.values();
        
        test.startTest();
			
			String resultado = WsProcesosAprobacion.AprobacionDescuento(Oportunidades[0].Id);
			
        test.stopTest();
        
    } 
    
    //Jefe
    static testMethod void AprobacionDescuentoTest02() {
        List<Opportunity> Oportunidades = TestDataFactory.MapOportunidades.values();
        List<OpportunityLineItem> productosOp = TestDataFactory.MapOpItems.values();
        
        productosOp[0].Preciodefacturacion__c = 58000;
        update productosOp;
        
        test.startTest();
			
			String resultado = WsProcesosAprobacion.AprobacionDescuento(Oportunidades[0].Id);
			
        test.stopTest();
        
    }   
    
    //Gerente
    static testMethod void AprobacionDescuentoTest03() {
        List<Opportunity> Oportunidades = TestDataFactory.MapOportunidades.values();
        List<OpportunityLineItem> productosOp = TestDataFactory.MapOpItems.values();
        
        productosOp[0].Preciodefacturacion__c = 55300;
        update productosOp;
        
        test.startTest();
			
			String resultado = WsProcesosAprobacion.AprobacionDescuento(Oportunidades[0].Id);
			
        test.stopTest();
        
    }
    
    
   //Director
    static testMethod void AprobacionDescuentoTest04() {
        List<Opportunity> Oportunidades = TestDataFactory.MapOportunidades.values();
        List<OpportunityLineItem> productosOp = TestDataFactory.MapOpItems.values();
        
        productosOp[0].Preciodefacturacion__c = 55000;
        update productosOp;
        
        test.startTest();
			
			String resultado = WsProcesosAprobacion.AprobacionDescuento(Oportunidades[0].Id);
			
        test.stopTest();
        
    }   
            
}