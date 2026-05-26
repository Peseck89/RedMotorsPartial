public with sharing class ApprovalPanelBase {
    public class StepRow {
        public Id id;
        public Id processInstanceId;
        public String stepStatus;
        public String comments;
        public Datetime createdDate;
        public Id actorId;
        public String actorName;
    }

    public class InstanceRow {
        public Id id;
        public String status;
        public Datetime createdDate;
        public Datetime completedDate;
        public Id submittedById;
        public String submittedByName;
        public Id lastActorId;
        public String lastActorName;
        public List<StepRow> steps;
    }

    public class WorkitemRow {
        public Id id;
        public Id processInstanceId;
        public Datetime createdDate;
        public Id actorId;
        public String actorName;
    }

    public class DataResp {
        public List<InstanceRow> instances;
        public List<WorkitemRow> myWorkitems;
    }

    public static Set<Id> getCurrentUserActorIds() {
        Set<Id> ids = new Set<Id>{ UserInfo.getUserId() };
        try {
            for (GroupMember gm : [
                SELECT GroupId
                FROM GroupMember
                WHERE UserOrGroupId = :UserInfo.getUserId()
            ]) {
                ids.add(gm.GroupId);
            }
        } catch (Exception e) {
            // ignore
        }
        return ids;
    }

    public static void ensureNotNullWorkitem(Id workitemId) {
        if (workitemId == null) {
            throw new AuraHandledException('Work item requerido.');
        }
    }

    public static String firstError(Approval.ProcessResult pr) {
        if (pr != null && pr.getErrors() != null && !pr.getErrors().isEmpty()) {
            return pr.getErrors()[0].getMessage();
        }
        return null;
    }

    public static Id ensureUserCanActOnNewestPending(Id workitemId) {
        ProcessInstanceWorkitem wi = [
            SELECT Id, ActorId, ProcessInstanceId,
                   ProcessInstance.Status,
                   ProcessInstance.CreatedDate,
                   ProcessInstance.TargetObjectId
            FROM ProcessInstanceWorkitem
            WHERE Id = :workitemId
            LIMIT 1
        ];

        Set<Id> allowed = getCurrentUserActorIds();
        if (!allowed.contains(wi.ActorId)) {
            throw new AuraHandledException('No tienes permiso para actuar sobre esta solicitud.');
        }

        ProcessInstance newest = [
            SELECT Id, CreatedDate, Status
            FROM ProcessInstance
            WHERE TargetObjectId = :wi.ProcessInstance.TargetObjectId
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        if (wi.ProcessInstanceId != newest.Id) {
            throw new AuraHandledException('Este work item pertenece a una instancia anterior. Actualiza la pantalla.');
        }
        if (newest.Status != 'Pending') {
            throw new AuraHandledException('La solicitud ya no está pendiente.');
        }
        return wi.ProcessInstance.TargetObjectId;
    }

    public static DataResp load(Id recordId) {
        DataResp r = new DataResp();
        r.instances = new List<InstanceRow>();
        r.myWorkitems = new List<WorkitemRow>();

        if (recordId == null) return r;

        List<ProcessInstance> pis = [
            SELECT Id, Status, CreatedDate, CompletedDate,
                   SubmittedById, SubmittedBy.Name,
                   LastActorId, LastActor.Name,
                   TargetObjectId
            FROM ProcessInstance
            WHERE TargetObjectId = :recordId
            ORDER BY CreatedDate DESC
        ];

        Map<Id, InstanceRow> rowsById = new Map<Id, InstanceRow>();
        for (ProcessInstance pi : pis) {
            InstanceRow ir = new InstanceRow();
            ir.id = pi.Id;
            ir.status = pi.Status;
            ir.createdDate = pi.CreatedDate;
            ir.completedDate = pi.CompletedDate;
            ir.submittedById = pi.SubmittedById;
            ir.submittedByName = (pi.SubmittedById != null && pi.SubmittedBy != null) ? pi.SubmittedBy.Name : null;
            ir.lastActorId = pi.LastActorId;
            ir.lastActorName = (pi.LastActorId != null && pi.LastActor != null) ? pi.LastActor.Name : null;
            ir.steps = new List<StepRow>();
            rowsById.put(pi.Id, ir);
        }

        if (!rowsById.isEmpty()) {
            for (ProcessInstanceStep s : [
                SELECT Id, ProcessInstanceId, StepStatus, Comments, CreatedDate, ActorId, Actor.Name
                FROM ProcessInstanceStep
                WHERE ProcessInstanceId IN :rowsById.keySet()
                ORDER BY CreatedDate ASC
            ]) {
                StepRow sr = new StepRow();
                sr.id = s.Id;
                sr.processInstanceId = s.ProcessInstanceId;
                sr.stepStatus = s.StepStatus;
                sr.comments = s.Comments;
                sr.createdDate = s.CreatedDate;
                sr.actorId = s.ActorId;
                sr.actorName = (s.ActorId != null && s.Actor != null) ? s.Actor.Name : null;
                rowsById.get(s.ProcessInstanceId).steps.add(sr);
            }

            Id newestPiId = (pis.isEmpty()) ? null : pis[0].Id;
            String newestStatus = (pis.isEmpty()) ? null : pis[0].Status;

            if (newestPiId != null && newestStatus == 'Pending') {
                Set<Id> actorIds = getCurrentUserActorIds();
                for (ProcessInstanceWorkitem wi : [
                    SELECT Id, ProcessInstanceId, CreatedDate, ActorId, Actor.Name
                    FROM ProcessInstanceWorkitem
                    WHERE ProcessInstanceId = :newestPiId
                      AND ActorId IN :actorIds
                    ORDER BY CreatedDate DESC
                ]) {
                    WorkitemRow wr = new WorkitemRow();
                    wr.id = wi.Id;
                    wr.processInstanceId = wi.ProcessInstanceId;
                    wr.createdDate = wi.CreatedDate;
                    wr.actorId = wi.ActorId;
                    wr.actorName = (wi.ActorId != null && wi.Actor != null) ? wi.Actor.Name : null;
                    r.myWorkitems.add(wr);
                }
            }
        }

        r.instances.addAll(rowsById.values());
        return r;
    }

    public static DataResp approve(Id workitemId, String comments, Id recordId) {
        ensureNotNullWorkitem(workitemId);
        try {
            Id targetId = ensureUserCanActOnNewestPending(workitemId);

            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setWorkitemId(workitemId);
            req.setAction('Approve');
            if (!String.isBlank(comments)) {
                req.setComments(comments);
            }

            Approval.ProcessResult pr = Approval.process(req);
            if (pr == null || !pr.isSuccess()) {
                String m = firstError(pr);
                throw new AuraHandledException('No se pudo aprobar.' + (m != null ? ' ' + m : ''));
            }

            return load((recordId != null) ? recordId : targetId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static DataResp reject(Id workitemId, String comments, Id recordId) {
        ensureNotNullWorkitem(workitemId);
        try {
            Id targetId = ensureUserCanActOnNewestPending(workitemId);

            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setWorkitemId(workitemId);
            req.setAction('Reject');
            if (!String.isBlank(comments)) {
                req.setComments(comments);
            }

            Approval.ProcessResult pr = Approval.process(req);
            if (pr == null || !pr.isSuccess()) {
                String m = firstError(pr);
                throw new AuraHandledException('No se pudo rechazar.' + (m != null ? ' ' + m : ''));
            }

            return load((recordId != null) ? recordId : targetId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
