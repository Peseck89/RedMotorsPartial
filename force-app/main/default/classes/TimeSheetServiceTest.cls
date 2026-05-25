@IsTest
private class TimeSheetServiceTest {

    @TestSetup
    static void setup() {
        // Create a User for the ServiceResource
        Profile p = [SELECT Id FROM Profile WHERE Name IN ('Standard User', 'Usuario estándar') LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'Mechanic',
            Email = 'testmechanic@redmotors.test',
            Username = 'testmechanic' + DateTime.now().getTime() + '@redmotors.test',
            Alias = 'tmech',
            TimeZoneSidKey = 'America/Bogota',
            LocaleSidKey = 'es_CO',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'es',
            ProfileId = p.Id
        );
        insert testUser;

        // Create data required by SuministrosTrigger (fires on WO insert)
        Product2 sumiProd = new Product2(Name = 'Suministros', IsActive = true);
        try { sumiProd.put('Codigo_de_Producto__c', 'SUMI'); } catch (Exception e) { /* field may not exist */ }
        insert sumiProd;
        try {
            SObject imp = Schema.getGlobalDescribe().get('Impuesto__c').newSObject();
            imp.put('Name', 'IVA 13%');
            imp.put('codigoImpuesto__c', '0108');
            insert imp;
        } catch (Exception e) { /* object may not exist */ }

        // Create ServiceResource
        ServiceResource sr = new ServiceResource();
        sr.Name = 'Test Mechanic SR';
        sr.RelatedRecordId = testUser.Id;
        sr.IsActive = true;
        sr.ResourceType = 'T';
        insert sr;
    }

    static ServiceResource getTestSR() {
        return [SELECT Id, RelatedRecordId FROM ServiceResource WHERE Name = 'Test Mechanic SR' LIMIT 1];
    }

    // ============================================================================
    // getOrCreateTimeSheetForToday Tests
    // ============================================================================

    @IsTest
    static void testGetOrCreateTimeSheetForToday_NewTS() {
        ServiceResource sr = getTestSR();

        Test.startTest();
        Id tsId = TimeSheetService.getOrCreateTimeSheetForToday(sr.Id);
        Test.stopTest();

        System.assertNotEquals(null, tsId, 'Should create a new TimeSheet');

        TimeSheet ts = [SELECT Id, ServiceResourceId, Status FROM TimeSheet WHERE Id = :tsId];
        System.assertEquals(sr.Id, ts.ServiceResourceId);
        System.assertEquals(TimeSheetService.TS_STATUS_NEW, ts.Status);
    }

    @IsTest
    static void testGetOrCreateTimeSheetForToday_ExistingTS() {
        ServiceResource sr = getTestSR();

        // Create a TS first
        Id tsId1 = TimeSheetService.getOrCreateTimeSheetForToday(sr.Id);

        Test.startTest();
        Id tsId2 = TimeSheetService.getOrCreateTimeSheetForToday(sr.Id);
        Test.stopTest();

        System.assertEquals(tsId1, tsId2, 'Should return existing TimeSheet');
    }

    @IsTest
    static void testGetOrCreateTimeSheetForToday_NullSR() {
        Test.startTest();
        Id tsId = TimeSheetService.getOrCreateTimeSheetForToday(null);
        Test.stopTest();

        System.assertEquals(null, tsId, 'Should return null for null SR');
    }

    // ============================================================================
    // createTimeSheetEntry Tests
    // ============================================================================

    @IsTest
    static void testCreateTimeSheetEntry_Basic() {
        ServiceResource sr = getTestSR();

        Test.startTest();
        Id tseId = TimeSheetService.createTimeSheetEntry(
            sr.Id, DateTime.now(), null,
            TimeSheetService.TSE_TYPE_PRODUCTIVO,
            TimeSheetService.DETALLE_TRABAJO,
            TimeSheetService.ETAPA_TRABAJO,
            null, 1, null, null
        );
        Test.stopTest();

        System.assertNotEquals(null, tseId, 'Should create a TimeSheetEntry');

        TimeSheetEntry tse = [SELECT Id, Subject, EndTime FROM TimeSheetEntry WHERE Id = :tseId];
        System.assert(tse.Subject.contains('Trabajo'), 'Subject should contain Trabajo');
        System.assertEquals(null, tse.EndTime, 'EndTime should be null (open entry)');
    }

    @IsTest
    static void testCreateTimeSheetEntry_AllFields() {
        ServiceResource sr = getTestSR();

        Test.startTest();
        Id tseId = TimeSheetService.createTimeSheetEntry(
            sr.Id, DateTime.now(), DateTime.now().addHours(1),
            TimeSheetService.TSE_TYPE_MUERTO,
            TimeSheetService.DETALLE_PAUSA,
            TimeSheetService.ETAPA_PAUSA,
            'Almuerzo', 2, null, null
        );
        Test.stopTest();

        System.assertNotEquals(null, tseId, 'Should create a TimeSheetEntry with all fields');

        TimeSheetEntry tse = [SELECT Id, Subject, EndTime FROM TimeSheetEntry WHERE Id = :tseId];
        System.assertNotEquals(null, tse.EndTime, 'EndTime should be set');
    }

    @IsTest
    static void testCreateTimeSheetEntry_NullSR() {
        Test.startTest();
        Id tseId = TimeSheetService.createTimeSheetEntry(
            null, DateTime.now(), null,
            TimeSheetService.TSE_TYPE_PRODUCTIVO,
            TimeSheetService.DETALLE_TRABAJO,
            TimeSheetService.ETAPA_TRABAJO,
            null, 1, null, null
        );
        Test.stopTest();

        System.assertEquals(null, tseId, 'Should return null for null SR');
    }

    // ============================================================================
    // closeOpenTimeSheetEntry Tests
    // ============================================================================

    @IsTest
    static void testCloseOpenTimeSheetEntry() {
        ServiceResource sr = getTestSR();

        // Create an open entry with StartTime in the past so EndTime > StartTime
        Id tseId = TimeSheetService.createTimeSheetEntry(
            sr.Id, DateTime.now().addMinutes(-30), null,
            TimeSheetService.TSE_TYPE_PRODUCTIVO,
            TimeSheetService.DETALLE_TRABAJO,
            TimeSheetService.ETAPA_TRABAJO,
            null, 1, null, null
        );

        Test.startTest();
        TimeSheetService.closeOpenTimeSheetEntry(sr.Id, TimeSheetService.ETAPA_TRABAJO);
        Test.stopTest();

        TimeSheetEntry tse = [SELECT Id, EndTime FROM TimeSheetEntry WHERE Id = :tseId];
        System.assertNotEquals(null, tse.EndTime, 'EndTime should be set after close');
    }

