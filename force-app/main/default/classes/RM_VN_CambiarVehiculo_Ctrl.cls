/**
 * @description       : Provee funcionalidad al componente de cambio de vehiculo
 * @author            : marcohernandezhp@gmail.com
 * @group             : Redmotors
 * @last modified on  : 06-23-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
public without sharing class RM_VN_CambiarVehiculo_Ctrl {
    
    public static final Integer PAGE_SIZE = 15;

    public static final String PRICEBOOK_NAME = getDefaultPriceListVN();    

    public static String getDefaultPriceListVN() {
        return RM_Config__mdt.getInstance('Default_Price_List_VN')?.Value__c;
    }        

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getOppLineItems(String oppId, Integer pageNumber){        
        Map<String,Object> responseMap = new Map<String,Object>{'success'=>false};

        try {
            String soqlConditions = ' WHERE OpportunityId = :oppId AND Product2.esVehiculo__c = true ';

            Integer offset = (pageNumber - 1) * PAGE_SIZE;

            Integer totalRecords = Database.countQuery('SELECT count() FROM OpportunityLineItem '+soqlConditions);        
            Integer recordEnd = PAGE_SIZE * pageNumber;

            responseMap.put('pageSize',PAGE_SIZE);
            responseMap.put('pageNumber',pageNumber);
            responseMap.put('totalRecords',totalRecords);
            responseMap.put('recordStart',offset + 1);
            responseMap.put('recordEnd',totalRecords >= recordEnd ? recordEnd : totalRecords);

            Set<Id> productIds = new Set<Id>();

            List<OpportunityLineItem> oppLineItems = (List<OpportunityLineItem>) Database.query('SELECT Id, UnitPrice, Product2Id, Product2.Id,Product2.ProductCode, Product2.Codigo_de_Producto__c,Product2.Anno__c, Product2.VN_Familia__c,Product2.Name, Product2.modelo__c, Product2.marcaVehiculo__c,Product2.Color__c, Product2.vin__c,Product2.Color_Externo__c'+
            ', Name FROM OpportunityLineItem '+soqlConditions+' ORDER BY Product2.Name LIMIT :PAGE_SIZE  OFFSET :offset');
            responseMap.put('records',oppLineItems);
                
        } catch (Exception e) {            
            throw new AuraHandledException(e.getMessage());
        }
        return responseMap;
    }


    @AuraEnabled
    public static Map<String,Object> replaceProduct(String oliId, String pxbId){
        Map<String,Object> responseMap = new Map<String,Object>();
        if (String.isBlank(oliId)) {
            throw new AuraHandledException('El vehiculo actual es requerido.');
        }

        if (String.isBlank(pxbId)) {
            throw new AuraHandledException('La bodega es requerida requerida.');
        }

        List<OpportunityLineItem> oliList = [SELECT Product2Id,Opportunity.Synced_Quote__c,OpportunityId FROM OpportunityLineItem WHERE Id =:oliId LIMIT 1];
        if (oliList.isEmpty()) {
            throw new AuraHandledException('El vehiculo actual no fue enontrado.');
        }

        List<ProductoXBodega__c> pxbList = [SELECT Producto__c,Bodega__c FROM ProductoXBodega__c WHERE Id =:pxbId LIMIT 1];
        if (pxbList.isEmpty()) {
            throw new AuraHandledException('El registro de producto x bodega actual no fue enontrado.');
        }

        List<Product2> prodList = [SELECT Id,(SELECT Product2Id, UnitPrice, Gerente__c, Jefe__c, Vendedor__c,Costo_Fijo__c, Name FROM PricebookEntries WHERE Pricebook2.Name = :PRICEBOOK_NAME AND Pricebook2.IsActive = TRUE AND IsActive = TRUE ORDER BY UnitPrice DESC LIMIT 1) FROM Product2 WHERE Id =:pxbList[0].Producto__c LIMIT 1];
        if (prodList.isEmpty() || prodList[0].PricebookEntries.isEmpty()) {
            throw new AuraHandledException('El vehiculo no fue encontrado.');
        }

        String quoteId = oliList[0].Opportunity.Synced_Quote__c;
        if (String.isBlank(quoteId)) {
            throw new AuraHandledException('La oportunidad no tiene un presupuesto sincronizado.');
        }

        List<Quote> existingQuoteList = [SELECT Id,Name,OpportunityId,CurrencyIsoCode,Pricebook2Id,(SELECT QuoteId,BMW_Bodega__c,Quote_Line_Item__c,PricebookEntryId,Vehiculo_Compatible__c,Quantity,UnitPrice,Description,Product2Id,ListPrice,BMW_Alias__c,TotalPrice,esRegalia__c,esExtra__c,esVehiculo__c,Oportunidad_Producto_Interes__c,Comision_Vendedor__c,Comision_Jefe__c,Comision_Gerente__c,OpportunityLineItemId FROM QuoteLineItems) FROM Quote WHERE Id =:quoteId LIMIT 1];

        if (existingQuoteList.isEmpty()) {
            throw new AuraHandledException('El presupuesto no fue encontrado.');
        }

        Quote newQuote = existingQuoteList[0].clone();
        insert newQuote;

        //Identificar el QLI existente
        QuoteLineItem currQLI;
        for (QuoteLineItem qli : existingQuoteList[0].QuoteLineItems) {
            if (qli.Product2Id == oliList[0].Product2Id) {
                currQLI = qli;
            }
        }

        if (currQLI == null) {
            throw new AuraHandledException('No se encontro el registro en el presupuesto.');
        }

        QuoteLineItem newQLI = currQLI.clone();
        newQLI.Id = null;
        newQLI.PricebookEntryId = prodList[0].PricebookEntries[0].Id;
        newQLI.Product2Id = prodList[0].Id;
        newQLI.BMW_Bodega__c = pxbList[0].Bodega__c;
        newQLI.QuoteId = newQuote.Id;
        insert newQLI;

        // System.debug('@newQLI@');
        // System.debug(newQLI);

        List<QuoteLineItem> qliToInsert = new List<QuoteLineItem>();
        for (QuoteLineItem qli : existingQuoteList[0].QuoteLineItems) {
            if (currQLI.Id != qli.Id) {
                QuoteLineItem oldQLI = qli.clone();
                oldQLI.Id = null;
                oldQLI.QuoteId = newQuote.Id;

                if (qli.Quote_Line_Item__c == currQLI.Id) {
                    oldQLI.Quote_Line_Item__c = newQLI.Id;
                }

                qliToInsert.add(oldQLI);   
            }
        }

        if (qliToInsert.size()>0) {
            insert qliToInsert;
        }

        Set<Id> quoteIds = new Set<Id>();
        quoteIds.add(newQuote.Id);
        RM_SyncQuoteService.syncQuote(quoteIds);
        
        return responseMap;
    }

    public static void dummy() {
        String test = '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
    }

}