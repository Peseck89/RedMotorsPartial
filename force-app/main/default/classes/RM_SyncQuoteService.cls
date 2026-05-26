/**
 * @description       : Clase que sincroniza un presupuesto con una oportunidad
 * @author            : marcohernandezhp@gmail.com
 * @group             : Redmotors
 * @last modified on  : 04-18-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
public without sharing class RM_SyncQuoteService {
    public static void syncQuote(Set<Id> quoteIds){
        
        if (quoteIds.size() > 0) {
            Map<Id,Quote> quoteMap = new Map<Id,Quote>([SELECT Id, OpportunityId, Opportunity.ConsecutivoOportunidad__c,IsSyncing__c,
                                        (SELECT Id,QuoteId, PricebookEntryId, OpportunityLineItemId, Quantity,UnitPrice, Discount, Product2Id, 
                                            ListPrice, Subtotal, Total_Extra__c,Total_Regalia__c,BMW_Alias__c, BMW_Bodega__c, BMW_CostoFijo__c, BMW_Disponibilidad__c,Comision_Vendedor__c,Comision_Jefe__c,Comision_Gerente__c, 
                                            BMW_Producto_Custom__c, BMW_TipoDeArticulo__c, esRegalia__c,Costo_Fijo_FM__c,TotalPrice,
                                            Quote_Line_Item__c, PricebookEntry.Costo_Fijo__c,FM_Vin__c,esExtra__c,Oportunidad_Producto_Interes__c FROM QuoteLineItems
                                        )
                                    FROM Quote WHERE Id IN :quoteIds]);

            Map<Id,OpportunityLineItem> qliIdOLIMap = new Map<Id,OpportunityLineItem>();
            Map<Id,QuoteLineItem> qliMap = new Map<Id,QuoteLineItem>();
            Set<Id> oppIds = new Set<Id>();
            List<Quote> quoteToUpdate = new List<Quote>();

            Map<Id,Decimal> oppIdMontoFijoMap = new Map<Id,Decimal>();
            Map<Id,Id> oppIdQuoteIdMap = new Map<Id,Id>();

            for (Quote quote : quoteMap.values()) {                
                quoteToUpdate.add(new Quote(Id = quote.Id,IsSyncing__c = true));
                oppIdQuoteIdMap.put(quote.OpportunityId,quote.Id);
                oppIds.add(quote.OpportunityId);
                Decimal costoFijoSoftland = 0;
                for (QuoteLineItem qli : quote.QuoteLineItems) {
                    if (qli.BMW_TipoDeArticulo__c != null && qli.BMW_TipoDeArticulo__c.toLowercase().contains('vehiculo')) {
                        Decimal montoFijo = oppIdMontoFijoMap.get(quote.OpportunityId);
                        montoFijo = montoFijo != null ? montoFijo : 0;
                        montoFijo += qli.Costo_Fijo_FM__c;
                        oppIdMontoFijoMap.put(quote.OpportunityId,montoFijo);
                        costoFijoSoftland = qli.PricebookEntry.Costo_Fijo__c;
                    }
                    
                    Decimal montoExtra = 0;
                    Decimal montoRegalia = 0;

                    qliMap.put(qli.Id,qli);
                    montoExtra += qli.Total_Extra__c != null ? qli.Total_Extra__c : 0;
                    montoRegalia += qli.Total_Regalia__c != null ?  qli.Total_Regalia__c : 0;

                    qliIdOLIMap.put(qli.Id,
                        new OpportunityLineItem(
                            OpportunityId = quote.OpportunityId,
                            Product2Id = qli.Product2Id,
                            Quantity = qli.Quantity,
                            TotalPrice = qli.TotalPrice,
                            Montodeextras__c = montoExtra,
                            Montoderegalias__c = montoRegalia,
                            esRegalia__c = qli.esRegalia__c,
                            esExtra__c = qli.esExtra__c,
                            Oportunidad_Producto_Interes__c = qli.Oportunidad_Producto_Interes__c,
                            Comision_Vendedor__c = qli.Comision_Vendedor__c,
                            Comision_Jefe__c = qli.Comision_Jefe__c,
                            Comision_Gerente__c = qli.Comision_Gerente__c,
                            PricebookEntryId = qli.PricebookEntryId,
                            Costo_Fijo__c = qli.Costo_Fijo_FM__c, //Fantacia
                            Costo_Fijo_Softland__c = costoFijoSoftland //Softland
                        )
                    );
                }
            }                                 
            
            List<Opportunity> newOppList = new List<Opportunity>();
            List<Opportunity> oppList = [SELECT Id, Total_Costo_Fijo__c, ConsecutivoOportunidad__c,Synced_Quote__c, SyncedQuoteId, (SELECT Id FROM OpportunityLineItems),(SELECT Id, IsSyncing__c FROM Quotes WHERE Id NOT IN :quoteIds) FROM Opportunity WHERE Id IN:oppIds];   
            List<OpportunityLineItem> oliToDelete = new List<OpportunityLineItem>();
            for (Opportunity opp : oppList) { 
                //opp.NombreProducto__c = opp.ConsecutivoOportunidad__c;
                opp.Total_Costo_Fijo__c = oppIdMontoFijoMap.get(opp.Id);
                opp.Synced_Quote__c = oppIdQuoteIdMap.get(opp.Id);
                opp.SyncedQuoteId = oppIdQuoteIdMap.get(opp.Id);
                
                for (Quote quote : opp.Quotes) {
                    quote.IsSyncing__c = false;
                    quoteToUpdate.add(quote);
                }
                oliToDelete.addAll(opp.OpportunityLineItems);
            }

            if (oliToDelete.size() > 0) {
                delete oliToDelete;
            }

            if (qliIdOLIMap.values().size() > 0) {
                insert qliIdOLIMap.values();
            }

            //update parents
            for (Id qliId : qliIdOLIMap.keySet()) {               
                QuoteLineItem qli = qliMap.get(qliId);
                if (qli.Quote_Line_Item__c != null) {   
                    OpportunityLineItem oli = qliIdOLIMap.get(qli.Id);                 
                    oli.Opportunity_Line_Item__c = qliIdOLIMap.get(qli.Quote_Line_Item__c).Id;
                }

                update qliIdOLIMap.values();
            }

            if (quoteToUpdate.size() > 0) {
                update quoteToUpdate;
            }            
            
            //actualizar opp
            if (oppList.size() > 0) {
                update oppList;
            }
        }
    }
}