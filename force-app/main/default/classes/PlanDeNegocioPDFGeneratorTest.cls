@IsTest
public class PlanDeNegocioPDFGeneratorTest {

    @IsTest
    static void testGeneratePDFPlanDeNegocio() {
        // Crear datos de prueba
        Account acc = new Account(
            Name = 'Test account',
            Cedula__c = '9876543210',
            Tipo_de_Documento__c = '02',
            codigoSoftland__c = '1234'
        );
        insert acc;

        Asset ast = new Asset(
            Name = 'TEST',
            AccountId = acc.Id,
            Tipo_de_veh_culo__c = 'Automóvil',
            Marca_Nvo__c = 'MINI',
            Modelo_Nvo2__c = 'COOPER-SE-VR-COUNTRYMA',
            Anio__c = '2020'
        );
        insert ast;

        // Crear una oportunidad de prueba con el RecordType adecuado
        RecordType autosUsadosRecordType = [SELECT Id FROM RecordType WHERE Name = 'Autos usados' AND SObjectType = 'Opportunity' LIMIT 1];
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id,
            BMW_PlacaDeVehiculoOElVIN__c = ast.Id,
            RecordTypeId = autosUsadosRecordType.Id
        );
        insert testOpportunity;

        // Crear lista de IDs de oportunidad
        List<Id> opportunityIds = new List<Id> { testOpportunity.Id };

        // Llamar al método invocable
        Test.startTest();
        List<ContentVersion> contentVersions = PlanDeNegocioPDFGenerator.generatePDFPlanDeNegocio(opportunityIds);
        Test.stopTest();

        // Aserciones para verificar los resultados
        System.assertNotEquals(null, contentVersions);
        System.assertEquals(1, contentVersions.size());
        System.assertEquals('Plan de Negocio', contentVersions[0].Title);
        System.assertEquals('Plan_de_Negocio.pdf', contentVersions[0].PathOnClient);
        System.assertEquals(ast.Id, contentVersions[0].FirstPublishLocationId);
        System.assertEquals('Test PDF Content', contentVersions[0].VersionData.toString());
    }
}