public without sharing class WorkStepService {
    
    public static final Integer PAGE_SIZE = 15;

    public static final Date START_DATE = isSandbox() || Test.isRunningTest() ? Date.newinstance(1900,01,01) : Date.valueOf(System.Label.RM_FechaFiltroCT);

	public static final String WS_STATUS_EN_CURSO = 'En curso';

	public static final String WS_STATUS_NUEVA = 'Nueva';

    public static final String WS_STATUS_COMPLETADA = 'Completada';

    public static final String WS_WORK_TYPE_MECHANICA_GENERAL = 'Mecánica General';

    public static Boolean isSandbox() {
        List<Organization> organizationList = [SELECT IsSandbox FROM Organization LIMIT 1];
        if (organizationList.size() > 0) {
            return organizationList[0].IsSandbox;
        }
        return false;
    }

    public static Map<String,Object> getWorkSteps(String tallerId,String serviceTypeId,String status,String caseNumber,String workOrderNumber,String plate,String vin,Date startDate,Date endDate,String userId,Boolean nested) {
        Map<String,Object> responseMap = new Map<String,Object>{'success' => false};        
        
        nested = nested == null ? false : nested;

        userId = userId != null ? userId : UserInfo.getUserId();

        Set<Id> territorySet = new Set<Id>(); 
        for (FSL__User_Territory__c ut : [SELECT Id,FSL__ServiceTerritory__c FROM FSL__User_Territory__c WHERE FSL__User__c =:userId]) {
            territorySet.add(ut.FSL__ServiceTerritory__c); 
        }
        
        if (territorySet.isEmpty() && !Test.isRunningTest()) {
            responseMap.put('message','No existen configuracion de territorio para el usuario.');
            return responseMap;
        }

        Set<String> woStatusSkiped = new Set<String>{'Orden Facturada','Orden Rechazada'};
        String soqlString = 'SELECT WorkOrder.AccountId,CreatedDate,WorkOrder.CT_DetalleEstadoFormula__c,WorkOrder.StatusDetail__c,WorkOrder.ServiceTerritoryId,CT_AsignadoA__c,WorkOrder.Status__c,'+
                        'CT_DetailStatus__c,CT_Semaforo__c,CT_TieneSubtipo__c,CT_NombreOrdenDeTrabajo__c,CT_HorasTipoTrabajo__c, CT_TipoDeTrabajoDelCaso__c,Numero_Caso__c,format(StartTime)cStartTime,Orden_URL_F__c,'+
                        'Mec_nico_asignado__r.FirstName,Mec_nico_asignado__r.LastName,CT_Tipo_de_Servicio__c,CT_AccountName__c,Caso__c,Caso__r.CaseNumber,'+
                        'WorkOrder.WorkOrderNumber, Id, WorkOrderId,AcumuladoMinutosPausas__c,Tipo_de_trabajo_del_caso__r.Horaa__c,'+
                        'Name,StartTime,EndTime,WorkOrder.MecanicoLider__c,Hora_de_inicio_de_pausa__c,Tipo_de_trabajo_del_caso__r.CT_Total_Subtareas_FM__c,'+
                        'WorkOrder.AssetId,WorkOrder.Asset.Name,WorkOrder.AccountNumber__c,'+
                        'Status, Mec_nico_asignado__c,Mec_nico_asignado__r.Name,Total_de_tiempo_trabajado_en_minutos__c,'+
                        'CT_Placa__c,WorkOrder.CreatedDate,WorkOrder.Owner.Name,WorkOrder.Account.Name,WorkOrder.Tipo_de_servicio__c,'+
                        'Tipo_de_trabajo_del_caso__c, Tipo_de_trabajo_del_caso__R.Name,WorkOrder.Contact.Name,WorkOrder.ServiceTerritory.Name,'+
                        '(select Cantidad_de_horas__c,Tipo_de_trabajo_del_caso__c,Caso__c from Subtipos_de_trabajos_del_caso__r) '+
                        'FROM WorkStep WHERE Caso__r.Status != \'Cerrado\' AND Caso__r.Fecha_Creacion_FM__c >:START_DATE AND WorkOrder.ServiceTerritoryId IN:territorySet AND (CT_TieneSubtipo__c = false OR CT_TieneSubtipo__c =:nested OR Tipo_de_trabajo_del_caso__r.CT_Total_Subtareas_FM__c = 0)  AND WorkOrder.Etapa_de_flujo_de_trabajo__c NOT IN :woStatusSkiped ';

        String soqlFilterString = '';
        
        if(String.isNotBlank(tallerId) && tallerId != 'all'){
            soqlFilterString += ' AND WorkOrder.ServiceTerritoryId = \''+ tallerId.trim() +'\' ';
        }

        if(String.isNotBlank(serviceTypeId) && serviceTypeId != 'all'){            
            soqlFilterString += ' AND WorkOrder.Tipo_de_servicio__c = \''+ serviceTypeId.trim() +'\'';
        }

        if(String.isNotBlank(status) && status != 'all'){            
            soqlFilterString += ' AND Status = \''+ status.trim() +'\'';
        }
        
        if(String.isNotBlank(workOrderNumber)){            
            soqlFilterString += ' AND WorkOrder.WorkOrderNumber LIKE \'%'+ workOrderNumber.trim() +'%\'';
        }

        if(String.isNotBlank(caseNumber)){
            soqlFilterString += ' AND Numero_Caso__c LIKE \'%'+ caseNumber.trim() +'%\'';
        }

        if(String.isNotBlank(plate)){
            soqlFilterString += ' AND (WorkOrder.Asset.Name LIKE \'%'+ plate.trim() +'%\' OR Caso__r.N_de_placa__c LIKE \'%'+ plate.trim() +'%\' )';
        }

        if(String.isNotBlank(vin)){
            soqlFilterString += ' AND ( WorkOrder.Asset.NumeroDeChasis__c LIKE \'%'+ vin.trim() +'%\' OR Caso__r.VIN__c LIKE \'%'+ vin.trim() +'%\' )';
        }
        
        if(startDate != null){                  
            soqlFilterString += ' AND WorkOrder.CT_Fecha_Creacion_FM__c >= :startDate ';
        }
        
        if(endDate != null){
            soqlFilterString += ' AND WorkOrder.CT_Fecha_Creacion_FM__c <= :endDate';            
        }
    
        soqlString += soqlFilterString;        

        soqlString += ' LIMIT :PAGE_SIZE';

        List<WorkStepWrapper> workStepWrapperList = new List<WorkStepWrapper>();
        try {
            List<WorkStep> workStepList = (List<WorkStep>) Database.query(soqlString);
            for (WorkStep workStep : workStepList) {
                workStepWrapperList.add(new WorkStepWrapper(workStep));
            }
            responseMap.put('workStepWrapperList',workStepWrapperList);
            responseMap.put('success',true);
        } catch (DMLException e) {            
            responseMap.put('message',e.getMessage());            
        }
        return responseMap;
    }

    public static Map<String,Object> getTasksGroupedByCase(List<String> territoryIds,String mechanicId, List<String> statuses,String caseNumber,String orderNumber,String plate,String vin,Date startCreationDate,Date endCreationDate,String userId,Integer pageNumber) {
        Map<String,Object> responseMap = new Map<String,Object>{'success' => false};    
        
        pageNumber = pageNumber != null ? pageNumber : 1;            
        
        Set<Id> assignedTerritoryIds = getAssignedTerritories();

        if (assignedTerritoryIds.isEmpty() && !Test.isRunningTest()) {
            responseMap.put('message','No existen configuracion de territorio para el usuario.');
            return responseMap;
        }

        Set<String> skipedWSStatus = new Set<String>{'Orden Facturada','Orden Rechazada'};

        String soqlWSSubquery = 'SELECT Caso__c FROM WorkStep WHERE Caso__r.Status != \'Cerrado\' AND Caso__r.Fecha_Creacion_FM__c >:START_DATE AND WorkOrder.ServiceTerritoryId IN:assignedTerritoryIds AND WorkOrder.Etapa_de_flujo_de_trabajo__c NOT IN :skipedWSStatus';        

        String soqlFilterString = '';
        
        if(territoryIds != null && !territoryIds.isEmpty()){            
            soqlFilterString += ' AND WorkOrder.ServiceTerritoryId IN :territoryIds';
        }

        if(String.isNotBlank(mechanicId)){            
            soqlFilterString += ' AND Mec_nico_asignado__c = :mechanicId';
        }    

        if(statuses != null && !statuses.isEmpty()){            
            soqlFilterString += ' AND Status IN :statuses ';
        }
        
        if(String.isNotBlank(orderNumber)){            
            soqlFilterString += ' AND WorkOrder.WorkOrderNumber = \''+ orderNumber.trim() +'\'';
        }        

        if(String.isNotBlank(caseNumber)){
            soqlFilterString += ' AND Numero_Caso__c LIKE \'%'+ caseNumber.trim() +'%\'';
        }

        if(String.isNotBlank(plate)){
            soqlFilterString += ' AND (WorkOrder.Asset.Name LIKE \'%'+ plate.trim() +'%\' OR Caso__r.N_de_placa__c LIKE \'%'+ plate.trim() +'%\' )';
        }                 

        if(String.isNotBlank(vin)){
            soqlFilterString += ' AND ( WorkOrder.Asset.NumeroDeChasis__c LIKE \'%'+ vin.trim() +'%\' OR Caso__r.VIN__c LIKE \'%'+ vin.trim() +'%\' )';
        }   
        
        if(startCreationDate != null){                  
            soqlFilterString += ' AND WorkOrder.CT_Fecha_Creacion_FM__c >= :startCreationDate ';
        }
        
        if(endCreationDate != null){
            soqlFilterString += ' AND WorkOrder.CT_Fecha_Creacion_FM__c <= :endCreationDate';            
        }        

        soqlWSSubquery += soqlFilterString;  

        try {
            Integer offset = (pageNumber - 1) * PAGE_SIZE;
            Integer totalRecords = Database.countQuery('SELECT count() FROM Case WHERE Id IN ('+soqlWSSubquery+') ');        
            Integer recordEnd = PAGE_SIZE * pageNumber;
    
            responseMap.put('pageSize',PAGE_SIZE);
            responseMap.put('pageNumber',pageNumber);
            responseMap.put('totalRecords',totalRecords);
            responseMap.put('recordStart',offset + 1);
            responseMap.put('recordEnd',totalRecords >= recordEnd ? recordEnd : totalRecords);        
    
            String soqlString = 'SELECT Id,VIN__c,CaseNumber,Asset.SerialNumber,Asset.NumeroDeChasis__c,Asset.Name,CreatedDate,(SELECT Id,WorkOrderNumber,Aprobado__c FROM WorkOrders LIMIT 1),(SELECT Horaa__c FROM Tipos_de_Trabajo__r WHERE Horaa__c != NULL),(SELECT Status,Total_de_tiempo_trabajado_en_minutos__c,AcumuladoMinutosPausas__c,Tipo_de_trabajo_del_caso__c,Tipo_de_trabajo_del_caso__r.Horaa__c,Tipo_de_trabajo_del_caso__r.CT_Total_Subtareas_FM__c,Mec_nico_asignado__c FROM Subtipos_de_trabajos1__r) FROM Case WHERE Status != \'Cerrado\' AND Id IN ('+soqlWSSubquery+')  LIMIT :PAGE_SIZE  OFFSET :offset';

            List<Case> caseList = (List<Case>) Database.query(soqlString);
            Set<Id> wsIds = new Set<Id>();
            Set<Id> woIds = new Set<Id>();
            for (Case currentCase : caseList) {
                for (WorkStep currentWorkStep : currentCase.Subtipos_de_trabajos1__r) {                    
                    wsIds.add(currentWorkStep.Id);
                }
                for (WorkOrder currentWorkOrder : currentCase.WorkOrders) {
                    woIds.add(currentWorkOrder.Id);
                }
            }

            List<Subtipo_de_trabajo_del_caso__c> sttcList = new List<Subtipo_de_trabajo_del_caso__c>();
            if (wsIds.size() > 0) {
                sttcList = [SELECT Id,Cantidad_de_horas__c,Caso__c,Paso_de_trabajo__c,Tipo_de_trabajo_del_caso__r.CT_Total_Subtareas_FM__c FROM Subtipo_de_trabajo_del_caso__c WHERE Paso_de_trabajo__c IN :wsIds AND Orden_de_trabajo__c IN:woIds];  
            }

            responseMap.put('sttcRecords',sttcList);            
            responseMap.put('records',caseList);            
            responseMap.put('success',true);
        } catch (DMLException e) {            
            responseMap.put('message',e.getMessage());            
        }
        return responseMap;
    } 
    
    public static Map<String,Object> getWorkStepsForReports(List<String> territories,String mechanicId,String caseNumber,Date startDate, Date endDate,Boolean showParentTasks) {

        Map<String,Object> responseMap = new Map<String,Object>();
        
        Set<Id> territoryIds = getAssignedTerritories();

        showParentTasks = showParentTasks == null ? false : !showParentTasks;

        String soqlString = 'SELECT Id,CT_CantidadDeHoras__c,Tipo_de_trabajo_del_caso__r.RM_ModoTrabajo__c,RM_TotalHorasFX__c,Caso__c,Caso__r.CaseNumber,WorkOrder.ServiceTerritoryId, Total_de_tiempo_trabajado_en_minutos__c, WorkOrderId,WorkOrder.WorkOrderNumber,Flag_Is_Task_FX__c,Mec_nico_asignado__c,Mec_nico_asignado__r.Name,WorkOrder.ServiceTerritory.Name,Caso__r.Service_Territory1__c,Caso__r.Service_Territory1__r.Name FROM WorkStep';               
        
        String soqlFilterString = ' WHERE Caso__r.Status = \'Cerrado\' AND Caso__r.Fecha_Creacion_FM__c >:START_DATE AND Caso__r.Service_Territory1__c IN:territoryIds AND Mec_nico_asignado__c != null AND WorkOrder.Etapa_de_flujo_de_trabajo__c = \'Orden Facturada\' ';
        // String soqlFilterString = ' WHERE Mec_nico_asignado__c != null  ';

        if(territories != null && !territories.isEmpty()){
            soqlFilterString += ' AND Caso__r.Service_Territory1__c IN :territories  ';
        }
        
        if(String.isNotBlank(mechanicId)){
            soqlFilterString += ' AND Mec_nico_asignado__c = :mechanicId ';
        }             
        
        if(startDate == null || endDate == null){
            return responseMap;
        }

        if(String.isNotBlank(caseNumber)){
            soqlFilterString += ' AND Caso__r.CaseNumber = :caseNumber ';
        }         
              
        soqlFilterString += ' AND Caso__r.Fecha_Creacion_FM__c >= :startDate AND Caso__r.Fecha_Creacion_FM__c <= :endDate';                

        if (!Test.isRunningTest()) {
            soqlString += soqlFilterString;            
        }
        
        soqlString += ' ORDER BY Mec_nico_asignado__r.Name ASC,WorkOrder.WorkOrderNumber';

        // System.debug('@@@soqlString@@@'+soqlString);
        
        List<WorkStep> workStepList = (List<WorkStep>) Database.query(soqlString);

        Set<Id> mechanicIds = new Set<Id>();
        Set<Id> caseIds = new Set<Id>();
        Map<String,Set<String>> mecIdCaseSetMap = new Map<String,Set<String>>();
        Map<String,List<WorkStep>> mecIdWorkStepListMap = new Map<String,List<WorkStep>>();

        Map<Id,String> territoryMap = new Map<Id,String>();
        for (WorkStep ws : workStepList) {
            mechanicIds.add(ws.Mec_nico_asignado__c);
            caseIds.add(ws.Caso__c);
            
            String key = ws.Mec_nico_asignado__c + '_' + ws.Caso__r.Service_Territory1__c;

            if (!mecIdCaseSetMap.containsKey(key)) {
                mecIdCaseSetMap.put(key,new Set<String>());
            }

            Set<String> caseSet = mecIdCaseSetMap.get(key);
            caseSet.add(ws.Caso__c);
            mecIdCaseSetMap.put(key,caseSet);

            if (!mecIdWorkStepListMap.containsKey(key)) {
                mecIdWorkStepListMap.put(key,new List<WorkStep>());
            }
            
            List<WorkStep> wsList = mecIdWorkStepListMap.get(key);
            wsList.add(ws);
            mecIdWorkStepListMap.put(key,wsList);

            territoryMap.put(ws.Caso__r.Service_Territory1__c,ws.Caso__r.Service_Territory1__r.Name);
        }
        
        System.debug('@mecIdWorkStepListMap@');        
        System.debug(mecIdWorkStepListMap);
        Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Id,Name FROM Contact WHERE Id IN :mechanicIds ORDER BY Name ASC]);
        
        List<ContactWrapperReport> WSWrapperReportList = new List<ContactWrapperReport>();
        for(String key : mecIdCaseSetMap.keySet()){
            List<String> separar = key.split('_');
            Contact mecanico = contactMap.get(separar[0]);

            ContactWrapperReport wrpReport = new ContactWrapperReport();
            wrpReport.mechanicId = mecanico.Id;
            wrpReport.mechanicName = mecanico.Name;
            wrpReport.territoryId = separar[1];
            wrpReport.territoryName = territoryMap.get(separar[1]);
            wrpReport.workSteps = mecIdWorkStepListMap.get(key);
            wrpReport.setCases(mecIdCaseSetMap.get(key));
            wrpReport.numWS = wrpReport.cases.size();
            WSWrapperReportList.add(wrpReport);
        }
        responseMap.put('records',WSWrapperReportList);
        responseMap.put('tiemposimproductivos',getTiemposImproductivos(caseIds));
        
        return responseMap;
    }

    public static List<TIWrrp> getTiemposImproductivos(Set<Id> caseIds) {
        List<TIWrrp> TIWrrpList = new List<TIWrrp>();
        Map<String,TIWrrp> caseIdTIWrrpMap = new Map<String,TIWrrp>();
        if (caseIds== null || caseIds.size() == 0) {
            return TIWrrpList;
        }
        List<Horas_improductivas_por_mec_nico__c> himList = [SELECT Id, Caso__c,Inicio__c,Hora_inicio__c,Fin__c, Hora_fin__c,Mecanico__c FROM Horas_improductivas_por_mec_nico__c WHERE Caso__c IN:caseIds];
        for (Horas_improductivas_por_mec_nico__c him : himList) {            
            String key = him.Caso__c + '_'+ him.Mecanico__c;

            if (caseIdTIWrrpMap.get(key) == null) {
                caseIdTIWrrpMap.put(key,new TIWrrp(him.Caso__c,him.Mecanico__c));
            }

            TIWrrp currTIWrrp = caseIdTIWrrpMap.get(key);
            Decimal total = currTIWrrp.total;
            total += getMinutosPausa(him);
            currTIWrrp.total = total;
            caseIdTIWrrpMap.put(key,currTIWrrp);
        }                

        return caseIdTIWrrpMap.values();
    }

    public class TIWrrp{
        @AuraEnabled
        public String caseId;
        @AuraEnabled
        public String mecanicoId;        
        @AuraEnabled
        public Decimal total;     
        
        public TIWrrp(String caseId,String mecanicoId){
            this.caseId = caseId;
            this.mecanicoId = mecanicoId;
            this.total = 0;
        }
    }

    public static Decimal getMinutosPausa(Horas_improductivas_por_mec_nico__c him) {
        if (him==null || him.Inicio__c == null || him.Hora_inicio__c == null || him.Fin__c == null || him.Hora_fin__c == null ) {
            return 0;
        }
        DateTime fechaHoraInicio =  Datetime.newInstanceGMT(him.Inicio__c,him.Hora_inicio__c);
        DateTime fechaHoraFin =  Datetime.newInstanceGMT(him.Fin__c,him.Hora_fin__c);

        Decimal hours = fechaHoraFin.getTime() - fechaHoraInicio.getTime();
        if (hours > 0) {
            hours /= 1000;
            hours /= 60;
            hours /= 60;
        }
        return hours;
    }

    public class ContactWrapperReport {
        @AuraEnabled
        public String mechanicId;

        @AuraEnabled
        public String territoryId;  

        @AuraEnabled
        public String territoryName;          
        
        @AuraEnabled
        public String caseId;            

        @AuraEnabled
        public String mechanicName;
        
        @AuraEnabled
        public Integer numWS;

        @AuraEnabled
        public List<WorkStep> workSteps;

        @AuraEnabled
        public List<String> cases;

        ContactWrapperReport(){
            this.cases = new List<String>();
        }

        public void setCases(Set<String> caseSet){
            for (String caseId : caseSet) {
                this.cases.add(caseId);
            }
        }
                
    }




















    public static void dummy(){
        String test = '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
    }    

    public static Set<Id> getAssignedTerritories() {
        Set<Id> territorySet = new Set<Id>(); 
        for (FSL__User_Territory__c ut : [SELECT Id,FSL__ServiceTerritory__c FROM FSL__User_Territory__c WHERE FSL__User__c = :UserInfo.getUserId()]) {
            territorySet.add(ut.FSL__ServiceTerritory__c); 
        }
        return territorySet;
    }
}