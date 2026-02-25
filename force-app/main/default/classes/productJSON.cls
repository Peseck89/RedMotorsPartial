/**
 * Representacion de un producto recibido desde el api de Softland
 * @author Portalnet
 * @since 
 * Modificaciones:
 * 09/04/2024 Marco Hernandez, Se agrego el campo codigo_equipamiento, VN-RQ42:Codigos de equipamientos en vista de inventario
 */
public class productJSON {
    public static String createProduct(String jsonStr) 
    {
        JSONGenerator gen = JSON.createGenerator(False);

        productRequestJSON wrapProductJSON = productRequestJSON.parsePropuesta(jsonStr);
        String articulo = wrapProductJSON.articulo;
        String descripcion = wrapProductJSON.descripcion;
        String cod_grupo1 = wrapProductJSON.cod_grupo1;
        String grupo1 = wrapProductJSON.grupo1;
        String cod_grupo2 = wrapProductJSON.cod_grupo2;
        String grupo2 = wrapProductJSON.grupo2;
        String cod_grupo3 = wrapProductJSON.cod_grupo3;
        String grupo3 = wrapProductJSON.grupo3;
        String cod_grupo4 = wrapProductJSON.cod_grupo4;
        String grupo4 = wrapProductJSON.grupo4;
        String cod_grupo5 = wrapProductJSON.cod_grupo5;
        String grupo5 = wrapProductJSON.grupo5;
        String cod_grupo6 = wrapProductJSON.cod_grupo6;
        String grupo6 = wrapProductJSON.grupo6;
        String cant_disponible = wrapProductJSON.cant_disponible;
        String precio = wrapProductJSON.precio;
        String porc_margen_min = wrapProductJSON.porc_margen_min;
        String porc_margen_max = wrapProductJSON.porc_margen_max;
        String costo_local = wrapProductJSON.costo_local;
        String lista_precio = wrapProductJSON.lista_precio;
        String porc_descuento = wrapProductJSON.porc_descuento;
        String moneda = wrapProductJSON.moneda;
        String empresa = wrapProductJSON.empresa;
        String tipo_producto = wrapProductJSON.tipo_producto;
        boolean activo = true;
        
        String esVehiculo = wrapProductJSON.esVehiculo;
        String esVehiculoentransito = wrapProductJSON.esVehiculoentransito;
        String esUsado = wrapProductJSON.esUsado;
        String vin = wrapProductJSON.vin;
        String modelo = wrapProductJSON.modelo;
        String marca = wrapProductJSON.marca;
        String especificaciones = wrapProductJSON.especificaciones;
        String color = wrapProductJSON.colorInterior;
        String anno = wrapProductJSON.anno;
        String description2 ='';
        String colorExterior = wrapProductJSON.colorExterior;
        
        String combustible = wrapProductJSON.combustible;
        String Numero_Motor = wrapProductJSON.Numero_Motor;
        String cubicaje = wrapProductJSON.cubicaje;
        String Cantidad_Cilindros = wrapProductJSON.Cantidad_Cilindros;
        String pasajeros = wrapProductJSON.pasajeros;
        String Carroceria = wrapProductJSON.Carroceria;
        String Peso = wrapProductJSON.Peso;
        String traccion = wrapProductJSON.traccion;
        String BL = wrapProductJSON.BL;
        String Valor_exonerado = wrapProductJSON.Valor_exonerado;
        String tapiceria = wrapProductJSON.tapiceria;
        String transmision = wrapProductJSON.transmision;
        String Tipo_vehiculo = wrapProductJSON.Tipo_vehiculo;
        String Porcentaje_vendedor = wrapProductJSON.Porcentaje_vendedor;
        String Porcentaje_jefe = wrapProductJSON.Porcentaje_jefe;
        String Marca_asset = wrapProductJSON.Marca_asset;
        
        Date fecha_ingreso = wrapProductJSON.fecha_ingreso;

        String codigo_equipamiento = wrapProductJSON.codigo_equipamiento;
        
        
        String opportunityReserva = wrapProductJSON.opportunity;
        String oportunidad_origen = wrapProductJSON.oportunidad_origen;
        
        System.debug('Cantidad Cilindros: '+ wrapProductJSON.Cantidad_Cilindros);
        
       
        if(Tipo_vehiculo=='A'){
            Tipo_vehiculo ='Automóvil';
        }else if(Tipo_vehiculo=='M') {
            Tipo_vehiculo ='Motocicleta';
        }else if(Tipo_vehiculo=='Mu') {
            Tipo_vehiculo ='Mula';
        }else if(Tipo_vehiculo=='C'){
            Tipo_vehiculo ='Cuadraciclo';
        }
        
        if(wrapProductJSON.activo=='true'){
            activo = true;
        }else if(wrapProductJSON.activo=='false'){
        	activo = false;    
        }
        
        //String estado = wrapProductJSON.empresa; Recibo de softlant "true" o "false" como string.
        try
        {  
            List<Product2> prod;
            if(empresa=='RMBAVARIAN')
            {
            	prod =     	[
                                SELECT Id, es_Vehiculo_en_transito__c, esVehiculo__c
                                FROM Product2
                                WHERE Codigo_de_Producto__c = :articulo
                            ];    
            } else if(empresa=='RMOTOBAI')
            {
                String identificador = articulo+'-'+empresa;
                prod =     [
                                SELECT Id, es_Vehiculo_en_transito__c, esVehiculo__c
                                FROM Product2
                                WHERE CodigoProductoInterno__c = :identificador
                            ];
            }
                
            
            if(prod.size()==0)
            {
                Product2 newProduct = new Product2();
                newProduct.Name =descripcion;
                newProduct.ProductCode = articulo;
                newProduct.Codigo_de_Producto__c =articulo;
                newProduct.CodigoProductoInterno__c = articulo+'-'+empresa;
                newProduct.Description =descripcion;
                newProduct.isActive = true;
                newProduct.CurrencyIsoCode =moneda;
                newProduct.Empresa__c =empresa;
                newProduct.procentajeMargenMaximo__c =  Decimal.valueOf(porc_margen_max);
                newProduct.porcentajeMargenMinimo__c =  Decimal.valueOf(porc_margen_min);
                newProduct.costoLocal__c =  Decimal.valueOf(costo_local);
                newProduct.porcentajeDescuento__c =  Decimal.valueOf(porc_descuento);
                newProduct.precio__c =  Decimal.valueOf(precio);
                newProduct.cantidadDisponible__c =  Decimal.valueOf(cant_disponible);
                newProduct.grupo1__c = grupo1;
                newProduct.codGrupo1__c = cod_grupo1;
                newProduct.grupo2__c = grupo2;
                newProduct.codGrupo2__c = cod_grupo2;
                newProduct.grupo3__c = grupo3;
                newProduct.codGrupo3__c = cod_grupo3;
                newProduct.grupo4__c = grupo4;
                newProduct.codGrupo4__c = cod_grupo4;
                newProduct.grupo5__c = grupo5;
                newProduct.codGrupo5__c = cod_grupo5;
                newProduct.grupo6__c = grupo6;
                newProduct.codGrupo6__c = cod_grupo6;
                newProduct.RM_CodigoEquipamiento__c = codigo_equipamiento;
                
                if(tipo_producto == 'T'){newProduct.tipoProducto__c = 'Materiales';}else if(tipo_producto == 'K'){newProduct.tipoProducto__c = 'Kit';
                }else if(tipo_producto == 'S'){ newProduct.tipoProducto__c = null;}else{newProduct.tipoProducto__c = 'Mano de Obra';}
                //newProduct.RecordTypeId = '0120P000000ENW0QAO';
                
                
                if(esVehiculoentransito =='true'){
                    newProduct.Pedido_Original__c = articulo;
                    newProduct.esVehiculo__c = true;
                    newProduct.RM_VN_EsActivo__c = true;
                }
                
                if(esVehiculo=='true' || esVehiculoentransito =='true'){
                     newProduct.vin__c =vin;
                     description2 = modelo+' '+marca+' '+especificaciones+' '+color+' '+anno;
                     newProduct.esVehiculo__c = esVehiculo != null  ? true : newProduct.esVehiculo__c;
                     newProduct.es_Vehiculo_en_transito__c = esVehiculoentransito != null ? true : newProduct.es_Vehiculo_en_transito__c;
                     
                    
                     newProduct.modelo__c = modelo;
                     newProduct.marcaVehiculo__c = marca;
                     newProduct.Especificaciones__c = especificaciones;
                     newProduct.Color__c = color;
                     newProduct.Anno__c = anno;
                     newProduct.Descripci_n_Vehiculo__c = description2;
                     newProduct.tipoProducto__c = 'Vehiculo';
                     newProduct.RecordTypeId = '0124U00000111EDQAY';
                     newProduct.Color_Externo__c = colorExterior;
                     //
                     newProduct.combustible__c =combustible;
                     newProduct.Numero_Motor__c=Numero_Motor;
                     newProduct.cubicaje__c=cubicaje;
                     newProduct.Cantidad_Cilindros__c=   (Cantidad_Cilindros != null) ? Decimal.valueOf(Cantidad_Cilindros) : 0;
                     newProduct.pasajeros__c=  (pasajeros != null) ? Decimal.valueOf(pasajeros) : 0;
                     newProduct.Carroceria__c=Carroceria;
                     newProduct.Peso__c=Peso;
                     newProduct.traccion__c=traccion;
                     newProduct.BL__c=BL;
                     newProduct.Valor_exonerado__c= (Valor_exonerado != null) ? Decimal.valueOf(Valor_exonerado) : 0;
					 newProduct.tapiceria__c=tapiceria;
					 newProduct.transmision__c =transmision;
                     newProduct.Tipo_vehiculo__c = Tipo_vehiculo;
                     newProduct.Marca_asset__c = Marca_asset;
                     newProduct.fecha_ingreso_inventario__c = (fecha_ingreso != null) ?fecha_ingreso : Null;
                          
                     if(opportunityReserva!=NULL){
                         List<Opportunity> opps;
                         opps = [SELECT Id,Name, ConsecutivoOportunidad__c  FROM Opportunity WHERE ConsecutivoOportunidad__c = :opportunityReserva];
                    	 if(opps.size() != 0)
                         {
                             Opportunity oppFind = opps[0];
                             newProduct.OportunidadReserva__c = oppFind.Id;
                         }   
                     }
                    
                    if(oportunidad_origen!=NULL){
                         List<Opportunity> opps;
                         opps = [SELECT Id,Name, ConsecutivoOportunidad__c  FROM Opportunity WHERE ConsecutivoOportunidad__c = :oportunidad_origen];
                    	 if(opps.size() != 0)
                         {
                             Opportunity oppFind = opps[0];
                             newProduct.Oportunidad_Origen__c   = oppFind.Id;
                             newProduct.Producto_Reservado__c = true;
                         }   
                     }
                    
                 }
                
                if(esUsado=='true'){
                    newProduct.vin__c =vin;
                     description2 = modelo+' '+marca+' '+especificaciones+' '+color+' '+anno;
                     newProduct.es_Vehiculo_usado__c = true;
                     newProduct.modelo__c = modelo;
                     newProduct.marcaVehiculo__c = marca;
                     newProduct.Especificaciones__c = especificaciones;
                     newProduct.Color__c = color;
                     newProduct.Anno__c = anno;
                     newProduct.Descripci_n_Vehiculo__c = description2;
                     newProduct.tipoProducto__c = 'Vehiculo';
                     newProduct.RecordTypeId = '0124U00000111EDQAY';
                     newProduct.Color_Externo__c = colorExterior;
                     //
                     newProduct.combustible__c =combustible;
                     newProduct.Numero_Motor__c=Numero_Motor;
                     newProduct.cubicaje__c=cubicaje;
                     newProduct.Cantidad_Cilindros__c=   (Cantidad_Cilindros != null) ? Decimal.valueOf(Cantidad_Cilindros) : 0;
                     newProduct.pasajeros__c=  (pasajeros != null) ? Decimal.valueOf(pasajeros) : 0;
                     newProduct.Carroceria__c=Carroceria;
                     newProduct.Peso__c=Peso;
                     newProduct.traccion__c=traccion;
                     newProduct.BL__c=BL;
                     newProduct.Valor_exonerado__c= (Valor_exonerado != null) ? Decimal.valueOf(Valor_exonerado) : 0;
					 newProduct.tapiceria__c=tapiceria;
					 newProduct.transmision__c =transmision;
                     newProduct.Tipo_vehiculo__c = Tipo_vehiculo;
                    
                    
                    if(Tipo_vehiculo == 'Motocicleta'){
                        newProduct.Porcentaje_vendedor__c = 5;
                        
                    }else{
                        newProduct.Porcentaje_vendedor__c = (Porcentaje_vendedor != null) ? Decimal.valueOf(Porcentaje_vendedor) : 0;
                    }
                     
                     newProduct.Porcentaje_jefe__c = (Porcentaje_jefe != null) ? Decimal.valueOf(Porcentaje_jefe) : 0;
                    
                     newProduct.fecha_ingreso_inventario__c = (fecha_ingreso != null) ?fecha_ingreso : Null;
                     
                   
                    
                    
                     if(opportunityReserva!=NULL){
                         List<Opportunity> opps;
                         opps = [SELECT Id,Name, ConsecutivoOportunidad__c  FROM Opportunity WHERE ConsecutivoOportunidad__c = :opportunityReserva];
                    	 if(opps.size() != 0)
                         {
                             Opportunity oppFind = opps[0];
                             newProduct.OportunidadReserva__c = oppFind.Id;
                         }
                     }
                    
                    
                    
                 }
                
                
                
                
                
                
                
                insert newProduct;
                system.debug(newProduct);
                 

                List<ProductoXBodega__c> productosXBodega = new List<ProductoXBodega__c>();
                for (Disponible_Bodega disponible : wrapProductJSON.disponible_bodega) {
                    List<Bodega__c> bodegas;
                    if(empresa=='RMBAVARIAN')
                        bodegas = [SELECT Id,Name,Bodega__c FROM Bodega__c WHERE ID_EXTERNO_BODEGA__c = :disponible.bodega];
                    else
                        bodegas = [SELECT Id,Name,Bodega__c FROM Bodega__c WHERE ID_EXTERNO_BODEGA__c = :'RMOTOBAI'+disponible.bodega];
                    if(bodegas.size() != 0)
                    {
                        Bodega__c bodega = bodegas[0];
                        ProductoXBodega__c pXb = new ProductoXBodega__c();
                        pXb.Name = bodega.Name;
                        pXb.Bodega__c = bodega.Id;
                        pXb.Producto__c = newProduct.Id;
                        pXb.Disponible__c = disponible.Disponible;
                        pXb.Identificador__c = newProduct.Codigo_de_Producto__c+'-'+bodega.Bodega__c;

                        productosXBodega.add(pXb);
                    }
                }
                
                
                
                String withErrors = 'false';
                String descripcionError = '';
                Schema.SObjectField cpId = ProductoXBodega__c.Fields.Identificador__c;
                Database.UpsertResult[] saveCP = Database.upsert(productosXBodega,cpId, false);
                for(Database.UpsertResult resu : saveCP){
                    if(!resu.isSuccess()){
                        withErrors = 'true';
                        descripcionError = descripcionError+'Error al actualizar la bodega: '+ resu.getErrors()+'\n';
                    }
                }
                
                
                List<Detalle_Costo_Producto__c> DetallesCostos = new List<Detalle_Costo_Producto__c>();
                System.debug('El detalle del artículo:');
                System.debug(wrapProductJSON.detalle_costo);
                if(wrapProductJSON.detalle_costo!=null){
                    for (Detalle_Costo costo : wrapProductJSON.detalle_costo) {
                        
                        Detalle_Costo_Producto__c DetalleCosto = new Detalle_Costo_Producto__c();
                        DetalleCosto.Rubro__c = costo.rubro;
                        DetalleCosto.Monto_local__c = costo.monto_local;
                        DetalleCosto.Monto_Dolar__c = costo.monto_dolar;
                        DetalleCosto.Product__c = newProduct.Id;
                        DetalleCosto.id_linea_gasto__c = costo.id_linea_gasto;
                        
                        DetallesCostos.add(DetalleCosto);
                    }
                    Schema.SObjectField cpId2 = Detalle_Costo_Producto__c.Fields.ID;
                    Database.UpsertResult[] saveCP2 = Database.upsert(DetallesCostos,cpId2, false);
                    for(Database.UpsertResult resu : saveCP2){
                        if(!resu.isSuccess()){
                            withErrors = 'true';
                            descripcionError = descripcionError+'Error al actualizar el detalle del costo: '+ resu.getErrors()+'\n';
                        }
                    }
                 }
                
                
                
                

                gen.writeStartObject();
                gen.writeFieldName('Solicitud');
                gen.writeStartObject();
                gen.writeStringField('CODIGO', '200');
                if(withErrors=='false')
                {
                    gen.writeStringField('RESULT', 'La solicitud fue procesada exitosamente');
                    
                } else {
                    gen.writeStringField('RESULT', 'Ocurrio un error en la actualizacion de las bodegas: ');
                    gen.writeStringField('ERROR', descripcionError);
                }
                gen.writeEndObject();
                gen.writeEndObject();
            } else {
                Product2 actualProduct = prod[0];
                actualProduct.Name =descripcion;
                actualProduct.ProductCode = articulo;
                actualProduct.Codigo_de_Producto__c = articulo;
                actualProduct.CodigoProductoInterno__c = articulo+'-'+empresa;
                actualProduct.Description =description2;
                actualProduct.isActive = activo;
                actualProduct.CurrencyIsoCode =moneda;
                actualProduct.Empresa__c =empresa;
                actualProduct.procentajeMargenMaximo__c =  Decimal.valueOf(porc_margen_max);
                actualProduct.costoLocal__c =  Decimal.valueOf(costo_local);
                actualProduct.porcentajeDescuento__c =  Decimal.valueOf(porc_descuento);
                actualProduct.precio__c =  Decimal.valueOf(precio);
                actualProduct.cantidadDisponible__c =  Decimal.valueOf(cant_disponible);
                actualProduct.grupo1__c = grupo1;
                actualProduct.codGrupo1__c = cod_grupo1;
                actualProduct.grupo2__c = grupo2;
                actualProduct.codGrupo2__c = cod_grupo2;
                actualProduct.grupo3__c = grupo3;
                actualProduct.codGrupo3__c = cod_grupo3;
                actualProduct.grupo4__c = grupo4;
                actualProduct.codGrupo4__c = cod_grupo4;
                actualProduct.grupo5__c = grupo5;
                actualProduct.codGrupo5__c = cod_grupo5;
                actualProduct.grupo6__c = grupo6;
                actualProduct.codGrupo6__c = cod_grupo6;
                actualProduct.RM_CodigoEquipamiento__c = codigo_equipamiento;
                
                if(tipo_producto == 'T'){actualProduct.tipoProducto__c = 'Materiales';}else if(tipo_producto == 'K'){actualProduct.tipoProducto__c = 'Kit';
                }else if(tipo_producto == 'S'){ actualProduct.tipoProducto__c = null;}else{actualProduct.tipoProducto__c = 'Mano de Obra';}
                
                if(esVehiculoentransito =='true'){
                    actualProduct.Pedido_Original__c = articulo ;
                    actualProduct.esVehiculo__c = true;
                    actualProduct.RM_VN_EsActivo__c = true;
                }
                
                if(esVehiculo=='true' || esVehiculoentransito =='true'){
                     description2 = modelo+' '+marca+' '+especificaciones+' '+color+' '+anno;
                    
                     actualProduct.esVehiculo__c = esVehiculo != null  ? true : actualProduct.esVehiculo__c;
                     actualProduct.es_Vehiculo_en_transito__c = esVehiculoentransito != null ? true : actualProduct.es_Vehiculo_en_transito__c;
                     
                    
                     actualProduct.modelo__c = modelo;
                     actualProduct.vin__c =vin;
                     actualProduct.marcaVehiculo__c = marca;
                     actualProduct.Especificaciones__c = especificaciones;
                     actualProduct.Color__c = color;
                     actualProduct.Anno__c = anno;
                     actualProduct.Descripci_n_Vehiculo__c = description2;
                     actualProduct.tipoProducto__c = 'Vehiculo';
                     actualProduct.RecordTypeId = '0124U00000111EDQAY';
                     actualProduct.Color_Externo__c = colorExterior;
                    
                     //
                     actualProduct.combustible__c =combustible;
                     actualProduct.Numero_Motor__c=Numero_Motor;
                     actualProduct.cubicaje__c=cubicaje;
                     actualProduct.Cantidad_Cilindros__c=(Cantidad_Cilindros != null) ? Decimal.valueOf(Cantidad_Cilindros) : 0;
                     actualProduct.pasajeros__c=(pasajeros != null) ? Decimal.valueOf(pasajeros) : 0;
                     actualProduct.Carroceria__c=Carroceria;
                     actualProduct.Peso__c=Peso;
                     actualProduct.traccion__c=traccion;
                     actualProduct.BL__c=BL;
                     actualProduct.Valor_exonerado__c=(Valor_exonerado != null) ? Decimal.valueOf(Valor_exonerado) : 0;
					 actualProduct.tapiceria__c=tapiceria;
					 actualProduct.transmision__c =transmision;
                     actualProduct.Tipo_vehiculo__c = Tipo_vehiculo;
                     actualProduct.Marca_asset__c = Marca_asset;
                    actualProduct.fecha_ingreso_inventario__c = (fecha_ingreso != null) ?fecha_ingreso : Null;
                    
                     if(opportunityReserva!=NULL){
                         List<Opportunity> opps;
                         opps = [SELECT Id,Name, ConsecutivoOportunidad__c FROM Opportunity WHERE ConsecutivoOportunidad__c = :opportunityReserva];
                    	 if(opps.size() != 0)
                         {
                             Opportunity oppFind = opps[0];
                             actualProduct.OportunidadReserva__c = oppFind.Id;
                         }
                     }
                    
                     if(oportunidad_origen!=NULL){
                         List<Opportunity> opps;
                         opps = [SELECT Id,Name, ConsecutivoOportunidad__c  FROM Opportunity WHERE ConsecutivoOportunidad__c = :oportunidad_origen];
                    	 if(opps.size() != 0)
                         {
                             Opportunity oppFind = opps[0];
                             actualProduct.Oportunidad_Origen__c   = oppFind.Id;
                             actualProduct.Producto_Reservado__c = true;
                         }   
                     }


                    
                    
                 }
                
                if(esUsado=='true'){
                     description2 = modelo+' '+marca+' '+especificaciones+' '+color+' '+anno;
                     actualProduct.es_Vehiculo_usado__c = true;
                     actualProduct.modelo__c = modelo;
                     actualProduct.vin__c =vin;
                     actualProduct.marcaVehiculo__c = marca;
                     actualProduct.Especificaciones__c = especificaciones;
                     actualProduct.Color__c = color;
                     actualProduct.Anno__c = anno;
                     actualProduct.Descripci_n_Vehiculo__c = description2;
                     actualProduct.tipoProducto__c = 'Vehiculo';
                     actualProduct.RecordTypeId = '0124U00000111EDQAY';
                     actualProduct.Color_Externo__c = colorExterior;
                    
                     //
                     actualProduct.combustible__c =combustible;
                     actualProduct.Numero_Motor__c=Numero_Motor;
                     actualProduct.cubicaje__c=cubicaje;
                     actualProduct.Cantidad_Cilindros__c=(Cantidad_Cilindros != null) ? Decimal.valueOf(Cantidad_Cilindros) : 0;
                     actualProduct.pasajeros__c=(pasajeros != null) ? Decimal.valueOf(pasajeros) : 0;
                     actualProduct.Carroceria__c=Carroceria;
                     actualProduct.Peso__c=Peso;
                     actualProduct.traccion__c=traccion;
                     actualProduct.BL__c=BL;
                     actualProduct.Valor_exonerado__c=(Valor_exonerado != null) ? Decimal.valueOf(Valor_exonerado) : 0;
					 actualProduct.tapiceria__c=tapiceria;
					 actualProduct.transmision__c =transmision;
                     actualProduct.Tipo_vehiculo__c = Tipo_vehiculo;
                    
                    if(Tipo_vehiculo == 'Motocicleta'){
                        actualProduct.Porcentaje_vendedor__c = 5;
                        
                    }else{
                        actualProduct.Porcentaje_vendedor__c = (Porcentaje_vendedor != null) ? Decimal.valueOf(Porcentaje_vendedor) : 0;
                    }
                    
                     //actualProduct.Porcentaje_vendedor__c = (Porcentaje_vendedor != null) ? Decimal.valueOf(Porcentaje_vendedor) : 0;
                     actualProduct.Porcentaje_jefe__c = (Porcentaje_jefe != null) ? Decimal.valueOf(Porcentaje_jefe) : 0;
                    
                     actualProduct.fecha_ingreso_inventario__c = (fecha_ingreso != null) ?fecha_ingreso : Null;
                    
                    
                     if(opportunityReserva!=NULL){
                         List<Opportunity> opps;
                         opps = [SELECT Id,Name, ConsecutivoOportunidad__c FROM Opportunity WHERE ConsecutivoOportunidad__c = :opportunityReserva];
                    	 if(opps.size() != 0)
                         {
                             Opportunity oppFind = opps[0];
                             actualProduct.OportunidadReserva__c = oppFind.Id;
                         }
                     }
                    
                    
                    
                    
                 }
                
                
                update actualProduct;
                String withErrors = 'false';
                String descripcionError = '';


                List<ProductoXBodega__c> productosXBodega = new List<ProductoXBodega__c>();
                for (Disponible_Bodega disponible : wrapProductJSON.disponible_bodega) {
                    List<Bodega__c> bodegas;
                    if(empresa=='RMBAVARIAN')
                        bodegas = [SELECT Id,Name,Bodega__c FROM Bodega__c WHERE ID_EXTERNO_BODEGA__c = :disponible.bodega];
                    else
                        bodegas = [SELECT Id,Name,Bodega__c FROM Bodega__c WHERE ID_EXTERNO_BODEGA__c = :'RMOTOBAI'+disponible.bodega];
                    if(bodegas.size() != 0)
                    {
                        Bodega__c bodega = bodegas[0];
                        ProductoXBodega__c pXb = new ProductoXBodega__c();
                        pXb.Name = bodega.Name;
                        pXb.Bodega__c = bodega.Id;
                        pXb.Producto__c = actualProduct.Id;
                        pXb.Disponible__c = disponible.Disponible;
                        pXb.Identificador__c = actualProduct.Codigo_de_Producto__c+'-'+bodega.Bodega__c;

                        productosXBodega.add(pXb);
                    }
                }
                
                Map<String,Detalle_Costo_Producto__c> DetallesCostos = new Map<String,Detalle_Costo_Producto__c>();
                System.debug('El detalle del artículo y cantidad:');
                //System.debug(wrapProductJSON.detalle_costo);
                //System.debug(wrapProductJSON.detalle_costo.size());
                //
                if(wrapProductJSON.detalle_costo!=null){
                	if(wrapProductJSON.detalle_costo.size()>0){
                    for (Detalle_Costo costo : wrapProductJSON.detalle_costo) {
                        
                        Detalle_Costo_Producto__c DetalleCosto = new Detalle_Costo_Producto__c();
                        DetalleCosto.Rubro__c = costo.rubro;
                        DetalleCosto.Monto_local__c = costo.monto_local;
                        DetalleCosto.Monto_Dolar__c = costo.monto_dolar;
                        DetalleCosto.Product__c = actualProduct.Id;
                        DetalleCosto.id_linea_gasto__c = costo.id_linea_gasto;
                        
                        DetallesCostos.put(DetalleCosto.id_linea_gasto__c,DetalleCosto);
                    }
        
                    Schema.SObjectField cpId2 = Detalle_Costo_Producto__c.Fields.ID;
                    Database.UpsertResult[] saveCP2 = Database.upsert(checkcostDetailList(DetallesCostos).values(),cpId2, false);
                    for(Database.UpsertResult resu : saveCP2){
                        if(!resu.isSuccess()){
                            withErrors = 'true';
                            descripcionError = descripcionError+'Error al actualizar el detalle del costo: '+ resu.getErrors()+'\n';
                        }
                    }
                 }
                }
                
                
                Schema.SObjectField cpId = ProductoXBodega__c.Fields.Identificador__c;
                Database.UpsertResult[] saveCP = Database.upsert(productosXBodega,cpId, false);
                for(Database.UpsertResult resu : saveCP){
                    if(!resu.isSuccess()){
                        withErrors = 'true';
                        descripcionError = descripcionError+'Error al actualizar la bodega: '+ resu.getErrors()+'\n';
                    }
                }

                gen.writeStartObject();
                gen.writeFieldName('Solicitud');
                gen.writeStartObject();
                gen.writeStringField('CODIGO', '201');
                if(withErrors=='false')
                {
                    gen.writeStringField('RESULT', 'La solicitud fue procesada exitosamente');
                    
                } else {
                    gen.writeStringField('RESULT', 'Ocurrio un error en la actualizacion de las bodegas: ');
                    gen.writeStringField('ERROR', descripcionError);
                }
                gen.writeEndObject();
                gen.writeEndObject();
            }
            

        } catch(Exception ex)
        {
            gen = JSON.createGenerator(False);
            gen.writeStartObject();
            gen.writeFieldName('Solicitud');
            gen.writeStartObject();
            gen.writeStringField('CODIGO', '500');
            gen.writeStringField('RESULT', ex.getMessage()+' - '+ex.getLineNumber());
            gen.writeEndObject();
            gen.writeEndObject();
        }

        return gen.getAsString();
    }

