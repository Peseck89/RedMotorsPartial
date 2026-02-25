@isTest
private class ModifyEventControllerTest {
    
    @isTest
    static void fetchRecordsBankNameTest()
    {
        Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        acc.codigoSoftland__c = '1234';
        
        insert acc;
        
        Case cs = new Case(Create_Orders_from_Workorders__c = true);
        insert cs;
        
        Asset asset = new Asset(Name = 'Test',
                                AccountId = acc.Id);
        insert asset;
        
        ModifyEventController.fetchRecords(asset.Name, asset.Id);
    }
    
    @isTest
    static void fetchRecordsSearchSringEmptyTest()
    {
        Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        acc.codigoSoftland__c = '1234';
        
        insert acc;
        
        Case cs = new Case(Create_Orders_from_Workorders__c = true);
        insert cs;
        
        Asset asset = new Asset(Name = 'Test',
                                AccountId = acc.Id);
        insert asset;
        
        ModifyEventController.fetchRecords('', '');
    }
    
    @isTest
    static void fetchEventDetailIfTest()
    {
        Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        acc.codigoSoftland__c = '1234';
        insert acc;
        
        Case cs = new Case(Create_Orders_from_Workorders__c = true);
        insert cs;
        
        Asset asset = new Asset(Name = 'Test',
                                AccountId = acc.Id);
        insert asset;
        
        List<Calendar> calendarList = [SELECT Id FROM Calendar LIMIT 1];
        
        WorkType wt = new WorkType(Name = 'Mecánica Rapida',
                                   EstimatedDuration = 100);
        insert wt;
        
        Event ev1 = new Event(StartDateTime = System.now(),
                              EndDateTime = System.now().addDays(3),
                              tipoCargoAseguradora__c = true,
                              tipoCargoBci__c = true,
                              tipoCargoCliente__c = true,
                              tipoCargoFabrica__c = true,
                              tipoCargoGarantia__c = true);
        insert ev1;
        try
        {
            ModifyEventController.fetchEventDetail(ev1.Id);
            
        }
        catch(Exception ex)
        {
            
        }
    }
    
    @isTest
    static void fetchEventDetailTest()
    {
        Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        acc.codigoSoftland__c = '1234';
        insert acc;
        
        Case cs = new Case(Create_Orders_from_Workorders__c = true);
        insert cs;
        
        Asset asset = new Asset(Name = 'Test',
                                AccountId = acc.Id);
        insert asset;
        
        List<Calendar> calendarList = [SELECT Id FROM Calendar LIMIT 1];
        
        WorkType wt = new WorkType(Name = 'Mecánica Rapida',
                                   EstimatedDuration = 100);
        insert wt;
        
        Event event = new Event(StartDateTime = System.now(),
                                EndDateTime = System.now().addDays(3),
                                tipoCargoAseguradora__c = true,
                                Activo__c = asset.Id,
                                OwnerId = calendarList[0].Id);
        
        try{insert event;}catch(Exception ex){}
        try
        {
            ModifyEventController.fetchEventDetail(event.Id);
            
        }
        catch(Exception ex)
        {
            
        }
    }
    
    @isTest
    static void updateEventDetailTest()
    {
        Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        acc.codigoSoftland__c = '1234';
        
        insert acc;
        
        Case cs = new Case(Create_Orders_from_Workorders__c = true);
        insert cs;
        
        Asset asset = new Asset(Name = 'Test',
                                AccountId = acc.Id);
        insert asset;
        
        List<Calendar> calendarList = [SELECT Id FROM Calendar LIMIT 1];
        WorkType wt = new WorkType(Name = 'Mecánica Rapida',
                                   EstimatedDuration = 100);
        insert wt;
        
        Event ev1 = new Event(StartDateTime = System.now(),
                              EndDateTime = System.now().addDays(3),
                              tipoCargoAseguradora__c = true,
                              tipoCargoBci__c = true,
                              tipoCargoCliente__c = true,
                              tipoCargoFabrica__c = true,
                              tipoCargoGarantia__c = true);
        insert ev1;
        try
        {
            ModifyEventController.updateEventDetail(ev1.Id, asset.Id, true, true, true, true);  
        }
        catch(Exception ex)
        {
            
        }
    }
}