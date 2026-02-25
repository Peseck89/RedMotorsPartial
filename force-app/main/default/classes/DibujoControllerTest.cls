@isTest
public class DibujoControllerTest {



    @isTest
    static void testGetDibujosByCase() {
        // Crear un caso
        Case testCase = new Case(Subject = 'Caso para Dibujo');
        insert testCase;

        // Crear un DibujoVehiculo__c relacionado
        DibujoVehiculo__c dibujo = new DibujoVehiculo__c(
            Case__c = testCase.Id
        );
        insert dibujo;

        // Crear un archivo (ContentVersion)
        ContentVersion version = new ContentVersion(
            Title = 'Test Image',
            PathOnClient = 'test-image.png',
            VersionData = Blob.valueOf('dummy data')
        );
        insert version;

        // Obtener el ContentDocumentId del archivo insertado
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :version.Id].ContentDocumentId;

        // Relacionarlo al Dibujo
        ContentDocumentLink link = new ContentDocumentLink(
            ContentDocumentId = contentDocumentId,
            LinkedEntityId = dibujo.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert link;

        Test.startTest();
        List<DibujoController.DibujoWrapper> dibujos = DibujoController.getDibujosByCase(testCase.Id);
        Test.stopTest();

        System.assertEquals(1, dibujos.size(), 'Debe haber un dibujo relacionado');
        System.assertEquals(dibujo.Id, dibujos[0].dibujoId, 'Debe coincidir el Id del dibujo');
        System.assertNotEquals(null, dibujos[0].versionId, 'Debe tener una versionId asociada');
    }
}