/**
 * @description       : 
 * @author            : marcohernandezhp@gmail.com
 * @group             : 
 * @last modified on  : 03-29-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
public with sharing class BMW_QuoteHandlerTrigger {
    public static  void handleTrigger(List<Quote> TriggerNew, List<Quote> TriggerOld,Map<Id, Quote> TriggerOldMap, System.TriggerOperation triggerEvent){
       switch on triggerEvent{
            when BEFORE_INSERT{
                beforeInsert(TriggerNew);
                // before(TriggerNew);
            } 
           when BEFORE_UPDATE{
                before(TriggerNew,TriggerOldMap);
            }            
       }
           
    }

    public static void before(List<Quote> TriggerNew,Map<Id, Quote> oldMap){
        Map<Id, Quote> quoteMap = new Map<Id, Quote>([SELECT Id,Opportunity.EsVehiculoNuevo__c FROM Quote WHERE Id IN :oldMap.keySet()]);
        for(Quote qte : TriggerNew){
            //Actualmente solo se tiene identificado el tipo vehiculos nuevos (BMW) como excepcion de impuestos
            //2023/02/27,
            if (!quoteMap.get(qte.Id).Opportunity.EsVehiculoNuevo__c) {                
                qte.Tax = (qte.TotalPrice/100)*13;
            }
        }
    }

    public static void beforeInsert(List<Quote> TriggerNew){
        List<Quote> quoteList = [Select Id From Quote];
        Integer count = quoteList.size();
        for(Quote qte : TriggerNew){
            count = count +1;
            qte.Name = 'PT-' + count;
            qte.ExpirationDate = date.today().addDays(15);
            if(qte.Vegencia_del_presupuesto__c == '30 Días'){
                qte.ExpirationDate = date.today().addDays(30);
            }
            if(qte.Vegencia_del_presupuesto__c == '15 Días'){
                qte.ExpirationDate = date.today().addDays(15);
            }
        }
    }
}