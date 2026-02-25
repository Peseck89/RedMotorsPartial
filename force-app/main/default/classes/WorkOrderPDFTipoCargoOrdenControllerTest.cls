@isTest(SeeAllData=false)
public class WorkOrderPDFTipoCargoOrdenControllerTest {
    @TestSetup
    static void makeData(){    

        ActividadComercial__c actividad = new ActividadComercial__c();
        actividad.Name = 'VENTA DE REPUESTOS NUEVOS PARA AUTOMOVIL';
        insert actividad;

        condicionPago__c condi = new condicionPago__c();
        condi.Name = 'CONTADO';
        condi.condicionPago__c = '0';
        insert condi;

        Impuesto__c im = new Impuesto__c();
        im.codigoImpuesto__c =  '0108';
        insert im;
                
        categoriaCliente__c cet = new categoriaCliente__c();
        cet.categoriaCliente__c = 'COM';
        insert cet;
            

        List<Account> accountList = createAccounts(1,true);
        List<Contact> contactList = createContacts(1,true);
        List<Asset> assetList = createAssets(1,true,accountList[0]);
        List<tiposDeTrabajo__c> tipoTrabajoList = createTipoTrabajo(1, true);
        
        List<Product2> productList = createProducts(1, true);
        List<Pricebook2> priceBookList = createPricebook2(1, true);
        List<PricebookEntry> priceBookEntryList = createPricebookEntries(1, true,priceBookList[0],productList[0]);        
        
        // New
        List<Case> caseList = createCase(1, true, assetList[0]);
        List<tiposDeTrabajoCaso__c> caseWorkTypeList = createCaseWorkType(1, true, caseList[0], tipoTrabajoList[0]);
        
        // Add params Case
        List<WorkOrder> workOrderList = createWorkOrders(1,true,assetList[0],priceBookList[0],caseList[0], accountList[0]);
       
        // Add 
        List<WorkOrderLineItem> workOrderItemsList = createWorkOrderLineItems(1, true,workOrderList[0],priceBookEntryList[0],tipoTrabajoList[0], caseWorkTypeList[0]);

    }

