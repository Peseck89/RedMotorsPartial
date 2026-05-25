@isTest
public class WorkStepServiceTest {

    @TestSetup
    static void setupTestData() {

        OperatingHours oh = new OperatingHours(Name = 'Test OH');
        insert oh;

        ServiceTerritory territory = new ServiceTerritory(
            Name             = 'Test Territory',
            IsActive         = true,
            OperatingHoursId = oh.Id
        );
        insert territory;

        FSL__User_Territory__c userTerritory = new FSL__User_Territory__c(
            FSL__User__c             = UserInfo.getUserId(),
            FSL__ServiceTerritory__c = territory.Id
        );
        insert userTerritory;

        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Asset asset = new Asset(
            Name              = 'ABC123',
            AccountId         = acc.Id,
            SerialNumber      = 'SN-001',
            NumeroDeChasis__c = 'VIN0001'
        );
        insert asset;

        Contact mechanic = new Contact(
            FirstName = 'Juan',
            LastName  = 'Pérez',
            AccountId = acc.Id
        );
        insert mechanic;

        Case testCase = new Case(
            AccountId             = acc.Id,
            AssetId               = asset.Id,
            Status                = 'Open',
            Service_Territory1__c = territory.Id
        );
        insert testCase;

        WorkType workType = new WorkType(
            Name              = 'Mecánica General',
            EstimatedDuration = 1,
            DurationType      = 'Hours'
        );
        insert workType;

        WorkOrder wo = new WorkOrder(
            AccountId                    = acc.Id,
            AssetId                      = asset.Id,
            ServiceTerritoryId           = territory.Id,
            Status                       = 'New',
            CaseId                       = testCase.Id,
            Etapa_de_flujo_de_trabajo__c = 'Proceso'
        );
        insert wo;

        // ── CORRECCIÓN PRINCIPAL ─────────────────────────────────────────────
        // WorkStep NO acepta WorkOrderId directamente (no es editable).
        // La jerarquía correcta es: WorkOrder → WorkPlan → WorkStep.
        // Se debe crear primero un WorkPlan ligado al WorkOrder y luego
        // usar WorkPlanId en el WorkStep.
        // ────────────────────────────────────────────────────────────────────
        WorkPlan wp = new WorkPlan(
            WorkOrderId = wo.Id,
            Name        = 'Test Work Plan'
        );
        insert wp;

        WorkStep ws = new WorkStep(
            WorkPlanId           = wp.Id,
            Name                 = 'Step 1',
            Status               = 'Nueva',
            Mec_nico_asignado__c = mechanic.Id,
            Caso__c              = testCase.Id,
            StartTime            = Datetime.now(),
            EndTime              = Datetime.now().addHours(1)
        );
        insert ws;
    }

    // ─── isSandbox ───────────────────────────────────────────────────────

    @isTest
    static void testIsSandbox() {
        Test.startTest();
        Boolean result = WorkStepService.isSandbox();
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    // ─── getAssignedTerritories ──────────────────────────────────────────

    @isTest
    static void testGetAssignedTerritories_withData() {
        Test.startTest();
        Set<Id> territories = WorkStepService.getAssignedTerritories();
        Test.stopTest();
        System.assert(territories != null);
        System.assert(!territories.isEmpty());
    }

    @isTest
    static void testGetAssignedTerritories_noData() {
        delete [SELECT Id FROM FSL__User_Territory__c
                WHERE FSL__User__c = :UserInfo.getUserId()];
        Test.startTest();
        Set<Id> territories = WorkStepService.getAssignedTerritories();
        Test.stopTest();
        System.assert(territories.isEmpty());
    }

    // ─── getWorkSteps ────────────────────────────────────────────────────

    @isTest
    static void testGetWorkSteps_basicQuery() {
        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory LIMIT 1];
        Test.startTest();
        Map<String,Object> result = WorkStepService.getWorkSteps(
            territory.Id, 'all', 'all',
            null, null, null, null, null, null,
            UserInfo.getUserId(),
            false
        );
        Test.stopTest();
        System.assertEquals(true, result.get('success'));
        System.assertNotEquals(null, result.get('workStepWrapperList'));
    }

