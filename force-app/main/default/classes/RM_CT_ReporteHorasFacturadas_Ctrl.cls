public with sharing class RM_CT_ReporteHorasFacturadas_Ctrl {

    private static final String MECHANIC_TERRITORY_KEY_FORMAT = '{0}_{1}';
    private static final String MECHANIC_TERRITORY_CASE_KEY_FORMAT = '{0}_{1}_{2}';
    private static final String TAREA_PADRE = 'Tarea padre';
    private static final String TAREA_HIJA = 'Tarea hija';


    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getData(String mechanicId, Date startDate, Date endDate, Boolean showResume, String caseNumber){
        Map<String, Object> result = new Map<String, Object>{'records' => new List<ReportHFWrp>()};
        try {
            //validate if the format dates are corect
            if (startDate == null || endDate == null) {
                return result;
            }
            Map<Id,Case> casesMap = getCases(mechanicId, startDate, endDate, caseNumber);
            result.put('cases', casesMap);
            Map<String,Object> data = prepareData(casesMap,showResume);
            result.put('records', data.get('records'));
            return result;
        } catch (Exception e) {
            System.debug('Error retrieving data: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving data: ' + e.getMessage());
        }
    }

    private static Map<String,Object> prepareData(Map<Id,Case> cases,Boolean showResume){
        Map<String,Object> responseMap = new Map<String,Object>();
        Map<String,ReportHFWrp> reportWrpsMap = new Map<String,ReportHFWrp>();
        Set<Id> ttcIdsProcesados = new Set<Id>();
        Map<Id,Contact> mechanicsMap = new Map<Id,Contact>();
        for (Case caso : cases.values()) {
            for (WorkStep ws : caso.Subtipos_de_trabajos1__r) {

                String key = getKey(ws?.RM_Mecanico__c, caso.Service_Territory1__c, caso.Id,showResume);

                ReportHFWrp reportWrp = reportWrpsMap.get(key);
                if(reportWrp == null){
                    reportWrp = new ReportHFWrp(caso,ws);
                }
                    
                reportWrp.horasEstimadas += ws.RM_TotalHorasFX__c != null ? ws.RM_TotalHorasFX__c : 0;
                reportWrp.horasFacturadas += ws.Tiempo_Trabajado_Horas_FM__c != null ? ws.Tiempo_Trabajado_Horas_FM__c : 0;
       
                Decimal horasRealesTrabajadas = ws.Tiempo_Trabajado_Horas_FM__c != null ? ws.Tiempo_Trabajado_Horas_FM__c : 0;

                if(ws.Tipo_de_trabajo_del_caso__c != null && ws.Tipo_de_trabajo_del_caso__r.RM_TipoTrabajoCaso__c == null){
                    reportWrp.horasTrabajadas += horasRealesTrabajadas;
                    reportWrp.eficiencia += reportWrp.horasTrabajadas > 0 && reportWrp.horasEstimadas > 0 ? reportWrp.horasTrabajadas / reportWrp.horasEstimadas : 0;
                    reportWrp.productividad += ws.Tiempo_Trabajado_Horas_FM__c != null && ws.Tiempo_Trabajado_Horas_FM__c > 0 ? (ws.Tiempo_Trabajado_Horas_FM__c / 8) * 22 : 0;
                }else{
                    reportWrp.horasReprocesadas += horasRealesTrabajadas;
                }
                reportWrpsMap.put(key, reportWrp);
            }
        }
        responseMap.put('records', reportWrpsMap.values());
        return responseMap;
    }

    private static String getKey(Id mechanicId,Id territoryId, Id caseId, Boolean showResume){
        return (!showResume) ? String.format(MECHANIC_TERRITORY_KEY_FORMAT, new List<String>{mechanicId, territoryId}) : String.format(MECHANIC_TERRITORY_CASE_KEY_FORMAT, new List<String>{mechanicId, territoryId, caseId});
    }

    private static Map<Id,Case> getCases(String mechanicId, Date startDate, Date endDate, String caseNumber) {
        if (startDate == null || endDate == null) {
            return new Map<Id,Case>();
        }

        Set<Id> territoryIds = getTerritoryIdsByUser();

        String mechanicFilter = '';
        if (String.isNotBlank(mechanicId)) {
            mechanicFilter += ' RM_Mecanico__c = :mechanicId AND ';
        }

        String queryString = ' SELECT Id, Service_Territory1__c, Service_Territory1__r.Id, Service_Territory1__r.Name, CaseNumber,'+
                             ' (SELECT Id,RM_Mecanico__c,RM_Mecanico__r.Name,Tipo_de_trabajo_del_caso__c,Tipo_de_trabajo_del_caso__r.RM_TipoTrabajoCaso__c,Tiempo_Trabajado_Horas_FM__c,RM_TotalHorasFX__c,RM_EsTrabajo__c FROM Subtipos_de_trabajos1__r WHERE ' +mechanicFilter+' ((Tipo_de_trabajo_del_caso__r.RM_ModoTrabajo__c = :TAREA_PADRE AND RM_EsTrabajo__c = TRUE) OR (Tipo_de_trabajo_del_caso__r.RM_ModoTrabajo__c = :TAREA_HIJA AND RM_EsTrabajo__c = FALSE)))'+
                            ' FROM Case ';
        
        String whereConditions = ' WHERE Service_Territory1__c != NULL AND Service_Territory1__c IN :territoryIds AND CreatedDate >= :startDate AND CreatedDate <= :endDate';

        if (String.isNotBlank(caseNumber)) {
            whereConditions += ' AND CaseNumber = :caseNumber';
        }

        queryString += whereConditions + ' LIMIT 50000';

        List<Case> cases = Database.query(queryString);

        Map<Id,Case> casesMap = new Map<Id,Case>();
        for (Case caso : cases) {
            casesMap.put(caso.Id, caso);
        }

        return casesMap;
    }

    private static Set<Id> getTerritoryIdsByUser() {
        Set<Id> territoryIds = new Set<Id>();
        for (FSL__User_Territory__c stm : [SELECT FSL__ServiceTerritory__c FROM FSL__User_Territory__c WHERE FSL__User__c = :UserInfo.getUserId()]) {
            territoryIds.add(stm.FSL__ServiceTerritory__c);
        }
        return territoryIds;
    }

    private static Set<Id> getMechanicIdsByTerritories(Set<Id> territoryIds) {
        Set<Id> mechanicIds = new Set<Id>();
        for (RM_MecanicoTaller__c mt : [SELECT RM_Mecanico__c FROM RM_MecanicoTaller__c WHERE RM_Taller__c = :territoryIds]) {
            territoryIds.add(mt.RM_Mecanico__c);
        }
        return mechanicIds;
    }

    public class ReportHFWrp {
        @AuraEnabled
        public Id mechanicId {get;set;}
        @AuraEnabled
        public String mechanicName {get;set;}
        @AuraEnabled
        public Id territoryId {get;set;}
        @AuraEnabled
        public String territoryName {get;set;}
        @AuraEnabled
        public Id caseId {get;set;}
        @AuraEnabled
        public String caseNumber {get;set;}
        @AuraEnabled
        public Decimal horasEstimadas {get;set;}
        @AuraEnabled
        public Decimal horasTrabajadas {get;set;}
        @AuraEnabled
        public Decimal horasFacturadas {get;set;}
        @AuraEnabled
        public Decimal horasReprocesadas {get;set;}
        @AuraEnabled
        public Decimal tiemposImproductivos {get;set;}
        @AuraEnabled
        public Decimal eficiencia {get;set;}
        @AuraEnabled
        public Decimal productividad {get;set;}
        @AuraEnabled
        public Map<String,ReportHFWrp> casosMap {get;set;}
        @AuraEnabled
        public List<ReportHFWrp> casosMaps {get;set;}
        @AuraEnabled
        public Map<String,WorkStep> workStep {get;set;}

        // public ReportHFWrp(Case caso,tiposDeTrabajoCaso__c ttc) {
        //     WorkStep ws = ttc?.Paso_de_trabajo__r;
        //     this.mechanicId = ws?.RM_Mecanico__r.Id;
        //     this.mechanicName = ws?.RM_Mecanico__r.Name;
        //     this.territoryId = caso.Service_Territory1__r.Id;
        //     this.territoryName = caso.Service_Territory1__r.Name;
        //     this.caseId = caso.Id;
        //     this.caseNumber = caso.CaseNumber;

        //     this.horasEstimadas = 0;
        //     this.horasTrabajadas = 0;
        //     this.horasFacturadas = 0;
        //     this.horasReprocesadas = 0;
        //     this.tiemposImproductivos = 0;
        //     this.eficiencia = 0;
        //     this.productividad = 0;
        //     this.casosMap = new Map<String,ReportHFWrp>();
        //     this.casosMaps = new List<ReportHFWrp>();
        // }

        public ReportHFWrp(Case caso,WorkStep ws) {
            this.mechanicId = ws.RM_Mecanico__r.Id;
            this.mechanicName = ws.RM_Mecanico__r.Name;
            this.territoryId = caso.Service_Territory1__r.Id;
            this.territoryName = caso.Service_Territory1__r.Name;
            this.caseId = caso.Id;
            this.caseNumber = caso.CaseNumber;

            this.horasEstimadas = 0;
            this.horasTrabajadas = 0;
            this.horasFacturadas = 0;
            this.horasReprocesadas = 0;
            this.tiemposImproductivos = 0;
            this.eficiencia = 0;
            this.productividad = 0;
            this.casosMap = new Map<String,ReportHFWrp>();
            this.casosMaps = new List<ReportHFWrp>();
        }

        // public void addWorkStep(Case caso,WorkStep ws){
            // si no es reprocesamiento
            // if(ws.Tipo_de_trabajo_del_caso__c != null && ws.Tipo_de_trabajo_del_caso__r != null){
                // if (ws.Tipo_de_trabajo_del_caso__r.RM_ModoTrabajo__c != null && ws.Tipo_de_trabajo_del_caso__r.RM_ModoTrabajo__c == 'Tarea padre') {
                //     this.horasEstimadas = ws.RM_TotalHorasFX__c != null ? ws.RM_TotalHorasFX__c : 0;
                //     this.horasTrabajadas = ws.Tiempo_Trabajado_Horas_FM__c != null ? ws.Tiempo_Trabajado_Horas_FM__c : 0;
                //     this.horasFacturadas = ws.RM_TotalHorasFX__c != null ? ws.RM_TotalHorasFX__c : 0;   
                // }else{
                    // this.horasEstimadas += ws.RM_TotalHorasFX__c != null ? ws.RM_TotalHorasFX__c : 0;
                    // this.horasTrabajadas += ws.Tiempo_Trabajado_Horas_FM__c != null ? ws.Tiempo_Trabajado_Horas_FM__c : 0;
                    // this.horasFacturadas += ws.RM_TotalHorasFX__c != null ? ws.RM_TotalHorasFX__c : 0;
                // }
            // }else if(ws.Tipo_de_trabajo_del_caso__c != null){
            //     if (ws.Tipo_de_trabajo_del_caso__r.RM_ModoTrabajo__c == 'Tarea padre') {
            //         this.horasReprocesadas = ws.Tiempo_Trabajado_Horas_FM__c != null ? ws.Tiempo_Trabajado_Horas_FM__c : 0;
            //     }else{
            //         this.horasReprocesadas += ws.Tiempo_Trabajado_Horas_FM__c != null ? ws.Tiempo_Trabajado_Horas_FM__c : 0;
            //     }
            // }
        // }

        // public void sumar(){
        //     for(ReportHFWrp caso : casosMaps){
        //         this.horasEstimadas += caso.horasEstimadas;
        //         this.horasTrabajadas += caso.horasTrabajadas;
        //         this.horasFacturadas += caso.horasFacturadas;
        //         this.horasReprocesadas += caso.horasReprocesadas;
        //         this.tiemposImproductivos += caso.tiemposImproductivos;
        //     }
        // }
    }
}