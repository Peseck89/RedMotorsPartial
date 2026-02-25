// WOApprovalPanelCtrl.cls
public with sharing class WOApprovalPanelCtrl {

    // ---- DTOs para el LWC ----
    public class StepRow {
        @AuraEnabled public Id id;
        @AuraEnabled public Id processInstanceId;
        @AuraEnabled public String stepStatus;
        @AuraEnabled public String comments;
        @AuraEnabled public Datetime createdDate;
        @AuraEnabled public Id actorId;
        @AuraEnabled public String actorName;
    }
    public class InstanceRow {
        @AuraEnabled public Id id;
        @AuraEnabled public String status;
        @AuraEnabled public Datetime createdDate;
        @AuraEnabled public Datetime completedDate;
        @AuraEnabled public Id submittedById;
        @AuraEnabled public String submittedByName;
        @AuraEnabled public Id lastActorId;
        @AuraEnabled public String lastActorName;
        @AuraEnabled public List<StepRow> steps;
    }
    public class WorkitemRow {
        @AuraEnabled public Id id;
        @AuraEnabled public Id processInstanceId;
        @AuraEnabled public Datetime createdDate;
        @AuraEnabled public Id actorId;
        @AuraEnabled public String actorName;
    }
    public class DataResp {
        @AuraEnabled public List<InstanceRow> instances;
        @AuraEnabled public List<WorkitemRow> myWorkitems;
    }

    // ---- Helpers ----
    private static Set<Id> getCurrentUserActorIds() {
        Set<Id> ids = new Set<Id>{ UserInfo.getUserId() };
        try {
            for (GroupMember gm : [
                SELECT GroupId
                FROM GroupMember
                WHERE UserOrGroupId = :UserInfo.getUserId()
            ]) { ids.add(gm.GroupId); }
        } catch (Exception e) { /* ignore */ }
        return ids;
    }

    private static void ensureNotNullWorkitem(Id workitemId) {
        if (workitemId == null) {
            throw new AuraHandledException('Work item requerido.');
        }
    }

    private static String firstError(Approval.ProcessResult pr) {
        if (pr != null && pr.getErrors() != null && !pr.getErrors().isEmpty()) { return pr.getErrors()[0].getMessage();
        }
        return null;
    }

    // Verifica permisos + que sea la instancia más reciente y Pending
    private static Id ensureUserCanActOnNewestPending(Id workitemId) {
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

        if (wi.ProcessInstanceId != newest.Id) {throw new AuraHandledException('Este work item pertenece a una instancia anterior. Actualiza la pantalla.');
        }
        if (newest.Status != 'Pending') { throw new AuraHandledException('La solicitud ya no está pendiente.');
        }
        return wi.ProcessInstance.TargetObjectId;
    }

    // ---- Carga de datos ----
    // IMPORTANTE: cacheable=true porque se usa con @wire / refreshApex.
    @AuraEnabled(cacheable=true)
    public static DataResp load(Id recordId) {
        DataResp r = new DataResp();
        r.instances   = new List<InstanceRow>();
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

            // Workitems SOLO de la instancia más reciente y PENDING
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
                    WorkitemRow wr = new WorkitemRow(); wr.id = wi.Id; wr.processInstanceId = wi.ProcessInstanceId; wr.createdDate = wi.CreatedDate; wr.actorId = wi.ActorId; wr.actorName = (wi.ActorId != null && wi.Actor != null) ? wi.Actor.Name : null; r.myWorkitems.add(wr);
                }
            }
        }

        r.instances.addAll(rowsById.values());
        return r;
    }

    @AuraEnabled(cacheable=true)
public static Boolean canView(Id recordId){
    if (recordId == null) return false;

    // 1) ¿Existe el WO y quién es el aprobador?
    WorkOrder wo = [
        SELECT Aprobador_Centro_de_Costos__c
        FROM WorkOrder
        WHERE Id = :recordId
        LIMIT 1
    ];
    if (wo == null) return false;

    Id currentUserId = UserInfo.getUserId();
    Boolean isApprover = (wo.Aprobador_Centro_de_Costos__c == currentUserId);

    // 2) Solo el perfil de *System Administrator* (o su variante en español)
    Profile pf = [
        SELECT Name
        FROM Profile
        WHERE Id = :UserInfo.getProfileId()
        LIMIT 1
    ];
    String pname = (pf != null && pf.Name != null) ? pf.Name.trim().toLowerCase() : '';
    Boolean isSysAdmin =
        pname == 'system administrator' || pname == 'administrador del sistema' || pname.contains('system administrator') || pname.contains('administrador del sistema');

    // Visibilidad final: Aprobador CC o SysAdmin. NO considerar ModifyAllData ni PS.
    return isApprover || isSysAdmin;
}

@AuraEnabled(cacheable=true)
public static Boolean canViewNo(Id recordId){
    if (recordId == null) return false;

    // 1) ¿Existe el WO y quién es el aprobador?
    WorkOrder wo = [
        SELECT Aprobador_Centro_de_Costos__c
        FROM WorkOrder
        WHERE Id = :recordId
        LIMIT 1
    ];
    if (wo == null) return false;

    Id currentUserId = UserInfo.getUserId();
    Boolean isApprover = (wo.Aprobador_Centro_de_Costos__c == currentUserId);

    // 2) Solo el perfil de *System Administrator* (o su variante en español)
    Profile pf = [
        SELECT Name
        FROM Profile
        WHERE Id = :UserInfo.getProfileId()
        LIMIT 1
    ];
    String pname = (pf != null && pf.Name != null) ? pf.Name.trim().toLowerCase() : '';
    Boolean isSysAdmin =
        pname == 'system administrator' || pname == 'administrador del sistema' || pname.contains('system administrator') || pname.contains('administrador del sistema');

    // Visibilidad final: Aprobador CC o SysAdmin. NO considerar ModifyAllData ni PS.
    return !isApprover && !isSysAdmin;
}

    // ---- Acciones ----
    // Devuelven DataResp fresco (útil incluso si usas wire).
    @AuraEnabled
    public static DataResp approve(Id workitemId, String comments, Id recordId) {
        ensureNotNullWorkitem(workitemId);
        try {
            Id targetId = ensureUserCanActOnNewestPending(workitemId);

            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setWorkitemId(workitemId);
            req.setAction('Approve');
            if (!String.isBlank(comments)) req.setComments(comments);

            Approval.ProcessResult pr = Approval.process(req);
            if (pr == null || !pr.isSuccess()) { String m = firstError(pr); throw new AuraHandledException('No se pudo aprobar.' + (m != null ? ' ' + m : ''));
            }

            return load((recordId != null) ? recordId : targetId);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static DataResp reject(Id workitemId, String comments, Id recordId) {
        ensureNotNullWorkitem(workitemId);
        try {
            Id targetId = ensureUserCanActOnNewestPending(workitemId);

            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest(); req.setWorkitemId(workitemId); req.setAction('Reject');
            if (!String.isBlank(comments)) req.setComments(comments);

            Approval.ProcessResult pr = Approval.process(req);
            if (pr == null || !pr.isSuccess()) { String m = firstError(pr); throw new AuraHandledException('No se pudo rechazar.' + (m != null ? ' ' + m : ''));
            }

            return load((recordId != null) ? recordId : targetId);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}