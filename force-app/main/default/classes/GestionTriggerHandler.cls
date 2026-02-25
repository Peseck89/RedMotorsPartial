/**
    @Autor: David Leon Sanchez IS
    @Fecha creacion:  11/22/2019
    @Proyecto: Altica Gestiones 
**/

public class GestionTriggerHandler extends TriggerHandler{
	private Map<Id, Gestion__c> mapNewGestion;
    private List<Gestion__c> listNewGestion;
    
    private Map<Id, Gestion__c> mapOldGestion;
    private List<Gestion__c> listOldGestion;
    
    public GestionTriggerHandler(){
        this.mapNewGestion = (Map<Id, Gestion__c>)Trigger.newMap;
		this.listNewGestion = (List<Gestion__c>)Trigger.New;
        this.listOldGestion = (List<Gestion__c>)Trigger.Old;
        this.mapOldGestion = (Map<Id, Gestion__c>)Trigger.oldMap;
    }
    
    public override void afterInsert(){
		List<Gestion__c> listGestion = new List<Gestion__c>();
        
        for(Gestion__c g : listNewGestion){
            System.debug(' ** GESTION ** ' + g);
            if(g.RecordTypeId == Schema.SObjectType.Gestion__c.getRecordTypeInfosByName().get('Recibo Pago').getRecordTypeId() && g.Estado__c == 'Cerrada'){
                listGestion.add(g);
            }
        }
        if(!listGestion.isEmpty() && listGestion.size() > 0){
            System.debug(' ** GESTIONES ** ' + listGestion);
            GestionServices.enviarEmailCliente(listGestion[0].Id);
        }
    }
    
    /*public override void afterUpdate(){
		List<Gestion__c> listGestion = new List<Gestion__c>();
        
        for(Gestion__c g : listNewGestion){
            System.debug(' ** GESTION ** ' + g);
            if(g.RecordTypeId == '0120x000000QGnn'){
                listGestion.add(g);
            }
        }
        if(!listGestion.isEmpty() && listGestion.size() > 0){
            System.debug(' ** GESTIONES ** ' + listGestion);
            GestionServices.enviarEmailCliente(listGestion[0].Id);
        }
    }*/
}