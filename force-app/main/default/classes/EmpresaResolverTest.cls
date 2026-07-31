@IsTest
private class EmpresaResolverTest {
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
    static void resolvesBavarianOtobaiAndNewCompanyWithoutUsingName() {
        List<Empresa__c> empresas = new List<Empresa__c>{
            buildEmpresa('Nombre visible 1', 'RMBAVARIAN', 'RMBAVARIAN', 'Bavarian Motors CR S.A.', true),
            buildEmpresa('Nombre visible 2', 'RMOTOBAI', 'RMOTOBAI', 'Otobai Motor CR S.A.', true),
            buildEmpresa('Nombre visible 3', 'RMCHINA', 'RMCHINA', 'Empresa Nueva S.A.', true)
        };
        insert empresas;

        EmpresaContext bavarian = EmpresaResolver.resolveByCodigo('rmbavarian');
        EmpresaContext otobai = EmpresaResolver.resolve(empresas[1].Id);
        EmpresaContext nueva = EmpresaResolver.resolveByCodigo(' RMCHINA ');

        System.assertEquals(empresas[0].Id, bavarian.empresaId);
        System.assertEquals('RMBAVARIAN', bavarian.codigo);
        System.assertEquals('RMOTOBAI', otobai.codigoErp);
        System.assertEquals('Empresa Nueva S.A.', nueva.nombreLegal);
        System.assertEquals(EmpresaContext.STATUS_CONFIGURED, nueva.configurationStatus);
        System.assert(nueva.isConfigured());
        System.assert(nueva.isActive());
    }

    @IsTest
    static void rejectsInactiveCompany() {
        Empresa__c empresa = buildEmpresa(
            'Inactiva',
            'RMINACTIVA',
            'RMINACTIVA',
            'Empresa Inactiva S.A.',
            false
        );
        insert empresa;

        try {
            EmpresaResolver.resolve(empresa.Id);
            System.assert(false, 'Debió rechazar la empresa inactiva.');
        } catch (EmpresaConfigurationException expected) {
            System.assert(expected.getMessage().contains('inactiva'));
        }
    }

    @IsTest
    static void rejectsNullId() {
        try {
            EmpresaResolver.resolve(null);
            System.assert(false, 'Debió rechazar el Id nulo.');
        } catch (EmpresaConfigurationException expected) {
            System.assert(expected.getMessage().contains('Id'));
        }
    }

    @IsTest
    static void rejectsNullAndBlankCode() {
        for (String invalidCode : new List<String>{ null, '', '   ' }) {
            try {
                EmpresaResolver.resolveByCodigo(invalidCode);
                System.assert(false, 'Debió rechazar el código nulo o vacío.');
            } catch (EmpresaConfigurationException expected) {
                System.assert(expected.getMessage().contains('código'));
            }
        }
    }

    @IsTest
    static void rejectsUnknownCodeWithoutBavarianFallback() {
        insert buildEmpresa(
            'Bavarian existe',
            'RMBAVARIAN',
            'RMBAVARIAN',
            'Bavarian Motors CR S.A.',
            true
        );

        try {
            EmpresaResolver.resolveByCodigo('EMPRESA_DESCONOCIDA');
            System.assert(false, 'No debe usar Bavarian como fallback.');
        } catch (EmpresaConfigurationException expected) {
            System.assert(expected.getMessage().contains('No existe'));
            System.assert(!expected.getMessage().contains('RMBAVARIAN'));
        }
    }

    // Codigo_ERP__c/Nombre_Legal__c ya NO bloquean resolve() (remediación hallazgo Luis #1,
    // 2026-07-31): una Empresa activa con código pero sin ERP o sin razón social se resuelve
    // igual (rutas que no necesitan ese dato, como TrabajoQuoteController, siguen funcionando);
    // solo se rechaza en el punto de uso real vía requireCodigoErp()/requireNombreLegal().
    @IsTest
    static void resolvesEmpresaWithMissingErpOrLegalNameAndDefersEnforcementToRequireMethods() {
        Empresa__c missingErp = buildEmpresa(
            'Sin ERP',
            'RMSINERP',
            null,
            'Sin ERP S.A.',
            true
        );
        Empresa__c missingLegalName = buildEmpresa(
            'Sin nombre legal',
            'RMSINLEGAL',
            'RMSINLEGAL',
            null,
            true
        );
        insert new List<Empresa__c>{ missingErp, missingLegalName };

        EmpresaContext sinErp = EmpresaResolver.resolve(missingErp.Id);
        System.assertEquals(null, sinErp.codigoErp);
        System.assert(sinErp.isConfigured());
        try {
            sinErp.requireCodigoErp();
            System.assert(false, 'requireCodigoErp() debe exigir el dato en el punto de uso.');
        } catch (EmpresaConfigurationException expected) {
            System.assert(expected.getMessage().contains('código ERP'));
        }

        EmpresaContext sinLegal = EmpresaResolver.resolve(missingLegalName.Id);
        System.assertEquals(null, sinLegal.nombreLegal);
        System.assert(sinLegal.isConfigured());
        try {
            sinLegal.requireNombreLegal();
            System.assert(false, 'requireNombreLegal() debe exigir el dato en el punto de uso.');
        } catch (EmpresaConfigurationException expected) {
            System.assert(expected.getMessage().contains('nombre legal'));
        }
    }

