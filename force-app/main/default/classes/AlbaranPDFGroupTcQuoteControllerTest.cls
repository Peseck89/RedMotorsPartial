@isTest(SeeAllData=false)
public class AlbaranPDFGroupTcQuoteControllerTest {
    @isTest
    public static void testReport(){
        
         ActividadComercial__c act = new ActividadComercial__c();
        act.Name = 'VENTA DE REPUESTOS NUEVOS PARA AUTOMOVIL';
        insert act;
        Pricebook2 pb = new Pricebook2(Name='Dolar2', IsActive=true);
        insert pb;
        
        condicionPago__c condicionPago = new condicionPago__c(condicionPago__c='0',Descripcion__c='test desc', Name='0');
        insert condicionPago;
        
        Impuesto__c Impuesto = new Impuesto__c(codigoImpuesto__c='0108',descripcion__c='test desc',Impuesto__c=2, Name='test imp', porcentaje__c=3);
        insert Impuesto;
        
        Account acc = new Account(Name='Test account', Cedula__c='9876543210', Tipo_de_Documento__c='02', condicionPago__c=condicionPago.Id, Impuesto__c=Impuesto.Id);
       	insert acc;
        
       	Contact co = new Contact(Firstname='Juan Diego',LastName='Espinoza S1', Email='jesp@abc.com', AccountId=acc.Id);
       	insert co;
        
       	Asset asset = new Asset(Name='BMW X6', ContactId=co.Id, AccountId=acc.Id);
       	insert asset;
        
        
  

        Id pricebookId = pb.Id;
        
        CentroCosto__c cc = new CentroCosto__c();
        insert cc;
        
		OperatingHours oh = new OperatingHours(Name = 'Normal');
        insert oh;
        
        ServiceTerritory st = new ServiceTerritory(Name = 'Uruca - Mecánica General', IsActive = true, OperatingHoursId = oh.id);
        insert st;
        Integer iTotReg = 1;
		TestDataFactory.datosGenerales();
        
        TestDataFactory.crearCuentas(iTotReg);
        Campaign campanna;       
        //Crear campaña.
        campanna = new Campaign
        (
            Name='Campaign'
        );
        
        insert campanna;    
        TestDataFactory.crearOportunidades(iTotReg,'Oportunidad Calificada');
        WorkOrder wo = new WorkOrder(subject ='title2', Pricebook2Id=pricebookId, tipoDeGasto__c='Cliente', AssetId=asset.Id,AccountId=acc.Id, ServiceTerritoryId=st.id);
        insert wo;
        Opportunity opp = [Select Id, AccountId From Opportunity LIMIT 1];
        opp.AccountId = acc.Id;
        opp.BMW_TallerDeServicio__c = st.id;
        update opp;
        Test.startTest();
        Quote qo =  new Quote(Name ='testqo',Pricebook2Id=pricebookId,OpportunityId=opp.Id);
        insert qo;
        
        Bodega__c bodega = new Bodega__c(bodega__c = 'BR01', ID_EXTERNO_BODEGA__c = 'BR01', Name = 'BR01');
        insert bodega;
        
        BodegaxTerritorio__c bxt = new BodegaxTerritorio__c(ServiceTerritory__c = st.Id, isPrincipal__c = true, Bodega__c = bodega.Id);
        insert bxt;
        
        //Insert product        
        Product2 prod= new Product2(IsActive=true, Name='Teste product2',tipoProducto__c='Materiales', ProductCode='L00012', Codigo_de_Producto__c='L00012');
        insert prod;
        
        insert new ProductoXBodega__c(Producto__c = prod.Id, Bodega__c = bodega.Id);
        
        Product2 prodMO= new Product2(IsActive=true, Name='Mano de Obra',tipoProducto__c='Mano de Obra', ProductCode='00012', Codigo_de_Producto__c='0012');
        insert prodMO;

        // Insert PricebookEntry
        //Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id =pricebookId, Product2Id = prod.Id, UnitPrice = 2000, IsActive = true);
        insert standardPBE;

        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = qo.Id;
        qli.Quantity = 2;
        qli.PricebookEntryId = standardPBE.Id;
        qli.Product2Id = prod.Id;
        qli.UnitPrice = 1;
        qli.BMW_Bodega__c = bodega.Id;
        insert qli;
        ApexPages.StandardController controller = new ApexPages.StandardController(qo);
        ApexPages.currentPage().getParameters().put('id', qo.Id);
        AlbaranPDFGroupTcQuoteController cntrl = new AlbaranPDFGroupTcQuoteController(controller);
        Test.stopTest();
    }
}