    @IsTest
    static void testCloseOpenTimeSheetEntry_NullSR() {
        Test.startTest();
        // Should not throw
        TimeSheetService.closeOpenTimeSheetEntry(null, TimeSheetService.ETAPA_TRABAJO);
        Test.stopTest();
    }

    // ============================================================================
    // getCurrentMecanicoId Tests
    // ============================================================================

    @IsTest
    static void testGetCurrentMecanicoId() {
        ServiceResource sr = getTestSR();

        User testUser = [SELECT Id FROM User WHERE Id = :sr.RelatedRecordId];

        Test.startTest();
        Id result;
        System.runAs(testUser) {
            result = TimeSheetService.getCurrentMecanicoId();
        }
        Test.stopTest();

        System.assertEquals(sr.Id, result, 'Should return the ServiceResource Id');
    }

    // ============================================================================
    // createDailyTimeSheets Tests
    // ============================================================================

    @IsTest
    static void testCreateDailyTimeSheets_All() {
        Test.startTest();
        Map<String, Integer> results = TimeSheetService.createDailyTimeSheets();
        Test.stopTest();

        System.assertNotEquals(null, results, 'Results should not be null');
        System.assert(results.get('created') >= 1, 'Should create at least 1 TS');
    }

    @IsTest
    static void testCreateDailyTimeSheets_Skip() {
        ServiceResource sr = getTestSR();

        // Create a TS first
        TimeSheetService.getOrCreateTimeSheetForToday(sr.Id);

        Test.startTest();
        Map<String, Integer> results = TimeSheetService.createDailyTimeSheets();
        Test.stopTest();

        System.assertEquals(0, results.get('created'), 'Should not create TS (already exists)');
        System.assert(results.get('skipped') >= 1, 'Should skip at least 1');
    }

    @IsTest
    static void testCreateDailyTimeSheets_WithAbsence() {
        ServiceResource sr = getTestSR();

        // Create a ResourceAbsence for today
        // NOTE: The ResourceAbsenceTrigger will create a TS+TSE on insert.
        // So when the scheduler runs, it finds the existing TS and skips it.
        ResourceAbsence ra = new ResourceAbsence();
        ra.ResourceId = sr.Id;
        ra.Start = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        ra.End = DateTime.newInstance(Date.today().addDays(1), Time.newInstance(0, 0, 0, 0));
        ra.Type = 'Vacation';
        insert ra;

        Test.startTest();
        Map<String, Integer> results = TimeSheetService.createDailyTimeSheets();
        Test.stopTest();

        // The trigger already created the TS, so the scheduler should skip or find it
        // Either way, a TS and TSE should exist
        List<TimeSheet> tsList = [SELECT Id FROM TimeSheet WHERE ServiceResourceId = :sr.Id];
        System.assert(tsList.size() >= 1, 'Should have at least 1 TS (from trigger or scheduler)');

        List<TimeSheetEntry> tseList = [SELECT Id FROM TimeSheetEntry WHERE TimeSheetId IN :tsList];
        System.assert(tseList.size() >= 1, 'Should have at least 1 TSE from absence');
    }

    // ============================================================================
    // recalculateAccumulatedTime Tests
    // ============================================================================

    @IsTest
    static void testRecalculateAccumulatedTime_WithTSEs() {
        ServiceResource sr = getTestSR();

        // Create WorkOrder + WOLI + SA
        WorkOrder wo = new WorkOrder();
        wo.Subject = 'Test WO';
        insert wo;

        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId = wo.Id;
        woli.Duration = 60;
        woli.DurationType = 'Minutes';
        insert woli;

        // Create closed TSEs linked to the WOLI
        Id tsId = TimeSheetService.getOrCreateTimeSheetForToday(sr.Id);

        DateTime baseTime = DateTime.now().addHours(-3);

        // TSE 1: Trabajo - 30 min
        TimeSheetEntry tse1 = new TimeSheetEntry();
        tse1.TimeSheetId = tsId;
        tse1.WorkOrderLineItemId = woli.Id;
        tse1.StartTime = baseTime;
        tse1.EndTime = baseTime.addMinutes(30);
        tse1.Subject = 'Trabajo';
        tse1.put('Tipo_de_Etapa__c', TimeSheetService.ETAPA_TRABAJO);
        tse1.put('Detalle_Tipo_Entrada__c', TimeSheetService.DETALLE_TRABAJO);

        // TSE 2: Pausa - 15 min
        TimeSheetEntry tse2 = new TimeSheetEntry();
        tse2.TimeSheetId = tsId;
        tse2.WorkOrderLineItemId = woli.Id;
        tse2.StartTime = baseTime.addMinutes(30);
        tse2.EndTime = baseTime.addMinutes(45);
        tse2.Subject = 'Pausa';
        tse2.put('Tipo_de_Etapa__c', TimeSheetService.ETAPA_PAUSA);
        tse2.put('Detalle_Tipo_Entrada__c', TimeSheetService.DETALLE_PAUSA);
        tse2.put('Motivo_de_Pausa__c', 'Almuerzo');

        // TSE 3: Retrabajo - 20 min
        TimeSheetEntry tse3 = new TimeSheetEntry();
        tse3.TimeSheetId = tsId;
        tse3.WorkOrderLineItemId = woli.Id;
        tse3.StartTime = baseTime.addMinutes(45);
        tse3.EndTime = baseTime.addMinutes(65);
        tse3.Subject = 'Retrabajo';
        tse3.put('Tipo_de_Etapa__c', TimeSheetService.ETAPA_TRABAJO);
        tse3.put('Detalle_Tipo_Entrada__c', TimeSheetService.DETALLE_RETRABAJO);

        insert new List<TimeSheetEntry>{ tse1, tse2, tse3 };

        Test.startTest();
        TimeSheetService.recalculateAccumulatedTime(woli.Id, null);
        Test.stopTest();

        WorkOrderLineItem woliAfter = [
            SELECT Total_Trabajo_Min__c, Total_Pausa_Min__c, Total_Retrabajo_Min__c
            FROM WorkOrderLineItem
            WHERE Id = :woli.Id
        ];

        System.assertEquals(30.0, woliAfter.Total_Trabajo_Min__c, 'Trabajo should be 30 min');
        System.assertEquals(15.0, woliAfter.Total_Pausa_Min__c, 'Pausa should be 15 min');
        System.assertEquals(20.0, woliAfter.Total_Retrabajo_Min__c, 'Retrabajo should be 20 min');
    }

