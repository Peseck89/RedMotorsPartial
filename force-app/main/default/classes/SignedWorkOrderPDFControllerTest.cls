@IsTest
public class SignedWorkOrderPDFControllerTest {
    @TestSetup
    static void setupData() {
        // Crear un WorkOrder de prueba
         ActividadComercial__c actividad = new ActividadComercial__c(Name = 'VENTA DE REPUESTOS NUEVOS PARA AUTOMOVIL');
        insert actividad;
        
        tiposDeTrabajo__c tiposDeTrabajo = new tiposDeTrabajo__c(Name = 'Mantenimiento');
        insert tiposDeTrabajo;
                
        Product2 prod= new Product2();
        prod.IsActive=true;
        prod.Name='Test product Test';
        prod.ProductCode='0001999';
        prod.Codigo_de_Producto__c='00199999';
        insert prod;
        
        List<PricebookEntry> lstPBE = new List<PricebookEntry>();
        Id stdPriceBook =  Test.getStandardPricebookId();
        PricebookEntry pd1 = new PricebookEntry();
        pd1.UnitPrice = 1;
        pd1.CurrencyIsoCode = 'USD';
        pd1.Product2Id = prod.Id;
        pd1.Pricebook2Id = stdPriceBook;
        pd1.IsActive = true;
        lstPBE.add(pd1);
        
        Bodega__c b = new Bodega__c();
        insert b;
        
        ProductoXBodega__c pxb = new ProductoXBodega__c();
        pxb.Producto__c = prod.Id;
        pxb.Bodega__c = b.Id;
        pxb.Disponible__c = 12;
        insert pxb;

        // Insert PricebookEntry
        PricebookEntry standardPBE = [select id, Pricebook2Id, UnitPrice,IsActive,CurrencyIsoCode 
                                      from PricebookEntry 
                                      where Product2Id =:prod.Id 
                                      and CurrencyIsoCode = 'USD'
                                      limit 1];//new PricebookEntry(Pricebook2Id =pricebookId, Product2Id = prod.Id, UnitPrice = 999, IsActive = true);
        System.debug(standardPBE.CurrencyIsoCode);
        
        Pricebook2 pb = new Pricebook2();
        pb.Name='Dolar';
        pb.IsActive=true;
       
        insert pb;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        WorkOrder wo = new WorkOrder();
        wo.subject ='title';
        wo.Pricebook2Id=standardPBE.Pricebook2Id;
        wo.tipoDeGasto__c='Cliente';
        wo.CurrencyIsoCode = 'USD';
        insert wo;
        List<Account> accountList = createAccounts(1,true);
        List<Contact> contactList = createContacts(1,true);
        List<Asset> assetList = createAssets(1,true,accountList[0]);
        List<Case> caseList = createCase(1, true, assetList[0]);

        // Crear una Firma__c relacionada con el WorkOrder
        Firma__c firma = new Firma__c(
            Nombre__c = 'Firma de Prueba',
            Case__c = caseList[0].Id,
            Visualforce__c = 'WorkOrderPresupuestoUsdPDF'
        );
        insert firma;

        // Crear un ContentDocument y ContentVersion para simular una firma almacenada
        ContentVersion cv = new ContentVersion(
            Title = 'Firma de Prueba',
            PathOnClient = 'Firma.png',
            VersionData = Blob.valueOf('Firma de prueba'),
            FirstPublishLocationId = firma.Id
        );
        insert cv;
         
        
    }

    @IsTest
    static void testControllerWithFirma() {
        // Obtener WorkOrder de prueba
        Case caso = [SELECT Id FROM Case LIMIT 1];

        // Simular el controlador con el ID del WorkOrder
        ApexPages.StandardController sc = new ApexPages.StandardController(caso);
        SignedWorkOrderPDFController controller = new SignedWorkOrderPDFController(sc);

        
    }

