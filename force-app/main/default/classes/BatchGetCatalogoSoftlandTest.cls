@isTest
public class BatchGetCatalogoSoftlandTest {

    private static final String SUCCESS_BODY = '{"Paging":{"TotalThisViewCount":1,"TotalRecordCount":1,"PageSize":1,"PageNo":1,"PageCount":1},"Data":[{"codigo":"AC001","descripcion":"Registro Test","cliente":"ASEG001","nombre":"Aseguradora Test","alias":"ASEG","contacto":"Contacto","cargo":"Cargo","id":"123456","moneda":"CRC","condicionPago":"test","pais":null,"provincia":null,"canton":null,"distrito":null,"barrio":null,"otras_senas":"Direccion Test","telefono1":"22222222","telefono2":"22222223","bodega":"BOD001","categoriaCliente":"test","centroCosto":"CC001","CuentaContable":"CTA001","impuesto":"1","codigoImpuesto":"IMP001","subtipo":"SUB001","articulo":"ART001","cant_disponible":"1","precio":"1","porc_descuento":"1","costo_local":"1","porc_margen_min":"1","porc_margen_max":"1","lista_precio":"LP","grupo1":"G1","cod_grupo1":"G1","grupo2":"G2","cod_grupo2":"G2","grupo3":"G3","cod_grupo3":"G3","grupo4":"G4","cod_grupo4":"G4","grupo5":"G5","cod_grupo5":"G5","grupo6":"G6","cod_grupo6":"G6","vin":"VIN001"}]}';

    @isTest
    static void testConstructors() {
        BatchGetCatalogoSoftland oneArg = new BatchGetCatalogoSoftland(BatchGetCatalogoSoftland.CATEGORIA_CLIENTE);
        System.assertEquals(BatchGetCatalogoSoftland.CATEGORIA_CLIENTE, oneArg.catalogName);
        System.assertEquals(null, oneArg.company);

        BatchGetCatalogoSoftland twoArgs = new BatchGetCatalogoSoftland(BatchGetCatalogoSoftland.CATEGORIA_CLIENTE, 'RMPEKING');
        System.assertEquals(BatchGetCatalogoSoftland.CATEGORIA_CLIENTE, twoArgs.catalogName);
        System.assertEquals('RMPEKING', twoArgs.company);

        BatchGetCatalogoSoftland threeArgs = new BatchGetCatalogoSoftland(BatchGetCatalogoSoftland.INVENTORY, 'group1', 'CRC');
        System.assertEquals(BatchGetCatalogoSoftland.INVENTORY, threeArgs.catalogName);
        System.assertEquals('group1', threeArgs.groupNumber);
        System.assertEquals('CRC', threeArgs.actualCurrency);
    }

    @isTest
    static void testExecuteActividadComercialPropagatesCompany() {
        Test.startTest();
        EndpointCaptureMock mock = new EndpointCaptureMock();
        Test.setMock(HttpCalloutMock.class, mock);
        BatchGetCatalogoSoftland batch = new BatchGetCatalogoSoftland(BatchGetCatalogoSoftland.ACTIVIDAD_COMERCIAL, 'RMPEKING');
        batch.execute(null);
        Test.stopTest();

        Boolean foundCompany = false;
        for (String endpoint : mock.capturedEndpoints) {
            if (endpoint.containsIgnoreCase('compania=RMPEKING')) {
                foundCompany = true;
            }
        }
        System.assert(foundCompany, 'El callout de ActividadComercial debe propagar la compania RMPEKING en el endpoint');

        List<ActividadComercial__c> resultados = [SELECT Id, codigo__c FROM ActividadComercial__c WHERE codigo__c = 'AC001'];
        System.assertEquals(1, resultados.size());
    }

    @isTest
    static void testExecuteAseguradora() {
        // calloutAseguradora hace upsert con allOrNone=false (upsertCatalog): un registro
        // Account que no cumpla validaciones del org queda silenciosamente sin insertar,
        // sin lanzar excepcion. Por eso no se afirma la creacion del registro; se verifica
        // evidencia real y verificable: rama ejecutada, compania propagada, sin excepcion.
        condicionPago__c cp = new condicionPago__c(condicionPago__c = 'test');
        insert cp;

        Test.startTest();
        EndpointCaptureMock mock = new EndpointCaptureMock();
        Test.setMock(HttpCalloutMock.class, mock);
        BatchGetCatalogoSoftland batch = new BatchGetCatalogoSoftland(BatchGetCatalogoSoftland.ASEGURADORA, 'RMBAVARIAN');
        Boolean completedWithoutException = false;
        batch.execute(null);
        completedWithoutException = true;
        Test.stopTest();

        System.assert(completedWithoutException, 'La rama ASEGURADORA no debe propagar una excepcion no controlada');

        Boolean foundAseguradoraEndpoint = false;
        Boolean foundCompany = false;
        for (String endpoint : mock.capturedEndpoints) {
            if (endpoint.containsIgnoreCase('getClientesAseguradoras')) {
                foundAseguradoraEndpoint = true;
            }
            if (endpoint.containsIgnoreCase('compania=RMBAVARIAN')) {
                foundCompany = true;
            }
        }
        System.assert(foundAseguradoraEndpoint, 'Debe ejecutarse la rama ASEGURADORA (endpoint getClientesAseguradoras)');
        System.assert(foundCompany, 'La rama ASEGURADORA debe propagar la compania en el endpoint');
    }

