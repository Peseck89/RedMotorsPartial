/**
 * @description       : Apex trigger helper on Quote object
 * @author            : marcohernandezhp@gmail.com
 * @group             : Redmotors
 * @last modified on  : 04-04-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
public without sharing class QuoteTriggerHelper {

    /**
    * @description Actualiza el id del presupuesto sincronizado en la oportunidad
    * @author marcohernandezhp@gmail.com | 04-04-2023 
    * @param newRecordList Registros con los nuevos valores capturados en el trigger
    * @param oldRecordMap Mapa con los valores anteriores capturados en ele trigger
    **/
    public static void setSyncedQuoteIdOnOpportunity(List<Quote> newRecordList,Map<Id,Quote> oldRecordMap) {
        List<Opportunity> oppsToUptList = new List<Opportunity>();
        for (Quote currQuote : newRecordList) {
            if (currQuote.IsSyncing__c != oldRecordMap.get(currQuote.Id).IsSyncing__c && currQuote.IsSyncing__c) {
                oppsToUptList.add(new Opportunity(
                    Id = currQuote.OpportunityId,
                    Synced_Quote__c = currQuote.Id
                ));
            }
        }

        if (oppsToUptList.size()>0) {
            update oppsToUptList;
        }
    }    

    /**
    * @description Calcula el impuesto cuando la oportunidad relacioada al presupuesto no es de vehiculos nuevos
    * @author marcohernandezhp@gmail.com | 04-04-2023 
    * @param newRecordList Registros con los nuevos valores capturados en el trigger
    **/
    public static void calculateTaxes(List<Quote> newRecordList) {
        System.debug('Entro a calcular Tax');

        for (Quote currQuote : newRecordList) {

            if (currQuote.Flag_Vehiculo_Nuevo_FM__c || currQuote.Cliente_Exonerado__c ) {
                currQuote.Tax = 0;
                System.debug('no tax ' + currQuote.Tax);
            }
            else{
                currQuote.Tax = (currQuote.Subtotal * 0.13);
                System.debug('tax ' + currQuote.Tax);
            }
        }
    }

    /**
    * @description Agrega fecha de expiracion basado en la vigencia del presupuesto 30 dias,15 dias
    * @author marcohernandezhp@gmail.com | 04-04-2023 
    * @param newRecordList Registros con los nuevos valores capturados en el trigger
    **/
    public static void addExpirationDate(List<Quote> newRecordList) {
        for (Quote currQuote : newRecordList) {
            if (currQuote.Vegencia_del_presupuesto__c != null){
                if (currQuote.Vegencia_del_presupuesto__c == '30 Días') {
                    currQuote.ExpirationDate = Date.today().addDays(30);
                }else if (currQuote.Vegencia_del_presupuesto__c == '15 Días') {
                    currQuote.ExpirationDate = Date.today().addDays(15);
                }
            }
        }
    }  
    
    /**
    * @description Setea el nombre del presupuesto en formato PR-000000
    * @author marcohernandezhp@gmail.com | 04-04-2023 
    * @param newRecordMap Registros con los nuevos valores capturados en el trigger
    **/
    public static void setFriendlyQuoteName(Map<Id, Quote> newRecordMap) {
        List<Quote> quoteList = [SELECT Id,QuoteNumber FROM Quote WHERE Id IN :newRecordMap.KeySet()];
        for (Quote currQuote : quoteList) {
            currQuote.Name = 'PT-'+currQuote.QuoteNumber;
        }
        if (quoteList.size()>0) {            
            update quoteList;
        }
    }    
}