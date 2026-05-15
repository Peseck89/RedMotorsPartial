/**
 * @description Test class for FSL_SimpleSlotsService
 * Tests the service wrapper for Field Service slot calculation
 * @author Red Motors Development Team
 */
@isTest
private class FSL_SimpleSlotsServiceTest {

    // ==========================
    // Test Data Setup
    // ==========================

    @TestSetup
    static void setupTestData() {
        // 1. Create Operating Hours with timezone
        OperatingHours oh = new OperatingHours(
            Name = 'Test Operating Hours',
            TimeZone = 'America/Costa_Rica'
        );
        insert oh;

        // 2. Create TimeSlots for Operating Hours (Mon-Fri 8:00-17:00)
        List<TimeSlot> timeSlots = new List<TimeSlot>();
        List<String> days = new List<String>{'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'};
        for (String day : days) {
            timeSlots.add(new TimeSlot(
                OperatingHoursId = oh.Id,
                DayOfWeek = day,
                StartTime = Time.newInstance(8, 0, 0, 0),
                EndTime = Time.newInstance(17, 0, 0, 0)
            ));
        }
        insert timeSlots;

        // 3. Create Service Territory
        ServiceTerritory territory = new ServiceTerritory(
            Name = 'Test Territory',
            IsActive = true,
            OperatingHoursId = oh.Id
        );
        insert territory;

        // 4. Create Work Type (2 hours duration)
        WorkType wt = new WorkType(
            Name = 'Test Work Type',
            EstimatedDuration = 120,
            DurationType = 'Minutes'
        );
        insert wt;

        // 5. Create Service Resources (RelatedRecordId required by org)
        ServiceResource resource1 = new ServiceResource(
            Name = 'Test Resource 1',
            IsActive = true,
            ResourceType = 'T',
            RelatedRecordId = UserInfo.getUserId()
        );
        insert resource1;

        // 6. Assign resource to territory
        Datetime now = Datetime.now();
        ServiceTerritoryMember stm = new ServiceTerritoryMember(
            ServiceTerritoryId = territory.Id,
            ServiceResourceId = resource1.Id,
            EffectiveStartDate = now.addDays(-30),
            TerritoryType = 'P'
        );
        insert stm;
    }

    // ==========================
    // Helper Methods
    // ==========================

    private static ServiceTerritory getTestTerritory() {
        return [SELECT Id, OperatingHoursId FROM ServiceTerritory WHERE Name = 'Test Territory' LIMIT 1];
    }

    private static WorkType getTestWorkType() {
        return [SELECT Id FROM WorkType WHERE Name = 'Test Work Type' LIMIT 1];
    }

    private static Datetime getNextMonday() {
        Datetime now = Datetime.now();
        Integer daysUntilMonday = Math.mod(8 - Integer.valueOf(now.format('u')), 7);
        if (daysUntilMonday == 0) daysUntilMonday = 7;
        return now.addDays(daysUntilMonday);
    }

    // ==========================
    // Tests: SlotsParams DTO
    // ==========================

    @isTest
    static void testSlotsParams_DefaultValues() {
        FSL_SimpleSlotsService.SlotsParams params = new FSL_SimpleSlotsService.SlotsParams();

        System.assertEquals(30, params.slotStepMinutes, 'Default slot step should be 30 minutes');
        System.assertEquals(500, params.maxSlotsPerResource, 'Default max slots should be 500');
        System.assertEquals(100, params.capacityPercentage, 'Default capacity should be 100%');
        System.assertEquals(true, params.excludeAbsences, 'Absences should be excluded by default');
        System.assertEquals(true, params.enforceOperatingHours, 'Operating hours should be enforced by default');
        System.assertEquals(false, params.windowInLocalTime, 'Window should be UTC by default');
        System.assertEquals(true, params.returnLocalTime, 'Should return local time by default');
    }

    // ==========================
    // Tests: SlotsResult DTO
    // ==========================

    @isTest
    static void testSlotsResult_DefaultValues() {
        FSL_SimpleSlotsService.SlotsResult result = new FSL_SimpleSlotsService.SlotsResult();

        System.assertEquals(true, result.success, 'Success should be true by default');
        System.assertNotEquals(null, result.slots, 'Slots list should be initialized');
        System.assertEquals(0, result.slots.size(), 'Slots list should be empty');
        System.assertNotEquals(null, result.resourceUtilization, 'Utilization list should be initialized');
        System.assertEquals(0, result.totalSlotsGenerated, 'Total generated should be 0');
        System.assertEquals(0, result.totalSlotsReturned, 'Total returned should be 0');
        System.assertEquals(0, result.globalUtilizationPercentage, 'Global utilization should be 0');
    }

