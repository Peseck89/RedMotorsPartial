@isTest
public class BMW_ChangeCurrencyWOWOLITest {
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
        List<Pricebook2> priceBookList = createPricebook2(2, true);
        List<PricebookEntry> priceBookEntryList = createPricebookEntries(1, true,priceBookList[0],productList[0]);        
        createPricebookEntries(1, true,priceBookList[1],productList[0]);
        
        // New
        List<Case> caseList = createCase(1, true, assetList[0]);
        List<tiposDeTrabajoCaso__c> caseWorkTypeList = createCaseWorkType(1, true, caseList[0], tipoTrabajoList[0]);
        
        // Add params Case
        List<WorkOrder> workOrderList = createWorkOrders(1,true,assetList[0],priceBookList[0],caseList[0], accountList[0]);
       
        // Add 
        List<WorkOrderLineItem> workOrderItemsList = createWorkOrderLineItems(1, true,workOrderList[0],priceBookEntryList[0],tipoTrabajoList[0], caseWorkTypeList[0]);

    }

    @IsTest
    static void testPrincipal(){
        Account account = [SELECT Id,Name FROM Account LIMIT 1];
        Contact contact = [SELECT Id,FirstName,LastName FROM Contact LIMIT 1];
        Asset asset = [SELECT Id,Name FROM Asset LIMIT 1];
        WorkOrder workOrder = [SELECT Id,AssetId,Pricebook2Id,CurrencyIsoCode FROM WorkOrder LIMIT 1];
        tiposDeTrabajo__c tipoTrabajo = [SELECT Id,Name FROM tiposDeTrabajo__c LIMIT 1];
        Product2 product = [SELECT Id,Name,ProductCode,Codigo_de_Producto__c FROM Product2 LIMIT 1];
        WorkOrderLineItem workOrderListItem = [SELECT Id,WorkOrderId FROM WorkOrderLineItem LIMIT 1];


        ApexPages.StandardController sc = new ApexPages.StandardController(workOrder);
        ApexPages.currentPage().getParameters().put('id', workOrder.Id);
        test.startTest();
            BMW_ChangeCurrencyWOWOLI workOrderController = new BMW_ChangeCurrencyWOWOLI(sc);
        	workOrderController.ot.Pricebook2Id = workOrder.Pricebook2Id;
        	workOrderController.ot.CurrencyIsoCode = workOrder.CurrencyIsoCode;
            workOrderController.changeCurrency();        
        test.stopTest();

        WorkOrder convertedWorkOrder = [
            SELECT Pricebook2.Name, CurrencyIsoCode
            FROM WorkOrder
            WHERE Id = :workOrder.Id
        ];
        System.assertEquals('Bavarian Dólar', convertedWorkOrder.Pricebook2.Name);
        System.assertEquals('USD', convertedWorkOrder.CurrencyIsoCode);
        System.assertEquals(
            1,
            [SELECT COUNT() FROM WorkOrderLineItem WHERE WorkOrderId = :workOrder.Id],
            'La conversión debe conservar la cantidad actual de líneas.'
        );
    }

    @IsTest
    static void convertsBavarianLocalToBavarianDolar() {
        BMW_ChangeCurrencyWOWOLI controller = prepareConversion(
            'Bavarian Local',
            'Bavarian Dólar',
            'CRC'
        );

        Test.startTest();
        controller.changeCurrency();
        Test.stopTest();

        assertConversionResult(controller, 'Bavarian Dólar', 'USD');
    }

    @IsTest
    static void convertsBavarianDolarToBavarianLocal() {
        BMW_ChangeCurrencyWOWOLI controller = prepareConversion(
            'Bavarian Dólar',
            'Bavarian Local',
            'USD'
        );

        Test.startTest();
        controller.changeCurrency();
        Test.stopTest();

        assertConversionResult(controller, 'Bavarian Local', 'CRC');
    }

    @IsTest
    static void convertsOtobaiLocalToOtobaiDolares() {
        BMW_ChangeCurrencyWOWOLI controller = prepareConversion(
            'Otobai Local',
            'Otobai Dólares',
            'CRC'
        );

        Test.startTest();
        controller.changeCurrency();
        Test.stopTest();

        assertConversionResult(controller, 'Otobai Dólares', 'USD');
    }

    @IsTest
    static void convertsOtobaiDolaresToOtobaiLocal() {
        BMW_ChangeCurrencyWOWOLI controller = prepareConversion(
            'Otobai Dólares',
            'Otobai Local',
            'USD'
        );

        Test.startTest();
        controller.changeCurrency();
        Test.stopTest();

        assertConversionResult(controller, 'Otobai Local', 'CRC');
    }

    @IsTest
    static void convertsPekingLocalToPekingDolares() {
        BMW_ChangeCurrencyWOWOLI controller = prepareConversion(
            'PEKING Local',
            'PEKING Dólares',
            'CRC'
        );

        Test.startTest();
        controller.changeCurrency();
        Test.stopTest();

        assertConversionResult(controller, 'PEKING Dólares', 'USD');
    }

    @IsTest
    static void convertsPekingDolaresToPekingLocal() {
        BMW_ChangeCurrencyWOWOLI controller = prepareConversion(
            'PEKING Dólares',
            'PEKING Local',
            'USD'
        );

        Test.startTest();
        controller.changeCurrency();
        Test.stopTest();

        assertConversionResult(controller, 'PEKING Local', 'CRC');
    }

    @IsTest
    static void rejectsUnknownPricebookWithoutFallback() {
        Pricebook2 unknownPricebook = ensurePricebook('Pricebook Desconocido');
        WorkOrder workOrder = createWorkOrderForConversion(unknownPricebook.Id, 'CRC');

        AuraHandledException caughtException;
        Test.startTest();
        try {
            createController(workOrder).changeCurrency();
        } catch (AuraHandledException exceptionValue) {
            caughtException = exceptionValue;
        }
        Test.stopTest();

        System.assertNotEquals(null, caughtException);
        System.assert(
            caughtException.getMessage().contains('no está autorizado'),
            caughtException.getMessage()
        );
        WorkOrder unchangedWorkOrder = [
            SELECT Pricebook2Id, CurrencyIsoCode
            FROM WorkOrder
            WHERE Id = :workOrder.Id
        ];
        System.assertEquals(unknownPricebook.Id, unchangedWorkOrder.Pricebook2Id);
        System.assertEquals('CRC', unchangedWorkOrder.CurrencyIsoCode);
    }

    @IsTest
    static void rejectsNullPricebookBeforeChangingWorkOrder() {
        Pricebook2 sourcePricebook = [
            SELECT Id
            FROM Pricebook2
            WHERE Name = 'Bavarian Local'
            LIMIT 1
        ];
        WorkOrder workOrder = createWorkOrderForConversion(sourcePricebook.Id, 'CRC');
        BMW_ChangeCurrencyWOWOLI controller = createController(workOrder);
        controller.ot.Pricebook2Id = null;

        AuraHandledException caughtException;
        Test.startTest();
        try {
            controller.changeCurrency();
        } catch (AuraHandledException exceptionValue) {
            caughtException = exceptionValue;
        }
        Test.stopTest();

        System.assertNotEquals(null, caughtException);
        System.assert(
            caughtException.getMessage().contains('no tiene un Pricebook'),
            caughtException.getMessage()
        );
    }

    @IsTest
    static void rejectsMissingOrAmbiguousTargetPricebook() {
        Pricebook2 otobaiLocal = ensurePricebook('Otobai Local');
        WorkOrder missingTargetWorkOrder = createWorkOrderForConversion(otobaiLocal.Id, 'CRC');

        AuraHandledException missingException;
        try {
            createController(missingTargetWorkOrder).changeCurrency();
        } catch (AuraHandledException exceptionValue) {
            missingException = exceptionValue;
        }
        System.assertNotEquals(null, missingException);
        System.assert(missingException.getMessage().contains('No existe un Pricebook'));

        insert new Pricebook2(Name = 'Bavarian Dólar', IsActive = true);
        Pricebook2 bavarianLocal = [
            SELECT Id
            FROM Pricebook2
            WHERE Name = 'Bavarian Local'
            LIMIT 1
        ];
        WorkOrder ambiguousTargetWorkOrder = createWorkOrderForConversion(
            bavarianLocal.Id,
            'CRC'
        );

        AuraHandledException ambiguousException;
        try {
            createController(ambiguousTargetWorkOrder).changeCurrency();
        } catch (AuraHandledException exceptionValue) {
            ambiguousException = exceptionValue;
        }
        System.assertNotEquals(null, ambiguousException);
        System.assert(ambiguousException.getMessage().contains('más de un Pricebook'));
    }

    private static BMW_ChangeCurrencyWOWOLI prepareConversion(
        String sourceName,
        String targetName,
        String sourceCurrency
    ) {
        Pricebook2 sourcePricebook = ensurePricebook(sourceName);
        ensurePricebook(targetName);
        WorkOrder workOrder = createWorkOrderForConversion(
            sourcePricebook.Id,
            sourceCurrency
        );
        return createController(workOrder);
    }

    private static void assertConversionResult(
        BMW_ChangeCurrencyWOWOLI controller,
        String targetName,
        String targetCurrency
    ) {
        System.assertEquals(
            targetName,
            [SELECT Name FROM Pricebook2 WHERE Id = :controller.ot.Pricebook2Id].Name
        );
        System.assertEquals(targetCurrency, controller.ot.CurrencyIsoCode);
    }

    private static BMW_ChangeCurrencyWOWOLI createController(WorkOrder workOrder) {
        ApexPages.StandardController standardController =
            new ApexPages.StandardController(workOrder);
        BMW_ChangeCurrencyWOWOLI controller =
            new BMW_ChangeCurrencyWOWOLI(standardController);
        controller.ot.Pricebook2Id = workOrder.Pricebook2Id;
        controller.ot.CurrencyIsoCode = workOrder.CurrencyIsoCode;
        return controller;
    }

    private static WorkOrder createWorkOrderForConversion(
        Id pricebookId,
        String currencyIsoCode
    ) {
        WorkOrder workOrder = new WorkOrder(
            Subject = 'Conversión de Pricebook',
            Pricebook2Id = pricebookId,
            CurrencyIsoCode = currencyIsoCode
        );
        insert workOrder;
        return workOrder;
    }

    private static Pricebook2 ensurePricebook(String name) {
        List<Pricebook2> existingPricebooks = [
            SELECT Id, Name
            FROM Pricebook2
            WHERE Name = :name
            LIMIT 1
        ];
        if (!existingPricebooks.isEmpty()) {
            return existingPricebooks[0];
        }
        Pricebook2 pricebook = new Pricebook2(Name = name, IsActive = true);
        insert pricebook;
        return pricebook;
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
                CurrencyIsoCode = 'CRC',
                CaseId = caso.Id,
                AccountId = account.Id
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
        List<String> pricebookNames = new List<String>{
            'Bavarian Local',
            'Bavarian Dólar'
        };
        for (Integer i = 1; i<=numberRecords; i++ ) {
            newRecordList.add(new Pricebook2(
                Name = pricebookNames[i - 1],
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
                IsActive = true,
                CurrencyIsoCode = pricebook.Name.contains('Local') ? 'CRC' : 'USD'
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
