public with sharing class cT_duplicarQuote {
    @AuraEnabled
    public static ID duplicarQuoteExacta(String PresupuestoId) {
    
        Quote newQuote = new Quote();

        if(PresupuestoId != null){
            Quote originQuote = [SELECT Id,AccountId,AdditionalAddress,AdditionalCity,AdditionalCountry,AdditionalGeocodeAccuracy,AdditionalLatitude
            ,AdditionalLongitude,AdditionalName,AdditionalPostalCode,AdditionalState,AdditionalStreet,BillingAddress,BillingCity,BillingCountry
            ,BillingGeocodeAccuracy,BillingLatitude,BillingLongitude,BillingName,BillingPostalCode,BillingState,BillingStreet,BMW_Advertencias__c
            ,BMW_CodigoDeProducto__c,BMW_Comentarios__c,BMW_CostoFijo__c,BMW_DescuentoGeneral__c,CanCreateQuoteLineItems,ContactId,ContractId
            ,CurrencyIsoCode,Description,Discount,Email,ExpirationDate,GrandTotal,Name,OpportunityId,Orden_De_Trabajo__c,Pricebook2Id,Phone
            ,QuoteNumber,QuoteToAddress,QuoteToCity,QuoteToCountry,QuoteToGeocodeAccuracy,QuoteToLatitude,QuoteToLongitude,QuoteToName,QuoteToPostalCode
            ,QuoteToState,QuoteToStreet,ShippingAddress,ShippingCity,ShippingCountry,ShippingGeocodeAccuracy,ShippingHandling,ShippingLatitude,ShippingLongitude
            ,ShippingName,ShippingPostalCode,ShippingState,ShippingStreet,Subtotal,Tax,TotalPrice
            FROM Quote WHERE Id = :PresupuestoId];
            
            newQuote = originQuote.clone(false,true,false,false);
            List<QuoteLineItem> originItems = [SELECT BMW_Alias__c,BMW_Bodega__c,BMW_CostoFijo__c,BMW_Dispinible__c,BMW_Disponibilidad__c,BMW_Producto_Custom__c
            ,BMW_TipoDeArticulo__c,CurrencyIsoCode,Description,Discount,Enviado_a_la_orden__c,LineNumber,ListPrice,OpportunityLineItemId,PricebookEntryId
            ,Product2Id,Quantity,ServiceDate,Subtotal,TotalPrice,UnitPrice
            FROM QuoteLineItem WHERE QuoteId = :PresupuestoId];
            Insert newQuote;
            List<QuoteLineItem> listNewQLI = new List<QuoteLineItem>();
            if(originItems.size()>0){
                for (QuoteLineItem itemActual : originItems) {
                    QuoteLineItem newQuoteItem = new QuoteLineItem();
                    //newQuoteItem = itemActual;
                    newQuoteItem.BMW_Alias__c = itemActual.BMW_Alias__c;
                    newQuoteItem.BMW_Bodega__c = itemActual.BMW_Bodega__c;
                    newQuoteItem.BMW_Dispinible__c = itemActual.BMW_Dispinible__c;
                    newQuoteItem.BMW_Disponibilidad__c = itemActual.BMW_Disponibilidad__c;
                    newQuoteItem.Description = itemActual.Description;
                    newQuoteItem.Discount = itemActual.Discount;
                    newQuoteItem.OpportunityLineItemId = itemActual.OpportunityLineItemId;
                    newQuoteItem.PricebookEntryId = itemActual.PricebookEntryId;
                    newQuoteItem.Product2Id = itemActual.Product2Id;
                    newQuoteItem.Quantity = itemActual.Quantity;
                    newQuoteItem.ServiceDate = itemActual.ServiceDate;
                    newQuoteItem.UnitPrice = itemActual.UnitPrice;
                    newQuoteItem.QuoteId = newQuote.Id;
                    listNewQLI.add(newQuoteItem);
                    //Insert newQuoteItem;
                }
                insert listNewQLI;
            }  
        }

        return newQuote.Id;
    }

}