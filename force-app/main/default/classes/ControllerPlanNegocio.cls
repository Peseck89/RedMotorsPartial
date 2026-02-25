public with sharing class ControllerPlanNegocio {
	
	public Opportunity op{set;get;}
	public List<ReciboUsado__c> recibos{set;get;}
	public List<datosProductos> productos{set;get;}	
	public String id{get;set;}
	public String Header{get;set;}
	public Date Fecha{get;set;}
	
	public ControllerPlanNegocio(){
		productos = new List<datosProductos>();
		id = Apexpages.currentPage().getParameters().get('id');
		
		if(id != null){
			op = [Select o.Tipo_de_financiamiento__c, o.Sucursal__c, o.Polarizado__c, o.Owner.Name, o.OwnerId, o.Importetotaldelnegocio__c, 
					o.Forma_de_Pago__c, o.Entidad__c, o.Detalles_del_Negocio__c, o.Detalle_regalias__c, o.Detalle_de_Polarizado__c, o.Detalle_de_Extras__c, 
					o.Color_interno__c, o.Color_externo__c, o.Account.Name, o.AccountId, (Select Modelo__c, Serecibevehiculo__c, Marca__c, Ano__c, Placa__c, 
					ValorReciboCliente__c From ReciboUsadosOportunidad__r), (Select Product2Id, ProductCode, Name, 
					FechaEstimadaEntrega__c  From OpportunityLineItems) From Opportunity o where id =: id];	
			
			if(op.OpportunityLineItems != null && op.OpportunityLineItems.size() > 0){
				List<String> idsProd = new List<String>();
				for(OpportunityLineItem opL : op.OpportunityLineItems){
					idsProd.add(opL.Product2Id);
				}
				Map<String,String> mapPro = new Map<String,String>();
				for(Product2 pro : [SELECT Name, Id FROM Product2 WHERE Id IN : idsProd]){
					mapPro.put(pro.Id, pro.Name);
				}

				System.debug('*********************** LISTA PRODUCTOS ************************** ' + op.OpportunityLineItems);
				for(OpportunityLineItem opL : op.OpportunityLineItems){
					datosProductos prod = new datosProductos();
					prod.codigo = opL.ProductCode;
					//prod.name = opL.Name;
					prod.name = mapPro.get(opL.Product2Id);
					prod.fechaEntrega = opL.FechaEstimadaEntrega__c;
					System.debug('*********************** Producto *************************8 ' + prod);
					productos.add(prod);
				}
			}

			System.debug('*********************** PRODUCTOS ************************* ' + productos);
				
			if(op.ReciboUsadosOportunidad__r != null && op.ReciboUsadosOportunidad__r.size() > 0){
				recibos = new List<ReciboUsado__c>();
				for(ReciboUsado__c reU : op.ReciboUsadosOportunidad__r){
					System.debug('******************** Recibo Usado ********************* ' + reU);
					if(reU.Serecibevehiculo__c == true){
						recibos.add(reU);
					}
				}
				System.debug('******************** Lista Recibos Usados ************************ ' + recibos);
			}

			System.debug('************************ RECIBO USADOS ****************************** ' + recibos);
				
			Fecha = System.today();
		}
	}
	
	public class datosProductos{
		public String codigo{get;set;}
		public String name{get;set;}
		public Date fechaEntrega{get;set;}
	}	    
}