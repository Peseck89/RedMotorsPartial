@isTest
public class ApiCrediWSTest {
    @isTest
    static void creaCuentaTest()
    {
        String cedula = '123,4556,7890';
        List<String> cedulas = new List<String>();
        cedulas.add(cedula);
        test.startTest();
        List<String> respuestaServicio = ApiCreditWS.getInfoCliente(cedulas);
        test.stopTest();
    }
}