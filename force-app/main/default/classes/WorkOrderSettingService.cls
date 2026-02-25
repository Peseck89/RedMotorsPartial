public class WorkOrderSettingService {
    @AuraEnabled public WorkOrderSetting__mdt WorkOrderSetting;
    
    public WorkOrderSettingService(String developerName){
        this.WorkOrderSetting = getWorkOrderSettingByDeveloperName(developerName);
        
    }
    private WorkOrderSetting__mdt getWorkOrderSettingByDeveloperName(String developerName) {
        List<WorkOrderSetting__mdt> settings = [SELECT Id, DeveloperName, only_available_spare_parts__c
                                                FROM WorkOrderSetting__mdt
                                                WHERE DeveloperName = :developerName
                                                LIMIT 1];
        if (!settings.isEmpty()) {
            return settings[0];
        }
        return null;
    }
    
    public WorkOrderSetting__mdt getWorkOrderSetting(){
        return WorkOrderSetting;
    }
}