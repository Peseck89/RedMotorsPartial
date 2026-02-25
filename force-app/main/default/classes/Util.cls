public without sharing class Util {

   public static map<String,Account> mapaAccounts = new map<String,Account>();
   public static void llenarDatosAccount(Set<string> accountsp){
   		//Select estatico para accounts, selecciona solamente si el mapa aun no tiene el dato nuevo
   		if(!mapaAccounts.KeySet().containsAll(accountsp))
			System.debug('****** clase util *****');
   			mapaAccounts.putAll([
				Select codigopostal__c, Website, Version__c, Vendedorasignado__c, Type, Tipo_de_viaje__c, Tipo_de_Documento__c, Tiene_Hijos__c, SystemModstamp, Suffix, SicDesc, ShippingStreet, ShippingState, ShippingPostalCode, ShippingLongitude, ShippingLatitude, ShippingGeocodeAccuracy, ShippingCountry, ShippingCity, ShippingAddress, Sexo__c, Salutation, RecordTypeId, Provincia__c, Profesiones__c, PhotoUrl, Phone, PersonTitle, PersonMobilePhone, PersonMailingStreet, PersonMailingState, PersonMailingPostalCode, PersonMailingLongitude, PersonMailingLatitude, PersonMailingGeocodeAccuracy, PersonMailingCountry, PersonMailingCity, PersonMailingAddress, PersonLastCUUpdateDate, PersonLastCURequestDate, PersonEmailBouncedReason, PersonEmailBouncedDate, PersonEmail, PersonDepartment, PersonContactId, ParentId, Pais__c, OwnerId, NumberOfEmployees, Nivelacademico__c, Nivel_de_ingreso_familiar_anual__c, Name, Monedas_Iden__c, MiddleName, MasterRecordId, Marca__c, Le_gusta_vacacionar__c, LastViewedDate, LastReferencedDate, LastName, LastModifiedDate, LastModifiedById, LastActivityDate, JigsawCompanyId, Jigsaw, IsPersonAccount, IsDeleted, Industry, Id, Gustospreferencias__c, Frecuencia_de_viaje__c, FirstName, Extensi_n__c, Estilo__c, EstadoCivilTipos__c, Empresas__c, Distrito__c, Direccion__c, Destino_favorito__c, Description, CreatedDate, CreatedById, Cedula__c, Canton__c, Cantidad_de_hijos__c, Calle__c, Calificacion__c, BillingStreet, BillingState, BillingPostalCode, BillingLongitude, BillingLatitude, BillingGeocodeAccuracy, BillingCountry, BillingCity, BillingAddress, Apellido2__c, Apellido1__c, Anno__c, AccountSource,CorreoElectronicoEmpresarial__c 
				from Account 
				where id IN :accountsp and id NOT IN :mapaAccounts.keySet()]);
   		
   }

	public static List<Opportunity> actualizaAprobador(List<OpportunityLineItem> opLineas){
		
		List<Opportunity> opsActualizadas = new List<Opportunity>();
		
		Integer numOli = 0;
		Integer director = 0;
		Integer gerente = 0;
		Integer jefe = 0;
		Integer vendedor = 0;
		Double montoDescuento = 0;	
		
		Id idOp = null;	
	
		for(OpportunityLineItem oli:opLineas){
		
			System.debug('Producto # ' + numOli);
			
			if(oli.Aprobador__c!=null){
				
				system.debug('% Vendedor ' + oli.porcentajeVendedor__c);
				system.debug('% Jefe ' + oli.porcentajeJefe__c);
				system.debug('% Gerente ' + oli.porcentajeGerente__c);
				system.debug('Aprobador ' + oli.Aprobador__c);
				system.debug('Descuento % ' + oli.Descuentoporcentaje__c);
				system.debug('Precio facturación: '+ oli.Preciodefacturacion__c);
				system.debug('Monto descuento: '+ oli.Montodescuento__c);
				system.debug('ListPrice: '+ oli.ListPrice);
				system.debug('UnitPrice: '+ oli.UnitPrice);
				system.debug('TotalPrice: '+ oli.TotalPrice);
				
				idOp = opLineas[0].OpportunityId;
				
				if(oli.Aprobador__c.equals('Director')) director++;
				
				if(oli.Aprobador__c.equals('Gerente')) gerente++;
				
				if(oli.Aprobador__c.equals('Jefe')) jefe++;
				
				if(oli.Aprobador__c.equals('Vendedor')) vendedor++;
				
				montoDescuento = montoDescuento + (oli.Montodescuento__c!=null?oli.Montodescuento__c:0);
			}
			
			numOli++;
		}
		
			System.debug('director '+ director);
			System.debug('gerente '+ gerente);
			System.debug('jefe '+ jefe);
			System.debug('vendedor '+ vendedor);
			System.debug('montoDescuento '+ montoDescuento);
			
			Opportunity op;
			
			if(director>0) {
				op = new Opportunity();
				op.id = idOp; op.Director__c = true; op.Gerente__c = false;op.Jefe__c = false; op.Vendedor__c = false; op.DescuentoAprobado__c = false; op.Aprobador__c = 'Director';
				opsActualizadas.add(op);
				
				return opsActualizadas;
				
			}
			
			if(director==0&&gerente>0){
				op = new Opportunity();
				op.id = idOp; op.Gerente__c = true; op.Jefe__c = false; op.Director__c = false; op.Vendedor__c = false; op.DescuentoAprobado__c = false; op.Aprobador__c = 'Gerente';
				opsActualizadas.add(op);
				
				return opsActualizadas;
				
			}
			
			if(director==0&&gerente==0&&jefe>0){
				op = new Opportunity();
				op.id = idOp; op.Jefe__c = true; op.Director__c = false; op.Gerente__c = false; op.Vendedor__c = false; op.DescuentoAprobado__c = false; op.Aprobador__c = 'Jefe';
				opsActualizadas.add(op);
				return opsActualizadas;
				
			}
			
			if(director==0&&gerente==0&&jefe==0&&vendedor>0){
				System.debug('***** entro test ***** ');
				System.debug('**** id op **** ' + idOp);
				op = new Opportunity();
				op.id = idOp;				
				op.DescuentoAprobado__c = true;
				op.Ultimo_descuento_aprobado__c = montoDescuento;
				op.Vendedor__c = true;
				op.Jefe__c = false;
				op.Director__c = false;
				op.Gerente__c = false;				
                op.Aprobador__c = 'Vendedor';
				opsActualizadas.add(op);
				
				return opsActualizadas;
				
			}
							   
		return opsActualizadas;
	}
	
	//Metodo que actualiza el campo ModelosProductos en la Oportunidad que se utiliza en la plantilla llamada Aviso Solicitud Descuento,
	// el metodo lo que hace es concatenar los nombres de los modelos de los productos
	public static void updateFieldOp(List<Id> ids, String idOp){
		String modelos = null;
		String espacio = ' || ';
		Opportunity op = new Opportunity();
		
		for(Product2 pro : [SELECT Id, Modelo_De_Inter_s__c FROM Product2 WHERE Id IN:ids]){
			if(modelos == null){
				modelos = pro.Modelo_De_Inter_s__c;
			}else{ modelos = modelos + espacio + pro.Modelo_De_Inter_s__c;
			}
		}
        
        if(modelos!=Null){
        if(modelos.length() > 255) {
            modelos = modelos.substring(0, 200);
        } } 
        
		op = [SELECT Id, ModelosProductos__c FROM Opportunity WHERE Id =: idOp];
		if(op.ModelosProductos__c == null){
            
			op.ModelosProductos__c = modelos;
		}else{
            op.ModelosProductos__c = op.ModelosProductos__c + espacio + modelos;
		}
        
		TriggerHandler.bypass('OpportunityTriggerHandler');
		update op;
		TriggerHandler.clearBypass('OpportunityTriggerHandler');
	}
	
	//Metodo que actualiza el campo ModelosProductos en la Oportunidad que se utiliza en la plantilla llamada Aviso Solicitud Descuento,
	// el metodo lo que hace es concatenar los nombres de los modelos de los productos cuando se elimina algun producto
	public static void updateFieldOp(String idOp){
		String modelos = null;
        String myString = ' ';
		String espacio = ' || ';
		Opportunity op;
		List<Id> idsPro= new List<Id>();
		
		op = [SELECT Id, ModelosProductos__c, (SELECT Product2Id FROM OpportunityLineItems) FROM Opportunity WHERE id =: idOp];
		for(OpportunityLineItem pro : op.OpportunityLineItems){idsPro.add(pro.Product2Id);
		}
		System.debug('************** productos delete ********************** ' + op);
		System.debug('************** productos delete ********************** ' + idsPro);
		for(Product2 pro : [SELECT Id, Modelo_De_Inter_s__c FROM Product2 WHERE Id IN:idsPro]){
			if(modelos == null){modelos = pro.Modelo_De_Inter_s__c;
			}else{
				modelos = modelos + espacio + pro.Modelo_De_Inter_s__c;
			}
		}
        if(modelos!=Null){
        if(modelos.length() > 255) {
            modelos = modelos.substring(0, 255);
        }}
        
		op.ModelosProductos__c = myString;
		TriggerHandler.bypass('OpportunityTriggerHandler');
		update op;
		TriggerHandler.clearBypass('OpportunityTriggerHandler');
	}
}