public without sharing class DataUploadController {

    @AuraEnabled
    public Static void initiateLeadImport()
    {
        System.debug('sendDataToAws');
        LeadAPIBatchCall.sendDataToAws();
    }

    @AuraEnabled
    public Static void initiateOpportunityImport()
    {
        System.debug('sendOpportunityDataToAws');
        OpportunityAPICall.sendOpportunityDataToAws();
    }
}