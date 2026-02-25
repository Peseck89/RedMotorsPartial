/**
	@Autor: David Leon Sanchez
	@Fecha creacion: 13/11/2017 
	@Cliente: RM - Altica
	@Proposito: Clase Test para probar la clase 'OpportunityLineItemService'
**/

@isTest
private class OpportunityLineItemServiceTest {
	Static Integer num = 1;
	Static Integer num2 = 2;
	Static Integer num3 = 3;
	
	Static{
		TestDataFactory.datosGenerales();
	}
	
	//Metodo para probar el metodo 'actualizarProductosOF' en la clase 'OpportunityLineItemService' cuando se elimina un producto de la Oportunidad
	//A la Oportunidad se le crean 2 productos
    static testMethod void deleteProduct(){
    	List<Opportunity> listOps = new List<Opportunity>();
    	List<OpportunityLineItem> listProd =  new List<OpportunityLineItem>();
    	
        //crear cuenta
        TestDataFactory.crearCuentas(num);
        
        //crear productos
        TestDataFactory.createProducts(num2);
        
        //crear precios
        TestDataFactory.createPriceBookEntries(num2, Test.getStandardPricebookId());
        
        //crear Oportunidad de Negocio
        TestDataFactory.crearOportunidades(num, 'Test Drive');
        
        //crear productos para la Oportunidad de negocio
        TestDataFactory.crearProductosOP(num);
		TestDataFactory.crearProductosOP(num);
        
        //crear la Oportunidad de Financiamiento
        listOps = TestDataFactory.MapOportunidades.values();
    	listOps[0].MonedaIngreso__c = SObjectType.Opportunity.Fields.MonedaIngreso__c.PicklistValues[1].getValue(); //dolares
        listOps[0].IngresoAproximado__c = 3000;
        listOps[0].Consentimientofinaciero__c = true;
    	update listOps;
        
        System.debug('**** OF Test ****' + [SELECT Name FROM Oportunidad_de_Financiamiento__c WHERE Oportunidad__c =: listOps[0].Id]);
        //empieza el test cuando se elimina un producto de la oportunidad
        Test.startTest();
        	for(OpportunityLineItem prod : [SELECT Id, Name FROM OpportunityLineItem WHERE OpportunityId =: listOps[0].Id]){
				delete prod;
				break;        	
        	}
    	Test.stopTest();
    }
    
    //Metodo para probar el metodo 'actualizarProductosOF' en la clase 'OpportunityLineItemService' cuando se elimina un producto de la Oportunidad
	//A la Oportunidad se le crean 3 productos
    static testMethod void deleteProduct2(){
    	List<Opportunity> listOps = new List<Opportunity>();
    	List<OpportunityLineItem> listProd =  new List<OpportunityLineItem>();
    	
        //crear cuenta
        TestDataFactory.crearCuentas(num);
        
        //crear productos
        TestDataFactory.createProducts(num3);
        
        //crear precios
        TestDataFactory.createPriceBookEntries(num3, Test.getStandardPricebookId());
        
        //crear Oportunidad de Negocio
        TestDataFactory.crearOportunidades(num, 'Test Drive');
        
        //crear productos para la Oportunidad de negocio
        TestDataFactory.crearProductosOP(num);
		TestDataFactory.crearProductosOP(num);
		TestDataFactory.crearProductosOP(num);
        
        //crear la Oportunidad de Financiamiento
        listOps = TestDataFactory.MapOportunidades.values();
    	listOps[0].MonedaIngreso__c = SObjectType.Opportunity.Fields.MonedaIngreso__c.PicklistValues[1].getValue(); //dolares
        listOps[0].IngresoAproximado__c = 3000;
        listOps[0].Consentimientofinaciero__c = true;
    	update listOps;
        
        System.debug('**** OF Test ****' + [SELECT Name FROM Oportunidad_de_Financiamiento__c WHERE Oportunidad__c =: listOps[0].Id]);
        //empieza el test cuando se elimina un producto de la oportunidad
        Test.startTest();
        	for(OpportunityLineItem prod : [SELECT Id, Name FROM OpportunityLineItem WHERE OpportunityId =: listOps[0].Id]){
				delete prod;
				break;        	
        	}
    	Test.stopTest();
    }
    
