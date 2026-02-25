public with sharing class KPIEstadoTallerController {

    public class KPIResponse {
        @AuraEnabled public Integer casosAbiertos;
        @AuraEnabled public Integer sinUpdate2;
        @AuraEnabled public Integer sinContacto5;
        @AuraEnabled public String sucursalConMasRetrasos;
        @AuraEnabled public Integer cantidadAlertasSucursal;
        @AuraEnabled public List<AsesorKPI> asesoresConMasRetrasos;
    }

    public class AsesorKPI {
        @AuraEnabled public String nombre;
        @AuraEnabled public Integer cantidad;

        // Orden de mayor a menor
        public Integer compareTo(Object o) {
            AsesorKPI other = (AsesorKPI)o;
            return other.cantidad - this.cantidad; 
        }
    }

    @AuraEnabled(cacheable=true)
    public static KPIResponse getKPIs() {

        KPIResponse resp = new KPIResponse();

        // ============================
        // 1. Casos abiertos
        // ============================
        resp.casosAbiertos = [
            SELECT COUNT()
            FROM Case
            WHERE IsClosed = false
        ];

        // ============================
        // 2. Sin actualización +2 días
        // ============================
        resp.sinUpdate2 = [
            SELECT COUNT()
            FROM Case
            WHERE IsClosed = false
            AND Dias_sin_contacto__c > 2
        ];

        // ============================
        // 3. Sin contacto +5 días
        // ============================
        resp.sinContacto5 = [
            SELECT COUNT()
            FROM Case
            WHERE IsClosed = false
            AND Dias_sin_contacto__c > 5
        ];

        // ============================
        // 4. Sucursal con más retrasos
        // ============================

        // 4.1 Obtener CaseIds afectados por alertas
        Set<Id> caseIds = new Set<Id>();
        for (Task t : [
            SELECT WhatId
            FROM Task
            WHERE Status = 'Open'
            AND Confirmacion_de_lectura__c = false
            AND Tipo_de_tarea__c = '-Recordatorio al asesor'
            AND RecordType.DeveloperName = 'Seguimiento'
            AND WhatId != null
        ]) {
            caseIds.add(t.WhatId);
        }

        Map<String, Integer> sucursalCount = new Map<String, Integer>();

        if (!caseIds.isEmpty()) {
            // 4.2 Obtener sucursales
            for (Case c : [
                SELECT Service_Territory1__r.Name
                FROM Case
                WHERE Id IN :caseIds
            ]) {
                if (c.Service_Territory1__r != null) {
                    String name = c.Service_Territory1__r.Name;
                    String sucursal =
                        name.contains('-') ? name.split(' - ')[0] : name;

                    Integer count = sucursalCount.get(sucursal);
                    sucursalCount.put(sucursal, count == null ? 1 : count + 1);
                }
            }
        }

        // 4.3 Determinar sucursal ganadora
        resp.sucursalConMasRetrasos = null;
        resp.cantidadAlertasSucursal = 0;

        for (String s : sucursalCount.keySet()) {
            if (sucursalCount.get(s) > resp.cantidadAlertasSucursal) {
                resp.cantidadAlertasSucursal = sucursalCount.get(s);
                resp.sucursalConMasRetrasos = s;
            }
        }

        // ============================
        // 5. Asesores con más retrasos
        // ============================
        Map<Id, Integer> asesorCount = new Map<Id, Integer>();
        Map<Id, String> asesorName = new Map<Id, String>();

        if (!caseIds.isEmpty()) {
            for (Case c : [
                SELECT OwnerId, Owner.Name
                FROM Case
                WHERE Id IN :caseIds
            ]) {
                asesorName.put(c.OwnerId, c.Owner.Name);

                Integer count = asesorCount.get(c.OwnerId);
                asesorCount.put(c.OwnerId, count == null ? 1 : count + 1);
            }
        }

        // Convertir a lista y ordenar
        List<AsesorKPI> asesores = new List<AsesorKPI>();
        for (Id uid : asesorCount.keySet()) {
            AsesorKPI a = new AsesorKPI();
            a.nombre = asesorName.get(uid);
            a.cantidad = asesorCount.get(uid);
            asesores.add(a);
        }

        // Ordenar usando compareTo()
        asesores.sort();

        resp.asesoresConMasRetrasos = asesores;
        

        return resp;
    }
}