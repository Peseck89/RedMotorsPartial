@isTest
public class CaseChecklistControllerTest_v2 {

     @TestSetup
    static void makeData(){    
        Account acc = new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        acc.codigoSoftland__c = '1234';  
        insert acc;

        Contact cont = new Contact(
            FirstName = 'Julio',
            LastName = 'Perez'
        );
        insert cont;

        tiposDeTrabajo__c tipoTrabajo = new tiposDeTrabajo__c(
            Name = 'Mantenimiento'        
        );
        insert tipoTrabajo;

        Asset vehiculo = new Asset(
            Name = 'Car 1',
            AccountId = acc.Id
        );
        insert vehiculo;

        WorkOrder workOrder = new WorkOrder(
            AssetId = vehiculo.Id            
        );
        insert workOrder;
        
        
    }

    @isTest
    public static void testCaseChecklistController() {

        List<tiposDeTrabajo__c> tipoTrabajoList = [SELECT Id,Name FROM tiposDeTrabajo__c LIMIT 1];
        WorkOrder workOrder = [SELECT Id,CaseId FROM WorkOrder LIMIT 1];
        Asset vehiculo = [SELECT Id FROM Asset LIMIT 1];
        
        System.debug('@@@workOrder@@@'+workOrder);
        
        Case cs = new Case(
            Create_Orders_from_Workorders__c = true,
            AssetId = vehiculo.Id
            );
        insert cs;

        workOrder.CaseId = cs.Id;
        update workOrder;
        
        Cambio_de_Propietario__c cambio = new Cambio_de_Propietario__c(
       Case__c = cs.Id,
       Asset__c = vehiculo.Id,
       //Cuenta_Anterior__c = acc.Id,
      //Cuenta_Nueva__c = acc.Id,
       Estado__c = 'Pendiente'
       );
       insert cambio;
        
        ContentVersion contentVersion = new ContentVersion(
        Title = 'Carrocería#1',
        PathOnClient = 'Penguins.jpg',
        VersionData = Blob.valueOf('Test Content'),
        IsMajorVersion = true
         );
         insert contentVersion;   
        
        ContentVersion contentVersion1 = new ContentVersion(
        Title = 'Carrocería#2',
        PathOnClient = 'Penguin.jpg',
        VersionData = Blob.valueOf('Test Content'),
        IsMajorVersion = true
         );
        insert contentVersion1;
        
        ContentVersion contentVersion2 = new ContentVersion(
        Title = 'Carrocería#3',
        PathOnClient = 'Cat.jpg',
        VersionData = Blob.valueOf('Test Content'),
        IsMajorVersion = true
         );
        insert contentVersion2;  
        
        ContentVersion contentVersion3 = new ContentVersion(
        Title = 'Carrocería#4',
        PathOnClient = 'Cat1.jpg',
        VersionData = Blob.valueOf('Test Content'),
        IsMajorVersion = true
         );
        insert contentVersion3;
        
        ContentVersion contentVersion4 = new ContentVersion(
        Title = 'Carrocería#5',
        PathOnClient = 'Cat2.jpg',
        VersionData = Blob.valueOf('Test Content'),
        IsMajorVersion = true
         );
        insert contentVersion4;
        
         List<ContentDocument> images = [SELECT Id, Title FROM ContentDocument];

         //create ContentDocumentLink  record 
         ContentDocumentLink cdl = New ContentDocumentLink();
         cdl.LinkedEntityId = cs.Id;
         cdl.ContentDocumentId = images[0].Id;
         cdl.shareType = 'V';
         insert cdl;
         ContentDocumentLink cdl1 = New ContentDocumentLink();
         cdl1.LinkedEntityId = cs.Id;
         cdl1.ContentDocumentId = images[1].Id;
         cdl1.shareType = 'V';
         insert cdl1;
         ContentDocumentLink cdl2 = New ContentDocumentLink();
         cdl2.LinkedEntityId = cs.Id;
         cdl2.ContentDocumentId = images[2].Id;
         cdl2.shareType = 'V';
         insert cdl2;
         ContentDocumentLink cdl3 = New ContentDocumentLink();
         cdl3.LinkedEntityId = cs.Id;
         cdl3.ContentDocumentId = images[3].Id;
         cdl3.shareType = 'V';
         insert cdl3;
         ContentDocumentLink cdl4 = New ContentDocumentLink();
         cdl4.LinkedEntityId = cs.Id;
         cdl4.ContentDocumentId = images[4].Id;
         cdl4.shareType = 'V';
         insert cdl4;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', cs.Id);
        ApexPages.StandardController controller = new ApexPages.StandardController(cs);
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        CaseChecklistController_v2 cntrl = new CaseChecklistController_v2(controller);
        Test.stopTest();
    }
    
    public class ExampleCalloutMock implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{"access_token":"","token_type":""}');
            return res;
        }
    }
}