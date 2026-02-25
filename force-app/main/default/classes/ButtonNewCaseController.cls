public with sharing class ButtonNewCaseController {
    @AuraEnabled
    public static Boolean getUserIsAsesor() {
        User currentUser = [SELECT IsAsesor__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        system.debug('IsAsesor__c value: ' + currentUser.IsAsesor__c);
        system.debug('Id: ' + currentUser.Id);
        return currentUser.IsAsesor__c;
        
        

    }
}