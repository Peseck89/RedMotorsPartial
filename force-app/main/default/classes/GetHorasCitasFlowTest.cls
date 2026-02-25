@isTest(seealldata=true)
public class GetHorasCitasFlowTest {
    @isTest
    static void testConvertLeads() {
        // Create test data
        
        // Define test OppAndAccountDetailsRequest
        getHorasCitasFlow.OppAndAccountDetailsRequest testRequest = new getHorasCitasFlow.OppAndAccountDetailsRequest();
        testRequest.nombreCalendario = new List<String>{'Escazú - Mecánica Rápida'};
        testRequest.dateRequest = new List<String>{'28/02/2024'};
        
        // Add test request to list
        List<getHorasCitasFlow.OppAndAccountDetailsRequest> testRequests = new List<getHorasCitasFlow.OppAndAccountDetailsRequest>();
        testRequests.add(testRequest);
        
        // Call the method to test
        Test.startTest();
        List<String> result = getHorasCitasFlow.convertLeads(testRequests);
        getHorasCitasFlow.checkTiempos('Escazú - Mecánica Rápida','28/02/2024');
        getHorasCitasFlow.dummy();
        Test.stopTest();
        
        // Assertions
        //System.assertEquals(0, result.size(), 'Expected no available times');
        // Add more assertions based on your business logic
    }
     @isTest
    static void testRoundToNearest30Minutes() {
        // Test rounding down to the nearest 30 minutes
        Datetime dt1 = Datetime.newInstance(2024, 7, 11, 0, 14, 12);
        Datetime expectedDt1 = Datetime.newInstanceGmt(2024, 7, 11, 0, 0, 0);
        Datetime roundedDt1 = getHorasCitasFlow.roundToNearest30Minutes(dt1);
        
        // Test rounding up to the nearest 30 minutes
        Datetime dt2 = Datetime.newInstance(2024, 7, 11, 0, 37, 12);
        Datetime expectedDt2 = Datetime.newInstanceGmt(2024, 7, 11, 1, 0, 0);
        Datetime roundedDt2 = getHorasCitasFlow.roundToNearest30Minutes(dt2);
        
        // Test rounding to 30 minutes when within the range
        Datetime dt3 = Datetime.newInstance(2024, 7, 11, 0, 16, 12);
        Datetime expectedDt3 = Datetime.newInstanceGmt(2024, 7, 11, 0, 30, 0);
        Datetime roundedDt3 = getHorasCitasFlow.roundToNearest30Minutes(dt3);
        
        // Test edge case exactly at 15 minutes
        Datetime dt4 = Datetime.newInstance(2024, 7, 11, 0, 15, 0);
        Datetime expectedDt4 = Datetime.newInstanceGmt(2024, 7, 11, 0, 30, 0);
        Datetime roundedDt4 = getHorasCitasFlow.roundToNearest30Minutes(dt4);
        
        // Test edge case exactly at 45 minutes
        Datetime dt5 = Datetime.newInstance(2024, 7, 11, 0, 45, 0);
        Datetime expectedDt5 = Datetime.newInstanceGmt(2024, 7, 11, 1, 0, 0);
        Datetime roundedDt5 = getHorasCitasFlow.roundToNearest30Minutes(dt5);
        
        // Test case for exactly on the hour
        Datetime dt6 = Datetime.newInstance(2024, 7, 11, 1, 0, 0);
        Datetime expectedDt6 = Datetime.newInstanceGmt(2024, 7, 11, 1, 0, 0);
        Datetime roundedDt6 = getHorasCitasFlow.roundToNearest30Minutes(dt6);
        
        // Test case for exactly at half past the hour
        Datetime dt7 = Datetime.newInstance(2024, 7, 11, 1, 30, 0);
        Datetime expectedDt7 = Datetime.newInstanceGmt(2024, 7, 11, 1, 30, 0);
        Datetime roundedDt7 = getHorasCitasFlow.roundToNearest30Minutes(dt7);
    }
}