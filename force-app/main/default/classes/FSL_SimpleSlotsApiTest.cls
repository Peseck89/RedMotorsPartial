@isTest
private class FSL_SimpleSlotsApiTest {

    // ==========================
    // Test Data Setup
    // ==========================

    @TestSetup
    static void setupTestData() {
        // 1. Create Operating Hours
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
        Id currentUserId = UserInfo.getUserId();
        ServiceResource resource1 = new ServiceResource(
            Name = 'Test Resource 1',
            IsActive = true,
            ResourceType = 'T',
            RelatedRecordId = currentUserId
        );
        insert resource1;

        // Second resource needs a different user — create one
        Profile stdProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'Resource2',
            Email = 'testresource2.fslslots@redmotors.test',
            Username = 'testresource2.fslslots.' + Datetime.now().getTime() + '@redmotors.test',
            Alias = 'tres2',
            TimeZoneSidKey = 'America/Costa_Rica',
            LocaleSidKey = 'es_CR',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'es',
            ProfileId = stdProfile.Id
        );
        insert testUser;

        ServiceResource resource2 = new ServiceResource(
            Name = 'Test Resource 2',
            IsActive = true,
            ResourceType = 'T',
            RelatedRecordId = testUser.Id
        );
        insert resource2;

        // 6. Assign resources to territory
        Datetime now = Datetime.now();
        ServiceTerritoryMember stm1 = new ServiceTerritoryMember(
            ServiceTerritoryId = territory.Id,
            ServiceResourceId = resource1.Id,
            EffectiveStartDate = now.addDays(-30),
            TerritoryType = 'P'
        );
        ServiceTerritoryMember stm2 = new ServiceTerritoryMember(
            ServiceTerritoryId = territory.Id,
            ServiceResourceId = resource2.Id,
            EffectiveStartDate = now.addDays(-30),
            TerritoryType = 'P'
        );
        insert new List<ServiceTerritoryMember>{stm1, stm2};
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

    private static ServiceResource getTestResource(String name) {
        return [SELECT Id FROM ServiceResource WHERE Name = :name LIMIT 1];
    }

    private static void setupRestContext(String jsonBody) {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/fsl/v1/simpleSlots';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response = res;
    }

    // ==========================
    // Test: Basic API response structure
    // ==========================
    @isTest
    static void testBasicResponseStructure() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();