    @IsTest
    static void testRecalculateAccumulatedTime_NoTSEs() {
        // Create WorkOrder + WOLI + SA with no TSEs
        WorkOrder wo = new WorkOrder();
        wo.Subject = 'Test WO Empty';
        insert wo;

        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId = wo.Id;
        woli.Duration = 60;
        woli.DurationType = 'Minutes';
        insert woli;

        Test.startTest();
        TimeSheetService.recalculateAccumulatedTime(woli.Id, null);
        Test.stopTest();

        WorkOrderLineItem woliAfter = [
            SELECT Total_Trabajo_Min__c, Total_Pausa_Min__c, Total_Retrabajo_Min__c
            FROM WorkOrderLineItem
            WHERE Id = :woli.Id
        ];

        System.assertEquals(0, woliAfter.Total_Trabajo_Min__c, 'Trabajo should be 0');
        System.assertEquals(0, woliAfter.Total_Pausa_Min__c, 'Pausa should be 0');
        System.assertEquals(0, woliAfter.Total_Retrabajo_Min__c, 'Retrabajo should be 0');
    }

    @IsTest
    static void testRecalculateAccumulatedTime_NullSaId() {
        Test.startTest();
        // Should not throw
        TimeSheetService.recalculateAccumulatedTime(null, null);
        Test.stopTest();
    }

    @IsTest
    static void testRecalculateAccumulatedTime_NullWoliId() {
        Test.startTest();
        // Should not throw, just log warning and skip
        TimeSheetService.recalculateAccumulatedTime(null, null);
        Test.stopTest();
    }

    // ============================================================================
    // Constants Tests
    // ============================================================================

    @IsTest
    static void testConstants() {
        System.assertEquals('Borrador', TimeSheetService.TS_STATUS_NEW);
        System.assertEquals('En Progreso', TimeSheetService.TS_STATUS_SUBMITTED);
        System.assertEquals('Terminado', TimeSheetService.TS_STATUS_APPROVED);
        System.assertEquals('Tiempo productivo', TimeSheetService.TSE_TYPE_PRODUCTIVO);
        System.assertEquals('Tiempo muerto', TimeSheetService.TSE_TYPE_MUERTO);
        System.assertEquals('Trabajo', TimeSheetService.ETAPA_TRABAJO);
        System.assertEquals('Pausa', TimeSheetService.ETAPA_PAUSA);
    }

    // ============================================================================
    // Operating Hours Validation Tests
    // ============================================================================

    @IsTest
    static void testDailyScheduler_SkipsNonWorkingDays() {
        ServiceResource sr = getTestSR();

        // Create OperatingHours with NO TimeSlots for today's day of week
        OperatingHours oh = new OperatingHours(
            Name = 'Test OH No Today',
            TimeZone = 'America/Costa_Rica'
        );
        insert oh;

        // Get today's day name and create slots for OTHER days only
        Date today = Date.today();
        String todayDay = DateTime.newInstance(today, Time.newInstance(12, 0, 0, 0)).formatGmt('EEEE');
        List<String> allDays = new List<String>{'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'};
        List<TimeSlot> slots = new List<TimeSlot>();
        for (String day : allDays) {
            if (day != todayDay) {
                slots.add(new TimeSlot(
                    OperatingHoursId = oh.Id,
                    DayOfWeek = day,
                    StartTime = Time.newInstance(7, 0, 0, 0),
                    EndTime = Time.newInstance(18, 0, 0, 0)
                ));
            }
        }
        insert slots;

        ServiceTerritory st = new ServiceTerritory(
            Name = 'Test Territory No Today',
            OperatingHoursId = oh.Id,
            IsActive = true
        );
        insert st;

        ServiceTerritoryMember stm = new ServiceTerritoryMember(
            ServiceResourceId = sr.Id,
            ServiceTerritoryId = st.Id,
            EffectiveStartDate = Date.today().addDays(-1),
            TerritoryType = 'P'
        );
        insert stm;

        Test.startTest();
        Map<String, Integer> results = TimeSheetService.createDailyTimeSheets();
        Test.stopTest();

        // The mechanic's territory has no slot for today, so should be skipped
        Integer skipped = results.get('skippedNonWorking');
        System.assertNotEquals(null, skipped, 'Should have skippedNonWorking counter');
        System.assert(skipped >= 1, 'Should skip at least 1 mechanic for non-working day');

        // Verify no TS was created
        List<TimeSheet> tsList = [SELECT Id FROM TimeSheet WHERE ServiceResourceId = :sr.Id AND StartDate = :today];
        System.assertEquals(0, tsList.size(), 'Should NOT create TS for non-working day');
    }

    @IsTest
    static void testDailyScheduler_CreatesOnWorkingDays() {
        ServiceResource sr = getTestSR();

        // Create OperatingHours WITH TimeSlot for today
        OperatingHours oh = new OperatingHours(
            Name = 'Test OH With Today',
            TimeZone = 'America/Costa_Rica'
        );
        insert oh;

        String todayDay = DateTime.newInstance(Date.today(), Time.newInstance(12, 0, 0, 0)).formatGmt('EEEE');
        insert new TimeSlot(
            OperatingHoursId = oh.Id,
            DayOfWeek = todayDay,
            StartTime = Time.newInstance(7, 0, 0, 0),
            EndTime = Time.newInstance(18, 0, 0, 0)
        );

        ServiceTerritory st = new ServiceTerritory(
            Name = 'Test Territory With Today',
            OperatingHoursId = oh.Id,
            IsActive = true
        );
        insert st;

        ServiceTerritoryMember stm = new ServiceTerritoryMember(
            ServiceResourceId = sr.Id,
            ServiceTerritoryId = st.Id,
            EffectiveStartDate = Date.today().addDays(-1),
            TerritoryType = 'P'
        );
        insert stm;

        Test.startTest();
        Map<String, Integer> results = TimeSheetService.createDailyTimeSheets();
        Test.stopTest();

        System.assert(results.get('created') >= 1, 'Should create TS for working day');

        List<TimeSheet> tsList = [SELECT Id FROM TimeSheet WHERE ServiceResourceId = :sr.Id AND StartDate = :Date.today()];
        System.assert(tsList.size() >= 1, 'Should have created TS for working day');
    }

    // ============================================================================
    // isStatusNew / isStatusSubmitted / isStatusApproved Tests
    // ============================================================================

    @IsTest
    static void testStatusHelpers() {
        // isStatusNew
        System.assertEquals(true, TimeSheetService.isStatusNew('New'), 'English New should match');
        System.assertEquals(true, TimeSheetService.isStatusNew('Borrador'), 'Spanish Borrador should match');
        System.assertEquals(false, TimeSheetService.isStatusNew('Submitted'), 'Submitted should not match New');

        // isStatusSubmitted
        System.assertEquals(true, TimeSheetService.isStatusSubmitted('Submitted'), 'English Submitted should match');
        System.assertEquals(true, TimeSheetService.isStatusSubmitted('En Progreso'), 'Spanish En Progreso should match');
        System.assertEquals(false, TimeSheetService.isStatusSubmitted('New'), 'New should not match Submitted');

        // isStatusApproved
        System.assertEquals(true, TimeSheetService.isStatusApproved('Approved'), 'English Approved should match');
        System.assertEquals(true, TimeSheetService.isStatusApproved('Terminado'), 'Spanish Terminado should match');
        System.assertEquals(false, TimeSheetService.isStatusApproved('Submitted'), 'Submitted should not match Approved');
    }