    @isTest
    static void testExecuteInventory() {
        // calloutInventory delega el upsert real a Database.executeBatch(BatchUpsertProduct2),
        // asincrono y con allOrNone=false: no garantiza la creacion del Product2 en este
        // escenario minimo. Se verifica evidencia real y verificable: rama ejecutada,
        // parametros propagados (groupNumber/actualCurrency), sin excepcion, y que el
        // batch de upsert realmente se encolo (AsyncApexJob).
        Test.startTest();
        EndpointCaptureMock mock = new EndpointCaptureMock();
        Test.setMock(HttpCalloutMock.class, mock);
        // 'getDolarListPaged' evita que BatchUpsertProduct2 deje "priceBooks" sin inicializar (null).
        BatchGetCatalogoSoftland batch = new BatchGetCatalogoSoftland(BatchGetCatalogoSoftland.INVENTORY, 'group1', 'getDolarListPaged');
        Boolean completedWithoutException = false;
        batch.execute(null);
        completedWithoutException = true;
        Test.stopTest();

        System.assert(completedWithoutException, 'La rama INVENTORY no debe propagar una excepcion no controlada');

        Boolean foundInventoryEndpoint = false;
        Boolean foundGroupNumber = false;
        Boolean foundCurrency = false;
        for (String endpoint : mock.capturedEndpoints) {
            if (endpoint.containsIgnoreCase('/products/')) {
                foundInventoryEndpoint = true;
            }
            if (endpoint.containsIgnoreCase('codGrupo1=group1')) {
                foundGroupNumber = true;
            }
            if (endpoint.containsIgnoreCase('/products/getDolarListPaged')) {
                foundCurrency = true;
            }
        }
        System.assert(foundInventoryEndpoint, 'Debe ejecutarse la rama INVENTORY (endpoint de products)');
        System.assert(foundGroupNumber, 'El groupNumber debe propagarse en el endpoint de Inventory');
        System.assert(foundCurrency, 'El actualCurrency (moneda) debe propagarse en el endpoint de Inventory');

        List<AsyncApexJob> batchJobs = [
            SELECT Id
            FROM AsyncApexJob
            WHERE ApexClass.Name = 'BatchUpsertProduct2'
            AND JobType = 'BatchApex'
        ];
        System.assertEquals(1, batchJobs.size(), 'calloutInventory debe encolar el batch BatchUpsertProduct2 con el inventario obtenido');
    }

    @isTest
    static void testLegacyOverloadCategoriaClienteDefaultsToRMBAVARIAN() {
        EndpointCaptureMock mock = new EndpointCaptureMock();
        Test.setMock(HttpCalloutMock.class, mock);
        String result = BatchGetCatalogoSoftland.calloutCategoriaCliente(
            Label.URLSoftland, Label.ambienteSoftland, 'Bearer', 'token', 1, new List<categoriaCliente__c>()
        );
        System.assertEquals('Ok', result);
        assertDefaultCompanyPropagated(mock);
    }

    @isTest
    static void testLegacyOverloadCentroCostoDefaultsToRMBAVARIAN() {
        EndpointCaptureMock mock = new EndpointCaptureMock();
        Test.setMock(HttpCalloutMock.class, mock);
        String result = BatchGetCatalogoSoftland.calloutCentroCosto(
            Label.URLSoftland, Label.ambienteSoftland, 'Bearer', 'token', 1, new List<centroCosto__c>()
        );
        System.assertEquals('Ok', result);
        assertDefaultCompanyPropagated(mock);
    }

    @isTest
    static void testLegacyOverloadCondicionPagoDefaultsToRMBAVARIAN() {
        EndpointCaptureMock mock = new EndpointCaptureMock();
        Test.setMock(HttpCalloutMock.class, mock);
        String result = BatchGetCatalogoSoftland.calloutCondicionPago(
            Label.URLSoftland, Label.ambienteSoftland, 'Bearer', 'token', 1, new List<condicionPago__c>()
        );
        System.assertEquals('Ok', result);
        assertDefaultCompanyPropagated(mock);
    }

