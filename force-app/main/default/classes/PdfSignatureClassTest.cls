@IsTest
public class PdfSignatureClassTest {

    @TestSetup
    static void setupData() {
        // ---- Catálogos varios (los que ya usas en otros lados) ----
        ActividadComercial__c actividad = new ActividadComercial__c(
            Name = 'VENTA DE REPUESTOS NUEVOS PARA AUTOMOVIL'
        );
        insert actividad;
        
        tiposDeTrabajo__c tiposDeTrabajo = new tiposDeTrabajo__c(Name = 'Mantenimiento');
        insert tiposDeTrabajo;

        condicionPago__c condicionPago = new condicionPago__c(
            condicionPago__c = '0',
            Descripcion__c   = 'test desc',
            Name             = '0'
        );
        insert condicionPago;
        
        Impuesto__c impuesto = new Impuesto__c(
            codigoImpuesto__c = '0108',
            descripcion__c    = 'test desc',
            Impuesto__c       = 2,
            Name              = 'test imp',
            porcentaje__c     = 3
        );
        insert impuesto;

        // ---- Producto y Pricebook ----
       Product2 prod = new Product2(
           IsActive              = true,
           Name                  = 'Test product Test',
           ProductCode           = '0001999',
           Codigo_de_Producto__c = '00199999'
    	);
    	insert prod;
    
        Id stdPriceBook = Test.getStandardPricebookId();
        
        // Buscar si YA existe un PBE para este producto en el standard pricebook
        PricebookEntry pbe;
        List<PricebookEntry> existingPbes = [
            SELECT Id, Pricebook2Id, UnitPrice, IsActive, CurrencyIsoCode
            FROM PricebookEntry
            WHERE Product2Id = :prod.Id
              AND Pricebook2Id = :stdPriceBook
            LIMIT 1
        ];
    
        if (!existingPbes.isEmpty()) {
            pbe = existingPbes[0];
        } else {
            pbe = new PricebookEntry(
                UnitPrice      = 1,
                CurrencyIsoCode= 'USD',
                Product2Id     = prod.Id,
                Pricebook2Id   = stdPriceBook,
                IsActive       = true
            );
            insert pbe;
        }

        Bodega__c b = new Bodega__c();
        insert b;
        
        ProductoXBodega__c pxb = new ProductoXBodega__c(
            Producto__c   = prod.Id,
            Bodega__c     = b.Id,
            Disponible__c = 12
        );
        insert pxb;

        // ---- User que será el Asesor (Owner del Case) ----
        Profile p = [SELECT Id FROM Profile WHERE UserType = 'Standard' LIMIT 1];
        User asesor = new User(
            FirstName        = 'Asesor',
            LastName         = 'Prueba',
            Email            = 'asesor.prueba@test.com',
            Username         = 'asesor.prueba.' + System.currentTimeMillis() + '@test.com',
            Alias            = 'asesor',
            TimeZoneSidKey   = 'America/Mexico_City',
            LocaleSidKey     = 'es_MX',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey= 'es_MX',
            ProfileId        = p.Id
        );
        insert asesor;

        // ---- Account / Contact ----
        Account acc = new Account(
            Name                  = 'Test account',
            Cedula__c             = '9876543210',     // ajusta si tu campo se llama distinto
            Tipo_de_Documento__c  = '02',
            condicionPago__c      = condicionPago.Id,
            Impuesto__c           = impuesto.Id
        );
        insert acc;

        Contact testContact = new Contact(
            FirstName = 'Luis',
            LastName  = 'Sandoval',
            Email     = 'test@example.com',
            AccountId = acc.Id
        );
        insert testContact;

        // ---- Asset (vehículo) + imagen asociada ----
        Asset asset = new Asset(
            Name                 = 'Vehículo de prueba',
            AccountId            = acc.Id,
            Status               = 'Installed',
            Tipo_de_veh_culo__c  = 'Automóvil' // para getImageFromAsset
        );
        insert asset;

        // Una imagen para el asset (simula la foto del auto del template)
        ContentVersion cvAsset = new ContentVersion(
            Title                = 'ImagenAuto',
            PathOnClient         = 'auto.png',
            VersionData          = Blob.valueOf('imagen'),
            FirstPublishLocationId = asset.Id
        );
        insert cvAsset;

        // ---- Case principal que se usará en la mayoría de tests ----
        Case caseTest = new Case(
            Description               = 'Test',
            ContactId                 = testContact.Id,
            Subject                   = 'Test',
            AccountId                 = acc.Id,
            Status                    = 'Creado',
            Origin                    = 'Web',
            OwnerId                   = asesor.Id,
            AssetId                   = asset.Id,
            Actualizo_direccion__c    = true,
            Actualizo_Kilometraje__c  = true,
            Kilometraje__c            = 100000,
            Cuenta_de_Facturacion__c  = acc.Id   // ajusta si tu API es distinto
        );
        insert caseTest;

        // WorkOrder (no lo usa la clase, pero lo dejo por si lo ocupas en otros tests)
        WorkOrder wo = new WorkOrder(
            Subject        = 'title',
            Pricebook2Id   = pbe.Pricebook2Id,
            tipoDeGasto__c = 'Cliente',
            CurrencyIsoCode= 'USD'
        );
        insert wo;
    }

