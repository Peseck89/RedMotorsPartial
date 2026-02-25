public with sharing class popUpBloqueClass {
    // DTO: un registro por Case (aunque tenga varias Tasks)
    public class PendingCaseDTO {
        @AuraEnabled public Id caseId;
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String caseSubject;

        @AuraEnabled public Id workOrderId;
        @AuraEnabled public String workOrderNumber;
        @AuraEnabled public String workOrderSubject;

        @AuraEnabled public List<Id> taskIds;
        public PendingCaseDTO() { taskIds = new List<Id>(); }
    }

    public class PendingTaskDTO {
    @AuraEnabled public Id taskId;
    @AuraEnabled public String subjectFormatted;

    @AuraEnabled public Id caseId;
    @AuraEnabled public String caseNumber;

    @AuraEnabled public String placa;

    @AuraEnabled public Id workOrderId;
    @AuraEnabled public String workOrderNumber;
}


    @AuraEnabled(cacheable=true)
    public static Boolean isCurrentUserOwnerOf(Id recordId) {
        if (recordId == null) return false;
        Id currentUserId = UserInfo.getUserId();
        Schema.SObjectType typeOf = recordId.getSObjectType();

        if (typeOf == Case.SObjectType) {
            Case c = [SELECT OwnerId FROM Case WHERE Id = :recordId LIMIT 1];
            return c.OwnerId == currentUserId;
        } else if (typeOf == WorkOrder.SObjectType) {
            WorkOrder wo = [SELECT OwnerId FROM WorkOrder WHERE Id = :recordId LIMIT 1];
            return wo.OwnerId == currentUserId;
        }
        return false;
    }

    @AuraEnabled(cacheable=true)
    public static List<PendingCaseDTO> getPendingCasesForCurrentOwner() {
        Id currentUserId = UserInfo.getUserId();

        // 1) Traer Tasks que cumplan las condiciones y cuyo What sea un Case del owner actual
        List<Task> tks = [
            SELECT Id, WhatId, CreatedDate,
                   RecordType.DeveloperName,
                   Status,
                   Tipo_de_tarea__c,
                   Confirmacion_de_lectura__c
            FROM Task
            WHERE Status = 'Open'
              AND Confirmacion_de_lectura__c = false
              AND Tipo_de_tarea__c = '-Recordatorio al asesor'
              AND RecordType.DeveloperName = 'Seguimiento'
              AND WhatId IN (SELECT Id FROM Case WHERE ID= '500PH00000hRF2gYAG')// OwnerId = :currentUserId)
        ];
        if (tks.isEmpty()) return new List<PendingCaseDTO>();

        // 2) Agrupar por Case (WhatId) — versión Apex (sin computeIfAbsent)
        Map<Id, List<Task>> caseIdToTasks = new Map<Id, List<Task>>();
        for (Task t : tks) {
            if (t.WhatId == null) continue;
            List<Task> bucket = caseIdToTasks.get(t.WhatId);
            if (bucket == null) {
                bucket = new List<Task>();
                caseIdToTasks.put(t.WhatId, bucket);
            }
            bucket.add(t);
        }

        Set<Id> caseIds = new Set<Id>(caseIdToTasks.keySet());

        // 3) Info del Case
        Map<Id, Case> casesById = new Map<Id, Case>([
            SELECT Id, CaseNumber, Subject
            FROM Case
            WHERE Id IN :caseIds
        ]);

        // 4) Un WorkOrder representativo por Case (el más reciente)
        Map<Id, WorkOrder> caseIdToLatestWO = new Map<Id, WorkOrder>();
        for (WorkOrder wo : [
            SELECT Id, WorkOrderNumber, Subject, CaseId, CreatedDate
            FROM WorkOrder
            WHERE CaseId IN :caseIds
            ORDER BY CreatedDate DESC
        ]) {
            if (!caseIdToLatestWO.containsKey(wo.CaseId)) {
                caseIdToLatestWO.put(wo.CaseId, wo);
            }
        }

        // 5) Construir DTOs (uno por Case; sin duplicados)
        List<PendingCaseDTO> out = new List<PendingCaseDTO>();
        for (Id cId : caseIds) {
            Case c = casesById.get(cId);
            if (c == null) continue;

            PendingCaseDTO dto = new PendingCaseDTO();
            dto.caseId = c.Id;
            dto.caseNumber = c.CaseNumber;
            dto.caseSubject = c.Subject;

            WorkOrder wo = caseIdToLatestWO.get(c.Id);
            if (wo != null) {
                dto.workOrderId = wo.Id;
                dto.workOrderNumber = wo.WorkOrderNumber;
                dto.workOrderSubject = wo.Subject;
            }

            for (Task t : caseIdToTasks.get(c.Id)) {
                dto.taskIds.add(t.Id);
            }
            out.add(dto);
        }
        return out;
    }

    @AuraEnabled(cacheable=true)
    public static List<PendingTaskDTO> getPendingTasksForCurrentOwner() {
        
        List<Task> tks = [
            SELECT 
                Id, WhatId, Subject,
                Tipo_de_tarea__c,
                Confirmacion_de_lectura__c,
                Status,
                RecordType.DeveloperName,
                TYPEOF What
                    WHEN Case THEN
                        CaseNumber,
                        Subject,
                        Asset.numeroDePlaca__c,
                        Work_Order__c,
                        Work_Order__r.WorkOrderNumber
                END
            FROM Task
            WHERE Status = 'Open'
            AND Confirmacion_de_lectura__c = false
            AND Tipo_de_tarea__c = '-Recordatorio al asesor'
            AND RecordType.DeveloperName = 'Seguimiento'
            AND WhatId IN (SELECT Id FROM Case WHERE Id = '500PH00000hRF2gYAG') // hardcode temporal
        ];

        List<PendingTaskDTO> out = new List<PendingTaskDTO>();

        for (Task t : tks) {

            // Asegurar que What es Case
            if (!(t.What instanceof Case)) continue;

            Case c = (Case)t.What;

            PendingTaskDTO dto = new PendingTaskDTO();
            dto.taskId = t.Id;

            dto.caseId = c.Id;
            dto.caseNumber = c.CaseNumber;

            dto.placa = c.Asset != null ? c.Asset.numeroDePlaca__c : null;

            dto.workOrderId = c.Work_Order__c;
            dto.workOrderNumber = c.Work_Order__r != null ? c.Work_Order__r.WorkOrderNumber : '';

            // Texto formateado
            dto.subjectFormatted =
                'Vehículo ' + dto.placa + ' – OT #' + dto.workOrderNumber + 
                ' ' + getSuffixFromOriginalSubject(t.Subject);

            out.add(dto);
        }

        return out;
    }


    // Determinar si es +2, +5, u otro
    private static String getSuffixFromOriginalSubject(String subject) {
        if (subject == null) return '';

        if (subject.contains('2 días')) return 'lleva +2 días en taller.';
        if (subject.contains('Seguimiento')) return 'lleva +5 días sin actualización.';

        // fallback
        return subject;
    }


    @AuraEnabled
    public static Integer markTasksAsRead(List<Id> taskIds) {
        if (taskIds == null || taskIds.isEmpty()) return 0;
        List<Task> toUpdate = [
            SELECT Id, Confirmacion_de_lectura__c, WhatId, Subject,
            TYPEOF What
                    WHEN Case THEN
                        CaseNumber,
                        Subject,
                        Asset.numeroDePlaca__c,
                        Work_Order__c,
                        Work_Order__r.WorkOrderNumber
                END
            FROM Task
            WHERE Id IN :taskIds
        ];
        List<Confirmacion_de_lectura__c> lstLecturas = new List<Confirmacion_de_lectura__c>();
        for (Task t : toUpdate) {
            t.Confirmacion_de_lectura__c = true;
            if (!(t.What instanceof Case)) continue;
            Case c = (Case)t.What;

            Confirmacion_de_lectura__c nuevaConfirmacion = new Confirmacion_de_lectura__c();
            nuevaConfirmacion.Case__c = c.id;
            nuevaConfirmacion.Actividad__c = t.id;
            lstLecturas.add(nuevaConfirmacion);

        }

        if (lstLecturas.size()>0) insert lstLecturas;
        

        if (!toUpdate.isEmpty()) update toUpdate;
        return toUpdate.size();
    }
}