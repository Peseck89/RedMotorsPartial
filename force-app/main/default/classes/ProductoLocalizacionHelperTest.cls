@isTest
private class ProductoLocalizacionHelperTest {

    private class ProductoLocalizacionHttpMock implements HttpCalloutMock {
        private String expectedCompany;

        ProductoLocalizacionHttpMock(String expectedCompany) {
            this.expectedCompany = expectedCompany;
        }

        public HTTPResponse respond(HTTPRequest req) {
            Map<String, Object> body =
                (Map<String, Object>) JSON.deserializeUntyped(req.getBody());
            System.assertEquals(expectedCompany, body.get('compania'));
            System.assertEquals('L00078', body.get('articulo'));
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"Data":[{"bodega":"BR01","localizacion":"E0","cant_disponible":5.0}]}');
            return res;
        }
    }

    @isTest static void testObtenerLocalizaciones_exito() {
        Test.setMock(HttpCalloutMock.class, new ProductoLocalizacionHttpMock('RMPEKING'));
        Test.startTest();
        String codigoProducto = 'L00078';
        String compania = 'rmpeking';
        HttpResponse res = new ProductoLocalizacionHelper().obtenerLocalizaciones(codigoProducto, compania);
        Test.stopTest();

        System.assertEquals(200, res.getStatusCode(), 'La respuesta debe tener código 200');
        System.assert(res.getBody().contains('BR01'), 'El body debe contener la bodega simulada');
    }

    @isTest static void testObtenerLocalizaciones_rechazaEmpresaVacia() {
        Boolean receivedExpectedError = false;
        try {
            new ProductoLocalizacionHelper().obtenerLocalizaciones('L00078', ' ');
        } catch (AuraHandledException ex) {
            receivedExpectedError = ex.getMessage().contains('Código Softland');
        }
        System.assert(receivedExpectedError);
    }
}
