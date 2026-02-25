@isTest(seeAllData = true)
public class OpportunityTriggerHandlerStages_test {
    static Integer iTotReg = 1;
    static Sucursal__c sucursal;
    static Campaign campanna;     
	static {

              
        
    }
    static testMethod void RTAsignadoDefecto() {
        
        test.startTest();
        	
        	List<Opportunity> lstOpp = [SELECT Id,Name,BMW_Comentarios__c, DescuentoAprobado__c ,entregado__c,StageName FROM Opportunity WHERE Id IN (SELECT OpportunityId From OpportunityLineItem  WHERE Descuentoporcentaje__c > 90) AND entregado__c = null AND StageName = 'Oportunidad Calificada'];
            for(Opportunity opp : lstOpp){
				opp.BMW_Comentarios__c = 'test';                        
            }
        	update lstOpp;
        	OpportunityTriggerHandlerStages oppStage = new OpportunityTriggerHandlerStages();
        	OpportunityTriggerHandlerStages.handleTrigger(lstOpp);

        test.stopTest();

    }
}