    @isTest
    static void testGetWorkSteps_tallerId_all() {
        Test.startTest();
        Map<String,Object> result = WorkStepService.getWorkSteps(
            'all', 'all', 'all',
            null, null, null, null, null, null,
            UserInfo.getUserId(),
            false
        );
        Test.stopTest();
        System.assertEquals(true, result.get('success'));
    }

    @isTest
    static void testGetWorkSteps_allFilters() {
        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory LIMIT 1];
        Case c                     = [SELECT CaseNumber FROM Case LIMIT 1];
        WorkOrder wo               = [SELECT WorkOrderNumber FROM WorkOrder LIMIT 1];

        Test.startTest();
        Map<String,Object> result = WorkStepService.getWorkSteps(
            territory.Id,
            'Tipo A',
            'Nueva',
            c.CaseNumber,
            wo.WorkOrderNumber,
            'ABC123',
            'VIN0001',
            Date.today().addDays(-1),
            Date.today().addDays(1),
            UserInfo.getUserId(),
            true
        );
        Test.stopTest();
        System.assertEquals(true, result.get('success'));
    }

    @isTest
    static void testGetWorkSteps_nullUserId() {
        Test.startTest();
        Map<String,Object> result = WorkStepService.getWorkSteps(
            null, 'all', 'all',
            null, null, null, null, null, null,
            null, null
        );
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @isTest
    static void testGetWorkSteps_noTerritoryConfigured() {
        delete [SELECT Id FROM FSL__User_Territory__c
                WHERE FSL__User__c = :UserInfo.getUserId()];
        Test.startTest();
        Map<String,Object> result = WorkStepService.getWorkSteps(
            null, 'all', 'all',
            null, null, null, null, null, null,
            UserInfo.getUserId(),
            false
        );
        Test.stopTest();
        // En sandbox/test el guard se omite; sólo verificamos que no explota
        System.assertNotEquals(null, result);
    }

    @isTest
    static void testGetWorkSteps_withDates() {
        Test.startTest();
        Map<String,Object> result = WorkStepService.getWorkSteps(
            null, 'all', 'all',
            null, null, null, null,
            Date.today().addDays(-30),
            Date.today(),
            UserInfo.getUserId(),
            false
        );
        Test.stopTest();
        System.assertEquals(true, result.get('success'));
    }

    @isTest
    static void testGetWorkSteps_nestedTrue() {
        Test.startTest();
        Map<String,Object> result = WorkStepService.getWorkSteps(
            null, 'all', 'all',
            null, null, null, null, null, null,
            UserInfo.getUserId(),
            true
        );
        Test.stopTest();
        System.assertEquals(true, result.get('success'));
    }

    // ─── getTasksGroupedByCase ───────────────────────────────────────────

    @isTest
    static void testGetTasksGroupedByCase_basicQuery() {
        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory LIMIT 1];
        Contact mechanic           = [SELECT Id FROM Contact LIMIT 1];

        Test.startTest();
        Map<String,Object> result = WorkStepService.getTasksGroupedByCase(
            new List<String>{ territory.Id },
            mechanic.Id,
            new List<String>{ 'Nueva', 'En curso' },
            null, null, null, null, null, null,
            UserInfo.getUserId(),
            1
        );
        Test.stopTest();
        System.assertEquals(true, result.get('success'));
        System.assertNotEquals(null, result.get('records'));
        System.assertEquals(1, result.get('pageNumber'));
        System.assertEquals(WorkStepService.PAGE_SIZE, result.get('pageSize'));
    }

    @isTest
    static void testGetTasksGroupedByCase_pageNumberNull() {
        Test.startTest();
        Map<String,Object> result = WorkStepService.getTasksGroupedByCase(
            null, null, null,
            null, null, null, null, null, null,
            UserInfo.getUserId(),
            null
        );
        Test.stopTest();
        System.assertEquals(1, result.get('pageNumber'));
    }

    @isTest
    static void testGetTasksGroupedByCase_allFilters() {
        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory LIMIT 1];
        Case c                     = [SELECT CaseNumber FROM Case LIMIT 1];
        WorkOrder wo               = [SELECT WorkOrderNumber FROM WorkOrder LIMIT 1];

        Test.startTest();
        Map<String,Object> result = WorkStepService.getTasksGroupedByCase(
            new List<String>{ territory.Id },
            null, null,
            c.CaseNumber,
            wo.WorkOrderNumber,
            'ABC123',
            'VIN0001',
            Date.today().addDays(-1),
            Date.today().addDays(1),
            UserInfo.getUserId(),
            1
        );
        Test.stopTest();
        System.assertEquals(true, result.get('success'));
    }

    @isTest
    static void testGetTasksGroupedByCase_noTerritories() {
        delete [SELECT Id FROM FSL__User_Territory__c
                WHERE FSL__User__c = :UserInfo.getUserId()];
        Test.startTest();
        Map<String,Object> result = WorkStepService.getTasksGroupedByCase(
            null, null, null,
            null, null, null, null, null, null,
            UserInfo.getUserId(),
            1
        );
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @isTest
    static void testGetTasksGroupedByCase_page2() {
        Test.startTest();
        Map<String,Object> result = WorkStepService.getTasksGroupedByCase(
            null, null, null,
            null, null, null, null,
            Date.today().addDays(-7),
            Date.today(),
            UserInfo.getUserId(),
            2
        );
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @isTest
    static void testGetTasksGroupedByCase_withPlateAndVin() {
        Test.startTest();
        Map<String,Object> result = WorkStepService.getTasksGroupedByCase(
            null, null, null,
            null, null,
            'ABC123',
            'VIN0001',
            null, null,
            UserInfo.getUserId(),
            1
        );
        Test.stopTest();
        System.assertEquals(true, result.get('success'));
    }

    // ─── getWorkStepsForReports ──────────────────────────────────────────

    @isTest
    static void testGetWorkStepsForReports_missingBothDates() {
        Test.startTest();
        Map<String,Object> result = WorkStepService.getWorkStepsForReports(
            null, null, null,
            null, null,
            false
        );
        Test.stopTest();
        System.assert(result.isEmpty());
    }

    @isTest
    static void testGetWorkStepsForReports_missingEndDate() {
        Test.startTest();
        Map<String,Object> result = WorkStepService.getWorkStepsForReports(
            null, null, null,
            Date.today().addDays(-7),
            null,
            false
        );
        Test.stopTest();
        System.assert(result.isEmpty());
    }

    @isTest
    static void testGetWorkStepsForReports_withDates() {
        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory LIMIT 1];
        Contact mechanic           = [SELECT Id FROM Contact LIMIT 1];
        Case c                     = [SELECT CaseNumber FROM Case LIMIT 1];

        Test.startTest();
        Map<String,Object> result = WorkStepService.getWorkStepsForReports(
            new List<String>{ territory.Id },
            mechanic.Id,
            c.CaseNumber,
            Date.today().addDays(-30),
            Date.today().addDays(1),
            true
        );
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.get('records'));
        System.assertNotEquals(null, result.get('tiemposimproductivos'));
    }

    @isTest
    static void testGetWorkStepsForReports_noMechanicNoCaseNumber() {
        ServiceTerritory territory = [SELECT Id FROM ServiceTerritory LIMIT 1];

        Test.startTest();
        Map<String,Object> result = WorkStepService.getWorkStepsForReports(
            new List<String>{ territory.Id },
            null, null,
            Date.today().addDays(-7),
            Date.today(),
            false
        );
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @isTest
    static void testGetWorkStepsForReports_nullShowParentTasks() {
        Test.startTest();
        Map<String,Object> result = WorkStepService.getWorkStepsForReports(
            null, null, null,
            Date.today().addDays(-7),
            Date.today(),
            null
        );
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    @isTest
    static void testGetWorkStepsForReports_nullTerritories() {
        Test.startTest();
        Map<String,Object> result = WorkStepService.getWorkStepsForReports(
            null, null, null,
            Date.today().addDays(-1),
            Date.today().addDays(1),
            false
        );
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    // ─── getTiemposImproductivos ─────────────────────────────────────────

    @isTest
    static void testGetTiemposImproductivos_emptySet() {
        Test.startTest();
        List<WorkStepService.TIWrrp> result =
            WorkStepService.getTiemposImproductivos(new Set<Id>());
        Test.stopTest();
        System.assertEquals(0, result.size());
    }

    @isTest
    static void testGetTiemposImproductivos_nullSet() {
        Test.startTest();
        List<WorkStepService.TIWrrp> result =
            WorkStepService.getTiemposImproductivos(null);
        Test.stopTest();
        System.assertEquals(0, result.size());
    }

    

   
    // ─── getMinutosPausa ─────────────────────────────────────────────────

    @isTest
    static void testGetMinutosPausa_nullRecord() {
        Test.startTest();
        Decimal result = WorkStepService.getMinutosPausa(null);
        Test.stopTest();
        System.assertEquals(0, result);
    }

    @isTest
    static void testGetMinutosPausa_allFieldsNull() {
        Horas_improductivas_por_mec_nico__c him =
            new Horas_improductivas_por_mec_nico__c();
        Test.startTest();
        Decimal result = WorkStepService.getMinutosPausa(him);
        Test.stopTest();
        System.assertEquals(0, result);
    }

    @isTest
    static void testGetMinutosPausa_soloInicioNull() {
        Horas_improductivas_por_mec_nico__c him =
            new Horas_improductivas_por_mec_nico__c(
                Fin__c      = Date.today(),
                Hora_fin__c = Time.newInstance(9, 0, 0, 0)
            );
        Test.startTest();
        Decimal result = WorkStepService.getMinutosPausa(him);
        Test.stopTest();
        System.assertEquals(0, result);
    }

  
    // ─── TIWrrp inner class ──────────────────────────────────────────────

    @isTest
    static void testTIWrrpConstructor() {
        Test.startTest();
        WorkStepService.TIWrrp ti =
            new WorkStepService.TIWrrp('case001', 'mec001');
        Test.stopTest();
        System.assertEquals('case001', ti.caseId);
        System.assertEquals('mec001', ti.mecanicoId);
        System.assertEquals(0, ti.total);
    }

    @isTest
    static void testTIWrrpTotalAccumulation() {
        Test.startTest();
        WorkStepService.TIWrrp ti =
            new WorkStepService.TIWrrp('case001', 'mec001');
        ti.total += 60;
        ti.total += 30;
        Test.stopTest();
        System.assertEquals(90, ti.total);
    }

    // ─── ContactWrapperReport inner class ────────────────────────────────

    @isTest
    static void testContactWrapperReport_setCases() {
        Test.startTest();
        WorkStepService.ContactWrapperReport wr =
            new WorkStepService.ContactWrapperReport();
        wr.setCases(new Set<String>{ 'case001', 'case002', 'case003' });
        Test.stopTest();
        System.assertEquals(3, wr.cases.size());
    }

    @isTest
    static void testContactWrapperReport_setCasesEmpty() {
        Test.startTest();
        WorkStepService.ContactWrapperReport wr =
            new WorkStepService.ContactWrapperReport();
        wr.setCases(new Set<String>());
        Test.stopTest();
        System.assertEquals(0, wr.cases.size());
    }

    @isTest
    static void testContactWrapperReport_fields() {
        Test.startTest();
        WorkStepService.ContactWrapperReport wr =
            new WorkStepService.ContactWrapperReport();
        wr.mechanicId    = 'mec001';
        wr.mechanicName  = 'Juan Pérez';
        wr.territoryId   = 'ter001';
        wr.territoryName = 'Territorio Norte';
        wr.numWS         = 5;
        Test.stopTest();
        System.assertEquals('mec001',           wr.mechanicId);
        System.assertEquals('Juan Pérez',        wr.mechanicName);
        System.assertEquals('Territorio Norte',  wr.territoryName);
        System.assertEquals(5,                   wr.numWS);
    }
}