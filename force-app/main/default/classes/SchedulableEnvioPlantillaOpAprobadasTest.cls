/**
	@Autor: David Leon Sanchez
	@Fecha creacion: 22/08/2017 
	@Proyecto: Altica
	@Proposito: Clase Test para probar la clase llamada SchedulableEnvioPlantillaOpAprobadas

**/

@isTest
private class SchedulableEnvioPlantillaOpAprobadasTest {

	Static{
		TestDataFactory.datosGenerales();
	}

	//Metodo para probar el envio de correo 
	@isTest
	private static void test1() {
		Account acct = new Account();
		acct.FirstName = 'Prueba';
		acct.LastName = 'Prueba';
		acct.Tipo_de_Documento__c = 'Cedula';
		acct.Cedula__c = '404440444';
		acct.PersonMobilePhone = '+50683838383';
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
		op.UltimaModificacion__c = System.today() - 3;
		op.Pricebook2Id = pb2.Id;
		op.OwnerId = UserInfo.getUserId();
		op.MonedaIngreso__c = SObjectType.Opportunity.Fields.MonedaIngreso__c.PicklistValues[1].getValue(); //Dólares
		op.IngresoAproximado__c = 1500;		
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
				System.debug('*********************** OporFinan *********************** ' + opF);
				opF.Estado__c = 'Aprobada';
				update opF;
			}
			
			SchedulableEnvioPlantillaOpAprobadas sh = new SchedulableEnvioPlantillaOpAprobadas();
			String sch = '0 0 23 * * ?';
			System.schedule('Test',sch,sh );
		Test.stopTest();
	}
}