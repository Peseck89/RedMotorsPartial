@IsTest
private class QuoteSoftlandPedidoServiceTest {
    private static Empresa__c buildEmpresa(
        String name,
        String codigo,
        String codigoErp,
        String nombreLegal,
        Boolean activa
    ) {
        return new Empresa__c(
            Name = name,
            Codigo__c = codigo,
            Codigo_ERP__c = codigoErp,
            Nombre_Legal__c = nombreLegal,
            Activa__c = activa
        );
    }

    @IsTest
    static void resolvesBavarianByLookup() {
        Empresa__c bavarian = buildEmpresa('Bavarian', 'RMBAVARIAN', 'RMBAVARIAN', 'Bavarian Motors CR S.A.', true);
        insert bavarian;
        Quote q = new Quote(Opportunity = new Opportunity(Empresa_Operadora__c = bavarian.Id));

        Test.startTest();
        String erp = QuoteSoftlandPedidoService.resolveCompanyErpCode(q);
        Test.stopTest();

        System.assertEquals('RMBAVARIAN', erp);
    }

    @IsTest
    static void resolvesOtobaiByLookup() {
        Empresa__c otobai = buildEmpresa('Otobai', 'RMOTOBAI', 'RMOTOBAI', 'Otobai Motor CR S.A.', true);
        insert otobai;
        Quote q = new Quote(Opportunity = new Opportunity(Empresa_Operadora__c = otobai.Id));

        Test.startTest();
        String erp = QuoteSoftlandPedidoService.resolveCompanyErpCode(q);
        Test.stopTest();

        System.assertEquals('RMOTOBAI', erp);
    }

    @IsTest
    static void resolvesPekingThroughEmpresaLookup() {
        Empresa__c peking = buildEmpresa('PEKING', 'RMPEKING', 'RMPEKING', 'PEKING QA / NO PRODUCCIÓN', true);
        insert peking;
        Quote q = new Quote(Opportunity = new Opportunity(Empresa_Operadora__c = peking.Id));

        Test.startTest();
        String erp = QuoteSoftlandPedidoService.resolveCompanyErpCode(q);
        Test.stopTest();

        System.assertEquals('RMPEKING', erp);
    }

    @IsTest
    static void resolvesFutureCompanyWithoutCodeChange() {
        Empresa__c futura = buildEmpresa('Futura', 'RMFUTURA', 'RMFUTURA', 'Futura Motors S.A.', true);
        insert futura;
        Quote q = new Quote(Opportunity = new Opportunity(Empresa_Operadora__c = futura.Id));

        Test.startTest();
        String erp = QuoteSoftlandPedidoService.resolveCompanyErpCode(q);
        Test.stopTest();

        System.assertEquals('RMFUTURA', erp);
    }

    @IsTest
    static void resolvesValidLegacyCompanyTextWhenLookupIsEmpty() {
        Empresa__c bavarian = buildEmpresa('Bavarian', 'RMBAVARIAN', 'RMBAVARIAN', 'Bavarian Motors CR S.A.', true);
        insert bavarian;
        Quote q = new Quote(
            Opportunity = new Opportunity(Empresa_Operadora__c = null, BMW_Compania__c = 'Bavarian')
        );

        Test.startTest();
        String erp = QuoteSoftlandPedidoService.resolveCompanyErpCode(q);
        Test.stopTest();

        System.assertEquals('RMBAVARIAN', erp);
    }

    @IsTest
    static void resolvesValidLegacyCompanyCodeWhenLookupIsEmpty() {
        Empresa__c otobai = buildEmpresa('Otobai', 'RMOTOBAI', 'RMOTOBAI', 'Otobai Motor CR S.A.', true);
        insert otobai;
        Quote q = new Quote(
            Opportunity = new Opportunity(Empresa_Operadora__c = null, BMW_Compania__c = 'RMOTOBAI')
        );

        Test.startTest();
        String erp = QuoteSoftlandPedidoService.resolveCompanyErpCode(q);
        Test.stopTest();

        System.assertEquals('RMOTOBAI', erp);
    }

    @IsTest
    static void rejectsUnresolvableLegacyCompanyWithControlledError() {
        Quote q = new Quote(
            Opportunity = new Opportunity(Empresa_Operadora__c = null, BMW_Compania__c = 'Desconocida')
        );

        Test.startTest();
        Boolean threw = false;
        try {
            QuoteSoftlandPedidoService.resolveCompanyErpCode(q);
        } catch (AuraHandledException expected) {
            threw = true;
        }
        Test.stopTest();

        System.assert(threw, 'Debió lanzar un error controlado para una empresa legacy no resoluble.');
    }

    @IsTest
    static void doesNotFallbackSilentlyToBavarian() {
        Empresa__c bavarian = buildEmpresa('Bavarian', 'RMBAVARIAN', 'RMBAVARIAN', 'Bavarian Motors CR S.A.', true);
        insert bavarian;
        Quote q = new Quote(
            Opportunity = new Opportunity(Empresa_Operadora__c = null, BMW_Compania__c = 'MarcaNoExistente')
        );

        Test.startTest();
        Boolean threw = false;
        String resolvedErp;
        try {
            resolvedErp = QuoteSoftlandPedidoService.resolveCompanyErpCode(q);
        } catch (AuraHandledException expected) {
            threw = true;
        }
        Test.stopTest();

        System.assert(threw, 'No debe resolver silenciosamente una empresa desconocida; obtuvo: ' + resolvedErp);
    }

    @IsTest
    static void rejectsInactiveCompanyWithControlledError() {
        Empresa__c inactiva = buildEmpresa('Inactiva', 'RMINACTIVA', 'RMINACTIVA', 'Inactiva S.A.', false);
        insert inactiva;
        Quote q = new Quote(Opportunity = new Opportunity(Empresa_Operadora__c = inactiva.Id));

        Test.startTest();
        Boolean threw = false;
        try {
            QuoteSoftlandPedidoService.resolveCompanyErpCode(q);
        } catch (AuraHandledException expected) {
            threw = true;
        }
        Test.stopTest();

        System.assert(threw, 'Debió rechazar una Empresa inactiva con un error controlado.');
    }
}
