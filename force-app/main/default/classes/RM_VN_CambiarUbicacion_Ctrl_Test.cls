/**
 * Clase de prueba para el controlador RM_VN_CambiarUbicacion_Ctrl
 * @author Redmotors
 * @since 05-09-2021
 */
@IsTest
public with sharing class RM_VN_CambiarUbicacion_Ctrl_Test {
    @TestSetup
    static void makeData(){
        RM_VN_DataFactoryHelper.createRecordsVN();
        ensureEmpresa('Bavarian', 'RMBAVARIAN', 'RMBAVARIAN');
        ensureEmpresa('Otobai', 'RMOTOBAI', 'RMOTOBAI');
        ensureEmpresa('PEKING', 'RMPEKING', 'RMPEKING');
    }

    @IsTest
    static void cambioBodegaExitosoTest(){    
        List<ProductoXBodega__c> productoXBodegas = [SELECT Id, Producto__c,Producto__r.vin__c, Bodega__c,Bodega__r.Name,Disponible__c, Bodega__r.ID_EXTERNO_BODEGA__c FROM ProductoXBodega__c WHERE Producto__r.esVehiculo__c = true LIMIT 1];
        ProductoXBodega__c productoXBodega = productoXBodegas[0];

        List<Bodega__c> bodegas = [SELECT Id, ID_EXTERNO_BODEGA__c FROM Bodega__c WHERE Id != :productoXBodega.Bodega__c LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, 'OK', getSuccessfullJsonResponse()));
        Test.startTest();
        RM_VN_CambiarUbicacion_Ctrl.guardar(productoXBodega.Id,bodegas[0].Id);
        Test.stopTest();

        RM_SoftlandClientResponse response = new RM_SoftlandClientResponse();
        response.operationResult = new RM_SoftlandClientOperationResult();
        response.operationResult.code = '00';
        response.operationResult.description = 'El vehiculo fue transferido correctamete.';

    }

    @IsTest
    static void cambioBodegaOtobaiUsaCompaniaOtobaiTest(){
        ProductoXBodega__c productoXBodega = getProductoXBodegaForCompany('RMOTOBAI');
        Bodega__c bodegaDestino = getDestino(productoXBodega.Bodega__c);

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, 'OK', getSuccessfullJsonResponse(), 'RMOTOBAI'));
        Test.startTest();
        Map<String, Object> response = RM_VN_CambiarUbicacion_Ctrl.guardar(productoXBodega.Id, bodegaDestino.Id);
        Test.stopTest();

        System.assertEquals(true, response.get('success'), 'La respuesta debe conservar el flujo exitoso para Otobai.');
    }

    @IsTest
    static void cambioBodegaPekingResuelveCodigoErpTest(){
        System.assertEquals(
            'RMPEKING',
            RM_VN_CambiarUbicacion_Ctrl.getCompanyName('RMPEKING'),
            'PEKING debe resolverse desde Empresa y no por una rama fija.'
        );
        System.assertEquals(
            'RMPEKING',
            RM_VN_CambiarUbicacion_Ctrl.getCompanyName('PEKING'),
            'El nombre de Empresa debe resolver el mismo código ERP.'
        );
    }

    @IsTest
    static void cambioBodegaEmpresaFuturaResuelveSinCambioDeCodigoTest(){
        ensureEmpresa('Empresa Futura', 'RMFUTURA', 'ERP-FUTURA');

        System.assertEquals(
            'ERP-FUTURA',
            RM_VN_CambiarUbicacion_Ctrl.getCompanyName('RMFUTURA'),
            'Una Empresa futura debe resolverse por configuración.'
        );
    }

    @IsTest
    static void cambioBodegaEmpresaNulaNoHaceFallbackBavarianTest(){
        ProductoXBodega__c productoXBodega = getProductoXBodegaForCompany(null);
        Bodega__c bodegaDestino = getDestino(productoXBodega.Bodega__c);

        Test.startTest();
        try {
            RM_VN_CambiarUbicacion_Ctrl.guardar(productoXBodega.Id, bodegaDestino.Id);
            System.assert(false, 'Una empresa nula no debe enviarse a Softland por fallback.');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e, 'Debe lanzarse un error controlado.');
        }
        Test.stopTest();
    }

    @IsTest
    static void validateUpdateQueueableTest(){
        List<ProductoXBodega__c> productoXBodegas = [SELECT Id, Producto__c,Producto__r.vin__c, Bodega__c,Bodega__r.Name,Disponible__c, Bodega__r.ID_EXTERNO_BODEGA__c FROM ProductoXBodega__c WHERE Producto__r.esVehiculo__c = true LIMIT 1];
        Bodega__c otraBodega= TestDataFactory.createBodega('Otra',true);
        Test.startTest();
            RM_VN_CambiarUbicacionQueueable executeUpdateCambioUbicacion = new RM_VN_CambiarUbicacionQueueable(productoXBodegas[0].Id,otraBodega.Id);
            System.enqueueJob(executeUpdateCambioUbicacion);
        Test.stopTest();
    }

    @IsTest
    static void searchLookUpBodegaTest(){    
        List<Bodega__c> bodegas = [SELECT Id, Name FROM Bodega__c LIMIT 1];
        Test.startTest();
        RM_VN_CambiarUbicacion_Ctrl.searchBodegas(bodegas[0].Name, null, 'Bodega__c', 'Bodega__c', 'Bodega', '', '');
        Test.stopTest();
    }

    //create a generic mockup class response
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        protected Integer code;
        protected String status;
        protected String body;
        protected String expectedCompany;

        public MockHttpResponseGenerator(Integer code, String status, String body) {
            this.code = code;
            this.status = status;
            this.body = body;
        }

        public MockHttpResponseGenerator(Integer code, String status, String body, String expectedCompany) {
            this(code, status, body);
            this.expectedCompany = expectedCompany;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(code);
            res.setStatus(status);
            res.setHeader('Content-Type', 'application/json');
            if(req.getEndpoint().contains('token')){
                res.setBody('{"access_token":"00001"}');
            }else{
                if (String.isNotBlank(expectedCompany)) {
                    System.assert(
                        req.getBody().contains('"compania":"' + expectedCompany + '"'),
                        'El callout debe usar la compañía esperada.'
                    );
                }
                res.setBody(body);
            }
            return res;
        }
    }

    private static ProductoXBodega__c getProductoXBodegaForCompany(String empresa) {
        Boolean useNonVehicleProduct = empresa == 'RMPEKING';
        Boolean isVehicleProduct = !useNonVehicleProduct;
        ProductoXBodega__c productoXBodega = [
            SELECT Id, Producto__c, Bodega__c
            FROM ProductoXBodega__c
            WHERE Producto__r.esVehiculo__c = :isVehicleProduct
            LIMIT 1
        ];
        Product2 producto = new Product2(
            Id = productoXBodega.Producto__c,
            Empresa__c = empresa
        );
        update producto;
        return productoXBodega;
    }

    private static Bodega__c getDestino(Id bodegaOrigenId) {
        return [
            SELECT Id, ID_EXTERNO_BODEGA__c
            FROM Bodega__c
            WHERE Id != :bodegaOrigenId
            LIMIT 1
        ];
    }

    private static void ensureEmpresa(String name, String codigo, String codigoErp) {
        if ([SELECT COUNT() FROM Empresa__c WHERE Codigo__c = :codigo] == 0) {
            insert new Empresa__c(
                Name = name,
                Codigo__c = codigo,
                Codigo_ERP__c = codigoErp,
                Nombre_Legal__c = name + ' Test S.A.',
                Activa__c = true
            );
        }
    }

    /**
     * Metodo que valida el cambio de bodega desde el servicio
     * @return  {"operationResult":{"code":"02","description":"El codigo del articulo no es valido."}}
     */
    public static String getSuccessfullJsonResponse(){
    return '{' +
            '"operationResult": {' +
                '"code": "00",' +
                '"description": "El vehiculo fue transferido correctamete."' +
            '}' +
        '}';
    }

    /**
     * Metodo que valida el cambio de bodega desde el servicio
     * @return  {"operationResult":{"code":"02","description":"El codigo del articulo no es valido."}}
     */
    public static String getFailledJsonResponse(){
        return '{' +
            '"operationResult": {' +
                '"code": "00",' +
                '"description": "El cambio ha sido exitoso"' +
            '}' +
        '}';
    }
}
