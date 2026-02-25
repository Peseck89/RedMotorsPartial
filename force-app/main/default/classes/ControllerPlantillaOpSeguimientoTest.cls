/**
    @Autor: David Leon Sanchez
    @Fecha creacion: 18/08/2017 
    @Proyecto: Altica
    @Proposito: Clase test para el funcionamiento de la clase llamada ControllerPlantillaOpSeguimiento

**/

@isTest
private class ControllerPlantillaOpSeguimientoTest {

    static{
        TestDataFactory.datosGenerales();
    }

    @isTest
    private static void test1() {
        
        Account acct = new Account();
        acct.FirstName = 'Test';
        acct.LastName = 'Test';
        acct.Tipo_de_Documento__c = 'Cedula';
        acct.Cedula__c = '402080760';
        acct.PersonMobilePhone = '+50688553311';
        insert acct;
        
        system.assertEquals([select FirstName from Account where id=:acct.id].FirstName ,'Test');
        
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
        
        system.assertEquals([select id from PricebookEntry where id=:pbe.id].id ,pbe.id);        
        
        Opportunity op = new Opportunity();
        op.Name = 'Prueba';
        op.Campana__c = TestDataFactory.campanna.Id;
        op.Sucursal__c = 'Pavas';
        op.AccountId = acct.Id;
        op.CloseDate = System.today() + 5;
        op.StageName = 'Test Drive';
        op.UltimaModificacion__c = (System.today()+10) - 3;
        op.Pricebook2Id = pb2.Id;
        op.Consentimientofinaciero__c = true;
        op.EnvioAlertaOF__c = false;
        op.OwnerId = UserInfo.getUserId();
        op.MonedaIngreso__c = SObjectType.Opportunity.Fields.MonedaIngreso__c.PicklistValues[1].getValue(); //Dólares
        op.IngresoAproximado__c = 1500;
		op.RT_Lead__c = 'BMW';
        insert op;
        
        system.assertEquals([select Sucursal__c from Opportunity where id=:op.id].Sucursal__c,'Pavas');        
         
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
        
        system.assertEquals([select Preciodefacturacion__c from OpportunityLineItem where id=:lineItem.id].Preciodefacturacion__c,220000);
        system.assertEquals([select Consentimientofinaciero__c from Opportunity where id=:op.id].Consentimientofinaciero__c,true);
        system.assertEquals([select MonedaIngreso__c from Opportunity where id =: op.id].MonedaIngreso__c, SObjectType.Opportunity.Fields.MonedaIngreso__c.PicklistValues[1].getValue());  
        system.assertEquals([select IngresoAproximado__c from Opportunity where id =: op.id].IngresoAproximado__c, 1500);         
        system.assertEquals([select OpportunityId from OpportunityLineItem where OpportunityId =:op.id].OpportunityId,op.id);
        system.assertEquals([select Oportunidad__c from Oportunidad_de_Financiamiento__c where Oportunidad__c =: op.id].Oportunidad__c, op.id);  
        
        list<Oportunidad_de_Financiamiento__c> opsFinanciamiento = new list<Oportunidad_de_Financiamiento__c>();
        
        for(Oportunidad_de_Financiamiento__c opF : [SELECT Id, Oportunidad__c, Estado__c FROM Oportunidad_de_Financiamiento__c WHERE Oportunidad__c =: op.Id]){
            opF.Estado__c = 'Aprobada';
            opsFinanciamiento.add(opF);
            //update opF;
            //System.debug('*********************** OporFinan *********************** ' + opF + '**' + opF.Oportunidad__c);
        }
        update opsFinanciamiento;
        
        Test.startTest();
            
            ControllerPlantillaOpSeguimiento cont = new ControllerPlantillaOpSeguimiento();
            Map<String, List<ControllerPlantillaOpSeguimiento.opsSegApro>> mapa = cont.MapOpSegu;
            
        Test.stopTest();
    }

