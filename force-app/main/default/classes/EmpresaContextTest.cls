@IsTest
private class EmpresaContextTest {
    private static Empresa__c createValidEmpresa() {
        Empresa__c empresa = new Empresa__c(
            Name = 'Empresa Context Test',
            Codigo__c = 'RMCONTEXT',
            Codigo_ERP__c = 'ERP_CONTEXT',
            Nombre_Legal__c = 'Empresa Context Test S.A.',
            Activa__c = true
        );
        insert empresa;
        return empresa;
    }

    @IsTest
    static void constructsConfiguredContextAndExposesGetters() {
        Empresa__c empresa = createValidEmpresa();

        EmpresaContext context = new EmpresaContext(
            empresa.Id,
            empresa.Codigo__c,
            empresa.Codigo_ERP__c,
            empresa.Nombre_Legal__c,
            empresa.Activa__c
        );

        System.assertEquals(empresa.Id, context.empresaId);
        System.assertEquals('RMCONTEXT', context.codigo);
        System.assertEquals('ERP_CONTEXT', context.codigoErp);
        System.assertEquals('Empresa Context Test S.A.', context.nombreLegal);
        System.assertEquals(true, context.activa);
        System.assertEquals(EmpresaContext.STATUS_CONFIGURED, context.configurationStatus);
        System.assertEquals(true, context.isConfigured());
        System.assertEquals(true, context.isActive());
        System.assertEquals('ERP_CONTEXT', context.requireCodigoErp());
        System.assertEquals('Empresa Context Test S.A.', context.requireNombreLegal());
    }

    @IsTest
    static void rejectsNullEmpresaId() {
        assertInvalidContext(
            null,
            'RMCONTEXT',
            'ERP_CONTEXT',
            'Empresa Context Test S.A.',
            true,
            'Id de Empresa es requerido'
        );
    }

    @IsTest
    static void rejectsNullCodigo() {
        Empresa__c empresa = createValidEmpresa();
        assertInvalidContext(
            empresa.Id,
            null,
            'ERP_CONTEXT',
            'Empresa Context Test S.A.',
            true,
            'código de Empresa es requerido'
        );
    }

    @IsTest
    static void rejectsBlankCodigo() {
        Empresa__c empresa = createValidEmpresa();
        assertInvalidContext(
            empresa.Id,
            '   ',
            'ERP_CONTEXT',
            'Empresa Context Test S.A.',
            true,
            'código de Empresa es requerido'
        );
    }

    @IsTest
    static void rejectsInactiveEmpresa() {
        Empresa__c empresa = createValidEmpresa();
        assertInvalidContext(
            empresa.Id,
            'RMINACTIVA',
            'ERP_INACTIVA',
            'Empresa Inactiva S.A.',
            false,
            'está inactiva'
        );
    }

    // Codigo_ERP__c y Nombre_Legal__c ya NO bloquean la construcción del contexto (remediación
    // hallazgo Luis #1, 2026-07-31): ningún consumidor real necesita ambos campos siempre, así
    // que el contexto se construye igual y solo require*() exige el dato en el punto de uso real.
    @IsTest
    static void constructsContextWithMissingCodigoErpAndRequireCodigoErpFailsLater() {
        Empresa__c empresa = createValidEmpresa();
        EmpresaContext context = new EmpresaContext(
            empresa.Id,
            'RMSINERP',
            null,
            'Empresa Sin ERP S.A.',
            true
        );

        System.assertEquals(null, context.codigoErp);
        System.assertEquals(true, context.isConfigured());

        try {
            context.requireCodigoErp();
            System.assert(false, 'requireCodigoErp() debe exigir el dato en el punto de uso.');
        } catch (EmpresaConfigurationException expected) {
            System.assert(expected.getMessage().contains('no tiene código ERP configurado'));
        }
    }

    @IsTest
    static void constructsContextWithMissingNombreLegalAndRequireNombreLegalFailsLater() {
        Empresa__c empresa = createValidEmpresa();
        EmpresaContext context = new EmpresaContext(
            empresa.Id,
            'RMSINLEGAL',
            'ERP_SIN_LEGAL',
            null,
            true
        );

        System.assertEquals(null, context.nombreLegal);
        System.assertEquals(true, context.isConfigured());

        try {
            context.requireNombreLegal();
            System.assert(false, 'requireNombreLegal() debe exigir el dato en el punto de uso.');
        } catch (EmpresaConfigurationException expected) {
            System.assert(expected.getMessage().contains('no tiene nombre legal configurado'));
        }
    }

    @IsTest
    static void requireCodigoErpRejectsIncompleteDeserializedContext() {
        EmpresaContext context = (EmpresaContext) JSON.deserialize(
            '{"codigo":"RMSINERP","codigoErp":null}',
            EmpresaContext.class
        );

        try {
            context.requireCodigoErp();
            System.assert(false, 'Debe exigir código ERP.');
        } catch (EmpresaConfigurationException expected) {
            System.assert(expected.getMessage().contains('no tiene código ERP configurado'));
        }
    }

    @IsTest
    static void requireNombreLegalRejectsIncompleteDeserializedContext() {
        EmpresaContext context = (EmpresaContext) JSON.deserialize(
            '{"codigo":"RMSINLEGAL","nombreLegal":null}',
            EmpresaContext.class
        );

        try {
            context.requireNombreLegal();
            System.assert(false, 'Debe exigir nombre legal.');
        } catch (EmpresaConfigurationException expected) {
            System.assert(expected.getMessage().contains('no tiene nombre legal configurado'));
        }
    }

    private static void assertInvalidContext(
        Id empresaId,
        String codigo,
        String codigoErp,
        String nombreLegal,
        Boolean activa,
        String expectedMessage
    ) {
        try {
            EmpresaContext context = new EmpresaContext(
                empresaId,
                codigo,
                codigoErp,
                nombreLegal,
                activa
            );
            System.assertEquals(
                null,
                context,
                'No debe construirse un contexto que incumpla las invariantes.'
            );
        } catch (EmpresaConfigurationException expected) {
            System.assert(
                expected.getMessage().contains(expectedMessage),
                'Mensaje inesperado: ' + expected.getMessage()
            );
        }
    }
}
