public with sharing class TemporalOPFinanciamientoService {
    /*public static void crearTemporalOPF(List<TemporalOPFinanciamiento__c> listTemp){
        List<Campaign> listCam = new List<Campaign>();
        List<Account> listAccount = new List<Account>();
		Map<String, Account> mapAccountUpdate = new Map<String, Account>();
        List<String> ids = new List<String>();
        List<Pricebook2> listPrecios = new List<Pricebook2>();
        List<TemporalOPFinanciamiento__c> listUpdate = new List<TemporalOPFinanciamiento__c>();
        List<Sucursal__c> listSucursales = new List<Sucursal__c>();
        List<User> listUsuarios = new List<User>();
        Map<String, Product2> mapProd = new Map<String, Product2>();
        Boolean existe = false;
        Boolean esActivo = false;
        Integer size = 0;
        String idJefe = '';
        Account tempA = new Account();
        
        //Obtengo las campañas
        listCam = [SELECT Id, Name FROM Campaign];
        
        //Obtengo las sucursales
        listSucursales = [SELECT Id, Name, Marca__c, JefedeSucursalMotorrad__c, JefesdeSucursalKTM__c, JefesdeSucursalKawasaki__c, JefesdeSucursalMini__c, 
                            JefesdeSucursalPolaris__c, JefeseSucursalBMW__c, DirectordeVentasBMW__c, DirectordeVentasKTM__c, DirectordeVentasKawasaki__c, 
                            DirectordeVentasMini__c, DirectordeVentasMotorrad__c, DirectordeVentasPolaris__c, JefedeSucursalHarley__c, DirectordeVentasHarley__c
							FROM Sucursal__c];
                            
        //Obtengo los usuarios
        listUsuarios = [SELECT Id, Name, Alias, IsActive FROM User];
        
        //Obtengo las cuentas
        listAccount = [SELECT Id, Name, FirstName, LastName, Cedula__c FROM Account];
        
        //Obtengo las listas de precios
        for(Pricebook2 price : [SELECT Id, Name FROM Pricebook2]){
            listPrecios.add(price);
        }
        
        //Obtengo los productos de salesforce
        for(Product2 prod : [SELECT Id, ProductCode, Name FROM Product2]){
            mapProd.put(prod.ProductCode, prod);
        }
        
        String IdTRegistroRedMotors = Schema.SObjectType.Account.getRecordTypeInfosByName().get('RedMotors-Altica').getRecordTypeId();
        for(TemporalOPFinanciamiento__c temp : listTemp){
            for(Account act : listAccount){
                if(act.Name.toLowerCase() == temp.Nombrecliente__c.toLowerCase() || act.Cedula__c == temp.Identificacioncliente__c){//Si la cuenta existe
                    existe = true;
                    tempA = act;
                    break;
                }
            }
            if(existe){//Si la cuenta existe
                //Se le asigna la cuenta existente en salesforce
                temp.IdCuenta__c = tempA.Id;
                existe = false;
            }else{
                //Se crea la cuenta nueva porque no existe en salesforce
                Account a = new Account();
                a.FirstName = temp.Nombrecliente__c.substringBefore(' ');
                a.LastName = temp.Nombrecliente__c.substringAfter(' ');
                a.PersonMobilePhone = temp.Telefonomovil__c;
                a.RecordTypeId = IdTRegistroRedMotors;
                if(temp.Identificacioncliente__c.length() == 9){
                    a.Tipo_de_Documento__c = 'Cedula';
                }else if(temp.Identificacioncliente__c.length() > 9 && temp.Identificacioncliente__c.length() < 12){
                    a.Tipo_de_Documento__c = 'Cédula Jurídica';
                }else{
                    a.Tipo_de_Documento__c = 'Pasaporte';
                }
                a.Cedula__c = temp.Identificacioncliente__c;
				a.PersonEmail = temp.Correoelectronico__c;
                //insert a;
                //temp.IdCuenta__c = a.Id;
				mapAccountUpdate.put(temp.Identificacioncliente__c, a);
            }
            for(Campaign cam : listCam){//Se le asigna el id de la campaña
                if(cam.Name.toLowerCase() == temp.Campana__c.toLowerCase()){
                    temp.IdCampana__c = cam.Id;
                }
            }
            
            //Si el producto es nuevo o usado o no esta disponible
            if(temp.Listapreasignada__c){
                //Si el producto es nuevo y no disponible
                if(temp.SubCategoria__c.toLowerCase() == 'nuevo' && temp.CodigoideVehiculo__c.toLowerCase() == 'no disponible' && temp.Modelovehiculo__c.toLowerCase() == 'no disponible'){
                    for(Pricebook2 l : listPrecios){//Se le asigna la lista de precios
                        System.debug('**** lista de precios **** ' + l.name);
                        if(l.name.toLowerCase() == 'precios - nuevos dummy'){
                            System.debug('****** entro asignacion lista de precios ****** ');
                            temp.IdListaPrecios__c = l.Id;
                            break;
                        }
                    }
                    temp.IdProducto__c = mapProd.get('Nuevo').Id;
                    temp.NombreProductoSF__c = mapProd.get('Nuevo').Name;
                    System.debug('***** nombre producto salesforce ***** ' + temp.NombreProductoSF__c);
                }else{//Si el producto es usado y no disponible
                    System.debug('****** producto usado y no disponible *****');
                    for(Pricebook2 l : listPrecios){//Se le asigna la lista de precios
                        System.debug('****** lista de precios *****' + l.name);
                        if(l.name.toLowerCase() == 'precios - usados dummy'){
                            temp.IdListaPrecios__c = l.Id;
                            break;
                        }
                    }
                    temp.IdProducto__c = mapProd.get('Usado').Id;
                    temp.NombreProductoSF__c = mapProd.get('Usado').Name;
                    temp.EsUsado__c = true;
                    temp.Creado_por__c = 'Hrojas';
                }
            }else{//Si el producto si existe en salesforce, es decir, no es nuevo y no es usado
                for(Pricebook2 l : listPrecios){
                    System.debug('**** lista precio no usado/nuevo **** ' + l);
                    size = l.name.length();
                    System.debug('****** size ***** ' + size);
                    System.debug('***** nombre ****** ' + l.Name.substring(size - 4, size) + ' **** ano vehiculo **** ' + temp.anovehiculo__c);
                    System.debug('****** marca vehiculo **** ' + temp.Marcavehiculo__c + ' **** ' + l.Name.substringBefore(' '));
					if(temp.Marcavehiculo__c.toLowerCase() == 'harley davidson' && l.Name == 'Harley Davidson - 2018'){
						temp.IdListaPrecios__c = l.Id;
						break;
					}
                    else if(l.Name.substring(size - 4, size) == temp.anovehiculo__c && temp.Marcavehiculo__c.toLowerCase() == l.Name.substringBefore(' ').toLowerCase()){
                        temp.IdListaPrecios__c = l.Id;
                        break;
                    }
                }
                temp.IdProducto__c = mapProd.get(temp.CodigoideVehiculo__c).Id;
                temp.NombreProductoSF__c = mapProd.get(temp.CodigoideVehiculo__c).Name;
            }
            //Si el campo 'creado por' contiene 'no disponible' o 'no estan en el catalogo' se busca el jefe de la sucursal y se le asigna a la Op
            System.debug('**** creado por **** ' + temp.Creado_por__c);
            if(temp.Creado_por__c.toLowerCase() == 'no disponible' || temp.Creado_por__c.toLowerCase() == 'no estan en el catalogo'){
                idJefe = buscarJefeSucursal(temp, listSucursales);
                System.debug('***** id jefe ***** ' + idJefe);
                temp.Creado_por__c = buscarAlias(idJefe, listUsuarios);
                temp.Cambiapropietario__c = true;
            }else{//Si el campo 'creado por' si contiene un alias pero se valida si este esta activo, si no esta activo se pone el alias del jefe de la sucursal
                esActivo = buscarActivo(temp.Creado_por__c, listUsuarios);
                if(!esActivo){
                    idJefe = buscarJefeSucursal(temp, listSucursales);
                    temp.Creado_por__c = buscarAlias(idJefe, listUsuarios);
                    temp.Cambiapropietario__c = true;
                }
            }
            for(User u : listUsuarios){
                if(temp.Propietario__c.toLowerCase() == u.Name.toLowerCase()){
                    System.debug('***** usuario asignado ***** ' + u.Name);
                    temp.IdPropietario__c = u.Id;
                    break;
                }
            }
            temp.FechaFinOpF__c = temp.FechaFinOpF__c.addHours(1);
            System.debug('****** FECHA_FIN ****** ' + temp.FechaFinOpF__c );
            //listUpdate.add(temp);
        }
        //System.debug('****** list update ****** ' + listUpdate + '****** ' + listUpdate.size());
        /*if(listUpdate.size() > 0){
            insert listUpdate;
        }
		if(mapAccountUpdate.size() > 0){
			insert mapAccountUpdate.values();
		}
		for(TemporalOPFinanciamiento__c temp : listTemp){
			if(temp.IdCuenta__c == null || temp.IdCuenta__c.length() == 0){
				temp.IdCuenta__c = mapAccountUpdate.get(temp.Identificacioncliente__c).Id;
			}
		}
    }
    
    public static void crearOp(List<TemporalOPFinanciamiento__c> listTemp){
        Map<String, String> mapUser = new Map<String, String>();
		Map<String, Sucursal__c> mapSucursales = new Map<String, Sucursal__c>();
		Map<String, Opportunity> mapUpdateOpp = new Map<String, Opportunity>();
		Map<String, OpportunityLineItem> mapUpdateProdOpp = new Map<String, OpportunityLineItem>();
		Map<String, Oportunidad_de_Financiamiento__c> mapUpdateOpF = new Map<String, Oportunidad_de_Financiamiento__c>();
        List<PricebookEntry> listPrecios = new List<PricebookEntry>();
        String tempMarca = '';
        String IdTRegistroOpFRedMotors = Schema.SObjectType.Oportunidad_de_Financiamiento__c.getRecordTypeInfosByName().get('RedMotors-Altica').getRecordTypeId();
        
        //Obtengo el nombre del jefe, gerente y director de cada sucursal
		for(Sucursal__c suc:[select Id,Name, Marca__c, 
                    DirectordeVentasBMW__c,
                    GerentedeSucursalBMW__c, 
                    JefeseSucursalBMW__c, 
                    DirectordeVentasPolaris__c, 
                    GerentedeSucursalPolaris__c, 
                    JefesdeSucursalPolaris__c, 
                    DirectordeVentasMini__c,
                    GerentedeSucursalMini__c,
                    JefesdeSucursalMini__c, 
                    DirectordeVentasKTM__c,
                    GerentedeSucursalKTM__c, 
                    JefesdeSucursalKTM__c, 
                    DirectordeVentasKawasaki__c,
                    GerentedeSucursalKawasaki__c, 
                    JefesdeSucursalKawasaki__c, 
                    DirectordeVentasMotorrad__c,
                    Gerente_de_SucursalMotorrad__c, 
                    JefedeSucursalMotorrad__c,
                    DirectordeVentasHarley__c,
                    GerentedeSucursalHarley__c,
                    JefedeSucursalHarley__c
                from Sucursal__c]){
                    mapSucursales.put(suc.Name,suc);
            }
		
		for(User u : [SELECT Id, Name, Alias FROM User]){
            mapUser.put(u.Alias, u.Id);
        }
        
        listPrecios = [SELECT ProductCode, Pricebook2.Id, Pricebook2.Name, UnitPrice FROM PricebookEntry];
        /*for(PricebookEntry price : [SELECT ProductCode, Pricebook2.Id, Pricebook2.Name, UnitPrice FROM PricebookEntry]){
            listPrecios.add(price);
        }
        
        for(TemporalOPFinanciamiento__c temp : listTemp){
            Opportunity op = new Opportunity();
            
            //Info Oportunidad
            op.Name = temp.Name + '-' + temp.Marcavehiculo__c + '-' + System.today().format();
            op.AccountId = temp.IdCuenta__c;
            op.Campana__c = temp.IdCampana__c;
            op.Sucursal__c = temp.Sucursal__c;
            //op.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('RedMotors-Altica').getRecordTypeId();
            /*if(temp.SubCategoria__c.toLowerCase() == 'nuevo'){
                System.debug('****** owner nuevo ****** ' + mapUser.get(temp.Creado_por__c));
                op.OwnerId = mapUser.get(temp.Creado_por__c);
            }else{
                op.OwnerId = temp.OwnerId;
            }
            op.OwnerId = '0050P00000742XP';//<- id usuario Rosella
            op.CloseDate = System.today();
            if(temp.SubCategoria__c.toLowerCase() == 'nuevo' && temp.Cambiapropietario__c){
                op.StageName = 'Cerrada Perdida';
                op.RazonVentaPerdida__c = 'Valor de recibo';
            }else if(temp.SubCategoria__c.toLowerCase() == 'nuevo' && !temp.Cambiapropietario__c){
                op.StageName = 'Oferta';
            }else if(temp.SubCategoria__c.toLowerCase() == 'usado'){
                op.StageName = 'Usada';
            }
            else{
                op.StageName = 'Oferta';
            }
            op.LeadSource = temp.Origen_candidato__c;
            op.ProcesoautomaticoOPF__c = true;
            op.Consentimientofinaciero__c = true;
            op.OFCreada__c = true;
            if(temp.EsUsado__c){
                op.Valor_Usado__c = temp.Valorfinanciamiento__c;
                op.MarcaUsado__c = temp.Marcavehiculo__c;
                op.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Oportunidad Usados').getRecordTypeId();
            }else{
                System.debug('****** marca vehiculo ***** ' + temp.Marcavehiculo__c);
                if(temp.Marcavehiculo__c.toLowerCase() == 'kawasaki' || temp.Marcavehiculo__c.toLowerCase() == 'polaris' || temp.Marcavehiculo__c.toLowerCase() == 'motorrad'){
                    tempMarca = temp.Marcavehiculo__c.substring(0,1).toUpperCase() + temp.Marcavehiculo__c.substring(1).toLowerCase();
                    System.debug('****** marca vehiculo 2 ******' + tempMarca);
                    op.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(tempMarca).getRecordTypeId();
                }else{
                    op.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(temp.Marcavehiculo__c).getRecordTypeId();
                }
            }
            op.IngresoAproximado__c = temp.Ingreso__c;
            op.MonedaIngreso__c = temp.Monedaingreso__c;
            op.Prima__c = temp.Primavehiculo__c;
            op.LlaveOpF__c = temp.Llave__c;
            op.Pricebook2Id = temp.IdListaPrecios__c;
            op.Enganche_monto__c = 1500;
            op.Enganche_recibo__c = '123';
            op.Realiza_Test_Drive__c = true;
			op.Plazo_en_Meses__c = temp.Plazo__c;
			// Se asigna el jefe, director y gerente de la sucursal 
			op.SucursalId__c = mapSucursales.get(op.Sucursal__c).Id;
            //Marca: BMW
            if(temp.Marcavehiculo__c == 'BMW'){
                if(mapSucursales.get(op.Sucursal__c).DirectordeVentasBMW__c!=null)
                    op.DirectorVentas__c = mapSucursales.get(op.Sucursal__c).DirectordeVentasBMW__c;
                        
                if(mapSucursales.get(op.Sucursal__c).GerentedeSucursalBMW__c!=null)
                    op.GerenteSucursal__c = mapSucursales.get(op.Sucursal__c).GerentedeSucursalBMW__c;
                        
                if(mapSucursales.get(op.Sucursal__c).JefeseSucursalBMW__c!=null)
                    op.JefeSucursal__c = mapSucursales.get(op.Sucursal__c).JefeseSucursalBMW__c;                       
            }
            //Marca: Polaris
            if(temp.Marcavehiculo__c == 'Polaris'){
                if(mapSucursales.get(op.Sucursal__c).DirectordeVentasPolaris__c!=null)
                    op.DirectorVentas__c = mapSucursales.get(op.Sucursal__c).DirectordeVentasPolaris__c;
                        
                if(mapSucursales.get(op.Sucursal__c).GerentedeSucursalPolaris__c!=null)
                    op.GerenteSucursal__c = mapSucursales.get(op.Sucursal__c).GerentedeSucursalPolaris__c;
                        
                if(mapSucursales.get(op.Sucursal__c).JefesdeSucursalPolaris__c!=null)
                    op.JefeSucursal__c = mapSucursales.get(op.Sucursal__c).JefesdeSucursalPolaris__c;                     
                     
            }
            //Marca: MINI
            if(temp.Marcavehiculo__c == 'MINI'){
                if(mapSucursales.get(op.Sucursal__c).DirectordeVentasMini__c!=null)
                    op.DirectorVentas__c = mapSucursales.get(op.Sucursal__c).DirectordeVentasMini__c;
                        
                if(mapSucursales.get(op.Sucursal__c).GerentedeSucursalMini__c!=null)
                    op.GerenteSucursal__c = mapSucursales.get(op.Sucursal__c).GerentedeSucursalMini__c;
                        
                if(mapSucursales.get(op.Sucursal__c).JefesdeSucursalMini__c!=null)
                    op.JefeSucursal__c = mapSucursales.get(op.Sucursal__c).JefesdeSucursalMini__c;                        
                     
            }
            //Marca: KTM
            if(temp.Marcavehiculo__c == 'KTM'){
                if(mapSucursales.get(op.Sucursal__c).DirectordeVentasKTM__c!=null)
                    op.DirectorVentas__c = mapSucursales.get(op.Sucursal__c).DirectordeVentasKTM__c;
                        
                if(mapSucursales.get(op.Sucursal__c).GerentedeSucursalKTM__c!=null)
                    op.GerenteSucursal__c = mapSucursales.get(op.Sucursal__c).GerentedeSucursalKTM__c;
                        
                if(mapSucursales.get(op.Sucursal__c).JefesdeSucursalKTM__c!=null)
                    op.JefeSucursal__c = mapSucursales.get(op.Sucursal__c).JefesdeSucursalKTM__c;                     
                     
            }
            //Marca: Kawasaki
            if(temp.Marcavehiculo__c == 'Kawasaki'){
                if(mapSucursales.get(op.Sucursal__c).DirectordeVentasKawasaki__c!=null)
                    op.DirectorVentas__c = mapSucursales.get(op.Sucursal__c).DirectordeVentasKawasaki__c;
                        
                if(mapSucursales.get(op.Sucursal__c).GerentedeSucursalKawasaki__c!=null)
                    op.GerenteSucursal__c = mapSucursales.get(op.Sucursal__c).GerentedeSucursalKawasaki__c;
                        
                if(mapSucursales.get(op.Sucursal__c).JefesdeSucursalKawasaki__c!=null)
                    op.JefeSucursal__c = mapSucursales.get(op.Sucursal__c).JefesdeSucursalKawasaki__c;                        
                     
            }               
            //Marca: Motorrad
            if(temp.Marcavehiculo__c == 'Motorrad'){
                if(mapSucursales.get(op.Sucursal__c).DirectordeVentasMotorrad__c!=null)
                    op.DirectorVentas__c = mapSucursales.get(op.Sucursal__c).DirectordeVentasMotorrad__c;
                        
                if(mapSucursales.get(op.Sucursal__c).Gerente_de_SucursalMotorrad__c!=null)
                    op.GerenteSucursal__c = mapSucursales.get(op.Sucursal__c).Gerente_de_SucursalMotorrad__c;
                        
                if(mapSucursales.get(op.Sucursal__c).JefedeSucursalMotorrad__c!=null)
                    op.JefeSucursal__c = mapSucursales.get(op.Sucursal__c).JefedeSucursalMotorrad__c;                     
                     
            } 
            //Marca: Harley Davidson
            if(temp.Marcavehiculo__c == 'Harley Davidson'){
                if(mapSucursales.get(op.Sucursal__c).DirectordeVentasHarley__c != null)
                    op.DirectorVentas__c = mapSucursales.get(op.Sucursal__c).DirectordeVentasHarley__c;
                        
                if(mapSucursales.get(op.Sucursal__c).GerentedeSucursalHarley__c != null)
                    op.GerenteSucursal__c = mapSucursales.get(op.Sucursal__c).GerentedeSucursalHarley__c;
                        
                if(mapSucursales.get(op.Sucursal__c).JefedeSucursalHarley__c != null)
                    op.JefeSucursal__c = mapSucursales.get(op.Sucursal__c).JefedeSucursalHarley__c;                     
            }
			op.RT_Lead__c = temp.Marcavehiculo__c;
			mapUpdateOpp.put(temp.Llave__c, op);
		}	

		//Se guardan todas las oportunidades de negocio creadas
		if(mapUpdateOpp.size() > 0){
			TriggerHandler.bypass('OpportunityTriggerHandler');
            insert mapUpdateOpp.values();
			TriggerHandler.clearBypass('OpportuntiyTriggerHandler');
		}

		for(TemporalOPFinanciamiento__c temp : listTemp){
			//Info Producto de la Oportunidad
            OpportunityLineItem prod = new OpportunityLineItem();
            prod.OpportunityId = mapUpdateOpp.get(temp.Llave__c).Id;
            prod.Product2Id = temp.IdProducto__c;
            prod.Quantity = 1;
            prod.TotalPrice = temp.Valorfinanciamiento__c;
            System.debug('****** pricebook2 ****** ' + mapUpdateOpp.get(temp.Llave__c).Pricebook2Id);
            System.debug('****** ProductCode ****** ' + temp.CodigoideVehiculo__c);
            //prod.PriceBookEntryId = [SELECT Id FROM PricebookEntry WHERE Pricebook2.Id =: op.Pricebook2Id and ProductCode =: temp.CodigoideVehiculo__c].Id;
			mapUpdateProdOpp.put(temp.Llave__c, prod);   
		}

		//Se guardan todos los productos de oportunidad de negocio creados
		if(mapUpdateProdOpp.size() > 0){
			TriggerHandler.bypass('OpportunityLineItemTriggerHandler');
            insert mapUpdateProdOpp.values();
            TriggerHandler.clearBypass('OpportunityLineItemTriggerHandler');
		}
		
		for(TemporalOPFinanciamiento__c temp : listTemp){
			//Info Oportunidad de Financiamiento
            Oportunidad_de_Financiamiento__c opF = new Oportunidad_de_Financiamiento__c();
            opF.Name = mapUpdateOpp.get(temp.Llave__c).Name;
            opF.RecordTypeId = IdTRegistroOpFRedMotors;
            opF.Oportunidad__c = mapUpdateOpp.get(temp.Llave__c).Id;
            opF.OwnerId = '0050P00000749UM';//<- id usuario Hernan
            opF.Producto__c = temp.CodigoideVehiculo__c;
            opF.Aprobador__c = '0050P00000749UM';//<- id usuario Hernan
            opF.FechaInicioOF__c = temp.FechaInicioOpF__c;
            opF.FechaCambioEstadoOF__c = temp.FechaFinOpF__c;
            opF.Email__c = temp.Correoelectronico__c;
            opF.Ingreso__c = temp.Ingreso__c;
            opF.ModenaIngreso__c = temp.Monedaingreso__c;
            opF.Ano__c = temp.anovehiculo__c;
            opF.Modelo__c = temp.Modelovehiculo__c;
            opF.Fecha_Formalizacion__c = temp.Fecha_Formalizacion__c;
            opF.Excepcion__c = temp.Excepcion__c;
            opF.Nombre_Cliente_Altica__c = mapUpdateOpp.get(temp.Llave__c).AccountId;
			opF.Plazo__c = temp.Plazo__c;
            if(!temp.EsUsado__c){
                for(PricebookEntry precio : listPrecios){
                    if(precio.ProductCode == temp.CodigoideVehiculo__c && precio.Pricebook2.Id == mapUpdateOpp.get(temp.Llave__c).Pricebook2Id){
                        System.debug('***** lista precio ***** ' + precio);
                        opF.PrecioLista__c = precio.UnitPrice;
                        break;
                    }               
                }
                //opF.PrecioLista__c = [SELECT ListPrice FROM OpportunityLineItem WHERE OpportunityId =: op.Id].ListPrice;
            }
            opF.TipoProducto__c = temp.Productofinanciero__c;
            opF.Categoria__c = temp.Categor_a__c;
            opF.Subcategoria__c = temp.SubCategoria__c;
            opF.CuotaTotal__c = temp.Cuotatotal__c;
            opF.Observaciones__c = temp.ComentariosInternos__c;
            opF.Score__c = temp.Score__c;
            opF.Moneda__c = temp.Moneda__c;
            opF.Estado__c = temp.EstadoOpF__c;
            opF.ComentariosAltica__c = temp.Comentarios_Financieros__c;
			opF.Prima_Altica__c = temp.Primavehiculo__c;
			opF.Cantidad__c = 1;
            if(temp.NombreProductoSF__c == 'Nuevo - Dummy' || temp.NombreProductoSF__c == 'Usado - Dummy'){
                opF.Valor_OF_Carga__c = temp.Valorfinanciamiento__c;
            }
			mapUpdateOpF.put(temp.Llave__c, opF);
		}

		//Se guardan todas las oportunidades de financiamiento creadas
		if(mapUpdateOpF.size() > 0){
			TriggerHandler.bypass('OportunidadFinanciamientoTriggerHandler');
            insert mapUpdateOpF.values();
			TriggerHandler.clearBypass('OportunidadFinanciamientoTriggerHandler');
		}
    }
    
    public static String buscarJefeSucursal(TemporalOPFinanciamiento__c temp, List<Sucursal__c> tempS){
        String id = '';
        System.debug('****** metodo buscarJefeSucursal *****' + temp);        
        for(Sucursal__c suc : tempS){
            System.debug('****** sucursal ******** ' + suc);
            if(temp.Sucursal__c.toLowerCase() == suc.Name.toLowerCase()){
                System.debug('***** validacion sucursales *****' + temp.Sucursal__c + '***** ' + suc.Name);
                if(temp.Marcavehiculo__c.toLowerCase() == 'bmw'){
                    if(suc.JefeseSucursalBMW__c != null){
                        id = suc.JefeseSucursalBMW__c;
                    }else{
                        id = suc.DirectordeVentasBMW__c;
                    }
                    System.debug('***** entro BWM **** ' + id);
                }else if(temp.Marcavehiculo__c.toLowerCase() == 'motorrad'){
                    if(suc.JefedeSucursalMotorrad__c != null){
                        id = suc.JefedeSucursalMotorrad__c;
                    }else{
                        id = suc.DirectordeVentasMotorrad__c;
                    }
                    System.debug('***** entro Motorrad **** ' + id);
                }else if(temp.Marcavehiculo__c.toLowerCase() == 'mini'){
                    if(suc.JefesdeSucursalMini__c != null){
                        System.debug('******* entro jefe ***** ' + suc.JefesdeSucursalMini__c);
                        id = suc.JefesdeSucursalMini__c;
                    }else{
                        id = suc.DirectordeVentasMini__c;
                    }
                    System.debug('***** entro MINI **** ' + id);
                }else if(temp.Marcavehiculo__c.toLowerCase() == 'ktm'){
                    if(suc.JefesdeSucursalKTM__c != null){
                        id = suc.JefesdeSucursalKTM__c;
                    }else{
                        id = suc.DirectordeVentasKTM__c;
                    }
                    System.debug('***** entro KTM **** ' + id);
                }else if(temp.Marcavehiculo__c.toLowerCase() == 'kawasaki'){
                    if(suc.JefesdeSucursalKawasaki__c != null){
                        id = suc.JefesdeSucursalKawasaki__c;
                    }else{
                        id = suc.DirectordeVentasKawasaki__c;
                    }
                    System.debug('***** entro Kawa **** ' + id);
                }else if(temp.Marcavehiculo__c.toLowerCase()  == 'polaris'){
                    if(suc.JefesdeSucursalPolaris__c != null){
                        id = suc.JefesdeSucursalPolaris__c;
                    }else{
                        id = suc.DirectordeVentasPolaris__c;
                    }
                    System.debug('***** entro Polaris**** ' + id);
                }else{
					if(suc.JefedeSucursalHarley__c != null){
						id = suc.JefedeSucursalHarley__c;
					}else{
						id = suc.DirectordeVentasHarley__c;
					}
				}
                break;
            }
        }
        return id;
    }
    
    public static String buscarAlias(String idJefe, List<User> tempU){
        String alias = '';
        for(User u : tempU){
           System.debug('****** USER TEST ****** ' + u);
           System.debug('****** IDJEFE ****** ' + idJefe);
            if(u.Id == idJefe.substring(0,15)){
                System.debug('****** user ****** ' + u);
                alias = u.Alias;
                break;
            }
           
        }
        System.debug('****** alias: ****** ' + alias);
        return alias;   
    }
    
    public static Boolean buscarActivo(String alias, List<User> tempU){
        Boolean existe = false;
        for(User u : tempU){
            if(u.Alias == alias){
                if(u.isActive){
                    existe = true;
                    break;
                }else{
                    return existe;
                }
            }
        }
        return existe;
    }  */
}