@isTest
private class CrearPlandeVentaTest {
    @isTest
    static void copiesEmpresaOperadoraWithoutTransformingLookup() {
        Empresa__c empresa = new Empresa__c(
            Name = 'PEKING Test',
            Codigo__c = 'RMPEKING',
            Codigo_ERP__c = 'RMPEKING',
            Nombre_Legal__c = 'PEKING Test S.A.',
            Activa__c = true
        );
        insert empresa;

        Quote sourceQuote = createSourceQuote(empresa.Id, 'Bavarian', 'WITH-LOOKUP');
        Opportunity sourceBefore = [
            SELECT Empresa_Operadora__c, BMW_Compania__c
            FROM Opportunity
            WHERE Id = :sourceQuote.OpportunityId
        ];

        Test.startTest();
        CrearPlandeVenta.FlowOutput output = executePlan(sourceQuote.Id);
        Test.stopTest();

        Quote createdQuote = [
            SELECT OpportunityId, Opportunity.Empresa_Operadora__c,
                   Opportunity.BMW_Compania__c
            FROM Quote
            WHERE Id = :output.newQuoteId
        ];
        Opportunity sourceAfter = [
            SELECT Empresa_Operadora__c, BMW_Compania__c
            FROM Opportunity
            WHERE Id = :sourceQuote.OpportunityId
        ];

        System.assertNotEquals(sourceQuote.OpportunityId, createdQuote.OpportunityId);
        System.assertEquals(empresa.Id, createdQuote.Opportunity.Empresa_Operadora__c);
        System.assertEquals(
            sourceBefore.Empresa_Operadora__c,
            sourceAfter.Empresa_Operadora__c
        );
        System.assertEquals(sourceBefore.BMW_Compania__c, sourceAfter.BMW_Compania__c);
    }

    @isTest
    static void preservesNullLookupAndLegacyCompanyBehavior() {
        Quote sourceQuote = createSourceQuote(null, 'Bavarian', 'WITHOUT-LOOKUP');
        Opportunity sourceOpportunity = [
            SELECT RecordType.Name
            FROM Opportunity
            WHERE Id = :sourceQuote.OpportunityId
        ];
        String expectedLegacyCompany =
            expectedLegacyCompany(sourceOpportunity.RecordType.Name);

        Test.startTest();
        CrearPlandeVenta.FlowOutput output = executePlan(sourceQuote.Id);
        Test.stopTest();

        Quote createdQuote = [
            SELECT OpportunityId, Compania__c,
                   Opportunity.Empresa_Operadora__c,
                   Opportunity.BMW_Compania__c
            FROM Quote
            WHERE Id = :output.newQuoteId
        ];

        System.assertNotEquals(sourceQuote.OpportunityId, createdQuote.OpportunityId);
        System.assertEquals(null, createdQuote.Opportunity.Empresa_Operadora__c);
        System.assertEquals(expectedLegacyCompany, createdQuote.Opportunity.BMW_Compania__c);
        System.assertEquals(expectedLegacyCompany, createdQuote.Compania__c);
    }

    private static CrearPlandeVenta.FlowOutput executePlan(Id sourceQuoteId) {
        CrearPlandeVenta.FlowInput input = new CrearPlandeVenta.FlowInput();
        input.quoteId = sourceQuoteId;

        List<CrearPlandeVenta.FlowOutput> outputs =
            CrearPlandeVenta.ejecutar(new List<CrearPlandeVenta.FlowInput>{ input });

        System.assertEquals(1, outputs.size());
        System.assertNotEquals(null, outputs[0].newQuoteId);
        return outputs[0];
    }

    private static Quote createSourceQuote(
        Id empresaOperadoraId,
        String legacyCompany,
        String scenario
    ) {
        Account account = new Account(Name = 'Cuenta ' + scenario);
        insert account;

        Pricebook2 pricebook = new Pricebook2(
            Name = 'Pricebook ' + scenario,
            IsActive = true
        );
        insert pricebook;

        Opportunity sourceOpportunity = new Opportunity(
            Name = 'Opportunity ' + scenario,
            AccountId = account.Id,
            StageName = 'Draft',
            CloseDate = Date.today(),
            Pricebook2Id = pricebook.Id,
            BMW_Compania__c = legacyCompany,
            Empresa_Operadora__c = empresaOperadoraId
        );
        insert sourceOpportunity;

        Quote sourceQuote = new Quote(
            Name = 'Quote ' + scenario,
            OpportunityId = sourceOpportunity.Id,
            Pricebook2Id = pricebook.Id,
            Compania__c = legacyCompany,
            ExpirationDate = Date.today().addDays(30)
        );
        insert sourceQuote;
        return sourceQuote;
    }

    private static String expectedLegacyCompany(String recordTypeName) {
        Set<String> bavarianRecordTypes = new Set<String>{
            'BMW',
            'Motorrad',
            'MINI',
            'Autos usados'
        };
        return bavarianRecordTypes.contains(recordTypeName) ? 'Bavarian' : 'Otobai';
    }
}