    // ============================================================================
    // getTypeForMotivoPausa Tests
    // ============================================================================

    @IsTest
    static void testGetTypeForMotivoPausa() {
        // Motivos de pausa personal → Tiempo no productivo
        System.assertEquals(TimeSheetService.TSE_TYPE_NO_PRODUCTIVO,
            TimeSheetService.getTypeForMotivoPausa('Almuerzo'), 'Almuerzo should be no productivo');
        System.assertEquals(TimeSheetService.TSE_TYPE_NO_PRODUCTIVO,
            TimeSheetService.getTypeForMotivoPausa('Café'), 'Café should be no productivo');

        // Motivos de tiempo muerto
        System.assertEquals(TimeSheetService.TSE_TYPE_MUERTO,
            TimeSheetService.getTypeForMotivoPausa('Espera de repuesto'), 'Espera should be muerto');
        System.assertEquals(TimeSheetService.TSE_TYPE_MUERTO,
            TimeSheetService.getTypeForMotivoPausa('Elaboración de presupuesto'), 'Presupuesto should be muerto');

        // Blank → muerto (default)
        System.assertEquals(TimeSheetService.TSE_TYPE_MUERTO,
            TimeSheetService.getTypeForMotivoPausa(null), 'Null should be muerto');
        System.assertEquals(TimeSheetService.TSE_TYPE_MUERTO,
            TimeSheetService.getTypeForMotivoPausa(''), 'Empty should be muerto');

        // Unknown → muerto (default)
        System.assertEquals(TimeSheetService.TSE_TYPE_MUERTO,
            TimeSheetService.getTypeForMotivoPausa('Motivo desconocido'), 'Unknown should be muerto');
    }

    // ============================================================================
    // getLastRunAlerts Tests
    // ============================================================================

    @IsTest
    static void testGetLastRunAlerts() {
        Test.startTest();
        List<Map<String, String>> alerts = TimeSheetService.getLastRunAlerts();
        Test.stopTest();

        System.assertNotEquals(null, alerts, 'Alerts list should not be null');
        System.assertEquals(0, alerts.size(), 'Should start with empty alerts');
    }

    // ============================================================================
    // Approval Methods Tests
    // ============================================================================

    @IsTest
    static void testApproveTimeSheet() {
        ServiceResource sr = getTestSR();
        Id tsId = TimeSheetService.getOrCreateTimeSheetForToday(sr.Id);

        // Set up TS in Terminado + Pendiente state for approval
        TimeSheet ts = [SELECT Id FROM TimeSheet WHERE Id = :tsId];
        ts.Status = TimeSheetService.TS_STATUS_APPROVED;
        ts.put('Estado_Revision__c', TimeSheetService.REVISION_PENDIENTE);
        ts.put('Hora_de_ingreso__c', Time.newInstance(7, 0, 0, 0));
        ts.put('Hora_de_salida__c', Time.newInstance(17, 0, 0, 0));
        update ts;

        Test.startTest();
        TimeSheetService.approveTimeSheet(tsId);
        Test.stopTest();

        TimeSheet updated = [SELECT Estado_Revision__c FROM TimeSheet WHERE Id = :tsId];
        System.assertEquals(TimeSheetService.REVISION_APROBADO, updated.Estado_Revision__c,
            'Estado_Revision should be Aprobado');
    }

    @IsTest
    static void testApproveTimeSheetsBulk() {
        ServiceResource sr = getTestSR();
        Id tsId = TimeSheetService.getOrCreateTimeSheetForToday(sr.Id);

        TimeSheet ts = [SELECT Id FROM TimeSheet WHERE Id = :tsId];
        ts.Status = TimeSheetService.TS_STATUS_APPROVED;
        ts.put('Estado_Revision__c', TimeSheetService.REVISION_PENDIENTE);
        ts.put('Hora_de_ingreso__c', Time.newInstance(7, 0, 0, 0));
        ts.put('Hora_de_salida__c', Time.newInstance(17, 0, 0, 0));
        update ts;

        Test.startTest();
        TimeSheetService.approveTimeSheetsBulk(new List<Id>{ tsId });
        Test.stopTest();

        TimeSheet updated = [SELECT Estado_Revision__c FROM TimeSheet WHERE Id = :tsId];
        System.assertEquals(TimeSheetService.REVISION_APROBADO, updated.Estado_Revision__c,
            'Bulk approval should set Aprobado');
    }

    @IsTest
    static void testApproveTimeSheetsBulk_NullList() {
        Test.startTest();
        // Should not throw
        TimeSheetService.approveTimeSheetsBulk(null);
        TimeSheetService.approveTimeSheetsBulk(new List<Id>());
        Test.stopTest();
    }

    @IsTest
    static void testRejectTimeSheet() {
        ServiceResource sr = getTestSR();
        Id tsId = TimeSheetService.getOrCreateTimeSheetForToday(sr.Id);

        // Set up TS in Terminado state
        TimeSheet ts = [SELECT Id FROM TimeSheet WHERE Id = :tsId];
        ts.Status = TimeSheetService.TS_STATUS_APPROVED;
        ts.put('Hora_de_ingreso__c', Time.newInstance(7, 0, 0, 0));
        ts.put('Hora_de_salida__c', Time.newInstance(17, 0, 0, 0));
        update ts;

        Test.startTest();
        TimeSheetService.rejectTimeSheet(tsId, 'Horas incorrectas');
        Test.stopTest();

        TimeSheet updated = [SELECT Status, Estado_Revision__c, Comentario_Rechazo__c
                             FROM TimeSheet WHERE Id = :tsId];
        System.assertEquals(TimeSheetService.TS_STATUS_SUBMITTED, updated.Status,
            'Status should revert to En Progreso');
        System.assertEquals(TimeSheetService.REVISION_RECHAZADO, updated.Estado_Revision__c,
            'Estado_Revision should be Rechazado');
        System.assertEquals('Horas incorrectas', updated.Comentario_Rechazo__c,
            'Comment should be saved');
    }

    @IsTest
    static void testRejectTimeSheet_NotApproved() {
        ServiceResource sr = getTestSR();
        Id tsId = TimeSheetService.getOrCreateTimeSheetForToday(sr.Id);

        // TS is in Borrador (New) state — reject should do nothing
        Test.startTest();
        TimeSheetService.rejectTimeSheet(tsId, 'Should not work');
        Test.stopTest();

        TimeSheet updated = [SELECT Status FROM TimeSheet WHERE Id = :tsId];
        System.assertEquals(TimeSheetService.TS_STATUS_NEW, updated.Status,
            'Status should remain unchanged');
    }

