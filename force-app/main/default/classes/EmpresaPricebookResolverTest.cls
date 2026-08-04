@IsTest
private class EmpresaPricebookResolverTest {

    private static Empresa__c createEmpresa(String codigo, Boolean activa, Boolean doInsert) {
        Empresa__c empresa = new Empresa__c(
            Name = codigo,
            Codigo__c = codigo,
            Codigo_ERP__c = codigo,
            Activa__c = activa
        );
        if (doInsert) {
            insert empresa;
        }
        return empresa;
    }

    private static Pricebook2 createPricebook(String name, Id empresaId, String currencyIsoCode, Boolean isActive) {
        Pricebook2 pb = new Pricebook2(
            Name = name,
            Empresa__c = empresaId,
            CurrencyIsoCode = currencyIsoCode,
            IsActive = isActive
        );
        insert pb;
        return pb;
    }

    @IsTest
    static void testEmpresaNula_RetornaError() {
        EmpresaPricebookResolver.PricebookResolutionResult result = EmpresaPricebookResolver.resolveForEmpresa(
            null,
            'CRC',
            null
        );

        System.assertEquals(EmpresaPricebookResolver.STATUS_ERROR, result.status, 'Empresa nula debe retornar error controlado.');
        System.assertEquals(null, result.pricebookId, 'No debe seleccionar ningún Pricebook cuando falta la Empresa.');
    }

    @IsTest
    static void testEmpresaInexistente_RetornaError() {
        Empresa__c temp = createEmpresa('TMP01', true, true);
        Id empresaIdFalso = temp.Id;
        delete temp;

        EmpresaPricebookResolver.PricebookResolutionResult result = EmpresaPricebookResolver.resolveForEmpresa(
            empresaIdFalso,
            'CRC',
            null
        );

        System.assertEquals(EmpresaPricebookResolver.STATUS_ERROR, result.status, 'Empresa inexistente debe retornar error controlado.');
    }

    @IsTest
    static void testEmpresaInactiva_RetornaError() {
        Empresa__c empresa = createEmpresa('INACTIVA01', false, true);

        EmpresaPricebookResolver.PricebookResolutionResult result = EmpresaPricebookResolver.resolveForEmpresa(
            empresa.Id,
            'CRC',
            null
        );

        System.assertEquals(EmpresaPricebookResolver.STATUS_ERROR, result.status, 'Empresa inactiva debe retornar error controlado.');
    }

    @IsTest
    static void testSinPricebooks_RetornaNoConfigurado() {
        Empresa__c empresa = createEmpresa('SINPB01', true, true);

        EmpresaPricebookResolver.PricebookResolutionResult result = EmpresaPricebookResolver.resolveForEmpresa(
            empresa.Id,
            'CRC',
            null
        );

        System.assertEquals(EmpresaPricebookResolver.STATUS_NO_CONFIGURADO, result.status, 'Sin Pricebooks activos debe retornar NO_CONFIGURADO.');
        System.assertEquals(null, result.pricebookId, 'No debe seleccionar un Pricebook por defecto (ni Bavarian ni Otobai ni PEKING).');
    }

    @IsTest
    static void testUnaOpcionValida_SeleccionaAutomaticamente() {
        Empresa__c empresa = createEmpresa('UNAOPCION01', true, true);
        Pricebook2 pb = createPricebook('Empresa Local', empresa.Id, 'CRC', true);

        EmpresaPricebookResolver.PricebookResolutionResult result = EmpresaPricebookResolver.resolveForEmpresa(
            empresa.Id,
            'CRC',
            null
        );

        System.assertEquals(EmpresaPricebookResolver.STATUS_EXITO, result.status, 'Con exactamente una opción válida debe seleccionarla.');
        System.assertEquals(pb.Id, result.pricebookId, 'Debe seleccionar el único Pricebook válido disponible.');
    }

