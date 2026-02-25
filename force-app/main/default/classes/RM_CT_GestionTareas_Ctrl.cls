public with sharing class RM_CT_GestionTareas_Ctrl {

    private static final Integer LIMIT_SIZE = 10;

    public static final Date START_DATE = RM_CT_Service.START_DATE;

    public static List<Case> getCases(String caseNumber, String caseId, String territoryId, Integer offsetSize) {

        String query = 'SELECT Id,CaseNumber,Service_Territory1__c,Service_Territory1__r.Name, Status, (SELECT Id, WorkOrderNumber,Status FROM WorkOrders) FROM Case';
        
        List<String> conditions = new List<String>();
    
        if (String.isNotBlank(caseNumber)) {
            conditions.add('CaseNumber = \'' + String.escapeSingleQuotes(caseNumber) + '\'');
        }

        if (String.isNotBlank(caseId)) {
            conditions.add('Id = \'' + String.escapeSingleQuotes(caseId) + '\'');
        }

        if (territoryId != null && territoryId != '') {
            conditions.add('Service_Territory1__c = \'' + String.escapeSingleQuotes(territoryId) + '\'');
        }
        
        // Agrega las condiciones a la consulta
        if (!conditions.isEmpty()) {
            query += ' WHERE ' + String.join(conditions, ' AND ');
        }
        
        // Agrega paginación a la consulta
        // query += ' LIMIT ' + LIMIT_SIZE;

        // if (offsetSize != null) {
        //     query += ' OFFSET ' + offsetSize;
        // }
        
        return Database.query(query);
    }

    @AuraEnabled(cacheable=true)
    public static List<RM_CaseWrapper> getData(String caseNumber, String caseId, String territoryId, Integer offsetSize) {
        //check if the caseNumber or caseId is not empty
        if (String.isBlank(caseNumber) && String.isBlank(caseId)) {
            throw new AuraHandledException('Se requiere el número de caso o el identificador del caso');
        }

        Map<Id,RM_CaseWrapper> caseWrappersMap = new Map<Id,RM_CaseWrapper>();
        //create a map with the work orders for each case
        Map<Id,RM_WorkOrderWrapper> workOrdersMap = new Map<Id,RM_WorkOrderWrapper>();
        for (Case c : getCases(caseNumber, caseId, territoryId, offsetSize)) {
            //create the RM_CaseWrapper for each Case
            RM_CaseWrapper caseWrapper = new RM_CaseWrapper(c);
            for (WorkOrder wo : c.WorkOrders) {
                RM_WorkOrderWrapper workOrderWrapper = new RM_WorkOrderWrapper(wo);
                caseWrapper.addWorkOrder(workOrderWrapper);
                workOrdersMap.put(wo.id,workOrderWrapper);
            }
            caseWrappersMap.put(c.Id,caseWrapper);
        }

        if (caseWrappersMap.isEmpty()) {
            return caseWrappersMap.values();
        }

        //get Trabajos y Subtrabajos
        Map<Id,RM_WorkStepWrapper> workStepWrapperMap = getTrabajosYSubtrabajos(caseWrappersMap);

        //add the RM_WorkStepWrapper to the RM_WorkOrderWrapper
        for (RM_WorkStepWrapper workStepWrapper : workStepWrapperMap.values()) {
            RM_WorkOrderWrapper workOrderWrapper = workOrdersMap.get(workStepWrapper.workOrderId);
            if (workOrderWrapper != null) {
                workOrderWrapper.addWorkStep(workStepWrapper);
            }
        }

        return caseWrappersMap.values();
    }

    @AuraEnabled
    public static Map<String,Object> reprocesarTrabajoYSubtrabajos(String ttcId,String sttcId) {

        Map<String,Object> responseMap = new Map<String,Object>{'success' => false};
        //validate ttcId is not null
        if (String.isBlank(ttcId)) {
            throw new AuraException('El trabajo es requerido');
        }
        
        try {
            //check if sttcId is not null, if it is not null, add the filter where Id = sttcId to the subquery
            String subQueryFilters = '';
            if (String.isNotBlank(sttcId)) {
                subQueryFilters = ' AND Id = :sttcId';
            }
            String query = 'SELECT Id, Name, RM_WorkOrder__r.WorkOrderNumber, RM_WorkOrder__c,Tipotrabajo__c, Caso__c, Caso__r.CaseNumber, ComentarioTTC__c, Status__c, Taller__c, Tipo_de_cargo__c, Horaa__c, Nombre_TTC__c, Plan_de_trabajo__c, Plan_creado__c, Total_de_horas__c, Paso_de_trabajo__c, Taller_Sucursal__c,RM_ModoTrabajo__c, RM_TipoTrabajoCaso__c, Paso_de_trabajo__r.Name, Paso_de_trabajo__r.WorkOrderId, Paso_de_trabajo__r.WorkOrderLineItemId, Paso_de_trabajo__r.Tipo_de_trabajo_del_caso__c, Paso_de_trabajo__r.WorkPlanId, (SELECT Id, Name, Paso_de_trabajo__c, Cantidad_de_horas__c, Mano_de_Obra__c, Paso_de_trabajo__r.Name, Paso_de_trabajo__r.WorkOrderId, Paso_de_trabajo__r.WorkOrderLineItemId, Paso_de_trabajo__r.Tipo_de_trabajo_del_caso__c, Paso_de_trabajo__r.WorkPlanId FROM Subtipos_de_trabajos_del_caso__r WHERE RM_SubtipoTrabajoCaso__c = null '+subQueryFilters+') FROM tiposDeTrabajoCaso__c WHERE Id = :ttcId';
            
            List<tiposDeTrabajoCaso__c> ttcs = Database.query(query);
            System.debug(ttcs);
            //verufy if the ttc exists
            if (ttcs.isEmpty()) {
                throw new AuraException('El trabajo no existe');
            }

            tiposDeTrabajoCaso__c ttc = ttcs[0];

            List<WorkPlan> workPlans = [SELECT Id, Conteo_de_pasos__c,ExecutionOrder, Name FROM WorkPlan WHERE WorkOrderId = :ttc.RM_WorkOrder__c];
            if (workPlans.isEmpty()) {
                //crear un plan de trabajo
                WorkPlan newWorkPlan = RM_CT_GestionTareas_Ctrl.createWorkPlan(ttcs[0]);
                INSERT newWorkPlan;
            }
            WorkPlan wp = workPlans[0];
            
            //create a new record from the ttc, we are going to reprocess the ttc but keeping the original ttc
            tiposDeTrabajoCaso__c newTTC = createTipoTrabajoCaso(ttc);
            insert newTTC;

            System.debug(newTTC);

            List<Subtipo_de_trabajo_del_caso__c> newSTCs = new List<Subtipo_de_trabajo_del_caso__c>();
            for (Subtipo_de_trabajo_del_caso__c stc : ttc.Subtipos_de_trabajos_del_caso__r) {
                newSTCs.add(createSubtipoTrabajoCaso(newTTC,stc));
            }

            if (newSTCs.size() > 0) {
                insert newSTCs;
            }

            responseMap.put('success', true);
            responseMap.put('message', 'El tipo de trabajo del caso ha sido reprocesado con éxito');

            return responseMap;
        } catch (DmlException e) {
            throw new AuraException(e.getMessage());
        } catch (Exception e) {
            throw new AuraException(e.getMessage());
        }
    }

    public static WorkPlan createWorkPlan(tiposDeTrabajoCaso__c ttc){
        WorkPlan wp = new WorkPlan(
            Name = 'Plan de trabajo para el Caso#' + ttc?.Caso__r?.CaseNumber + ', Order#',
            Caso__c = ttc.RM_WorkOrder__c,
            Description = ttc.Nombre_TTC__c,
            ExecutionOrder = 1,
            ParentRecordId = ttc.RM_WorkOrder__c,
            WorkOrderId = ttc.RM_WorkOrder__c
        );
        return wp;
    }

    private static tiposDeTrabajoCaso__c createTipoTrabajoCaso(tiposDeTrabajoCaso__c ttc){
        return  new tiposDeTrabajoCaso__c(
            Caso__c = ttc.Caso__c,
            // ComentarioTTC__c = ttc.ComentarioTTC__c,
            Horaa__c = ttc.Horaa__c,
            RM_ModoTrabajo__c = null,
            // Paso_de_trabajo__c = ttc.Paso_de_trabajo__c,
            Taller__c = ttc.Taller__c,
            Taller_Sucursal__c = ttc.Taller_Sucursal__c,
            Tipo_de_cargo__c = ttc.Tipo_de_cargo__c,
            Tipotrabajo__c = ttc.Tipotrabajo__c,
            RM_TipoTrabajoCaso__c = ttc.Id,
            RM_WorkOrder__c = ttc.RM_WorkOrder__c
        );
    }

    //create method to create subtrabajo
    private static Subtipo_de_trabajo_del_caso__c createSubtipoTrabajoCaso(tiposDeTrabajoCaso__c ttc,Subtipo_de_trabajo_del_caso__c sttc){
        return  new Subtipo_de_trabajo_del_caso__c(
            Caso__c = ttc.Caso__c,
            Name = sttc.Name,
            RM_SubtipoTrabajoCaso__c = sttc.Id,
            Cantidad_de_horas__c = sttc.Cantidad_de_horas__c,
            Tipo_de_trabajo_del_caso__c = ttc.Id,
            Mano_de_Obra__c = sttc.Mano_de_Obra__c
        );
    }


    private static Map<Id,RM_WorkStepWrapper> getTrabajosYSubtrabajos(Map<Id,RM_CaseWrapper> caseWrappersMap){
        //create the subtipo de trabajo del caso (RM_WorkStepWrapper)
        Map<Id,tiposDeTrabajoCaso__c> tipoDeTrabajoDelCasoMap = new Map<Id,tiposDeTrabajoCaso__c>([ 
            SELECT Id, Name, Tipotrabajo__r.Name, Status__c,
                Plan_de_trabajo__c, Total_de_horas__c, Paso_de_trabajo__c, RM_ModoTrabajo__c,
                 Caso__c, Caso__r.CaseNumber,
                FechaAlta__c, ComentarioTTC__c, Tipo_de_cargo__c, Taller__c,Paso_de_trabajo__r.RM_TotalHorasFX__c,
                Nombre_TTC__c, Plan_creado__c, Paso_de_trabajo__r.WorkOrderId, Paso_de_trabajo__r.WorkOrder.WorkOrderNumber, Paso_de_trabajo__r.Name, Paso_de_trabajo__r.Status,
                Paso_de_trabajo__r.RM_Mecanico__c, Paso_de_trabajo__r.RM_Mecanico__r.Name,
                Paso_de_trabajo__r.StartTime,Paso_de_trabajo__r.EndTime,Paso_de_trabajo__r.Total_de_tiempo_trabajado_en_minutos__c,RM_TipoTrabajoCaso__c,
                (
                    SELECT Id,Name, Caso__c, Caso__r.CaseNumber,
                        Paso_de_trabajo__c, Paso_de_trabajo__r.Name, Orden_de_trabajo__c, id_paso__c, Mano_de_Obra__c,Paso_de_trabajo__r.RM_TotalHorasFX__c,
                        Mecanico__c, Cantidad_de_horas__c, Paso_de_trabajo__r.Status,Paso_de_trabajo__r.RM_Mecanico__c, Tipo_de_trabajo_del_caso__r.RM_ModoTrabajo__c,
                        Paso_de_trabajo__r.RM_Mecanico__r.Name,Paso_de_trabajo__r.WorkOrderId,Paso_de_trabajo__r.WorkOrder.WorkOrderNumber,
                        Paso_de_trabajo__r.StartTime,Paso_de_trabajo__r.EndTime,Paso_de_trabajo__r.Total_de_tiempo_trabajado_en_minutos__c,RM_SubtipoTrabajoCaso__c,
                        Tipo_de_trabajo_del_caso__c
                    FROM Subtipos_de_trabajos_del_caso__r 
                    ORDER BY CreatedDate ASC
                )
            FROM tiposDeTrabajoCaso__c WHERE Caso__c IN :caseWrappersMap.keySet()
            ORDER BY CreatedDate ASC
            ]);

        //crea un mapa de RM_WorkStepWrapper para representar los tipos de trabajo del caso para los tiposDeTrabajoCaso__c
        Map<Id,RM_WorkStepWrapper> workStepWrapperMap = new Map<Id,RM_WorkStepWrapper>();
        for(tiposDeTrabajoCaso__c tipoDeTrabajoDelCaso : tipoDeTrabajoDelCasoMap.values()){
            RM_WorkStepWrapper workStepWrapper = new RM_WorkStepWrapper(tipoDeTrabajoDelCaso);
            //crea los subtipos de trabajo del caso (RM_WorkStepWrapper) para los subtipos de trabajo del caso
            for(Subtipo_de_trabajo_del_caso__c subtipoDeTrabajoDelCaso : tipoDeTrabajoDelCaso.Subtipos_de_trabajos_del_caso__r){
                RM_WorkStepWrapper subWorkStepWrapper = new RM_WorkStepWrapper(subtipoDeTrabajoDelCaso);
                workStepWrapper.addSubWorkStep(subWorkStepWrapper);
                if(tipoDeTrabajoDelCaso.RM_ModoTrabajo__c != null && tipoDeTrabajoDelCaso.RM_ModoTrabajo__c == 'Tarea padre'){
                    workStepWrapper.totalMinutosReales = subWorkStepWrapper.totalMinutosReales;
                }else{
                    workStepWrapper.totalMinutosReales += subWorkStepWrapper.totalMinutosReales;
                }
            }
            workStepWrapperMap.put(tipoDeTrabajoDelCaso.Id,workStepWrapper);
        }
        return workStepWrapperMap;
    }

    @AuraEnabled
    public static Map<String,Object> asignarMechanico(Id recordId, String mechanicId) {
        Map<String,Object> response = new Map<String,Object>{'success' => false};

        if (String.isBlank(recordId)) {
            throw new AuraHandledException('El identificador del registro es requerido');
        }

        if (String.isBlank(mechanicId)) {
            throw new AuraHandledException('El mecánico es requerido');
        }


        //Consultar Mecanico y Validar Si Existe
        List<Contact> mechanics = [SELECT Id FROM Contact WHERE Id = :mechanicId AND RecordType.DeveloperName LIKE 'Contacto_de_Taller' LIMIT 1];
        if (mechanics.isEmpty()) {
            throw new AuraHandledException('El mecánico no existe');
        }

        Schema.SObjectType objectType = recordId.getSObjectType();
        String objectName = objectType.getDescribe().getName();

        Set<Id> workStepIds = new Set<Id>();
        List<WorkStep> workStepsToUpdate = new List<WorkStep>();
        response.put('objectType',objectName);
        Boolean skipWorkStepTriggers = false;
        if(objectName.equals('WorkOrder')){
            List<WorkStep> workSteps = [SELECT Id,RM_Mecanico__c FROM WorkStep WHERE WorkOrderId = :recordId AND RM_Mecanico__c = null];
            for (WorkStep ws : workSteps) {
                ws.RM_Mecanico__c = mechanicId;
                workStepsToUpdate.add(ws);
            }
            skipWorkStepTriggers = true;
        }else if(objectName.equals('tiposDeTrabajoCaso__c')){
            List<tiposDeTrabajoCaso__c> trabajos = [SELECT Id,Paso_de_trabajo__c,
                                                        (
                                                            SELECT Id, Paso_de_trabajo__c,Paso_de_trabajo__r.RM_Mecanico__c
                                                            FROM Subtipos_de_trabajos_del_caso__r
                                                            WHERE Paso_de_trabajo__c != null AND Paso_de_trabajo__r.RM_Mecanico__c = null
                                                        )
                                                        FROM tiposDeTrabajoCaso__c 
                                                        WHERE Id = :recordId];

            if (trabajos.isEmpty()) {
                throw new AuraHandledException('El trabajo no existe');
            }
            tiposDeTrabajoCaso__c trabajo = trabajos[0];
            if (String.isBlank(trabajo.Paso_de_trabajo__c)) {
                throw new AuraHandledException('El trabajo no tiene relacionado el paso de trabajo');
            }

            if(String.isNotBlank(trabajo.Paso_de_trabajo__c)){
                workStepsToUpdate.add(new WorkStep(Id = trabajo.Paso_de_trabajo__c, RM_Mecanico__c = mechanicId));
            }
        }else if(objectName.equals('Subtipo_de_trabajo_del_caso__c')){
            List<Subtipo_de_trabajo_del_caso__c> subtrabajos = [SELECT Id, Paso_de_trabajo__r.Status,Paso_de_trabajo__c,Paso_de_trabajo__r.RM_Mecanico__c FROM Subtipo_de_trabajo_del_caso__c WHERE Id = :recordId];
            if (subtrabajos.isEmpty()) {
                throw new AuraHandledException('El subtrabajo no existe');
            }
            Subtipo_de_trabajo_del_caso__c subtrabajo = subtrabajos[0];
            if (String.isBlank(subtrabajo.Paso_de_trabajo__c)) {
                throw new AuraHandledException('El subtrabajo no tiene relacionado el paso de trabajo');
            }
            if (String.isNotBlank(subtrabajo.Paso_de_trabajo__r.RM_Mecanico__c)) {
                throw new AuraHandledException('El subtrabajo ya tiene un mecánico asignado');
            }

            workStepsToUpdate.add(new WorkStep(Id = subtrabajo.Paso_de_trabajo__c, RM_Mecanico__c = mechanicId));
        }

        if (workStepsToUpdate.isEmpty()){
            throw new AuraHandledException('No se encontraron pasos para asignar el mecánico');
        }

    try {
            if (skipWorkStepTriggers) {
                TriggerHandler.bypass('WorkStepTriggerHandler');
            }
            update workStepsToUpdate;
            if (skipWorkStepTriggers) {
                TriggerHandler.clearBypass('WorkStepTriggerHandler');
            }

            response.put('success', true);
            response.put('message', 'El mecánico ha sido asignado con éxito');
            return response;    
        } catch (DmlException e) {
            throw new AuraHandledException(e.getMessage());
        } catch(Exception e){
            throw new AuraHandledException('Error:'+e.getMessage());
        }
    }

    @AuraEnabled
    public static string reasignarMechanico(String workStepId, String mechanicId){
        //validate required parameters
        if (String.isBlank(workStepId) || String.isBlank(mechanicId)) {
            throw new AuraHandledException('Los parámetros workStepId y mechanicId son requeridos');
        }
        try {
            //query the workstep
            WorkStep ws = [SELECT Id, RM_Mecanico__c,Status FROM WorkStep WHERE Id = :workStepId];

            //validate if the workstep exists and if the mechanic is already assigned
            if (ws == null) {
                // throw new AuraHandledException('El trabajo no existe');
                System.debug('El trabajo no existe');
            }

            if (ws.Status != 'Nueva') {
                // throw new AuraHandledException('La tarea solo puede ser reasignada si está en estado Nueva');
                System.debug('La tarea solo puede ser reasignada si está en estado Nueva');
            }

            //assign the mechanic
            ws.RM_Mecanico__c = mechanicId;
            update ws;
            return 'El mecánico ha sido asignado con éxito';
        } catch (DmlException e) {
            System.debug('Error: ' + e.getMessage());
            //throw new AuraHandledException(e.getMessage());
        }
        catch (Exception e) {
            //throw new AuraHandledException(e.getMessage());
        }
        return '';
    }

    @AuraEnabled
    public static string updateWorkStepStatus(String workStepId, String status) {
        //validate required parameters
        if (String.isBlank(workStepId) || String.isBlank(status)) {
            throw new AuraHandledException('Los parámetros workStepId y status son requeridos');
        }
        try {
            //query the workstep
            WorkStep ws = [SELECT Id, RM_Mecanico__c, Status,Caso__c FROM WorkStep WHERE Id = :workStepId];

            //validate if the workstep exists and if the mechanic is already assigned
            if (ws == null) {
                throw new AuraHandledException('El trabajo no existe');
            }

            //assign the mechanic
            ws.Status = Status;
            update ws;

            if(ws.Status == RM_WorkStep_Helper.WORK_STEP_STATUS_IN_PROGRESS && ws.Caso__c != null){
                //actualizar el caso con el mecanico asignado
                Case caso = new Case(
                    Mecanico_Asignado__c = ws.RM_Mecanico__c,
                    Id = ws.Caso__c
                );
                UPDATE caso;
            }
            return 'Accion realizada con exito.';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String deleteTrabajo(String ttcId) {
        if (String.isBlank(ttcId)) {
            throw new AuraHandledException('El ttcId es requerido.');
        }
        try {
            List<tiposDeTrabajoCaso__c> ttcs = [SELECT Id,Paso_de_trabajo__c,(SELECT Id,Paso_de_trabajo__c FROM Subtipos_de_trabajos_del_caso__r ) FROM tiposDeTrabajoCaso__c WHERE Id = :ttcId];
            if (ttcs.isEmpty()) {
                throw new AuraHandledException('El trabajo no existe.');
            }

            //get the wokrsteps
            Set<Id> workStepIds = new Set<Id>();
            workStepIds.add(ttcs[0].Paso_de_trabajo__c);
            for (Subtipo_de_trabajo_del_caso__c sttc : ttcs[0].Subtipos_de_trabajos_del_caso__r) {
                workStepIds.add(sttc.Paso_de_trabajo__c);
            }

            if (!workStepIds.isEmpty()) {
                List<WorkStep> workSteps = [SELECT Id FROM WorkStep WHERE Id IN :workStepIds];
                if (!workSteps.isEmpty()) {
                    delete workSteps;
                }
            }
            
            delete ttcs;
            return 'El trabajo ha sido eliminado con éxito';
        } catch (DmlException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String deleteSubtrabajo(String sttcId) {
        if (String.isBlank(sttcId)) {
            throw new AuraHandledException('El ttcId es requerido.');
        }
        try {
            List<Subtipo_de_trabajo_del_caso__c> sttcs = [SELECT Id,Paso_de_trabajo__c FROM Subtipo_de_trabajo_del_caso__c WHERE Id = :sttcId];
            
            //get the wokrsteps
            Set<Id> workStepIds = new Set<Id>();
            workStepIds.add(sttcs[0].Paso_de_trabajo__c);

            if (!workStepIds.isEmpty()) {
                List<WorkStep> workSteps = [SELECT Id FROM WorkStep WHERE Id IN :workStepIds];
                if (!workSteps.isEmpty()) {
                    delete workSteps;
                }
            }

            if (sttcs.isEmpty()) {
                throw new AuraHandledException('El trabajo no existe.');
            }
            delete sttcs;
            return 'El subtrabajo ha sido eliminado con éxito';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchCases(String searchTerm, List<String> selectedIds, String firedElement, String objName, String displayedObjName, String icon) {
        List<LookupSearchResult> results = new List<LookupSearchResult>(); 
        Set<Id> relatedTerritoryIds = new Set<Id>(); 

        //filtrar la consulta por territorio
        for (FSL__User_Territory__c ut : [SELECT Id,FSL__ServiceTerritory__c FROM FSL__User_Territory__c WHERE FSL__User__c =:UserInfo.getUserId()  WITH SECURITY_ENFORCED]) {
            relatedTerritoryIds.add(ut.FSL__ServiceTerritory__c); 
        }

        if (relatedTerritoryIds.isEmpty() && !Test.isRunningTest()) {
            return results;
        }

        searchTerm = '%'+searchTerm+'%';     
        String query = 'SELECT Id,CaseNumber FROM Case WHERE Fecha_Creacion_FM__c > :START_DATE AND Service_Territory1__c IN:relatedTerritoryIds AND CaseNumber LIKE :searchTerm ORDER BY CaseNumber LIMIT 10';      
        for (Case c : (List<Case>) Database.query(query)) {
           String subtitle = 'Caso';
           String resultName = c.CaseNumber;
           results.add(new LookupSearchResult(c.Id, objName, icon, resultName, subtitle));
        }
        results.sort();
        return results;
    }

    // public static void dummy() {
    //     String test = '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    //      test += '';
    // }
}