/**
    @Autor: David Leon Sanchez
    @Fecha creacion:  
    @Proyecto: Altica
    @Proposito: TriggerHandler para el manejo del OportunidadFinanciamientoService 
**/

public class OportunidadFinanciamientoTriggerHandler extends TriggerHandler{
    
    private Map<Id, Oportunidad_de_Financiamiento__c> newOpFMap;
    private List<Oportunidad_de_Financiamiento__c> ListNewOpsF;
    
    private Map<Id, Oportunidad_de_Financiamiento__c> MapOldOppF;
    private List<Oportunidad_de_Financiamiento__c> ListOldOppsF;
    
    public OportunidadFinanciamientoTriggerHandler() {
        this.newOpFMap = (Map<Id, Oportunidad_de_Financiamiento__c>) Trigger.newMap;
        this.ListNewOpsF = (List<Oportunidad_de_Financiamiento__c>) Trigger.New;
        this.ListOldOppsF = (List<Oportunidad_de_Financiamiento__c>) Trigger.Old;
        this.MapOldOppF = (Map<Id, Oportunidad_de_Financiamiento__c>) Trigger.oldMap;                   
    }

	public override void afterInsert(){
		Set<String> listIdsOp = new Set<String>();
		String idTipoRegistro = '';

		System.debug('**** oportunidad financiera *** ' + ListNewOpsF);
		idTipoRegistro = Schema.SObjectType.Oportunidad_de_Financiamiento__c.getRecordTypeInfosByName().get('RedMotors-Altica').getRecordTypeId();
		System.debug('**** tipo registro **** ' + idTipoRegistro);
		for(Oportunidad_de_Financiamiento__c opF : ListNewOpsF){
			if(opF.RecordTypeId == idTipoRegistro){
				listIdsOp.add(opF.Oportunidad__c);
			}
		}
		System.debug('***** lista ***** ' + listIdsOp);
		if(listIdsOp.size() > 0){
			OportunidadFinanciamientoService.updateRecordTypeAccount(listIdsOp);
		}
	}

   //Metodo donde se obtiene la informacion para los metodos updateField y deleteSchedulable
    public override void afterDelete(){
        Set<Id> idsOp = new Set<Id>();
        List<String> idsOpF = new List<String>();

        System.debug('*************************** lista vieja *************************' + ListOldOppsF);
        for(Oportunidad_de_Financiamiento__c opF : ListOldOppsF){
            System.debug('********************entro al for *********************' + opF);
            idsOp.add(opF.Oportunidad__c);
            idsOpF.add(opF.Name);
            System.debug('***************************** lista de id op **************************' + idsOp);
        }
        System.debug('************************ salio del for *****************');
        System.debug('********************************* lista ids Op ************************' + idsOp);
        if(!idsOp.isEmpty() && !idsOpF.isEmpty()){
            OportunidadFinanciamientoService.updateField(idsOp);
            OportunidadFinanciamientoService.deleteSchedulable(idsOpF);
        }
    }
	