    @IsTest
    static void testVariasOpciones_RetornaSeleccionRequerida() {
        Empresa__c empresa = createEmpresa('VARIAS01', true, true);
        createPricebook('Empresa Local A', empresa.Id, 'CRC', true);
        createPricebook('Empresa Local B', empresa.Id, 'CRC', true);

        EmpresaPricebookResolver.PricebookResolutionResult result = EmpresaPricebookResolver.resolveForEmpresa(
            empresa.Id,
            'CRC',
            null
        );

        System.assertEquals(EmpresaPricebookResolver.STATUS_SELECCION_REQUERIDA, result.status, 'Con varias opciones válidas debe requerir selección.');
        System.assertEquals(null, result.pricebookId, 'No debe elegir arbitrariamente entre varias opciones.');
        System.assertEquals(2, result.opciones.size(), 'Debe listar ambas opciones válidas.');
    }

    @IsTest
    static void testPricebookActualValido_SeConserva() {
        Empresa__c empresa = createEmpresa('ACTUAL01', true, true);
        Pricebook2 pbActual = createPricebook('Empresa Local', empresa.Id, 'CRC', true);
        createPricebook('Empresa Dolar', empresa.Id, 'USD', true);

        EmpresaPricebookResolver.PricebookResolutionResult result = EmpresaPricebookResolver.resolveForEmpresa(
            empresa.Id,
            'CRC',
            pbActual.Id
        );

        System.assertEquals(EmpresaPricebookResolver.STATUS_EXITO, result.status, 'Un Pricebook actual válido debe conservarse.');
        System.assertEquals(pbActual.Id, result.pricebookId, 'Debe conservar el mismo Pricebook actual, no reemplazarlo.');
    }

    @IsTest
    static void testPricebookActualDeOtraEmpresa_NoSeConservaYCaeAUnaOpcion() {
        Empresa__c empresaA = createEmpresa('EMPRESAA01', true, true);
        Empresa__c empresaB = createEmpresa('EMPRESAB01', true, true);
        Pricebook2 pbEmpresaB = createPricebook('Empresa B Local', empresaB.Id, 'CRC', true);
        Pricebook2 pbEmpresaA = createPricebook('Empresa A Local', empresaA.Id, 'CRC', true);

        EmpresaPricebookResolver.PricebookResolutionResult result = EmpresaPricebookResolver.resolveForEmpresa(
            empresaA.Id,
            'CRC',
            pbEmpresaB.Id
        );

        System.assertEquals(EmpresaPricebookResolver.STATUS_EXITO, result.status, 'Debe caer a la única opción válida de la Empresa correcta.');
        System.assertEquals(pbEmpresaA.Id, result.pricebookId, 'No debe conservar el Pricebook de otra Empresa.');
        System.assertNotEquals(pbEmpresaB.Id, result.pricebookId, 'El Pricebook de otra Empresa nunca debe quedar seleccionado.');
    }

    @IsTest
    static void testPricebookActualDeOtraEmpresaSinOpciones_RetornaNoConfigurado() {
        Empresa__c empresaA = createEmpresa('EMPRESAC01', true, true);
        Empresa__c empresaB = createEmpresa('EMPRESAD01', true, true);
        Pricebook2 pbEmpresaB = createPricebook('Empresa D Local', empresaB.Id, 'CRC', true);

        EmpresaPricebookResolver.PricebookResolutionResult result = EmpresaPricebookResolver.resolveForEmpresa(
            empresaA.Id,
            'CRC',
            pbEmpresaB.Id
        );

        System.assertEquals(EmpresaPricebookResolver.STATUS_NO_CONFIGURADO, result.status, 'Sin opciones propias, debe indicar NO_CONFIGURADO, nunca conservar el de otra Empresa.');
        System.assertEquals(null, result.pricebookId);
    }

    @IsTest
    static void testPricebookInactivo_NoSeConsideraCandidato() {
        Empresa__c empresa = createEmpresa('INACTIVOPB01', true, true);
        createPricebook('Empresa Local Inactiva', empresa.Id, 'CRC', false);

        EmpresaPricebookResolver.PricebookResolutionResult result = EmpresaPricebookResolver.resolveForEmpresa(
            empresa.Id,
            'CRC',
            null
        );

        System.assertEquals(EmpresaPricebookResolver.STATUS_NO_CONFIGURADO, result.status, 'Un Pricebook inactivo no debe considerarse candidato.');
    }

