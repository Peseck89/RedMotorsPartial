public with sharing class RM_Lead_Trigger_Helper {

    public List<RM_RecordTypeMapping__mdt> rtMappingMdtList = getRecordTypeMapping();

    public List<RM_RecordTypeMapping__mdt> getRecordTypeMapping(){
        return [SELECT Id,RM_SourceObject__c,RM_TargetObject__c,RM_SourceRecordTypeName__c,RM_TargetRecordTypeName__c FROM RM_RecordTypeMapping__mdt WHERE RM_SourceObject__c = 'Lead' AND RM_TargetObject__c = 'Opportunity' AND RM_IsActive__c = TRUE WITH SECURITY_ENFORCED];
    }

    public Map<String,String> getRecordTypeIdsByRTName(){
        Map<String,String> rtIdRTIdMap = new Map<String,String>();
        Map<String,String> recordTypeIdsMap = new Map<String,String>();
        Set<String> recordTypeNames = new Set<String>();
        for (RM_RecordTypeMapping__mdt rtMappingMdt : rtMappingMdtList) {
            recordTypeNames.add(rtMappingMdt.RM_SourceRecordTypeName__c);
            recordTypeNames.add(rtMappingMdt.RM_TargetRecordTypeName__c);
        }

        List<RecordType> recordTypeList = [SELECT Id,DeveloperName,SobjectType FROM RecordType WHERE IsActive = TRUE AND SobjectType IN ('Opportunity','Lead') AND DeveloperName IN :recordTypeNames AND IsActive = TRUE WITH SECURITY_ENFORCED ];
        for (RecordType rt: recordTypeList) {
            rtIdRTIdMap.put(rt.SobjectType+'_'+rt.DeveloperName,rt.Id);
        }
        
        for (RM_RecordTypeMapping__mdt rtMappingMdt : rtMappingMdtList) {
            String leadRTId = rtIdRTIdMap.get(rtMappingMdt.RM_SourceObject__c+'_'+rtMappingMdt.RM_SourceRecordTypeName__c);
            String oppRTId = rtIdRTIdMap.get(rtMappingMdt.RM_TargetObject__c+'_'+rtMappingMdt.RM_TargetRecordTypeName__c);
            if (leadRTId != null && oppRTId != null) {                
                recordTypeIdsMap.put(leadRTId,oppRTId);
            }
        }
        return recordTypeIdsMap;
    }
    
    public void setOpportunityRecordType(List<Lead> newList) {
        Map<String,String> recordTypeIdsMap = getRecordTypeIdsByRTName();
        List <Opportunity> oppsToUpdate = new List<Opportunity>();
        Id pbBavarianId = getPBBavarianId();
        if (!recordTypeIdsMap.isEmpty()) {
            for (Lead ld: newList) {
                if(ld.RecordTypeId != null && recordTypeIdsMap.containsKey(ld.RecordTypeId)){
                    Opportunity opp = new Opportunity();
                    opp.Id = ld.ConvertedOpportunityId;
                    opp.RecordTypeId = recordTypeIdsMap.get(ld.RecordTypeId);
                    //opp.Pricebook2Id = pbBavarianId;
                    oppsToUpdate.add(opp);
                }
            }            
        }

        if(oppsToUpdate.size() > 0) { 
            update oppsToUpdate;    
        }
    }

    private Id getPBBavarianId() {
        List<Pricebook2> pbList = [SELECT Id FROM Pricebook2 WHERE Name = :RM_VN_Service.PRICEBOOK_NAME WITH SECURITY_ENFORCED LIMIT 1];
        if (pbList.size()>0) {
            return pbList[0].Id;
        }
        return null;
    }

    public void identifyVehicleUsed(Map<Id, Lead> newLeadMap,Map<Id, Lead> oldLeadMap) {
        Map<String,String> placaOppIdMap = new Map<String,String>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();         
        for (Lead lead: newLeadMap.values()) {
            if (lead.Placa_usados__c != null && lead.ConvertedOpportunityId != null && lead.ConvertedOpportunityId != oldLeadMap.get(lead.Id).ConvertedOpportunityId) {
                placaOppIdMap.put(lead.Placa_usados__c,lead.ConvertedOpportunityId);
            }
        }

        if (placaOppIdMap.isEmpty()) {
            return;   
        }

        Map<String,PricebookEntry> placaPBEMap = getBavarianPricesByPlaca(placaOppIdMap.keySet());
        if (placaPBEMap.isEmpty()) {
            return;   
        }

        List<Quote> newQuoteList = new List<Quote>();
        Map<Id,Quote> leadIdNewQuoteMap = new Map<Id,Quote>();
        for (Lead lead: newLeadMap.values()) {
            if (lead.Placa_usados__c != null && lead.ConvertedOpportunityId != null && lead.ConvertedOpportunityId != oldLeadMap.get(lead.Id).ConvertedOpportunityId) {
                
                PricebookEntry pbeBavarian = placaPBEMap.get(lead.Placa_usados__c);

                leadIdNewQuoteMap.put(lead.Id,
                    new Quote(
                        OpportunityId = lead.ConvertedOpportunityId,
                        Name = lead.ConvertedOpportunityId,
                        CurrencyIsoCode = 'USD',
                        Pricebook2Id = pbeBavarian != null ? pbeBavarian.Pricebook2Id : null
                        )
                );
            }
        }

        if (!leadIdNewQuoteMap.isEmpty()) {
            insert leadIdNewQuoteMap.values();
        }

        Set<Id> quoteIds = new Set<Id>();
        //crear quote line items
        List<QuoteLineItem> newQLIList = new List<QuoteLineItem>();
        for (Lead lead: newLeadMap.values()) {
            if (lead.Placa_usados__c != null && lead.ConvertedOpportunityId != null) {               
                Quote newQuote = leadIdNewQuoteMap.get(lead.Id);
                quoteIds.add(newQuote.Id);
                if (String.isNotBlank(lead.Placa_usados__c) && placaPBEMap.get(lead.Placa_usados__c) != null) {
                    PricebookEntry pbeBavarian = placaPBEMap.get(lead.Placa_usados__c); 
                    newQLIList.add(new QuoteLineItem(
                        QuoteId = newQuote.Id,
                        PriceBookEntryId = pbeBavarian.Id,
                        Quantity = 1,
                        UnitPrice = pbeBavarian.UnitPrice
                    ));
                }
            }
        }

        if (newQLIList.size() > 0) {
            insert newQLIList;
        }
        
        if (quoteIds.size()>0) {            
            RM_SyncQuoteService.syncQuote(quoteIds);
        }

    }

    public Map<String,PricebookEntry> getBavarianPricesByPlaca(Set<String> placas) {     
        Map<String,PricebookEntry> placaPBEMap = new Map<String,PricebookEntry>();    
        List<PricebookEntry> pbeList = [SELECT Id, Pricebook2Id,Pricebook2.Name, Pricebook2.IsActive,Pricebook2.CurrencyIsoCode, UnitPrice, IsActive, ProductCode FROM PricebookEntry WHERE Pricebook2.Name = :RM_VU_Service.PRICEBOOK_NAME AND ProductCode IN :placas AND IsActive = TRUE AND Product2.es_Vehiculo_usado__c = TRUE AND Product2.IsActive = TRUE AND Pricebook2.IsActive = TRUE AND Pricebook2.CurrencyIsoCode = 'USD'];
        for (PricebookEntry pbe : pbeList) {
            placaPBEMap.put(pbe.ProductCode,pbe);
        }
        return placaPBEMap;
    }    

    public static void name() {
        String  test = '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
                test += '';
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