    @IsTest
    static void testControllerWithoutFirma() {
        // Crear un WorkOrder sin firma asociada
        ActividadComercial__c actividad = new ActividadComercial__c(Name = 'VENTA DE REPUESTOS NUEVOS PARA AUTOMOVIL');
        insert actividad;
        
        tiposDeTrabajo__c tiposDeTrabajo = new tiposDeTrabajo__c(Name = 'Mantenimiento');
        insert tiposDeTrabajo;
                
        Product2 prod= new Product2();
        prod.IsActive=true;
        prod.Name='Test product Test';
        prod.ProductCode='0001999';
        prod.Codigo_de_Producto__c='00199999';
        insert prod;
        
        List<PricebookEntry> lstPBE = new List<PricebookEntry>();
        Id stdPriceBook =  Test.getStandardPricebookId();
        PricebookEntry pd1 = new PricebookEntry();
        pd1.UnitPrice = 1;
        pd1.CurrencyIsoCode = 'USD';
        pd1.Product2Id = prod.Id;
        pd1.Pricebook2Id = stdPriceBook;
        pd1.IsActive = true;
        lstPBE.add(pd1);
        
        Bodega__c b = new Bodega__c();
        insert b;
        
        ProductoXBodega__c pxb = new ProductoXBodega__c();
        pxb.Producto__c = prod.Id;
        pxb.Bodega__c = b.Id;
        pxb.Disponible__c = 12;
        insert pxb;

        // Insert PricebookEntry
        PricebookEntry standardPBE = [select id, Pricebook2Id, UnitPrice,IsActive,CurrencyIsoCode 
                                      from PricebookEntry 
                                      where Product2Id =:prod.Id 
                                      and CurrencyIsoCode = 'USD'
                                      limit 1];//new PricebookEntry(Pricebook2Id =pricebookId, Product2Id = prod.Id, UnitPrice = 999, IsActive = true);
        System.debug(standardPBE.CurrencyIsoCode);
        
        Pricebook2 pb = new Pricebook2();
        pb.Name='Dolar';
        pb.IsActive=true;
       
        insert pb;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        WorkOrder wo = new WorkOrder();
        wo.subject ='title';
        wo.Pricebook2Id=standardPBE.Pricebook2Id;
        wo.tipoDeGasto__c='Cliente';
        wo.CurrencyIsoCode = 'USD';
        insert wo;
		        Case caso = [SELECT Id FROM Case LIMIT 1];

        // Simular el controlador con el ID del nuevo WorkOrder
        ApexPages.StandardController sc = new ApexPages.StandardController(caso);
        SignedWorkOrderPDFController controller = new SignedWorkOrderPDFController(sc);

    }
    public static List<Contact> createContacts(Integer numberRecords, Boolean insertDML) {
        List<Contact> newRecordList = new List<Contact>();
        for (Integer i = 1; i<=numberRecords; i++ ) {
            newRecordList.add(new Contact(                
                FirstName = 'Test First Name '+i,
                LastName = 'Test LastM Name '+i                
            ));
        }
        if(insertDML) {
            insert newRecordList;
        }
        return newRecordList;   
    }    

    public static List<Asset> createAssets(Integer numberRecords, Boolean insertDML,Account account){
        List<Asset> newRecordList = new List<Asset>();
        for (Integer i = 1; i<=numberRecords; i++ ) {
            newRecordList.add(new Asset(
                Name = 'Test Car '+i,
                AccountId = account.Id                
            ));
        }
        if(insertDML) {
            insert newRecordList;
        }
        return newRecordList;   
    } 
	public static List<Account> createAccounts(Integer numberRecords, Boolean insertDML) {
        List<Account> newRecordList = new List<Account>();
        for (Integer i = 1; i<=numberRecords; i++ ) {
            newRecordList.add(new Account(
                Name = 'Test Acc '+i
            ));
        }
        if(insertDML) {
            insert newRecordList;
        }
        return newRecordList;   
    }
    public static List<Case> createCase(Integer numberRecords, Boolean insertDML, Asset vehiculo) {
        List<Case> newRecordList = new List<Case>();
        for (Integer i = 1; i<=numberRecords; i++ ) {
            newRecordList.add(new Case(
                Create_Orders_from_Workorders__c = true,
                AssetId = vehiculo.Id
            ));
        }
        if(insertDML) {
            insert newRecordList;
        }
        return newRecordList;  
    }  
}