@isTest
private class ProductoLocalizacionHelperTest {

    private class ProductoLocalizacionHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"Data":[{"bodega":"BR01","localizacion":"E0","cant_disponible":5.0}]}');
            return res;
        }
    }

    @isTest static void testObtenerLocalizaciones_exito() {
        Test.setMock(HttpCalloutMock.class, new ProductoLocalizacionHttpMock());
        Test.startTest();
        String codigoProducto = 'L00078';
        String compania = 'RMBAVARIAN';
        HttpResponse res = new ProductoLocalizacionHelper().obtenerLocalizaciones(codigoProducto, compania);
        Test.stopTest();

        System.assertEquals(200, res.getStatusCode(), 'La respuesta debe tener código 200');
        System.assert(res.getBody().contains('BR01'), 'El body debe contener la bodega simulada');
    }
}