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
        String cant_disponible = wrapProductJSON.cant_disponible;
        String empresa = normalizeCompanyCode(wrapProductJSON.empresa);
        wrapProductJSON.empresa = empresa;
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

        String Tipo_vehiculo = wrapProductJSON.Tipo_vehiculo;
        String Porcentaje_vendedor = wrapProductJSON.Porcentaje_vendedor;
        String Porcentaje_jefe = wrapProductJSON.Porcentaje_jefe;
        String Marca_asset = wrapProductJSON.Marca_asset;

        Date fecha_ingreso = wrapProductJSON.fecha_ingreso;

        String opportunityReserva = wrapProductJSON.opportunity;
        String oportunidad_origen = wrapProductJSON.oportunidad_origen;
        Boolean isUsedVehicle = esUsado == 'true';
        Id reservationOpportunityId = null;
        Id originOpportunityId = null;
        Boolean shouldReleaseReservation = false;

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
            validateSupportedCompany(empresa);
            reservationOpportunityId = getOpportunityId(opportunityReserva);
            originOpportunityId = getOpportunityId(oportunidad_origen);
            shouldReleaseReservation = false;
            /*shouldReleaseReservation = isUsedVehicle
                && hasAvailableInventory(cant_disponible, wrapProductJSON.disponible_bodega)
                && reservationOpportunityId == null
                && originOpportunityId == null;*/
            List<Product2> prod = new List<Product2>();
            if(isUsedVehicle && String.isNotBlank(vin))
            {
                prod =      [
                                SELECT Id, es_Vehiculo_en_transito__c, esVehiculo__c, es_Vehiculo_usado__c, OportunidadReserva__c,
                                       Producto_Reservado__c, vin__c, Codigo_de_Producto__c
                                FROM Product2
                                WHERE vin__c = :vin
                                LIMIT 1
                            ];
            } else if(empresa=='RMBAVARIAN')
            {
            	prod =     	[
                                SELECT Id, es_Vehiculo_en_transito__c, esVehiculo__c, es_Vehiculo_usado__c, OportunidadReserva__c,
                                       Producto_Reservado__c, vin__c, Codigo_de_Producto__c
                                FROM Product2
                                WHERE Codigo_de_Producto__c = :articulo
                            ];
            } else if(empresa=='RMOTOBAI' || empresa=='RMPEKING')
            {
                String identificador = articulo+'-'+empresa;
                prod =     [
                                SELECT Id, es_Vehiculo_en_transito__c, esVehiculo__c, es_Vehiculo_usado__c, OportunidadReserva__c,
                                       Producto_Reservado__c, vin__c, Codigo_de_Producto__c
                                FROM Product2
                                WHERE CodigoProductoInterno__c = :identificador
                            ];
            }


            if(prod.size()==0)
            {
                validateCompanyCanProcessWarehouses(empresa);
                Product2 newProduct = new Product2();
                applyCoreProductFields(newProduct, wrapProductJSON, true, activo);

                if(esVehiculoentransito =='true'){
                    newProduct.Pedido_Original__c = articulo;
                    newProduct.esVehiculo__c = true;
                    newProduct.RM_VN_EsActivo__c = true;
                }

                if(esVehiculo=='true' || esVehiculoentransito =='true'){
                    description2 = buildVehicleDescription(modelo, marca, especificaciones, color, anno);
                    newProduct.esVehiculo__c = esVehiculo != null ? true : newProduct.esVehiculo__c;
                    newProduct.es_Vehiculo_en_transito__c = esVehiculoentransito != null ? true : newProduct.es_Vehiculo_en_transito__c;
                    applyVehicleFields(newProduct, wrapProductJSON, modelo, marca, especificaciones, color, anno, colorExterior, Tipo_vehiculo, Marca_asset, fecha_ingreso, description2);
                    if(reservationOpportunityId != null) newProduct.OportunidadReserva__c = reservationOpportunityId;
                    if(originOpportunityId != null){
                        newProduct.Oportunidad_Origen__c = originOpportunityId;
                        newProduct.Producto_Reservado__c = true;
                    }
                }

                if(esUsado=='true'){
                    description2 = buildVehicleDescription(modelo, marca, especificaciones, color, anno);
                    newProduct.es_Vehiculo_usado__c = true;
                    applyVehicleFields(newProduct, wrapProductJSON, modelo, marca, especificaciones, color, anno, colorExterior, Tipo_vehiculo, null, fecha_ingreso, description2);
                    applyUsedVehicleComissions(newProduct, Tipo_vehiculo, Porcentaje_vendedor, Porcentaje_jefe);
                    if(reservationOpportunityId != null){
                        newProduct.OportunidadReserva__c = reservationOpportunityId;
                        newProduct.Producto_Reservado__c = true;
                    }
                }

                insert newProduct;
                system.debug(newProduct);
                if((newProduct.esVehiculo__c == true || newProduct.es_Vehiculo_usado__c == true) && reservationOpportunityId != null){
                    VehicleReservationHistoryService.startReservation(
                        newProduct.Id,
                        reservationOpportunityId,
                        VehicleReservationHistoryService.ORIGEN_PORTALNET
                    );
                }

                List<ProductoXBodega__c> productosXBodega = new List<ProductoXBodega__c>();
                for (Disponible_Bodega disponible : wrapProductJSON.disponible_bodega) {
                    List<Bodega__c> bodegas;
                    if(empresa=='RMBAVARIAN')
                        bodegas = [SELECT Id,Name,Bodega__c FROM Bodega__c WHERE ID_EXTERNO_BODEGA__c = :disponible.bodega];
                    else if(empresa=='RMOTOBAI')
                        bodegas = [SELECT Id,Name,Bodega__c FROM Bodega__c WHERE ID_EXTERNO_BODEGA__c = :'RMOTOBAI'+disponible.bodega];
                    else
                        throw new ProductCompanyConfigurationException('No existe bodega principal confirmada para ' + empresa + '.');
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
                if(withErrors=='false'){
                    gen.writeStringField('RESULT', 'La solicitud fue procesada exitosamente');
                } else {
                    gen.writeStringField('RESULT', 'Ocurrio un error en la actualizacion de las bodegas: ');
                    gen.writeStringField('ERROR', descripcionError);
                }
                gen.writeEndObject();
                gen.writeEndObject();
            } else {
                validateCompanyCanProcessWarehouses(empresa);
                Product2 actualProduct = prod[0];
                Id previousReservationOpportunityId = actualProduct.OportunidadReserva__c;
                applyCoreProductFields(actualProduct, wrapProductJSON, false, activo);

                if(esVehiculoentransito =='true'){
                    actualProduct.Pedido_Original__c = articulo;
                    actualProduct.esVehiculo__c = true;
                    actualProduct.RM_VN_EsActivo__c = true;
                }

                if(esVehiculo=='true' || esVehiculoentransito =='true'){
                    description2 = buildVehicleDescription(modelo, marca, especificaciones, color, anno);
                    actualProduct.esVehiculo__c = esVehiculo != null ? true : actualProduct.esVehiculo__c;
                    actualProduct.es_Vehiculo_en_transito__c = esVehiculoentransito != null ? true : actualProduct.es_Vehiculo_en_transito__c;
                    applyVehicleFields(actualProduct, wrapProductJSON, modelo, marca, especificaciones, color, anno, colorExterior, Tipo_vehiculo, Marca_asset, fecha_ingreso, description2);
                    if(reservationOpportunityId != null) actualProduct.OportunidadReserva__c = reservationOpportunityId;
                    if(originOpportunityId != null){
                        actualProduct.Oportunidad_Origen__c = originOpportunityId;
                        actualProduct.Producto_Reservado__c = true;
                    }
                }

                if(esUsado=='true'){
                    description2 = buildVehicleDescription(modelo, marca, especificaciones, color, anno);
                    actualProduct.es_Vehiculo_usado__c = true;
                    actualProduct.vin__c = vin;
                    applyVehicleFields(actualProduct, wrapProductJSON, modelo, marca, especificaciones, color, anno, colorExterior, Tipo_vehiculo, null, fecha_ingreso, description2);
                    applyUsedVehicleComissions(actualProduct, Tipo_vehiculo, Porcentaje_vendedor, Porcentaje_jefe);
                    if(reservationOpportunityId != null){
                        actualProduct.OportunidadReserva__c = reservationOpportunityId;
                        actualProduct.Producto_Reservado__c = true;
                    }
                }

                if(shouldReleaseReservation){
                    VehicleReservationHistoryService.completeCurrentReservation(
                        actualProduct,
                        VehicleReservationHistoryService.ORIGEN_PORTALNET,
                        'Reserva finalizada por reingreso de vehiculo disponible.'
                    );
                } else if(reservationOpportunityId != null){
                    VehicleReservationHistoryService.completePreviousReservation(
                        actualProduct.Id,
                        previousReservationOpportunityId,
                        reservationOpportunityId,
                        VehicleReservationHistoryService.ORIGEN_PORTALNET,
                        'Reserva finalizada por nueva oportunidad de reserva.'
                    );
                }

                update actualProduct;
                if((actualProduct.esVehiculo__c == true || actualProduct.es_Vehiculo_usado__c == true) && reservationOpportunityId != null){
                    VehicleReservationHistoryService.startReservation(
                        actualProduct.Id,
                        reservationOpportunityId,
                        VehicleReservationHistoryService.ORIGEN_PORTALNET
                    );
                }
                String withErrors = 'false';
                String descripcionError = '';

                List<ProductoXBodega__c> productosXBodega = new List<ProductoXBodega__c>();
                for (Disponible_Bodega disponible : wrapProductJSON.disponible_bodega) {
                    List<Bodega__c> bodegas;
                    if(empresa=='RMBAVARIAN')
                        bodegas = [SELECT Id,Name,Bodega__c FROM Bodega__c WHERE ID_EXTERNO_BODEGA__c = :disponible.bodega];
                    else if(empresa=='RMOTOBAI')
                        bodegas = [SELECT Id,Name,Bodega__c FROM Bodega__c WHERE ID_EXTERNO_BODEGA__c = :'RMOTOBAI'+disponible.bodega];
                    else
                        throw new ProductCompanyConfigurationException('No existe bodega principal confirmada para ' + empresa + '.');
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
                if(withErrors=='false'){
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

    /**
     * Aplica los campos comunes de vehículo (nuevo o usado) a un Product2.
     * Consolida la duplicación entre bloques insert y update.
     */
    private static String buildVehicleDescription(String modelo, String marca,
            String especificaciones, String color, String anno) {
        return modelo + ' ' + marca + ' ' + especificaciones + ' ' + color + ' ' + anno;
    }

    private class ProductCompanyConfigurationException extends Exception {}

    private static String normalizeCompanyCode(String companyCode) {
        if (String.isBlank(companyCode)) {
            return null;
        }

        String normalized = companyCode.trim().toUpperCase();
        if (normalized == 'BAVARIAN') {
            return 'RMBAVARIAN';
        }
        if (normalized == 'OTOBAI') {
            return 'RMOTOBAI';
        }
        if (normalized == 'PEKING') {
            return 'RMPEKING';
        }
        return normalized;
    }

    private static void validateSupportedCompany(String companyCode) {
        if (companyCode == 'RMBAVARIAN' || companyCode == 'RMOTOBAI' || companyCode == 'RMPEKING') {
            return;
        }

        throw new ProductCompanyConfigurationException('No existe empresa soportada para procesar el producto.');
    }

    private static void validateCompanyCanProcessWarehouses(String companyCode) {
        if (companyCode == 'RMPEKING') {
            throw new ProductCompanyConfigurationException('No existe bodega principal confirmada para RMPEKING.');
        }
    }

    private static Id productoRedMotorsRecordTypeId;

    private static final Id VEHICULOS_RECORD_TYPE_ID = '0124U00000111EDQAY';

    /**
     * Unico punto de resolucion del RecordTypeId de Product2 para RMPEKING/RMBAVARIAN/RMOTOBAI,
     * invocado por applyCoreProductFields y applyVehicleFields. @TestVisible porque el bloqueo de
     * bodega principal para RMPEKING impide observar el insert real en pruebas sin alterar
     * comportamiento productivo; este metodo puro permite comprobar directamente cual RecordTypeId
     * usaria produccion, sin DML ni datos.
     */
    @TestVisible
    private static Id resolveProductRecordTypeId(String empresa, Boolean esVehiculo) {
        if (empresa == 'RMPEKING') {
            return getProductoRedMotorsRecordTypeId();
        }
        if (esVehiculo == true) {
            return VEHICULOS_RECORD_TYPE_ID;
        }
        return null;
    }

    /**
     * RMPEKING solo admite Empresa__c en el Record Type "Producto Red Motors" (Producto_Red_Motors);
     * "Vehiculos" (default del org) no lo admite, asi que se resuelve dinamicamente en vez de asumir el default.
     */
    private static Id getProductoRedMotorsRecordTypeId() {
        if (productoRedMotorsRecordTypeId == null) {
            List<RecordType> productoRedMotorsRecordTypes = [
                SELECT Id
                FROM RecordType
                WHERE SObjectType = 'Product2'
                AND DeveloperName = 'Producto_Red_Motors'
            ];
            if (productoRedMotorsRecordTypes.isEmpty()) {
                throw new ProductCompanyConfigurationException(
                    'No existe el Record Type "Producto Red Motors" (DeveloperName Producto_Red_Motors) para Product2.'
                );
            }
            productoRedMotorsRecordTypeId = productoRedMotorsRecordTypes[0].Id;
        }
        return productoRedMotorsRecordTypeId;
    }

    private static void applyCoreProductFields(Product2 p, productRequestJSON w,
            Boolean isNewProduct, Boolean activo) {
        p.Name = w.descripcion;
        p.ProductCode = w.articulo;
        p.Codigo_de_Producto__c = w.articulo;
        p.CodigoProductoInterno__c = w.articulo + '-' + w.empresa;
        p.Description = isNewProduct ? w.descripcion : '';
        p.isActive = isNewProduct ? true : activo;
        p.CurrencyIsoCode = w.moneda;
        p.Empresa__c = w.empresa;
        p.procentajeMargenMaximo__c = Decimal.valueOf(w.porc_margen_max);
        if (isNewProduct) {
            p.porcentajeMargenMinimo__c = Decimal.valueOf(w.porc_margen_min);
        }
        p.costoLocal__c = Decimal.valueOf(w.costo_local);
        p.porcentajeDescuento__c = Decimal.valueOf(w.porc_descuento);
        p.precio__c = Decimal.valueOf(w.precio);
        p.cantidadDisponible__c = Decimal.valueOf(w.cant_disponible);
        p.grupo1__c = w.grupo1;
        p.codGrupo1__c = w.cod_grupo1;
        p.grupo2__c = w.grupo2;
        p.codGrupo2__c = w.cod_grupo2;
        p.grupo3__c = w.grupo3;
        p.codGrupo3__c = w.cod_grupo3;
        p.grupo4__c = w.grupo4;
        p.codGrupo4__c = w.cod_grupo4;
        p.grupo5__c = w.grupo5;
        p.codGrupo5__c = w.cod_grupo5;
        p.grupo6__c = w.grupo6;
        p.codGrupo6__c = w.cod_grupo6;
        p.RM_CodigoEquipamiento__c = w.codigo_equipamiento;
        p.sustitutivo__c = w.sustitutivo;
        p.alternativo__c = w.alternativo;
        p.margen__c = w.margen;
        p.transito__c = w.transito;
        p.tipoProducto__c = resolveTipoProducto(w.tipo_producto);
        Id resolvedRecordTypeId = resolveProductRecordTypeId(w.empresa, false);
        if (resolvedRecordTypeId != null) {
            p.RecordTypeId = resolvedRecordTypeId;
        }
    }

    private static String resolveTipoProducto(String tipoProducto) {
        if (tipoProducto == 'T') return 'Materiales';
        if (tipoProducto == 'K') return 'Kit';
        if (tipoProducto == 'S') return null;
        return 'Mano de Obra';
    }

    private static void applyVehicleFields(Product2 p, productRequestJSON w,
            String modelo, String marca, String especificaciones, String color,
            String anno, String colorExterior, String Tipo_vehiculo, String Marca_asset,
            Date fecha_ingreso, String description2) {
        p.vin__c              = w.vin;
        p.modelo__c           = modelo;
        p.marcaVehiculo__c    = marca;
        p.Especificaciones__c = especificaciones;
        p.Color__c            = color;
        p.Anno__c             = anno;
        p.Descripci_n_Vehiculo__c = description2;
        p.tipoProducto__c     = 'Vehiculo';
        p.RecordTypeId        = resolveProductRecordTypeId(w.empresa, true);
        p.Color_Externo__c    = colorExterior;
        p.combustible__c      = w.combustible;
        p.Numero_Motor__c     = w.Numero_Motor;
        p.cubicaje__c         = w.cubicaje;
        p.Cantidad_Cilindros__c = (w.Cantidad_Cilindros != null) ? Decimal.valueOf(w.Cantidad_Cilindros) : 0;
        p.pasajeros__c        = (w.pasajeros != null) ? Decimal.valueOf(w.pasajeros) : 0;
        p.Carroceria__c       = w.Carroceria;
        p.Peso__c             = w.Peso;
        p.traccion__c         = w.traccion;
        p.BL__c               = w.BL;
        p.Valor_exonerado__c  = (w.Valor_exonerado != null) ? Decimal.valueOf(w.Valor_exonerado) : 0;
        p.tapiceria__c        = w.tapiceria;
        p.transmision__c      = w.transmision;
        p.Tipo_vehiculo__c    = Tipo_vehiculo;
        if(Marca_asset != null) p.Marca_asset__c = Marca_asset;
        p.fecha_ingreso_inventario__c = (fecha_ingreso != null) ? fecha_ingreso : null;
    }

    /**
     * Aplica comisiones específicas de vehículo usado (vendedor/jefe).
     */
    private static void applyUsedVehicleComissions(Product2 p, String Tipo_vehiculo,
            String Porcentaje_vendedor, String Porcentaje_jefe) {
        if(Tipo_vehiculo == 'Motocicleta'){
            p.Porcentaje_vendedor__c = 5;
        } else {
            p.Porcentaje_vendedor__c = (Porcentaje_vendedor != null) ? Decimal.valueOf(Porcentaje_vendedor) : 0;
        }
        p.Porcentaje_jefe__c = (Porcentaje_jefe != null) ? Decimal.valueOf(Porcentaje_jefe) : 0;
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

        public String sustitutivo;
        public String alternativo;
        public String margen;
        public String transito;
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

    private static Id getOpportunityId(String consecutiveNumber) {
        if (String.isBlank(consecutiveNumber)) {
            return null;
        }
        List<Opportunity> opportunities = [
            SELECT Id
            FROM Opportunity
            WHERE ConsecutivoOportunidad__c = :consecutiveNumber
            LIMIT 1
        ];
        return opportunities.isEmpty() ? null : opportunities[0].Id;
    }

    private static Boolean hasAvailableInventory(String availableQuantity, List<Disponible_Bodega> availableWarehouses) {
        if (!String.isBlank(availableQuantity)) {
            try {
                if (Decimal.valueOf(availableQuantity) > 0) {
                    return true;
                }
            } catch (Exception ex) {
                System.debug('Cantidad disponible invalida: ' + availableQuantity);
            }
        }
        if (availableWarehouses != null) {
            for (Disponible_Bodega warehouse : availableWarehouses) {
                if (warehouse != null && warehouse.disponible != null && warehouse.disponible > 0) {
                    return true;
                }
            }
        }
        return false;
    }

    public static Map<String,Detalle_Costo_Producto__c> checkcostDetailList(Map<String,Detalle_Costo_Producto__c> softlandRequest){
        List<Detalle_Costo_Producto__c> deleteSalesforceRecords = [select id,id_linea_gasto__c from Detalle_Costo_Producto__c where Product__c =: softlandRequest.values()[0].Product__c];
        delete deleteSalesforceRecords;
        return softlandRequest;
    }

}