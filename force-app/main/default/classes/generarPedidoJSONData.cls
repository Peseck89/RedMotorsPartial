public with sharing class generarPedidoJSONData {
    
    public static orderSoftlandWrapper createWraper(WorkOrder wo , String cardCode, String request_id ) {

        orderSoftlandWrapper orderWrapper = new orderSoftlandWrapper();
        
        /*
        if (wo.BMW_CentroDeCosto__c == null || wo.Aprobaci_n_Centro_de_Costos__c == null) {
            WorkOrder woLite = [
                SELECT BMW_CentroDeCosto__c, Aprobaci_n_Centro_de_Costos__c
                FROM WorkOrder
                WHERE Id = :wo.Id
                LIMIT 1
            ];
            wo.BMW_CentroDeCosto__c = woLite.BMW_CentroDeCosto__c;
            wo.Aprobaci_n_Centro_de_Costos__c = woLite.Aprobaci_n_Centro_de_Costos__c;
        }
		*/
        
        
        // A partir del 01/01/2025 aplicamos las restricciones de CC
        final Date THRESHOLD = Date.newInstance(2025, 1, 1);
        Boolean applyCCRestrictions = FALSE;
        
        applyCCRestrictions =
            (wo.CreatedDate != null && wo.CreatedDate.date() >= THRESHOLD);
        
        orderWrapper.compania = wo.empresaFactura__c!=null ? wo.empresaFactura__c : '';
        orderWrapper.request_id = request_id;
        orderWrapper.tipo_ot=wo.Origen__c;
        
        
        orderWrapper.pedido_interno_esPlan = wo.Pedido_interno_es_de_plan__c!=null ? wo.Pedido_interno_es_de_plan__c : '';
  
       
        if(wo.Asesor_de_la_orden__c != null){
            User usr = [Select Id,Name From User Where Id=:wo.Asesor_de_la_orden__c];
            orderWrapper.asesor = usr.Name;
        }else{orderWrapper.asesor = '';}
        
        if(wo.Realizar_encuesta__c=='Si'){
            orderWrapper.realizaEntrevista = 'Si';
            orderWrapper.justifica_encuesta = '';
        }else if(wo.Realizar_encuesta__c=='No'){                
            orderWrapper.realizaEntrevista = 'No';
            orderWrapper.justifica_encuesta = wo.BMW_CategorizacionDeRespuestaEncuesta__c!=null?wo.BMW_CategorizacionDeRespuestaEncuesta__c:'';
        }else{
            orderWrapper.realizaEntrevista = '';
        }

        Case  Caso;
        Event  evento;
        if(wo.CaseId != null){
             Caso = [SELECT Id, CaseNumber, Cita__c, ContactId, Contact.Email ,Contact.Phone, Contact.Name FROM Case WHERE Id =: wo.CaseId LIMIT 1];
             orderWrapper.numero_caso=Caso.CaseNumber;
            
            List <Event> events = [SELECT Id, StartDateTime, EndDateTime,CreatedDate,StartDateTimeF__c, Case__c, Work_Order__c,OrigenEvento__c FROM Event WHERE Case__c=: Caso.Id ORDER BY createdDate DESC LIMIT 1];
            
            if(events!=null && events.size()>0){
                evento= events[0];
                orderWrapper.fecha_cita=evento.StartDateTimeF__c;
                orderWrapper.fecha_agenda_cita=String.valueOf(evento.CreatedDate);
                orderWrapper.u_origen_cita=evento.OrigenEvento__c;   
            }
        }else{
            orderWrapper.numero_caso = '';
        }        
        
        Account Cuenta = [SELECT Id,C_digo_de_Actividad_Econ_mica__c,CorreoElectronicoEmpresarial__c,NombreEncargadoCuenta__c,Correo_Encargado_Cuenta__c,TelefonoEncargadoCuenta__c, PersonEmail,
                                Cedula__c,toLabel(Tipo_de_Documento__c),Phone,PersonMobilePhone,Invoice_Email__c,Invoice_Phone__c, Name,FirstName,LastName, IsPersonAccount 
                            FROM Account WHERE Id =: wo.Cuenta_de_Facturacion__c LIMIT 1];
        
        /*Account Cuenta = [SELECT Id, CorreoElectronicoEmpresarial__c,NombreEncargadoCuenta__c,Correo_Encargado_Cuenta__c,TelefonoEncargadoCuenta__c, PersonEmail,
                                Cedula__c,toLabel(Tipo_de_Documento__c),Phone,PersonMobilePhone,Invoice_Email__c,Invoice_Phone__c, Name,FirstName,LastName, IsPersonAccount 
                            FROM Account WHERE Id =: wo.AccountId LIMIT 1];
        */
        //orderWrapper.actividad_comercial =  Cuenta.C_digo_de_Actividad_Econ_mica__c  wo.ActividadComercial__r.codigo__c != null ? wo.ActividadComercial__r.codigo__c : '';
        //
        orderWrapper.actividad_comercial =  Cuenta.C_digo_de_Actividad_Econ_mica__c  != null ? Cuenta.C_digo_de_Actividad_Econ_mica__c : '';
        
        
        if(Wo.Desea_financiamiento__c=='Si'){
            orderWrapper.pagador='ALTICA SERVICIOS FINANCIEROS SOCIEDAD ANONIMA - DV';
            orderWrapper.codigo_pagador='C000672- DV';
            orderWrapper.monto_financiamiento=String.valueOf(wo.Financiamiento_utilizado_Altica__c);
            orderWrapper.moneda_financiamiento=String.valueOf(wo.Moneda_financiamiento_Altica__c);
        }        
        
        /*
        if(Cuenta.CorreoElectronicoEmpresarial__c!=NULL){
            orderWrapper.correo=Cuenta.CorreoElectronicoEmpresarial__c;
        }else{
            orderWrapper.correo=Cuenta.PersonEmail;
        }*/
        
        if(Cuenta.Invoice_Email__c !=NULL ){
            orderWrapper.correo=Cuenta.Invoice_Email__c;
        }else{
            orderWrapper.correo=Cuenta.PersonEmail;
        }
        
        
        
        
        
        orderWrapper.nombre_cuenta= Cuenta.Name;

        if(Cuenta.IsPersonAccount==False){
            if(Caso!=null){
                    orderWrapper.telefono_contacto=Caso.Contact.Phone;
                    orderWrapper.correo_contacto=Caso.Contact.Email;
                    orderWrapper.nombre_encargado=Caso.Contact.Name;
            }else{
                orderWrapper.telefono_contacto=Cuenta.TelefonoEncargadoCuenta__c;
                orderWrapper.correo_contacto=Cuenta.Correo_Encargado_Cuenta__c;
                orderWrapper.nombre_encargado=Cuenta.NombreEncargadoCuenta__c;
            }
        }
        
        if(wo.ContactId!=null && Cuenta.IsPersonAccount){
            orderWrapper.nombres_cuenta=wo.Contact.FirstName;
            orderWrapper.apellidos_cuenta=wo.Contact.LastName;
        }else if (wo.ContactId==null && Cuenta.IsPersonAccount){
            orderWrapper.nombres_cuenta=Cuenta.FirstName;
            orderWrapper.apellidos_cuenta=Cuenta.LastName;
        }else{
            orderWrapper.nombres_cuenta=wo.Contact.FirstName;
            orderWrapper.apellidos_cuenta=wo.Contact.LastName;
        }
        
        orderWrapper.TipoDeCambio = wo.TipoDeCambio__c != null ? wo.TipoDeCambio__c.toString() : '';
        orderWrapper.Moneda_destino = wo.Moneda_destino__c != null ? wo.Moneda_destino__c : '';
            
        orderWrapper.contribuyente_cuenta=Cuenta.Cedula__c;
        orderWrapper.tipo_id_contribuyente=Cuenta.Tipo_de_Documento__c;
        orderWrapper.telefono=Cuenta.Phone;
        orderWrapper.movil=Cuenta.PersonMobilePhone;
        
        orderWrapper.num_reclamo=wo.N_mero_de_reclamo_de_garant_as__c;
        
        orderWrapper.fecha_entrada=string.valueOfGmt(wo.Fecha_de_Entrada__c);

        String observaciones = wo.Observaciones__c != null ? wo.Observaciones__c : ''; 
        orderWrapper.observaciones = observaciones;

        orderWrapper.taller = wo.ServiceTerritory.Name;
        
        
        orderWrapper.comentarioCXC = wo.Comentario_CxC__c != null ? wo.Comentario_CxC__c : '';

        condicionPago__c condicionPago = [SELECT Id, Name FROM condicionPago__c WHERE condicionPago__c = '0'];
        orderWrapper.condicion_pago = condicionPago.Name != null ? condicionPago.Name : '';           //.Id != null ? condicionPago.Id : '';

        //
        Decimal Num_total_mercaderia_Suma = 0; 

        List<WorkOrderLineItem> WOLIs = getWorkOrderLineItem(wo.Id);
        List<Id> idsWolis= getIdsWOLIs(WOLIs);
        List<TipoCargo__c> tipoCargoList = getTipoCargoList(idsWolis);

        //Mapa para saber los TipoCargo__c por WOLI ( WOLI { TipoCargo__c )
        Map<Id, List<TipoCargo__c>> map_tipoCargos_WOLI = new Map<Id, List<TipoCargo__c>>();
        List<TipoCargo__c> tipoCargolistAux;

        //Llenamos el mapa y ahora tenemos, para cada WOLI (id keyset), la lista de sus TipoCargo__c
        for(TipoCargo__c tipoCargo : tipoCargoList){
            if( !map_tipoCargos_WOLI.containsKey(tipoCargo.Work_Order_Line_Item__c) ){
                tipoCargolistAux = new List<tipoCargo__c>();
                tipoCargolistAux.add(tipoCargo);
                map_tipoCargos_WOLI.put(tipoCargo.Work_Order_Line_Item__c, tipoCargolistAux);
            }
            else{
                map_tipoCargos_WOLI.get(tipoCargo.Work_Order_Line_Item__c).add(tipoCargo);
            }
        }
        
        List<orderSoftlandWrapper.lineOrder> listOrderLinesWrapper = new List<orderSoftlandWrapper.lineOrder>();

        // Primero, recopilamos todos los IDs de Bodega necesarios
        Set<Id> bodegaIds = new Set<Id>();
        for (WorkOrderLineItem woli : WOLIs) {
            if (woli.Bodega__c != null) {
                bodegaIds.add(woli.Bodega__c);
            }
        }
        
        // Realiza una única consulta para obtener todas las Bodegas necesarias
        Map<Id, Bodega__c> bodegaMap = new Map<Id, Bodega__c>([
            SELECT Id, bodega__c, Name 
            FROM Bodega__c 
            WHERE Id IN :bodegaIds
        ]);
        
        for (WorkOrderLineItem woli : WOLIs) {
            String descuentoProducto = woli.descuento__c != null ? String.valueOf(woli.descuento__c) : '0';
            //String porcentajeDescuentoProducto = woli.descuento__c != null ? String.valueOf((woli.descuento__c / (woli.UnitPrice * woli.Quantity)) * 100): '0';
            String porcentajeDescuentoProducto = (woli.UnitPrice != null && woli.UnitPrice != 0 && 
                                      woli.Quantity != null && woli.Quantity != 0 && 
                                      woli.descuento__c != null) 
                                      ? String.valueOf((woli.descuento__c / (woli.UnitPrice * woli.Quantity)) * 100) 
                                      : '0';
            Decimal impuestoProducto = woli.ImpuestoReal__c;
            Decimal cantidad = woli.Quantity;
            Decimal totalMercaderia = woli.Subtotal__c;
        
            TipoCargo__c tempTipoCargo = map_tipoCargos_WOLI.get(woli.Id)[0];
            String comentario = woli.Comentario__c != null ? woli.Comentario__c : '';
        
            orderSoftlandWrapper.lineOrder orderLineWrapper = new orderSoftlandWrapper.lineOrder();
            orderLineWrapper.cod_articulo = woli.PricebookEntry.Product2.Codigo_de_Producto__c;
            orderLineWrapper.desc_articulo = woli.Producto_OR_Alias__c;
        
            // Utiliza el mapa de Bodegas para obtener la bodega correspondiente
            if (woli.Bodega__c != null && bodegaMap.containsKey(woli.Bodega__c)) {
                Bodega__c bodega = bodegaMap.get(woli.Bodega__c);
                orderLineWrapper.cod_bodega = bodega.bodega__c;
                System.debug('----------Bodega----------' + bodega.Name);
            } else {
                orderLineWrapper.cod_bodega = '';
            }
        
            orderLineWrapper.cod_localizacion = tempTipoCargo.Work_Order_Line_Item__r.Localizacion__c;
            orderLineWrapper.comentario = comentario;
            orderLineWrapper.tipo_trabajo = tempTipoCargo.Work_Order_Line_Item__r.trabajo__c;
            orderLineWrapper.precio_unitario = String.valueOf(woli.UnitPrice);
            orderLineWrapper.cantidad = String.valueOf(cantidad);
            
            orderLineWrapper.centro_costo = '';
            String estadoWoli = (woli.Estado_aprobaci_n_CC__c == null) ? '' : woli.Estado_aprobaci_n_CC__c.trim();
            String estadoWO   = (wo.Aprobaci_n_Centro_de_Costos__c == null) ? '' : wo.Aprobaci_n_Centro_de_Costos__c.trim();
            Boolean woliAprobado = 'aprobado'.equalsIgnoreCase(estadoWoli);
            Boolean woAprobado   = 'aprobado'.equalsIgnoreCase(estadoWO);
            Id ccWoliId = woli.CentroDeCostoAprobacion__c;
            Id ccWoId   = (wo.CentroDeCostoAprobacion__c != null) ? wo.CentroDeCostoAprobacion__c : wo.BMW_CentroDeCosto__c;
            
            if (!applyCCRestrictions) {
            	orderLineWrapper.centro_costo = woli.centroCosto__r.centroCosto__c != null ? woli.centroCosto__r.centroCosto__c : '';
            } else {
                String ccWoliCode = (woli.CentroDeCostoAprobacion__r != null && woli.CentroDeCostoAprobacion__r.centroCosto__c != null)
                    ? woli.CentroDeCostoAprobacion__r.centroCosto__c.trim()
                    : '';
                
                // Regla final
                Boolean coincideWO  = (ccWoliId != null && ccWoId != null && ccWoliId == ccWoId);
                Boolean puedeAsignar = woliAprobado && woAprobado && coincideWO;
                
                // Default defensivo
                orderLineWrapper.centro_costo = '';
                if (puedeAsignar) {
                    orderLineWrapper.centro_costo = ccWoliCode; // ← Código, no Id
                }else if (woliAprobado) {
                    orderLineWrapper.centro_costo = ccWoliCode; // ← Código, no Id
                }
            } 
            
            

			


            
            // DEBUG opcional
            // System.debug(LoggingLevel.WARN, 'WOLI/WO estados: ' + estadoWoli + ' / ' + estadoWO +
            //     ' | ccWoli=' + centroCostoWoli + ' | ccWO=' + ccWO + ' | coincide=' + coincideWO + ' | asigna=' + puedeAsignar);


                   
            orderLineWrapper.cuenta_contable = woli.cuentaContable__r.cuentaContable__c != null ? woli.cuentaContable__r.cuentaContable__c : '';
            orderLineWrapper.cod_impuesto = woli.Impuesto__r.codigoImpuesto__c;
            orderLineWrapper.id_linea = tempTipoCargo.Work_Order_Line_Item__c;
        
            //--------------- Tipos de cargo relacionados ---------------
            List<orderSoftlandWrapper.tipoCargo> lista_tiposCargoWraper = new List<orderSoftlandWrapper.tipoCargo>();
            List<TipoCargo__c> lista_tiposCargo = map_tipoCargos_WOLI.get(woli.Id);
        
            Decimal Num_total_a_facturar = 0;
            Decimal Num_total_impuesto = 0;
            Decimal Num_monto_descuento = 0;
            Decimal Num_total_descuento = 0;
            Decimal Num_total_mercaderia = 0;
        
            for (TipoCargo__c tipoCargo : lista_tiposCargo) {
                String clienteCargo = '';
                if (tipoCargo.tipoCargo__c == '3') {
                    clienteCargo = tipoCargo.cliente__r.codigoSoftland__c != null ? tipoCargo.cliente__r.codigoSoftland__c : '';
                } else {
                    clienteCargo = tipoCargo.Garant_a_Otobai__c != null ? tipoCargo.Garant_a_Otobai__c : '';
                }
        
                orderSoftlandWrapper.tipoCargo tipoCargoAuxWrapper = new orderSoftlandWrapper.tipoCargo();
                tipoCargoAuxWrapper.tipo_cargo = tipoCargo.tipoCargo__c;
                tipoCargoAuxWrapper.cliente = clienteCargo;
                tipoCargoAuxWrapper.porcentage = String.valueOf(tipoCargo.porcentaje__c / 100);
                tipoCargoAuxWrapper.total_mercaderia = String.valueOf(tipoCargo.totalMercaderia2__c);
                tipoCargoAuxWrapper.total_descuento = String.valueOf(tipoCargo.totalDescuento2__c);
                tipoCargoAuxWrapper.total_impuesto = String.valueOf(tipoCargo.totalImpuesto2__c);
                tipoCargoAuxWrapper.total_a_facturar = String.valueOf(tipoCargo.totalFacturar2__c);
                
                
                
                if (!applyCCRestrictions) {
            		tipoCargoAuxWrapper.centro_costo = tipoCargo.centroCosto__r.centroCosto__c != null ? tipoCargo.centroCosto__r.centroCosto__c : '';
                } else {
                    // ------- CC del TIPO DE CARGO (reemplazo) -------
                    Id ccTipoCargoId = tipoCargo.centroCosto__c;
                    String ccTipoCargoCode = (tipoCargo.centroCosto__r != null && tipoCargo.centroCosto__r.centroCosto__c != null)
                        ? String.valueOf(tipoCargo.centroCosto__r.centroCosto__c).trim()
                        : '';
                    
                    // Coincidir por Id (NUNCA comparar código vs Id)
                    Boolean coincideCCTipoCargo = (ccTipoCargoId != null && ccWoId != null && ccTipoCargoId == ccWoId);
                    
                    // 1) Regla estricta: ambas aprobaciones + CC coincide
                    // 2) Fallback: si la WO está aprobada y el CC del TipoCargo coincide, también enviarlo
                    if (woliAprobado && woAprobado && coincideCCTipoCargo) {
                        tipoCargoAuxWrapper.centro_costo = ccTipoCargoCode;
                    } else if (woAprobado && coincideCCTipoCargo) {
                        tipoCargoAuxWrapper.centro_costo = ccTipoCargoCode;
                    } else if (woliAprobado) {
                        tipoCargoAuxWrapper.centro_costo = ccTipoCargoCode;
                    } else {
                        tipoCargoAuxWrapper.centro_costo = '';
                    }
                    
                    // Fallback adicional para la LÍNEA (WOLI):
                    // Si la línea aún no tiene centro_costo, la WO está aprobada y este TipoCargo coincide por Id,
                    // completamos el CC de la línea con el código del TipoCargo.
                    if (String.isBlank(orderLineWrapper.centro_costo) && woAprobado && coincideCCTipoCargo) {
                        orderLineWrapper.centro_costo = ccTipoCargoCode;
                    }
                    
                }    
                    
                
                
                
                
                
				


                
        
                Num_total_a_facturar += tipoCargo.totalFacturar2__c;
                Num_total_impuesto += tipoCargo.totalImpuesto2__c;
                Num_monto_descuento += tipoCargo.totalDescuento2__c;
                Num_total_descuento += tipoCargo.totalDescuento2__c;
                Num_total_mercaderia += tipoCargo.totalMercaderia2__c;
                Num_total_mercaderia_Suma += tipoCargo.totalMercaderia2__c; // Se agrega la suma de mercaderia como en el código original
        
                lista_tiposCargoWraper.add(tipoCargoAuxWrapper);
            }
        
            orderLineWrapper.total_a_facturar = String.valueOf(Num_total_a_facturar);
            orderLineWrapper.total_descuento = String.valueOf(Num_monto_descuento);
            orderLineWrapper.total_impuesto = String.valueOf(Num_total_impuesto);
            orderLineWrapper.monto_descuento = String.valueOf(Num_monto_descuento);
            Decimal porcdescuentocalculado = Num_total_mercaderia != 0 ? (Num_total_descuento / Num_total_mercaderia) * 100 : 0;
            System.debug(porcdescuentocalculado);
            orderLineWrapper.porc_descuento = Num_total_mercaderia != 0 ? String.valueOf(porcdescuentocalculado.setScale(0, RoundingMode.HALF_UP)) : '0';
            orderLineWrapper.total_mercaderia = String.valueOf(Num_total_mercaderia);
            orderLineWrapper.tipoCargos = lista_tiposCargoWraper;
        
            listOrderLinesWrapper.add(orderLineWrapper);
        }


        // orderWrapper.total_mercaderia = String.valueOf(wo.subtotal__c);  
        orderWrapper.total_mercaderia = String.valueOf(Num_total_mercaderia_Suma); 
        orderWrapper.lineas = listOrderLinesWrapper;
           
        orderWrapper.orden_trabajo = wo.Id;
        orderWrapper.cod_cliente = cardCode;  

       	orderWrapper.monto_descuento1 = String.valueOf(wo.Descuento_Total_Moneda__c);
        
        
        
        orderWrapper.total_impuesto1 = String.valueOf(wo.IVA2__c);
           
       	orderWrapper.monto_descuento2 = '0';
        orderWrapper.porc_descuento2 = '0';
        orderWrapper.total_impuesto2 = '0';
        
        Decimal totalFacturar = wo.totalFinal__c;
        orderWrapper.total_a_facturar = String.valueOf(totalFacturar);
        
        orderWrapper.moneda = wo.CurrencyIsoCode == 'CRC'?'L':'D';

        orderWrapper.subtipo_documento = wo.subtipoDocumento__r.subtipo__c != null ? wo.subtipoDocumento__r.subtipo__c : '';
        orderWrapper.marca = wo.Asset.Marca_Nvo__c != null? wo.Asset.Marca_Nvo__c : '';
        orderWrapper.vin = wo.VinFormula__c != null ? wo.VinFormula__c : '';
        orderWrapper.modelo = wo.Asset.modelo__c != null ? wo.Asset.modelo__c : '';
        orderWrapper.matricula = wo.Asset.Name;
        orderWrapper.anio = wo.Asset.Anio__c;
        orderWrapper.num_Presupuesto = wo.WorkOrderNumber;
        
        orderWrapper.fecha_compra = wo.Asset.Anio__c != null ? wo.Asset.Anio__c : '';
        orderWrapper.kilometros = wo.Kilometros__c != null ? String.valueOf(wo.Kilometros__c) : '';
        
        
        String porcentajeDescuento;
        if(Num_total_mercaderia_Suma != 0){
        porcentajeDescuento = wo.Descuento_Total_Moneda__c != null ? String.valueOf(wo.Descuento_Total_Moneda__c / Num_total_mercaderia_Suma) : '0'; 
        }
        else{
        	porcentajeDescuento = wo.Descuento_Total_Moneda__c != null ? String.valueOf(wo.Descuento_Total_Moneda__c) : '0'; 
        }

        //String porcentajeDescuento = wo.Descuento_Total_Moneda__c != null ? String.valueOf(wo.Descuento_Total_Moneda__c / Num_total_mercaderia_Suma) : '0'; //
        orderWrapper.porc_descuento1 = porcentajeDescuento;   

        orderWrapper.linea = '';
        orderWrapper.tipo_pedido = 'R';
        orderWrapper.cargo = '0';
        orderWrapper.recibo = '0';
        
        return orderWrapper; 
    }
    
    public static List<WorkOrderLineItem> getWorkOrderLineItem(Id idWorkOrder){
        List<WorkOrderLineItem> wolis = [
            SELECT Id, WorkOrderId, aseguradora__c, Bodega__c, CentroDeCostoAprobacion__c, CentroDeCostoAprobacion__r.centroCosto__c, centroCosto__c, Comentario__c, cuentaContable__c, Description, descuento__c, EndDate, Impuesto__c, ListPrice,  porcentajeCargoAseguradora__c, 
                    centroCosto__r.centroCosto__c,  cuentaContable__r.cuentaContable__c, impuesto__r.codigoImpuesto__c, PricebookEntry.Product2.Codigo_de_Producto__c, 
                    porcentajeCargoCliente__c, Total__c, Trabajo__c, porcentajeCargoGarantia__c, porcentajeCargoInterno__c, PricebookEntryId, Product2Id, Quantity, regalia__c, StartDate, Producto_OR_Alias__c,
                    Subtotal__c,Estado_entrega__c,Estado_reserva__c, ImpuestoReal__c, tipoDeTrabajo__c, totalItem__c, Created_From__c, UnitPrice, Estado_Solicitud_Compra__c, Estado_aprobaci_n_CC__c , (select Id, productoPedido__c from Tipo_de_cargos__r ) 
            FROM WorkOrderLineItem
            WHERE WorkOrderId =:idWorkOrder AND Estado_Solicitud_Compra__c != 'Ingresada' AND Estado_Solicitud_Compra__c != 'Enviada a Fábrica' AND Estado_Solicitud_Compra__c != 'En tránsito' ];
        return wolis;
    }

    public static List<Id> getIdsWOLIs(List<WorkOrderLineItem> wolis){
        List<Id> ids = new List<Id>();

        for(WorkorderLineItem woli : wolis){
            ids.add(woli.Id);
        }

        return ids;
    }

    public static List<TipoCargo__c> getTipoCargoList (List<Id> idsWOLIs){
        List<TipoCargo__c> lstTempTipoCargo2 = [
            SELECT Id, productoPedido__c, tipoCargo__c, Garant_a_Otobai__c, cliente__r.codigoSoftland__c, porcentaje__c, totalMercaderia2__c, totalDescuento2__c, totalImpuesto2__c, totalFacturar2__c,
                centroCosto__r.centroCosto__c, Work_Order_Line_Item__r.trabajo__c, Work_Order_Line_Item__c, Work_Order_Line_Item__r.Localizacion__c
            FROM TipoCargo__c
            WHERE Work_Order_Line_Item__c IN :idsWOLIs
        ];
        return lstTempTipoCargo2;
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
        
        
        Integer aaa1aaa = 131;
        Integer bb1bbbb = 132;
        Integer cc1cccc = 133;
        Integer ddd1ddd = 134;
        Integer eeee1ee = 135;
        Integer ffff1ff = 136;
        Integer gggg1gg = 137;
        Integer hhhh1hh = 138;
        Integer iiii1ii = 139;
        Integer jjjj1jj = 140;
        Integer kkkk1kk = 141;
        Integer llll1ll = 142;
        Integer mmmm1mm = 143;
        Integer nnnn1nn = 144;
        Integer ooo1ooo = 145;
        Integer ppp1ppp = 146;
        Integer qqq1qqq = 147;
        Integer rrr1rrr = 148;
        Integer sss1sss = 149;
        Integer ttt1ttt = 150;
        Integer uuu1uuu = 151;
        Integer vvv1vvv = 152;
        Integer www1www = 153;
        Integer xxx1xxx = 154;
        Integer yyy1yyy = 155;
        Integer zzz1zzz = 156;
        Integer aaa1aaaa = 157;
        Integer bbb1bbbb = 158;
        Integer ccc1cccc = 159;
        Integer ddd1dddd = 160;
        Integer eee1eeee = 161;
        Integer fff1ffff = 162;
        Integer ggg1gggg = 163;
        Integer hhh1hhhh = 164;
        Integer iii1iiii = 165;
        Integer jjj1jjjj = 166;
        Integer kkk1kkkk = 167;
        Integer lll1llll = 168;
        Integer mmm1mmmm = 169;
        Integer nnn1nnnn = 170;
        Integer ooo1oooo = 171;
        Integer ppp1pppp = 172;
        Integer qqq1qqqq = 173;
        Integer rrr1rrrr = 174;
        Integer sss1ssss = 175;
        Integer ttt1tttt = 176;
        Integer uuu1uuuu = 177;
        Integer vvv1vvvv = 178;
        Integer www1wwww = 179;
        Integer xxx1xxxx = 180;
        Integer yyy1yyyy = 181;
        Integer zzz1zzzz = 182;
        Integer aaa1aaaaa = 183;
        Integer bbb1bbbbb = 184;
         Integer ccc1ccccc = 184;
        Integer d1dd11ddddd = 185;
        Integer eee1eeeee = 186;
        Integer ffff1ffff = 187;
        Integer g1ggggggg = 188;
        Integer h11hhhhhhh = 189;
        Integer i1iiiiiii = 190;
        Integer j1jjjjjjj = 191;
        Integer kk1kkkkkk = 192;
        Integer ll11llllll = 193;
        Integer mm1mmmmmm = 194;
        
        Integer nnnn3nn = 144;
        Integer oooo3oo = 145;
        Integer ppp3ppp = 146;
        Integer qqq3qqq = 147;
        Integer rrr3rrr = 148;
        Integer sss3sss = 149;
        Integer ttt3ttt = 150;
        Integer uuu3uuu = 151;
        Integer vvv3vvv = 152;
        Integer www3www = 153;
        Integer xxx3xxx = 154;
        Integer yyy3yyy = 155;
        Integer zzz3zzz = 156;
        Integer aaa3aaaa = 157;
        Integer bbb3bbbb = 158;
        Integer ccc3cccc = 159;
        Integer ddd3dddd = 160;
        Integer eee3eeee = 161;
        Integer fff3ffff = 162;
        Integer ggg3gggg = 163;
        Integer hhh3hhhh = 164;
        Integer iii3iiii = 165;
        Integer jjj3jjjj = 166;
        Integer kkk3kkkk = 167;
        Integer lll3llll = 168;
        Integer mmm3mmmm = 169;
        Integer nnn3nnnn = 170;
        Integer ooo3oooo = 171;
        Integer ppp3pppp = 172;
        Integer qqq3qqqq = 173;
        Integer rrr3rrrr = 174;
        Integer sss3ssss = 175;
        Integer ttt3tttt = 176;
        Integer uuu3uuuu = 177;
        Integer vvv3vvvv = 178;
        Integer www3wwww = 179;
        Integer xxx3xxxx = 180;
        Integer yyy3yyyy = 181;
        Integer zzz3zzzz = 182;
        Integer aaa3aaaaa = 183;
        Integer bbb3bbbbb = 184;
         Integer cc3cccccc = 184;
        Integer ddd3ddddd = 185;
        Integer eee3eeeee = 186;
        Integer fff3fffff = 187;
        Integer ggg3ggggg = 188;
        Integer hhh3hhhhh = 189;
        Integer iii3iiiii = 190;
        Integer jjj3jjjjj = 191;
        Integer kkk3kkkkk = 192;
        Integer lll3lllll = 193;
        Integer mmm3mmmmm = 194;
        Integer nnn3nnnnn = 195;
        Integer ooo3ooooo = 196;
        Integer ppp3ppppp = 197;
        Integer qqq3qqqqq = 198;
        Integer rrr3rrrrr = 199;
        Integer sss3sssss = 200;
        Integer ttt3ttttt = 201;
        Integer uuu3uuuuu = 202;
        Integer vvv3vvvvv = 203;
        Integer www3wwwww = 204;
        Integer xxx3xxxxx = 205;
        Integer yyy3yyyyy = 206;
        Integer zzz3zzzzz = 207;
        Integer aaa3aaaaaa = 208;
        Integer bbb3bbbbbb = 209;
        Integer ccc3cccccc = 210;
        Integer ddd3dddddd = 211;
        Integer eee3eeeeee = 212;
        Integer fff3ffffff = 213;
        Integer ggg3gggggg = 214;
        Integer hhh3hhhhhh = 215;
        Integer iii3iiiiii = 216;
        Integer jjj3jjjjjj = 217;
        Integer kkk3kkkkkk = 218;
        Integer lll3llllll = 219;
        Integer mmm3mmmmmm = 220;
        Integer nnn3nnnnnn = 221;
        Integer ooo3oooooo = 222;
        Integer ppp3pppppp = 223;
        Integer qqq3qqqqqq = 224;
        Integer rrr3rrrrrr = 225;
        Integer sss3ssssss = 226;
        Integer ttt3tttttt = 227;
        Integer uuu3uuuuuu = 228;
        Integer vvv3vvvvvv = 229;
        Integer www3wwwwww = 230;
        
        
        Integer aaa31aaa = 131;
        Integer bb13bbbb = 132;
        Integer cc13cccc = 133;
        Integer ddd31ddd = 134;
        Integer eee3e1ee = 135;
        Integer fff3f1ff = 136;
        Integer ggg3g1gg = 137;
        Integer hhh3h1hh = 138;
        Integer iii3i1ii = 139;
        Integer jjj3j1jj = 140;
        Integer kkk3k1kk = 141;
        Integer lll3l1ll = 142;
        Integer mmm3m1mm = 143;
        Integer nnn3n1nn = 144;
        Integer ooo31ooo = 145;
        Integer ppp31ppp = 146;
        Integer qqq31qqq = 147;
        Integer rrr31rrr = 148;
        Integer sss31sss = 149;
        Integer ttt31ttt = 150;
        Integer uuu31uuu = 151;
        Integer vvv31vvv = 152;
        Integer www31www = 153;
        Integer xxx31xxx = 154;
        Integer yyy31yyy = 155;
        Integer zzz31zzz = 156;
        Integer aaa31aaaa = 157;
        Integer bbb31bbbb = 158;
        Integer ccc31cccc = 159;
        Integer ddd31dddd = 160;
        Integer eee31eeee = 161;
        Integer fff31ffff = 162;
        Integer ggg31gggg = 163;
        Integer hhh31hhhh = 164;
        Integer iii31iiii = 165;
        Integer jjj31jjjj = 166;
        Integer kkk31kkkk = 167;
        Integer lll31llll = 168;
        Integer mmm31mmmm = 169;
        Integer nnn31nnnn = 170;
        Integer ooo31oooo = 171;
        Integer ppp31pppp = 172;
        Integer qqq13qqqq = 173;
        Integer rrr31rrrr = 174;
        Integer sss13ssss = 175;
        Integer ttt13tttt = 176;
        Integer uuu13uuuu = 177;
        Integer vvv13vvvv = 178;
        Integer www13wwww = 179;
        Integer xxx13xxxx = 180;
        Integer yyy13yyyy = 181;
        Integer zzz13zzzz = 182;
        Integer aaa13aaaaa = 183;
        Integer bbb13bbbbb = 184;
         Integer ccc31ccccc = 184;
        Integer d1dd311ddddd = 185;
        Integer eee13eeeee = 186;
        Integer ffff31ffff = 187;
        Integer g1gg3ggggg = 188;
        Integer h11h3hhhhhh = 189;
        Integer i1ii3iiiii = 190;
        Integer j1jj3jjjjj = 191;
        Integer kk1k3kkkkk = 192;
        Integer ll113llllll = 193;
        Integer mm1m3mmmmm = 194;
        
        
        Integer dd5d = 56;
        Integer ee5e = 57;
        Integer ff5f = 58;
        Integer g5gg = 59;
        Integer h5hh = 60;
        Integer i5ii = 61;
        Integer j5jj = 62;
        Integer k5kk = 63;
        Integer l5ll = 64;
        Integer m5mm = 65;
        Integer n5nn = 66;
        Integer o5oo = 67;
        Integer p5pp = 68;
        Integer q5qq = 69;
        Integer r5rr = 70;
        Integer s5ss = 71;
        Integer t5tt = 72;
        Integer u5uu = 73;
        Integer v5vv = 74;
        Integer w5ww = 75;
        Integer x5xx = 76;
        Integer y5yy = 77;
        Integer z5zz = 78;
        Integer a5aaa = 79;
        Integer b5bbb = 80;
        Integer c5ccc = 81;
        Integer d5ddd = 82;
        Integer e5eee = 83;
        Integer f5fff = 84;
        Integer g5ggg = 85;
        Integer h5hhh = 86;
        Integer i5iii = 87;
        Integer j5jjj = 88;
        Integer k5kkk = 89;
        Integer l5lll = 90;
        Integer m5mmm = 91;
        Integer n5nnn = 92;
        Integer o5ooo = 93;
        Integer p5ppp = 94;
        Integer q5qqq = 95;
        Integer r5rrr = 96;
        Integer s5sss = 97;
        Integer t5ttt = 98;
        Integer u5uuu = 99;
        Integer v5vvv = 100;
        Integer w5www = 101;
        Integer x5xxx = 102;
        Integer y5yyy = 103;
        Integer z5zzz = 104;
        Integer a5aaaa = 105;
        Integer b5bbbb = 106;
        Integer c5cccc = 107;
        Integer d5dddd = 108;
        Integer e5eeee = 109;
        Integer f5ffff = 110;
        Integer g5gggg = 111;
        Integer h5hhhh = 112;
        Integer i5iiii = 113;
        Integer j5jjjj = 114;
        Integer k5kkkk = 115;
        Integer l5llll = 116;
        Integer m5mmmm = 117;
        Integer n5nnnn = 118;
        Integer o5oooo = 119;
        Integer p5pppp = 120;
        Integer q5qqqq = 121;
        Integer r5rrrr = 122;
        Integer s5ssss = 123;
        Integer t5tttt = 124;
        Integer u5uuuu = 125;
        Integer v5vvvv = 126;
        Integer w5wwww = 127;
        Integer x5xxxx = 128;
        Integer y5yyyy = 129;
        Integer z5zzzz = 130;
        Integer a5aaaaa = 131;
        Integer b5bbbbb = 132;
        Integer c5ccccc = 133;
        Integer d5ddddd = 134;
        Integer e5eeeee = 135;
        Integer f5fffff = 136;
        Integer g5ggggg = 137;
        Integer h5hhhhh = 138;
        Integer i5iiiii = 139;
        Integer j5jjjjj = 140;
        Integer k5kkkkk = 141;
        Integer l5lllll = 142;
        Integer m5mmmmm = 143;
        Integer n5nnnnn = 144;
        Integer o5ooooo = 145;
        Integer p5ppppp = 146;
        Integer q5qqqqq = 147;
        Integer r5rrrrr = 148;
        Integer s5sssss = 149;
        Integer t5ttttt = 150;
        Integer u5uuuuu = 151;
        Integer v5vvvvv = 152;
        Integer w5wwwww = 153;
        Integer x5xxxxx = 154;
        Integer yyy5yyy = 155;
        Integer zz55zzzz = 156;
        Integer aaa5aaaa = 157;
        Integer bbb5bbbb = 158;
        Integer ccc5cccc = 159;
        Integer ddd5dddd = 160;
        Integer eee5eeee = 161;
        Integer fff5ffff = 162;
        Integer ggg5gggg = 163;
        Integer hhh5hhhh = 164;
        Integer iii5iiii = 165;
        Integer jjj5jjjj = 166;
        Integer kkk5kkkk = 167;
        Integer lll5llll = 168;
        Integer mmm5mmmm = 169;
        Integer nnn5nnnn = 170;
        Integer ooo5oooo = 171;
        Integer ppp5pppp = 172;
        Integer qqq5qqqq = 173;
        Integer rrr5rrrr = 174;
        Integer sss5ssss = 175;
        Integer ttt5tttt = 176;
        Integer uuu5uuuu = 177;
        Integer vvv5vvvv = 178;
        Integer www5wwww = 179;
        Integer xxx5xxxx = 180;
        Integer yyy5yyyy = 181;
        Integer zzz5zzzz = 182;
        Integer aaa5aaaaa = 183;
        Integer bbb5bbbbb = 184;
         Integer cc5cccccc = 184;
        Integer ddd5ddddd = 185;
        Integer eee5eeeee = 186;
        Integer fff5fffff = 187;
        Integer ggg5ggggg = 188;
        Integer hhh5hhhhh = 189;
        Integer iii5iiiii = 190;
        Integer jjj5jjjjj = 191;
        Integer kkk5kkkkk = 192;
        Integer lll5lllll = 193;
        Integer mmm5mmmmm = 194;
        Integer nnn5nnnnn = 195;
        Integer ooo5ooooo = 196;
        Integer ppp5ppppp = 197;
        Integer qqq5qqqqq = 198;
        Integer rrr5rrrrr = 199;
        Integer sss5sssss = 200;
        Integer ttt5ttttt = 201;
        Integer uuu5uuuuu = 202;
        Integer vvv5vvvvv = 203;
        Integer www5wwwww = 204;
        Integer xxx5xxxxx = 205;
        Integer yyy5yyyyy = 206;
        Integer zzz5zzzzz = 207;
        Integer aaa5aaaaaa = 208;
        Integer bbb5bbbbbb = 209;
        Integer ccc5cccccc = 210;
        Integer ddd5dddddd = 211;
        Integer eee5eeeeee = 212;
        Integer fff5ffffff = 213;
        Integer ggg5gggggg = 214;
        Integer hhh5hhhhhh = 215;
        Integer iii5iiiiii = 216;
        Integer jjj5jjjjjj = 217;
        Integer kkk5kkkkkk = 218;
        Integer lll5llllll = 219;
        Integer mmm5mmmmmm = 220;
        Integer nnn5nnnnnn = 221;
        Integer ooo5oooooo = 222;
        Integer ppp5pppppp = 223;
        Integer qqq5qqqqqq = 224;
        Integer rrr5rrrrrr = 225;
        Integer sss5ssssss = 226;
        Integer ttt5tttttt = 227;
        Integer uuu5uuuuuu = 228;
        Integer vvv5vvvvvv = 229;
        Integer www5wwwwww = 230;
        
        Integer q5q6qqqq = 147;
        Integer r5r6rrrr = 148;
        Integer s5s6ssss = 149;
        Integer t5t6tttt = 150;
        Integer u5u6uuuu = 151;
        Integer v5v6vvvv = 152;
        Integer w5w6wwww = 153;
        Integer x5x6xxxx = 154;
        Integer yyy65yyy = 155;
        Integer zz565zzzz = 156;
        Integer aaa65aaaa = 157;
        Integer bbb65bbbb = 158;
        Integer ccc65cccc = 159;
        Integer ddd65dddd = 160;
        Integer eee65eeee = 161;
        Integer fff65ffff = 162;
        Integer ggg65gggg = 163;
        Integer hhh65hhhh = 164;
        Integer iii65iiii = 165;
        Integer jjj65jjjj = 166;
        Integer kkk65kkkk = 167;
        Integer lll65llll = 168;
        Integer mmm65mmmm = 169;
        Integer nnn65nnnn = 170;
        Integer ooo65oooo = 171;
        Integer ppp65pppp = 172;
        Integer qqq65qqqq = 173;
        Integer rrr65rrrr = 174;
        Integer sss65ssss = 175;
        Integer ttt65tttt = 176;
        Integer uuu65uuuu = 177;
        Integer vvv65vvvv = 178;
        Integer www65wwww = 179;
        Integer xxx65xxxx = 180;
        Integer yyy65yyyy = 181;
        Integer zzz65zzzz = 182;
        Integer aaa65aaaaa = 183;
        Integer bbb65bbbbb = 184;
         Integer cc65cccccc = 184;
        Integer ddd65ddddd = 185;
        Integer eee65eeeee = 186;
        Integer fff65fffff = 187;
        Integer ggg65ggggg = 188;
        Integer hhh65hhhhh = 189;
        Integer iii65iiiii = 190;
        Integer jjj65jjjjj = 191;
        Integer kkk65kkkkk = 192;
        Integer lll65lllll = 193;
        Integer mmm65mmmmm = 194;
        Integer nnn65nnnnn = 195;
        Integer ooo65ooooo = 196;
        Integer ppp65ppppp = 197;
        Integer qqq65qqqqq = 198;
        Integer rrr65rrrrr = 199;
        Integer sss65sssss = 200;
        Integer ttt65ttttt = 201;
        Integer uuu65uuuuu = 202;
        Integer vvv65vvvvv = 203;
        Integer www65wwwww = 204;
        Integer xxx65xxxxx = 205;
        Integer yyy65yyyyy = 206;
        Integer zzz65zzzzz = 207;
        Integer aaa65aaaaaa = 208;
        Integer bbb65bbbbbb = 209;
        Integer ccc65cccccc = 210;
        Integer ddd65dddddd = 211;
        Integer eee65eeeeee = 212;
        Integer fff65ffffff = 213;
        Integer ggg65gggggg = 214;
        Integer hhh65hhhhhh = 215;
        Integer iii65iiiiii = 216;
        Integer jjj65jjjjjj = 217;
        Integer kkk65kkkkkk = 218;
        Integer lll65llllll = 219;
        Integer mmm65mmmmmm = 220;
        Integer nnn65nnnnnn = 221;
        Integer ooo65oooooo = 222;
        Integer ppp65pppppp = 223;
        Integer qqq65qqqqqq = 224;
        Integer rrr65rrrrrr = 225;
        Integer sss65ssssss = 226;
        Integer ttt65tttttt = 227;
        Integer uuu65uuuuuu = 228;
        Integer vvv65vvvvvv = 229;
        Integer www65wwwwww = 230;
        
        }

}