    // ==========================
    // Tests: getAvailableSlots (Main Service Method)
    // ==========================

    @isTest
    static void testGetAvailableSlots_Success() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();

        Datetime testDate = getNextMonday();

        FSL_SimpleSlotsService.SlotsParams params = new FSL_SimpleSlotsService.SlotsParams();
        params.serviceTerritoryId = territory.Id;
        params.workTypeId = wt.Id;
        params.earliestStart = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 14, 0, 0);
        params.dueDate = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 23, 0, 0);
        params.operatingHoursTimeZone = 'America/Costa_Rica';

        Test.startTest();
        FSL_SimpleSlotsService.SlotsResult result = FSL_SimpleSlotsService.getAvailableSlots(params);
        Test.stopTest();

        System.assertEquals(true, result.success, 'Request should succeed');
        System.assertNotEquals(null, result.slots, 'Slots should not be null');
    }

    @isTest
    static void testGetAvailableSlots_MissingServiceTerritory() {
        WorkType wt = getTestWorkType();

        FSL_SimpleSlotsService.SlotsParams params = new FSL_SimpleSlotsService.SlotsParams();
        params.serviceTerritoryId = null;  // Missing
        params.workTypeId = wt.Id;
        params.earliestStart = Datetime.now();
        params.dueDate = Datetime.now().addDays(1);

        Test.startTest();
        FSL_SimpleSlotsService.SlotsResult result = FSL_SimpleSlotsService.getAvailableSlots(params);
        Test.stopTest();

        System.assertEquals(false, result.success, 'Should fail without service territory');
        System.assert(result.errorMessage.contains('serviceTerritoryId'), 'Error should mention serviceTerritoryId');
    }

    @isTest
    static void testGetAvailableSlots_MissingWorkType() {
        ServiceTerritory territory = getTestTerritory();

        FSL_SimpleSlotsService.SlotsParams params = new FSL_SimpleSlotsService.SlotsParams();
        params.serviceTerritoryId = territory.Id;
        params.workTypeId = null;  // Missing
        params.earliestStart = Datetime.now();
        params.dueDate = Datetime.now().addDays(1);

        Test.startTest();
        FSL_SimpleSlotsService.SlotsResult result = FSL_SimpleSlotsService.getAvailableSlots(params);
        Test.stopTest();

        System.assertEquals(false, result.success, 'Should fail without work type');
        System.assert(result.errorMessage.contains('workTypeId'), 'Error should mention workTypeId');
    }

    @isTest
    static void testGetAvailableSlots_MissingEarliestStart() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();

        FSL_SimpleSlotsService.SlotsParams params = new FSL_SimpleSlotsService.SlotsParams();
        params.serviceTerritoryId = territory.Id;
        params.workTypeId = wt.Id;
        params.earliestStart = null;  // Missing
        params.dueDate = Datetime.now().addDays(1);

        Test.startTest();
        FSL_SimpleSlotsService.SlotsResult result = FSL_SimpleSlotsService.getAvailableSlots(params);
        Test.stopTest();

        System.assertEquals(false, result.success, 'Should fail without earliest start');
        System.assert(result.errorMessage.contains('earliestStart'), 'Error should mention earliestStart');
    }

    @isTest
    static void testGetAvailableSlots_InvalidDateRange() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();

        FSL_SimpleSlotsService.SlotsParams params = new FSL_SimpleSlotsService.SlotsParams();
        params.serviceTerritoryId = territory.Id;
        params.workTypeId = wt.Id;
        params.earliestStart = Datetime.now().addDays(1);  // After dueDate
        params.dueDate = Datetime.now();

        Test.startTest();
        FSL_SimpleSlotsService.SlotsResult result = FSL_SimpleSlotsService.getAvailableSlots(params);
        Test.stopTest();

        System.assertEquals(false, result.success, 'Should fail with invalid date range');
        System.assert(result.errorMessage.contains('before'), 'Error should mention date order');
    }

    // ==========================
    // Tests: getSlots (LWC/Aura Method)
    // ==========================

    @isTest
    static void testGetSlots_WithOptions() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();

        Datetime testDate = getNextMonday();
        Datetime windowStart = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 14, 0, 0);
        Datetime windowEnd = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 23, 0, 0);

        String optionsJson = JSON.serialize(new Map<String, Object>{
            'slotStepMinutes' => 30,
            'capacityPercentage' => 80,
            'excludeAbsences' => true,
            'enforceOperatingHours' => true,
            'windowInLocalTime' => false,
            'returnLocalTime' => true,
            'operatingHoursTimeZone' => 'America/Costa_Rica'
        });

        Test.startTest();
        FSL_SimpleSlotsService.SlotsResult result = FSL_SimpleSlotsService.getSlots(
            territory.Id,
            wt.Id,
            windowStart,
            windowEnd,
            optionsJson
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
    }

    @isTest
    static void testGetSlots_NullOptions() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();

        Datetime windowStart = Datetime.now();
        Datetime windowEnd = Datetime.now().addDays(1);

        Test.startTest();
        FSL_SimpleSlotsService.SlotsResult result = FSL_SimpleSlotsService.getSlots(
            territory.Id,
            wt.Id,
            windowStart,
            windowEnd,
            null  // No options
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
    }

    @isTest
    static void testGetSlots_EmptyOptions() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();

        Test.startTest();
        FSL_SimpleSlotsService.SlotsResult result = FSL_SimpleSlotsService.getSlots(
            territory.Id,
            wt.Id,
            Datetime.now(),
            Datetime.now().addDays(1),
            ''  // Empty options
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
    }

    // ==========================
    // Tests: getSlotsWithParams
    // ==========================

    @isTest
    static void testGetSlotsWithParams() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();

        Datetime testDate = getNextMonday();
        Datetime windowStart = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 14, 0, 0);
        Datetime windowEnd = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 23, 0, 0);

        Test.startTest();
        FSL_SimpleSlotsService.SlotsResult result = FSL_SimpleSlotsService.getSlotsWithParams(
            territory.Id,
            wt.Id,
            windowStart,
            windowEnd,
            30,      // slotStepMinutes
            100,     // capacityPercentage
            true,    // excludeAbsences
            false,   // windowInLocalTime
            true,    // returnLocalTime
            'America/Costa_Rica'
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
    }

    @isTest
    static void testGetSlotsWithParams_NullValues() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();

        Test.startTest();
        FSL_SimpleSlotsService.SlotsResult result = FSL_SimpleSlotsService.getSlotsWithParams(
            territory.Id,
            wt.Id,
            Datetime.now(),
            Datetime.now().addDays(1),
            null,    // Use defaults
            null,
            null,
            null,
            null,
            null
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
    }

    // ==========================
    // Tests: getSlotsForDate
    // ==========================

    @isTest
    static void testGetSlotsForDate() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();

        Date targetDate = getNextMonday().date();

        Test.startTest();
        FSL_SimpleSlotsService.SlotsResult result = FSL_SimpleSlotsService.getSlotsForDate(
            territory.Id,
            wt.Id,
            targetDate,
            'America/Costa_Rica'
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
    }

    @isTest
    static void testGetSlotsForDate_NullTimezone() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();

        Test.startTest();
        FSL_SimpleSlotsService.SlotsResult result = FSL_SimpleSlotsService.getSlotsForDate(
            territory.Id,
            wt.Id,
            Date.today().addDays(1),
            null  // Should default to America/Costa_Rica
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
    }

    // ==========================
    // Tests: getSlotsForDateRange
    // ==========================

    @isTest
    static void testGetSlotsForDateRange() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();

        Date startDate = getNextMonday().date();
        Date endDate = startDate.addDays(5);

        Test.startTest();
        FSL_SimpleSlotsService.SlotsResult result = FSL_SimpleSlotsService.getSlotsForDateRange(
            territory.Id,
            wt.Id,
            startDate,
            endDate,
            'America/Costa_Rica'
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
    }

    @isTest
    static void testGetSlotsForDateRange_DefaultTimezone() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();

        Test.startTest();
        FSL_SimpleSlotsService.SlotsResult result = FSL_SimpleSlotsService.getSlotsForDateRange(
            territory.Id,
            wt.Id,
            Date.today(),
            Date.today().addDays(3),
            ''  // Empty timezone
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
    }

    // ==========================
    // Tests: Flow Invocable Method
    // ==========================

    @isTest
    static void testGetAvailableSlotsInvocable() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();

        FSL_SimpleSlotsService.FlowInput input = new FSL_SimpleSlotsService.FlowInput();
        input.serviceTerritoryId = territory.Id;
        input.workTypeId = wt.Id;
        input.earliestStart = Datetime.now();
        input.dueDate = Datetime.now().addDays(1);
        input.operatingHoursTimeZone = 'America/Costa_Rica';
        input.capacityPercentage = 100;
        input.excludeAbsences = true;
        input.windowInLocalTime = true;

        List<FSL_SimpleSlotsService.FlowInput> inputs = new List<FSL_SimpleSlotsService.FlowInput>{input};

        Test.startTest();
        List<FSL_SimpleSlotsService.FlowOutput> outputs =
            FSL_SimpleSlotsService.getAvailableSlotsInvocable(inputs);
        Test.stopTest();

        System.assertEquals(1, outputs.size(), 'Should return one output');
        FSL_SimpleSlotsService.FlowOutput output = outputs[0];
        System.assertNotEquals(null, output.success, 'Success should be populated');
    }

    @isTest
    static void testGetAvailableSlotsInvocable_MultipleInputs() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();

        List<FSL_SimpleSlotsService.FlowInput> inputs = new List<FSL_SimpleSlotsService.FlowInput>();

        for (Integer i = 0; i < 3; i++) {
            FSL_SimpleSlotsService.FlowInput input = new FSL_SimpleSlotsService.FlowInput();
            input.serviceTerritoryId = territory.Id;
            input.workTypeId = wt.Id;
            input.earliestStart = Datetime.now().addDays(i);
            input.dueDate = Datetime.now().addDays(i + 1);
            inputs.add(input);
        }

        Test.startTest();
        List<FSL_SimpleSlotsService.FlowOutput> outputs =
            FSL_SimpleSlotsService.getAvailableSlotsInvocable(inputs);
        Test.stopTest();

        System.assertEquals(3, outputs.size(), 'Should return three outputs');
    }

    @isTest
    static void testGetAvailableSlotsInvocable_NullOptionalFields() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();

        FSL_SimpleSlotsService.FlowInput input = new FSL_SimpleSlotsService.FlowInput();
        input.serviceTerritoryId = territory.Id;
        input.workTypeId = wt.Id;
        input.earliestStart = Datetime.now();
        input.dueDate = Datetime.now().addDays(1);
        // Leave optional fields null

        List<FSL_SimpleSlotsService.FlowInput> inputs = new List<FSL_SimpleSlotsService.FlowInput>{input};

        Test.startTest();
        List<FSL_SimpleSlotsService.FlowOutput> outputs =
            FSL_SimpleSlotsService.getAvailableSlotsInvocable(inputs);
        Test.stopTest();

        System.assertEquals(1, outputs.size(), 'Should handle null optional fields');
    }

    // ==========================
    // Tests: Summary Methods
    // ==========================

    @isTest
    static void testGetSummary() {
        FSL_SimpleSlotsService.SlotsResult result = new FSL_SimpleSlotsService.SlotsResult();
        result.success = true;
        result.totalSlotsGenerated = 10;
        result.totalSlotsReturned = 8;
        result.globalUtilizationPercentage = 25.5;

        // Add a mock slot
        FSL_SimpleSlotsService.SlotInfo slot = new FSL_SimpleSlotsService.SlotInfo();
        slot.resourceName = 'Test Mechanic';
        slot.startTimeLocal = '2026-01-15 09:00';
        slot.endTimeLocal = '2026-01-15 11:00';
        result.slots.add(slot);

        // Add mock utilization
        FSL_SimpleSlotsService.ResourceUtilizationInfo util = new FSL_SimpleSlotsService.ResourceUtilizationInfo();
        util.resourceName = 'Test Mechanic';
        util.utilizationPercentage = 25.0;
        util.slotsGenerated = 10;
        result.resourceUtilization.add(util);

        Test.startTest();
        String summary = FSL_SimpleSlotsService.getSummary(result);
        Test.stopTest();

        System.assertNotEquals(null, summary, 'Summary should not be null');
        System.assert(summary.contains('SLOTS SUMMARY'), 'Summary should contain header');
        System.assert(summary.contains('Test Mechanic'), 'Summary should contain resource name');
    }

    @isTest
    static void testGetSummary_NullResult() {
        Test.startTest();
        String summary = FSL_SimpleSlotsService.getSummary(null);
        Test.stopTest();

        System.assertNotEquals(null, summary, 'Summary should not be null');
        System.assert(summary.contains('null'), 'Summary should indicate null result');
    }

    @isTest
    static void testGetSummary_ErrorResult() {
        FSL_SimpleSlotsService.SlotsResult result = new FSL_SimpleSlotsService.SlotsResult();
        result.success = false;
        result.errorMessage = 'Test error message';

        Test.startTest();
        String summary = FSL_SimpleSlotsService.getSummary(result);
        Test.stopTest();

        System.assert(summary.contains('Error'), 'Summary should contain error');
    }

    @isTest
    static void testLogSummary() {
        FSL_SimpleSlotsService.SlotsResult result = new FSL_SimpleSlotsService.SlotsResult();

        Test.startTest();
        FSL_SimpleSlotsService.logSummary(result);
        Test.stopTest();

        // Just verify no exceptions thrown
        System.assert(true, 'logSummary should complete without error');
    }

    // ==========================
    // Tests: DTOs Initialization
    // ==========================

    @isTest
    static void testSlotInfo_Properties() {
        FSL_SimpleSlotsService.SlotInfo slot = new FSL_SimpleSlotsService.SlotInfo();
        slot.resourceId = '0Hn000000000001';
        slot.resourceName = 'Test Resource';
        slot.startTime = Datetime.now();
        slot.endTime = Datetime.now().addHours(2);
        slot.startTimeLocal = '2026-01-15 09:00';
        slot.endTimeLocal = '2026-01-15 11:00';
        slot.grade = 85.5;

        System.assertEquals('Test Resource', slot.resourceName, 'Resource name should be set');
        System.assertEquals(85.5, slot.grade, 'Grade should be set');
    }

    @isTest
    static void testResourceUtilizationInfo_Properties() {
        FSL_SimpleSlotsService.ResourceUtilizationInfo util = new FSL_SimpleSlotsService.ResourceUtilizationInfo();
        util.resourceId = '0Hn000000000001';
        util.resourceName = 'Test Resource';
        util.totalWindowMinutes = 480;
        util.busyMinutes = 120;
        util.absenceMinutes = 60;
        util.availableMinutes = 300;
        util.slotsGenerated = 5;
        util.utilizationPercentage = 37.5;
        util.potentialUtilization = 50.0;

        System.assertEquals(480, util.totalWindowMinutes, 'Total window should be set');
        System.assertEquals(37.5, util.utilizationPercentage, 'Utilization should be set');
    }

    // ==========================
    // Tests: Exception Handling
    // ==========================

    @isTest
    static void testSlotsServiceException() {
        FSL_SimpleSlotsService.SlotsServiceException ex =
            new FSL_SimpleSlotsService.SlotsServiceException('Test error');

        System.assertEquals('Test error', ex.getMessage(), 'Exception message should match');
    }

    // ==========================
    // Tests: overrideCapacity in SlotsParams
    // ==========================

    @isTest
    static void testOverrideCapacity_ViaService() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();

        Datetime testDate = getNextMonday();

        FSL_SimpleSlotsService.SlotsParams params = new FSL_SimpleSlotsService.SlotsParams();
        params.serviceTerritoryId = territory.Id;
        params.workTypeId = wt.Id;
        params.earliestStart = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 14, 0, 0);
        params.dueDate = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 23, 0, 0);
        params.operatingHoursTimeZone = 'America/Costa_Rica';
        params.overrideCapacity = 50;

        Test.startTest();
        FSL_SimpleSlotsService.SlotsResult result = FSL_SimpleSlotsService.getAvailableSlots(params);
        Test.stopTest();

        System.assertEquals(true, result.success, 'Request should succeed with overrideCapacity');
        System.assertNotEquals(null, result.slots, 'Slots should not be null');
    }

    @isTest
    static void testOverrideCapacity_ViaJsonOptions() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();

        Datetime testDate = getNextMonday();
        Datetime windowStart = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 14, 0, 0);
        Datetime windowEnd = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 23, 0, 0);

        String optionsJson = JSON.serialize(new Map<String, Object>{
            'overrideCapacity' => 70,
            'operatingHoursTimeZone' => 'America/Costa_Rica'
        });

        Test.startTest();
        FSL_SimpleSlotsService.SlotsResult result = FSL_SimpleSlotsService.getSlots(
            territory.Id,
            wt.Id,
            windowStart,
            windowEnd,
            optionsJson
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(true, result.success, 'Request should succeed');
    }

    @isTest
    static void testSTCapacity_FallbackInService() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();

        // Set Capacity__c on ST
        territory.put('Capacity__c', 75);
        update territory;

        Datetime testDate = getNextMonday();

        FSL_SimpleSlotsService.SlotsParams params = new FSL_SimpleSlotsService.SlotsParams();
        params.serviceTerritoryId = territory.Id;
        params.workTypeId = wt.Id;
        params.earliestStart = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 14, 0, 0);
        params.dueDate = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 23, 0, 0);
        params.operatingHoursTimeZone = 'America/Costa_Rica';
        // capacityPercentage default is 100, should be overridden by ST.Capacity__c=75
        params.capacityPercentage = 100;

        Test.startTest();
        FSL_SimpleSlotsService.SlotsResult result = FSL_SimpleSlotsService.getAvailableSlots(params);
        Test.stopTest();

        System.assertEquals(true, result.success, 'Request should succeed');
    }
}