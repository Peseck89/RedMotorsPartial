@isTest
private class ServiceAppointmentStatusSyncHandlerTest {
    private static Integer sequence = 0;

    private static Id fakeSAId() {
        sequence++;
        return (Id)('08p000000000' + String.valueOf(sequence).leftPad(3, '0'));
    }

    private static Account createAccount() {
        Account acc = new Account(Name = 'Status Sync Test Account');
        insert acc;
        return acc;
    }

    private static WorkOrder createWorkOrder(Boolean requiereLavado) {
        WorkOrder wo = new WorkOrder(
            AccountId = createAccount().Id,
            Subject = 'Status Sync WO',
            Status = 'New'
        );
        if (Schema.SObjectType.WorkOrder.fields.getMap().containsKey('Requiere_lavado__c')
                && Schema.SObjectType.WorkOrder.fields.getMap().get('Requiere_lavado__c').getDescribe().isCreateable()) {
            wo.put('Requiere_lavado__c', requiereLavado ? 'Si' : 'No');
        }
        insert wo;
        return wo;
    }

    private static WorkType createWorkType(String name) {
        WorkType wt = new WorkType(Name = name, EstimatedDuration = 30);
        insert wt;
        return wt;
    }

    private static WorkOrderLineItem createWoli(Id workOrderId, String subject, String statusValue, Id workTypeId) {
        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = workOrderId,
            Subject = subject,
            Status = statusValue,
            Duration = 60,
            DurationType = 'Minutes'
        );
        if (workTypeId != null) {
            woli.WorkTypeId = workTypeId;
        }
        if (Schema.SObjectType.WorkOrderLineItem.fields.getMap().containsKey('Orden_de_ejecucion__c')) {
            woli.put('Orden_de_ejecucion__c', 1);
        }
        insert woli;
        return woli;
    }

    private static void sync(Id parentId, String oldStatus, String newStatus) {
        Id saId = fakeSAId();
        ServiceAppointment oldSa = new ServiceAppointment(Id = saId, Status = oldStatus);
        ServiceAppointment newSa = new ServiceAppointment(Id = saId, ParentRecordId = parentId, Status = newStatus);

        ServiceAppointmentStatusSyncHandler.syncStatusToWOLI(
            new List<ServiceAppointment>{ newSa },
            new Map<Id, ServiceAppointment>{ saId => oldSa }
        );
    }

    @isTest
    static void testStatusMappingsToWoli() {
        Map<String, String> expectedBySAStatus = new Map<String, String>{
            'Scheduled' => 'Programado',
            'Dispatched' => 'Enviado',
            'In Progress' => 'En curso',
            'Pausado' => 'Pausado',
            'Completed' => 'Completado',
            'Cannot Complete' => 'No se puede completar',
            'Canceled' => 'Cancelado',
            'Retrabajo' => 'En curso',
            'scheduled' => 'Programado'
        };

        WorkOrder wo = createWorkOrder(false);
        WorkOrderLineItem woli = createWoli(wo.Id, 'WOLI status mapping', 'Nuevo', null);

        Test.startTest();
        for (String saStatus : expectedBySAStatus.keySet()) {
            sync(woli.Id, 'None', saStatus);
        }
        Test.stopTest();

        WorkOrderLineItem updated = [
            SELECT Id, Status
            FROM WorkOrderLineItem
            WHERE Id = :woli.Id
        ];

        System.assert(new Set<String>(expectedBySAStatus.values()).contains(updated.Status));
    }

    @isTest
    static void testSkipsWhenStatusDoesNotApply() {
        WorkOrder wo = createWorkOrder(false);
        WorkOrderLineItem woli = createWoli(wo.Id, 'Skip WOLI', 'Nuevo', null);

        Test.startTest();
        sync(woli.Id, 'Scheduled', 'Scheduled');
        sync(woli.Id, 'Nuevo', null);
        sync(null, 'None', 'Scheduled');
        sync(createAccount().Id, 'None', 'Scheduled');
        Test.stopTest();

        WorkOrderLineItem updated = [SELECT Status FROM WorkOrderLineItem WHERE Id = :woli.Id];
        System.assertEquals('Nuevo', updated.Status);
    }

    @isTest
    static void testParentWorkOrderPropagatesScheduledToEarlyWolis() {
        WorkOrder wo = createWorkOrder(false);
        WorkOrderLineItem nuevo = createWoli(wo.Id, 'Nuevo WOLI', 'Nuevo', null);

        Test.startTest();
        sync(wo.Id, 'None', 'Scheduled');
        Test.stopTest();

        Map<Id, WorkOrderLineItem> updated = new Map<Id, WorkOrderLineItem>([
            SELECT Id, Status
            FROM WorkOrderLineItem
            WHERE Id = :nuevo.Id
        ]);
        System.assertEquals('Programado', updated.get(nuevo.Id).Status);
    }

    @isTest
    static void testChainCreatesControlCalidadFromPrueba() {
        createWorkType('Prueba');
        createWorkType('Control de calidad');

        WorkOrder wo = createWorkOrder(false);
        WorkOrderLineItem prueba = createWoli(wo.Id, 'Prueba', 'Completado',
            [SELECT Id FROM WorkType WHERE Name = 'Prueba' LIMIT 1].Id);

        Test.startTest();
        ServiceAppointmentStatusSyncHandler.createChainWOLIForCompletedWOLIs(new Set<Id>{ prueba.Id });
        Test.stopTest();

        List<WorkOrderLineItem> created = [
            SELECT Id, Subject, Status
            FROM WorkOrderLineItem
            WHERE WorkOrderId = :wo.Id
            AND Subject = 'Control de Calidad'
        ];
        System.assertEquals(1, created.size());
        System.assertEquals('Nuevo', created[0].Status);
        System.assertEquals(false, ServiceAppointmentStatusSyncHandler.chainWOLICreatedId == null);
    }

    @isTest
    static void testChainCreatesLavadoWhenRequired() {
        Boolean canSetRequiereLavado = Schema.SObjectType.WorkOrder.fields.getMap().containsKey('Requiere_lavado__c')
            && Schema.SObjectType.WorkOrder.fields.getMap().get('Requiere_lavado__c').getDescribe().isCreateable();
        createWorkType('Control de calidad');
        createWorkType('Lavado');

        WorkOrder wo = createWorkOrder(true);
        WorkOrderLineItem cc = createWoli(wo.Id, 'Control de Calidad', 'Completado',
            [SELECT Id FROM WorkType WHERE Name = 'Control de calidad' LIMIT 1].Id);

        Test.startTest();
        ServiceAppointmentStatusSyncHandler.createChainWOLIForCompletedWOLIs(new Set<Id>{ cc.Id });
        Test.stopTest();

        List<WorkOrderLineItem> created = [
            SELECT Id, Subject
            FROM WorkOrderLineItem
            WHERE WorkOrderId = :wo.Id
            AND Subject = 'Lavado'
        ];
        System.assertEquals(canSetRequiereLavado ? 1 : 0, created.size());
    }

    @isTest
    static void testChainSkipsExistingAndNonChainItems() {
        WorkOrder wo = createWorkOrder(false);
        WorkOrderLineItem other = createWoli(wo.Id, 'Otro trabajo', 'Completado', null);

        Test.startTest();
        ServiceAppointmentStatusSyncHandler.createChainWOLIForCompletedWOLIs(new Set<Id>{ other.Id });
        Test.stopTest();

        List<WorkOrderLineItem> created = [
            SELECT Id
            FROM WorkOrderLineItem
            WHERE WorkOrderId = :wo.Id
            AND Id != :other.Id
        ];
        System.assertEquals(0, created.size());
    }
}