public class ActualizarTipoCargo {
    
    public class FlowInput
    {        
        @InvocableVariable (required=true)
        public WorkOrder WO; 
    }
    
    @InvocableMethod(label='Actualizar Tipo de Cargo')
    public static void ActualizarRegistros(List<FlowInput> fi) 
    {  
        Map<Id, String> WosGasto = new Map<Id, String>();
        Map<Id, String> WosCurrency = new Map<Id, String>();
        for(FlowInput Input : fi)
        {
            WosGasto.put(Input.WO.Id, Input.WO.tipoDeGasto__c);
            WosCurrency.put(Input.WO.Id, Input.WO.CurrencyIsoCode);
        }
        Set<Id> WoIds = WosGasto.keySet();
        String facturado = 'Facturado';
        String Qry = 'SELECT Id, WorkOrderId,Estado__c FROM WorkOrderLineItem WHERE WorkOrderId IN: WoIds AND Estado__c !=\'' +facturado +'\'';
        List<WorkOrderLineItem> WoliRecords = Database.query(Qry);	 
        System.debug('WoliRecords '+WoliRecords);
        if(WoliRecords.size()>0){
            Map<Id, WorkOrderLineItem> WoliMap = new Map<Id, WorkOrderLineItem>(WoliRecords);
            System.debug(WoliMap);
            Set<Id> WoliIds = WoliMap.keySet();
                    System.debug('WoliIds '+WoliIds);

            Qry = 'SELECT Id, Work_Order_Line_Item__c, tipoCargo__c, CurrencyIsoCode FROM tipoCargo__c WHERE Work_Order_Line_Item__c IN: WoliIds';
            List<tipoCargo__c> tCargos = Database.query(Qry);
            System.debug('tcargos ' +tCargos);
            for(tipoCargo__c tCargo : tCargos)
            {
                tCargo.tipoCargo__c = WosGasto.get(WoliMap.get(tCargo.Work_Order_Line_Item__c).WorkOrderId) == 'Cliente' ? '1' 
                    : WosGasto.get(WoliMap.get(tCargo.Work_Order_Line_Item__c).WorkOrderId) == 'Interno' ? '2'
                        : WosGasto.get(WoliMap.get(tCargo.Work_Order_Line_Item__c).WorkOrderId) == 'Aseguradora' ? '3'
                            : WosGasto.get(WoliMap.get(tCargo.Work_Order_Line_Item__c).WorkOrderId) == 'Garantía' ? '4'
                                : WosGasto.get(WoliMap.get(tCargo.Work_Order_Line_Item__c).WorkOrderId) == 'BSI Interno' ? '6'
                                : WosGasto.get(WoliMap.get(tCargo.Work_Order_Line_Item__c).WorkOrderId) == 'BCI' ? '5': null;
                tCargo.CurrencyIsoCode = WosCurrency.get(WoliMap.get(tCargo.Work_Order_Line_Item__c).WorkOrderId);            
            }
            update tCargos;
            
            Qry = 'SELECT Id, CurrencyIsoCode, Orden_de_trabajo__c FROM Subtipo_de_trabajo_del_caso__c WHERE Orden_de_trabajo__c IN: WoIds';
            List<Subtipo_de_trabajo_del_caso__c> subtipoTrabajo = Database.query(Qry);
            for(Subtipo_de_trabajo_del_caso__c subtipo : subtipoTrabajo)
            {
                subtipo.CurrencyIsoCode = WosCurrency.get(subtipo.Orden_de_trabajo__c);
                System.debug('subtipo.CurrencyIsoCode: ' + subtipo.CurrencyIsoCode);
            }
            Update subtipoTrabajo;
        }
    }     
}