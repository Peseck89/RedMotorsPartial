/**
 * @description       : Provee informacion a la pantalla vista kanban
 * @author            : marcohernandezhp@gmail.com
 * @group             : Redmotors
 * @last modified on  : 02-27-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/

public without sharing class CT_VistaKanban_Ctrl {
    
    public static final Integer PAGE_SIZE = 100;

    public static final Date START_DATE = isSandbox() ? Date.newinstance(1900,01,01) : Date.newinstance(2022,10,31); 

    public static Boolean isSandbox() {
        List<Organization> organizationList = [SELECT IsSandbox FROM Organization LIMIT 1];
        if (organizationList.size() > 0) {
            return organizationList[0].IsSandbox;
        }
        return false;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getRecords(String tallerId,String serviceTypeId,String status,String caseNumber,String workOrderNumber,String vin,Date startDate,Date endDate,Boolean nested,String objetoStatus) {
        Map<String,Object> responseMap = new Map<String,Object>{'success' => false};        
        
        Set<Id> territorySet = new Set<Id>(); 
        for (FSL__User_Territory__c ut : [SELECT Id,FSL__ServiceTerritory__c FROM FSL__User_Territory__c WHERE FSL__User__c = :UserInfo.getUserId()]) {
            territorySet.add(ut.FSL__ServiceTerritory__c); 
        }
        
        if (territorySet.isEmpty() && !Test.isRunningTest()) {
            responseMap.put('message','No existen configuracion de territorio para el usuario.');
            return responseMap;
        }

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
                        'FROM WorkStep WHERE Caso__r.Fecha_Creacion_FM__c >:START_DATE AND WorkOrder.ServiceTerritoryId IN:territorySet AND (CT_TieneSubtipo__c = false OR CT_TieneSubtipo__c =:nested OR Tipo_de_trabajo_del_caso__r.CT_Total_Subtareas_FM__c = 0)  AND WorkOrder.Etapa_de_flujo_de_trabajo__c NOT IN(\'Orden Facturada\',\'Orden Rechazada\') ';

        String soqlFilterString = '';
        
        if(String.isNotBlank(tallerId) && tallerId != 'all'){
            soqlFilterString += ' AND WorkOrder.ServiceTerritoryId = \''+ tallerId.trim() +'\' ';
        }

        if(String.isNotBlank(serviceTypeId) && serviceTypeId != 'all'){            
            soqlFilterString += ' AND WorkOrder.Tipo_de_servicio__c = \''+ serviceTypeId.trim() +'\'';
        }

        if(String.isNotBlank(status) && status != 'all'){ 
            soqlFilterString += objetoStatus == null || objetoStatus.equalsIgnoreCase('workstep') ? ' AND Status = \''+ status.trim() +'\'' : ' AND WorkOrder.StatusDetail__c = \''+ status.trim() +'\''   ;  
        }
        
        if(String.isNotBlank(workOrderNumber)){            
            soqlFilterString += ' AND WorkOrder.WorkOrderNumber LIKE \'%'+ workOrderNumber.trim() +'%\'';
        }

        if(String.isNotBlank(caseNumber)){
            soqlFilterString += ' AND Numero_Caso__c LIKE \'%'+ caseNumber.trim() +'%\'';
        }

        if(String.isNotBlank(vin)){
            soqlFilterString += ' AND (WorkOrder.Asset.Name LIKE \'%'+ vin.trim() +'%\' OR  Caso__r.N_de_placa__c LIKE \'%'+ vin.trim() +'%\' OR WorkOrder.Asset.NumeroDeChasis__c LIKE \'%'+ vin.trim() +'%\' OR Caso__r.VIN__c LIKE \'%'+ vin.trim() +'%\' )';
        }
        
        if(startDate != null){                  
            soqlFilterString += ' AND WorkOrder.CT_Fecha_Creacion_FM__c >= :startDate ';
        }
        
        if(endDate != null){
            soqlFilterString += ' AND WorkOrder.CT_Fecha_Creacion_FM__c <= :endDate';            
        }
    
        soqlString += soqlFilterString;        

        soqlString += ' LIMIT :PAGE_SIZE';

        System.debug(soqlString);

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
}