@IsTest
public class BMW_LineaPlantillaEmpresa_Test {
    @IsTest
    static void resolvesBavarianLookup() {
        assertLookupResolution('RMBAVARIAN');
    }

    @IsTest
    static void resolvesOtobaiLookup() {
        assertLookupResolution('RMOTOBAI');
    }

    @IsTest
    static void resolvesPekingLookup() {
        assertLookupResolution('RMPEKING');
    }

    @IsTest
    static void lookupTakesPriorityOverContradictoryLegacyValue() {
        Empresa__c empresa = createEmpresa('RMPEKING', true, true);
        Plantilla_de_Presupuesto__c plantilla = createPlantilla(
            empresa.Id,
            'Bavarian',
            'PRIORIDAD'
        );

        Test.startTest();
        String result = BMW_LineaPlantillaEmpresa.getEmpresa(plantilla.Id);
        Test.stopTest();

        System.assertEquals('RMPEKING', result);
        System.assertNotEquals('RMBAVARIAN', result);
    }

    @IsTest
    static void usesBavarianLegacyFallback() {
        Plantilla_de_Presupuesto__c plantilla = createPlantilla(
            null,
            'Bavarian',
            'LEGACY-BAV'
        );

        System.assertEquals(
            'RMBAVARIAN',
            BMW_LineaPlantillaEmpresa.getEmpresa(plantilla.Id)
        );
    }

    @IsTest
    static void usesOtobaiLegacyFallback() {
        Plantilla_de_Presupuesto__c plantilla = createPlantilla(
            null,
            'Otobai',
            'LEGACY-OTO'
        );

        System.assertEquals(
            'RMOTOBAI',
            BMW_LineaPlantillaEmpresa.getEmpresa(plantilla.Id)
        );
    }

    @IsTest
    static void rejectsInactiveAndIncompleteCompanies() {
        Empresa__c inactive = createEmpresa('RMINACTIVA', false, true);
        Empresa__c incomplete = createEmpresa('RMINCOMPLETA', true, false);
        Plantilla_de_Presupuesto__c inactiveTemplate = createPlantilla(
            inactive.Id,
            'Otobai',
            'INACTIVE'
        );
        Plantilla_de_Presupuesto__c incompleteTemplate = createPlantilla(
            incomplete.Id,
            'Otobai',
            'INCOMPLETE'
        );

        assertConfigurationFailure(inactiveTemplate.Id, 'inactiva');
        assertConfigurationFailure(incompleteTemplate.Id, 'incompleta');
    }

    @IsTest
    static void rejectsNullTemplateId() {
        assertConfigurationFailure(null, 'Id');
    }

    @IsTest
    static void rejectsMissingTemplate() {
        String prefix = Plantilla_de_Presupuesto__c.SObjectType
            .getDescribe()
            .getKeyPrefix();
        Id missingId = (Id)(prefix + '000000000000');

        assertConfigurationFailure(missingId, 'No existe');
    }

    private static void assertLookupResolution(String codigo) {
        Empresa__c empresa = createEmpresa(codigo, true, true);
        Plantilla_de_Presupuesto__c plantilla = createPlantilla(
            empresa.Id,
            'Otobai',
            'LOOKUP-' + codigo
        );

        Test.startTest();
        String result = BMW_LineaPlantillaEmpresa.getEmpresa(plantilla.Id);
        Test.stopTest();

        System.assertEquals(codigo, result);
    }

    private static Empresa__c createEmpresa(
        String codigo,
        Boolean activa,
        Boolean complete
    ) {
        Empresa__c empresa = new Empresa__c(
            Name = 'Empresa ' + codigo,
            Codigo__c = codigo,
            Codigo_ERP__c = complete ? codigo : null,
            Nombre_Legal__c = complete ? 'Empresa ' + codigo + ' S.A.' : null,
            Activa__c = activa
        );
        insert empresa;
        return empresa;
    }

    private static Plantilla_de_Presupuesto__c createPlantilla(
        Id empresaId,
        String legacyCompany,
        String suffix
    ) {
        Plantilla_de_Presupuesto__c plantilla =
            new Plantilla_de_Presupuesto__c(
                Nombre__c = 'Plantilla ' + suffix,
                BMW_TipoDeVehiculo__c = 'Automóvil',
                Empresa_Operadora__c = empresaId,
                BMW_Compania__c = legacyCompany
            );
        insert plantilla;
        return plantilla;
    }

    private static void assertConfigurationFailure(
        Id plantillaId,
        String expectedMessage
    ) {
        try {
            BMW_LineaPlantillaEmpresa.getEmpresa(plantillaId);
            System.assert(false, 'Se esperaba EmpresaConfigurationException.');
        } catch (EmpresaConfigurationException expected) {
            System.assert(
                expected.getMessage().contains(expectedMessage),
                'Mensaje inesperado: ' + expected.getMessage()
            );
        }
    }
}
