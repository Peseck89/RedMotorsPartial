@IsTest
public class CaseChecklistControllerTest_v2 {

    @TestSetup
    static void makeData() {
        Account acc = new Account(
            Name = 'Test account',
            Cedula__c = '9876543210',
            Tipo_de_Documento__c = '02',
            codigoSoftland__c = '1234'
        );
        insert acc;

        Contact cont = new Contact(
            FirstName = 'Julio',
            LastName  = 'Perez',
            AccountId = acc.Id
        );
        insert cont;

        tiposDeTrabajo__c tipoTrabajo = new tiposDeTrabajo__c(
            Name = 'Mantenimiento'
        );
        insert tipoTrabajo;

        Asset vehiculo = new Asset(
            Name      = 'Car 1',
            AccountId = acc.Id
        );
        insert vehiculo;

        Case cs = new Case(
            AccountId = acc.Id,
            ContactId = cont.Id,
            AssetId = vehiculo.Id,
            Create_Orders_from_Workorders__c = true
        );
        insert cs;

        WorkOrder workOrder = new WorkOrder(
            AssetId = vehiculo.Id,
            CaseId = cs.Id,
            Kilometros__c = 5000
        );
        insert workOrder;

        Cambio_de_Propietario__c cambio = new Cambio_de_Propietario__c(
            Case__c   = cs.Id,
            Asset__c  = vehiculo.Id,
            Estado__c = 'Pendiente'
        );
        insert cambio;

        tiposDeTrabajoCaso__c ttc = new tiposDeTrabajoCaso__c(
            Caso__c          = cs.Id,
            Tipotrabajo__c   = tipoTrabajo.Id,
            Status__c        = 'Abierta',
            Tipo_de_cargo__c = 'Cliente',
            Horaa__c         = 4
        );
        insert ttc;

        List<ContentVersion> cvList = new List<ContentVersion>{
            new ContentVersion(Title = 'Carrocería#1', PathOnClient = 'img1.jpg', VersionData = Blob.valueOf('Test'), IsMajorVersion = true),
            new ContentVersion(Title = 'Carrocería#2', PathOnClient = 'img2.jpg', VersionData = Blob.valueOf('Test'), IsMajorVersion = true),
            new ContentVersion(Title = 'Carrocería#3', PathOnClient = 'img3.jpg', VersionData = Blob.valueOf('Test'), IsMajorVersion = true),
            new ContentVersion(Title = 'Carrocería#4', PathOnClient = 'img4.jpg', VersionData = Blob.valueOf('Test'), IsMajorVersion = true),
            new ContentVersion(Title = 'Carrocería#5', PathOnClient = 'img5.jpg', VersionData = Blob.valueOf('Test'), IsMajorVersion = true)
        };
        insert cvList;

        List<ContentDocument> docs = [SELECT Id FROM ContentDocument];
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        
        for (ContentDocument doc : docs) {
            cdlList.add(new ContentDocumentLink(
                LinkedEntityId    = cs.Id,
                ContentDocumentId = doc.Id,
                ShareType         = 'V'
            ));
        }
        insert cdlList;
    }

    @IsTest
    static void testCaseChecklistController() {
        Case cs = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        
        PageReference pageRef = Page.CaseChecklistPDFBeta; 
        pageRef.getParameters().put('id', cs.Id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController stdController = new ApexPages.StandardController(cs);
        CaseChecklistController_v2 cntrl = new CaseChecklistController_v2(stdController);
        
        Test.stopTest();

        System.assertNotEquals(null, cntrl.cambioPropietario);
        System.assertEquals(5000, cntrl.kilometros);
        
        System.assertNotEquals(null, cntrl.imageUrl);
        System.assertNotEquals(null, cntrl.imageUrl1);
        System.assertNotEquals(null, cntrl.imageUrl2);
        System.assertNotEquals(null, cntrl.imageUrl3);
        System.assertNotEquals(null, cntrl.imageUrl4);
    }
}