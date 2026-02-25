/**
    @Autor: David Leon Sanchez
    @Fecha creacion:  
    @Proyecto: Altica
    @Proposito: Clase Service para el manejo del OportunidadFinancieraTriggerHandler

**/

public class OportunidadFinanciamientoService {
    
    //Metodo para actualizar campos en la Oportunidad cuando se le elimina la Oportunidad de Financiamiento
    public static void updateField(Set<Id> idsOp){
        List<Opportunity> listOp = new List<Opportunity>();

        System.debug('****************** list ids ******************' + idsOp);
        for(Opportunity op : [SELECT Consentimientofinaciero__c, OFCreada__c, (Select name From Oportunidades_de_Financiamiento1__r) FROM Opportunity WHERE Id IN:idsOp]){
            op.OFCreada__c = false;
            op.Consentimientofinaciero__c = false;
            op.EstadoOF__c = '';
            listOp.add(op);
        }
        System.debug('****************** op a update *******************' + listOp);
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
        System.debug('********************* op actualizada **********************' + listOp);
    }
    
    //Metodo para eliminar el trabajo programado guardado con el nombre de la Oportunidad de Financiamiento
    public static void deleteSchedulable(List<String> idsOF){
        List<String> names = new List<String>();
        List<Id> idsCJD = new List<Id>();

        System.debug('ID' + idsOF);
        for(CronJobDetail crd : [SELECT id FROM CronJobDetail WHERE name IN : idsOF]){
            idsCJD.add(crd.Id);
            System.debug('************************** lista ids CronJobDetail ************************ ' + idsCJD); 
        }
        for(CronTrigger ct : [SELECT id FROM CronTrigger WHERE CronJobDetailID IN : idsCJD]){
            System.debug('************************** lista ids CronTrigger ************************* ' + ct);
            System.abortJob(ct.Id);
        }
    }
    
    //Metodo donde actualiza el campo llamado Comentarios Altica en la Oportunidad ligada a la Oportunidad de Financiamiento
    public static void updateFieldOp(Map<Id, String> mapOf){
        System.debug('******************* MAPA OFS ************ ' + mapOf);
        List<Opportunity> listOp = new List<Opportunity>();

        for(Opportunity op : [SELECT Id, ComentariosAltica__c FROM Opportunity WHERE id IN : mapOf.keySet()]){
            System.debug('*************** OP **************** ' + op);
            op.ComentariosAltica__c = mapOf.get(op.Id);
            listOp.add(op);
        }
        System.debug('******************* LISTA OFS UPDATE ******** ' + listOp);
        if(listOp.size() > 0){
            TriggerHandler.bypass('OpportunityTriggerHandler');
            update listOp;
            TriggerHandler.clearBypass('OpportunityTriggerHandler');
        }
    }

	//Actualiza la prima en la oportunidad de negocio cuando se actualiza desde la oportunidad de financiamiento ligada 
	public static void updateFieldOpPrima(Map<Id, Double> mapOfPrima){
        System.debug('******************* MAPA OFS ************ ' + mapOfPrima);
        List<Opportunity> listOpUpdate = new List<Opportunity>();

        for(Opportunity op : [SELECT Id, ComentariosAltica__c FROM Opportunity WHERE id IN : mapOfPrima.keySet()]){
            System.debug('*************** OP **************** ' + op);
            op.Prima__c = mapOfPrima.get(op.Id);
            listOpUpdate.add(op);
        }
        System.debug('******************* LISTA OFS UPDATE ******** ' + listOpUpdate);
        if(listOpUpdate.size() > 0){
            TriggerHandler.bypass('OpportunityTriggerHandler');
            update listOpUpdate;
            TriggerHandler.clearBypass('OpportunityTriggerHandler');
        }
    }

	// Metodo para actualizar el tipo de registro de la cuenta de la oportunidad de negocio cuando dicha oportunidad se le crea una
	// oportunidad de financiamiento desde RM
	public static void updateRecordTypeAccount(Set<String> listTemp){
		String idTipoRegistroNuevo = '';
		Set<String> listIdsAccounts = new Set<String>();
		List<Opportunity> listOpp = new List<Opportunity>();
		List<Account> listAccountsUpdate = new List<Account>();

		idTipoRegistroNuevo = Schema.SObjectType.Account.getRecordTypeInfosByName().get('RedMotors-Altica').getRecordTypeId();
		System.debug('***** tipo registro  ****** ' + idTipoRegistroNuevo);
		listOpp = [SELECT AccountId FROM Opportunity WHERE Id IN : listTemp];
		for(Opportunity op : listOpp){
			listIdsAccounts.add(op.AccountId);
		}
		listAccountsUpdate = [SELECT RecordTypeId FROM Account WHERE Id IN : listIdsAccounts];
		for(Account act : listAccountsUpdate){
			act.RecordTypeId = idTipoRegistroNuevo;
		}
		System.debug('****** cuenta update ***** ' + listAccountsUpdate);
		TriggerHandler.bypass('AccountTriggerHandler');
		update listAccountsUpdate;
		TriggerHandler.clearBypass('AccountTriggerHandler');
	}

