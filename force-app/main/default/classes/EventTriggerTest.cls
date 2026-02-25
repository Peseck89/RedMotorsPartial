@isTest(seeAllData = true)
public class EventTriggerTest {

    @isTest static void testEventTrigger()
    {
        Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='1234567999';
        acc.Tipo_de_Documento__c='13';
        acc.codigoSoftland__c = '1234';
        insert acc;
        
        Case cs = new Case(Create_Orders_from_Workorders__c = true);
        insert cs;
        
        Asset asset = [Select id From Asset Where Id != null Limit 1];
        
        
        List<Calendar> calendarList = [Select Id From Calendar limit 1];
        
        Event ev = new Event(StartDateTime = System.now().addDays(1),
                                EndDateTime = System.now().addDays(3),
                                tipoCargoAseguradora__c = true,
                             	tipoCargoBci__c = true,
                             	tipoCargoCliente__c = true,
                             	tipoCargoFabrica__c = true,
                             	tipoCargoGarantia__c = true,
                                Activo__c = asset.Id,
                                OwnerId = calendarList[0].Id);
        try{insert ev;}catch(Exception ex){}
        
        List<AsesorxCalendario__c> lstAsesor = [SELECT Asesor__c, Service_Territory__c 
                 FROM AsesorxCalendario__c 
                 WHERE Asesor__c != null];
        
        
        
		Event ev1 = new Event(StartDateTime = System.now().addDays(1),
                                EndDateTime = System.now().addDays(3),
                                tipoCargoAseguradora__c = true,
                             	tipoCargoBci__c = true,
                             	tipoCargoCliente__c = true,
                             	tipoCargoFabrica__c = true,
                             	tipoCargoGarantia__c = true);
        insert ev1;
        ev1.OwnerId = lstAsesor[0].Asesor__c;
        update ev1;
          
        
       	Event evtRes = [Select tipoCargoBci__c, Activo__c From Event Limit 1];
        
    }

    @isTest static void testEventTriggerBad()
    {
        Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='1234567929';
        acc.Tipo_de_Documento__c='13';
        acc.codigoSoftland__c = '1234';
        insert acc;
        
        Case cs = new Case(Create_Orders_from_Workorders__c = true);
        insert cs;
        
        Asset asset = [Select id From Asset Where Id != null Limit 1];
        
        
        List<Calendar> calendarList = [Select Id From Calendar limit 1];
        
        Event ev = new Event(StartDateTime = System.now(),
                                EndDateTime = System.now().addDays(3),
                                tipoCargoAseguradora__c = true,
                             	tipoCargoBci__c = true,
                             	tipoCargoCliente__c = true,
                             	tipoCargoFabrica__c = true,
                             	tipoCargoGarantia__c = true,
                                Activo__c = asset.Id,
                                OwnerId = calendarList[0].Id);
        try{insert ev;}catch(Exception ex){}

    }
}