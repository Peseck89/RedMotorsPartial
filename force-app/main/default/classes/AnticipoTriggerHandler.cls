/**
 * @description       : Clase trigger handler del objeto Anticipo
 * @author            : marcohernandezhp@gmail.com
 * @group             : Remotors
 * @last modified on  : 05-18-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
public class AnticipoTriggerHandler extends TriggerHandler {

	public List<Anticipo__c> newRecordList;
    public Map<Id, Anticipo__c> newRecordMap;
    public List<Anticipo__c> oldRecordList;
    public Map<Id, Anticipo__c> oldRecordMap;

    public AnticipoTriggerHandler() {
        this.newRecordList = (List<Anticipo__c>) Trigger.New;
        this.newRecordMap = (Map<Id, Anticipo__c>) Trigger.newMap;
        this.oldRecordList = (List<Anticipo__c>) Trigger.Old;
        this.oldRecordMap = (Map<Id, Anticipo__c>) Trigger.oldMap;        
    }  
    
	public override void afterInsert(){
        VN_RQ106_OpportunityAnticipoSyncService.syncAfterInsert(newRecordList);
	}

    public override void afterUpdate(){
        VN_RQ106_OpportunityAnticipoSyncService.syncAfterUpdate(newRecordList, oldRecordMap);
    }

    public override void afterDelete(){
        VN_RQ106_OpportunityAnticipoSyncService.syncAfterDelete(oldRecordList);
    }

    public override void afterUndelete(){
        VN_RQ106_OpportunityAnticipoSyncService.syncAfterUndelete(newRecordList);
    }
}
