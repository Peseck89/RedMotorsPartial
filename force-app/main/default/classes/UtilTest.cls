/**
	@Autor: David Leon Sanchez
	@Fecha creacion: 09/10/2017 
	@Proyecto: Red Motor
	@Proposito: Clase test para probar la funcionalidad de la clase Util
 */
 
@isTest
private class UtilTest {
	static Integer iTo = 1;
	
	static{
        TestDataFactory.datosGenerales();
        
        TestDataFactory.createProducts(iTo);
        
        
       // TestDataFactory.createPriceBookEntries(iTo, Test.getStandardPricebookId());
        
        TestDataFactory.crearCuentas(iTo);
        
        TestDataFactory.crearOportunidades(iTo, 'Oportunidad Calificada');
		PricebookEntry pbe = [Select Id,UnitPrice,currencyisocode From PricebookEntry LIMIT 1];
        Opportunity opp = [Select 	Id,currencyisocode From Opportunity LIMIT 1];
        opp.currencyisocode = pbe.currencyisocode;
        update opp;
		//TestDataFactory.crearProductosOP(iTo);
        OpportunityLineItem item = new OpportunityLineItem(
                PriceBookEntryId = pbe.Id,
                OpportunityId=opp.Id,
                Quantity = 1,
                TotalPrice = pbe.UnitPrice
            );
        
        TriggerHandler.bypass('OpportunityLineItemTrigger');
		insert item;
		TriggerHandler.clearBypass('OpportunityLineItemTrigger');
        
    }
	
	//Metodo para probar la funcionalidad del metodo llamado updateFieldOp de la clase llamada Util
	@isTest
    private static void updateFieldAdd(){
    	List<Opportunity> Oportunidades = TestDataFactory.MapOportunidades.values();
        List<OpportunityLineItem> productosOp = [Select Id,Product2Id,PriceBookEntryId,OpportunityId,Quantity,TotalPrice,
                                                 UnitPrice,Porcentaje_Comision_Vendedor_FM__c,Porcentaje_Comision_Jefe_FM__c,
                                                 Porcentaje_Comision_Gerente_FM__c
                                                 from OpportunityLineItem];
    	List<Id> idsP = new List<Id>();
    	
    	idsP.add(productosOp[0].Product2Id);
    	test.startTest();
    		Util.updateFieldOp(idsP, Oportunidades[0].Id);
                productosOp[0].UnitPrice = 0;
		update productosOp;
    	test.stopTest();	
    }
    
    static testMethod void updateFieldDelete() {
        List<Opportunity> Oportunidades = TestDataFactory.MapOportunidades.values();
        List<OpportunityLineItem> productosOp = [Select Id,Product2Id,PriceBookEntryId,OpportunityId,Quantity,TotalPrice from OpportunityLineItem];
    	
    	test.startTest();
    	//	delete TestDataFactory.MapOpItems.get(0);
        delete productosOp;
    	test.stopTest();  
    }
}