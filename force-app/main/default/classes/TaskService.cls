/**
	@Autor: David Leon Sanchez
	@Fecha creacion: 17/08/2017 
	@Proyecto: Altica
	@Proposito: Clase Service para el manejo del TaskTriggerHandler

**/

public class TaskService {
	
	//Metodo donde se buscan las Op que tengan el mismo Id de la lista recibida por parametro con el fin de actualizar el campo llamado UltimaModificacion__c
	public static void updateField(Set<Id> idsOp){
		List<Opportunity> listOp = new List<Opportunity>();

		if(idsOp.size() > 0){
			for(Opportunity op : [SELECT id, UltimaModificacion__c FROM Opportunity WHERE id IN : idsOp]){
				op.UltimaModificacion__c = System.now();
				listOp.add(op);
			}
			System.debug('*************************** List Op a modificar ******************** ' + listOp);
			if(!listOp.isEmpty()){
				Savepoint sp = Database.setSavepoint();
				try{
					TriggerHandler.bypass('OpportunityTriggerHandler');
					update listOp;
					TriggerHandler.clearBypass('OpportunityTriggerHandler');
				}catch(Exception e){
					System.debug(e);
					Database.rollback(sp);
				}
			}
		}
	}
}