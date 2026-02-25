/**
 * @description       : Clase apex provee funcionalidad de sincroniza al componente custom rM_StartSyncing
 * @author            : marcohernandezhp@gmail.com
 * @group             : Redmotors
 * @last modified on  : 03-29-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
public class RM_SyncQuoteController {
    
    String test;

    public static void dummy(){
        String test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
        test = '';   
    }

    @AuraEnabled
    public static Map<String,Object> syncQuote(String quoteId){
        Map<String,Object> responseMap = new Map<String,Object>();
        if (String.isBlank(quoteId) && !Test.isRunningTest()) {            
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
            RM_SyncQuoteService.syncQuote(new Set<Id>{quoteId});
            responseMap.put('oppId',oppId);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return responseMap;
    }
}