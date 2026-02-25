public with sharing class ControllerPlanVenta {
	
	public Opportunity op{set;get;}
	public List<ReciboUsado__c> recibos{set;get;}
	public List<planVenta> productos{set;get;}
	public String id{get;set;}
	public String Header{get;set;}
	public String conFinanciero{get;set;}
	public String flag{get;set;}
	
	public ControllerPlanVenta(){
		productos = new List<planVenta>();
		id = Apexpages.currentPage().getParameters().get('id');
		
		if(id  != null){
			op = [Select o.Campana__r.Name, o.ValorTotal__c, o.Tipo_de_financiamiento__c, o.Sucursal__c, o.Solicitud_de_Placas__c, o.Prima__c, 
					o.PorcentajeTotalderecibo__c, o.Polarizado__c, o.Plazo_en_Meses__c, o.Placa_Solicitada__c, o.Owner.Name, o.OwnerId, o.OportunidadFinanciamiento__c, 
					o.MontodeRegalias__c, o.MontodeExtras__c, o.MontoSoporteTotal__c, o.MontoFinanciar__c, o.JefeSucursal__r.Name, o.Importetotaldelnegocio__c, 
					o.GerenteSucursal__r.Name, o.Forma_de_Pago__c, o.EstadoOF__c, o.Entidad__c, o.Enganche_recibo__c, o.Enganche_monto__c, 
					o.DirectorVentas__r.Name, o.Detalles_del_Negocio__c, o.Detalle_regalias__c, o.Detalle_de_Polarizado__c, o.Detalle_de_Extras__c, o.Descuento_Total__c, 
					o.Descuento_Total_Moneda__c, o.DescuentoAprobado__c, o.Consentimientofinaciero__c, o.ConsecutivoOportunidad__c, o.ComentariosFinancieros__c, 
					o.Color_interno__c, o.Color_externo__c, o.CloseDate, o.Account.Name, o.AccountId, (Select Modelo__c, Ano__c, Marca__c, Placa__c, ValorReciboCliente__c, 
					MontoSoporte__c, ReciboJefeUsados__c, Serecibevehiculo__c From ReciboUsadosOportunidad__r), (Select Product2Id, Modelo_De_Inter_s1__c, ProductCode, 
					Name, ListPrice, Montodescuento__c, Preciodefacturacion__c, Preciototal__c From OpportunityLineItems) From Opportunity o where id =: id];
					
			if(op.Consentimientofinaciero__c != null && op.Consentimientofinaciero__c)	
				conFinanciero = 'Si';
			else
				conFinanciero = 'No';
			
			if(op.OpportunityLineItems != null && op.OpportunityLineItems.size() > 0){
				List<String> idsProd = new List<String>();
				for(OpportunityLineItem opL : op.OpportunityLineItems){
					idsProd.add(opL.Product2Id);
				}
				Map<String,String> mapPro = new Map<String,String>();
				for(Product2 pro : [SELECT Name, Id FROM Product2 WHERE Id IN : idsProd]){
					mapPro.put(pro.Id, pro.Name);
				}
				
				for(OpportunityLineItem opL : op.OpportunityLineItems){
					planVenta datosVenta = new planVenta();
					datosVenta.name = mapPro.get(opL.Product2Id);
					System.debug('********************************** NOMBRE DEL PRODUCTO ***************************** ' + datosVenta.Name);
					datosVenta.codigoProd = opL.ProductCode;
					datosVenta.precioFacturacion = opL.Preciodefacturacion__c;
					datosVenta.montoDescuento = opL.Montodescuento__c;
					datosVenta.precioTotal = opL.Preciototal__c;
					datosVenta.precioLista = opL.ListPrice;
					productos.add(datosVenta);
				}
			}
				
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
		}	
	}

	public class planVenta{
		public String name{get;set;}
		public String codigoProd{get;set;}
		public Double precioFacturacion{get;set;}
		public Double montoDescuento{get;set;}
		public Double precioTotal{get;set;}
		public Double precioLista{get;set;}
	}
}