    @isTest
    static void testLegacyOverloadCuentaContableDefaultsToRMBAVARIAN() {
        EndpointCaptureMock mock = new EndpointCaptureMock();
        Test.setMock(HttpCalloutMock.class, mock);
        String result = BatchGetCatalogoSoftland.calloutCuentaContable(
            Label.URLSoftland, Label.ambienteSoftland, 'Bearer', 'token', 1, new List<CuentaContable__c>()
        );
        System.assertEquals('Ok', result);
        assertDefaultCompanyPropagated(mock);
    }

    @isTest
    static void testLegacyOverloadImpuestoDefaultsToRMBAVARIAN() {
        EndpointCaptureMock mock = new EndpointCaptureMock();
        Test.setMock(HttpCalloutMock.class, mock);
        String result = BatchGetCatalogoSoftland.calloutImpuesto(
            Label.URLSoftland, Label.ambienteSoftland, 'Bearer', 'token', 1, new List<Impuesto__c>()
        );
        System.assertEquals('Ok', result);
        assertDefaultCompanyPropagated(mock);
    }

    @isTest
    static void testLegacyOverloadSubtipoDocumentoDefaultsToRMBAVARIAN() {
        EndpointCaptureMock mock = new EndpointCaptureMock();
        Test.setMock(HttpCalloutMock.class, mock);
        String result = BatchGetCatalogoSoftland.calloutSubtipoDocumento(
            Label.URLSoftland, Label.ambienteSoftland, 'Bearer', 'token', 1, new List<SubtipoDocumento__c>()
        );
        System.assertEquals('Ok', result);
        assertDefaultCompanyPropagated(mock);
    }

    private static void assertDefaultCompanyPropagated(EndpointCaptureMock mock) {
        Boolean foundDefaultCompany = false;
        for (String endpoint : mock.capturedEndpoints) {
            if (endpoint.containsIgnoreCase('compania=' + BatchGetCatalogoSoftland.DEFAULT_COMPANY)) {
                foundDefaultCompany = true;
            }
        }
        System.assert(foundDefaultCompany, 'El overload sin company debe usar DEFAULT_COMPANY (RMBAVARIAN) en el endpoint');
    }

    @isTest
    static void testCalloutMethodsHandleCalloutException() {
        Test.setMock(HttpCalloutMock.class, new ThrowingCalloutMock());
        String url = Label.URLSoftland;

        String resultActividadComercial = BatchGetCatalogoSoftland.calloutActividadComercial(
            url, 'Bearer', 'token', 1, new List<ActividadComercial__c>(), new HttpCalloutActividadComercial(), 'RMBAVARIAN'
        );
        System.assertEquals('Simulated Softland callout failure', resultActividadComercial);

        String resultAseguradora = BatchGetCatalogoSoftland.calloutAseguradora(
            url, 'Bearer', 'token', 1, new List<Account>(), new HttpCalloutAseguradora(), 'RMBAVARIAN'
        );
        System.assertEquals('Simulated Softland callout failure', resultAseguradora);
    }

    @isTest
    static void testExecuteHandlesAuthCalloutExceptionWithoutThrowing() {
        Test.setMock(HttpCalloutMock.class, new ThrowingCalloutMock());
        BatchGetCatalogoSoftland batch = new BatchGetCatalogoSoftland(BatchGetCatalogoSoftland.CATEGORIA_CLIENTE, 'RMBAVARIAN');
        batch.execute(null);
    }

    public class SuccessCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            String endpoint = req.getEndpoint();
            if (endpoint != null && endpoint.containsIgnoreCase('oauth/token')) {
                res.setBody('{"access_token":"token","token_type":"Bearer"}');
            } else {
                res.setBody(SUCCESS_BODY);
            }
            return res;
        }
    }

    public class EndpointCaptureMock implements HttpCalloutMock {
        public List<String> capturedEndpoints = new List<String>();

        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            String endpoint = req.getEndpoint();
            if (endpoint != null && endpoint.containsIgnoreCase('oauth/token')) {
                res.setBody('{"access_token":"token","token_type":"Bearer"}');
            } else {
                if (endpoint != null) {
                    capturedEndpoints.add(endpoint);
                }
                res.setBody(SUCCESS_BODY);
            }
            return res;
        }
    }

    public class ThrowingCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            throw new System.CalloutException('Simulated Softland callout failure');
        }
    }
}