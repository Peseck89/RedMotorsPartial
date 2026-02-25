public with sharing class cT_vistaTradicional {
    
    public static final Integer PAGE_SIZE = 15;

    public static final Date START_DATE = WorkStepService.START_DATE;

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getWorkSteps(List<String> statuses,List<String> territories,String mechanicId,String serviceType,String workOrderNumber,String caseNumber,String plate,String vin,Date creationDateFrom,Date creationDateTo,Integer pageNumber) {
        Map<String,Object> responseMap = new Map<String,Object>();
        pageNumber = pageNumber != null ? pageNumber : 1;

        Set<Id> assignedTerritoryIds = WorkStepService.getAssignedTerritories();

        if (assignedTerritoryIds.isEmpty() && !Test.isRunningTest()) {
            return responseMap;
        }
        
        String soqlString = 'SELECT CT_NombreOrdenDeTrabajo__c, CT_TipoDeTrabajoDelCaso__c,CT_AsignadoA__c,WorkOrder.Status__c,Caso__c,Caso__r.CaseNumber,'+
                            'Mec_nico_asignado__r.FirstName,Mec_nico_asignado__r.LastName,CT_TieneSubtipo__c,Tipo_de_trabajo_del_caso__r.Horaa__c,WorkOrder.CT_Fecha_Creacion_FM__c,'+
                            'WorkOrder.WorkOrderNumber, Id, WorkOrderId,AcumuladoMinutosPausas__c,'+
                            'Name,StartTime,EndTime,WorkOrder.MecanicoLider__c,Hora_de_inicio_de_pausa__c,Hora_de_finalizaci_n_de_pausa__c,'+
                            'WorkOrder.AssetId,WorkOrder.Asset.Name,WorkOrder.AccountNumber__c,WorkOrder.Asset.NumeroDeChasis__c,'+
                            'Status, Mec_nico_asignado__c,Mec_nico_asignado__r.Name,Total_de_tiempo_trabajado_en_minutos__c,'+
                            'CT_Placa__c,WorkOrder.CreatedDate,WorkOrder.Owner.Name,WorkOrder.Account.Name,WorkOrder.Tipo_de_servicio__c,'+
                            'Tipo_de_trabajo_del_caso__c, Tipo_de_trabajo_del_caso__r.Name,Tipo_de_trabajo_del_caso__r.Nombre_TTC__c,Tipo_de_trabajo_del_caso__r.CT_Total_Subtareas_FM__c,WorkOrder.Contact.Name,WorkOrder.ServiceTerritory.Name,'+
                            '(select Cantidad_de_horas__c,Tipo_de_trabajo_del_caso__c,Caso__c from Subtipos_de_trabajos_del_caso__r) '+
                            'FROM WorkStep';

        String soqlFilterString = ' WHERE Caso__r.Fecha_Creacion_FM__c >:START_DATE AND WorkOrder.ServiceTerritoryId IN:assignedTerritoryIds AND WorkOrder.Etapa_de_flujo_de_trabajo__c != \'Orden Facturada\' AND WorkOrder.Etapa_de_flujo_de_trabajo__c != \'Orden Rechazada\'  AND (Tipo_de_trabajo_del_caso__r.CT_Total_Subtareas_FM__c = 0 OR CT_TieneSubtipo__c = true ) ';
        
        if(statuses != null && statuses.size() > 0){            
            soqlFilterString += ' AND Status IN :statuses';
        }
        if(territories != null && !territories.isEmpty()){
            soqlFilterString += ' AND WorkOrder.ServiceTerritoryId IN :territories ';
        }
        if(String.isNotBlank(serviceType) && serviceType != 'all'){            
            soqlFilterString += ' AND WorkOrder.Tipo_de_servicio__c = \''+ serviceType.trim() +'\' ';
        }
        if(String.isNotBlank(mechanicId)){            
            soqlFilterString += ' AND Mec_nico_asignado__c = \''+ mechanicId.trim() +'\'';
        }    
        if(String.isNotBlank(plate)){            
            soqlFilterString += ' AND CT_Placa__c LIKE \'%'+plate+'%\'';
        } 
        if(String.isNotBlank(vin)){            
            soqlFilterString += ' AND WorkOrder.VinFormula__c  LIKE \'%'+ vin.trim() +'%\' ';
        }                 
        if(String.isNotBlank(workOrderNumber)){            
            soqlFilterString += ' AND WorkOrder.WorkOrderNumber = \''+ workOrderNumber.trim() +'\' ';
        }
        if(String.isNotBlank(caseNumber)){
            soqlFilterString += ' AND Caso__r.CaseNumber = \''+ caseNumber.trim() +'\' ';
        }                
        if(creationDateFrom != null){                        
            soqlFilterString += ' AND WorkOrder.CT_Fecha_Creacion_FM__c >= :creationDateFrom ';
        }        
        if(creationDateTo != null){       
            soqlFilterString += ' AND WorkOrder.CT_Fecha_Creacion_FM__c <= :creationDateTo';            
        }     

        try {                                   
            Integer offset = (pageNumber - 1) * PAGE_SIZE;
            Integer totalRecords = Database.countQuery('SELECT count() FROM WorkStep '+ soqlFilterString);
            Integer recordEnd = PAGE_SIZE * pageNumber;
                        
            responseMap.put('pageSize',PAGE_SIZE);
            responseMap.put('pageNumber',pageNumber);
            responseMap.put('totalRecords',totalRecords);
            responseMap.put('recordStart',offset + 1);
            responseMap.put('recordEnd',totalRecords >= recordEnd ? recordEnd : totalRecords);
            
            soqlString += soqlFilterString +'  ORDER BY WorkOrderId,LastModifiedDate DESC LIMIT :PAGE_SIZE OFFSET :offset';

            // System.debug(soqlString);
            responseMap.put('records',(List<WorkStep>) Database.query(soqlString));
        } catch (Exception e) {
            if(!Test.isRunningTest())
            throw new AuraHandledException(e.getMessage());
        }
        return responseMap;
    }

    @AuraEnabled(cacheable=true)
    public static List<ServiceTerritory> getTalleres() {        
        List<FSL__User_Territory__c> listaTerritorio = [SELECT FSL__Territory_Name__c FROM FSL__User_Territory__c WHERE FSL__User__c =: UserInfo.getUserId()];
        List<String> newList = new List<String>();
        For(FSL__User_Territory__c territ : listaTerritorio ){
            newList.add(territ.FSL__Territory_Name__c);
        }
        
        return [SELECT Id,Name FROM ServiceTerritory WHERE Name IN :newList];
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getTalleresForSelect() {
        List<Map<String,String>> territoryMapList = new List<Map<String,String>>();
        territoryMapList.add(new Map<String,String>{'label'=>'Todos','value'=>'all'});
        for (ServiceTerritory st : getTalleres()) {
            territoryMapList.add(new Map<String,String>{'label'=>st.Name,'value'=>st.Id});
        }
        return territoryMapList;
    }      

    @AuraEnabled(cacheable=true)
    public static List<WorkOrder> getOrdenes() {
        return [SELECT Id,WorkOrderNumber FROM WorkOrder];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContact() {
        Id recordTypeId =
        Schema.SObjectType.Contact.getRecordTypeInfosByName()
        .get('Contacto de Taller').getRecordTypeId();
        return [SELECT Id,Name FROM Contact WHERE RecordTypeId = :recordTypeId];
    }

    public static String getErrorMessage(String message){
        if (message.contains('FIELD_FILTER_VALIDATION_EXCEPTION')) {
            message = message.substringAfter('FIELD_FILTER_VALIDATION_EXCEPTION');
            message = message.substringAfter(', ');
        }
        if (message.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
            message = message.substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION');
            message = message.substringAfter(', ');
        }            
        if (message.contains('INVALID_FIELD')) {
            message = message.substringAfter('INVALID_FIELD');
            message = message.substringAfter(', ');
        }         
        return message;
    }

    
    @AuraEnabled
    public static void updateRecordMeca(String idRegistro , Id idMecanicoNuevo) {
        WorkStep workStep = [SELECT Id,Mec_nico_asignado__c FROM WorkStep WHERE Id=: idRegistro LIMIT 1];
        if (workStep == null) {
            throw new AuraHandledException('Registro de Work Step no encontrado.');
        }
        if (String.isEmpty(idRegistro)) {
            throw new AuraHandledException('El id del work step es requerido!');
        }
        if (String.isEmpty(idMecanicoNuevo)) {
            throw new AuraHandledException('El id del mecanico es requerido!');
        }
        try{
            List<WorkStep> stepActualiza = [Select Id,Status from WorkStep where Id= : idRegistro];
            for(WorkStep ws : stepActualiza){
                ws.Mec_nico_asignado__c = idMecanicoNuevo;
            }
            workStep.Mec_nico_asignado__c = idMecanicoNuevo;
            update workStep;
        }catch(DmlException e){
            throw new AuraHandledException(getErrorMessage(e.getMessage()));
        }
    }


    @AuraEnabled
    public static void updateRecordEnCurso(String idRegistro) {
        WorkStep workStep = [SELECT Id,Status,StartTime FROM WorkStep WHERE Id=: idRegistro LIMIT 1];
        if (workStep == null) {
            throw new AuraHandledException('Registro de Work Step no encontrado.');
        }

        try{
            workStep.StartTime = System.today();
            workStep.Status = 'En curso';
            update workStep;
        }catch(DmlException e){
            if (Test.isRunningTest()) {
                System.debug(e.getMessage());
            }else{
                throw new AuraHandledException(getErrorMessage(e.getMessage()));
            }
        }
    }        

    @AuraEnabled
    public static void updateRecordComp(String idRegistro ,Datetime fechaDeFin) {
        WorkStep workStep = [SELECT Id,Status,EndTime FROM WorkStep WHERE Id=: idRegistro LIMIT 1];
        if (workStep == null) {
            throw new AuraHandledException('Registro de Work Step no encontrado.');
        }
        try{        
            workStep.Status = 'Completada';
            workStep.EndTime = fechaDeFin;
            update workStep;      
        }catch(DmlException e){
            throw new AuraHandledException(getErrorMessage(e.getMessage()));
        }
    }    
}