    //Metodo para probar el metodo 'actualizarProductosOF' en la clase 'OpportunityLineItemService' cuando se actualiza un producto de la Oportunidad
	//A la Oportunidad se le crean 2 productos
    static testMethod void updateProduct(){
    	List<Opportunity> listOps = new List<Opportunity>();
    	List<OpportunityLineItem> listProd =  new List<OpportunityLineItem>();
    	
        //crear cuenta
        TestDataFactory.crearCuentas(num);
        
        //crear productos
        TestDataFactory.createProducts(num2);
        
        //crear precios
        TestDataFactory.createPriceBookEntries(num2, Test.getStandardPricebookId());
        
        //crear Oportunidad de Negocio
        TestDataFactory.crearOportunidades(num, 'Test Drive');
        
        //crear productos para la Oportunidad de negocio
        TestDataFactory.crearProductosOP(num);
		TestDataFactory.crearProductosOP(num);
        
        //crear la Oportunidad de Financiamiento
        listOps = TestDataFactory.MapOportunidades.values();
    	listOps[0].MonedaIngreso__c = SObjectType.Opportunity.Fields.MonedaIngreso__c.PicklistValues[1].getValue(); //dolares
        listOps[0].IngresoAproximado__c = 3000;
        listOps[0].Consentimientofinaciero__c = true;
    	update listOps;
        
        System.debug('**** OF Test ****' + [SELECT Name FROM Oportunidad_de_Financiamiento__c WHERE Oportunidad__c =: listOps[0].Id]);
        //empieza el test cuando se elimina un producto de la oportunidad
        Test.startTest();
        	for(OpportunityLineItem prod : [SELECT Id, Name, Quantity FROM OpportunityLineItem WHERE OpportunityId =: listOps[0].Id]){
				prod.Quantity = 2;
				update prod;        	
        	}
        ActualizaNombreProducto.ActualizaProdu(2018,01,01,2020,12,31);
    	Test.stopTest();
    }
    
    /*//Metodo para probar el metodo 'actualizarProductosOF' en la clase 'OpportunityLineItemService' cuando se le agrega un producto a la Oportunidad
	//A la Oportunidad se le crea 1 producto
    static testMethod void addProduct(){
    	List<Opportunity> listOps = new List<Opportunity>();
    	List<OpportunityLineItem> listProd =  new List<OpportunityLineItem>();
    	
        //crear cuenta
        TestDataFactory.crearCuentas(num);
        
        //crear productos
        TestDataFactory.createProducts(num2);
        
        //crear precios
        TestDataFactory.createPriceBookEntries(num2, Test.getStandardPricebookId());
        
        //crear Oportunidad de Negocio
        TestDataFactory.crearOportunidades(num, 'Test Drive');
        
        //crear productos para la Oportunidad de negocio
        TestDataFactory.crearProductosOP(num);
        
        //crear la Oportunidad de Financiamiento
        listOps = TestDataFactory.MapOportunidades.values();
    	listOps[0].MonedaIngreso__c = SObjectType.Opportunity.Fields.MonedaIngreso__c.PicklistValues[1].getValue(); //dolares
        listOps[0].IngresoAproximado__c = 3000;
        listOps[0].Consentimientofinaciero__c = true;
    	update listOps;
        
        System.debug('**** OF Test ****' + [SELECT Name FROM Oportunidad_de_Financiamiento__c WHERE Oportunidad__c =: listOps[0].Id]);
        //empieza el test cuando se elimina un producto de la oportunidad
        Test.startTest();
        	TestDataFactory.crearProductosOP(num);
    	Test.stopTest();
    }*/
    
}