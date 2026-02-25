@isTest
public class ApiCreditLWCWSTest {
    @isTest
    static void testGetInfoCliente() {
        // Simulación de respuesta del servicio externo
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorApiCredId());
        
        String cedula = '123,4556,7890';
        Test.startTest();
        ApiCreditLWCWS.Data respuestaServicio = ApiCreditLWCWS.getInfoCliente(cedula);
        Test.stopTest();
        
        // Validaciones
        System.assertNotEquals(null, respuestaServicio, 'La respuesta no debe ser nula');
        System.assertEquals('Juan', respuestaServicio.nombre, 'El nombre debe ser Juan');
        System.assertEquals('Perez', respuestaServicio.apellido1, 'El primer apellido debe ser Perez');
        System.assertEquals('Casado', respuestaServicio.estadoCivil, 'El estado civil debe ser Casado');
    }
}