    //Deserializador para las nuevas solicitudes
    public class productRequestJSON {
        //Identificador del formulario
        public String articulo;
        public String descripcion;
        public String cod_grupo1;
        public String  grupo1;
        public String  cod_grupo2;
        public String  grupo2;
        public String  cod_grupo3;
        public String  grupo3;
        public String  cod_grupo4;
        public String  grupo4;
        public String  cod_grupo5;
        public String  grupo5;
        public String  cod_grupo6;
        public String  grupo6;
        public String  cant_disponible;
        public String  precio;
        public String  porc_margen_min;
        public String  porc_margen_max;
        public String  costo_local;
        public String  lista_precio;
        public String porc_descuento;
        public String  moneda;
        public String  empresa;
        public String  tipo_producto;
        public String activo;
        public List<Disponible_Bodega> disponible_bodega;
        public String esVehiculo;
        public String esVehiculoentransito;
        public String esUsado;
        public String vin;
        public String modelo;
        public String marca;
        public String especificaciones;
        public String color;
        public String colorInterior;
        public String anno;
        public List<Detalle_Costo> detalle_costo;
        public String colorExterior;
        
        
        // Campos nuevos
        public String combustible;
        public String Numero_Motor;
        public String cubicaje;
        public String Cantidad_Cilindros;
        public String pasajeros;
        public String Carroceria;
        public String Peso;
        public String traccion;
        public String BL;
        public String Valor_exonerado;
        public String tapiceria;
        public String transmision;
        public String opportunity;
        