    @IsTest
    static void resolvesTwoHundredRequestsWithOneQuery() {
        List<Empresa__c> empresas = new List<Empresa__c>();
        Set<String> codigos = new Set<String>();
        for (Integer i = 0; i < 200; i++) {
            String codigo = 'RM' + String.valueOf(i).leftPad(3, '0');
            codigos.add(codigo);
            empresas.add(
                buildEmpresa(
                    'Empresa ' + i,
                    codigo,
                    codigo,
                    'Empresa Legal ' + i,
                    true
                )
            );
        }
        insert empresas;

        Test.startTest();
        Integer queriesBefore = Limits.getQueries();
        Map<String, EmpresaContext> resolved = EmpresaResolver.resolveAllByCodigo(codigos);
        Integer queriesUsed = Limits.getQueries() - queriesBefore;
        Test.stopTest();

        System.assertEquals(200, resolved.size());
        System.assertEquals(1, queriesUsed, 'La resolución bulk debe usar una sola consulta.');
        System.assertEquals('RM000', resolved.get('RM000').codigoErp);
        System.assertEquals('RM199', resolved.get('RM199').codigoErp);
    }

    @IsTest
    static void resolvesTwoHundredIdsWithOneQuery() {
        List<Empresa__c> empresas = new List<Empresa__c>();
        for (Integer i = 0; i < 200; i++) {
            String codigo = 'ID' + String.valueOf(i).leftPad(3, '0');
            empresas.add(
                buildEmpresa(
                    'Empresa por Id ' + i,
                    codigo,
                    'ERP' + codigo,
                    'Empresa por Id Legal ' + i,
                    true
                )
            );
        }
        insert empresas;

        Set<Id> empresaIds = new Set<Id>();
        Map<Id, Empresa__c> empresasById = new Map<Id, Empresa__c>();
        for (Empresa__c empresa : empresas) {
            empresaIds.add(empresa.Id);
            empresasById.put(empresa.Id, empresa);
        }

        Test.startTest();
        Integer queriesBefore = Limits.getQueries();
        Map<Id, EmpresaContext> resolved = EmpresaResolver.resolveAll(empresaIds);
        Integer queriesUsed = Limits.getQueries() - queriesBefore;
        Test.stopTest();

        System.assertEquals(200, resolved.size());
        System.assertEquals(empresaIds, resolved.keySet());
        System.assertEquals(1, queriesUsed, 'La resolución bulk por Id debe usar una sola consulta.');

        Id firstId = empresas[0].Id;
        Id lastId = empresas[199].Id;
        System.assertEquals(empresasById.get(firstId).Codigo__c, resolved.get(firstId).codigo);
        System.assertEquals('ERPID199', resolved.get(lastId).codigoErp);
        System.assertEquals('Empresa por Id Legal 199', resolved.get(lastId).nombreLegal);
        System.assert(resolved.get(firstId).isConfigured());
        System.assert(resolved.get(lastId).isActive());
    }

    @IsTest
    static void resolvesEmptyCollectionsWithoutQuery() {
        Test.startTest();
        Integer queriesBefore = Limits.getQueries();
        Map<Id, EmpresaContext> byId = EmpresaResolver.resolveAll(new Set<Id>());
        Map<String, EmpresaContext> byCode = EmpresaResolver.resolveAllByCodigo(new Set<String>());
        Integer queriesUsed = Limits.getQueries() - queriesBefore;
        Test.stopTest();

        System.assertEquals(0, byId.size());
        System.assertEquals(0, byCode.size());
        System.assertEquals(0, queriesUsed);
    }
}
