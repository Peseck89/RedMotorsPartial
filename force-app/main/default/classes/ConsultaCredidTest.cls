@isTest
public class ConsultaCredidTest {
    @isTest static void testObtenerConfidenceResult() {
        // Mock
        Test.setMock(HttpCalloutMock.class, new ConsultaCredidMock());
        
        // Test data
        String identificacionCliente = '114230700';

        // Perform test
        Test.startTest();
        String confidenceResult = ConsultaCredid.obtenerConfidenceResult(identificacionCliente);
        Test.stopTest();

        // Assert
        //System.assertEquals('824', confidenceResult);
    }
}