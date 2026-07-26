@IsTest
private class precioProductoJSON_PekingGapTest {
    // Caracteriza, sin SeeAllData y sin tocar codigo productivo, el
    // comportamiento ACTUAL de precioProductoJSON.createProduct() cuando
    // recibe una empresa no mapeada (por ejemplo 'RMPEKING'). Ver
    // IMPLEMENTACION_BLOQUE10_BUSQUEDA_DETALLADA.md para el detalle de por
    // que no se implemento soporte real para RMPEKING en este bloque: falta
    // confirmar, para la nueva empresa, cual de las dos convenciones de
    // identificacion de producto ya existentes (Codigo_de_Producto__c como
    // RMBAVARIAN, o CodigoProductoInterno__c compuesto como RMOTOBAI) debe
    // seguir Softland, y ese dato es externo/contractual, no deducible del
    // codigo.
    @IsTest
    static void testCreateProduct_UnknownCompany_ReturnsGenericServerErrorInsteadOfControlledMessage() {
        precioProductoJSON.productRequestJSON req = new precioProductoJSON.productRequestJSON();
        req.articulo = 'ART-PEKING-TEST';
        req.precio_local = '1000';
        req.precio_dolar = '10';
        req.costo_local = '800';
        req.costo_dolar = '8';
        req.empresa = 'RMPEKING';

        String jsonStr = JSON.serialize(req);

        Test.startTest();
        String responseJson = precioProductoJSON.createProduct(jsonStr);
        Test.stopTest();

        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(responseJson);
        Map<String, Object> solicitud = (Map<String, Object>) parsed.get('Solicitud');

        // Comportamiento actual: para cualquier empresa distinta de
        // RMBAVARIAN/RMOTOBAI, la variable local `prod` queda sin
        // inicializar y `prod.size()` lanza una NullPointerException que el
        // catch generico convierte en un CODIGO 500 generico -- no en un
        // rechazo controlado y explicito de "empresa no soportada". Esta
        // prueba deja registrado ese comportamiento para poder compararlo
        // una vez se confirme la convencion de producto de RMPEKING.
        System.assertEquals(
            '500',
            (String) solicitud.get('CODIGO'),
            'Hoy, una empresa no mapeada (RMPEKING) produce un error 500 por NullPointerException no controlada, no un rechazo explicito.'
        );
    }
}
