public with sharing class RM_CT_Service {

    public static final Date START_DATE = getStartDateFilter();
    public static final Integer PAGE_SIZE = 15;

    public static Set<Id> getAssignedTerritoryIds() {
        Set<Id> territoryIds = new Set<Id>(); 
        for (FSL__User_Territory__c ut : [SELECT Id,FSL__ServiceTerritory__c,FSL__User__c FROM FSL__User_Territory__c WHERE FSL__User__c = :UserInfo.getUserId()]) {
            territoryIds.add(ut.FSL__ServiceTerritory__c); 
        }
        return territoryIds;
    }

    public static Date getStartDateFilter() {
        Date startDate;
        String customLabelDate = Label.RM_FechaFiltroCT;
        
        if (String.isNotBlank(customLabelDate)) {
            try {
                return Date.valueOf(customLabelDate);
            } catch (Exception e) {
                System.debug('Invalid date format in custom label RM_FechaFiltroCT: ' + e.getMessage());
                startDate = Date.newInstance(1900, 01, 01);
            }
        } else {
            startDate = Date.newInstance(1900, 01, 01);
        }
        return startDate;
    }

}