    @IsTest
    static void testReport(){
        Account account = [SELECT Id,Name FROM Account LIMIT 1];
        Contact contact = [SELECT Id,FirstName,LastName FROM Contact LIMIT 1];
        Asset asset = [SELECT Id,Name FROM Asset LIMIT 1];
        WorkOrder workOrder = [SELECT Id,AssetId FROM WorkOrder LIMIT 1];
        tiposDeTrabajo__c tipoTrabajo = [SELECT Id,Name FROM tiposDeTrabajo__c LIMIT 1];
        Product2 product = [SELECT Id,Name,ProductCode,Codigo_de_Producto__c FROM Product2 LIMIT 1];
        WorkOrderLineItem workOrderListItem = [SELECT Id,WorkOrderId FROM WorkOrderLineItem LIMIT 1];
		
        TipoCargo__c tc = new TipoCargo__c(Work_Order_Line_Item__c = workOrderListItem.Id,
                                          tipoCargo__c='1');
        insert tc;
        
        Test.setMock(HttpCalloutMock.class, new WorkOrderPDFTipoCargoOrdenMock());
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(workOrder);
        ApexPages.currentPage().getParameters().put('id', workOrder.Id);
        Test.startTest();
        WorkOrderPDFTipoCargoOrdenController workOrderController = new WorkOrderPDFTipoCargoOrdenController(sc);
        Test.stopTest();

        System.assertNotEquals(null, workOrderController.workOrder, 'El WorkOrder debe haberse cargado en el controlador');
        
        System.debug('@@@@account@@@@'+account);
        System.debug('@@@@contact@@@@'+contact);
        System.debug('@@@@asset@@@@'+asset);
        System.debug('@@@@workOrder@@@@'+workOrder);
        System.debug('@@@@tipoTrabajo@@@@'+tipoTrabajo);
        System.debug('@@@@product@@@@'+product);
        System.debug('@@@@workOrderListItem@@@@'+workOrderListItem);
    }
    
        
        private class WorkOrderPDFTipoCargoOrdenMock implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setBody('{"ok": true}');
        return res;
    }
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

    public static List<WorkOrder> createWorkOrders(Integer numberRecords, Boolean insertDML,Asset vehiculo,Pricebook2 priceBook, Case caso,Account account) {
        List<WorkOrder> newRecordList = new List<WorkOrder>();
        for (Integer i = 1; i<=numberRecords; i++ ) {
            newRecordList.add(new WorkOrder(
                AssetId = vehiculo.Id,
                Pricebook2Id = priceBook.Id,
                CaseId = caso.Id,
                AccountId = account.Id,
                tipoDeGasto__c = 'Cliente'
            ));
        }
        if(insertDML) {
            insert newRecordList;
        }
        return newRecordList;   
    } 
    
    public static List<tiposDeTrabajo__c> createTipoTrabajo(Integer numberRecords, Boolean insertDML) {
        List<tiposDeTrabajo__c> newRecordList = new List<tiposDeTrabajo__c>();
        for (Integer i = 1; i<=numberRecords; i++ ) {
            newRecordList.add(new tiposDeTrabajo__c(
                Name = 'Test Tipo trabajo '+i
            ));
        }
        if(insertDML) {
            insert newRecordList;
        }
        return newRecordList;   
    }

    public static List<tiposDeTrabajoCaso__c> createCaseWorkType(Integer numberRecords, Boolean insertDML, Case caso, tiposDeTrabajo__c workType) {
        List<tiposDeTrabajoCaso__c> newRecordList = new List<tiposDeTrabajoCaso__c>();
        for (Integer i = 1; i<=numberRecords; i++ ) {
            newRecordList.add(new tiposDeTrabajoCaso__c(
                Caso__c = caso.Id,
                Tipotrabajo__c = workType.Id,
                Comment__c = 'Test Tipo trabajo caso'+i
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
        
    public static List<Product2> createProducts(Integer numberRecords, Boolean insertDML) {
        List<Product2> newRecordList = new List<Product2>();
        for (Integer i = 1; i<=numberRecords; i++ ) {
            newRecordList.add(new Product2(
                Name = 'Test Product '+i,
                ProductCode = '750100882000'+i,
                Codigo_de_Producto__c = '750100882000'+i
            ));
        }
        if(insertDML) {
            insert newRecordList;
        }
        return newRecordList;   
    }

    public static List<Pricebook2> createPricebook2(Integer numberRecords, Boolean insertDML) {
        List<Pricebook2> newRecordList = new List<Pricebook2>();
        for (Integer i = 1; i<=numberRecords; i++ ) {
            newRecordList.add(new Pricebook2(
                Name = 'Dolar '+i,
                IsActive = true
            ));
        }        
        if(insertDML) {
            insert newRecordList;
        }
        return newRecordList;   
    }

    public static List<PricebookEntry> createPricebookEntries(Integer numberRecords, Boolean insertDML,Pricebook2 pricebook,Product2 product) {
        List<PricebookEntry> newRecordList = new List<PricebookEntry>();
        for (Integer i = 1; i<=numberRecords; i++ ) {
            newRecordList.add(new PricebookEntry(
                Pricebook2Id = pricebook.Id,
                Product2Id = product.Id,
                UnitPrice =2000,
                IsActive = true
            ));
        }        
        if(insertDML) {
            insert newRecordList;
        }
        return newRecordList;   
    }  

// 1, true,workOrderList[0],priceBookEntryList[0],tipoTrabajoList[0], caseWorkTypeList[0]
    public static List<WorkOrderLineItem> createWorkOrderLineItems(Integer numberRecords, Boolean insertDML,WorkOrder workOrder,PricebookEntry priceBookEntry,tiposDeTrabajo__c tipoTrabajo,tiposDeTrabajoCaso__c caseWorkType) {
        List<WorkOrderLineItem> newRecordList = new List<WorkOrderLineItem>();
        for (Integer i = 1; i<=numberRecords; i++ ) {
            newRecordList.add(new WorkOrderLineItem(
                WorkOrderId = workOrder.Id,
                PricebookEntryId = priceBookEntry.Id,
                description = 'Test '+i,
                tiposDeTrabajo__c = tipoTrabajo.Id,
                TipoTrabajoCaso__c = caseWorkType.Id,
                especificacionesTaller__c = 'Sugerido',
                Quantity = 1
            ));
        }
        if(insertDML) {
            insert newRecordList;
        }
        return newRecordList;   
    } 
}