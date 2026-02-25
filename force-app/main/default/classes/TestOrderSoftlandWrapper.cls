@isTest
private class TestOrderSoftlandWrapper {
    
    // Método de prueba para verificar la deserialización correcta del JSON en un orderSoftlandWrapper
    static testMethod void testParseMethod() {
        // Crear un JSON de ejemplo para deserializar
        String jsonExample = '{ "compania": "Comp1", "observaciones": "Obs1", "lineas": [ { "cod_articulo": "Art1" } ] }';

        // Llamar al método parse de orderSoftlandWrapper
        orderSoftlandWrapper parsedObject = orderSoftlandWrapper.parse(jsonExample);

        // Verificar que el objeto no sea null
        System.assertNotEquals(null, parsedObject, 'El objeto deserializado no debe ser null');

        // Verificar que los campos se hayan deserializado correctamente
        System.assertEquals('Comp1', parsedObject.compania, 'La compañía no se deserializó correctamente');
        System.assertEquals('Obs1', parsedObject.observaciones, 'Las observaciones no se deserializaron correctamente');

        // Verificar la deserialización de listas y sus elementos
        System.assertNotEquals(null, parsedObject.lineas, 'La lista de lineas no debe ser null');
        System.assertEquals(1, parsedObject.lineas.size(), 'La cantidad de elementos en lineas es incorrecta');
        System.assertEquals('Art1', parsedObject.lineas[0].cod_articulo, 'El código de artículo en lineas no se deserializó correctamente');
    }
}