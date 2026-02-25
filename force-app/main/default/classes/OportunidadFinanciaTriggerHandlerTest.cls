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
private class OportunidadFinanciaTriggerHandlerTest {

	static Integer iTo = 1;
    static {
        TestDataFactory.datosGenerales();
    } 
    
    static testMethod void myUnitTest() {

        Account acct = new Account();
        acct.FirstName = 'Test1';
        acct.LastName = 'Test1';
        acct.Tipo_de_Documento__c = 'Cedula';
        acct.Cedula__c = '402080760';
        acct.PersonMobilePhone = '+50688553311';
        insert acct;
        
        system.assertEquals([select FirstName from Account where id =: acct.id].FirstName ,'Test1');
        
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
        
        system.assertEquals([select id from PricebookEntry where id =: pbe.id].id ,pbe.id);  
        
        Test.startTest();
            Opportunity op = new Opportunity();
            op.Name = 'Prueba';
            op.Campana__c = TestDataFactory.campanna.Id;
            op.Sucursal__c = 'Pavas';
            op.AccountId = acct.Id;
            op.CloseDate = System.today() + 5;
            op.StageName = 'Test Drive';
            op.UltimaModificacion__c = (System.today()+10) - 3;
            op.Pricebook2Id = pb2.Id;
            op.EnvioAlertaOF__c = false;
            op.Consentimientofinaciero__c = false;
            op.OwnerId = UserInfo.getUserId();
            op.MonedaIngreso__c = SObjectType.Opportunity.Fields.MonedaIngreso__c.PicklistValues[1].getValue(); //Dólares
            op.IngresoAproximado__c = 1500;
			op.RT_Lead__c = 'BMW';
            insert op;
            
            system.assertEquals([select Sucursal__c from Opportunity where id =: op.id].Sucursal__c,'Pavas');
         
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
            
            system.assertEquals([select Preciodefacturacion__c from OpportunityLineItem where id =: lineItem.id].Preciodefacturacion__c,220000);  
            
            op.Consentimientofinaciero__c = true;
            update op;
            
            system.assertEquals([select Consentimientofinaciero__c from Opportunity where id =: op.id].Consentimientofinaciero__c, true);
            system.assertEquals([select OpportunityId from OpportunityLineItem where OpportunityId =: op.id].OpportunityId, op.id);        
            system.assertEquals([select MonedaIngreso__c from Opportunity where id =: op.id].MonedaIngreso__c, SObjectType.Opportunity.Fields.MonedaIngreso__c.PicklistValues[1].getValue());  
            system.assertEquals([select IngresoAproximado__c from Opportunity where id =: op.id].IngresoAproximado__c, 1500); 
            system.assertEquals([select COUNT() from Oportunidad_de_Financiamiento__c where Oportunidad__c =: op.id],1);
            system.assertEquals([select Oportunidad__c from Oportunidad_de_Financiamiento__c where Oportunidad__c =: op.id].Oportunidad__c, op.id);
            
            list<Oportunidad_de_Financiamiento__c> opF = [SELECT Name, Id, Oportunidad__c, Estado__c FROM Oportunidad_de_Financiamiento__c WHERE Oportunidad__c =: op.Id];
            System.debug('******************** OF ******************* ' + opF[0].Name);
            opF[0].Estado__c = 'Aprobada';
            opF[0].ComentariosAltica__c = 'Prueba Prueba Prueba';
            update opF;
            
            system.assertEquals([select Estado__c from Oportunidad_de_Financiamiento__c where Oportunidad__c=:op.id].Estado__c,'Aprobada');
            
			opF[0].Prima_Altica__c = 5000;
            update opF;

            delete opF;
            
            system.assertEquals([select COUNT() from Oportunidad_de_Financiamiento__c where Oportunidad__c=:op.id],0);
            
        Test.stopTest();        
        
    }

