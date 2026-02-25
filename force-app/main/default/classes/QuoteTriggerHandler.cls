/**
 * @description       : Apex trigger handler on Quote Object
 * @author            : marcohernandezhp@gmail.com
 * @group             : Redmotors
 * @last modified on  : 04-04-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
public without sharing class QuoteTriggerHandler extends TriggerHandler{

    public List<Quote> newRecordList{get;set;}
    public List<Quote> oldRecordList{get;set;}
    public Map<Id, Quote> newRecordMap{get;set;}
    public Map<Id, Quote> oldRecordMap{get;set;}

    public QuoteTriggerHandler() {
        this.newRecordList = (List<Quote>) Trigger.New;
        this.oldRecordList = (List<Quote>) Trigger.Old;
        this.newRecordMap = (Map<Id, Quote>) Trigger.newMap;
        this.oldRecordMap = (Map<Id, Quote>) Trigger.oldMap;                 
    }	

	public override void beforeInsert(){}	
	
	public override void beforeUpdate(){
		QuoteTriggerHelper.addExpirationDate(newRecordList);
		QuoteTriggerHelper.calculateTaxes(newRecordList);
	}
		
	public override void beforeDelete(){}
	
	public override void afterInsert(){
		QuoteTriggerHelper.setFriendlyQuoteName(newRecordMap);
	}	
	
	public override void afterUpdate(){		
		QuoteTriggerHelper.setSyncedQuoteIdOnOpportunity(newRecordList, oldRecordMap);
	}
	
	public override void afterDelete(){}
	
	public override void afterUndelete(){}
}