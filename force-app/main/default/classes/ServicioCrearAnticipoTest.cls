@IsTest
private class ServicioCrearAnticipoTest {
    private static final String HELIOS_ID = '176316';
    private static final String SOFTLAND_ID = '00000089';

    private static User createUserWithAnticipoPermissions() {
        User currentUser = [
            SELECT ProfileId, LocaleSidKey, LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];
        String uniqueValue = String.valueOf(DateTime.now().getTime()) + String.valueOf(Math.abs(Crypto.getRandomInteger()));
        User testUser = new User(
            Username = 'vn106.servicio.' + uniqueValue + '@example.com',
            Email = 'vn106.servicio.' + uniqueValue + '@example.com',
            LastName = 'VN106 Servicio',
            Alias = 'vn106s',
            CommunityNickname = 'vn106s' + uniqueValue.right(8),
            ProfileId = currentUser.ProfileId,
            LocaleSidKey = currentUser.LocaleSidKey,
            LanguageLocaleKey = currentUser.LanguageLocaleKey,
            TimeZoneSidKey = currentUser.TimeZoneSidKey,
            EmailEncodingKey = String.isBlank(currentUser.EmailEncodingKey) ? 'UTF-8' : currentUser.EmailEncodingKey
        );
        insert testUser;

        PermissionSet permissionSet = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'VN_RQ106_Anticipo'
            LIMIT 1
        ];
        insert new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = permissionSet.Id);
        return testUser;
    }

    private static Anticipo__c createAnticipo() {
        Account account = new Account(
            Name = 'Cliente Servicio Crear Anticipo',
            codigoSoftland__c = 'C126750'
        );
        insert account;

        Opportunity opportunity = new Opportunity(
            Name = 'Oportunidad Servicio Crear Anticipo',
            AccountId = account.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(15),
            Pricebook2Id = Test.getStandardPricebookId(),
            CurrencyIsoCode = 'USD',
            empresaQueFactura__c = 'Bavarian'
        );
        insert opportunity;

        Anticipo__c anticipo = new Anticipo__c(
            Oportunidad__c = opportunity.Id,
            Identificador__c = SOFTLAND_ID,
            Identificador_Helios__c = HELIOS_ID,
            Estatus__c = 'En validación de Tesorería',
            Tipo_Ingreso__c = 'Abono',
            Medio_Pago__c = 'Transferencia',
            Fecha_Ingreso__c = Date.today(),
            Referencia_Comprobante__c = 'REF-SOFTLAND',
            Depositante__c = 'Cliente Servicio',
            Monto__c = 200,
            CurrencyIsoCode = 'USD',
            Comentarios_Asesor__c = 'Evidencia enviada a Tesorería'
        );
        insert anticipo;

        return anticipo;
    }

    private static ServicioCrearAnticipo.RespuestaRest invokeService(Map<String, Object> payload) {
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/CrearAnticipo/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(payload));
        RestContext.request = request;
        RestContext.response = new RestResponse();

        return ServicioCrearAnticipo.crearAnticipo();
    }

    @IsTest
    static void crearAnticipoWithLegacyPdfLinkUpdatesAnticipo() {
        User userWithPermissions = createUserWithAnticipoPermissions();
        System.runAs(userWithPermissions) {
            Anticipo__c anticipo = createAnticipo();
            String pdfLink = 'https://example.com/pdf/176316.pdf';

            Test.startTest();
            ServicioCrearAnticipo.RespuestaRest response = invokeService(new Map<String, Object>{
                'identificadorHelios' => HELIOS_ID,
                'identificadorSoftland' => SOFTLAND_ID,
                'estado' => 'Anticipo creado',
                'comentarios' => 'SE APRUEBA LA SOLICITUD',
                'linkpdf' => pdfLink
            });
            Test.stopTest();

            Anticipo__c updated = [
                SELECT Id, Identificador__c, Estatus__c,
                    Comentarios_Aprobacion_Rechazo__c, PDF_Anticipo_Softland__c
                FROM Anticipo__c
                WHERE Id = :anticipo.Id
            ];

            System.assertEquals(true, response.exito);
            System.assertEquals(anticipo.Id, response.idAnticipo);
            System.assertEquals(SOFTLAND_ID, updated.Identificador__c);
            System.assertEquals('Anticipo creado', updated.Estatus__c);
            System.assertEquals('SE APRUEBA LA SOLICITUD', updated.Comentarios_Aprobacion_Rechazo__c);
            System.assertEquals(pdfLink, updated.PDF_Anticipo_Softland__c);
        }
    }

    @IsTest
    static void crearAnticipoWithBase64PdfCreatesFileAndInternalLink() {
        User userWithPermissions = createUserWithAnticipoPermissions();
        System.runAs(userWithPermissions) {
            Anticipo__c anticipo = createAnticipo();
            String pdfBase64 = EncodingUtil.base64Encode(Blob.valueOf('%PDF-1.4 test pdf'));

            Test.startTest();
            ServicioCrearAnticipo.RespuestaRest response = invokeService(new Map<String, Object>{
                'identificadorHelios' => HELIOS_ID,
                'identificadorSoftland' => SOFTLAND_ID,
                'estado' => 'Anticipo creado',
                'comentarios' => 'SE APRUEBA LA SOLICITUD',
                'pdf' => pdfBase64
            });
            Test.stopTest();

            Anticipo__c updated = [
                SELECT Id, Identificador__c, Estatus__c,
                    Comentarios_Aprobacion_Rechazo__c, PDF_Anticipo_Softland__c
                FROM Anticipo__c
                WHERE Id = :anticipo.Id
            ];
            List<ContentDocumentLink> links = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :anticipo.Id
            ];
            List<ContentVersion> versions = [
                SELECT Id, Title, PathOnClient, ContentDocumentId
                FROM ContentVersion
                WHERE ContentDocumentId = :links[0].ContentDocumentId
                    AND IsLatest = true
            ];

            System.assertEquals(true, response.exito);
            System.assertEquals(null, response.advertencia);
            System.assertEquals(SOFTLAND_ID, updated.Identificador__c);
            System.assertEquals('Anticipo creado', updated.Estatus__c);
            System.assertEquals('SE APRUEBA LA SOLICITUD', updated.Comentarios_Aprobacion_Rechazo__c);
            System.assert(updated.PDF_Anticipo_Softland__c.startsWith('/sfc/servlet.shepherd/version/download/'));
            System.assertEquals(1, links.size());
            System.assertEquals(1, versions.size());
            System.assertEquals('PDF Softland - ' + HELIOS_ID, versions[0].Title);
            System.assertEquals('PDF_Softland_' + HELIOS_ID + '.pdf', versions[0].PathOnClient);
            System.assert(updated.PDF_Anticipo_Softland__c.endsWith(versions[0].Id));
        }
    }

    @IsTest
    static void crearAnticipoWithInvalidPdfKeepsFunctionalUpdate() {
        User userWithPermissions = createUserWithAnticipoPermissions();
        System.runAs(userWithPermissions) {
            Anticipo__c anticipo = createAnticipo();

            Test.startTest();
            ServicioCrearAnticipo.RespuestaRest response = invokeService(new Map<String, Object>{
                'identificadorHelios' => HELIOS_ID,
                'identificadorSoftland' => SOFTLAND_ID,
                'estado' => 'Anticipo creado',
                'comentarios' => 'SE APRUEBA LA SOLICITUD',
                'pdf' => 'base64-invalido'
            });
            Test.stopTest();

            Anticipo__c updated = [
                SELECT Id, Identificador__c, Estatus__c,
                    Comentarios_Aprobacion_Rechazo__c, PDF_Anticipo_Softland__c
                FROM Anticipo__c
                WHERE Id = :anticipo.Id
            ];

            System.assertEquals(true, response.exito);
            System.assertNotEquals(null, response.advertencia);
            System.assertEquals(SOFTLAND_ID, updated.Identificador__c);
            System.assertEquals('Anticipo creado', updated.Estatus__c);
            System.assertEquals('SE APRUEBA LA SOLICITUD', updated.Comentarios_Aprobacion_Rechazo__c);
            System.assertEquals(null, updated.PDF_Anticipo_Softland__c);
            System.assertEquals(0, [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :anticipo.Id]);
        }
    }

    @IsTest
    static void crearAnticipoWithSecondBase64PdfCreatesNewVersion() {
        User userWithPermissions = createUserWithAnticipoPermissions();
        System.runAs(userWithPermissions) {
            Anticipo__c anticipo = createAnticipo();
            String firstPdf = EncodingUtil.base64Encode(Blob.valueOf('%PDF-1.4 first pdf'));
            String secondPdf = EncodingUtil.base64Encode(Blob.valueOf('%PDF-1.4 second pdf'));

            Test.startTest();
            invokeService(new Map<String, Object>{
                'identificadorHelios' => HELIOS_ID,
                'pdf' => firstPdf
            });
            ServicioCrearAnticipo.RespuestaRest response = invokeService(new Map<String, Object>{
                'identificadorHelios' => HELIOS_ID,
                'pdf' => secondPdf
            });
            Test.stopTest();

            List<ContentDocumentLink> links = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :anticipo.Id
            ];
            List<ContentVersion> versions = [
                SELECT Id, ContentDocumentId, IsLatest
                FROM ContentVersion
                WHERE ContentDocumentId = :links[0].ContentDocumentId
                ORDER BY CreatedDate ASC
            ];
            Anticipo__c updated = [
                SELECT PDF_Anticipo_Softland__c
                FROM Anticipo__c
                WHERE Id = :anticipo.Id
            ];

            System.assertEquals(true, response.exito);
            System.assertEquals(1, links.size());
            System.assertEquals(2, versions.size());
            System.assertEquals(false, versions[0].IsLatest);
            System.assertEquals(true, versions[1].IsLatest);
            System.assert(updated.PDF_Anticipo_Softland__c.endsWith(versions[1].Id));
        }
    }
}
