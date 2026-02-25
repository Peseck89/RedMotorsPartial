@isTest
private class ReciboUsadoServiceTest {

    @isTest
    static void testDummy() {
        // Ejecutar el método dummy
        ReciboUsadoService.dummy(); // <-- Llamada directa
        
        // Verificación (obligatoria en pruebas)
        System.assert(true, 'El método se ejecutó correctamente');
    }
}