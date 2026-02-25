/**
	@Autor: David Leon Sanchez
	@Fecha creacion: 24/08/2017 
	@Proyecto: Altica
	@Proposito: Clase Test para probar la clase llamada SchedulableEnvioAlertaOF

**/

@isTest
private class TestUpdateFieldProductOpF {
	
	Static{
		TestDataFactory.datosGenerales();
	}

	//Test para probar el metodo llamado UpdateFieldProductOpF de la clase UpdateFieldProductOpF solo con un producto
	@IsTest 
	private static void test1(){
		List<ID>idsOppts = new List<Id>();

		//Crear Cuenta
		Account acct = new Account(
			FirstName = 'Test', 
			LastName = 'Test', 
			Tipo_de_Documento__c = 'Cedula', 
			Cedula__c = '402080760', 
			PersonEmail = 'da_ls90@hotmail.es', 
			PersonMobilePhone = '+50683838383');
		insert acct;

		//Crear sucursales.
		Sucursal__c sucursal = new Sucursal__c(
			Name='Pavas',
			DirectordeVentasBMW__c = UserInfo.getUserId(),
			GerentedeSucursalBMW__c = UserInfo.getUserId(),
			JefeseSucursalBMW__c = UserInfo.getUserId()
		);
		insert sucursal;

		Pricebook2 pb2 = new Pricebook2();
		pb2.Name = 'BMW - 2017';
		pb2.IsActive = true;
		insert pb2;

		Product2 prod = new Product2();
		prod.Name = 'BM35 - X5 - 25d PREMIUM';
		prod.Codigo_de_Producto__c = 'BM36';
		prod.ProductCode = 'BM36';
		prod.IsActive = true;
		prod.Marca__c = 'BMW';
		prod.Description = '25d PAQ M';
		prod.NombredePlantilla__c = 'BMWX5AgradecimientoVisita';
		prod.Familia__c = 'X5';
		
		insert prod;
		System.debug('qqqqq' + prod);

		PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
		insert standardPBE;

		PricebookEntry pbe = new PricebookEntry();
		pbe.Product2Id = prod.Id;
		pbe.Pricebook2Id = pb2.Id;
		pbe.UnitPrice = 98000;
		pbe.UseStandardPrice = false;
		pbe.IsActive = true;
		System.debug('ppppp' + pbe);
		insert pbe;

		Test.startTest();
			Opportunity op = new Opportunity();
			op.OwnerId = UserInfo.getUserId();
			op.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
			op.Name = 'Prueba';
			op.Campana__c = TestDataFactory.campanna.Id;
			op.Sucursal__c = sucursal.Name;
			op.SucursalId__c = sucursal.Id;
			op.CloseDate = system.today();
			op.StageName = 'Oportunidad Calificada';
			op.Pricebook2Id = pb2.Id;
			op.AccountId = acct.Id;
			op.Consentimientofinaciero__c = true;
			op.OFCreada__c = false;
			op.MonedaIngreso__c = 'Colones';
			op.IngresoAproximado__c = 160000;
			op.RT_Lead__c = 'BMW';
			insert op;
			idsOppts.add(op.Id);
			UpdateFieldProductOpF.getProduct(idsOppts);

			OpportunityLineItem lineItem = new OpportunityLineItem();
			lineItem.Preciodefacturacion__c = 220000;
			lineItem.OpportunityId = op.Id;
			lineItem.Marca__c = prod.Marca__c;
			lineItem.Modelo_De_Inter_s1__c = prod.Modelo_De_Inter_s__c;
			lineItem.Familia1__c = prod.Familia__c;
			lineItem.Quantity = 1;
			lineItem.PricebookEntryId = pbe.Id;
			lineItem.TotalPrice = 225000;
			insert lineItem;
		Test.stopTest();
	}

