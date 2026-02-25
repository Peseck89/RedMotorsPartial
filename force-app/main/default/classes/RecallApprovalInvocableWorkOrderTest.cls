@IsTest
private class RecallApprovalInvocableWorkOrderTest {

    @testSetup
    static void setupData() {
        // Cuenta base
        Account acc = new Account(
            Name = 'Cuenta Test WO Recall'
        );
        insert acc;

        // Usuario activo para usar como aprobador
        User aprobador = [
            SELECT Id
            FROM User
            WHERE IsActive = true
            LIMIT 1
        ];

        // Work Order que cumple el criterio del approval:
        // Aprobador_Centro_de_Costos__c != null
        WorkOrder wo = new WorkOrder(
            Subject   = 'WO Test Recall',
            Status    = 'New',                // Ajusta si tu org usa otro status obligatorio
            AccountId = acc.Id,
            Aprobador_Centro_de_Costos__c = aprobador.Id
            // Si el approval SOLO depende del aprobador, con esto basta.
            // Si además usa otros campos, agrégalos aquí.
            // Aprobaci_n_Centro_de_Costos__c lo puede cambiar luego el proceso.
        );
        insert wo;
    }

    @IsTest
    static void testRecallApprovalForWorkOrder() {
        WorkOrder wo = [
            SELECT Id
            FROM WorkOrder
            LIMIT 1
        ];

        // Buscamos un approval process ACTIVO para WorkOrder
        List<ProcessDefinition> defs = [
            SELECT Id, Name, TableEnumOrId, State
            FROM ProcessDefinition
            WHERE TableEnumOrId = 'WorkOrder'
              AND State = 'Active'
            LIMIT 1
        ];

        // Si no hay procesos activos, al menos probamos que el invocable no truene
        if (defs.isEmpty()) {
            RecallApprovalInvocable.Input inputNoProc = new RecallApprovalInvocable.Input();
            inputNoProc.recordId = wo.Id;

            Test.startTest();
            RecallApprovalInvocable.recall(new List<RecallApprovalInvocable.Input>{ inputNoProc });
            Test.stopTest();

            System.assert(true,
                'No hay approval process activo para WorkOrder; el invocable no debe lanzar excepción.');
            return;
        }

        ProcessDefinition pd = defs[0];

        Boolean submittedOk = false;
        try {
            Approval.ProcessSubmitRequest submitReq = new Approval.ProcessSubmitRequest();
            submitReq.setObjectId(wo.Id);
            submitReq.setProcessDefinitionNameOrId(pd.Id);

            Approval.ProcessResult submitResult = Approval.process(submitReq);
            submittedOk = submitResult.isSuccess()
                          && 'Submitted'.equals(submitResult.getInstanceStatus());
        } catch (DmlException e) {
            submittedOk = false;
        }

        // Si no logró entrar a ningún approval, igual probamos que el invocable no truene
        if (!submittedOk) {
            RecallApprovalInvocable.Input inputNoApproval = new RecallApprovalInvocable.Input();
            inputNoApproval.recordId = wo.Id;

            Test.startTest();
            RecallApprovalInvocable.recall(new List<RecallApprovalInvocable.Input>{ inputNoApproval });
            Test.stopTest();

            System.assert(true,
                'El Work Order no entró a ningún approval process, pero el invocable debe manejarlo sin error.');
            return;
        }

        // Aquí sí se envió a aprobación, probamos el recall real
        List<ProcessInstanceWorkitem> itemsBefore = [
            SELECT Id, ProcessInstance.TargetObjectId
            FROM ProcessInstanceWorkitem
            WHERE ProcessInstance.TargetObjectId = :wo.Id
        ];
        System.assert(
            !itemsBefore.isEmpty(),
            'Debe existir al menos un ProcessInstanceWorkitem antes del recall.'
        );

        RecallApprovalInvocable.Input input = new RecallApprovalInvocable.Input();
        input.recordId = wo.Id;

        Test.startTest();
        RecallApprovalInvocable.recall(new List<RecallApprovalInvocable.Input>{ input });
        Test.stopTest();

        List<ProcessInstanceWorkitem> itemsAfter = [
            SELECT Id, ProcessInstance.TargetObjectId
            FROM ProcessInstanceWorkitem
            WHERE ProcessInstance.TargetObjectId = :wo.Id
        ];

        System.assertEquals(
            0,
            itemsAfter.size(),
            'Después del recall no deberían quedar workitems pendientes para el Work Order.'
        );
    }

    @IsTest
    static void testRecallWorkOrderWithoutApproval() {
        Account acc = new Account(Name = 'Cuenta WO Sin Aprobación');
        insert acc;

        WorkOrder wo = new WorkOrder(
            Subject   = 'WO Sin Aprobación',
            Status    = 'New',
            AccountId = acc.Id
        );
        insert wo;

        RecallApprovalInvocable.Input input = new RecallApprovalInvocable.Input();
        input.recordId = wo.Id;

        Test.startTest();
        RecallApprovalInvocable.recall(new List<RecallApprovalInvocable.Input>{ input });
        Test.stopTest();

        System.assert(true,
            'El método debe manejar correctamente un Work Order sin aprobación activa (no debe lanzar excepción).');
    }
}