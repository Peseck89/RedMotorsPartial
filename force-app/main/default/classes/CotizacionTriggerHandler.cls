public class CotizacionTriggerHandler extends TriggerHandler{

	private Map<Id, Cotizacion__c> newCotizacionMap;
    private List<Cotizacion__c> ListNewCotizacion;
    
    private Map<Id, Cotizacion__c> MapOldCotizacion;
    private List<Cotizacion__c> ListOldCotizacion;
    
    public CotizacionTriggerHandler() {
        this.newCotizacionMap = (Map<Id, Cotizacion__c>) Trigger.newMap;
        this.ListNewCotizacion = (List<Cotizacion__c>) Trigger.New;
        this.ListOldCotizacion = (List<Cotizacion__c>) Trigger.Old;
        this.MapOldCotizacion = (Map<Id, Cotizacion__c>) Trigger.oldMap;         
        
    }

	public override void AfterUpdate(){
		Id idOpF;

		for(Cotizacion__c c : ListNewCotizacion){
			System.debug(' ** ESTADO COTIZACION ** ' + c.Estado__c);
			if(c.Estado__c == 'Aceptada' && c.Oportunidad_de_Financiamiento__c != null){
				if(c.Oportunidad_de_Financiamiento__r.Estado__c == 'Aprobada'){
					c.addError('No puede ligar la cotización a la oportunidad de financiamiento porque la oportunidad de financiamiento esta en estado Aprobada');
				}else{
					idOpF = c.Oportunidad_de_Financiamiento__c;
				}
			}
		}

		if(idOpF != null){
			CotizacionService.actualizarOpF(idOpF);
		}
	}
}