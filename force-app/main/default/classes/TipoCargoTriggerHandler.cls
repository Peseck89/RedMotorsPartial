public class TipoCargoTriggerHandler
{
    public static void UpdateCurrencyISOCode(List<tipoCargo__c> tipoCargoList)
    {
        Set<String> woliSet = new Set<String>();
        List<WorkOrderLineItem> woliUpdateList = new List<WorkOrderLineItem>();
    
        for(tipoCargo__c rec : tipoCargoList)
        {
            if(rec.Work_Order_Line_Item__c != null)
                //rec.CurrencyIsoCode = rec.Work_Order_Line_Item__r.CurrencyIsoCode; 
                woliSet.add(rec.Work_Order_Line_Item__r.CurrencyIsoCode);
        }

        //if(woliUpdateList.size() > 0)
            //update woliUpdateList;
    }
    public static void UpdateCurrencyISOCode2(List<tipoCargo__c> tipoCargoList){
        Set<Id> WoliId = new Set<Id>();
        Map<Id,String> woliCurrency = new Map<Id,String>();
        for(tipoCargo__c rec : tipoCargoList)
        {
            if(rec.Work_Order_Line_Item__c != null){
                WoliId.add(rec.Work_Order_Line_Item__c);
            }
        }
        IF(WoliId.size()>0){
        List<WorkOrderLineItem> woliList = [Select Id,CurrencyIsoCode From WorkOrderLineItem Where Id IN: WoliId];
            for(WorkOrderLineItem woli : woliList){woliCurrency.put(woli.Id,woli.CurrencyIsoCode);
            }
            for(tipoCargo__c rec : tipoCargoList)
        	{
            	if(rec.Work_Order_Line_Item__c != null){rec.CurrencyIsoCode = woliCurrency.get(rec.Work_Order_Line_Item__c); 
            	}
        	}
        }
    }
    
    public static void UpdatePercentage(List<tipoCargo__c> tipoCargoList)
    {
        Set<String> woliSet = new Set<String>();
        List<WorkOrderLineItem> woliUpdateList = new List<WorkOrderLineItem>();
    
        for(tipoCargo__c rec : tipoCargoList) 
        {
            if(rec.Work_Order_Line_Item__c != null)
                woliSet.add(rec.Work_Order_Line_Item__c);
        }
        
        AggregateResult[] groupedResults = [SELECT Work_Order_Line_Item__c, SUM(porcentaje__c) 
                                            FROM tipoCargo__c
                                            WHERE Work_Order_Line_Item__c in : woliSet
                                            GROUP BY Work_Order_Line_Item__c];
         List<Object> woliList = new List<Object>();                 
        for (AggregateResult ar : groupedResults)  
        {
            if(ar.get('Work_Order_Line_Item__c') != null)
                woliUpdateList.add(new WorkOrderLineItem(Id = (String) ar.get('Work_Order_Line_Item__c'), 
                                                         porcentajeTiposDeCargo__c = (Decimal) ar.get('expr0')));
            if((Decimal) ar.get('expr0') >100){
                woliList.add(ar.get('Work_Order_Line_Item__c'));
            }
        }
        if(woliList.size()>0){
            for(tipoCargo__c rec : tipoCargoList){
                for(Object woli : woliList){
                    if(rec.Work_Order_Line_Item__c == woli){
                        rec.addError('La suma de todos los porcentajes de los tipos de cargo no puede ser mayor a 100');
                    }
                }
            }
        }
        else{
        	update woliUpdateList;
        }
    }
}