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
 
 // Realizado por David León, fecha: 07/11/2017
@isTest
private class PlanVentaTest {

	static{
		TestDataFactory.datosGenerales();
	}

    static testMethod void myUnitTest() {
        
        ControllerPlanVenta conTest2;
        
        // TO DO: implement unit test
        Account acc = new Account(RecordTypeid=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId(), FirstName='Account Test Name',   
                                    LastName='Apellido',PersonEmail='da_ls90@hotmail.es');
        insert(acc);
        
        Campaign cam = new Campaign(Name='Campaign Test');
        insert(cam);
        
        Opportunity opp = new Opportunity(Name='Opportunity Test', Campana__c= TestDataFactory.campanna.Id, Sucursal__c='Pavas', Accountid=acc.Id, CloseDate=System.today(), 
                                           StageName='Oferta', Enganche_monto__c=150000, Enganche_recibo__c= '50000', Realiza_Test_Drive__c=true, Consentimientofinaciero__c=true, RT_Lead__c = 'BMW');
        insert(opp);
        
        Product2 pro = new Product2(Codigo_de_Producto__c= 'AA00', Name='Product Test', ProductCode='TT00');
        insert pro;
        
        Pricebook2 priceTest = new Pricebook2(Name='priceTest', IsActive = true, Description='Test');
        insert priceTest;
        
        PricebookEntry standardPriceTest = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id=pro.Id, UnitPrice=150000, IsActive=true);
        insert standardPriceTest;
        
        PricebookEntry priceEntryTest = new PricebookEntry(Pricebook2Id=priceTest.id, Product2Id=pro.Id, UnitPrice= 25000, IsActive=true, UseStandardPrice=false);
        insert priceEntryTest;
        
        OpportunityLineItem lineItemTest = new OpportunityLineItem(TotalPrice=priceEntryTest.UnitPrice, PricebookEntryId=priceEntryTest.Id, Quantity=1, OpportunityId=opp.id);
        insert(lineItemTest);
        
        ReciboUsado__c reciboTest = new ReciboUsado__c(Name='UsadoTest', 
			Serecibevehiculo__c = true, 
			Oportunidad__c=opp.Id,  
			Marca__c = 'HONDA',   
			Ano__c='2007',  
			//Modelo__c='Civic Si',   
			Placa__c='BKZ 496',
			Traccion__c = '4x2',
			EstiloUsado__c = 'TODO TERRENO',
			Version__c = ' ',
			ReciboJefeUsados__c = 10000,
			RecordTypeId = Schema.SObjectType.ReciboUsado__c.getRecordTypeInfosByName().get('Automóvil').getRecordTypeId()
		);
        insert reciboTest;
                                                
        test.startTest();
        Apexpages.currentPage().getParameters().put('id',opp.id);
        conTest2 = new ControllerPlanVenta();
        
        conTest2.Header='testPlanVeta';
        conTest2.flag='Test';
        opp.Consentimientofinaciero__c = false;
        update(opp);
        
        Apexpages.currentPage().getParameters().put('id',opp.id);
        conTest2 = new ControllerPlanVenta();
        test.stopTest();
        
    }
}