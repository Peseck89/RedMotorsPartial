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

                // //setear el mockup
        try {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(500, 'ERROR', getSuccessfullJsonResponse()));
        RM_CalloutException.dummy();
        } catch (Exception e) {
        }
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

        public MockHttpResponseGenerator(Integer code, String status, String body) {
            this.code = code;
            this.status = status;
            this.body = body;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(code);
            res.setStatus(status);
            res.setHeader('Content-Type', 'application/json');
            if(req.getEndpoint().contains('token')){
                res.setBody('{"access_token":"00001"}');
            }else{
                res.setBody(body);
            }
            return res;
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