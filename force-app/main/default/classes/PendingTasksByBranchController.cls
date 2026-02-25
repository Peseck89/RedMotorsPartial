// PendingTasksByBranchController.cls
public with sharing class PendingTasksByBranchController {

    public class PendingTaskRowDTO {
        @AuraEnabled public Id caseId;
        @AuraEnabled public String caseNumber;

        @AuraEnabled public String vin;
        @AuraEnabled public String placa;
        @AuraEnabled public String cliente;

        @AuraEnabled public String sucursal;
        @AuraEnabled public String tipoServicio;

        @AuraEnabled public Datetime fechaIngreso;
        @AuraEnabled public Decimal diasEnTaller;

        @AuraEnabled public Datetime ultimoContacto;
        @auraEnabled public Decimal diasSinContacto; 
        @AuraEnabled public Id asesorId;
        @AuraEnabled public String asesorNombre;

        @AuraEnabled public String semaforo; // Estado actual (Semaforo__c)
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getTiposDeServicio(String sucursal) {

        List<String> tipos = new List<String>();
        String busquedaSucursal = '%'+sucursal+'%';

        // Ejemplo: sacar del campo Name después del guión
        // Pinares - Diagnóstico
        // Uruca - Mantenimiento
        for (ServiceTerritory st : [
            SELECT Name FROM ServiceTerritory WHERE IsActive = true AND Name Like :busquedaSucursal
        ]) {
            if (st.Name.contains('-')) {
                List<String> parts = st.Name.split(' - ');
                if (parts.size() > 1) {
                    tipos.add(parts[1].trim());
                }
            }
        }

        tipos.sort();
        return tipos;
    }



    @AuraEnabled(cacheable=true)
    public static List<PendingTaskRowDTO> getPendingTasksForFilters(
        Date fechaInicio,
        Date fechaFin,
        String sucursal,   // Uruca, Pinares, Escazú, Motorrad, Otobai (o null para todas)
        Id asesorId        // opcional, null = todos
    ) {
        
        Datetime startDt = null;
        Datetime endDt   = null;

        if (fechaInicio != null) {
            startDt = Datetime.newInstance(
                fechaInicio.year(), fechaInicio.month(), fechaInicio.day(), 0, 0, 0
            );
        }
        if (fechaFin != null) {
            endDt = Datetime.newInstance(
                fechaFin.year(), fechaFin.month(), fechaFin.day(), 23, 59, 59
            );
        }

        String sucursalPrefix = String.isBlank(sucursal) ? null : (sucursal + ' - ');
        // 1) Obtener CaseIds desde Task (primero, sin semi-join)
        Set<Id> caseIdsFromTasks = new Set<Id>();

        for (Task t : [
            SELECT WhatId
            FROM Task
            WHERE Status = 'Open'
            AND Confirmacion_de_lectura__c = false
            AND Tipo_de_tarea__c = '-Recordatorio al asesor'
            AND RecordType.DeveloperName = 'Seguimiento'
            AND WhatId != null
        ]) {
            caseIdsFromTasks.add(t.WhatId);
        }

        if (caseIdsFromTasks.isEmpty()) {
            return new List<PendingTaskRowDTO>();
        }
        
        List<Case> cases = new List<Case>();

        // 2) Query de Cases usando los IDs recuperados
        if(asesorId != null){
            cases = [
            SELECT
                Id,
                CaseNumber,
                FechaEntrada__c,
                Dias_en_taller__c,
                Semaforo__c,
                Dias_sin_contacto__c,
                Account.Name,
                VIN__c,
                Asset.numeroDePlaca__c,
                OwnerId,
                Owner.Name,
                Service_Territory1__r.Name
            FROM Case
            WHERE Id IN :caseIdsFromTasks
            AND IsClosed = false
            AND ( FechaEntrada__c >= :startDt )
            AND (   FechaEntrada__c <= :endDt )
            AND (  Service_Territory1__r.Name LIKE :sucursalPrefix + '%' )
            AND ( OwnerId = :asesorId )

            ];

        }else{
            cases = [
            SELECT
                Id,
                CaseNumber,
                FechaEntrada__c,
                Dias_en_taller__c,
                Dias_sin_contacto__c,
                Semaforo__c,
                Account.Name,
                VIN__c,
                Asset.numeroDePlaca__c,
                OwnerId,
                Owner.Name,
                Service_Territory1__r.Name
            FROM Case
            WHERE Id IN :caseIdsFromTasks
            AND IsClosed = false
            AND ( FechaEntrada__c >= :startDt )
            AND (   FechaEntrada__c <= :endDt )
            AND (  Service_Territory1__r.Name LIKE :sucursalPrefix + '%' )

            ];
        }
        


        if (cases.isEmpty()) {
            return new List<PendingTaskRowDTO>();
        }

        Set<Id> caseIds = new Set<Id>();
        for (Case c : cases) {
            caseIds.add(c.Id);
        }

        // 2) Último contacto por Case (última Task que cumple los criterios)
        Map<Id, Datetime> caseToLastContact = new Map<Id, Datetime>();
        for (Task t : [
            SELECT Id, WhatId, CreatedDate
            FROM Task
            WHERE WhatId IN :caseIds
            AND Status = 'Open'
            AND Confirmacion_de_lectura__c = false
            AND Tipo_de_tarea__c = '-Recordatorio al asesor'
            AND RecordType.DeveloperName = 'Seguimiento'
        ]) {
            if (t.WhatId == null) continue;
            Datetime current = caseToLastContact.get(t.WhatId);
            if (current == null || t.CreatedDate > current) {
                caseToLastContact.put(t.WhatId, t.CreatedDate);
            }
        }

        // 3) Armar DTO
        List<PendingTaskRowDTO> out = new List<PendingTaskRowDTO>();

        for (Case c : cases) {
            PendingTaskRowDTO dto = new PendingTaskRowDTO();
            dto.caseId = c.Id;
            dto.caseNumber = c.CaseNumber;

            dto.vin   = (c.Asset != null) ? c.VIN__c : null;
            dto.placa = (c.Asset != null) ? c.Asset.numeroDePlaca__c : null;

            dto.cliente = (c.Account != null) ? c.Account.Name : null;

            String stName = (c.Service_Territory1__r != null) ? c.Service_Territory1__r.Name : null;
            if (!String.isBlank(stName)) {
                List<String> parts = stName.split(' - ');
                if (!parts.isEmpty()) {
                    dto.sucursal = parts[0];
                    if (parts.size() > 1) {
                        dto.tipoServicio = parts[1];
                    }
                }
            }

            dto.fechaIngreso  = c.FechaEntrada__c;
            dto.diasEnTaller  = c.Dias_en_taller__c;
            dto.ultimoContacto = caseToLastContact.get(c.Id);
            dto.diasSinContacto = c.Dias_sin_contacto__c;
            dto.asesorId      = c.OwnerId;
            dto.asesorNombre  = (c.Owner != null) ? c.Owner.Name : null;

            dto.semaforo      = c.Semaforo__c;

            out.add(dto);
        }

        return out;
    }
}