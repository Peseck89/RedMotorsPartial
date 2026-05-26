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

    private static DataResp toDataResp(ApprovalPanelBase.DataResp source) {
        return (DataResp) JSON.deserialize(JSON.serialize(source), DataResp.class);
    }

    private static Boolean userCanViewApproval(Id recordId) {
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

        return isApprover || isSysAdmin;
    }

    // ---- Carga de datos ----
    // IMPORTANTE: cacheable=true porque se usa con @wire / refreshApex.
    @AuraEnabled(cacheable=true)
    public static DataResp load(Id recordId) {
        return toDataResp(ApprovalPanelBase.load(recordId));
    }

    @AuraEnabled(cacheable=true)
public static Boolean canView(Id recordId){
    if (recordId == null) return false;
    // Visibilidad final: Aprobador CC o SysAdmin. NO considerar ModifyAllData ni PS.
    return userCanViewApproval(recordId);
}

@AuraEnabled(cacheable=true)
public static Boolean canViewNo(Id recordId){
    if (recordId == null) return false;
    // Visibilidad final: Aprobador CC o SysAdmin. NO considerar ModifyAllData ni PS.
    return !userCanViewApproval(recordId);
}

    // ---- Acciones ----
    // Devuelven DataResp fresco (útil incluso si usas wire).
    @AuraEnabled
    public static DataResp approve(Id workitemId, String comments, Id recordId) {
        return toDataResp(ApprovalPanelBase.approve(workitemId, comments, recordId));
    }

    @AuraEnabled
    public static DataResp reject(Id workitemId, String comments, Id recordId) {
        return toDataResp(ApprovalPanelBase.reject(workitemId, comments, recordId));
    }
}
