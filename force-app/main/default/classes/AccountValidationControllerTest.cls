@isTest
public class AccountValidationControllerTest {
	static testMethod void AccountValidationControllerTest() {
       		
        ActividadComercial__c act = new ActividadComercial__c();
        act.Name = 'VENTA DE REPUESTOS NUEVOS PARA AUTOMOVIL';
        insert act;
        Pricebook2 pb = new Pricebook2(Name='Dolar2', IsActive=true);
        insert pb;
        
        condicionPago__c condicionPago = new condicionPago__c(condicionPago__c='0',Descripcion__c='test desc', Name='0');
        insert condicionPago;
        
        Impuesto__c Impuesto = new Impuesto__c(codigoImpuesto__c='0108',descripcion__c='test desc',Impuesto__c=2, Name='test imp', porcentaje__c=3);
        insert Impuesto;
        
        Account acc = new Account(Name='Test account', Cedula__c='9876543210', Tipo_de_Documento__c='02', condicionPago__c=condicionPago.Id, Impuesto__c=Impuesto.Id,codigoSoftland__c='C0399232');
       	insert acc;
        
       	Contact co = new Contact(Firstname='Juan Diego',LastName='Espinoza S1', Email='jesp@abc.com', AccountId=acc.Id);
       	insert co;
        
       	Asset asset = new Asset(Name='BMW X6', ContactId=co.Id, AccountId=acc.Id);
       	insert asset;
        
        
  

        Id pricebookId = pb.Id;
        
        CentroCosto__c cc = new CentroCosto__c();
        insert cc;
        
        WorkOrder wo = new WorkOrder(subject ='title2', Pricebook2Id=pricebookId, tipoDeGasto__c='Cliente', AssetId=asset.Id,AccountId=acc.Id);
        insert wo;
        
        WorkOrder tmp = [Select PriceBook2Id from WorkOrder Where Id = :wo.id];
        //system.assertEquals(pricebookId,tmp.PriceBook2Id,'The workorder price book was modified after it was inserted');

        //Insert product        
        Product2 prod= new Product2(IsActive=true, Name='Test product2', ProductCode='00012', Codigo_de_Producto__c='0012');
        insert prod;
        
        Product2 prodMO= new Product2(IsActive=true, Name='Mano de Obra',tipoProducto__c='Mano de Obra', ProductCode='00012', Codigo_de_Producto__c='0012');
        insert prodMO;

        // Insert PricebookEntry

        //Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id =pricebookId, Product2Id = prod.Id, UnitPrice = 2000, IsActive = true);
        insert standardPBE;
        
       

        WorkOrderLineItem woli = new WorkOrderLineItem(workOrderId = wo.Id, description = 'abcd2', Quantity=2, PricebookEntryId=standardPBE.Id, centroCosto__c = cc.Id,Product__c=prod.Id);        
        insert woli;
        
        tiposDeTrabajo__c tipotraba = new tiposDeTrabajo__c(Name='Mantenimiento');
        insert tipotraba;
        
        wo.Etapa_de_flujo_de_trabajo__c='Aprobación de presupuesto';
        wo.AccountId=acc.Id;
        wo.ActividadComercial__c = act.Id;
        wo.Tipo_de_Cargo__c = 'x';
        //update wo;
        
        ProductConsumed pc = new ProductConsumed(WorkorderId = wo.Id,PriceBookEntryId = standardPBE.Id,QuantityConsumed = 1);
        insert pc;
        
        Case Caso = new Case();
        Caso.Description='TEst';
        Caso.Subject = 'Test';
        Caso.AccountId=acc.Id;
        insert Caso;

        Sucursal__c sucursal = new Sucursal__c(
            Name='Pavas',
            DirectordeVentasBMW__c = UserInfo.getUserId(),
            GerentedeSucursalBMW__c = UserInfo.getUserId(),
            JefeseSucursalBMW__c = UserInfo.getUserId()
        );
        insert sucursal;

        Campaign camp = new Campaign(Name = 'test campaing', 
                                     IsActive = true, 
                                     RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Campaña Red Motors').getRecordTypeId());
        insert camp;
        
        Opportunity opp = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId(),
            AccountId = acc.id,
            CloseDate = System.today().AddMonths(3),
            StageName = 'Oportunidad Calificada',
            Campana__c = camp.Id,
            Sucursal__c = sucursal.Name,
            RT_Lead__c = 'BMW'
        ); 
        insert opp;

        Test.startTest();
        AccountValidationController.updateOnlyId(acc.Cedula__c,'02',acc.id);
        AccountValidationController.accountValidation(Caso.id);
        AccountValidationController.getContact(Caso.id);
        AccountValidationController.accountValidationByOpportunity(opp.Id);
        AccountValidationController.getSoftlandAccount(acc.Id);
        AccountValidationController.updateSoftlandAccount('{ "cliente": "C116571", "email": "poland@poland.hom", "email_doc_electronico": "poland@poland.hom", "ID": "'+acc.Id+'", "telefono1": "8989898989", "telefono2": "8989898989" }');
        Test.stopTest();
        


    }
}