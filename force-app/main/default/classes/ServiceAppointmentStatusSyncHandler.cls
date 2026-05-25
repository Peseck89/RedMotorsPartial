/**
 * Handler for ServiceAppointment Status sync to WorkOrderLineItem
 * Maps Service Appointment statuses to corresponding WOLI statuses
 *
 * Also handles automatic chain WOLI creation when a chain step completes:
 * - Prueba completes → creates Lavado (if WO requires) or CC (if not)
 * - Lavado completes → creates CC
 * - CC completes → nothing (flow closes WO)
 *
 * Service Appointment Status → Work Order Line Item Status mapping:
 * - None → Nuevo
 * - Scheduled → Programado
 * - Dispatched → Enviado
 * - In Progress → En curso
 * - Completed → Completado
 * - Cannot Complete → No se puede completar
 * - Canceled → Cancelado
 *
 * @author Red Motors Development Team
 * @date 2026
 */
public with sharing class ServiceAppointmentStatusSyncHandler {

    // Guard to prevent recursion when creating chain WOLIs
    private static Boolean isCreatingChainWOLI = false;

    // Public static variables to communicate chain creation result to callers (e.g., SaPlayerHubController)
    public static Id chainWOLICreatedId = null;
    public static String chainCreationMessage = null;

    // Fallback WorkType IDs (used when WorkType not found by name query)
    private static final String LAVADO_FALLBACK_WORKTYPE_ID = '08qNq000000KHBBIA4';
    private static final String CC_FALLBACK_WORKTYPE_ID = '08qNq000000KHCnIAO';

    // Map of Service Appointment Status (API Value) to WOLI Status (API Value)
    // SA: None, Scheduled, Dispatched, In Progress, Pausado, Completed, Cannot Complete, Canceled, Retrabajo
    // WOLI: Nuevo, Programado, Enviado, En curso, Pausado, Completado, No se puede completar, Cancelado
    private static final Map<String, String> SA_TO_WOLI_STATUS_MAP = new Map<String, String>{
        'None' => 'Nuevo',
        'Scheduled' => 'Programado',
        'Dispatched' => 'Enviado',
        'In Progress' => 'En curso',
        'Pausado' => 'Pausado',
        'Completed' => 'Completado',
        'Cannot Complete' => 'No se puede completar',
        'Canceled' => 'Cancelado',
        'Retrabajo' => 'En curso'
    };

    /**
     * Syncs Service Appointment status changes to related Work Order Line Items.
     * IMPORTANT: Creates chain WOLIs BEFORE syncing status to prevent premature WO closure.
     * @param newRecords List of updated ServiceAppointments
     * @param oldMap Map of old ServiceAppointment records by Id
     */
    public static void syncStatusToWOLI(List<ServiceAppointment> newRecords, Map<Id, ServiceAppointment> oldMap) {
        // Guard against recursion from chain SA creation
        if (isCreatingChainWOLI) return;

        // CRITICAL: Create chain WOLI BEFORE syncing status to WOLI.
        // The flow "RM_FSL_Auto_Cerrar_Work_Order_por_WOLIs_Completadas" closes the WO
        // when CC WOLI is completed. If we sync status first, the WO might close
        // before the next chain WOLI is created.
        createChainWOLIIfCompleted(newRecords, oldMap);

        // Collect WOLIs that need status update
        Map<Id, String> woliIdToNewStatus = new Map<Id, String>();
        // SA padre → WO: propagar status a WOLIs del WO
        Set<Id> woIdsForBulkSync = new Set<Id>();
        Map<Id, String> woIdToNewStatus = new Map<Id, String>();

        for (ServiceAppointment sa : newRecords) {
            ServiceAppointment oldSa = oldMap.get(sa.Id);

            // Check if status changed
            if (sa.Status != oldSa.Status) {
                if (sa.ParentRecordId != null) {
                    if (isWorkOrderLineItem(sa.ParentRecordId)) {
                        // SA hija (modelo viejo): sync 1:1 SA→WOLI
                        String mappedStatus = mapSAStatusToWOLI(sa.Status);
                        if (mappedStatus != null) {
                            woliIdToNewStatus.put(sa.ParentRecordId, mappedStatus);
                        }
                    } else if (isWorkOrder(sa.ParentRecordId)) {
                        // SA padre (modelo nuevo): propagar a WOLIs del WO
                        // Solo propagar Scheduled→Programado (NO Canceled — con múltiples SAs, cancelar una no debe afectar WOLIs)
                        if (sa.Status == 'Scheduled') {
                            woIdsForBulkSync.add(sa.ParentRecordId);
                            woIdToNewStatus.put(sa.ParentRecordId, mapSAStatusToWOLI(sa.Status));
                        }
                    }
                }
            }
        }

        // Update WOLIs from SA hija (modelo viejo)
        if (!woliIdToNewStatus.isEmpty()) {
            updateWOLIStatuses(woliIdToNewStatus);
        }

        // Update WOLIs from SA padre (modelo nuevo): propagar a todos los WOLIs del WO
        if (!woIdsForBulkSync.isEmpty()) {
            propagateStatusToWOLIs(woIdsForBulkSync, woIdToNewStatus);
        }
    }

    /**
     * Checks SAs that changed to Completed and creates the next chain WOLI if applicable.
     * Chain: Prueba → Lavado (if WO requires) or CC → CC → (end)
     */
    private static void createChainWOLIIfCompleted(List<ServiceAppointment> newRecords, Map<Id, ServiceAppointment> oldMap) {
        // Collect WOLI IDs from SAs that just changed to Completed
        Set<Id> completedWoliIds = new Set<Id>();

        for (ServiceAppointment sa : newRecords) {
            ServiceAppointment oldSa = oldMap.get(sa.Id);

            if (sa.Status == 'Completed' && oldSa.Status != 'Completed'
                && sa.ParentRecordId != null && isWorkOrderLineItem(sa.ParentRecordId)) {
                completedWoliIds.add(sa.ParentRecordId);
            }
        }

        if (completedWoliIds.isEmpty()) return;

        // Delegate to inner class without sharing to ensure we can create records
        ChainWOLICreator creator = new ChainWOLICreator();
        creator.createNextChainWOLI(completedWoliIds);
    }

    /**
     * Checks if an Id is a WorkOrderLineItem
     */
    private static Boolean isWorkOrderLineItem(Id recordId) {
        if (recordId == null) return false;
        return recordId.getSObjectType() == WorkOrderLineItem.SObjectType;
    }

    private static Boolean isWorkOrder(Id recordId) {
        if (recordId == null) return false;
        return recordId.getSObjectType() == WorkOrder.SObjectType;
    }

    /**
     * Propaga el status de la SA padre a todos los WOLIs del WO.
     * Solo para Scheduled→Programado y Canceled→Cancelado.
     */
    private static void propagateStatusToWOLIs(Set<Id> workOrderIds, Map<Id, String> woIdToNewStatus) {
        // Only propagate to WOLIs that are in early states (Nuevo, Programado, Enviado)
        // Do NOT touch WOLIs that are already En curso, Pausado, Completado, etc.
        Set<String> earlyStatuses = new Set<String>{'Nuevo', 'Programado', 'Enviado'};
        List<WorkOrderLineItem> wolisToUpdate = new List<WorkOrderLineItem>();
        for (WorkOrderLineItem woli : [
            SELECT Id, Status, WorkOrderId
            FROM WorkOrderLineItem
            WHERE WorkOrderId IN :workOrderIds
            AND Status IN :earlyStatuses
        ]) {
            String newStatus = woIdToNewStatus.get(woli.WorkOrderId);
            if (newStatus != null && newStatus != woli.Status) {
                wolisToUpdate.add(new WorkOrderLineItem(Id = woli.Id, Status = newStatus));
            }
        }
        if (!wolisToUpdate.isEmpty()) {
            update wolisToUpdate;
        }
    }

    /**
     * Maps SA status to WOLI status
     */
    private static String mapSAStatusToWOLI(String saStatus) {
        if (String.isBlank(saStatus)) return null;

        // Direct mapping
        if (SA_TO_WOLI_STATUS_MAP.containsKey(saStatus)) {
            return SA_TO_WOLI_STATUS_MAP.get(saStatus);
        }

        // Try case-insensitive match
        for (String key : SA_TO_WOLI_STATUS_MAP.keySet()) {
            if (key.equalsIgnoreCase(saStatus)) {
                return SA_TO_WOLI_STATUS_MAP.get(key);
            }
        }

        // If no mapping found, return null (don't update)
        return null;
    }

    /**
     * Updates WOLI records with new statuses
     */
    private static void updateWOLIStatuses(Map<Id, String> woliIdToNewStatus) {
        List<WorkOrderLineItem> wolisToUpdate = new List<WorkOrderLineItem>();

        for (WorkOrderLineItem woli : [
            SELECT Id, Status, LineItemNumber
            FROM WorkOrderLineItem
            WHERE Id IN :woliIdToNewStatus.keySet()
        ]) {
            String newStatus = woliIdToNewStatus.get(woli.Id);

            // Only update if status is actually different
            if (newStatus != null && newStatus != woli.Status) {
                woli.Status = newStatus;
                wolisToUpdate.add(woli);
            }
        }

        // Perform update
        if (!wolisToUpdate.isEmpty()) {
            try {
                if (Schema.sObjectType.WorkOrderLineItem.isUpdateable()) {
                    Database.SaveResult[] results = Database.update(wolisToUpdate, false);

                    for (Integer i = 0; i < results.size(); i++) {
                        Database.SaveResult sr = results[i];
                        if (!sr.isSuccess()) {
                            for (Database.Error err : sr.getErrors()) {
                            }
                        }
                    }
                }
            } catch (Exception e) {
            }
        }
    }

    // ============================================================================
    // INNER CLASS: Creates next chain WOLI + SA when a chain step completes
    // Chain: Prueba → Lavado (if required) or CC → CC → (end)
    // Uses "without sharing" to ensure record creation succeeds regardless of
    // the running user's permissions (mechanic may not have create access).
    // ============================================================================
    /**
     * Crea el siguiente WOLI en la cadena (Prueba→Lavado→CC).
     * Llamado desde SaPlayerHubController al completar un WOLI.
     * @param woliIds Set de WOLI Ids que acaban de completarse
     */
    public static void createChainWOLIForCompletedWOLIs(Set<Id> woliIds) {
        new ChainWOLICreator().createNextChainWOLI(woliIds);
    }

    private without sharing class ChainWOLICreator {

        /**
         * For each completed WOLI, determines if it's a chain step (Prueba/Lavado)
         * and creates the next WOLI in the chain (sin SA — modelo SA padre).
         */
        public void createNextChainWOLI(Set<Id> woliIds) {
            try {
                // Build dynamic query to handle optional custom fields
                String query = 'SELECT Id, Subject, WorkOrderId, WorkTypeId, WorkType.Name, WorkOrder.ServiceTerritoryId';
                Map<String, Schema.SObjectField> woliFields = Schema.SObjectType.WorkOrderLineItem.fields.getMap();
                Map<String, Schema.SObjectField> woFields = Schema.SObjectType.WorkOrder.fields.getMap();

                Boolean hasAlias = woliFields.containsKey('alias_articulo__c');
                Boolean hasRequiereLavado = woFields.containsKey('requiere_lavado__c');

                if (hasAlias) {
                    query += ', Alias_Articulo__c';
                }
                if (hasRequiereLavado) {
                    query += ', WorkOrder.Requiere_lavado__c';
                }

                query += ' FROM WorkOrderLineItem WHERE Id IN :woliIds';
                List<WorkOrderLineItem> wolis = Database.query(query);

                for (WorkOrderLineItem woli : wolis) {
                    processWoli(woli, hasAlias, hasRequiereLavado);
                }
            } catch (Exception e) {
                // Do NOT re-throw — completing a chain step must not fail
                chainCreationMessage = 'Error al crear siguiente paso automáticamente: ' + e.getMessage();
            }
        }

        private void processWoli(WorkOrderLineItem woli, Boolean hasAlias, Boolean hasRequiereLavado) {
            String workTypeName = (woli.WorkType != null && String.isNotBlank(woli.WorkType.Name))
                ? woli.WorkType.Name : '';
            String alias = hasAlias ? (String.isNotBlank((String) woli.get('Alias_Articulo__c')) ? (String) woli.get('Alias_Articulo__c') : '') : '';
            String subject = String.isNotBlank(woli.Subject) ? woli.Subject : '';

            // Cadena: Prueba → CC → Lavado (si requerido)
            if (isPrueba(workTypeName, alias, subject)) {
                handlePruebaCompleted(woli);
            } else if (isCC(workTypeName, alias, subject)) {
                handleCCCompleted(woli, hasRequiereLavado);
            }
            // Lavado completed → terminal (flow "RM_FSL_Auto_Cerrar..." cierra WO si requiere lavado)
        }

        // ---- Chain handlers ----
        // Orden: Prueba → Control de Calidad → Lavado (si requerido)

        private void handlePruebaCompleted(WorkOrderLineItem woli) {
            // Prueba → CC siempre
            if (woliExistsForType(woli.WorkOrderId, 'Control de Calidad', 'Control de calidad')) {
                return;
            }
            Id workTypeId = getWorkTypeId('Control de calidad', CC_FALLBACK_WORKTYPE_ID);
            Decimal nextOrden = getMaxOrden(woli.WorkOrderId) + 1;
            createWOLIWithSA(woli.WorkOrderId, woli.WorkOrder.ServiceTerritoryId,
                'Control de Calidad', 'CONTROL FINAL', workTypeId, nextOrden);
            chainCreationMessage = 'Control de Calidad creado automáticamente.';
        }

        private void handleCCCompleted(WorkOrderLineItem woli, Boolean hasRequiereLavado) {
            // CC → Lavado (solo si WO requiere lavado)
            Boolean requiereLavado = false;
            if (hasRequiereLavado) {
                String requiereLavadoValue = (String) woli.WorkOrder.get('Requiere_lavado__c');
                requiereLavado = String.isNotBlank(requiereLavadoValue)
                    && requiereLavadoValue.trim().equalsIgnoreCase('Si');
            }

            if (requiereLavado) {
                if (woliExistsForType(woli.WorkOrderId, 'Lavado', 'Lavado')) {
                    return;
                }
                Id workTypeId = getWorkTypeId('Lavado', LAVADO_FALLBACK_WORKTYPE_ID);
                Decimal nextOrden = getMaxOrden(woli.WorkOrderId) + 1;
                createWOLIWithSA(woli.WorkOrderId, woli.WorkOrder.ServiceTerritoryId,
                    'Lavado', 'Lavado Red Motos', workTypeId, nextOrden);
                chainCreationMessage = 'Lavado creado automáticamente.';
            }
            // Si no requiere lavado → CC es terminal, flow cierra WO
        }

        // ---- Type identification ----

        private Boolean isPrueba(String workTypeName, String alias, String subject) {
            return workTypeName.equalsIgnoreCase('Prueba')
                || alias.equalsIgnoreCase('Prueba')
                || subject.equalsIgnoreCase('Prueba');
        }

        private Boolean isLavado(String workTypeName, String alias, String subject) {
            return workTypeName.equalsIgnoreCase('Lavado')
                || alias.startsWithIgnoreCase('Lavado')
                || subject.equalsIgnoreCase('Lavado');
        }

        private Boolean isCC(String workTypeName, String alias, String subject) {
            return workTypeName.equalsIgnoreCase('Control de calidad')
                || alias.equalsIgnoreCase('CONTROL FINAL')
                || subject.equalsIgnoreCase('Control de Calidad');
        }

        // ---- Helper methods ----

        private Boolean woliExistsForType(Id workOrderId, String subjectName, String workTypeName) {
            List<WorkOrderLineItem> existing = [
                SELECT Id FROM WorkOrderLineItem
                WHERE WorkOrderId = :workOrderId
                  AND (Subject = :subjectName OR WorkType.Name = :workTypeName)
                LIMIT 1
            ];
            return !existing.isEmpty();
        }

        private Id getWorkTypeId(String name, String fallbackId) {
            List<WorkType> wts = [SELECT Id FROM WorkType WHERE Name = :name LIMIT 1];
            if (!wts.isEmpty()) {
                return wts[0].Id;
            }
            return (Id) fallbackId;
        }

        private Decimal getMaxOrden(Id workOrderId) {
            if (!Schema.SObjectType.WorkOrderLineItem.fields.getMap().containsKey('orden_de_ejecucion__c')) {
                return 0;
            }
            List<AggregateResult> results = [
                SELECT MAX(Orden_de_ejecucion__c) maxVal
                FROM WorkOrderLineItem
                WHERE WorkOrderId = :workOrderId
            ];
            if (!results.isEmpty() && results[0].get('maxVal') != null) {
                return (Decimal) results[0].get('maxVal');
            }
            return 0;
        }

        private void createWOLIWithSA(Id workOrderId, Id serviceTerritoryId,
                String woliSubject, String woliAlias, Id workTypeId, Decimal orden) {
            // Crear solo el WOLI (sin SA — modelo SA padre)
            // La SA padre del WO ya existe y se recalculará su duración
            WorkOrderLineItem newWoli = new WorkOrderLineItem();
            newWoli.WorkOrderId = workOrderId;
            newWoli.Subject = woliSubject;
            newWoli.Status = 'Nuevo';
            newWoli.WorkTypeId = workTypeId;
            if (Schema.SObjectType.WorkOrderLineItem.fields.getMap().containsKey('orden_de_ejecucion__c')) {
                newWoli.put('Orden_de_ejecucion__c', orden);
            }
            if (Schema.SObjectType.WorkOrderLineItem.fields.getMap().containsKey('trabajo__c')) {
                newWoli.put('Trabajo__c', 'Mano de Obra');
            }
            if (Schema.SObjectType.WorkOrderLineItem.fields.getMap().containsKey('alias_articulo__c')) {
                newWoli.put('Alias_Articulo__c', woliAlias);
            }
            insert newWoli;

            chainWOLICreatedId = newWoli.Id;
        }
    }
}
