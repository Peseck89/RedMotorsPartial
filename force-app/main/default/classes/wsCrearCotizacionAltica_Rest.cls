/*
  Creado por David Leon IS
  Fecha creacion: 13/01/2019
  Descripcion: Web service rest para la creacion de gestiones desde la pagina web de Altica
*/

@RestResource(UrlMapping='/AlticaCotizaciones/*')
global class wsCrearCotizacionAltica_Rest{

	@HttpPost
	global static responseCotizacion crearCotizacion(){
		RestRequest req = RestContext.request;
		responseCotizacion response =  new responseCotizacion();
		Cotizacion__c cotizacion = new Cotizacion__c();

		if(req == null){
			response.status = 'error';
			response.mensaje = 'Información entrante nula';
			return response;
		}

		String jsonInput = req.requestBody.toString();
		InfoCotizacion nuevaCotizacion = new InfoCotizacion();
		nuevaCotizacion.creditDistribution = new List<CreditDistribution>();
		nuevaCotizacion = (InfoCotizacion) JSON.deserialize(jsonInput, InfoCotizacion.class);
		System.debug(' ** INFO COTIZACION ENTRANTE ** ' + nuevaCotizacion);
		System.debug(' ** INFO DISTRIBUCION ENTRANTE ** ' + nuevaCotizacion.creditDistribution);

		cotizacion.Activo__c = nuevaCotizacion.assetName;
		cotizacion.Ano__c = String.valueOf(nuevaCotizacion.assetYear);
		cotizacion.Apellidos_Cliente__c = nuevaCotizacion.clientLastName;
		cotizacion.Campana__c = nuevaCotizacion.campaignName;
		cotizacion.Compania__c = nuevaCotizacion.companyName;
		cotizacion.Condicion_Activo__c = nuevaCotizacion.assetConditionName;
		cotizacion.Correo_Electronico__c = nuevaCotizacion.clientEmail;
		cotizacion.Moneda__c = nuevaCotizacion.currencyName;
		cotizacion.Monto_Real__c = nuevaCotizacion.realAmount;
		cotizacion.Monto_Seguro__c = nuevaCotizacion.insuranceAmount;
		cotizacion.Nombre_Cliente__c = nuevaCotizacion.clientName;
		cotizacion.Plazo__c = nuevaCotizacion.periodValue;
		cotizacion.Precio__c = nuevaCotizacion.price;
		cotizacion.Prima__c = nuevaCotizacion.premium;
		cotizacion.Producto__c = nuevaCotizacion.productName;
		cotizacion.Profesion__c = nuevaCotizacion.clientEmploymentName;
		cotizacion.Seguro_Fijo__c = nuevaCotizacion.fixedInsurance;
		cotizacion.Telefono__c = nuevaCotizacion.clientPhoneNumber;
		cotizacion.Valor_Residual__c = nuevaCotizacion.futureValue;
		cotizacion.Porcentaje_Valor_Residual__c = nuevaCotizacion.residualValue;

		try{
			insert cotizacion;
			System.debug(' ** ID COTIZACION ** ' + cotizacion.Id);
			crearDistribuciones(cotizacion.Id, nuevaCotizacion.creditDistribution);
			crearCargos(cotizacion.Id, nuevaCotizacion.creditCharges);
			crearTablaPagos(cotizacion.Id, nuevaCotizacion.paymentsTable);
			response.mensaje = 'Cotización creada exitosamente';
		}catch(DmlException ex){
			response.status = 'error';
			response.mensaje = 'Error al intentar crear la cotización en salesforce. ' + ex.getMessage();
			return response;
		}
		return response;
	}

	//Metodo para crear las distribuciones de la cotizacion
	public static void crearDistribuciones(Id idCotizacion, List<CreditDistribution> listTemp){
		List<Distribucion__c> listCreate = new List<Distribucion__c>();

		for(CreditDistribution cd : listTemp){
			Distribucion__c d = new Distribucion__c();
			d.Cotizacion__c = idCotizacion;
			d.Cuota__c = cd.fee;
			System.debug(' ** CD BASE RATE ** ' + cd.baseRate);
			if(cd.baseRate != null){
				d.Descripcion_Tasa_Base__c = cd.baseRate.baseRateDescription;
				d.Porcentaje_Tasa_Base__c = cd.baseRate.baseRatePercentage;
				d.Variable_Tasa_Base__c = cd.baseRate.baseRateVariable;
			}
			d.Mes_Final__c = cd.finalMonth;
			d.Mes_Inicial__c = cd.initialMonth;
			d.Spread__c = cd.spread;

			listCreate.add(d);
		}

		if(!listCreate.isEmpty() && listCreate.size() > 0){
			insert listCreate;
		}
	}

	//Metodo para crear los cargos de la cotizacion
	public static void crearCargos(Id idCotizacion, List<CreditCharges> listTemp){
		List<Cargo__c> listCreate = new List<Cargo__c>();
	
		for(CreditCharges cc : listTemp){
			Cargo__c c = new Cargo__c();

			c.Cotizacion__c = idCotizacion;
			c.Descripcion_Cargo__c = cc.charge.description;
			c.Descripcion_Tipo_Pago__c = cc.paymentTypeDescription;
			c.Impuesto__c = cc.charge.taxes;
			c.Monto__c = cc.amount;
			c.Porcentaje_Credito__c = cc.creditPercentage;

			listCreate.add(c);
		}

		if(!listCreate.isEmpty() && listCreate.size() > 0){
			insert listCreate;
			System.debug(' ** LISTA DE CARGOS CREADOS ** ' + listCreate[0].Id);
			crearCargosFinancieros(listCreate, listTemp);
		}
	}

	//Metodo para crear los cargos financieros asociados a un cargo
	public static void crearCargosFinancieros(List<Cargo__c> listTempCargos, List<CreditCharges> listTempCC){
		List<Cargos_Financiamiento__c> listCreate = new List<Cargos_Financiamiento__c>();

		for(CreditCharges cc : listTempCC){
			if(!cc.chargesFinancing.isEmpty() && cc.chargesFinancing.size() > 0){
				for(ChargesFinancing temp : cc.chargesFinancing){
					Cargos_Financiamiento__c cf = new Cargos_Financiamiento__c();

					cf.Mes_Inicial__c = temp.initialMonth;
					cf.Mes_Final__c = temp.finalMonth;
					cf.Intereses__c = temp.interest;
					cf.Porcentaje__c = temp.percentage;
					cf.Monto_Fijo__c = temp.fixedAmount;

					for(Cargo__c c : listTempCargos){
						if(c.Descripcion_Cargo__c == cc.charge.description){
							cf.Cargo__c = c.Id;
							break;
						}
					}
					listCreate.add(cf);
				}

			}
		}
		if(!listCreate.isEmpty() && listCreate.size() > 0){
			insert listCreate;
		}
	}

	//Metodo para crear las tablas de pago de la cotizacion
	public static void crearTablaPagos(Id idCotizacion, List<PaymentsTable> listTemp){
		List<Tabla_Pagos__c> listCreate = new List<Tabla_Pagos__c>();

		for(PaymentsTable pt : listTemp){
			Tabla_Pagos__c tp = new Tabla_Pagos__c();

			tp.Cotizacion__c = idCotizacion;
			tp.Impuestos__c = pt.taxes;
			tp.Intereses__c = pt.interest;
			tp.Monto__c = pt.amount;
			tp.Monto_Total__c = pt.totalAmount;
			tp.Principal__c = pt.principal;
			tp.Saldo__c = pt.balance;
			tp.Index__c = pt.index;
			tp.Administrativo__c = pt.charges.Administrativo;
			tp.Seguro_Monto_Fijo__c = pt.charges.Seguro;
			tp.comision__c = pt.charges.Comision_Sin_IVA;
			tp.GPS__c = pt.charges.GPS;

			listCreate.add(tp);
		}

		if(!listCreate.isEmpty() && listCreate.size() > 0){
			insert listCreate;
		}
	}

	//Clase para manejar el mensaje que devuelve el web service
	global class responseCotizacion{
		global String status{get;set;}
		global String mensaje{get;set;}

		global responseCotizacion(){
			this.status = 'exito';
			this.mensaje = '';
		}
	}

	//Clases para la informacion general de la cotizacion
	public class InfoCotizacion {
		public Integer assetYear;
		public String clientName;
		public String clientLastName;
		public String clientEmail;
		public String clientPhoneNumber;
		public String clientEmploymentName;
		public String companyName;
		public String assetName;
		public String assetConditionName;
		public String productName;
		public Double price;
		public String currencyName;
		public Double fixedInsurance;
		public Double insuranceAmount;
		public Double realAmount;
		public String campaignName;
		public Integer period;
		public Integer periodValue;
		public Double premium;
		public Double futureValue;
		public Double residualValue;
		public List<CreditDistribution> creditDistribution;
		public List<CreditCharges> creditCharges;
		public List<PaymentsTable> paymentsTable;

		public InfoCotizacion(){
			this.assetYear = 0;
			this.clientName = '';
			this.clientLastName = '';
			this.clientEmail = '';
			this.clientPhoneNumber = '';
			this.clientEmploymentName = '';
			this.companyName = '';
			this.assetName = '';
			this.assetConditionName = '';
			this.productName = '';
			this.price = 0;
			this.currencyName = '';
			this.fixedInsurance = 0;
			this.insuranceAmount = 0;
			this.realAmount = 0;
			this.campaignName = '';
			this.period = 0;
			this.periodValue = 0;
			this.premium = 0;
			this.futureValue = 0;
			this.residualValue = 0;
			this.creditDistribution = new List<CreditDistribution>();
			this.creditCharges = new List<CreditCharges>();
			this.paymentsTable = new List<PaymentsTable>();
		}
	}

	public class CreditDistribution {
		public Integer initialMonth;
		public Integer finalMonth;
		public BaseRate baseRate;
		public Double spread;
		public Double fee;

		public CreditDistribution(){
			this.initialMonth = 0;
			this.finalMonth = 0;
			this.baseRate = new BaseRate();
			this.spread = 0;
			this.fee = 0;
		}
	}

	public class BaseRate {
		public String baseRateDescription;
		public Double baseRatePercentage;
		public Integer baseRateVariable;

		public BaseRate(){
			this.baseRateDescription = '';
			this.baseRatePercentage = 0;
			this.baseRateVariable = 0;
		}
	}

	public class CreditCharges {
		public Charge charge;
		public Double amount;
		public String paymentTypeDescription;
		public Double creditPercentage;
		public List<ChargesFinancing> chargesFinancing;

		public CreditCharges(){
			this.charge = new Charge();
			this.amount = 0;
			this.paymentTypeDescription = '';
			this.creditPercentage = 0;
			this.chargesFinancing = new List<ChargesFinancing>();
		}
	}

	public class Charge {
		public String description;
		public Double taxes;

		public Charge(){
			this.description = '';
			this.taxes = 0;
		}
	}

	public class ChargesFinancing {
		public Integer initialMonth;
		public Integer finalMonth;
		public Double percentage;
		public Double interest;
		public Double fixedAmount;

		public ChargesFinancing(){
			this.initialMonth = 0;
			this.finalMonth = 0;
			this.percentage = 0;
			this.interest = 0;
			this.fixedAmount = 0;
		}
	}

	public class PaymentsTable {
		public Double amount;
		public Double interest;
		public Double principal;
		public Charges charges;
		public Double totalAmount;
		public Double taxes;
		public Double balance;
		public Integer index;

		public PaymentsTable(){
			this.amount = 0;
			this.interest = 0;
			this.principal = 0;
			this.charges = new Charges();
			this.totalAmount = 0;
			this.taxes = 0;
			this.balance = 0;
			this.index = 0;
		}
	}

	public class Charges {
		public Double Administrativo;
		public Double Seguro;
		public Double Comision_Sin_IVA;
		public Double GPS;

		public Charges(){
			this.Administrativo = 0;
			this.Seguro = 0;
			this.Comision_Sin_IVA = 0;
			this.GPS = 0;
		}
	}
}