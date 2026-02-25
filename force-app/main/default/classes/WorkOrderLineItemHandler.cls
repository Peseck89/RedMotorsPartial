public class WorkOrderLineItemHandler {
    public static Boolean isFirstExecution = true;
    public static void updateSubtotal(List<WorkOrderLineItem> newWOLIs)
    {
        if(isFirstExecution)
        {
            List<WorkOrderLineItem> woLiUpdates = new List<WorkOrderLineItem>();
            Map<Id, WorkOrderLineItem> newWOLIsMap = new Map<Id, WorkOrderLineItem>(newWOLIs);
            List<tipoCargo__c> tipoCargos = [SELECT Work_Order_Line_Item__c, TotalMercaderia2__c,totalDescuento2__c,totalImpuesto2__c FROM tipoCargo__c WHERE Work_Order_Line_Item__c IN: newWOLIsMap.keySet()];
            Map<Id, List<tipoCargo__c>> tCargos = new Map<Id, List<tipoCargo__c>>();        
            for(Id key : newWOLIsMap.keySet())
            {
                tCargos.put(key, new List<tipoCargo__c>());
                System.debug('tCargos: ' + tCargos);
            }
            for(tipoCargo__c tCargo : tipoCargos)
            {
                tCargos.get(tCargo.Work_Order_Line_Item__c).add(tCargo);
            }        
            for(WorkOrderLineItem woLi : newWOLIsMap.values())
            {            
                Decimal totalMercaderia2 = 0;
                Decimal totalDescuento2 = 0;
                Decimal totalImpuesto2 = 0;
                for(tipoCargo__c tipoCargo : tCargos.get(woLi.Id))
                {
                    totalMercaderia2 += tipoCargo.TotalMercaderia2__c;
                    totalDescuento2 += tipoCargo.totalDescuento2__c;
                    totalImpuesto2 += tipoCargo.totalImpuesto2__c;
                    System.debug('tipoCargo: ' + tipoCargo);
                }
                woLi.Subtotal__c = totalMercaderia2; 
                woLi.Descuento__c = totalDescuento2; 
                woLi.ImpuestoReal__c = totalImpuesto2; 
                woLiUpdates.add(woLi);                
            }
            //update woLiUpdates;   
            isFirstExecution = false;
        }        
    }
}