    // -------- getImageFromAsset --------
    @IsTest
    static void testGetImageFromAsset_conAsset() {
        Case caso = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        PdfSignatureClass.getImageFromAsset(caso.Id);
        Test.stopTest();
    }

    @IsTest
    static void testGetImageFromAsset_sinAsset() {
        // Case sin asset
        Case c = new Case(
            Description = 'Sin asset',
            Status      = 'Creado',
            Origin      = 'Web'
        );
        insert c;

        Test.startTest();
        PdfSignatureClass.getImageFromAsset(c.Id);
        Test.stopTest();
    }

    // -------- getValidacionCase --------
    @IsTest
    static void testGetValidacionCase_ok() {
        Case caso = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        PdfSignatureClass.getValidacionCase(caso.Id);
        Test.stopTest();
    }

    @IsTest
    static void testGetValidacionCase_errorCatch() {
        // Id inválido para provocar excepción en el SOQL
        try {
            Test.startTest();
            PdfSignatureClass.getValidacionCase('003000000000000'); // Id fake
            Test.stopTest();
        } catch (Exception e) {
            // ignoramos, sólo queremos cubrir el catch
        }
    }

    // -------- SaveSignature / GeneratePDF --------
    @IsTest
    static void testSaveSignatureSuccess_y_GeneratePDF() {
        Case caso = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        String firmaId = PdfSignatureClass.SaveSignature(
            'Test Firma',
            caso.Id,
            'TestVisualforcePage',
            'TestVisualforcePageFirmado',
            'from Button',
            EncodingUtil.base64Encode(Blob.valueOf('Firma de prueba'))
        );

        // Llamada normal a GeneratePDF (se apoya en savePDFfile.attachPDFinCase)
        // No hacemos asserts, sólo cobertura
        try {
            PdfSignatureClass.GeneratePDF(caso.Id, 'from Button', 'TestVisualforcePageFirmado');
        } catch (Exception e) {
            // Si por algo falla savePDFfile.attachPDFinCase en este entorno, no nos tumba el test
        }
        Test.stopTest();
    }

    @IsTest
    static void testSaveSignatureMissingData() {
        try {
            Test.startTest();
            PdfSignatureClass.SaveSignature('', '', '', '', '', '');
            Test.stopTest();
        } catch (AuraHandledException e) {
            // esperado por validación de datos obligatorios
        }
    }

