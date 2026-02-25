/**
 * @description       : 
 * @author            : marcohernandezhp@gmail.com
 * @group             : 
 * @last modified on  : 03-28-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
@isTest
public class cT_newPlanVentaControler_test {
 // Realizado por David León, fecha: 07/11/2017
    static{
        // TestDataFactory.datosGenerales();
        TestDataFactory.createQuoteWithItems();
    }

    static testMethod void myUnitTest() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];       
        Quote quote = [SELECT Id FROM Quote LIMIT 1];  
        Set<Id> quoteIds = new Set<Id>{quote.Id};  
        RM_SyncQuoteService_v2.syncQuote(quoteIds);
        // // TO DO: implement unit test
        // Account acc = new Account(RecordTypeid=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId(), 
        //                           FirstName='Account Test Name',   
        //                           LastName='Apellido',PersonEmail='da_ls90@hotmail.es',
        //                           Cedula__c = '123123123');
        // insert(acc);
        
        // Campaign cam = new Campaign(Name='Campaign Test');
        // insert(cam);
        
        // String tipoTaller = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Taller').getRecordTypeId();
        
        // Opportunity opp = new Opportunity(Name='Opportunity Test', Campana__c= TestDataFactory.campanna.Id, Sucursal__c='Pavas', Accountid=acc.Id, CloseDate=System.today(), 
        //                                    StageName='Oferta', Enganche_monto__c=150000, Enganche_recibo__c= '50000', Realiza_Test_Drive__c=true, RT_Lead__c = 'BMW',recordtypeid = tipoTaller);
        // insert(opp);
        
        // Product2 pro = new Product2(Codigo_de_Producto__c= 'AA00', Name='Product Test', ProductCode='TT00');
        // insert pro;
        
        // Pricebook2 priceTest = new Pricebook2(Name='priceTest', IsActive = true, Description='Test');
        // insert priceTest;
        
        // /*PricebookEntry standardPriceTest = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id=pro.Id, UnitPrice=150000, IsActive=true);
        // insert standardPriceTest;*/
        
        // PricebookEntry priceEntryTest = new PricebookEntry(Pricebook2Id=priceTest.id, Product2Id=pro.Id, UnitPrice= 25000, IsActive=true, UseStandardPrice=false);
        // insert priceEntryTest;
        
        // OpportunityLineItem lineItemTest = new OpportunityLineItem(TotalPrice=priceEntryTest.UnitPrice, PricebookEntryId=priceEntryTest.Id, Quantity=1, OpportunityId=opp.id);
        // insert(lineItemTest);
        
		// Quote nuevaQuote = new Quote();
        // nuevaQuote.OpportunityId = opp.id;
        // nuevaQuote.Pricebook2Id = priceTest.id;
        // insert nuevaQuote;
        
        // QuoteLineItem nuevoLineItem = new QuoteLineItem();
        // // nuevoLineItem.esVehiculo__c = true;
        // nuevoLineItem.QuoteId = nuevaQuote.id;
        // nuevoLineItem.Product2Id = pro.id;
        // nuevoLineItem.PricebookEntryId = priceEntryTest.id;
        // nuevoLineItem.Quantity = 1;
        // nuevoLineItem.UnitPrice = 1;
        // insert nuevoLineItem;
                       
        // System.debug('Opp id ' + opp.id);
        String oppoId = opp.id;

        ReciboUsado__c reciboUsado = new ReciboUsado__c();
		reciboUsado.Oportunidad__c  = oppoId;
        reciboUsado.Marca__c = 'BMW';
        reciboUsado.Ano__c = '2023';
        reciboUsado.Placa__c = 'ASDASD112';
        reciboUsado.ValorReciboCliente__c = 1;
        reciboUsado.ReciboJefeUsados__c = 1;
        reciboUsado.Modelo__c = 'X1';
        reciboUsado.Color__c = 'GRIS';
        reciboUsado.N_puertas__c = 4;
        reciboUsado.Serecibevehiculo__c = true;
        reciboUsado.Fecha_de_recibo__c = Date.today();
        reciboUsado.Kilometraje__c = 100;

        insert reciboUsado;

        // cT_newPlanVentaControler.datosVehiculo dv = new cT_newPlanVentaControler.datosVehiculo();
  
        test.startTest();
        cT_newPlanVentaControler quotePDF = new cT_newPlanVentaControler(new ApexPages.StandardController(opp));
        ApexPages.currentPage().getParameters().put('Id',opp.Id);
        //quotePDF.getData(oppoId);
        test.stopTest();
    }

}