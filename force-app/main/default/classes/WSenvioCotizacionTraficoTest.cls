@isTest
private class WSenvioCotizacionTraficoTest {
    private static final String BMW_MODEL = 'BM19 - 318 - Executive';
    private static final String BMW_MODEL_2 = 'BM81 - Serie 1 - 118i Paq M';
    private static final String BMW_MODEL_3 = 'BM83 - X4 - XDrive 20d Premium';
    private static final String BMW_MODEL_4 = 'BM65 - 420I GC - SPORT LINE';
    private static final String MINI_MODEL = 'MI1 - COOPER 3PTS (MT)';
    private static final String MOTORRAD_MODEL = 'MN-BMW-ADVENTURE-G310-GS';
    private static final String POLARIS_MODEL = 'GENERAL XP 4 1000 PREMIUM';
    private static final String KAWASAKI_MODEL = 'MN-KAWA-Z-Z900-ABS';
    private static final String INDIAN_MODEL = 'MN-INDIAN-CRUISER-SCOUT-ABS';

    private class MockHttpSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            res.setBodyAsBlob(Blob.valueOf('FAKE_PDF'));
            return res;
        }
    }

    private static Lead buildLead(String marca, String marca2, String marca3, String marca4,
                                  String modelo1, Boolean cot1,
                                  String modelo2, Boolean cot2,
                                  String modelo3, Boolean cot3,
                                  String modelo4, Boolean cot4,
                                  String leadSource, String asuntoWeb) {
        Id recordTypeId = recordTypeFor(marca);
        Lead l = new Lead(
            FirstName             = 'Test',
            LastName              = 'Lead',
            Company               = 'Test Co',
            Email                 = 'test' + String.valueOf(Math.abs(Crypto.getRandomInteger())) + '@test.com',
            Marca__c              = marca,
            Marca2__c             = marca2,
            Marca3__c             = marca3,
            Marca4__c             = marca4,
            Modelo_De_Inter_s1__c = modelo1,
            Cotizacion_1__c       = cot1,
            Modelo_De_Inter_s2__c = modelo2,
            Cotizacion_2__c       = cot2,
            Modelo_De_Inter_s3__c = modelo3,
            Cotizacion_3__c       = cot3,
            Modelo_De_Inter_s4__c = modelo4,
            Cotizacion_4__c       = cot4,
            LeadSource            = leadSource,
            AsuntoWeb__c          = asuntoWeb
        );
        if (recordTypeId != null) {
            l.RecordTypeId = recordTypeId;
        }
        insert l;
        return l;
    }

    private static Id recordTypeFor(String developerName) {
        if (String.isBlank(developerName)) return null;
        Map<String, Schema.RecordTypeInfo> infos =
            Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName();
        return infos.containsKey(developerName) ? infos.get(developerName).getRecordTypeId() : null;
    }

    private static Lead buildLeadSimple(String marca) {
        return buildLead(marca, null, null, null,
                         null, false, null, false, null, false, null, false,
                         null, null);
    }

   
    @isTest
    static void testEnvioCotizacion_KTM_Marca1() {
        Lead l = buildLeadSimple('KTM');
        Test.startTest();
        String result = WSenvioCotizacionTrafico.envioCotizacion(l.Id, null);
        Test.stopTest();
        System.assert(result.contains('No tiene los suficientes privilegios'),
                      'Debe bloquear KTM en Marca__c');
    }

    @isTest
    static void testEnvioCotizacion_KTM_Marca2() {
        Lead l = buildLeadSimple('KTM');
        Test.startTest();
        String result = WSenvioCotizacionTrafico.envioCotizacion(l.Id, null);
        Test.stopTest();
        System.assert(result.contains('No tiene los suficientes privilegios'));
    }

    @isTest
    static void testEnvioCotizacion_KTM_Marca3() {
        Lead l = buildLeadSimple('KTM');
        Test.startTest();
        String result = WSenvioCotizacionTrafico.envioCotizacion(l.Id, null);
        Test.stopTest();
        System.assert(result.contains('No tiene los suficientes privilegios'));
    }

    @isTest
    static void testEnvioCotizacion_KTM_Marca4() {
        Lead l = buildLeadSimple('KTM');
        Test.startTest();
        String result = WSenvioCotizacionTrafico.envioCotizacion(l.Id, null);
        Test.stopTest();
        System.assert(result.contains('No tiene los suficientes privilegios'));
    }

    @isTest
    static void testEnvioCotizacion_BMW_SinModelos() {
        Lead l = buildLeadSimple('BMW');
        Test.startTest();
        String result = WSenvioCotizacionTrafico.envioCotizacion(l.Id, null);
        Test.stopTest();
        System.assertEquals('enviado correctamente', result);
    }

    @isTest
    static void testEnvioCotizacion_BMW_TestDrive_SinProducto() {
        Lead l = buildLead('BMW', null, null, null,
                           BMW_MODEL, true,
                           null, false, null, false, null, false,
                           'Página Web', 'Test Drive');
        Test.startTest();
        String result = WSenvioCotizacionTrafico.envioCotizacion(l.Id, null);
        Test.stopTest();
        System.assertEquals('no enviado', result);
    }

    @isTest
    static void testEnvioCotizacion_BMW_Normal_SinProducto() {
        Lead l = buildLead('BMW', null, null, null,
                           BMW_MODEL, true,
                           null, false, null, false, null, false,
                           null, null);
        Test.startTest();
        String result = WSenvioCotizacionTrafico.envioCotizacion(l.Id, null);
        Test.stopTest();
        System.assertEquals('no enviado', result);
    }

    @isTest
    static void testEnvioCotizacion_BMW_ConProductoYLink() {
        String modelo = BMW_MODEL;
        insert new Product2(
            Name                   = modelo,
            Codigo_de_Producto__c  = 'BM19',
            Modelo_De_Inter_s__c   = modelo,
            Link_ficha_t_cnica__c  = 'https://example.com/ficha.pdf',
            IsActive               = true
        );
        Lead l = buildLead('BMW', null, null, null,
                           modelo, true,
                           null, false, null, false, null, false,
                           null, null);
        Test.setMock(HttpCalloutMock.class, new MockHttpSuccess());
        Test.startTest();
        String result = WSenvioCotizacionTrafico.envioCotizacion(l.Id, null);
        Test.stopTest();
        System.assertEquals('enviado correctamente', result);
    }

    @isTest
    static void testEnvioCotizacion_MINI_SinModelos() {
        Lead l = buildLeadSimple('MINI');
        Test.startTest();
        String result = WSenvioCotizacionTrafico.envioCotizacion(l.Id, null);
        Test.stopTest();
        System.assertEquals('enviado correctamente', result);
    }

    @isTest
    static void testEnvioCotizacion_MINI_ConModelo_SinProducto() {
        Lead l = buildLead('MINI', null, null, null,
                           MINI_MODEL, true,
                           null, false, null, false, null, false,
                           null, null);
        Test.startTest();
        String result = WSenvioCotizacionTrafico.envioCotizacion(l.Id, null);
        Test.stopTest();
        System.assertEquals('no enviado', result);
    }

    @isTest
    static void testEnvioCotizacion_Motorrad_SinModelos() {
        Lead l = buildLeadSimple('Motorrad');
        Test.startTest();
        String result = WSenvioCotizacionTrafico.envioCotizacion(l.Id, null);
        Test.stopTest();
        System.assertEquals('enviado correctamente', result);
    }

    @isTest
    static void testEnvioCotizacion_Motorrad_ConModelo_SinProducto() {
        Lead l = buildLead('Motorrad', null, null, null,
                           MOTORRAD_MODEL, true,
                           null, false, null, false, null, false,
                           null, null);
        Test.startTest();
        String result = WSenvioCotizacionTrafico.envioCotizacion(l.Id, null);
        Test.stopTest();
        System.assertEquals('no enviado', result);
    }

    @isTest
    static void testEnvioCotizacion_Polaris_SinModelos() {
        Lead l = buildLeadSimple('Polaris');
        Test.startTest();
        String result = WSenvioCotizacionTrafico.envioCotizacion(l.Id, null);
        Test.stopTest();
        System.assertEquals('enviado correctamente', result);
    }

    @isTest
    static void testEnvioCotizacion_Polaris_ConModelo_SinProducto() {
        Lead l = buildLead('Polaris', null, null, null,
                           POLARIS_MODEL, true,
                           null, false, null, false, null, false,
                           null, null);
        Test.startTest();
        String result = WSenvioCotizacionTrafico.envioCotizacion(l.Id, null);
        Test.stopTest();
        System.assertEquals('no enviado', result);
    }

    @isTest
    static void testEnvioCotizacion_Kawasaki_SinModelos() {
        Lead l = buildLeadSimple('Kawasaki');
        Test.startTest();
        String result = WSenvioCotizacionTrafico.envioCotizacion(l.Id, null);
        Test.stopTest();
        System.assertEquals('enviado correctamente', result);
    }

    @isTest
    static void testEnvioCotizacion_Kawasaki_ConModelo_SinProducto() {
        Lead l = buildLead('Kawasaki', null, null, null,
                           KAWASAKI_MODEL, true,
                           null, false, null, false, null, false,
                           null, null);
        Test.startTest();
        String result = WSenvioCotizacionTrafico.envioCotizacion(l.Id, null);
        Test.stopTest();
        System.assertEquals('no enviado', result);
    }

    @isTest
    static void testEnvioCotizacion_Indian_SinModelos() {
        Lead l = buildLeadSimple('Indian');
        Test.startTest();
        String result = WSenvioCotizacionTrafico.envioCotizacion(l.Id, null);
        Test.stopTest();
        System.assertEquals('enviado correctamente', result);
    }

    @isTest
    static void testEnvioCotizacion_Indian_ConModelo_SinProducto() {
        Lead l = buildLead('Indian', null, null, null,
                           INDIAN_MODEL, true,
                           null, false, null, false, null, false,
                           null, null);
        Test.startTest();
        String result = WSenvioCotizacionTrafico.envioCotizacion(l.Id, null);
        Test.stopTest();
        System.assertEquals('no enviado', result);
    }

    @isTest
    static void testEnvioCotizacion_ModeloSinFlag() {
        Lead l = buildLead('BMW', null, null, null,
                           BMW_MODEL, false,
                           null, false, null, false, null, false,
                           null, null);
        Test.startTest();
        String result = WSenvioCotizacionTrafico.envioCotizacion(l.Id, null);
        Test.stopTest();
        System.assertEquals('enviado correctamente', result);
    }

    @isTest
    static void testEnvioCotizacion_CuatroModelos_SinProductos() {
        Lead l = buildLead('BMW', null, null, null,
                           BMW_MODEL,   true,
                           BMW_MODEL_2, true,
                           BMW_MODEL_3, true,
                           BMW_MODEL_4, true,
                           null, null);
        Test.startTest();
        String result = WSenvioCotizacionTrafico.envioCotizacion(l.Id, null);
        Test.stopTest();
        System.assertEquals('no enviado', result);
    }

    @isTest
    static void testEnvioCotizacion_ConDocumento_SinProducto() {
        Folder f = [SELECT Id FROM Folder WHERE Type = 'Document' LIMIT 1];
        insert new Document(
            FolderId      = f.Id,
            Name          = 'BM19 Test',
            DeveloperName = 'BM19Test' + String.valueOf(Math.abs(Crypto.getRandomInteger())),
            Body          = Blob.valueOf('fake'),
            ContentType   = 'application/pdf',
            Type          = 'pdf'
        );
        Lead l = buildLead('BMW', null, null, null,
                           BMW_MODEL, true,
                           null, false, null, false, null, false,
                           null, null);
        Test.startTest();
        String result = WSenvioCotizacionTrafico.envioCotizacion(l.Id, null);
        Test.stopTest();
        System.assertEquals('no enviado', result);
    }


    @isTest
    static void testMultimarca_SinModelos() {
        Lead l = buildLeadSimple('BMW');
        Test.startTest();
        String result = WSenvioCotizacionTrafico.envioCotizacionMultimarca(l.Id, null);
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @isTest
    static void testMultimarca_Modelo1_ConProducto() {
        insert new Product2(
            Name                  = 'BMW Serie 3',
            Codigo_de_Producto__c = 'BM19',
            ProductCode           = 'BM19',
            NombredePlantilla__c  = 'Cotizacion_BMW',
            IsActive              = true
        );
        Lead l = buildLead('BMW', null, null, null,
                           BMW_MODEL, true,
                           null, false, null, false, null, false,
                           null, null);
        Test.startTest();
        String result = WSenvioCotizacionTrafico.envioCotizacionMultimarca(l.Id, null);
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @isTest
    static void testMultimarca_Modelos234() {
        insert new List<Product2>{
            new Product2(Name='BMW P2', Codigo_de_Producto__c='BM81', ProductCode='BM81', NombredePlantilla__c='Cotizacion_BMW', IsActive=true),
            new Product2(Name='BMW P3', Codigo_de_Producto__c='BM83', ProductCode='BM83', NombredePlantilla__c='Cotizacion_BMW', IsActive=true),
            new Product2(Name='BMW P4', Codigo_de_Producto__c='BM65', ProductCode='BM65', NombredePlantilla__c='Cotizacion_BMW', IsActive=true)
        };
        Lead l = buildLead('BMW', null, null, null,
                           null, false,
                           BMW_MODEL_2, true,
                           BMW_MODEL_3, true,
                           BMW_MODEL_4, true,
                           null, null);
        Test.startTest();
        String result = WSenvioCotizacionTrafico.envioCotizacionMultimarca(l.Id, null);
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @isTest
    static void testMultimarca_ConAttachment() {
        EmailTemplate et = [SELECT Id, DeveloperName FROM EmailTemplate
                            WHERE DeveloperName = 'NewMultimarcacotizacion_1678510036978' LIMIT 1];
        insert new Attachment(
            ParentId    = et.Id,
            Name        = 'ficha.pdf',
            Body        = Blob.valueOf('FAKE PDF'),
            ContentType = 'application/pdf'
        );
        insert new Product2(
            Name                  = 'BMW Serie 3 Att',
            Codigo_de_Producto__c = 'BM19',
            ProductCode           = 'BM19',
            NombredePlantilla__c  = et.DeveloperName,
            IsActive              = true
        );
        Lead l = buildLead('BMW', null, null, null,
                           BMW_MODEL, true,
                           null, false, null, false, null, false,
                           null, null);
        Test.startTest();
        String result = WSenvioCotizacionTrafico.envioCotizacionMultimarca(l.Id, null);
        Test.stopTest();
        System.assertNotEquals(null, result);
    }
}