@isTest
private class ServicioActualizaPlacaTest {

    @isTest
    static void testActualizarNombreProducto_exito() {
        // Crear un producto con un VIN como nombre
        Product2 producto = new Product2(Name = '1HGCM82633A004352', Codigo_de_Producto__c ='1HGCM82633A004352',  es_Vehiculo_usado__c=TRUE);
        insert producto;

        // JSON de entrada con VIN existente y nueva placa
        String jsonBody = '{"original":"1HGCM82633A004352", "cambio":"B123456"}';

        // Simular la llamada REST
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/actualizaProductoPorVin';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);

        RestContext.request = req;
        RestContext.response = res;

        // Ejecutar el método
        ServicioActualizaPlaca.actualizarNombreProducto();

        // Verificar que el nombre del producto fue actualizado
        Product2 actualizado = [SELECT Name, Codigo_de_Producto__c FROM Product2 WHERE Id = :producto.Id];
        System.assertEquals('B123456', actualizado.Codigo_de_Producto__c);
    }

    @isTest
    static void testActualizarNombreProducto_sinProducto() {
        String jsonBody = '{"original":"NO_EXISTE", "cambio":"B999999"}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/actualizaProductoPorVin';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);

        RestContext.request = req;
        RestContext.response = res;

        ServicioActualizaPlaca.actualizarNombreProducto();

        // Esperamos código 404
        System.assertEquals(404, RestContext.response.statusCode);
    }

    @isTest
    static void testActualizarNombreProducto_datosIncompletos() {
        String jsonBody = '{"original":"", "cambio":""}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/actualizaProductoPorVin';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);

        RestContext.request = req;
        RestContext.response = res;

        ServicioActualizaPlaca.actualizarNombreProducto();

        // Esperamos código 400
        System.assertEquals(400, RestContext.response.statusCode);
    }
}