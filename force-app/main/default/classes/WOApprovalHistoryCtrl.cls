// WOApprovalHistoryCtrl.cls
public with sharing class WOApprovalHistoryCtrl {
    @AuraEnabled(cacheable=true)
    public static Resp getData(Id recordId){
        if (recordId == null) return new Resp();

        List<ProcessInstance> pis = [
            SELECT Id, Status, CreatedDate, CompletedDate,
                   SubmittedById, LastActorId, TargetObjectId
            FROM ProcessInstance
            WHERE TargetObjectId = :recordId
            ORDER BY CreatedDate DESC
            LIMIT 200
        ];

        Set<Id> piIds = new Set<Id>();
        for (ProcessInstance pi : pis) piIds.add(pi.Id);

        List<ProcessInstanceStep> steps = piIds.isEmpty() ? new List<ProcessInstanceStep>() : [
            SELECT Id, ProcessInstanceId, StepStatus, ActorId, Comments, CreatedDate
            FROM ProcessInstanceStep
            WHERE ProcessInstanceId IN :piIds
            ORDER BY CreatedDate ASC
        ];

        List<ProcessInstanceWorkitem> wis = piIds.isEmpty() ? new List<ProcessInstanceWorkitem>() : [
            SELECT Id, ProcessInstanceId, ActorId, OriginalActorId, CreatedDate
            FROM ProcessInstanceWorkitem
            WHERE ProcessInstanceId IN :piIds
            ORDER BY CreatedDate DESC
        ];

        Resp r = new Resp();
        r.instances = pis;
        r.steps = steps;
        r.workitems = wis;
        return r;
    }

    public class Resp {
        @AuraEnabled public List<ProcessInstance> instances;
        @AuraEnabled public List<ProcessInstanceStep> steps;
        @AuraEnabled public List<ProcessInstanceWorkitem> workitems;
    }
}