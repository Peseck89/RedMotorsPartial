@isTest
public class ContentDocumentLinkTriggerTest {
	
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"Caso":"AAAAA555555","Taller":"AAAAA555555","Etapa":"AAAAA555555","Matricula":"AAAAA555555","VIN":"AAAAA555555","Marca":"AAAAA555555","Modelo":"AAAAA555555","Anio":"AAAAA555555","Asesor":"AAAAA555555","Tipo de Vehiculo":"AAAAA555555","Fecha Entrada":"2025-03-19T03:36:10.212Z","Estado Caso":"AAAAA555555","Inicio Etapa":"2025-03-19T03:36:10.212Z","Fin Etapa":"2025-03-19T03:36:10.212Z","Fecha Hora Ejecucion":"2025-03-19T03:36:10.212Z","Minutos Laborales":98.6,"Hora Laborales":98.6,"Estatus de Etapa":"AAAAA555555","ID del Caso":"AAAAA555555"}]');
            res.setStatusCode(200);
            return res;
        }
    }
    @isTest
    static void testContentDocumentLinkTrigger() {
        // Crear los registros necesarios para la prueba
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        condicionPago__c ConPag = new condicionPago__c(condicionPago__c='0');
        insert ConPag;

        ActividadComercial__c ActCom = new ActividadComercial__c(Name = 'VENTA DE REPUESTOS NUEVOS PARA AUTOMOVIL');
        insert ActCom;

        Impuesto__c imp = new Impuesto__c(Name='IVA-Tarifa General 13%');
        insert imp;

        Account Acc = new Account(
            Name = 'Test Acc',
            Cedula__c = '9876543210',
            Tipo_de_Documento__c = '02',
            codigoSoftland__c = '1234'
        );
        insert Acc;

        Case testCase = new Case(Subject = 'Test');
        insert testCase;

        Pricebook2 PriceBook = new Pricebook2(Name = 'TestPB', IsActive = true);
        insert PriceBook;

        WorkOrder WO = new WorkOrder(CaseId = testCase.Id, Pricebook2Id = PriceBook.Id, AccountId = Acc.Id);
        insert WO;

        tiposDeTrabajoCaso__c tipoDeTrabajoCaso = new tiposDeTrabajoCaso__c(Caso__c = testCase.Id);
        insert tipoDeTrabajoCaso;

        Product2 Prod = new Product2(Name = 'Test Prod', Codigo_de_Producto__c = 'TestProd', tipoProducto__c = 'Mano de Obra');
        insert Prod;

        PricebookEntry PBE = new PricebookEntry(Pricebook2Id = PriceBook.Id, Product2Id = Prod.Id, UnitPrice = 5, IsActive = true); 
        insert PBE;

        Subtipo_de_trabajo_del_caso__c subtipoDeTrabajoCaso = new Subtipo_de_trabajo_del_caso__c(
            Name = 'Test',
            Caso__c = testCase.Id,
            Orden_de_trabajo__c = WO.Id,
            Tipo_de_trabajo_del_caso__c = tipoDeTrabajoCaso.Id,
            Cantidad_de_horas__c = 4
        );
        insert subtipoDeTrabajoCaso;

        Test.startTest();

        // Asociar ContentVersion a tipoDeTrabajoCaso
        ContentVersion content1 = new ContentVersion(
            Title = 'FotoTrabajo',
            PathOnClient = '/FotoTrabajo.jpg',
            VersionData = Blob.valueOf('contenido'),
            Origin = 'H'
        );
        insert content1;

        ContentDocumentLink contentlink1 = new ContentDocumentLink(
            LinkedEntityId = tipoDeTrabajoCaso.Id,
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :content1.Id].ContentDocumentId,
            ShareType = 'I'
        );
        insert contentlink1;

        // Asociar ContentVersion a subtipoDeTrabajoCaso
        ContentVersion content2 = new ContentVersion(
            Title = 'VideoTrabajo',
            PathOnClient = '/VideoTrabajo.mp4',
            VersionData = Blob.valueOf('contenido'),
            Origin = 'H'
        );
        insert content2;

        ContentDocumentLink contentlink2 = new ContentDocumentLink(
            LinkedEntityId = subtipoDeTrabajoCaso.Id,
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :content2.Id].ContentDocumentId,
            ShareType = 'I'
        );
        insert contentlink2;

        // Crear PDF y asociar a producto
        ContentVersion contentPdf = new ContentVersion(
            Title = 'FichaTecnica',
            PathOnClient = '/FichaTecnica.pdf',
            VersionData = Blob.valueOf('contenido pdf'),
            Origin = 'H'
        );
        insert contentPdf;

        ContentDocumentLink contentlinkPdf = new ContentDocumentLink(
            LinkedEntityId = Prod.Id,
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentPdf.Id].ContentDocumentId,
            ShareType = 'I'
        );
        insert contentlinkPdf;

        Test.stopTest();

        // Validar si se llenó Link_ficha_t_cnica__c (sin asserts)
        Prod = [SELECT Link_ficha_t_cnica__c FROM Product2 WHERE Id = :Prod.Id LIMIT 1];
        System.debug('Link generado en producto: ' + Prod.Link_ficha_t_cnica__c);

        // Validar la eliminación también
        delete contentlink1;
        delete contentlink2;
        delete contentlinkPdf;
    }
}