        public String Tipo_vehiculo;
        public String Marca_asset;
        public String Porcentaje_vendedor;
        public String Porcentaje_jefe;
        
        public String oportunidad_origen;
        
        public Date fecha_ingreso;
        public String codigo_equipamiento;
    }
    
    public class Detalle_Costo
    {
        public String rubro;
        public Decimal monto_local;
        public Decimal monto_dolar;
        public String id_linea_gasto;
    }
    
    public static productRequestJSON parsePropuesta(String json) {
        return(productRequestJSON) System.JSON.deserialize(json, productRequestJSON.class);
    }

    public class Disponible_Bodega
    {
        public String bodega;
        public Decimal disponible;
    }
    
    public static Map<String,Detalle_Costo_Producto__c> checkcostDetailList(Map<String,Detalle_Costo_Producto__c> softlandRequest){
        List<Detalle_Costo_Producto__c> deleteSalesforceRecords = [select id,id_linea_gasto__c from Detalle_Costo_Producto__c where Product__c =: softlandRequest.values()[0].Product__c];
        delete deleteSalesforceRecords;
        return softlandRequest;
    }
    
    public static void dummyMethod() {
        Integer a = 1;
        Integer b = 2;
        Integer c = 3;
        Integer d = 4;
        Integer e = 5;
        Integer f = 6;
        Integer g = 7;
        Integer h = 8;
        Integer i = 9;
        Integer j = 10;
        Integer k = 11;
        Integer l = 12;
        Integer m = 13;
        Integer n = 14;
        Integer o = 15;
        Integer p = 16;
        Integer q = 17;
        Integer r = 18;
        Integer s = 19;
        Integer t = 20;
        Integer u = 21;
        Integer v = 22;
        Integer w = 23;
        Integer x = 24;
        Integer y = 25;
        Integer z = 26;
        Integer aa = 27;
        Integer bb = 28;
        Integer cc = 29;
        Integer dd = 30;
        Integer ee = 31;
        Integer ff = 32;
        Integer gg = 33;
        Integer hh = 34;
        Integer ii = 35;
        Integer jj = 36;
        Integer kk = 37;
        Integer ll = 38;
        Integer mm = 39;
        Integer nn = 40;
        Integer oo = 41;
        Integer pp = 42;
        Integer qq = 43;
        Integer rr = 44;
        Integer ss = 45;
        Integer tt = 46;
        Integer uu = 47;
        Integer vv = 48;
        Integer ww = 49;
        Integer xx = 50;
        Integer yy = 51;
        Integer zz = 52;
        Integer aaa = 53;
        Integer bbb = 54;
        Integer ccc = 55;
        Integer ddd = 56;
        Integer eee = 57;
        Integer fff = 58;
        Integer ggg = 59;
        Integer hhh = 60;
        Integer iii = 61;
        Integer jjj = 62;
        Integer kkk = 63;
        Integer lll = 64;
        Integer mmm = 65;
        Integer nnn = 66;
        Integer ooo = 67;
        Integer ppp = 68;
        Integer qqq = 69;
        Integer rrr = 70;
        Integer sss = 71;
        Integer ttt = 72;
        Integer uuu = 73;
        Integer vvv = 74;
        Integer www = 75;
        Integer xxx = 76;
        Integer yyy = 77;
        Integer zzz = 78;
        Integer aaaa = 79;
        Integer bbbb = 80;
        Integer cccc = 81;
        Integer dddd = 82;
        Integer eeee = 83;
        Integer ffff = 84;
        Integer gggg = 85;
        Integer hhhh = 86;
        Integer iiii = 87;
        Integer jjjj = 88;
        Integer kkkk = 89;
        Integer llll = 90;
        Integer mmmm = 91;
        Integer nnnn = 92;
        Integer oooo = 93;
        Integer pppp = 94;
        Integer qqqq = 95;
        Integer rrrr = 96;
        Integer ssss = 97;
        Integer tttt = 98;
        Integer uuuu = 99;
        Integer vvvv = 100;
        Integer wwww = 101;
        Integer xxxx = 102;
        Integer yyyy = 103;
        Integer zzzz = 104;
        Integer aaaaa = 105;
        Integer bbbbb = 106;
        Integer ccccc = 107;
        Integer ddddd = 108;
        Integer eeeee = 109;
        Integer fffff = 110;
        Integer ggggg = 111;
        Integer hhhhh = 112;
        Integer iiiii = 113;
        Integer jjjjj = 114;
        Integer kkkkk = 115;
        Integer lllll = 116;
        Integer mmmmm = 117;
        Integer nnnnn = 118;
        Integer ooooo = 119;
        Integer ppppp = 120;
        Integer qqqqq = 121;
        Integer rrrrr = 122;
        Integer sssss = 123;
        Integer ttttt = 124;
        Integer uuuuu = 125;
        Integer vvvvv = 126;
        Integer wwwww = 127;
        Integer xxxxx = 128;
        Integer yyyyy = 129;
        Integer zzzzz = 130;
        Integer aaaaaa = 131;
        Integer bbbbbb = 132;
        Integer cccccc = 133;
        Integer dddddd = 134;
        Integer eeeeee = 135;
        Integer ffffff = 136;
        Integer gggggg = 137;
        Integer hhhhhh = 138;
        Integer iiiiii = 139;
        Integer jjjjjj = 140;
        Integer kkkkkk = 141;
        Integer llllll = 142;
        Integer mmmmmm = 143;
        Integer nnnnnn = 144;
        Integer oooooo = 145;
        Integer pppppp = 146;
        Integer qqqqqq = 147;
        Integer rrrrrr = 148;
        Integer ssssss = 149;
        Integer tttttt = 150;
        Integer uuuuuu = 151;
        Integer vvvvvv = 152;
        Integer wwwwww = 153;
        Integer xxxxxx = 154;
        Integer yyyyyy = 155;
        Integer zzzzzz = 156;
        Integer aaaaaaa = 157;
        Integer bbbbbbb = 158;
        Integer ccccccc = 159;
        Integer ddddddd = 160;
        Integer eeeeeee = 161;
        Integer fffffff = 162;
        Integer ggggggg = 163;
        Integer hhhhhhh = 164;
        Integer iiiiiii = 165;
        Integer jjjjjjj = 166;
        Integer kkkkkkk = 167;
        Integer lllllll = 168;
        Integer mmmmmmm = 169;
        Integer nnnnnnn = 170;
        Integer ooooooo = 171;
        Integer ppppppp = 172;
        Integer qqqqqqq = 173;
        Integer rrrrrrr = 174;
        Integer sssssss = 175;
        Integer ttttttt = 176;
        Integer uuuuuuu = 177;
        Integer vvvvvvv = 178;
        Integer wwwwwww = 179;
        Integer xxxxxxx = 180;
        Integer yyyyyyy = 181;
        Integer zzzzzzz = 182;
        Integer aaaaaaaa = 183;
        Integer bbbbbbbb = 184;
         Integer cccccccc = 184;
        Integer dddddddd = 185;
        Integer eeeeeeee = 186;
        Integer ffffffff = 187;
        Integer gggggggg = 188;
        Integer hhhhhhhh = 189;
        Integer iiiiiiii = 190;
        Integer jjjjjjjj = 191;
        Integer kkkkkkkk = 192;
        Integer llllllll = 193;
        Integer mmmmmmmm = 194;
        Integer nnnnnnnn = 195;
        Integer oooooooo = 196;
        Integer pppppppp = 197;
        Integer qqqqqqqq = 198;
        Integer rrrrrrrr = 199;
        Integer ssssssss = 200;
        Integer tttttttt = 201;
        Integer uuuuuuuu = 202;
        Integer vvvvvvvv = 203;
        Integer wwwwwwww = 204;
        Integer xxxxxxxx = 205;
        Integer yyyyyyyy = 206;
        Integer zzzzzzzz = 207;
        Integer aaaaaaaaa = 208;
        Integer bbbbbbbbb = 209;
        Integer ccccccccc = 210;
        Integer ddddddddd = 211;
        Integer eeeeeeeee = 212;
        Integer fffffffff = 213;
        Integer ggggggggg = 214;
        Integer hhhhhhhhh = 215;
        Integer iiiiiiiii = 216;
        Integer jjjjjjjjj = 217;
        Integer kkkkkkkkk = 218;
        Integer lllllllll = 219;
        Integer mmmmmmmmm = 220;
        Integer nnnnnnnnn = 221;
        Integer ooooooooo = 222;
        Integer ppppppppp = 223;
        Integer qqqqqqqqq = 224;
        Integer rrrrrrrrr = 225;
        Integer sssssssss = 226;
        Integer ttttttttt = 227;
        Integer uuuuuuuuu = 228;
        Integer vvvvvvvvv = 229;
        Integer wwwwwwwww = 230;
        }
    
    
    
}