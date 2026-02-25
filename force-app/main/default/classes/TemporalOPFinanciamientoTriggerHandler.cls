/*
	Creador: David Leon Sanchez (IS)
	Fecha: 17/11/207
	Cliente: Red Motor / Altica
*/

public class TemporalOPFinanciamientoTriggerHandler extends TriggerHandler{
    /*private Map<Id, TemporalOPFinanciamiento__c> newTOpFMap;
	private List<TemporalOPFinanciamiento__c> ListNewTOpsF;
	
	private Map<Id, TemporalOPFinanciamiento__c> MapOldTOppF;
	private List<TemporalOPFinanciamiento__c> ListOldTOppsF;
	
	public TemporalOPFinanciamientoTriggerHandler(){
		this.newTOpFMap = (Map<Id, TemporalOPFinanciamiento__c>) Trigger.newMap;
		this.ListNewTOpsF = (List<TemporalOPFinanciamiento__c>) Trigger.New;
		this.ListOldTOppsF = (List<TemporalOPFinanciamiento__c>) Trigger.Old;
		this.MapOldTOppF = (Map<Id, TemporalOPFinanciamiento__c>) Trigger.oldMap;	
	}
	
	public override void beforeInsert(){
		if(ListNewTOpsF.size() > 0){
			TemporalOPFinanciamientoService.crearTemporalOPF(ListNewTOpsF);
		}
	}
	
	public override void afterInsert(){
		System.debug('**** lista nueva ***** ' + ListNewTOpsF.size());
		//System.debug('**** lista vieja ***** ' + ListOldTOppsF.size());
		if(ListNewTOpsF.size() > 0){
			TemporalOPFinanciamientoService.crearOp(ListNewTOpsF);
		}
	}*/
}