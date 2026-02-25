@RestResource(urlMapping='/actualizaProductoPlaca')
global with sharing class ServicioActualizaPlaca {

    global class EntradaWrapper {
        public String original;
        public String cambio;
    }

    @HttpPost
    global static void actualizarNombreProducto() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            EntradaWrapper datos = (EntradaWrapper) JSON.deserialize(req.requestBody.toString(), EntradaWrapper.class);

            if (String.isBlank(datos.original) || String.isBlank(datos.cambio)) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf('Debe incluir "original" y "cambio" en el JSON');
                return;
            }

            // Buscar el producto
            Product2 producto = [
                SELECT Id, Name, Codigo_de_Producto__c, es_Vehiculo_usado__c
                FROM Product2
                WHERE Codigo_de_Producto__c = :datos.original AND es_Vehiculo_usado__c = TRUE
                LIMIT 1
            ];

            // Actualizar el código del producto
            producto.Codigo_de_Producto__c = datos.cambio;
            update producto;

            // Eliminar registros de ProductoXBodega__c relacionados
            List<ProductoXBodega__c> registrosABorrar = [
                SELECT Id FROM ProductoXBodega__c
                WHERE Producto__c = :producto.Id
            ];
            if (!registrosABorrar.isEmpty()) {
                delete registrosABorrar;
            }

            res.statusCode = 200;
            res.responseBody = Blob.valueOf('Producto actualizado y registros relacionados eliminados correctamente');

        } catch (QueryException qe) {
            res.statusCode = 404;
            res.responseBody = Blob.valueOf('No se encontró producto con ese VIN');
        } catch (Exception e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('Error inesperado: ' + e.getMessage());
        }
    }
}