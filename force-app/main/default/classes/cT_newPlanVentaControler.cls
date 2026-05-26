/**
 * @description       : 
 * @author            : marcohernandezhp@gmail.com
 * @group             : 
 * @last modified on  : 05-04-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
public with sharing class cT_newPlanVentaControler {

	public static List<String> currencyFormat = new String[]{'0','number','###,###,##0.00'};
	
    public Opportunity op{set;get;}
	public Quote quote{set;get;}
	public List<QuoteLineItem> quoteLine{set;get;}	
	public List<OpportunityLineItem> lstOppLine{set;get;}
	public datosVehiculo vehiculo {set;get;}
	public List<datosVehiculo> vehiculos {set;get;}	
	public List<datosProductos> productosQuote{set;get;}	
	public List<datosProductos> productosQuoteRegalias{set;get;}	
	public Double facturacionTotal {set;get;}
	public vehiUsado usados {set;get;}
	public List<ReciboUsado__c> recibos{set;get;}
	public ReciboUsado__c recibo{set;get;}
	public List<datosProductos> productos{set;get;}		
	public String Header{get;set;}
	public Boolean noTiene {get;set;}
	public Date Fecha{get;set;}
	public Decimal valorTotalNegocio{get;set;}
	public Decimal oppDescuentoTotalMonto{get;set;}
	public Decimal oppDescuentoTotalPorcentaje{get;set;}

	public Opportunity opp {get;set;}
   

    public cT_newPlanVentaControler(Apexpages.StandardController controller) {
        String recordId = controller.getId();

        List<Opportunity> oppList = [
                                    SELECT Id,NombreDestinoDescuento__c,Account.Name,Owner.Name,Name,ModelosProductos__c,MontodeExtras__c,ValorTotal__c,Importetotaldelnegocio__c,
                                    Recibe_usado__c,Placa_usado__c , MontodeRegalias__c,Detalle_regalias__c,Detalle_de_Extras__c,MontoSoporteTotal__c,Descuento_Total_Moneda__c,
                                    Descuento_Total__c,Margen_Total__c, SumaCostoTotal__c,SumaListaPrecio__c,Detalles_del_Negocio__c,Cuenta_de_Facturaci_n__c,Cuenta_de_Facturaci_n__r.Name,
                                    (
                                        SELECT Id,PrecioFacturacion2__c,Opportunity_Line_Item__c,Description,Montodescuento__c,Product2.Name,Product2.Description,ListPrice,Product2Id,Product2.Detalle_de_Polarizado__c,Product2.Polarizado__c,Polarizado__c,Detalle_de_polarizado__c,
                                        Product2.vin__c,UnitPrice,Product2.Color__c,Product2.Anno__c,Product2.modelo__c,Product2.Color_Externo__c,Product2.esVehiculo__c,Regal_a__c,Montoderegalias__c,Soporte__c,Product2.esExtra__c,Costo_Final__c,TotalPrice,Costo_Fijo__c,esRegalia__c,esExtra__c,FechaEstimadaEntrega__c,
										Montodeextras__c,VN_Precio_Venta_Fantasia_FX__c,VN_Descuento_Aplicado_Monto_FX__c,VN_Descuento_Aplicado_Porcentaje_FX__c
                                        FROM OpportunityLineItems
                                    ),
                                    (
                                        SELECT Id,Serecibevehiculo__c,Se_Recibe_Motocicleta__c,Marca__c,Modelo__c,Ano__c,Placa__c,MontoSoporte__c,ValorReciboCliente__c,ReciboJefeUsados__c 
                                        FROM ReciboUsadosOportunidad__r 
                                    ),
                                    (
                                        SELECT Id
                                        FROM Quotes
                                        WHERE IsSyncing__c = true
                                    )
                                    FROM Opportunity
                                    WHERE Id = :recordId];
                   
        

	cT_newPlanVentaBase.Totales tot = cT_newPlanVentaBase.calcularTotales(oppList, false);
	valorTotalNegocio          = tot.valorTotalNegocio;
	oppDescuentoTotalMonto     = tot.oppDescuentoTotalMonto;
	oppDescuentoTotalPorcentaje = tot.oppDescuentoTotalPorcentaje;

	if (oppList.size()>0) {
		opp = oppList[0];
	}									
									
									
        getData(recordId);
		getDataQuote(recordId);
    }


	
    public void getData(String recordId) {
        System.debug('*********************** Id Dado ************************** ');
        if(recordId != null){
			op = [Select o.Tipo_de_financiamiento__c, o.Sucursal__c, o.Polarizado__c, o.Owner.Name, o.OwnerId, o.Importetotaldelnegocio__c, 
					o.Forma_de_Pago__c, o.Entidad__c, o.Detalles_del_Negocio__c, o.Detalle_regalias__c, o.Detalle_de_Polarizado__c, o.Detalle_de_Extras__c, 
					o.Color_interno__c, o.Color_externo__c, o.Account.Name, o.AccountId, (Select Modelo__c, Serecibevehiculo__c, Marca__c, Ano__c, Placa__c, 
					ValorReciboCliente__c From ReciboUsadosOportunidad__r), (Select Product2Id,Product2.esVehiculo__c,Product2.esExtra__c, ProductCode, Name,
					FechaEstimadaEntrega__c,Regal_a__c, ListPrice, Montodescuento__c, Preciodefacturacion__c, Preciototal__c,Polarizado__c,Detalle_de_polarizado__c
					  From OpportunityLineItems) From Opportunity o where id =: recordId];	
			System.debug('*********************** PRIMER BUSCAR ************************** ');
			if(op.OpportunityLineItems != null && op.OpportunityLineItems.size() > 0){
				List<String> idsProd = new List<String>();
				for(OpportunityLineItem opL : op.OpportunityLineItems){
					idsProd.add(opL.Product2Id);
				}
				Map<String,String> mapPro = new Map<String,String>();
				for(Product2 pro : [SELECT Name, Id FROM Product2 WHERE Id IN : idsProd]){
					mapPro.put(pro.Id, pro.Name);
				}
				//sacar los nuevos campos
				Map<String,String> mapProModelo = new Map<String,String>();
				for(Product2 pro : [SELECT 	modelo__c, Id FROM Product2 WHERE Id IN : idsProd]){
					mapProModelo.put(pro.Id, pro.modelo__c);
				}
				Map<String,String> mapProAnno = new Map<String,String>();
				for(Product2 pro : [SELECT 	Anno__c, Id FROM Product2 WHERE Id IN : idsProd]){
					mapProAnno.put(pro.Id, pro.Anno__c);
				}
				Map<String,String> mapProColor = new Map<String,String>();
				for(Product2 pro : [SELECT 	Color__c, Id FROM Product2 WHERE Id IN : idsProd]){
					mapProColor.put(pro.Id, pro.Color__c);
				}
				Map<String,String> mapProVin = new Map<String,String>();
				for(Product2 pro : [SELECT 	vin__c, Id FROM Product2 WHERE Id IN : idsProd]){
					mapProVin.put(pro.Id, pro.vin__c);
				}

				System.debug('*********************** LISTA PRODUCTOS ************************** ' + op.OpportunityLineItems);
				List<datosProductos> nvoProd = new List<datosProductos>();
				Integer indexAct =0;
				for(OpportunityLineItem opL : op.OpportunityLineItems){
					datosProductos prod = new datosProductos();
					indexAct += 1;
					prod.codigo = opL.ProductCode;
					prod.numerador = indexAct;
					if (opL.Regal_a__c == true) {
						prod.tipo = 'regalia';
					}else if(opL.Product2.esVehiculo__c == true) {
						prod.tipo = 'vehiculo';
					}else if (opL.Product2.esExtra__c == true) {
						prod.tipo = 'extra';
					}
					prod.modelo = mapProModelo.get(opL.Product2Id);
					prod.color = mapProColor.get(opL.Product2Id);
					prod.vin = mapProVin.get(opL.Product2Id);
					//prod.name = opL.Name;
					prod.name = mapPro.get(opL.Product2Id);
					prod.anno = mapProAnno.get(opL.Product2Id);
					prod.fechaEntrega = opL.FechaEstimadaEntrega__c;
					prod.polarizado = opL.Polarizado__c;
					prod.detaPolarizado = opL.Detalle_de_polarizado__c;
					prod.precioFacturacion = opL.Preciodefacturacion__c;
					prod.montoDescuento = opL.Montodescuento__c;
					prod.precioTotal = opL.Preciototal__c;
					prod.precioLista = opL.ListPrice;
					System.debug('*********************** Producto *************************8 ' + prod);
                    if(test.isRunningTest()){
                        
                    }else{
                        nvoProd.add(prod);
                    }
					
				}
				if (nvoProd.size() > 0) {
					productos = nvoProd;
				}
			}

			//System.debug('*********************** PRODUCTOS ************************* ' + productos);
				
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


	public void getDataQuote(String recordId) {
        System.debug('*********************** Id Dado ************************** ');
        if(recordId != null){
			List<Quote> lstQuote = cT_newPlanVentaBase.getUltimaQuote(recordId);
			if (lstQuote.size()>0) {
				quote = lstQuote[0];
			System.debug('*********************** PRIMER BUSCAR ************************** ' + quote);
			quoteLine = [SELECT Id,BMW_Alias__c,Product2.esVehiculo__c,Quote_Line_Item__c,esExtra__c,esRegalia__c,Product2.id,Product2.codGrupo4__c,Product2.codGrupo6__c,Product2.Color_Externo__c,Product2.codGrupo5__c,Product2.Name,Product2.vin__c,UnitPrice,Discount,Product2.Description,TotalPrice,CurrencyIsoCode,Product2.Codigo_de_Producto__c,Product2.modelo__c,Product2.Anno__c,Product2.color__c,ListPrice,
			 product2.Detalle_de_Polarizado__c,product2.Polarizado__c, product2.Fecha_Entrega__c FROM QuoteLineItem WHERE QuoteId =: quote.Id];

			System.debug('*********************** PRODUCTOS ************************* ' + quoteLine);
			Double facturacionSuma = 0;
			List<datosProductos> nvoProdQuote = new List<datosProductos>();
			List<datosProductos> nvoProdQuoteRegalia = new List<datosProductos>();
			List<datosVehiculo> lstVehiculos = new List<datosVehiculo>();
			Integer indexAct = 0;
			for(QuoteLineItem itemActual : quoteLine){
				if (itemActual.Product2 != null && itemActual.Product2.esVehiculo__c == false ) {
					
					datosProductos prodQuote = new datosProductos();
					if (itemActual.esRegalia__c == true) {
						prodQuote.codigo = 'regalia';
						prodQuote.name = itemActual.Product2.Name;
						prodQuote.codProd = itemActual.Quote_Line_Item__c;
						prodQuote.descripcion = itemActual.Product2.Description;
						prodQuote.precioTotal = itemActual.TotalPrice;
						prodQuote.currencyQuot = itemActual.CurrencyIsoCode;
						nvoProdQuoteRegalia.add(prodQuote);
						
					}else {
						facturacionSuma = facturacionSuma + itemActual.TotalPrice;
						prodQuote.codigo = 'extra';
						prodQuote.codProd = itemActual.Quote_Line_Item__c;
						prodQuote.name = itemActual.Product2.Name;
						prodQuote.descripcion = itemActual.Product2.Description;
						prodQuote.precioTotal = itemActual.TotalPrice;
						prodQuote.currencyQuot = itemActual.CurrencyIsoCode;
						nvoProdQuote.add(prodQuote);
					}
					productosQuoteRegalias = nvoProdQuoteRegalia;
					productosQuote = nvoProdQuote;
				}else {
					
					datosVehiculo prodVehiculo = new datosVehiculo();
					indexAct += 1;
					prodVehiculo.idProd = itemActual.Product2.id;
					lstOppLine = [SELECT Id,Product2Id,Preciodefacturacion__c,Montodescuento__c,PrecioFacturacion2__c,Preciototal__c,ListPrice FROM OpportunityLineItem WHERE Product2Id =: itemActual.Product2.id ];
					if (lstOppLine.size()>0) {
						prodVehiculo.precioFacturacion = lstOppLine[0].Preciodefacturacion__c;
						prodVehiculo.precioTotal = lstOppLine[0].Preciototal__c;
						prodVehiculo.precioLista = lstOppLine[0].ListPrice;
						prodVehiculo.montoDescuento = lstOppLine[0].Montodescuento__c;
					}
					prodVehiculo.numerador = indexAct;
					prodVehiculo.codigo = itemActual.Product2.Codigo_de_Producto__c;
					prodVehiculo.modelo = itemActual.Product2.codGrupo4__c + ' ' + itemActual.Product2.codGrupo5__c;
					prodVehiculo.anio = itemActual.Product2.Anno__c;

					prodVehiculo.polarizado = itemActual.product2.Polarizado__c;
					prodVehiculo.detaPolarizado = itemActual.product2.Detalle_de_Polarizado__c;
					prodVehiculo.fechaEntrega = itemActual.product2.Fecha_Entrega__c;

					prodVehiculo.color = itemActual.Product2.Color_Externo__c ;
					prodVehiculo.name = itemActual.Product2.Name;
					prodVehiculo.vin = itemActual.Product2.vin__c;
					prodVehiculo.colorInterno = itemActual.Product2.color__c;
					
					
					
					facturacionSuma = facturacionSuma + itemActual.TotalPrice;
					vehiculo = prodVehiculo;
					lstVehiculos.add(prodVehiculo);
				}						
				vehiculos = lstVehiculos;
			}
			facturacionTotal = facturacionSuma;
			System.debug('************************ Productos Quote ****************************** ' + productosQuote);

			System.debug('************************ RECIBO USADOS ****************************** ' + recibos);
				
			Fecha = System.today();
			}
			//Sacar el usado
			List<ReciboUsado__c> lstUsados = cT_newPlanVentaBase.getReciboUsadoFinal(recordId);
			if (lstUsados.size() > 0) {
				vehiUsado usado = new vehiUsado();
				usado.marca = lstUsados[0].Marca__c;
				usado.modelo = lstUsados[0].Modelo__c;
				usado.anio = lstUsados[0].Ano__c;
				usado.placa = lstUsados[0].Placa__c;
				usado.montoSoporte = lstUsados[0].MontoSoporte__c;
				usado.reciboCliente = lstUsados[0].ValorReciboCliente__c;
				usado.reciboJefe = lstUsados[0].ReciboJefeUsados__c;
				usados = usado;
			}
			
		}

	}
	
	public class datosProductos{
		public String tipo{get;set;}
		public String codigo{get;set;}
		public String name{get;set;}
		public String modelo{get;set;}
		public String anno{get;set;}
		public Integer numerador{get;set;}
		public String color{get;set;}
		public String vin{get;set;}
		public String descripcion{get;set;}
		public String polarizado{get;set;}
		public String detaPolarizado{get;set;}
		public Date fechaEntrega{get;set;}
		public String currencyQuot{get;set;}
		public String codProd{get;set;}
		public Double precioFacturacion{get;set;}
		public Double montoDescuento{get;set;}
		public Double precioTotal{get;set;}
		public Double precioLista{get;set;}
	}	
	public class datosVehiculo{
		public String idProd {get;set;}
		public Integer numerador {get;set;}
		public String codigo{get;set;}
		public String polarizado{get;set;}
		public String detaPolarizado{get;set;}
		public String modelo{get;set;}
		public String name{get;set;}
		public Date fechaEntrega{get;set;}
		public String anio{get;set;}
		public String color{get;set;}
		public String colorInterno{get;set;}
		public String vin{get;set;}
		public Double precioFacturacion{get;set;}
		public Double montoDescuento{get;set;}
		public Double precioTotal{get;set;}
		public Double precioLista{get;set;}
	}	 
	public class vehiUsado{
		public String marca {get;set;}
		public String modelo {get;set;}
		public string anio {get;set;}
		public String placa {get;set;}
		public Double montoSoporte {get;set;}
		public Double reciboCliente {get;set;}
		public Double reciboJefe {get;set;}
	}	
}