/**
 * @description       : 
 * @author            : Marco Hernandez
 * @group             : Redmotors
 * @last modified on  : 05-31-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
public with sharing class WorkStepController {    
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getWorkSteps(String territoryId,String serviceTypeId,String status,String caseNumber,String workOrderNumber,String plate,String vin,Date startDate,Date endDate,Boolean nested) {
            Id userId = UserInfo.getUserId();
            Map<String,Object> responseMap = WorkStepService.getWorkSteps(territoryId, serviceTypeId, status, caseNumber, workOrderNumber, plate, vin, startDate, endDate, null, nested);
            if(!(Boolean) responseMap.get('success')){                        
                throw new AuraHandledException((String)responseMap.get('message'));    
            }          
        return responseMap;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getTasksGroupedByCase(List<String> territoryIds,String mechanicId,List<String> statuses,String caseNumber,String orderNumber,String plate,String vin,Date creationDateFrom,Date creationDateTo, Integer pageNumber) {
            Id userId = UserInfo.getUserId();
            Map<String,Object> responseMap = WorkStepService.getTasksGroupedByCase(territoryIds, mechanicId, statuses, caseNumber, orderNumber, plate, vin, creationDateFrom, creationDateTo, userId, pageNumber);
            if(!(Boolean) responseMap.get('success')){                                          
                throw new AuraHandledException((String)responseMap.get('message'));
            }          
        return responseMap;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getWorkStepsForReports(List<String> territories,String mechanicId,String caseNumber,Date startDate, Date endDate,Boolean showParentTasks){
        return WorkStepService.getWorkStepsForReports(territories, mechanicId, caseNumber, startDate, endDate,showParentTasks);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ServiceTerritory> getTerritories() {        
        List<Map<String,String>> territoryMapList = new List<Map<String,String>>();
        
        List<Id> territoryIds = new List<Id>();
        for(FSL__User_Territory__c userTerritory : [SELECT FSL__ServiceTerritory__c FROM FSL__User_Territory__c WHERE FSL__User__c =: UserInfo.getUserId()] ){
            territoryIds.add(userTerritory.FSL__ServiceTerritory__c);
        }
        return [SELECT Id,Name FROM ServiceTerritory WHERE Id IN :territoryIds];
    }     

}