	//Test para probar la clase llamada SchedulableEnvioAlertaOF
	@isTest
	private static void test2() {
		Account acct = new Account();
		acct.FirstName = 'Prueba';
		acct.LastName = 'Prueba';
		acct.Tipo_de_Documento__c = 'Cedula';
		acct.Cedula__c = '123456789';
		acct.PersonMobilePhone = '+50683347634';
		insert acct;

		Pricebook2 pb2 = new Pricebook2();
		pb2.Name = 'BMW - 2017';
		pb2.IsActive = true;
		insert pb2;

		Product2 prod = new Product2();
		prod.Name = 'BM35 - X5 - 25d PREMIUM';
		prod.Codigo_de_Producto__c = 'BM36';
		prod.ProductCode = 'BM36';
		prod.IsActive = true;
		prod.Marca__c = 'BMW';
		prod.Description = '25d PAQ M';
		prod.NombredePlantilla__c = 'BMWX5AgradecimientoVisita';
		prod.Familia__c = 'X5';
		
		insert prod;
		System.debug('qqqqq' + prod);

		PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
		insert standardPBE;

		PricebookEntry pbe = new PricebookEntry();
		pbe.Product2Id = prod.Id;
		pbe.Pricebook2Id = pb2.Id;
		pbe.UnitPrice = 98000;
		pbe.UseStandardPrice = false;
		pbe.IsActive = true;
		System.debug('ppppp' + pbe);
		insert pbe;

		Opportunity op = new Opportunity();
		op.Name = 'Prueba';
		op.Sucursal__c = 'Pavas';
		op.AccountId = acct.Id;
		op.CloseDate = System.today() + 5;
		op.StageName = 'Test Drive';
		op.Campana__c = TestDataFactory.campanna.Id;
		op.UltimaModificacion__c = System.now();
		op.Pricebook2Id = pb2.Id;
		op.OwnerId = UserInfo.getUserId();
		op.MonedaIngreso__c = 'Colones';
		op.IngresoAproximado__c = 160000;	
		op.RT_Lead__c = 'BMW';	
		insert op;

		System.debug('************************** Oportunidad ************************* ' + op);
		OpportunityLineItem lineItem = new OpportunityLineItem();
		lineItem.Preciodefacturacion__c = 220000;
		lineItem.OpportunityId = op.Id;
		lineItem.Marca__c = prod.Marca__c;
		lineItem.Modelo_De_Inter_s1__c = prod.Modelo_De_Inter_s__c;
		lineItem.Familia1__c = prod.Familia__c;
		lineItem.Quantity = 1;
		lineItem.PricebookEntryId = pbe.Id;
		lineItem.TotalPrice = 225000;
		insert lineItem;
		System.debug('************************** Producto de la Oportunidad ************************* ' + lineItem);

		Test.startTest();
			op.Consentimientofinaciero__c = true;
			update op;
			System.debug('********************** Oportunidad ********************** ' + op);
			for(Oportunidad_de_Financiamiento__c opF : [SELECT Id, Estado__c FROM Oportunidad_de_Financiamiento__c WHERE Oportunidad__c =: op.Id]){
				opF.FechaInicioOF__c = System.now() - 1;
				update opF;
				System.debug('**************************** fecha de OF ********************** ' + opF.FechaInicioOF__c);
			}
			
			SchedulableEnvioAlertaOF sh = new SchedulableEnvioAlertaOF();
			String sch = '0 12 10 * * ?';
			System.schedule('Test',sch,sh );
		Test.stopTest();
	}
	
	//Test para probar el metodo llamado UpdateFieldProductOpF de la clase UpdateFieldProductOpF con mas de un producto
	@IsTest 
	private static void test3(){
		Integer num = 1;
		Integer num2 = 2;
		Integer num3 = 3;
		
		//Se crea la cuenta
		TestDataFactory.crearCuentas(num);
		
		//Se crean productos
		TestDataFactory.createProducts(num3);
		
		//Se crean los precios
		TestDataFactory.createPriceBookEntries(num3, Test.getStandardPricebookId());
		
		//Se crean la Oportunidad de Negocio
		TestDataFactory.crearOportunidades(num, 'Test Drive');
		
		//Se crean productos para la Oportunidad de negocio creada
		TestDataFactory.crearProductosOP(num);
		TestDataFactory.crearProductosOP(num);
		TestDataFactory.crearProductosOP(num);
		
		Test.startTest();
			List<Opportunity> opp = TestDataFactory.MapOportunidades.values();
			//Se llenan esos campos como requisitos para crear la Oportunidad de Financiamiento
			opp[0].MonedaIngreso__c = SObjectType.Opportunity.Fields.MonedaIngreso__c.PicklistValues[1].getValue(); //dolares
			opp[0].IngresoAproximado__c = 2500;
			opp[0].Consentimientofinaciero__c = true;
			update opp;
		Test.stopTest();
	}
}