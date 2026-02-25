public with sharing class RM_MecanicoTaller_Trg_Handler extends TriggerHandler{
    private List<RM_MecanicoTaller__c> newRecordList{get;set;}
    private List<RM_MecanicoTaller__c> oldRecordList{get;set;}
    private Map<Id, RM_MecanicoTaller__c> newRecordMap{get;set;}
    private Map<Id, RM_MecanicoTaller__c> oldRecordMap{get;set;}

    public RM_MecanicoTaller_Trg_Handler () {
        this.newRecordList = (List<RM_MecanicoTaller__c>) Trigger.New;
        this.oldRecordList = (List<RM_MecanicoTaller__c>) Trigger.Old;
        this.newRecordMap = (Map<Id, RM_MecanicoTaller__c>) Trigger.newMap;
        this.oldRecordMap = (Map<Id, RM_MecanicoTaller__c>)  Trigger.oldMap;                      
    }

    public override void beforeInsert(){
        // setMecanicoTallerName();
        validarMecanicoTallerCombinacionUnica();
    }

    // private void setMecanicoTallerName(){
    //     Set<Id> mecanicoIds = new Set<Id>();
    //     Set<Id> tallerIds = new Set<Id>();
    //     for(RM_MecanicoTaller__c record : newRecordList){
    //         mecanicoIds.add(record.RM_Mecanico__c);
    //         tallerIds.add(record.RM_Taller__c);
    //     }

    //     Map<Id, Contact> mecanicoMap = new Map<Id, Contact>([SELECT Id,Name FROM Contact WHERE Id IN :mecanicoIds]);
    //     Map<Id, ServiceTerritory> tallerMap = new Map<Id, ServiceTerritory>([SELECT Id,Name FROM ServiceTerritory WHERE Id IN :tallerIds]);

    //     for(RM_MecanicoTaller__c record : newRecordList){
    //         record.Name = mecanicoMap.get(record.RM_Mecanico__c) + ' - ' + tallerMap.get(record.RM_Taller__c);
    //     }
    // }

    private void validarMecanicoTallerCombinacionUnica(){
        Set<Id> mecanicoIds = new Set<Id>();
        Set<Id> tallerIds = new Set<Id>();
        for(RM_MecanicoTaller__c record : newRecordList){
            mecanicoIds.add(record.RM_Mecanico__c);
            tallerIds.add(record.RM_Taller__c);

        }

        Set<String> mecanicoTallerSet = new Set<String>();
        List<RM_MecanicoTaller__c> records = [SELECT Id,RM_Mecanico__c,RM_Taller__c FROM RM_MecanicoTaller__c WHERE RM_Mecanico__c IN :mecanicoIds AND RM_Taller__c IN :tallerIds];
        for(RM_MecanicoTaller__c record : records){
            mecanicoTallerSet.add(record.RM_Mecanico__c + '-' + record.RM_Taller__c);
        }
        
        if(!records.isEmpty()){
            for(RM_MecanicoTaller__c record : newRecordList){
                if(mecanicoTallerSet.contains(record.RM_Mecanico__c + '-' + record.RM_Taller__c)){
                    record.addError('El mecánico ya se encuentra relacionado con el taller seleccionado.');
                }
            }
        }
    }
}