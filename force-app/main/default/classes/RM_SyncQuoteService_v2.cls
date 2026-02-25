public without sharing class RM_SyncQuoteService_v2 {
    public static void syncQuote(Set<Id> quoteIds) {
        if (quoteIds.isEmpty()) {
            return; // Exit if there are no quotes to process
        }

        // Fetch all relevant Quote data in a single SOQL query
        Map<Id, Quote> quoteMap = new Map<Id, Quote>([
            SELECT Id, OpportunityId, Opportunity.ConsecutivoOportunidad__c, IsSyncing__c,
                (SELECT Id, QuoteId, PricebookEntryId, OpportunityLineItemId, Quantity, UnitPrice, Discount, Product2Id, 
                        ListPrice, Subtotal, Total_Extra__c, Total_Regalia__c, BMW_Alias__c, BMW_Bodega__c, BMW_CostoFijo__c, 
                        BMW_Disponibilidad__c, Comision_Vendedor__c, Comision_Jefe__c, Comision_Gerente__c, BMW_Producto_Custom__c, 
                        BMW_TipoDeArticulo__c, esRegalia__c, Costo_Fijo_FM__c, TotalPrice, Quote_Line_Item__c, 
                        PricebookEntry.Costo_Fijo__c, FM_Vin__c, esExtra__c, Oportunidad_Producto_Interes__c 
                 FROM QuoteLineItems
                )
            FROM Quote WHERE Id IN :quoteIds
        ]);

        // Initialize collections for processing
        Map<Id, OpportunityLineItem> qliIdOLIMap = new Map<Id, OpportunityLineItem>();
        Map<Id, QuoteLineItem> qliMap = new Map<Id, QuoteLineItem>();
        Set<Id> oppIds = new Set<Id>();
        List<Quote> quoteToUpdate = new List<Quote>();
        Map<Id, Decimal> oppIdMontoFijoMap = new Map<Id, Decimal>();
        Map<Id, Id> oppIdQuoteIdMap = new Map<Id, Id>();

        // Process Quotes and Quote Line Items
        for (Quote quote : quoteMap.values()) {
            quoteToUpdate.add(new Quote(Id = quote.Id, IsSyncing__c = true));
            oppIdQuoteIdMap.put(quote.OpportunityId, quote.Id);
            oppIds.add(quote.OpportunityId);
            Decimal costoFijoSoftland = 0;

            for (QuoteLineItem qli : quote.QuoteLineItems) {
                if (qli.BMW_TipoDeArticulo__c != null && qli.BMW_TipoDeArticulo__c.toLowerCase().contains('vehiculo')) {
                    Decimal montoFijo = oppIdMontoFijoMap.get(quote.OpportunityId);
                    montoFijo = montoFijo != null ? montoFijo : 0;
                    montoFijo += qli.Costo_Fijo_FM__c;
                    oppIdMontoFijoMap.put(quote.OpportunityId, montoFijo);
                    costoFijoSoftland = qli.PricebookEntry.Costo_Fijo__c;
                }

                Decimal montoExtra = qli.Total_Extra__c != null ? qli.Total_Extra__c : 0;
                Decimal montoRegalia = qli.Total_Regalia__c != null ? qli.Total_Regalia__c : 0;
                qliMap.put(qli.Id, qli);

                // Create Opportunity Line Item mapping
                qliIdOLIMap.put(qli.Id, new OpportunityLineItem(
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
                    Costo_Fijo__c = qli.Costo_Fijo_FM__c,
                    Costo_Fijo_Softland__c = costoFijoSoftland
                ));
            }
        }

        // Fetch Opportunities related to Quotes
        List<Opportunity> oppList = [SELECT Id, Total_Costo_Fijo__c, ConsecutivoOportunidad__c, Synced_Quote__c, 
                                        (SELECT Id FROM OpportunityLineItems),
                                        (SELECT Id, IsSyncing__c FROM Quotes WHERE Id NOT IN :quoteIds) 
                                     FROM Opportunity WHERE Id IN :oppIds];

        // Prepare Opportunity and related Quote updates
        List<OpportunityLineItem> oliToDelete = new List<OpportunityLineItem>();
        for (Opportunity opp : oppList) {
            opp.Total_Costo_Fijo__c = oppIdMontoFijoMap.get(opp.Id);
            opp.Synced_Quote__c = oppIdQuoteIdMap.get(opp.Id);

            for (Quote quote : opp.Quotes) {
                quote.IsSyncing__c = false;
                quoteToUpdate.add(quote);
            }
            oliToDelete.addAll(opp.OpportunityLineItems);
        }

        // Perform DML operations in bulk
        if (!oliToDelete.isEmpty()) {
            delete oliToDelete;
        }
        if (!qliIdOLIMap.isEmpty()) {
            insert qliIdOLIMap.values();
        }

        // Update parent-child relationships after initial insertion
        for (OpportunityLineItem oli : qliIdOLIMap.values()) {
            QuoteLineItem qli = qliMap.get(oli.Id);
            if (qli != null && qli.Quote_Line_Item__c != null) {
                oli.Opportunity_Line_Item__c = qliIdOLIMap.get(qli.Quote_Line_Item__c).Id;
            }
        }

        if (!qliIdOLIMap.isEmpty()) {
            update qliIdOLIMap.values();
        }

        if (!quoteToUpdate.isEmpty()) {
            update quoteToUpdate;
        }

        if (!oppList.isEmpty()) {
            update oppList;
        }
    }
}