	//Metodo para hacer test de alerta cuando se le va a aprobar o condicionar una opF y este cliente ya posee una opF aprobada
	static testMethod void opFVarias() {
		Oportunidad_de_Financiamiento__c opF1 = new Oportunidad_de_Financiamiento__c();

		TestDataFactory.crearCuentasAltica(iTo);
		TestDataFactory.crearOpFAltica(iTo);
		opF1 = TestDataFactory.MapOpF.get(0);
		opF1.Estado__c = 'Aprobada';
		update opF1;

		Test.startTest();
			Oportunidad_de_Financiamiento__c opF2 = new Oportunidad_de_Financiamiento__c();
			opF2.Campana_Altica__c = TestDataFactory.campannaAltica.Id;
			opF2.FechaInicioOF__c = System.now();
			opF2.Nombre_Cliente_Altica__c = TestDataFactory.MapCuentasAltica.get(0).Id;
			insert opF2;

			//Se actualiza el estado de la segunda opF
			try{
				opF2.Estado__c = 'Aprobada';
				update opF2;
			}catch(Exception e){
				Boolean expectedExceptionThrown = e.getMessage().contains('El cliente tiene una o mas oportunidades de  financiamiento aprobadas') ? true : false;
				System.assertEquals(expectedExceptionThrown, true);
			}

		Test.stopTest();
	}

	//Metodo para hacer test para el conteo de opF relacionadas con campanas
	static  testMethod void testConteoAltica(){
		List<Oportunidad_de_Financiamiento__c> listOpF = new List<Oportunidad_de_Financiamiento__c>();
		
		TestDataFactory.crearCuentasAltica(2);
		TestDataFactory.crearOpFAltica(2);
		listOpF = TestDataFactory.MapOpF.values();

		Test.startTest();
			
			listOpF[0].Estado__c = 'Condicionada';
			listOpF[0].ComentariosAltica__c = 'Prueba';
			listOpF[1].Estado__c = 'Condicionada';
			listOpF[1].ComentariosAltica__c = 'Prueba';
			update listOpF;

			listOpF[0].Estado__c = 'Aprobada';
			listOpF[1].Estado__c = 'Aprobada';
			update listOpF;

			listOpF[0].Estado__c = 'Denegado';
			listOpF[0].Observaciones__c = 'Prueba';
			listOpF[1].Estado__c = 'Denegado';
			listOpF[1].Observaciones__c = 'Prueba';
			update listOpF;

			listOpF[0].Estado__c = 'Condicionada';
			listOpF[1].Estado__c = 'Condicionada';
			update listOpF;

		Test.stopTest();
	}

	//Metodo para hacer test para el conteo de opF relacionadas con campanas
	static  testMethod void testConteoRedMotors(){
		List<Opportunity> listOp = new List<Opportunity>();
		Set<String> setIds = new Set<String>();
		List<Oportunidad_de_Financiamiento__c> listOpF = new List<Oportunidad_de_Financiamiento__c>();
        
        TestDataFactory.createProducts(2);
        TestDataFactory.createPriceBookEntries(2, Test.getStandardPricebookId());
        TestDataFactory.crearCuentas(2);
        TestDataFactory.crearOportunidades(2,'Oportunidad Calificada');
        TestDataFactory.crearProductosOP(2);
		
		Test.startTest();
			listOp = TestDataFactory.MapOportunidades.values();

			listOp[0].Consentimientofinaciero__c = true;
			listOp[1].Consentimientofinaciero__c = true;
			setIds.add(listOp[0].Id);
			setIds.add(listOp[1].Id);
			update listOp;

			listOpF = [SELECT Id, Estado__c FROM Oportunidad_de_Financiamiento__c WHERE Oportunidad__c IN : setIds];
            System.debug('******************** OF ******************* ' + listOpF);

			listOpF[0].Estado__c = 'Condicionada';
			listOpF[0].ComentariosAltica__c = 'Prueba';
			listOpF[1].Estado__c = 'Condicionada';
			listOpF[1].ComentariosAltica__c = 'Prueba';
			update listOpF;

			listOpF[0].Estado__c = 'Aprobada';
			listOpF[1].Estado__c = 'Aprobada';
			update listOpF;

			listOpF[0].Estado__c = 'Denegado';
			listOpF[0].Observaciones__c = 'Prueba';
			listOpF[1].Estado__c = 'Denegado';
			listOpF[1].Observaciones__c = 'Prueba';
			update listOpF;

			listOpF[0].Estado__c = 'Condicionada';
			listOpF[1].Estado__c = 'Condicionada';
			update listOpF;

		Test.stopTest();
	}
}