    //Test que comprueba con un Owner que tenga mas de una Oportunidad
    @isTest
    private static void test2() {
        
        list<String> ops = new list<string>();

        Account acct = new Account();
        acct.FirstName = 'Test';
        acct.LastName = 'Test';
        acct.Tipo_de_Documento__c = 'Cedula';
        acct.Cedula__c = '402080760';
        acct.PersonMobilePhone = '+50688553311';
        insert acct;
        system.assertEquals([select FirstName from Account where id=:acct.id].FirstName ,'Test');        

        Account acct2 = new Account();
        acct2.FirstName = 'Test1';
        acct2.LastName = 'Test1';
        acct2.Tipo_de_Documento__c = 'Cedula';
        acct2.Cedula__c = '112233445';
        acct2.PersonMobilePhone = '+50688353311';
        insert acct2;
        system.assertEquals([select FirstName from Account where id=:acct2.id].FirstName ,'Test1');

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
        
        system.assertEquals([select id from PricebookEntry where id=:pbe.id].id,pbe.id);
        
        Opportunity op1 = new Opportunity();
        op1.Name = 'Prueba';
        op1.Campana__c = TestDataFactory.campanna.Id;
        op1.Sucursal__c = 'Pavas';
        op1.AccountId = acct.Id;
        op1.CloseDate = System.today() + 5;
        op1.StageName = 'Test Drive';
        op1.UltimaModificacion__c = System.today() - 3;
        op1.Pricebook2Id = pb2.Id;
        op1.EnvioAlertaOF__c = false;
        op1.OwnerId = UserInfo.getUserId();
        op1.MonedaIngreso__c = SObjectType.Opportunity.Fields.MonedaIngreso__c.PicklistValues[1].getValue(); //Dólares
        op1.IngresoAproximado__c = 1500;
		op1.RT_Lead__c = 'BMW';
        insert op1; 
        ops.add(op1.id);
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem();
        lineItem1.Preciodefacturacion__c = 220000;
        lineItem1.OpportunityId = op1.Id;
        lineItem1.Marca__c = prod.Marca__c;
        lineItem1.Modelo_De_Inter_s1__c = prod.Modelo_De_Inter_s__c;
        lineItem1.Familia1__c = prod.Familia__c;
        lineItem1.Quantity = 1;
        lineItem1.PricebookEntryId = pbe.Id;
        lineItem1.TotalPrice = 225000;
        insert lineItem1;
        
        op1.Consentimientofinaciero__c = true;
        update op1;       
        
        system.assertEquals([select Consentimientofinaciero__c from Opportunity where id=:op1.id].Consentimientofinaciero__c,true);
        system.assertEquals([select MonedaIngreso__c from Opportunity where id =: op1.id].MonedaIngreso__c, SObjectType.Opportunity.Fields.MonedaIngreso__c.PicklistValues[1].getValue());  
        system.assertEquals([select IngresoAproximado__c from Opportunity where id =: op1.id].IngresoAproximado__c, 1500); 
        system.assertEquals([select OpportunityId from OpportunityLineItem where OpportunityId =:op1.id].OpportunityId,op1.id);     
        system.assertEquals([select Oportunidad__c from Oportunidad_de_Financiamiento__c where Oportunidad__c =: op1.id].Oportunidad__c, op1.id);        

        Opportunity op2 = new Opportunity();
        op2.Name = 'Prueba 2';
        op2.Campana__c = TestDataFactory.campanna.Id;
        op2.Sucursal__c = 'Pavas';
        op2.AccountId = acct2.Id;
        op2.CloseDate = System.today() + 5;
        op2.StageName = 'Test Drive';
        op2.UltimaModificacion__c = System.today() - 3;
        op2.Pricebook2Id = pb2.Id;
        op2.EnvioAlertaOF__c = false;
        op2.OwnerId = UserInfo.getUserId();
        op2.MonedaIngreso__c = SObjectType.Opportunity.Fields.MonedaIngreso__c.PicklistValues[1].getValue(); //Dólares
        op2.IngresoAproximado__c = 1500;
		op2.RT_Lead__c = 'BMW';
        insert op2; 
        ops.add(op2.id);

        OpportunityLineItem lineItem2 = new OpportunityLineItem();
        lineItem2.Preciodefacturacion__c = 220000;
        lineItem2.OpportunityId = op2.Id;
        lineItem2.Marca__c = prod.Marca__c;
        lineItem2.Modelo_De_Inter_s1__c = prod.Modelo_De_Inter_s__c;
        lineItem2.Familia1__c = prod.Familia__c;
        lineItem2.Quantity = 1;
        lineItem2.PricebookEntryId = pbe.Id;
        lineItem2.TotalPrice = 225000;
        insert lineItem2;            

        op2.Consentimientofinaciero__c = true;
        update op2;
            
        system.debug('ops ids ******  ' + ops);
        
        system.assertEquals([select Consentimientofinaciero__c from Opportunity where id=:op2.id].Consentimientofinaciero__c,true);
        system.assertEquals([select MonedaIngreso__c from Opportunity where id =: op2.id].MonedaIngreso__c, SObjectType.Opportunity.Fields.MonedaIngreso__c.PicklistValues[1].getValue());  
        system.assertEquals([select IngresoAproximado__c from Opportunity where id =: op2.id].IngresoAproximado__c, 1500);         
        system.assertEquals([select OpportunityId from OpportunityLineItem where OpportunityId =:op2.id].OpportunityId,op2.id);
        system.assertEquals([select Oportunidad__c from Oportunidad_de_Financiamiento__c where Oportunidad__c =: op2.id].Oportunidad__c, op2.id);
        
        Integer i= 1;
        list<Oportunidad_de_Financiamiento__c> opFinanciamiento= new list<Oportunidad_de_Financiamiento__c>();
        for(Oportunidad_de_Financiamiento__c opF : [SELECT Id, Estado__c FROM Oportunidad_de_Financiamiento__c WHERE Oportunidad__c IN:ops ]){
            System.debug('*********************** OporFinan *********************** ' + i + ' | -> '+ opF);
            opF.Estado__c = 'Aprobada';
            opFinanciamiento.add(opF);
            //update opF;
            i++;
        }
        update opFinanciamiento;
        
        Test.startTest();
         
            ControllerPlantillaOpSeguimiento cont = new ControllerPlantillaOpSeguimiento();
            Map<String, List<ControllerPlantillaOpSeguimiento.opsSegApro>> mapa = cont.MapOpSegu;
            
        Test.stopTest();
    }
    
}