    @IsTest
    static void testSubmitForReview() {
        ServiceResource sr = getTestSR();
        Id tsId = TimeSheetService.getOrCreateTimeSheetForToday(sr.Id);

        Test.startTest();
        TimeSheetService.submitForReview(tsId);
        Test.stopTest();

        TimeSheet updated = [SELECT Estado_Revision__c FROM TimeSheet WHERE Id = :tsId];
        System.assertEquals(TimeSheetService.REVISION_PENDIENTE, updated.Estado_Revision__c,
            'Estado_Revision should be Pendiente');
    }

    @IsTest
    static void testSubmitForReview_NullId() {
        Test.startTest();
        // Should not throw
        TimeSheetService.submitForReview(null);
        Test.stopTest();
    }

    // ============================================================================
    // getTimeSheetEntries Tests
    // ============================================================================

    @IsTest
    static void testGetTimeSheetEntries() {
        ServiceResource sr = getTestSR();

        // Create a TSE
        Id tseId = TimeSheetService.createTimeSheetEntry(
            sr.Id, DateTime.now().addMinutes(-60), DateTime.now(),
            TimeSheetService.TSE_TYPE_PRODUCTIVO,
            TimeSheetService.DETALLE_TRABAJO,
            TimeSheetService.ETAPA_TRABAJO,
            null, 1, null, null
        );
        Id tsId = [SELECT TimeSheetId FROM TimeSheetEntry WHERE Id = :tseId].TimeSheetId;

        Test.startTest();
        List<TimeSheetService.TimeSheetEntryDetail> entries =
            TimeSheetService.getTimeSheetEntries(tsId);
        Test.stopTest();

        System.assert(entries.size() >= 1, 'Should return at least 1 entry');
        TimeSheetService.TimeSheetEntryDetail detail = entries[0];
        System.assertNotEquals(null, detail.id, 'Entry ID should not be null');
        System.assertNotEquals(null, detail.startTime, 'StartTime should not be null');
        System.assertEquals(true, detail.isClosed, 'Entry should be closed');
        System.assert(detail.duracionMin > 0, 'Duration should be > 0');
    }

    @IsTest
    static void testGetTimeSheetEntries_NullId() {
        Test.startTest();
        List<TimeSheetService.TimeSheetEntryDetail> entries =
            TimeSheetService.getTimeSheetEntries(null);
        Test.stopTest();

        System.assertNotEquals(null, entries, 'Should return empty list, not null');
        System.assertEquals(0, entries.size(), 'Should be empty');
    }

    // ============================================================================
    // updateTimeSheetHours Tests
    // ============================================================================

    @IsTest
    static void testUpdateTimeSheetHours() {
        ServiceResource sr = getTestSR();
        Id tsId = TimeSheetService.getOrCreateTimeSheetForToday(sr.Id);

        Test.startTest();
        TimeSheetService.updateTimeSheetHours(tsId, '08:30', '17:15');
        Test.stopTest();

        TimeSheet updated = [SELECT Hora_de_ingreso__c, Hora_de_salida__c
                             FROM TimeSheet WHERE Id = :tsId];
        System.assertEquals(Time.newInstance(8, 30, 0, 0), updated.Hora_de_ingreso__c,
            'Ingreso should be 08:30');
        System.assertEquals(Time.newInstance(17, 15, 0, 0), updated.Hora_de_salida__c,
            'Salida should be 17:15');
    }

    @IsTest
    static void testUpdateTimeSheetHours_IngresoOnly() {
        ServiceResource sr = getTestSR();
        Id tsId = TimeSheetService.getOrCreateTimeSheetForToday(sr.Id);

        Test.startTest();
        TimeSheetService.updateTimeSheetHours(tsId, '07:00', null);
        Test.stopTest();

        TimeSheet updated = [SELECT Hora_de_ingreso__c, Hora_de_salida__c
                             FROM TimeSheet WHERE Id = :tsId];
        System.assertEquals(Time.newInstance(7, 0, 0, 0), updated.Hora_de_ingreso__c);
        System.assertEquals(null, updated.Hora_de_salida__c, 'Salida should remain null');
    }

    // ============================================================================
    // getCurrentUserTerritory Tests
    // ============================================================================

    @IsTest
    static void testGetCurrentUserTerritory_WithTerritory() {
        ServiceResource sr = getTestSR();

        // Create territory and membership
        OperatingHours oh = new OperatingHours(Name = 'Test OH Territory');
        insert oh;

        ServiceTerritory st = new ServiceTerritory(
            Name = 'Taller Test',
            OperatingHoursId = oh.Id,
            IsActive = true
        );
        insert st;

        ServiceTerritoryMember stm = new ServiceTerritoryMember(
            ServiceResourceId = sr.Id,
            ServiceTerritoryId = st.Id,
            EffectiveStartDate = Date.today().addDays(-1),
            TerritoryType = 'P'
        );
        insert stm;

        User testUser = [SELECT Id FROM User WHERE Id = :sr.RelatedRecordId];

        Test.startTest();
        Map<String, String> result;
        System.runAs(testUser) {
            result = TimeSheetService.getCurrentUserTerritory();
        }
        Test.stopTest();

        System.assertNotEquals(null, result, 'Should return territory map');
        System.assertEquals(st.Id, result.get('id'), 'Territory ID should match');
        System.assertEquals('Taller Test', result.get('name'), 'Territory name should match');
    }

    @IsTest
    static void testGetCurrentUserTerritory_NoTerritory() {
        Test.startTest();
        Map<String, String> result = TimeSheetService.getCurrentUserTerritory();
        Test.stopTest();

        // Current running user likely has no ServiceResource
        // This test just ensures no exception is thrown
        // Result may be null if running user has no SR
    }

    // ============================================================================
    // getTimeSheetsForTerritory Tests
    // ============================================================================

    @IsTest
    static void testGetTimeSheetsForTerritory() {
        ServiceResource sr = getTestSR();

        OperatingHours oh = new OperatingHours(Name = 'Test OH TSForTerritory');
        insert oh;

        ServiceTerritory st = new ServiceTerritory(
            Name = 'Taller TS Territory',
            OperatingHoursId = oh.Id,
            IsActive = true
        );
        insert st;

        ServiceTerritoryMember stm = new ServiceTerritoryMember(
            ServiceResourceId = sr.Id,
            ServiceTerritoryId = st.Id,
            EffectiveStartDate = Date.today().addDays(-1),
            TerritoryType = 'P'
        );
        insert stm;

        // Create TimeSheet for today
        TimeSheetService.getOrCreateTimeSheetForToday(sr.Id);

        Test.startTest();
        List<TimeSheetService.TimeSheetSummary> summaries =
            TimeSheetService.getTimeSheetsForTerritory(st.Id, Date.today());
        Test.stopTest();

        System.assertNotEquals(null, summaries, 'Should return list');
        System.assert(summaries.size() >= 1, 'Should have at least 1 summary');

        TimeSheetService.TimeSheetSummary s = summaries[0];
        System.assertNotEquals(null, s.timeSheetId, 'TS ID should not be null');
        System.assertNotEquals(null, s.mecanicoName, 'Mechanic name should not be null');
        System.assertEquals(Date.today(), s.fecha, 'Fecha should be today');
    }

