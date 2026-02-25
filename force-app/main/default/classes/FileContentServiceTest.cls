@isTest
public class FileContentServiceTest {

    @TestSetup
    static void setupTestData() {
        // Create Account
        Account testAccount = new Account(
            Name = 'Test Account',
            Cedula__c = '9876543210',
            Tipo_de_Documento__c = '02',
            codigoSoftland__c = '1234'
        );
        insert testAccount;

        // Create Asset
        Asset vehiculo = new Asset(
            Name = 'Car 1',
            AccountId = testAccount.Id
        );
        insert vehiculo;

        // Create Case
        Case cs = new Case(
            Create_Orders_from_Workorders__c = true,
            AssetId = vehiculo.Id
        );
        insert cs;

        // Create tiposDeTrabajo__c
        tiposDeTrabajo__c tipoTrabajo = new tiposDeTrabajo__c(Name = 'Mantenimiento');
        insert tipoTrabajo;

        // Create tiposDeTrabajoCaso__c
        tiposDeTrabajoCaso__c tipoTrabajoCaso = new tiposDeTrabajoCaso__c(
            Tipotrabajo__c = tipoTrabajo.Id,
            filesJson__c = JSON.serialize(new List<FileContentService.FileJson>{
                new FileContentService.FileJson('TestFile1', 'https://example.com/file1', '12345', 'pdf'),
                new FileContentService.FileJson('TestFile2', 'https://example.com/file2', '67890', 'doc')
            }),
            Caso__c = cs.Id
        );
        insert tipoTrabajoCaso;

        // Create Subtipo_de_trabajo_del_caso__c
        Subtipo_de_trabajo_del_caso__c subTipoTrabajoCaso = new Subtipo_de_trabajo_del_caso__c(
            Name = 'Sub-Maintenance Case',
            filesJson__c = JSON.serialize(new List<FileContentService.FileJson>{
                new FileContentService.FileJson('SubFile1', 'https://example.com/subfile1', '98765', 'xls')
            }),
            Tipo_de_trabajo_del_caso__c = tipoTrabajoCaso.Id
        );
        insert subTipoTrabajoCaso;

        // Create ContentVersion
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Test content data'),
            IsMajorVersion = true,
            FirstPublishLocationId = testAccount.Id
        );
        insert contentVersion;
    }

    @isTest
    static void testGetNestedFileJson() {
        // Retrieve a tiposDeTrabajoCaso__c record
        tiposDeTrabajoCaso__c parentRecord = [
            SELECT Id
            FROM tiposDeTrabajoCaso__c
            LIMIT 1
        ];

        // Instantiate the service
        FileContentService service = new FileContentService();

        // Call the method to test
        Test.startTest();
        String result = service.getNestedFileJson(parentRecord.Id);
        Test.stopTest();

        // Validate the output

    }

    @isTest
    static void testSaveJsonToObjects() {
        // Prepare test data
        tiposDeTrabajoCaso__c tipoTrabajoCaso = [SELECT Id FROM tiposDeTrabajoCaso__c LIMIT 1];

        // Prepare FileInfo map
        Map<Id, List<FileContentService.FileInfo>> fileInfoMap = new Map<Id, List<FileContentService.FileInfo>>();
        List<FileContentService.FileInfo> fileInfos = new List<FileContentService.FileInfo>();

        fileInfos.add(new FileContentService.FileInfo(
            'https://test.salesforce.com/samplefile1',
            'pdf',
            tipoTrabajoCaso.Id
        ));

        fileInfoMap.put(tipoTrabajoCaso.Id, fileInfos);

        // Instantiate the service
        FileContentService service = new FileContentService();

        // Call the saveJsonToObjects method
        Test.startTest();
        service.saveJsonToObjects(fileInfoMap, 'tiposDeTrabajoCaso__c');
        Test.stopTest();

        // Validate that filesJson__c was updated
        tiposDeTrabajoCaso__c updatedRecord = [SELECT filesJson__c FROM tiposDeTrabajoCaso__c WHERE Id = :tipoTrabajoCaso.Id];
        System.assertNotEquals(null, updatedRecord.filesJson__c, 'filesJson__c should not be null after update');
    }

    @isTest
    static void testSaveContentDistributions() {
        // Get the test ContentDocument
        ContentDocument testContentDocument = [SELECT Id FROM ContentDocument LIMIT 1];

        // Instantiate the service
        FileContentService service = new FileContentService();

        // Call the saveContentDistributions method
        Test.startTest();
        service.saveContentDistributions(new List<Id> { testContentDocument.Id });
        Test.stopTest();

        // Validate that ContentDistribution was created
        List<ContentDistribution> distributions = [
            SELECT Id, ContentDocumentId FROM ContentDistribution
            WHERE ContentDocumentId = :testContentDocument.Id
        ];
        System.assertNotEquals(0, distributions.size(), 'ContentDistribution should be created.');
    }

    @isTest
    static void testDeleteContentDistributions() {
        // Get the test ContentDocument
        ContentDocument testContentDocument = [SELECT Id FROM ContentDocument LIMIT 1];

        // Create a ContentDistribution
        ContentVersion testContentVersion = [SELECT Id FROM ContentVersion WHERE ContentDocumentId = :testContentDocument.Id LIMIT 1];
        ContentDistribution testDistribution = new ContentDistribution(
            Name = 'Test Distribution',
            ContentVersionId = testContentVersion.Id,
            PreferencesAllowViewInBrowser = true,
            PreferencesLinkLatestVersion = true,
            PreferencesNotifyOnVisit = false,
            PreferencesPasswordRequired = false
        );
        insert testDistribution;

        // Validate that ContentDistribution exists
        List<ContentDistribution> distributions = [
            SELECT Id FROM ContentDistribution WHERE ContentDocumentId = :testContentDocument.Id
        ];
        System.assertEquals(1, distributions.size(), 'ContentDistribution should exist before deletion.');

        // Instantiate the service
        FileContentService service = new FileContentService();

        // Call the deleteContentDistributions method
        Test.startTest();
        service.deleteContentDistributions(new List<Id> { testContentDocument.Id });
        Test.stopTest();

        // Validate that ContentDistribution was deleted
        distributions = [
            SELECT Id FROM ContentDistribution WHERE ContentDocumentId = :testContentDocument.Id
        ];
        System.assertEquals(0, distributions.size(), 'ContentDistribution should be deleted.');
    }

    @isTest
    static void testProcessContentFiles() {
        // Get the test Account
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        // Get the associated ContentDocument
        ContentDocument testContentDocument = [SELECT Id FROM ContentDocument LIMIT 1];

        // Instantiate the service
        FileContentService service = new FileContentService();

        // Call the processContentFiles method
        Test.startTest();
        service.processContentFiles(new List<Id> { testAccount.Id }, 'Account');
        Test.stopTest();

        // Validate that ContentDistributions were created
        List<ContentDistribution> distributions = [
            SELECT Id FROM ContentDistribution WHERE ContentDocumentId = :testContentDocument.Id
        ];
        System.assertNotEquals(0, distributions.size(), 'ContentDistributions should be created.');
    }
}