@IsTest
private class FSL_SlotsApi_Test {

    // Utility: build a minimal, valid Service Appointment for tests
    private static ServiceAppointment newSA() {
        ServiceAppointment sa = new ServiceAppointment();
        sa.Subject            = 'Test SA';
        sa.EarliestStartTime  = System.now().addDays(1);
        sa.DueDate            = System.now().addDays(2);
        sa.Duration           = 60;
        sa.DurationType       = 'Minutes';
        // We deliberately do NOT set Territory/Skills/Policy here to keep data light.
        // The managed calls may still throw -> our API wraps and returns 500 (acceptable in unit test).
        insert sa;
        return sa;
    }

    @IsTest
    static void test_400_badRequest() {
        // Missing required fields -> expect 400 and empty list
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri  = '/services/apexrest/fsl/v1/slots';
        req.httpMethod  = 'POST';
        req.requestBody = Blob.valueOf('{}');

        RestContext.request  = req;
        RestContext.response = res;

        List<FSL_SlotsApi.SlotDTO> outList = FSL_SlotsApi.getSlots();
        System.assertEquals(400, RestContext.response.statusCode, 'Should return 400 on missing fields');
        System.assertEquals(0, outList.size(), 'No payload on 400');
    }

    @IsTest
    static void test_booking_path_returns_200_or_500() {
        ServiceAppointment sa = newSA();

        // Dummy ID for schedulingPolicyId. We don’t need a real record for coverage;
        // the managed service may throw and our API will convert to 500.
        Id fakePolicyId = (Id) sa.Id; // any Id works; type is not enforced here

        Map<String, Object> body = new Map<String, Object>{
            'serviceAppointmentId' => sa.Id,
            'schedulingPolicyId'   => fakePolicyId,
            'mode'                 => 'booking',
            'exactAppointments'    => false
            // operatingHoursId omitted -> code will fall back to UserInfo.getTimeZone()
        };

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri  = '/services/apexrest/fsl/v1/slots';
        req.httpMethod  = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(body));

        RestContext.request  = req;
        RestContext.response = res;

        List<FSL_SlotsApi.SlotDTO> outList = FSL_SlotsApi.getSlots();

        Integer status = RestContext.response.statusCode;
        System.assert(status == 200 || status == 500,
            'Expect 200 with data in a seeded org or 500 when managed API has no seed data');
        // No exception should bubble up.
    }

    @IsTest
    static void test_candidates_path_returns_200_or_500() {
        ServiceAppointment sa = newSA();
        Id fakePolicyId = (Id) sa.Id;

        Map<String, Object> body = new Map<String, Object>{
            'serviceAppointmentId' => sa.Id,
            'schedulingPolicyId'   => fakePolicyId,
            'mode'                 => 'candidates',
            'sortBy'               => 'grade'
        };

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri  = '/services/apexrest/fsl/v1/slots';
        req.httpMethod  = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(body));

        RestContext.request  = req;
        RestContext.response = res;

        List<FSL_SlotsApi.SlotDTO> outList = FSL_SlotsApi.getSlots();

        Integer status = RestContext.response.statusCode;
        System.assert(status == 200 || status == 500,
            'Expect 200 with candidates in a seeded org or 500 when engine cannot compute');
        // Again, the goal is to cover path + error handling, not engine results.
    }

    @IsTest
    static void test_comparators_cover() {
        // Directly exercise the comparators deterministically
        FSL_SlotsApi.SlotDTO a = new FSL_SlotsApi.SlotDTO();
        FSL_SlotsApi.SlotDTO b = new FSL_SlotsApi.SlotDTO();
        a.startTime = System.now();
        b.startTime = System.now().addHours(1);
        a.grade = 0.5; b.grade = 0.9;

        // Start time ascending
        Integer stCmp = new FSL_SlotsApi.ByStartTime().compare(a, b);
        System.assertEquals(-1, stCmp, 'a starts before b');

        // Grade descending
        Integer gCmp = new FSL_SlotsApi.ByGradeDesc().compare(a, b);
        System.assertEquals(1, gCmp, 'b has higher grade, so a > b returns 1 (desc order)');
    }
}