    @IsTest
    static void testGetTimeSheetsForTerritory_NullParams() {
        Test.startTest();
        List<TimeSheetService.TimeSheetSummary> result1 =
            TimeSheetService.getTimeSheetsForTerritory(null, Date.today());
        List<TimeSheetService.TimeSheetSummary> result2 =
            TimeSheetService.getTimeSheetsForTerritory(null, null);
        Test.stopTest();

        System.assertEquals(0, result1.size(), 'Should return empty for null territory');
        System.assertEquals(0, result2.size(), 'Should return empty for null params');
    }

    // ============================================================================
    // Additional Constants Tests
    // ============================================================================

    @IsTest
    static void testAdditionalConstants() {
        // Detalle constants
        System.assertEquals('Trabajo', TimeSheetService.DETALLE_TRABAJO);
        System.assertEquals('Pausa', TimeSheetService.DETALLE_PAUSA);
        System.assertEquals('Retrabajo', TimeSheetService.DETALLE_RETRABAJO);
        System.assertEquals('Vacaciones', TimeSheetService.DETALLE_VACACIONES);
        System.assertEquals('Dia de enfermedad', TimeSheetService.DETALLE_ENFERMEDAD);
        System.assertEquals('Ausencia personal', TimeSheetService.DETALLE_PERSONAL);
        System.assertEquals('Capacitacion', TimeSheetService.DETALLE_CAPACITACION);
        System.assertEquals('Otra ausencia', TimeSheetService.DETALLE_OTRA);
        System.assertEquals('Limpieza', TimeSheetService.DETALLE_LIMPIEZA);

        // Type constants
        System.assertEquals('Tiempo no productivo', TimeSheetService.TSE_TYPE_NO_PRODUCTIVO);
        System.assertEquals('Tiempo personal', TimeSheetService.TSE_TYPE_PERSONAL);

        // Revision constants
        System.assertEquals('Pendiente', TimeSheetService.REVISION_PENDIENTE);
        System.assertEquals('Aprobado', TimeSheetService.REVISION_APROBADO);
        System.assertEquals('Rechazado', TimeSheetService.REVISION_RECHAZADO);

        // Work hours
        System.assertEquals(7, TimeSheetService.WORK_START_HOUR);
        System.assertEquals(17, TimeSheetService.WORK_END_HOUR);
    }

    // ============================================================================
    // Wrapper class instantiation Tests
    // ============================================================================

    @IsTest
    static void testTimeSheetSummaryWrapper() {
        TimeSheetService.TimeSheetSummary s = new TimeSheetService.TimeSheetSummary();
        s.timeSheetId = null;
        s.mecanicoName = 'Test';
        s.serviceResourceId = null;
        s.status = 'New';
        s.estadoRevision = 'Pendiente';
        s.comentarioRechazo = 'Motivo';
        s.horaIngreso = '08:00';
        s.horaSalida = '17:00';
        s.horasLaboradas = 9.0;
        s.totalTrabajoMin = 420.0;
        s.totalPausaMin = 60.0;
        s.totalEntries = 5;
        s.fecha = Date.today();

        System.assertEquals('Test', s.mecanicoName);
        System.assertEquals(9.0, s.horasLaboradas);
    }

    @IsTest
    static void testTimeSheetEntryDetailWrapper() {
        TimeSheetService.TimeSheetEntryDetail d = new TimeSheetService.TimeSheetEntryDetail();
        d.id = null;
        d.subject = 'Trabajo';
        d.startTime = DateTime.now();
        d.endTime = DateTime.now().addHours(1);
        d.type = 'Tiempo productivo';
        d.tipoEtapa = 'Trabajo';
        d.detalle = 'Trabajo';
        d.motivoPausa = null;
        d.ciclo = 1;
        d.isClosed = true;
        d.duracionMin = 60.0;

        System.assertEquals('Trabajo', d.subject);
        System.assertEquals(60.0, d.duracionMin);
    }

    // ============================================================================
    // createTimeSheetEntry with SA ID (overloaded method) Tests
    // ============================================================================

    @IsTest
    static void testCreateTimeSheetEntry_WithSAId() {
        ServiceResource sr = getTestSR();

        WorkOrder wo = new WorkOrder(Subject = 'Test WO With SA');
        insert wo;
        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = wo.Id, Duration = 60, DurationType = 'Minutes');
        insert woli;

        Test.startTest();
        Id tseId = TimeSheetService.createTimeSheetEntry(
            sr.Id, DateTime.now(), null,
            TimeSheetService.TSE_TYPE_PRODUCTIVO,
            TimeSheetService.DETALLE_TRABAJO,
            TimeSheetService.ETAPA_TRABAJO,
            null, 1, wo.Id, woli.Id, null
        );
        Test.stopTest();