    @IsTest
    static void testMonedaNoCoincide_NoSeConsideraCandidato() {
        Empresa__c empresa = createEmpresa('MONEDA01', true, true);
        createPricebook('Empresa Dolar', empresa.Id, 'USD', true);

        EmpresaPricebookResolver.PricebookResolutionResult result = EmpresaPricebookResolver.resolveForEmpresa(
            empresa.Id,
            'CRC',
            null
        );

        System.assertEquals(EmpresaPricebookResolver.STATUS_NO_CONFIGURADO, result.status, 'Un Pricebook de otra moneda no debe considerarse candidato.');
    }

    @IsTest
    static void testSinMonedaProvista_ConsideraTodasLasMonedas() {
        Empresa__c empresa = createEmpresa('SINMONEDA01', true, true);
        createPricebook('Empresa Local', empresa.Id, 'CRC', true);
        createPricebook('Empresa Dolar', empresa.Id, 'USD', true);

        EmpresaPricebookResolver.PricebookResolutionResult result = EmpresaPricebookResolver.resolveForEmpresa(
            empresa.Id,
            null,
            null
        );

        System.assertEquals(EmpresaPricebookResolver.STATUS_SELECCION_REQUERIDA, result.status, 'Sin filtro de moneda, ambas opciones son válidas y no debe elegir arbitrariamente.');
        System.assertEquals(2, result.opciones.size());
    }

    @IsTest
    static void testBulk_MultiplesEmpresasEnUnaSolaLlamada_SinSoqlEnLoop() {
        List<EmpresaPricebookResolver.PricebookResolutionRequest> requests = new List<EmpresaPricebookResolver.PricebookResolutionRequest>();
        List<Empresa__c> empresas = new List<Empresa__c>();
        for (Integer i = 0; i < 50; i++) {
            empresas.add(createEmpresa('BULK' + i, true, false));
        }
        insert empresas;

        List<Pricebook2> pricebooks = new List<Pricebook2>();
        for (Empresa__c empresa : empresas) {
            pricebooks.add(new Pricebook2(
                Name = 'PB ' + empresa.Codigo__c,
                Empresa__c = empresa.Id,
                CurrencyIsoCode = 'CRC',
                IsActive = true
            ));
        }
        insert pricebooks;

        for (Empresa__c empresa : empresas) {
            EmpresaPricebookResolver.PricebookResolutionRequest request = new EmpresaPricebookResolver.PricebookResolutionRequest();
            request.empresaId = empresa.Id;
            request.currencyIsoCode = 'CRC';
            requests.add(request);
        }

        Test.startTest();
        List<EmpresaPricebookResolver.PricebookResolutionResult> results = EmpresaPricebookResolver.resolve(requests);
        Test.stopTest();

        System.assertEquals(50, results.size(), 'Debe resolver todas las solicitudes del lote.');
        for (EmpresaPricebookResolver.PricebookResolutionResult result : results) {
            System.assertEquals(EmpresaPricebookResolver.STATUS_EXITO, result.status);
        }
    }

    @IsTest
    static void testListaVacia_NoLanzaError() {
        List<EmpresaPricebookResolver.PricebookResolutionResult> results = EmpresaPricebookResolver.resolve(
            new List<EmpresaPricebookResolver.PricebookResolutionRequest>()
        );
        System.assertEquals(0, results.size());

        results = EmpresaPricebookResolver.resolve(null);
        System.assertEquals(0, results.size());
    }

