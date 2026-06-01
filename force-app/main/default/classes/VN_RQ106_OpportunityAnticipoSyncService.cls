public class VN_RQ106_OpportunityAnticipoSyncService {
    private static final Set<String> RECEIVED_STATUSES = new Set<String>{
        'Aplicado',
        'Vehículo reservado'
    };

    private static final Set<String> PENDING_STATUSES = new Set<String>{
        'Borrador',
        'En validación de Tesorería',
        'Corrección requerida por Tesorería',
        'Confirmada por Tesorería',
        'Anticipo creado',
        'Error de integración'
    };

    private static final Set<String> CANCELLED_STATUSES = new Set<String>{
        'Rechazada por Tesorería',
        'Reserva rechazada',
        'Cancelado'
    };

    public static void syncAfterInsert(List<Anticipo__c> newRecords) {
        syncOpportunityStates(collectOpportunityIds(newRecords));
    }

    public static void syncAfterUpdate(List<Anticipo__c> newRecords, Map<Id, Anticipo__c> oldRecordMap) {
        Set<Id> opportunityIds = new Set<Id>();
        if (newRecords == null || oldRecordMap == null) {
            return;
        }

        for (Anticipo__c newRecord : newRecords) {
            Anticipo__c oldRecord = oldRecordMap.get(newRecord.Id);
            if (oldRecord == null) {
                continue;
            }

            if (newRecord.Estatus__c != oldRecord.Estatus__c ||
                newRecord.Oportunidad__c != oldRecord.Oportunidad__c) {
                addOpportunityId(opportunityIds, oldRecord.Oportunidad__c);
                addOpportunityId(opportunityIds, newRecord.Oportunidad__c);
            }
        }

        syncOpportunityStates(opportunityIds);
    }

    public static void syncAfterDelete(List<Anticipo__c> oldRecords) {
        syncOpportunityStates(collectOpportunityIds(oldRecords));
    }

    public static void syncAfterUndelete(List<Anticipo__c> newRecords) {
        syncOpportunityStates(collectOpportunityIds(newRecords));
    }

    private static Set<Id> collectOpportunityIds(List<Anticipo__c> records) {
        Set<Id> opportunityIds = new Set<Id>();
        if (records == null) {
            return opportunityIds;
        }

        for (Anticipo__c record : records) {
            addOpportunityId(opportunityIds, record.Oportunidad__c);
        }
        return opportunityIds;
    }

    private static void addOpportunityId(Set<Id> opportunityIds, Id opportunityId) {
        if (opportunityId != null) {
            opportunityIds.add(opportunityId);
        }
    }

    private static void syncOpportunityStates(Set<Id> opportunityIds) {
        if (opportunityIds == null || opportunityIds.isEmpty()) {
            return;
        }

        Map<Id, StateAccumulator> statesByOpportunityId = new Map<Id, StateAccumulator>();
        for (Id opportunityId : opportunityIds) {
            statesByOpportunityId.put(opportunityId, new StateAccumulator());
        }

        for (Anticipo__c anticipo : [
            SELECT Oportunidad__c, Estatus__c
            FROM Anticipo__c
            WHERE Oportunidad__c IN :opportunityIds
        ]) {
            StateAccumulator accumulator = statesByOpportunityId.get(anticipo.Oportunidad__c);
            if (accumulator != null) {
                accumulator.addStatus(anticipo.Estatus__c);
            }
        }

        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        for (Opportunity opportunity : [
            SELECT Id, Estado_Anticipo__c
            FROM Opportunity
            WHERE Id IN :opportunityIds
        ]) {
            String newState = statesByOpportunityId.get(opportunity.Id).getOpportunityState();
            if (opportunity.Estado_Anticipo__c != newState) {
                opportunitiesToUpdate.add(new Opportunity(
                    Id = opportunity.Id,
                    Estado_Anticipo__c = newState
                ));
            }
        }

        if (!opportunitiesToUpdate.isEmpty()) {
            update opportunitiesToUpdate;
        }
    }

    private class StateAccumulator {
        private Boolean hasReceived = false;
        private Boolean hasPending = false;
        private Boolean hasCancelled = false;
        private Boolean hasUnknown = false;

        private void addStatus(String status) {
            if (RECEIVED_STATUSES.contains(status)) {
                hasReceived = true;
            } else if (PENDING_STATUSES.contains(status)) {
                hasPending = true;
            } else if (CANCELLED_STATUSES.contains(status)) {
                hasCancelled = true;
            } else if (!String.isBlank(status)) {
                hasUnknown = true;
            }
        }

        private String getOpportunityState() {
            if (hasReceived) {
                return 'Recibido';
            }
            if (hasPending) {
                return 'Pendiente';
            }
            if (hasCancelled && !hasUnknown) {
                return 'Cancelado';
            }
            return null;
        }
    }
}