        System.assertNotEquals(null, tseId, 'Should create TSE through overloaded method');
    }

    // ============================================================================
    // closeOpenTimeSheetEntry - No open entry & null tipoEtapa Tests
    // ============================================================================

    @IsTest
    static void testCloseOpenTimeSheetEntry_NoOpenEntry() {
        ServiceResource sr = getTestSR();

        // Create a TS but NO open TSE - the close should silently do nothing
        TimeSheetService.getOrCreateTimeSheetForToday(sr.Id);

        Test.startTest();
        // Should not throw even though there is no open entry to close
        TimeSheetService.closeOpenTimeSheetEntry(sr.Id, TimeSheetService.ETAPA_TRABAJO);
        Test.stopTest();

        // Verify no TSEs were created or modified
        List<TimeSheetEntry> entries = [
            SELECT Id FROM TimeSheetEntry
            WHERE TimeSheet.ServiceResourceId = :sr.Id
            AND TimeSheet.StartDate = :Date.today()
        ];
        System.assertEquals(0, entries.size(), 'Should have no TSE entries');
    }

    @IsTest
    static void testCloseOpenTimeSheetEntry_NullTipoEtapa() {
        ServiceResource sr = getTestSR();

        // Create an open entry without a specific tipo etapa
        Id tseId = TimeSheetService.createTimeSheetEntry(
            sr.Id, DateTime.now().addMinutes(-30), null,
            TimeSheetService.TSE_TYPE_PRODUCTIVO,
            TimeSheetService.DETALLE_TRABAJO,
            TimeSheetService.ETAPA_TRABAJO,
            null, 1, null, null
        );

        Test.startTest();
        // Passing null for tipoEtapa should still close the open entry
        // (the query omits the Tipo_de_Etapa__c filter when tipoEtapa is blank)
        TimeSheetService.closeOpenTimeSheetEntry(sr.Id, null);
        Test.stopTest();

        TimeSheetEntry tse = [SELECT Id, EndTime FROM TimeSheetEntry WHERE Id = :tseId];
        System.assertNotEquals(null, tse.EndTime, 'EndTime should be set when closing with null tipoEtapa');
    }

    // ============================================================================
    // createTimeSheetEntry - Verify WO/WOLI fields on TSE
    // ============================================================================

    @IsTest
    static void testCreateTimeSheetEntry_VerifyWOLIFields() {
        ServiceResource sr = getTestSR();

        WorkOrder wo = new WorkOrder(Subject = 'Test WO Fields');
        insert wo;
        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = wo.Id, Duration = 60, DurationType = 'Minutes');
        insert woli;

        Test.startTest();
        Id tseId = TimeSheetService.createTimeSheetEntry(
            sr.Id, DateTime.now(), null,
            TimeSheetService.TSE_TYPE_PRODUCTIVO,
            TimeSheetService.DETALLE_TRABAJO,
            TimeSheetService.ETAPA_TRABAJO,
            null, 1, wo.Id, woli.Id
        );
        Test.stopTest();

        System.assertNotEquals(null, tseId, 'Should create TSE');

        TimeSheetEntry tse = [
            SELECT Id, WorkOrderId, WorkOrderLineItemId
            FROM TimeSheetEntry WHERE Id = :tseId
        ];
        System.assertEquals(wo.Id, tse.WorkOrderId, 'WorkOrderId should be set on TSE');
        System.assertEquals(woli.Id, tse.WorkOrderLineItemId, 'WorkOrderLineItemId should be set on TSE');
    }

    // ============================================================================
    // createTimeSheetEntry - Pausa with motivo (subject building + Type mapping)
    // ============================================================================

    @IsTest
    static void testCreateTimeSheetEntry_PausaWithMotivo() {
        ServiceResource sr = getTestSR();

        Test.startTest();
        Id tseId = TimeSheetService.createTimeSheetEntry(
            sr.Id, DateTime.now(), null,
            TimeSheetService.TSE_TYPE_NO_PRODUCTIVO,
            TimeSheetService.DETALLE_PAUSA,
            TimeSheetService.ETAPA_PAUSA,
            'Espera de repuesto', 1, null, null
        );
        Test.stopTest();

        System.assertNotEquals(null, tseId, 'Should create TSE for Pausa');

        TimeSheetEntry tse = [
            SELECT Id, Subject, Tipo_de_Etapa__c, Detalle_Tipo_Entrada__c, Motivo_de_Pausa__c
            FROM TimeSheetEntry WHERE Id = :tseId
        ];
        System.assert(tse.Subject.contains('Pausa'), 'Subject should contain Pausa');
        System.assert(tse.Subject.contains('Espera de repuesto'), 'Subject should contain motivo');
        System.assertEquals(TimeSheetService.ETAPA_PAUSA, tse.Tipo_de_Etapa__c);
        System.assertEquals('Espera de repuesto', tse.Motivo_de_Pausa__c);
    }

    // ============================================================================
    // getTimeSheetsForTerritory - With TSE aggregation (trabajo + pausa totals)
    // ============================================================================

    @IsTest
    static void testGetTimeSheetsForTerritory_WithTSEAggregation() {
        ServiceResource sr = getTestSR();

        OperatingHours oh = new OperatingHours(Name = 'Test OH Aggregation');
        insert oh;

        ServiceTerritory st = new ServiceTerritory(
            Name = 'Taller Aggregation',
            OperatingHoursId = oh.Id,
            IsActive = true
        );
        insert st;

        ServiceTerritoryMember stm = new ServiceTerritoryMember(
            ServiceResourceId = sr.Id,
            ServiceTerritoryId = st.Id,
            EffectiveStartDate = Date.today().addDays(-1),
            TerritoryType = 'P'
        );
        insert stm;

        // Create TimeSheet for today
        Id tsId = TimeSheetService.getOrCreateTimeSheetForToday(sr.Id);

        DateTime baseTime = DateTime.now().addHours(-3);

        // Create a closed Trabajo TSE (30 min)
        TimeSheetEntry tse1 = new TimeSheetEntry();
        tse1.TimeSheetId = tsId;
        tse1.StartTime = baseTime;
        tse1.EndTime = baseTime.addMinutes(30);
        tse1.Subject = 'Trabajo';
        tse1.put('Tipo_de_Etapa__c', TimeSheetService.ETAPA_TRABAJO);
        tse1.put('Detalle_Tipo_Entrada__c', TimeSheetService.DETALLE_TRABAJO);

        // Create a closed Pausa TSE (15 min)
        TimeSheetEntry tse2 = new TimeSheetEntry();
        tse2.TimeSheetId = tsId;
        tse2.StartTime = baseTime.addMinutes(30);
        tse2.EndTime = baseTime.addMinutes(45);
        tse2.Subject = 'Pausa';
        tse2.put('Tipo_de_Etapa__c', TimeSheetService.ETAPA_PAUSA);
        tse2.put('Detalle_Tipo_Entrada__c', TimeSheetService.DETALLE_PAUSA);
        tse2.put('Motivo_de_Pausa__c', 'Almuerzo');

        insert new List<TimeSheetEntry>{ tse1, tse2 };

        Test.startTest();
        List<TimeSheetService.TimeSheetSummary> summaries =
            TimeSheetService.getTimeSheetsForTerritory(st.Id, Date.today());
        Test.stopTest();

        System.assert(summaries.size() >= 1, 'Should have at least 1 summary');

        TimeSheetService.TimeSheetSummary s = summaries[0];
        System.assert(s.totalTrabajoMin >= 30, 'Trabajo should be at least 30 min');
        System.assert(s.totalPausaMin >= 15, 'Pausa should be at least 15 min');
        System.assert(s.totalEntries >= 2, 'Should have at least 2 entries');
        System.assertNotEquals(null, s.fecha, 'Fecha should not be null');
        System.assertEquals(Date.today(), s.fecha, 'Fecha should be today');
    }

    // ============================================================================
    // getTimeSheetEntries - Open entry (null EndTime) path
    // ============================================================================

    @IsTest
    static void testGetTimeSheetEntries_OpenEntry() {
        ServiceResource sr = getTestSR();

        // Create an open TSE (no EndTime)
        Id tseId = TimeSheetService.createTimeSheetEntry(
            sr.Id, DateTime.now().addMinutes(-10), null,
            TimeSheetService.TSE_TYPE_PRODUCTIVO,
            TimeSheetService.DETALLE_TRABAJO,
            TimeSheetService.ETAPA_TRABAJO,
            null, 1, null, null
        );
        Id tsId = [SELECT TimeSheetId FROM TimeSheetEntry WHERE Id = :tseId].TimeSheetId;

        Test.startTest();
        List<TimeSheetService.TimeSheetEntryDetail> entries =
            TimeSheetService.getTimeSheetEntries(tsId);
        Test.stopTest();

        System.assert(entries.size() >= 1, 'Should return at least 1 entry');
        TimeSheetService.TimeSheetEntryDetail detail = entries[0];
        System.assertEquals(false, detail.isClosed, 'Entry should be open (not closed)');
        System.assertEquals(null, detail.duracionMin, 'Duration should be null for open entry');
        System.assertEquals(null, detail.endTime, 'EndTime should be null');
    }

    // ============================================================================
    // DailyTimeSheetProcessor - Alerts path (existing TS in non-New status)
    // ============================================================================

    @IsTest
    static void testCreateDailyTimeSheets_AlertsForNonNewTS() {
        ServiceResource sr = getTestSR();

        // Create TS and set it to Submitted (En Progreso) to trigger the alert path
        Id tsId = TimeSheetService.getOrCreateTimeSheetForToday(sr.Id);
        TimeSheet ts = [SELECT Id FROM TimeSheet WHERE Id = :tsId];
        ts.Status = TimeSheetService.TS_STATUS_SUBMITTED;
        ts.put('Hora_de_ingreso__c', Time.newInstance(7, 0, 0, 0));
        update ts;

        Test.startTest();
        Map<String, Integer> results = TimeSheetService.createDailyTimeSheets();
        Test.stopTest();

        // The processor should detect the non-New TS and generate an alert
        Integer alertCount = results.get('alerts');
        System.assertNotEquals(null, alertCount, 'Should have alerts counter');
        System.assert(alertCount >= 1, 'Should have at least 1 alert for non-New TS');

        // Verify the alert data was populated
        List<Map<String, String>> alerts = TimeSheetService.getLastRunAlerts();
        System.assert(alerts.size() >= 1, 'Should have at least 1 alert entry');

        Boolean foundMechanic = false;
        for (Map<String, String> alert : alerts) {
            if (alert.get('tsId') == tsId) {
                foundMechanic = true;
                System.assertNotEquals(null, alert.get('mechanicName'), 'Alert should have mechanic name');
                System.assertNotEquals(null, alert.get('tsStatus'), 'Alert should have TS status');
            }
        }
        System.assert(foundMechanic, 'Should find an alert for the test mechanic');
    }

    // ============================================================================
    // getTypeForMotivoPausa - Additional motivo branches
    // ============================================================================

    @IsTest
    static void testGetTypeForMotivoPausa_AllBranches() {
        // MOTIVOS_PAUSA set: Almuerzo, Cafe, Reuniones, Medico de empresa
        System.assertEquals(TimeSheetService.TSE_TYPE_NO_PRODUCTIVO,
            TimeSheetService.getTypeForMotivoPausa('Reuniones'), 'Reuniones should be no productivo');
        System.assertEquals(TimeSheetService.TSE_TYPE_NO_PRODUCTIVO,
            TimeSheetService.getTypeForMotivoPausa('Médico de empresa'), 'Medico de empresa should be no productivo');

        // MOTIVOS_TIEMPO_MUERTO set: Elaboracion presupuesto, Espera repuesto,
        // Espera asignacion, Limpieza, Cambio vehiculo, Cambio tarea
        System.assertEquals(TimeSheetService.TSE_TYPE_MUERTO,
            TimeSheetService.getTypeForMotivoPausa('Espera de asignación'), 'Espera asignacion should be muerto');
        System.assertEquals(TimeSheetService.TSE_TYPE_MUERTO,
            TimeSheetService.getTypeForMotivoPausa('Limpieza'), 'Limpieza should be muerto');
        System.assertEquals(TimeSheetService.TSE_TYPE_MUERTO,
            TimeSheetService.getTypeForMotivoPausa('Cambio de vehículo'), 'Cambio vehiculo should be muerto');
        System.assertEquals(TimeSheetService.TSE_TYPE_MUERTO,
            TimeSheetService.getTypeForMotivoPausa('Cambio de tarea'), 'Cambio tarea should be muerto');

        // Motivos NOT in any set → default muerto
        System.assertEquals(TimeSheetService.TSE_TYPE_MUERTO,
            TimeSheetService.getTypeForMotivoPausa('Descanso'), 'Descanso should default to muerto');
        System.assertEquals(TimeSheetService.TSE_TYPE_MUERTO,
            TimeSheetService.getTypeForMotivoPausa('Cita médica'), 'Cita medica should default to muerto');
        System.assertEquals(TimeSheetService.TSE_TYPE_MUERTO,
            TimeSheetService.getTypeForMotivoPausa('Trámite administrativo'), 'Tramite should default to muerto');
    }

    // ============================================================================
    // updateTimeSheetHours - Edge cases
    // ============================================================================

    @IsTest
    static void testUpdateTimeSheetHours_BothNull() {
        ServiceResource sr = getTestSR();
        Id tsId = TimeSheetService.getOrCreateTimeSheetForToday(sr.Id);

        // First set both hours
        TimeSheetService.updateTimeSheetHours(tsId, '08:00', '17:00');

        Test.startTest();
        // Call with both null/empty - should update without error
        // (only the non-blank values are applied; existing values preserved by Apex
        // since we create a new SObject with only Id and conditionally set fields)
        TimeSheetService.updateTimeSheetHours(tsId, '', '');
        Test.stopTest();

        // The TS was updated with a new SObject(Id=tsId) with no hora fields set,
        // which effectively does not change existing values (update with unchanged fields)
        TimeSheet updated = [SELECT Hora_de_ingreso__c, Hora_de_salida__c FROM TimeSheet WHERE Id = :tsId];
        // When both strings are blank, updateHours creates a TS sObject with just the Id
        // and calls update. The existing field values on the record remain unchanged
        // because blank fields on the sObject are not sent in the DML.
        System.assertNotEquals(null, updated.Hora_de_ingreso__c, 'Ingreso should remain from prior update');
    }

    @IsTest
    static void testUpdateTimeSheetHours_SalidaOnly() {
        ServiceResource sr = getTestSR();
        Id tsId = TimeSheetService.getOrCreateTimeSheetForToday(sr.Id);

        // Set ingreso first to satisfy validation rule (Salida requires Ingreso)
        TimeSheetService.updateTimeSheetHours(tsId, '07:00', null);

        Test.startTest();
        TimeSheetService.updateTimeSheetHours(tsId, null, '16:45');
        Test.stopTest();

        TimeSheet updated = [SELECT Hora_de_ingreso__c, Hora_de_salida__c FROM TimeSheet WHERE Id = :tsId];
        System.assertEquals(Time.newInstance(16, 45, 0, 0), updated.Hora_de_salida__c,
            'Salida should be 16:45');
    }
}