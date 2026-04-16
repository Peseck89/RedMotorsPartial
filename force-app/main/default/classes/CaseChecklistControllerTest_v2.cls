@isTest
public class CaseChecklistControllerTest_v2 {

    @TestSetup
    static void makeData() {
        Account acc = new Account();
        acc.Name = 'Test account';
        acc.Cedula__c = '9876543210';
        acc.Tipo_de_Documento__c = '02';
        acc.codigoSoftland__c = '1234';
        insert acc;

        Contact cont = new Contact(
            FirstName = 'Julio',
            LastName  = 'Perez'
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

        WorkOrder workOrder = new WorkOrder(
            AssetId = vehiculo.Id
        );
        insert workOrder;
    }

    @isTest
    static void testCaseChecklistController() {
        List<tiposDeTrabajo__c> tipoTrabajoList = [SELECT Id, Name FROM tiposDeTrabajo__c LIMIT 1];
        WorkOrder workOrder = [SELECT Id, CaseId FROM WorkOrder LIMIT 1];
        Asset vehiculo = [SELECT Id FROM Asset LIMIT 1];

        Case cs = new Case(
            Create_Orders_from_Workorders__c = true,
            AssetId = vehiculo.Id
        );
        insert cs;

        // Setear Kilometros__c para cubrir la rama if(OT[0].Kilometros__c != null && != 0)
        workOrder.CaseId       = cs.Id;
        workOrder.Kilometros__c = 5000;
        update workOrder;

        Cambio_de_Propietario__c cambio = new Cambio_de_Propietario__c(
            Case__c   = cs.Id,
            Asset__c  = vehiculo.Id,
            Estado__c = 'Pendiente'
        );
        insert cambio;

        // Crear tiposDeTrabajoCaso__c para cubrir listTipos.size()>0 y la query de subtipos
        tiposDeTrabajoCaso__c ttc = new tiposDeTrabajoCaso__c(
            Caso__c          = cs.Id,
            Tipotrabajo__c   = tipoTrabajoList[0].Id,
            Status__c        = 'Abierta',
            Tipo_de_cargo__c = 'Cliente',
            Horaa__c         = 4
        );
        insert ttc;

        // Insertar ContentVersions y vincularlos al Case para cubrir el loop de imágenes
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
                shareType         = 'V'
            ));
        }
        insert cdlList;

        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', cs.Id);
        ApexPages.StandardController controller = new ApexPages.StandardController(cs);
        CaseChecklistController_v2 cntrl = new CaseChecklistController_v2(controller);
        Test.stopTest();

        System.assertNotEquals(null, cntrl.cambioPropietario,  'Debe encontrar el cambio de propietario pendiente');
        System.assertEquals(5000,  cntrl.kilometros,            'Debe usar Kilometros__c del WorkOrder cuando es != 0');
        System.assertNotEquals(null, cntrl.ordenesTrabajo,      'ordenesTrabajo (propiedad de clase) no debe ser null');
        System.assertEquals(1,     cntrl.ordenesTrabajo.size(), 'Debe encontrar el WorkOrder vinculado al Case');
        System.assertNotEquals(null, cntrl.listTipos,           'listTipos no debe ser null');
        // Las 5 imageUrl deben estar asignadas por el loop de ContentVersions
        System.assertNotEquals(null, cntrl.imageUrl,  'imageUrl (Carrocería#1) debe estar asignada');
        System.assertNotEquals(null, cntrl.imageUrl1, 'imageUrl1 (Carrocería#2) debe estar asignada');
        System.assertNotEquals(null, cntrl.imageUrl2, 'imageUrl2 (Carrocería#3) debe estar asignada');
        System.assertNotEquals(null, cntrl.imageUrl3, 'imageUrl3 (Carrocería#4) debe estar asignada');
        System.assertNotEquals(null, cntrl.imageUrl4, 'imageUrl4 (Carrocería#5) debe estar asignada');
    }
}