    @IsTest
    static void testLookupPrincipalResuelvePekingSinUsarFallbackLegacy() {
        Empresa__c peking = createEmpresa('RMPEKING', true, true);
        Empresa__c otobai = createEmpresa('RMOTOBAI', true, true);
        Pricebook2 pekingPricebook = createPricebook('PB prueba PEKING', peking.Id, 'CRC', true);
        createPricebook('PB prueba Otobai', otobai.Id, 'CRC', true);

        EmpresaPricebookResolver.PricebookResolutionResult result = EmpresaPricebookResolver.resolveForSource(
            peking.Id,
            'Otobai',
            'CRC',
            null
        );

        System.assertEquals(EmpresaPricebookResolver.STATUS_EXITO, result.status);
        System.assertEquals(peking.Id, result.empresaId, 'El lookup debe prevalecer sobre el fallback legacy.');
        System.assertEquals(pekingPricebook.Id, result.pricebookId, 'PEKING no debe caer en el Pricebook de Otobai.');
    }

    @IsTest
    static void testLookupVacioUsaFallbackLegacyBavarianYOtobai() {
        Empresa__c bavarian = createEmpresa('RMBAVARIAN', true, true);
        Empresa__c otobai = createEmpresa('RMOTOBAI', true, true);
        Pricebook2 bavarianPricebook = createPricebook('PB prueba Bavarian', bavarian.Id, 'CRC', true);
        Pricebook2 otobaiPricebook = createPricebook('PB prueba Otobai', otobai.Id, 'CRC', true);

        EmpresaPricebookResolver.PricebookResolutionResult bavarianResult =
            EmpresaPricebookResolver.resolveForSource(null, ' Bavarian ', 'CRC', null);
        EmpresaPricebookResolver.PricebookResolutionResult otobaiResult =
            EmpresaPricebookResolver.resolveForSource(null, 'otobai', 'CRC', null);

        System.assertEquals(bavarian.Id, bavarianResult.empresaId);
        System.assertEquals(bavarianPricebook.Id, bavarianResult.pricebookId);
        System.assertEquals(otobai.Id, otobaiResult.empresaId);
        System.assertEquals(otobaiPricebook.Id, otobaiResult.pricebookId);
    }

    @IsTest
    static void testLegacyDesconocidoNoCaeEnEmpresaPorDefecto() {
        Empresa__c bavarian = createEmpresa('RMBAVARIAN', true, true);
        createPricebook('PB prueba Bavarian', bavarian.Id, 'CRC', true);

        EmpresaPricebookResolver.PricebookResolutionResult result = EmpresaPricebookResolver.resolveForSource(
            null,
            'PEKING',
            'CRC',
            null
        );

        System.assertEquals(EmpresaPricebookResolver.STATUS_ERROR, result.status);
        System.assertEquals(null, result.empresaId);
        System.assertEquals(null, result.pricebookId);
        System.assert(result.mensaje.contains('fallback temporal'));
    }

    @IsTest
    static void testFallbackConfiguradoSinEmpresaRetornaNoConfigurado() {
        EmpresaPricebookResolver.PricebookResolutionResult result = EmpresaPricebookResolver.resolveForSource(
            null,
            'Bavarian',
            'CRC',
            null
        );

        System.assertEquals(EmpresaPricebookResolver.STATUS_NO_CONFIGURADO, result.status);
        System.assertEquals(null, result.empresaId);
        System.assertEquals(null, result.pricebookId);
    }

    @IsTest
    static void testFallbackAmbiguoNoSeleccionaEmpresa() {
        Empresa__c primera = createEmpresa('BAV01', true, false);
        primera.Codigo_ERP__c = 'RMBAVARIAN';
        Empresa__c segunda = createEmpresa('BAV02', true, false);
        segunda.Codigo_ERP__c = 'RMBAVARIAN';
        insert new List<Empresa__c>{ primera, segunda };

        EmpresaPricebookResolver.PricebookResolutionResult result = EmpresaPricebookResolver.resolveForSource(
            null,
            'Bavarian',
            'CRC',
            null
        );

        System.assertEquals(EmpresaPricebookResolver.STATUS_ERROR, result.status);
        System.assertEquals(null, result.empresaId);
        System.assertEquals(null, result.pricebookId);
        System.assert(result.mensaje.contains('más de una Empresa'));
    }
}