	//Metodo para buscar si un cliente posee una oportunidad de financiamiento
	//Entra al metodo cuando se actualiza el estado de la oportunidad de financiamiento
	public static Boolean BuscarOpFs(String idOpF, String idTemp, Integer accion){
		List<Opportunity> listOp = new List<Opportunity>();
		System.debug('**** entro al metodo ***** ');
		if(accion == 1){
			listOp = [SELECT Id FROM Opportunity WHERE AccountId =: idTemp];	
			Oportunidad_de_Financiamiento__c[] listOpF = [SELECT Name, Oportunidad__c FROM Oportunidad_de_Financiamiento__c 
															WHERE Oportunidad__c IN : listOp AND Estado__c =: 'Aprobada'];
			System.debug('***** oportuFinan aprobadas ***** ' + listOpF);
			if(listOpF.size() > 0){
				if(listOpF.size() == 1 && listOpF[0].Id == idOpF){
					return false;
				}else{
					return true;
				}
			}
		}else{
			System.debug('****** id cliente ****** ' + idTemp);
			Oportunidad_de_Financiamiento__c[] listOpF = [SELECT Id, Name FROM Oportunidad_de_Financiamiento__c 
															WHERE Nombre_Cliente_Altica__c =: idTemp AND Estado__c =: 'Aprobada'];
			System.debug('***** oportuFinan aprobadas ***** ' + listOpF);
			if(listOpF.size() > 0){
				if(listOpF.size() == 1 && listOpF[0].Id == idOpF){
					return false;
				}else{
					return true;
				}
			}
		}
		return false;
	}

	//Metodo para llevar el conteo de las oportunidades de financiamiento por campaña.
	// El conteo se lleva en el objeto campaña
	//Metodo solo para cuando es la primera vez que se le cambia el estado a la opF
	public static void campaignAdd(Map<String, String> mapCampaign){
		List<Campaign> listCampaignUpdate = new List<Campaign>();
		String idTipoRegistro;

		idTipoRegistro = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Campaña Altica').getRecordTypeId();
		System.debug('***** mapa campanas **** ' + mapCampaign);
		for(Campaign cm : [SELECT Id, Name, Cantidad_OpFi_Aprobada__c, Cantidad_OpFi_Condicionadas__c, Cantidad_OpFi_Denegadas__c FROM Campaign WHERE RecordType.Id =: idTipoRegistro]){
			System.debug('**** mapa select **** ' + cm);
			if(mapCampaign.containsKey(cm.Id)){
				if(mapCampaign.get(cm.Id) == 'Aprobada'){
					if(cm.Cantidad_OpFi_Aprobada__c == null){
						cm.Cantidad_OpFi_Aprobada__c = 1;
					}else{
						cm.Cantidad_OpFi_Aprobada__c = cm.Cantidad_OpFi_Aprobada__c + 1;
					}
				}else if(mapCampaign.get(cm.Id) == 'Condicionada'){
					if(cm.Cantidad_OpFi_Condicionadas__c == null){
						cm.Cantidad_OpFi_Condicionadas__c = 1;
					}else{
						cm.Cantidad_OpFi_Condicionadas__c = cm.Cantidad_OpFi_Condicionadas__c + 1;
					}
				}else{
					if(cm.Cantidad_OpFi_Denegadas__c == null){
						cm.Cantidad_OpFi_Denegadas__c = 1;
					}else{
						cm.Cantidad_OpFi_Denegadas__c = cm.Cantidad_OpFi_Denegadas__c + 1;
					}
				}
				listCampaignUpdate.add(cm);
			}
		}
		System.debug('*** lista update campanas *** ' + listCampaignUpdate);
		if(listCampaignUpdate.size() > 0 ){
			try{
				update listCampaignUpdate;
			}catch(DmlException ex){
				System.debug(' ** error al actualizar el conteo de opF por campanna ** ' + ex.getMessage());
			}
		}
	}

	//Metodo para llevar el conteo de las oportunidades de financiamiento por campaña.
	// El conteo se lleva en el objeto campaña
	//Metodo solo para cuando es la segunda o mas veces que se le cambia el estado a la opF
	public static void campaignDesc(Map<String, String> mapCampaign){
		List<Campaign> listCampaignUpdate = new List<Campaign>();
		String idTipoRegistro;

		idTipoRegistro = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Campaña Altica').getRecordTypeId();
		for(Campaign cm : [SELECT Id, Name, Cantidad_OpFi_Aprobada__c, Cantidad_OpFi_Condicionadas__c, Cantidad_OpFi_Denegadas__c FROM Campaign WHERE RecordType.Id =: idTipoRegistro]){
			System.debug('**** mapa select **** ' + cm);
			if(mapCampaign.containsKey(cm.Id)){
				if(mapCampaign.get(cm.Id) == 'Aprobada'){
					if(cm.Cantidad_OpFi_Aprobada__c > 0){
						cm.Cantidad_OpFi_Aprobada__c = cm.Cantidad_OpFi_Aprobada__c - 1;
					}
				}else if(mapCampaign.get(cm.Id) == 'Condicionada'){
					if(cm.Cantidad_OpFi_Condicionadas__c > 0){
						cm.Cantidad_OpFi_Condicionadas__c = cm.Cantidad_OpFi_Condicionadas__c - 1;
					}
				}else{
					if(cm.Cantidad_OpFi_Denegadas__c > 0){
						cm.Cantidad_OpFi_Denegadas__c = cm.Cantidad_OpFi_Denegadas__c - 1;
					}
				}
				listCampaignUpdate.add(cm);
			}
		}
		System.debug('*** lista update campanas *** ' + listCampaignUpdate);
		if(listCampaignUpdate.size() > 0 ){
			try{
				update listCampaignUpdate;
			}catch(DmlException ex){
				System.debug(' ** error al actualizar el conteo de opF por campanna ** ' + ex.getMessage());
			}
		}
	}
}