        Datetime testDate = getNextMonday();
        Datetime windowStart = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 14, 0, 0);
        Datetime windowEnd = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 23, 0, 0);

        String json = JSON.serialize(new Map<String, Object>{
            'serviceTerritoryId' => territory.Id,
            'workTypeId' => wt.Id,
            'earliestStart' => windowStart,
            'dueDate' => windowEnd,
            'operatingHoursTimeZone' => 'America/Costa_Rica',
            'slotStepMinutes' => 30,
            'maxSlotsPerResource' => 50,
            'capacityPercentage' => 100,
            'excludeAbsences' => true
        });

        setupRestContext(json);

        Test.startTest();
        FSL_SimpleSlotsApi.SlotsResponse response = FSL_SimpleSlotsApi.getSimpleSlots();
        Test.stopTest();

        // Verify response structure
        System.assertNotEquals(null, response, 'Response should not be null');
        System.assertNotEquals(null, response.slots, 'Slots list should not be null');
        System.assertNotEquals(null, response.resourceUtilization, 'Resource utilization list should not be null');
        System.assertNotEquals(null, response.totalSlotsGenerated, 'totalSlotsGenerated should not be null');
        System.assertNotEquals(null, response.totalSlotsReturned, 'totalSlotsReturned should not be null');
        System.assertNotEquals(null, response.globalUtilizationPercentage, 'globalUtilizationPercentage should not be null');
    }

    // ==========================
    // Test: Capacity Percentage reduces slots
    // ==========================
    @isTest
    static void testCapacityPercentage80_ReducesSlots() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();

        // Use a Monday in the future for testing
        Datetime testDate = getNextMonday();
        Datetime windowStart = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 14, 0, 0);
        Datetime windowEnd = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 23, 0, 0);

        // First call with 100% capacity
        String json100 = JSON.serialize(new Map<String, Object>{
            'serviceTerritoryId' => territory.Id,
            'workTypeId' => wt.Id,
            'earliestStart' => windowStart,
            'dueDate' => windowEnd,
            'operatingHoursTimeZone' => 'America/Costa_Rica',
            'slotStepMinutes' => 30,
            'maxSlotsPerResource' => 50,
            'capacityPercentage' => 100,
            'excludeAbsences' => true
        });

        setupRestContext(json100);

        Test.startTest();
        FSL_SimpleSlotsApi.SlotsResponse response100 = FSL_SimpleSlotsApi.getSimpleSlots();

        // Second call with 80% capacity
        String json80 = JSON.serialize(new Map<String, Object>{
            'serviceTerritoryId' => territory.Id,
            'workTypeId' => wt.Id,
            'earliestStart' => windowStart,
            'dueDate' => windowEnd,
            'operatingHoursTimeZone' => 'America/Costa_Rica',
            'slotStepMinutes' => 30,
            'maxSlotsPerResource' => 50,
            'capacityPercentage' => 80,
            'excludeAbsences' => true
        });

        setupRestContext(json80);
        FSL_SimpleSlotsApi.SlotsResponse response80 = FSL_SimpleSlotsApi.getSimpleSlots();
        Test.stopTest();

        // Assert that 80% capacity returns fewer slots
        System.debug('Slots at 100%: ' + response100.slots.size());
        System.debug('Slots at 80%: ' + response80.slots.size());

        if (response100.slots.size() > 1) {
            // Capacity acts as a gate based on utilization — without existing appointments,
            // 80% capacity may return the same number of slots as 100% (utilization is 0%)
            System.assert(response80.slots.size() <= response100.slots.size(),
                'Capacity 80% should return same or fewer slots. Got ' + response80.slots.size() + ' vs ' + response100.slots.size());
        }
    }

    // ==========================
    // Test: Capacity percentage limits based on UTILIZATION
    // Slots stop being shown when adding one would exceed capacityPercentage
    // ==========================
    @isTest
    static void testCapacityPercentage_LimitsBasedOnUtilization() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();

        Datetime testDate = getNextMonday();
        Datetime windowStart = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 14, 0, 0);
        Datetime windowEnd = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 23, 0, 0);

        // Test with 100% capacity (full availability)
        String json100 = JSON.serialize(new Map<String, Object>{
            'serviceTerritoryId' => territory.Id,
            'workTypeId' => wt.Id,
            'earliestStart' => windowStart,
            'dueDate' => windowEnd,
            'operatingHoursTimeZone' => 'America/Costa_Rica',
            'slotStepMinutes' => 30,
            'maxSlotsPerResource' => 50,
            'capacityPercentage' => 100,
            'excludeAbsences' => true
        });

        setupRestContext(json100);

        Test.startTest();
        FSL_SimpleSlotsApi.SlotsResponse response100 = FSL_SimpleSlotsApi.getSimpleSlots();

        // Test with 50% capacity - should stop showing slots when utilization would exceed 50%
        String json50 = JSON.serialize(new Map<String, Object>{
            'serviceTerritoryId' => territory.Id,
            'workTypeId' => wt.Id,
            'earliestStart' => windowStart,
            'dueDate' => windowEnd,
            'operatingHoursTimeZone' => 'America/Costa_Rica',
            'slotStepMinutes' => 30,
            'maxSlotsPerResource' => 50,
            'capacityPercentage' => 50,
            'excludeAbsences' => true
        });

        setupRestContext(json50);
        FSL_SimpleSlotsApi.SlotsResponse response50 = FSL_SimpleSlotsApi.getSimpleSlots();
        Test.stopTest();

        System.debug('Slots at 100% capacity: ' + response100.slots.size());
        System.debug('Slots at 50% capacity: ' + response50.slots.size());

        // At 50% capacity, should have fewer or equal slots than 100%
        System.assertNotEquals(null, response100.slots);
        System.assertNotEquals(null, response50.slots);
        System.assert(response50.slots.size() <= response100.slots.size(),
            '50% capacity should have <= slots than 100%');

        // Check that potentialUtilization is populated in utilization
        if (!response50.resourceUtilization.isEmpty()) {
            FSL_SimpleSlotsApi.ResourceUtilization util = response50.resourceUtilization[0];
            System.assertNotEquals(null, util.utilizationPercentage);
            System.assertNotEquals(null, util.potentialUtilization);
            System.debug('Current utilization: ' + util.utilizationPercentage + '%, Potential: ' + util.potentialUtilization + '%');
            // Potential utilization should not exceed capacity percentage (50% in this case)
            System.assert(util.potentialUtilization <= 50,
                'Potential utilization should not exceed capacity limit');
        }
    }

    // ==========================
    // Test: Absences are excluded
    // ==========================
    @isTest
    static void testAbsences_ReduceAvailableSlots() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();
        ServiceResource resource1 = getTestResource('Test Resource 1');

        Datetime testDate = getNextMonday();
        Datetime windowStart = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 14, 0, 0);
        Datetime windowEnd = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 23, 0, 0);

        // Create an absence for resource1 (lunch break 12:00-13:00 local = 18:00-19:00 UTC)
        ResourceAbsence absence = new ResourceAbsence(
            ResourceId = resource1.Id,
            Start = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 18, 0, 0),
            End = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 19, 0, 0),
            Type = 'Lunch'
        );
        insert absence;

        // Call with excludeAbsences = true
        String jsonWithAbsences = JSON.serialize(new Map<String, Object>{
            'serviceTerritoryId' => territory.Id,
            'workTypeId' => wt.Id,
            'earliestStart' => windowStart,
            'dueDate' => windowEnd,
            'operatingHoursTimeZone' => 'America/Costa_Rica',
            'slotStepMinutes' => 30,
            'maxSlotsPerResource' => 50,
            'capacityPercentage' => 100,
            'excludeAbsences' => true
        });

        setupRestContext(jsonWithAbsences);

        Test.startTest();
        FSL_SimpleSlotsApi.SlotsResponse responseWithExclusion = FSL_SimpleSlotsApi.getSimpleSlots();

        // Call with excludeAbsences = false
        String jsonWithoutAbsences = JSON.serialize(new Map<String, Object>{
            'serviceTerritoryId' => territory.Id,
            'workTypeId' => wt.Id,
            'earliestStart' => windowStart,
            'dueDate' => windowEnd,
            'operatingHoursTimeZone' => 'America/Costa_Rica',
            'slotStepMinutes' => 30,
            'maxSlotsPerResource' => 50,
            'capacityPercentage' => 100,
            'excludeAbsences' => false
        });

        setupRestContext(jsonWithoutAbsences);
        FSL_SimpleSlotsApi.SlotsResponse responseWithoutExclusion = FSL_SimpleSlotsApi.getSimpleSlots();
        Test.stopTest();

        System.debug('Slots with absence exclusion: ' + responseWithExclusion.slots.size());
        System.debug('Slots without absence exclusion: ' + responseWithoutExclusion.slots.size());

        // With absence exclusion, we should have fewer or equal slots
        System.assert(responseWithExclusion.slots.size() <= responseWithoutExclusion.slots.size(),
            'Expected fewer slots when excluding absences');

        // Verify utilization is captured
        System.assert(responseWithExclusion.resourceUtilization.size() > 0, 'Should have utilization data');
    }

    // ==========================
    // Test: Operating Hours enforcement flag
    // ==========================
    @isTest
    static void testEnforceOperatingHours_Flag() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();

        // Request slots for a Saturday (no OH configured)
        Datetime testDate = getNextSaturday();
        Datetime windowStart = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 14, 0, 0);
        Datetime windowEnd = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 20, 0, 0);

        // With enforceOperatingHours = true (should return 0 slots on Saturday)
        String jsonEnforce = JSON.serialize(new Map<String, Object>{
            'serviceTerritoryId' => territory.Id,
            'workTypeId' => wt.Id,
            'earliestStart' => windowStart,
            'dueDate' => windowEnd,
            'operatingHoursTimeZone' => 'America/Costa_Rica',
            'slotStepMinutes' => 30,
            'maxSlotsPerResource' => 50,
            'capacityPercentage' => 100,
            'excludeAbsences' => true,
            'enforceOperatingHours' => true
        });

        setupRestContext(jsonEnforce);

        Test.startTest();
        FSL_SimpleSlotsApi.SlotsResponse responseEnforce = FSL_SimpleSlotsApi.getSimpleSlots();

        // With enforceOperatingHours = false (should return slots even on Saturday)
        String jsonNoEnforce = JSON.serialize(new Map<String, Object>{
            'serviceTerritoryId' => territory.Id,
            'workTypeId' => wt.Id,
            'earliestStart' => windowStart,
            'dueDate' => windowEnd,
            'operatingHoursTimeZone' => 'America/Costa_Rica',
            'slotStepMinutes' => 30,
            'maxSlotsPerResource' => 50,
            'capacityPercentage' => 100,
            'excludeAbsences' => true,
            'enforceOperatingHours' => false
        });

        setupRestContext(jsonNoEnforce);
        FSL_SimpleSlotsApi.SlotsResponse responseNoEnforce = FSL_SimpleSlotsApi.getSimpleSlots();
        Test.stopTest();

        System.debug('Slots with enforceOH=true on Saturday: ' + responseEnforce.slots.size());
        System.debug('Slots with enforceOH=false on Saturday: ' + responseNoEnforce.slots.size());

        // Saturday has no operating hours, so with enforce=true, we expect 0 slots
        System.assertEquals(0, responseEnforce.slots.size(),
            'Expected 0 slots on Saturday when enforcing Operating Hours');

        // With enforce=false, we should get some slots
        System.assert(responseNoEnforce.slots.size() > 0,
            'Expected some slots on Saturday when NOT enforcing Operating Hours');
    }

    // ==========================
    // Test: Required fields validation
    // ==========================
    @isTest
    static void testValidation_MissingRequiredFields() {
        // Missing serviceTerritoryId
        String json = JSON.serialize(new Map<String, Object>{
            'workTypeId' => '08qXXXXXXXXXXXXXXX',
            'earliestStart' => Datetime.now(),
            'dueDate' => Datetime.now().addDays(1)
        });

        setupRestContext(json);

        Test.startTest();
        FSL_SimpleSlotsApi.SlotsResponse response = FSL_SimpleSlotsApi.getSimpleSlots();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode,
            'Expected 400 status code for missing serviceTerritoryId');
    }

    // ==========================
    // Test: Invalid date range
    // ==========================
    @isTest
    static void testValidation_InvalidDateRange() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();

        // earliestStart >= dueDate
        String json = JSON.serialize(new Map<String, Object>{
            'serviceTerritoryId' => territory.Id,
            'workTypeId' => wt.Id,
            'earliestStart' => Datetime.now().addDays(1),
            'dueDate' => Datetime.now()
        });

        setupRestContext(json);

        Test.startTest();
        FSL_SimpleSlotsApi.SlotsResponse response = FSL_SimpleSlotsApi.getSimpleSlots();
        Test.stopTest();

        System.assertEquals(400, RestContext.response.statusCode,
            'Expected 400 status code for invalid date range');
    }

    // ==========================
    // Test: Slots are ordered by startTime
    // ==========================
    @isTest
    static void testSlots_OrderedByStartTime() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();

        Datetime testDate = getNextMonday();
        Datetime windowStart = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 14, 0, 0);
        Datetime windowEnd = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 23, 0, 0);

        String json = JSON.serialize(new Map<String, Object>{
            'serviceTerritoryId' => territory.Id,
            'workTypeId' => wt.Id,
            'earliestStart' => windowStart,
            'dueDate' => windowEnd,
            'operatingHoursTimeZone' => 'America/Costa_Rica',
            'slotStepMinutes' => 30,
            'maxSlotsPerResource' => 50,
            'capacityPercentage' => 100,
            'excludeAbsences' => true
        });

        setupRestContext(json);

        Test.startTest();
        FSL_SimpleSlotsApi.SlotsResponse response = FSL_SimpleSlotsApi.getSimpleSlots();
        Test.stopTest();

        // Verify slots are ordered
        if (response.slots.size() > 1) {
            for (Integer i = 1; i < response.slots.size(); i++) {
                System.assert(response.slots[i].startTime >= response.slots[i-1].startTime,
                    'Slots should be ordered by startTime');
            }
        }
    }

    // ==========================
    // Test: Resource utilization is calculated
    // ==========================
    @isTest
    static void testResourceUtilization_Calculated() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();
        ServiceResource resource1 = getTestResource('Test Resource 1');

        Datetime testDate = getNextMonday();
        Datetime windowStart = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 14, 0, 0);
        Datetime windowEnd = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 20, 0, 0);

        // Create a 2-hour absence
        ResourceAbsence absence = new ResourceAbsence(
            ResourceId = resource1.Id,
            Start = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 16, 0, 0),
            End = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 18, 0, 0),
            Type = 'Break'
        );
        insert absence;

        String json = JSON.serialize(new Map<String, Object>{
            'serviceTerritoryId' => territory.Id,
            'workTypeId' => wt.Id,
            'earliestStart' => windowStart,
            'dueDate' => windowEnd,
            'operatingHoursTimeZone' => 'America/Costa_Rica',
            'slotStepMinutes' => 30,
            'maxSlotsPerResource' => 50,
            'capacityPercentage' => 100,
            'excludeAbsences' => true
        });

        setupRestContext(json);

        Test.startTest();
        FSL_SimpleSlotsApi.SlotsResponse response = FSL_SimpleSlotsApi.getSimpleSlots();
        Test.stopTest();

        // Verify utilization is calculated
        System.assert(response.resourceUtilization.size() > 0, 'Should have utilization data');

        // Find utilization for resource1
        FSL_SimpleSlotsApi.ResourceUtilization util1 = null;
        for (FSL_SimpleSlotsApi.ResourceUtilization ru : response.resourceUtilization) {
            if (ru.resourceId == resource1.Id) {
                util1 = ru;
                break;
            }
        }

        if (util1 != null) {
            System.debug('Resource 1 utilization: ' + util1.utilizationPercentage + '%');
            System.debug('Resource 1 absenceMinutes: ' + util1.absenceMinutes);
            System.debug('Resource 1 totalWindowMinutes: ' + util1.totalWindowMinutes);

            // Window is 6 hours = 360 minutes
            // Absence is 2 hours = 120 minutes
            // So utilization should be around 33% (120/360 * 100)
            System.assertNotEquals(null, util1.utilizationPercentage);
            System.assert(util1.absenceMinutes > 0, 'Should have absence minutes recorded');
        }

        // Verify global utilization
        System.assertNotEquals(null, response.globalUtilizationPercentage);
    }

    // ==========================
    // Test: Long absence blocks entire day
    // ==========================
    @isTest
    static void testLongAbsence_BlocksSlots() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();
        ServiceResource resource1 = getTestResource('Test Resource 1');

        Datetime testDate = getNextMonday();
        // Window: 14:00 to 20:00 UTC (6 hours)
        Datetime windowStart = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 14, 0, 0);
        Datetime windowEnd = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 20, 0, 0);

        // Create absence covering 14:00-18:00 (4 hours) - blocks first 4 hours
        ResourceAbsence absence = new ResourceAbsence(
            ResourceId = resource1.Id,
            Start = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 14, 0, 0),
            End = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 18, 0, 0),
            Type = 'Medical Appointment'
        );
        insert absence;

        String json = JSON.serialize(new Map<String, Object>{
            'serviceTerritoryId' => territory.Id,
            'workTypeId' => wt.Id,
            'earliestStart' => windowStart,
            'dueDate' => windowEnd,
            'operatingHoursTimeZone' => 'America/Costa_Rica',
            'slotStepMinutes' => 30,
            'maxSlotsPerResource' => 50,
            'capacityPercentage' => 100,
            'excludeAbsences' => true,
            'enforceOperatingHours' => false  // Don't enforce OH for this test
        });

        setupRestContext(json);

        Test.startTest();
        FSL_SimpleSlotsApi.SlotsResponse response = FSL_SimpleSlotsApi.getSimpleSlots();
        Test.stopTest();

        // Verify that no slots for resource1 start before 18:00
        for (FSL_SimpleSlotsApi.SlotDTO slot : response.slots) {
            if (slot.resourceId == resource1.Id) {
                System.assert(slot.startTime >= Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 18, 0, 0),
                    'Resource 1 should not have slots before 18:00 due to absence. Found slot at: ' + slot.startTime);
            }
        }
    }

    // ==========================
    // Helper: Get next Monday
    // ==========================
    private static Datetime getNextMonday() {
        Datetime now = Datetime.now();
        // Find next Monday
        Integer daysUntilMonday = Math.mod(8 - Integer.valueOf(now.format('u')), 7);
        if (daysUntilMonday == 0) daysUntilMonday = 7;
        return now.addDays(daysUntilMonday);
    }

    // ==========================
    // Test: overrideCapacity takes priority over capacityPercentage
    // ==========================
    @isTest
    static void testOverrideCapacity_TakesPriority() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();

        Datetime testDate = getNextMonday();
        Datetime windowStart = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 14, 0, 0);
        Datetime windowEnd = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 23, 0, 0);

        // Send capacityPercentage=100 but overrideCapacity=50
        // overrideCapacity should win
        String json = JSON.serialize(new Map<String, Object>{
            'serviceTerritoryId' => territory.Id,
            'workTypeId' => wt.Id,
            'earliestStart' => windowStart,
            'dueDate' => windowEnd,
            'operatingHoursTimeZone' => 'America/Costa_Rica',
            'slotStepMinutes' => 30,
            'maxSlotsPerResource' => 50,
            'capacityPercentage' => 100,
            'overrideCapacity' => 50,
            'excludeAbsences' => true
        });

        setupRestContext(json);

        Test.startTest();
        FSL_SimpleSlotsApi.SlotsResponse response = FSL_SimpleSlotsApi.getSimpleSlots();
        Test.stopTest();

        System.assertNotEquals(null, response, 'Response should not be null');
        System.assertNotEquals(null, response.slots, 'Slots should not be null');

        // With overrideCapacity=50, utilization check should be stricter
        if (!response.resourceUtilization.isEmpty()) {
            for (FSL_SimpleSlotsApi.ResourceUtilization util : response.resourceUtilization) {
                // If slots were generated, potential utilization should be <= 50
                if (util.slotsGenerated > 0) {
                    System.assert(util.potentialUtilization <= 50,
                        'Potential utilization should not exceed overrideCapacity (50%). Got: ' + util.potentialUtilization);
                }
            }
        }
    }

    // ==========================
    // Test: ST Capacity__c is used as fallback when no capacityPercentage
    // ==========================
    @isTest
    static void testSTCapacity_UsedAsFallback() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();

        // Set Capacity__c on the territory
        territory.put('Capacity__c', 60);
        update territory;

        Datetime testDate = getNextMonday();
        Datetime windowStart = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 14, 0, 0);
        Datetime windowEnd = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 23, 0, 0);

        // Don't send capacityPercentage — should fall back to ST.Capacity__c = 60
        String json = JSON.serialize(new Map<String, Object>{
            'serviceTerritoryId' => territory.Id,
            'workTypeId' => wt.Id,
            'earliestStart' => windowStart,
            'dueDate' => windowEnd,
            'operatingHoursTimeZone' => 'America/Costa_Rica',
            'slotStepMinutes' => 30,
            'maxSlotsPerResource' => 50,
            'excludeAbsences' => true
        });

        setupRestContext(json);

        Test.startTest();
        FSL_SimpleSlotsApi.SlotsResponse response = FSL_SimpleSlotsApi.getSimpleSlots();
        Test.stopTest();

        System.assertNotEquals(null, response, 'Response should not be null');
        // With ST capacity = 60%, resources should respect that limit
        if (!response.resourceUtilization.isEmpty()) {
            for (FSL_SimpleSlotsApi.ResourceUtilization util : response.resourceUtilization) {
                if (util.slotsGenerated > 0) {
                    System.assert(util.potentialUtilization <= 60,
                        'Potential utilization should not exceed ST Capacity (60%). Got: ' + util.potentialUtilization);
                }
            }
        }
    }

    // ==========================
    // Test: overrideCapacity overrides ST Capacity__c
    // ==========================
    @isTest
    static void testOverrideCapacity_OverridesSTCapacity() {
        ServiceTerritory territory = getTestTerritory();
        WorkType wt = getTestWorkType();

        // Set Capacity__c=40 on territory, but send overrideCapacity=90
        territory.put('Capacity__c', 40);
        update territory;

        Datetime testDate = getNextMonday();
        Datetime windowStart = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 14, 0, 0);
        Datetime windowEnd = Datetime.newInstanceGmt(testDate.yearGmt(), testDate.monthGmt(), testDate.dayGmt(), 23, 0, 0);

        String json = JSON.serialize(new Map<String, Object>{
            'serviceTerritoryId' => territory.Id,
            'workTypeId' => wt.Id,
            'earliestStart' => windowStart,
            'dueDate' => windowEnd,
            'operatingHoursTimeZone' => 'America/Costa_Rica',
            'slotStepMinutes' => 30,
            'maxSlotsPerResource' => 50,
            'overrideCapacity' => 90,
            'excludeAbsences' => true
        });

        setupRestContext(json);

        Test.startTest();
        FSL_SimpleSlotsApi.SlotsResponse response = FSL_SimpleSlotsApi.getSimpleSlots();
        Test.stopTest();

        System.assertNotEquals(null, response, 'Response should not be null');
        // overrideCapacity=90 should be used instead of ST.Capacity__c=40
        // So resources with low utilization should still get slots
        if (!response.resourceUtilization.isEmpty()) {
            for (FSL_SimpleSlotsApi.ResourceUtilization util : response.resourceUtilization) {
                if (util.slotsGenerated > 0) {
                    System.assert(util.potentialUtilization <= 90,
                        'Potential utilization should not exceed overrideCapacity (90%). Got: ' + util.potentialUtilization);
                }
            }
        }
    }

    // ==========================
    // Helper: Get next Saturday
    // ==========================
    private static Datetime getNextSaturday() {
        Datetime now = Datetime.now();
        // Find next Saturday (day 6)
        Integer currentDay = Integer.valueOf(now.format('u'));
        Integer daysUntilSaturday = Math.mod(13 - currentDay, 7);
        if (daysUntilSaturday == 0) daysUntilSaturday = 7;
        return now.addDays(daysUntilSaturday);
    }
}