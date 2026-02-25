public class RecallApprovalInvocable {

    public class Input {
        @InvocableVariable(required=true)
        public Id recordId;
    }

    @InvocableMethod
    public static void recall(List<Input> inputs) {
        Set<Id> recordIds = new Set<Id>();
        for (Input i : inputs) {
            if (i.recordId != null) {
                recordIds.add(i.recordId);
            }
        }
        if (recordIds.isEmpty()) return;

        Map<Id, ProcessInstanceWorkitem> workitemsByTarget = new Map<Id, ProcessInstanceWorkitem>();

        for (ProcessInstanceWorkitem wi : [
            SELECT Id, ProcessInstance.TargetObjectId
            FROM ProcessInstanceWorkitem
            WHERE ProcessInstance.TargetObjectId IN :recordIds
        ]) {
            Id targetId = wi.ProcessInstance.TargetObjectId; if (!workitemsByTarget.containsKey(targetId)) { workitemsByTarget.put(targetId, wi);
            }
        }

        for (Id recId : recordIds) {
            ProcessInstanceWorkitem wi = workitemsByTarget.get(recId);
            if (wi == null) continue;

            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest(); req.setAction('Removed');req.setComments('Removido automáticamente desde Flow'); req.setWorkitemId(wi.Id); Approval.process(req);
        }
    }
}