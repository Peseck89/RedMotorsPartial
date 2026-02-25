/**
 * @description       : Crear un nuevo presupuesto apartir de la seleccion de inventario
 * @author            : marcohernandezhp@gmail.com
 * @group             : Redmotors
 * @last modified on  : 04-09-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/

public without sharing class RM_VN_QuoteController {

    @AuraEnabled
    public static List<Quote> getQuotes(String oppId){
        List<Quote> quoteList = [SELECT Id, Name FROM Quote WHERE OpportunityId =:oppId ORDER BY QuoteNumber ASC];
        return quoteList;        
    }

    @AuraEnabled
    public static Map<String,Object> addVehicle(String oppId,String oppProdIntId,String prodXBodegaId,String existingQuoteId){
        Map<String,Object> responseMap = QuoteService.addVehicle(oppId,oppProdIntId,prodXBodegaId,existingQuoteId);
        if (!((Boolean) responseMap.get('success'))) {
            throw new AuraHandledException(((String) responseMap.get('message')));   
        }
        return responseMap;        
    }

    @AuraEnabled
    public static Map<String,Object> addLineItem(String quoteId,String prodXBodId,String qliId,Boolean esRegalia,Boolean esExtra,String productType,String productAlias,Decimal productQuantity,Decimal productUnitPrice){
        Map<String,Object> responseMap = QuoteService.addLineItem(quoteId,prodXBodId,qliId,esRegalia,esExtra,productType,productAlias,productQuantity,productUnitPrice);
        if (!((Boolean) responseMap.get('success'))) {
            throw new AuraHandledException(((String) responseMap.get('message')));   
        }
        return responseMap;        
    }    
}