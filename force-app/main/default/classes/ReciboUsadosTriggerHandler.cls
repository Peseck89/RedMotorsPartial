public class ReciboUsadosTriggerHandler extends TriggerHandler {

    private list<ReciboUsado__c> newReciboUsados;
    
    public ReciboUsadosTriggerHandler() {
        newReciboUsados  = (List<ReciboUsado__c>) Trigger.New;
    }
    
	public override void BeforeInsert(){
        /*
        List<ReciboUsado__c> listRUCarro = new List<ReciboUsado__c>();
		List<ReciboUsado__c> listRUMoto = new List<ReciboUsado__c>();

		for(ReciboUsado__c r : newReciboUsados){
			System.debug(' ** RECIBO USADO ** ' + r);
			if(r.RecordTypeId == '0120x000000RVngAAG'){
				listRUCarro.add(r);
			}else{
				listRUMoto.add(r);
			}
		}

		if(!listRUCarro.isEmpty() && listRUCarro.size() > 0){
			ReciboUsadoService.calculoRecibo(listRUCarro);
		}
		if(!listRUMoto.isEmpty() && listRUMoto.size() > 0){
			ReciboUsadoService.calculoScoreMotos(listRUMoto);
		}*/
		ReciboUsadoService.buscarRU(newReciboUsados);
		ReciboUsadoService.guardarDatosMayuscula(newReciboUsados);
    }
    
    public override void AfterInsert(){
        Set<Id> listRUCarro = new Set<Id>();
		Set<Id> listRUMoto = new Set<Id>();

		for(ReciboUsado__c r : newReciboUsados){
            System.debug(' ** Id Record Type ** ' + r.RecordTypeId);
			if(r.RecordTypeId == '0120P000000ESxJ'){
				listRUCarro.add(r.Id);
			}else{
				listRUMoto.add(r.Id);
			}
		}
		System.debug(' ** SIZE AUTOS ** ' + listRUCarro.size());
        System.debug(' ** SIZE MOTOS ** ' + listRUMoto.size());
		if(!listRUCarro.isEmpty() && listRUCarro.size() > 0){
			ReciboUsadoService.calculoRecibo(listRUCarro);
		}
		if(!listRUMoto.isEmpty() && listRUMoto.size() > 0){
			ReciboUsadoService.calculoScoreMotos(listRUMoto);
		}
    }

    public override void afterUpdate(){
        Set<Id> listRUCarro = new Set<Id>();
		Set<Id> listRUMoto = new Set<Id>();
        
        

		for(ReciboUsado__c r : newReciboUsados){
			if(r.RecordTypeId == '0120P000000ESxJ'){
				listRUCarro.add(r.Id);
			}else{
				listRUMoto.add(r.Id);
			}
            if(TRUE){
                ExternalServiceCallerController.sendDataFromTrigger(r.Id);
            }
		}
        
        Id recordTypeId1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Autos usados').getRecordTypeId();
		Id recordTypeId2 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Motos usados').getRecordTypeId();

        
        for(ReciboUsado__c r : newReciboUsados){
			if(!(r.Oportunidad__r.RecordTypeId == recordTypeId1 || r.Oportunidad__r.RecordTypeId == recordTypeId2) &&
              r.Oportunidad__r.StageName=='Oferta' &&
              r.Serecibevehiculo__c == TRUE && r.ReciboJefeUsados__c != NULL 
              ){
                ExternalServiceCallerController.sendDataFromTrigger(r.Id);
            }
		}

        
        
        
        
        

		if(!listRUCarro.isEmpty() && listRUCarro.size() > 0){
			ReciboUsadoService.calculoRecibo(listRUCarro);
		}
		if(!listRUMoto.isEmpty() && listRUMoto.size() > 0){ ReciboUsadoService.calculoScoreMotos(listRUMoto);
		}
        
        //Obtenemos la lista de OPS que tienen al menos 1 recibo de usados con el check de se recibe vehiculo
        list<String> opListIDs = new list<String>();
        //Mapa de Montos de Soporte de los recibos 
        map<Id, Decimal> montoSoporteMap = new map<Id, Decimal>();
        //Mapa que contiene la OP con su producto de mayor precio
        map<Id, OpportunityLineItem> opLineItemMap = new map<Id, OpportunityLineItem>();
        
        for(ReciboUsado__c r: newReciboUsados)
        {
           opListIDs.add(r.Oportunidad__c);
        }
        
        //**********************************************************************
        //Obtenemos la sumatoria de los montos de soporte de los recibos de usados de la OP
        //
        for(AggregateResult ar: [SELECT Oportunidad__c, SUM(MontoSoporte__c) FROM ReciboUsado__c
                                 WHERE Oportunidad__c IN: opListIDs AND Serecibevehiculo__c=true GROUP BY Oportunidad__c])
        {
            //Si el ID de una OP no existe en el mapa montoSoporteMap quiere decir que dicha OP NO posee ningun recibo usado o ningun recibo de usados que tenga el
            // check de recibe vehiculo por lo tanto el soporte en el producto debe de ser 0.
            // 
            Id opId = (Id)ar.get('Oportunidad__c');
            Decimal monto = (Decimal)ar.get('expr0');
            
            montoSoporteMap.put(opId, monto);

        }
        
        //**********************************************************************
        //Obtenemos el producto con el mayor precio
        for(OpportunityLineItem item: [Select Id, OpportunityId, Soporte__c From OpportunityLineItem Where OpportunityId IN: opListIDs
                                         Order By ListPrice DESC])
        {
           if(!opLineItemMap.containsKey(item.OpportunityId))
           {
              opLineItemMap.put(item.OpportunityId, item);
           }
        }
        
        if(opLineItemMap.size()>0)
        {
           for(OpportunityLineItem opItem: opLineItemMap.values())
           {
              if(montoSoporteMap.containsKey(opItem.OpportunityId))
              {
                  opItem.Soporte__c = montoSoporteMap.get(opItem.OpportunityId);
              }else{
                  opItem.Soporte__c = 0;
              }
           }
           
           TriggerHandler.bypass('OpportunityTriggerHandler');
           update opLineItemMap.values();
           TriggerHandler.clearBypass('OpportunityTriggerHandler');
 
        }//if(opLineItemMap.size()>0)
        
        //**********************************************************************
        
    }
    
}