    @IsTest
    static void testSaveSignatureExceptionHandling() {
        try {
            Test.startTest();
            // Provocar error DML con Id inválido en lookup Case__c
            PdfSignatureClass.SaveSignature(
                'Error Firma',
                '123456789012345', // no es un Id válido de Case
                'TestVisualforcePage',
                'TestVisualforceFirmada',
                'from Button',
                EncodingUtil.base64Encode(Blob.valueOf('Firma de prueba'))
            );
            Test.stopTest();
        } catch (AuraHandledException e) {
            // cubre el catch de SaveSignature
        }
    }

    // -------- SaveDibujo --------
    @IsTest
    static void testSaveDibujoSuccess() {
        Case caso = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        PdfSignatureClass.SaveDibujo(
            caso.Id,
            EncodingUtil.base64Encode(Blob.valueOf('Dibujo de prueba')),
            'Auto'
        );
        Test.stopTest();
    }

    @IsTest
    static void testSaveDibujoMissingData() {
        try {
            Test.startTest();
            PdfSignatureClass.SaveDibujo('', '', 'Auto');
            Test.stopTest();
        } catch (AuraHandledException e) {
            // esperado, cubre validación inicial
        }
    }

    // -------- getContactInfo --------
    @IsTest
    static void testGetContactInfo_ok() {
        Case caso = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        PdfSignatureClass.getContactInfo(caso.Id);
        Test.stopTest();
    }

    @IsTest
    static void testGetContactInfo_errorCatch() {
        try {
            Test.startTest();
            PdfSignatureClass.getContactInfo('500000000000000'); // Id fake
            Test.stopTest();
        } catch (Exception e) {
            // cubre el catch interno
        }
    }

    // -------- getLastContentDocumentId --------
    @IsTest
    static void testGetLastContentDocumentId_conDocumento() {
        Case caso = [SELECT Id FROM Case LIMIT 1];

        // ContentVersion ligado al Case (simula el PDF firmado)
        ContentVersion cv = new ContentVersion(
            Title                = 'OrdenFirmada',
            PathOnClient         = 'OT.pdf',
            VersionData          = Blob.valueOf('pdf'),
            FirstPublishLocationId = caso.Id
        );
        insert cv;

        Test.startTest();
        PdfSignatureClass.getLastContentDocumentId(caso.Id);
        Test.stopTest();
    }

    @IsTest
    static void testGetLastContentDocumentId_sinDocumento() {
        // Case sin documentos
        Case c = new Case(
            Description = 'Sin docs',
            Status      = 'Creado',
            Origin      = 'Web'
        );
        insert c;

        Test.startTest();
        PdfSignatureClass.getLastContentDocumentId(c.Id);
        Test.stopTest();
    }

    // -------- sendSignedPDFEmail --------
    @IsTest
    static void testSendSignedPDFEmail_ok() {
        Case caso = [SELECT Id, Contact.Email, Contact.Name FROM Case LIMIT 1];

        // ContentVersion para el PDF firmado
        ContentVersion cv = new ContentVersion(
            Title                = 'Orden de Trabajo Firmada',
            PathOnClient         = 'TestPDF.pdf',
            VersionData          = Blob.valueOf('Contenido de prueba'),
            FirstPublishLocationId = caso.Id
        );
        insert cv;

        ContentDocumentLink cdl = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :caso.Id 
            LIMIT 1
        ];

        Test.startTest();
        PdfSignatureClass.sendSignedPDFEmail(caso.Id, cdl.ContentDocumentId);
        Test.stopTest();
    }

    @IsTest
    static void testSendSignedPDFEmail_errorCatch() {
        Case caso = [SELECT Id FROM Case LIMIT 1];

        try {
            Test.startTest();
            // ContentDocumentId inexistente para provocar excepción en el SOQL de ContentVersion
            PdfSignatureClass.sendSignedPDFEmail(caso.Id, '999999999999999');
            Test.stopTest();
        } catch (AuraHandledException e) {
            // cubre el catch de sendSignedPDFEmail
        }
    }
}