	//Metodo donde se obtiene la información para los metodos llamados deleteSchedulable y updateFieldOp
    public override void afterUpdate(){
		Id idTipoRegistroCompartido, idTipoRegistroAltica;
        List<String> names = new List<String>();
        Map<Id, String> mapOf = new Map<Id, String>();
		Map<Id, Double> mapOfPrima = new Map<Id, Double>();
		Map<String, String> mapCampaignAlticaAdd = new Map<String, String>();
		Map<String, String> mapCampaignAlticaDesc = new Map<String, String>();

		idTipoRegistroCompartido = Schema.SObjectType.Oportunidad_de_Financiamiento__c.getRecordTypeInfosByName().get('RedMotors-Altica').getRecordTypeId();
		idTipoRegistroAltica = Schema.SObjectType.Oportunidad_de_Financiamiento__c.getRecordTypeInfosByName().get('Altica').getRecordTypeId();
        for(Oportunidad_de_Financiamiento__c opF : ListNewOpsF){
            if(opF.Estado__c != MapOldOppF.get(opF.Id).Estado__c){
                names.add(opF.Name);
            }
            if(opF.ComentariosAltica__c != MapOldOppF.get(opF.Id).ComentariosAltica__c){
            	mapOf.put(opF.Oportunidad__c, opF.ComentariosAltica__c);
            }
			if(ListOldOppsF[0].Prima_Altica__c != ListNewOpsF[0].Prima_Altica__c && ListNewOpsF[0].RecordTypeId == idTipoRegistroCompartido){
				mapOfPrima.put(opF.Oportunidad__c, opF.Prima_Altica__c);
			}
		}
        if(!names.isEmpty()){
            OportunidadFinanciamientoService.deleteSchedulable(names);
        }
        if(!mapOf.isEmpty()){
        	OportunidadFinanciamientoService.updateFieldOp(mapOf);
        }
		if(!mapOfPrima.isEmpty()){
			OportunidadFinanciamientoService.updateFieldOpPrima(mapOfPrima);
		}

		//Logica para llevar el conteo de opF por campaña
		for(Oportunidad_de_Financiamiento__c opF : ListNewOpsF){
			System.debug(' ** estado opF ** ' + opF.Estado__c);
			if(opF.Estado__c != NULL && ListOldOppsF[0].Estado__c == NULL){//validacion cuando es la primera vez que cambia el estado de la OpF
				mapCampaignAlticaAdd.put(opF.Campana_Altica__c, opF.Estado__c);
			}else if(opF.Estado__c != NULL && ListOldOppsF[0].Estado__c != NULL){//validacion cuando es la segunda o mas veces que cambia el estado de la opF
				mapCampaignAlticaAdd.put(opF.Campana_Altica__c, opF.Estado__c);
				mapCampaignAlticaDesc.put(opF.Campana_Altica__c, ListOldOppsF[0].Estado__c);
			}
		}
		System.debug(' ** campanna add ** ' + mapCampaignAlticaAdd.values());
		System.debug(' ** campanna des ** ' + mapCampaignAlticaDesc.values());
		if(mapCampaignAlticaAdd.size() > 0 ){//Metodo para el conteo en el objeto campaña
			System.debug('**** metod true **** ');
			OportunidadFinanciamientoService.campaignAdd(mapCampaignAlticaAdd);
			if(mapCampaignAlticaDesc.size() > 0){
				OportunidadFinanciamientoService.campaignDesc(mapCampaignAlticaDesc);
			}
		}
	}

	public override void beforeUpdate(){
		Id idTipoRegistroCompartido;
		String idOpF, idClienteAltica, idClienteRMAltica;
		Integer tipoRegistro;

		idTipoRegistroCompartido = Schema.SObjectType.Oportunidad_de_Financiamiento__c.getRecordTypeInfosByName().get('RedMotors-Altica').getRecordTypeId();

		//Logica para hacer la busqueda de clientes con opFs en estado 'Aprobada'
		idOpF = ListNewOpsF[0].Id;
		if(ListNewOpsF[0].RecordTypeId == idTipoRegistroCompartido && (ListNewOpsF[0].Estado__c == 'Aprobada' && ListNewOpsF[0].Etapa__c == 'Cotizado y pre aprobado')){
			idClienteRMAltica = [SELECT AccountId FROM Opportunity WHERE Id =: ListNewOpsF[0].Oportunidad__c].AccountId;	
			tipoRegistro = 1;
		}else if(ListNewOpsF[0].Estado__c == 'Aprobada' && ListNewOpsF[0].Etapa__c == 'Cotizado y pre aprobado'){
			idClienteAltica = ListNewOpsF[0].Nombre_Cliente_Altica__c;
			tipoRegistro = 2;
		}
		if(ListNewOpsF[0].Posee_varias_OpFs__c == false && (idClienteAltica != null || idClienteRMAltica != null)){
			if(idClienteRMAltica != null){
				if(OportunidadFinanciamientoService.BuscarOpFs(idOpF, idClienteRMAltica, tipoRegistro)){
					System.debug('***** imprime error ***** ');
					ListNewOpsF[0].addError('El cliente tiene una o mas oportunidades de  financiamiento aprobadas');
				}
			}else{
				if(OportunidadFinanciamientoService.BuscarOpFs(idOpF, idClienteAltica, tipoRegistro)){
					ListNewOpsF[0].addError('El cliente tiene una o mas oportunidades de  financiamiento aprobadas');
				}
			}
		}
		if(ListNewOpsF[0].ModenaIngreso__c == 'Colones' && ListNewOpsF[0].Ingreso__c < 50000){
			ListNewOpsF[0].addError('Si Moneda Ingreso = "Colones" el campo Ingreso debe ser mayor o igual a 50.000 pero si Moneda Ingreso = "Dólares" ' + 
									'el campo Ingreso debe ser menor a 50.000');
		}else if(ListNewOpsF[0].ModenaIngreso__c == 'Dólares' && ListNewOpsF[0].Ingreso__c > 50000){
			ListNewOpsF[0].addError('Si Moneda Ingreso = "Colones" el campo Ingreso debe ser mayor o igual a 50.000 pero si Moneda Ingreso = "Dólares" ' + 
									'el campo Ingreso debe ser menor a 50.000');
		}
	}
}