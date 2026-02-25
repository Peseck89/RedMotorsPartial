public with sharing class CT_VistaKanbanController {
    @AuraEnabled(cacheable=true)
    public static List<WorkStep> getInfoTallerEstado2(Boolean bolAnidado, String strEstado,String strTipo,String strDesde,String strHasta,String strOrden,String strVehiculo) {
        Id userId = UserInfo.getUserId();
        Id territorioUsuario = null;
        FSL__User_Territory__c usTerr = new FSL__User_Territory__c();
        try {
        usTerr = [Select FSL__ServiceTerritory__c From FSL__User_Territory__c
                                        Where FSL__User__c =: userId LIMIT 1];
        } catch (Exception e) {
        }
        if(usTerr != null){
            territorioUsuario = usTerr.FSL__ServiceTerritory__c;
        }
        if(strOrden != '%'){
            WorkOrder wo = [Select Id, WorkOrderNumber From WorkOrder Where Id =:strOrden];
            if(wo != null){
                strOrden = wo.WorkOrderNumber;
            }
        }
        if(strVehiculo != '%'){
            Asset asse = [Select Id, Name From Asset Where Id =:strVehiculo];
            if(asse != null){
                strVehiculo = asse.Name;
            }
        }
        Boolean bolAnidado2 = false;
        String fecha1 = strDesde + ' 00:00:00';
        Datetime dt = DateTime.valueOfGMT(fecha1);
        String fecha2 = strHasta + ' 24:59:00';
        Datetime dt2 = DateTime.valueOfGMT(fecha2);
        return [SELECT WorkOrder.ServiceTerritoryId, CT_Semaforo__c,CT_TieneSubtipo__c,CT_NombreOrdenDeTrabajo__c,CT_HorasTipoTrabajo__c, CT_TipoDeTrabajoDelCaso__c,
        CT_AsignadoA__c,WorkOrder.Status__c  ,CT_Tipo_de_Servicio__c,CT_AccountName__c,
        WorkOrder.WorkOrderNumber, Id, WorkOrderId,AcumuladoMinutosPausas__c,CT_PlacaId__c,
        Name,StartTime,EndTime,WorkOrder.MecanicoLider__c,Hora_de_inicio_de_pausa__c,
        WorkOrder.AssetId,WorkOrder.Asset.Name,WorkOrder.AccountNumber__c,WorkOrder.Id, 
        Status, Mec_nico_asignado__c,Mec_nico_asignado__r.Name,Total_de_tiempo_trabajado_en_minutos__c,
        CT_Placa__c,WorkOrder.CreatedDate,WorkOrder.Owner.Name,WorkOrder.Account.Name,WorkOrder.Tipo_de_servicio__c,
        Tipo_de_trabajo_del_caso__c, Tipo_de_trabajo_del_caso__R.Name,WorkOrder.Contact.Name,WorkOrder.ServiceTerritory.Name
        //,(select Cantidad_de_horas__c from Subtipos_de_trabajos_del_caso__r)	
        FROM WorkStep WHERE Status LIKE :strEstado AND WorkOrder.Tipo_de_servicio__c LIKE :strTipo 
        AND (CT_TieneSubtipo__c =: bolAnidado OR CT_TieneSubtipo__c =: bolAnidado2)  AND CT_Placa__c LIKE :strVehiculo AND WorkOrder.WorkOrderNumber LIKE :strOrden 
        AND CreatedDate >= :dt 
        AND WorkOrder.ServiceTerritoryId =: territorioUsuario
        AND CreatedDate <= :dt2 ORDER BY CREATEDDATE DESC];
    }

}