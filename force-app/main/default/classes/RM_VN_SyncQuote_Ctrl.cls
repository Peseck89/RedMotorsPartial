public without sharing class RM_VN_SyncQuote_Ctrl {
    
    @AuraEnabled
    public static Map<String,Object> sync(String quoteId){
        Map<String,Object> responseMap = new Map<String,Object>();
        if (String.isBlank(quoteId)) {            
            throw new AuraHandledException('Se requiere el id del presupuesto.');
        }
        String oppId;
        List<Quote> quoteList = [SELECT Id,OpportunityId FROM Quote WHERE Id = :quoteId LIMIT 1];

        if (quoteList.isEmpty()) {
            throw new AuraHandledException('No se encontro el presupuesto.');
        }
        oppId = quoteList[0].OpportunityId;

        List<Opportunity> oppList = [SELECT Id,(SELECT Id FROM Anticipos__r WHERE Estatus__c != 'Cancelado' LIMIT 1) FROM Opportunity WHERE Id = :oppId LIMIT 1];
        if (oppList.isEmpty()) {
            throw new AuraHandledException('No se encontro la oportunidad.');
        }   
        
        if (oppList[0].Anticipos__r != null && oppList[0].Anticipos__r.size() > 0) {
            throw new AuraHandledException('La oportunidad no puede sincronizarse ya tiene relacionado un anticipo.');
        }

        try {            
            RM_VN_SyncQuote_Service.sync(new Set<Id>{quoteId});
            responseMap.put('oppId',oppId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return responseMap;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean hasRelatedPlanMttos(String quoteId){
        Map<String,Object> responseMap = new Map<String,Object>();
        if (String.isBlank(quoteId)) {            
            throw new AuraHandledException('El identificador del presupuesto es requerido.');
        }
        String oppId;
        List<Quote> quoteList = [SELECT Id,OpportunityId FROM Quote WHERE Id = :quoteId LIMIT 1];

        if (quoteList.isEmpty()) {
            throw new AuraHandledException('El presupuesto no fue encontrado.');
        }
        oppId = quoteList[0].OpportunityId;

        List<Opportunity> oppList = [SELECT Id,(SELECT Id FROM Planes_de_mantenimiento__r LIMIT 1) FROM Opportunity WHERE Id = :oppId LIMIT 1];
        if (oppList.isEmpty()) {
            throw new AuraHandledException('La oportunidad no fue encontrada.');
        } 
        
        return oppList[0].Planes_de_mantenimiento__r.size()>0;
    }
}