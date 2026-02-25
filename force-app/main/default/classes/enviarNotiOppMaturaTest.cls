@isTest(SeeAllData = true)
public with sharing class enviarNotiOppMaturaTest {
    static testmethod void testCalloutCellExpert(){
        Id clinicRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Cartera Madura').getRecordTypeId();
        List<Opportunity> lstOpp = [Select id From Opportunity WHERE RecordTypeId =: clinicRecordTypeId LIMIT 10];
        List<String> lstStr = new List<String>();
        for (Opportunity opp : lstOpp) {
            lstStr.add(opp.id);
        }
        
        enviarNotiOppMadura.enviarNoti(lstStr);
   }
}