public class orderJSONData {
	public static orderSoftlandWrapper getJSONFromOrder(String idOrder,String cardCode, String request_id)
    {
        Order vSelectedOrder = cls_DMLHelper.getOrder(idOrder);
        orderSoftlandWrapper vOrder = new orderSoftlandWrapper();
        vOrder.compania = vSelectedOrder.empresaQueFactura__c!=null?vSelectedOrder.empresaQueFactura__c:'';
        vOrder.request_id = request_id;
       
        
        if(vSelectedOrder.Work_Order__c != null){
        	WorkOrder wo = [Select Id, Description,Observaciones__c,Asesor_de_la_orden__c,Realizar_encuesta__c, AccountId,CaseId,Fecha_de_Apertura__c,Fecha_de_Entrada__c,
                            ContactId,Contact.FirstName,Contact.LastName,Origen__c, BMW_CategorizacionDeRespuestaEncuesta__c, Desea_financiamiento__c, Financiamiento_utilizado_Altica__c,Moneda_financiamiento_Altica__c 
                            from WorkOrder Where Id =: vSelectedOrder.Work_Order__c LIMIT 1];
            vOrder.tipo_ot=wo.Origen__c;
            
            
            if (wo.Observaciones__c != null) {
                if (wo.Observaciones__c.length() > 8000) {
                    vOrder.Observaciones_workorder = wo.Observaciones__c.substring(0, 8000);
                } else {
                    vOrder.Observaciones_workorder = wo.Observaciones__c;
                }
            } else {
                vOrder.Observaciones_workorder = '';
            }
            
            if (wo.Description != null) {
                if (wo.Description.length() > 8000) {
                    vOrder.Descripcion_workorder = wo.Description.substring(0, 8000);
                } else {
                    vOrder.Descripcion_workorder = wo.Description;
                }
            } else {
                vOrder.Descripcion_workorder = '';
            }

            
            if(wo.Asesor_de_la_orden__c != null){
                User usr = [Select Id,Name From User Where Id=:wo.Asesor_de_la_orden__c];
                vOrder.asesor = usr.Name;
            }else{vOrder.asesor = '';}
            
            
            if(wo.Realizar_encuesta__c=='Si'){
                vOrder.realizaEntrevista = 'Si';
                vOrder.justifica_encuesta = '';
            }else if(wo.Realizar_encuesta__c=='No'){
                
                vOrder.realizaEntrevista = 'No';
                vOrder.justifica_encuesta = wo.BMW_CategorizacionDeRespuestaEncuesta__c!=null?wo.BMW_CategorizacionDeRespuestaEncuesta__c:'';
            
            }
            else{
                vOrder.realizaEntrevista = '';
            }
            
            
            
            
            // Modificacion Diego Portalnet 2-Agosto 2022
            // 
            // 
            Case  Caso;
            Event  evento;
			if(wo.CaseId != null){
                 Caso = [Select Id,Description, CaseNumber, Cita__c, ContactId, Contact.Email ,Contact.Phone, Contact.Name from Case Where Id =: wo.CaseId LIMIT 1];
                 vOrder.numero_caso=Caso.CaseNumber;
                
                if (Caso.Description != null) {
                    if (Caso.Description.length() > 8000) {
                        vOrder.Descripcion_caso = Caso.Description.substring(0, 8000);
                    }
                    else {
                        vOrder.Descripcion_caso = Caso.Description;
                    }
                }else {
                        vOrder.Descripcion_caso = '';
                }
                
                
                List <Event> events = [SELECT Id, StartDateTime, EndDateTime,CreatedDate,StartDateTimeF__c, Case__c, Work_Order__c,OrigenEvento__c FROM Event WHERE Case__c=: Caso.Id order by createdDate desc limit 1];
                
                //System.debug('Lista ' + evento);
                
                if(events!=null && events.size()>0){
                    evento= events[0];
                    vOrder.fecha_cita=evento.StartDateTimeF__c;
                    vOrder.fecha_agenda_cita=String.valueOf(evento.CreatedDate);
                    vOrder.u_origen_cita=evento.OrigenEvento__c;
                    
                }
                
                
            }else{vOrder.numero_caso = '';}
            
            
            Account Cuenta = [Select Id, CorreoElectronicoEmpresarial__c,NombreEncargadoCuenta__c,Correo_Encargado_Cuenta__c,TelefonoEncargadoCuenta__c, PersonEmail,Cedula__c,toLabel(Tipo_de_Documento__c),Phone,PersonMobilePhone,Invoice_Email__c,Invoice_Phone__c, Name,FirstName,LastName, IsPersonAccount from Account Where Id =: wo.AccountId LIMIT 1];
			
            if(Wo.Desea_financiamiento__c=='Si'){
                vOrder.pagador='ALTICA SERVICIOS FINANCIEROS SOCIEDAD ANONIMA - DV';
                vOrder.codigo_pagador='C000672- DV';
                vOrder.monto_financiamiento=String.valueOf(wo.Financiamiento_utilizado_Altica__c);
                vOrder.moneda_financiamiento=String.valueOf(wo.Moneda_financiamiento_Altica__c);
                
            }
            
            
            if(Cuenta.CorreoElectronicoEmpresarial__c!=NULL){
                vOrder.correo=Cuenta.CorreoElectronicoEmpresarial__c;
            }else{
                vOrder.correo=Cuenta.PersonEmail;
            }
            vOrder.nombre_cuenta= Cuenta.Name;
            /*
            if(Cuenta.IsPersonAccount==False){
                if(Caso!=null){
                    vOrder.telefono_contacto=Caso.Contact.Phone;
                    vOrder.correo_contacto=Caso.Contact.Email;
                    vOrder.nombre_encargado=Caso.Contact.Name;
                }else{
                    vOrder.telefono_contacto=Cuenta.TelefonoEncargadoCuenta__c;
                    vOrder.correo_contacto=Cuenta.Correo_Encargado_Cuenta__c;
                    vOrder.nombre_encargado=Cuenta.NombreEncargadoCuenta__c;
                }
            
			*/
            if(Cuenta.IsPersonAccount==False){
                if(Caso!=null){
                        vOrder.telefono_contacto=Caso.Contact.Phone;
                        vOrder.correo_contacto=Caso.Contact.Email;
                        vOrder.nombre_encargado=Caso.Contact.Name;
                }else{
                    vOrder.telefono_contacto=Cuenta.TelefonoEncargadoCuenta__c;
                    vOrder.correo_contacto=Cuenta.Correo_Encargado_Cuenta__c;
                    vOrder.nombre_encargado=Cuenta.NombreEncargadoCuenta__c;
                }
            }
            
            if(wo.ContactId!=null && Cuenta.IsPersonAccount){
                vOrder.nombres_cuenta=wo.Contact.FirstName;
                vOrder.apellidos_cuenta=wo.Contact.LastName;
            }else if (wo.ContactId==null && Cuenta.IsPersonAccount){
                vOrder.nombres_cuenta=Cuenta.FirstName;
                vOrder.apellidos_cuenta=Cuenta.LastName;
            }else
            {
            	vOrder.nombres_cuenta=wo.Contact.FirstName;
                vOrder.apellidos_cuenta=wo.Contact.LastName;
            }
                
            vOrder.contribuyente_cuenta=Cuenta.Cedula__c;
            vOrder.tipo_id_contribuyente=Cuenta.Tipo_de_Documento__c;
            vOrder.telefono=Cuenta.Phone;
            vOrder.movil=Cuenta.PersonMobilePhone;
            
            vOrder.fecha_entrada=string.valueOfGmt(wo.Fecha_de_Entrada__c);
            
            
            
        }
        else{vOrder.asesor = '';}
        String observaciones = vSelectedOrder.Observaciones__c!=null?vSelectedOrder.Observaciones__c:''; 
        vOrder.observaciones = observaciones;
        //Ajuste de servicio
        vOrder.taller=vSelectedOrder.Work_Order__r.ServiceTerritory.Name;
        
        
        vOrder.comentarioCXC = vSelectedOrder.Comentario_CxC__c!=null?+vSelectedOrder.Comentario_CxC__c:'';
        vOrder.condicion_pago = vSelectedOrder.condicionPago__r.condicionPago__c!=null?vSelectedOrder.condicionPago__r.condicionPago__c:'';
        vOrder.total_mercaderia = String.valueOf(vSelectedOrder.Subtotal__c);
       	vOrder.monto_descuento1 = String.valueOf(vSelectedOrder.Descuento_Total_Moneda__c);
       	vOrder.monto_descuento2 = '0';
        
        String porcentajeDescuento = vSelectedOrder.porcentajeDescuento2__c!=null?String.valueOf(vSelectedOrder.porcentajeDescuento2__c):'0';
        vOrder.porc_descuento1 = porcentajeDescuento;
        
        vOrder.porc_descuento2 = '0';
        vOrder.total_impuesto1 = String.valueOf(vSelectedOrder.iva2__c);
        vOrder.total_impuesto2 = '0';
        
        Decimal totalFacturar = vSelectedOrder.Total_Final__c;
        vOrder.total_a_facturar = String.valueOf(totalFacturar);
        
        vOrder.moneda = vSelectedOrder.CurrencyIsoCode == 'CRC'?'L':'D';
        vOrder.condicion_pago = vSelectedOrder.condicionPago__r.condicionPago__c!=null?vSelectedOrder.condicionPago__r.condicionPago__c:'';
       	vOrder.cod_cliente = cardCode; 
       	vOrder.subtipo_documento = vSelectedOrder.subtipoDocumento__r.subtipo__c!=null?vSelectedOrder.subtipoDocumento__r.subtipo__c:'';
        vOrder.actividad_comercial = vSelectedOrder.ActividadComercial__r.codigo__c!=null?vSelectedOrder.ActividadComercial__r.codigo__c:'';
        //vOrder.tipo_pedido = 'N';//N o R (--Por confirmar-- y Reserva) Depende campo que se llama anticipo
        //if(vSelectedOrder.isValidated__c){vOrder.tipo_pedido='R';}
        vOrder.tipo_pedido = 'R'; // Se realiza el cambio a petición del cliente para que el servicio SIEMPRE RESERVE Septiembre 2022
        vOrder.orden_trabajo = vSelectedOrder.Id;
        vOrder.marca = vSelectedOrder.Work_Order__r.Asset.Marca_Nvo__c!=null?vSelectedOrder.Work_Order__r.Asset.Marca_Nvo__c:'';
        vOrder.vin = vSelectedOrder.Work_Order__r.VinFormula__c!=null?vSelectedOrder.Work_Order__r.VinFormula__c:'';
        vOrder.linea = '';
        vOrder.modelo = vSelectedOrder.Work_Order__r.Asset.modelo__c!=null?vSelectedOrder.Work_Order__r.Asset.modelo__c:'';
        vOrder.matricula = vSelectedOrder.Work_Order__r.Asset.Name;
        vOrder.anio = vSelectedOrder.Work_Order__r.Asset.Anio__c;
        
        vOrder.fecha_compra=vSelectedOrder.Work_Order__r.Asset.Anio__c!=null?vSelectedOrder.Work_Order__r.Asset.Anio__c:'';
        
        vOrder.kilometros = vSelectedOrder.Work_Order__r.kilometros__c!=null?String.valueOf(vSelectedOrder.Work_Order__r.kilometros__c):'';
        vOrder.num_Presupuesto = vSelectedOrder.Work_Order__r.WorkOrderNumber;
        vOrder.cargo = '0';
        vOrder.recibo = '0';
                
        Decimal Num_total_mercaderia_Suma = 0;

        List<OrderItem> vSelectedOrderItems = cls_DMLHelper.getOrderItem(idOrder);
        //Optimización SOQL Limit
        Map<Id, OrderItem> vSelectedOrderItems2 = new Map<Id, OrderItem>([SELECT Id,PricebookEntry.Product2.Codigo_de_Producto__c,PricebookEntry.Product2.Description, Bodega__r.bodega__c,Comentario__c,Quantity,Costo_Final__c,centroCosto__r.centroCosto__c, cuentaContable__r.cuentaContable__c,impuesto__r.codigoImpuesto__c,UnitPrice,totalItem__c,ListPrice, descuento__c,impuesto__c,montoImpuesto__c,porcentajeDescuento__c,impuesto__r.impuesto__c,ImpuestoReal__c,Subtotal__c, porcentajeDescuento2__c,ProductOrAlias__c FROM OrderItem WHERE OrderId = :idOrder]);
        List<TipoCargo__c> lstTempTipoCargo2 = [
            SELECT 
                Id, productoPedido__c, tipoCargo__c, Garant_a_Otobai__c, cliente__r.codigoSoftland__c, porcentaje__c,
                totalMercaderia2__c, totalDescuento2__c, totalImpuesto2__c, totalFacturar2__c,
                centroCosto__r.centroCosto__c, Work_Order_Line_Item__r.trabajo__c, Work_Order_Line_Item__c, Work_Order_Line_Item__r.Localizacion__c
            FROM 
            	TipoCargo__c
            WHERE 
            	productoPedido__c IN :vSelectedOrderItems2.keySet()
        ];
        Map <Id, List<TipoCargo__c>> mapTipoCargo = new Map <Id, List<TipoCargo__c>> ();
        List<TipoCargo__c> tipoClist;
        for(TipoCargo__c tipoC: lstTempTipoCargo2){
            if(!mapTipoCargo.containsKey(tipoC.productoPedido__C)){
                tipoClist = new List<TipoCargo__c>();
                tipoClist.add(tipoC);
                mapTipoCargo.put(tipoC.productoPedido__C, tipoClist);   
            }else{
                mapTipoCargo.get(tipoC.productoPedido__C).add(tipoC);
            }
        }
        List<orderSoftlandWrapper.lineOrder> orderLines = new List<orderSoftlandWrapper.lineOrder>();
        
        for (OrderItem lineItem : vSelectedOrderItems2.values()) {
            String descuentoProducto =  lineItem.descuento__c!=null?String.valueOf(lineItem.descuento__c):'0';
            String porcentajeDescuentoProducto = lineItem.porcentajeDescuento2__c !=null?String.valueOf(lineItem.porcentajeDescuento2__c):'0';
            Decimal impuestoProducto = lineItem.ImpuestoReal__c;
            Decimal totalFacturarProducto = lineItem.totalItem__c+impuestoProducto-Decimal.valueOf(descuentoProducto);
            Decimal cantidad = lineItem.Quantity;
           	Decimal	totalMercaderia = lineItem.Subtotal__c;//lineItem.ListPrice*cantidad; 
            
            //List<TipoCargo__c> lstTempTipoCargo = [SELECT Id,Work_Order_Line_Item__r.trabajo__c,Work_Order_Line_Item__c,Work_Order_Line_Item__r.Localizacion__c FROM TipoCargo__c WHERE productoPedido__C = :lineItem.Id];
            TipoCargo__c tempTipoCargo = mapTipoCargo.get(lineItem.Id)[0];
            String comentario = lineItem.Comentario__c != null?lineItem.Comentario__c:'';
            
            orderSoftlandWrapper.lineOrder orderLine = new orderSoftlandWrapper.lineOrder();
            orderLine.cod_articulo = lineItem.PricebookEntry.Product2.Codigo_de_Producto__c;
            orderLine.desc_articulo = lineItem.ProductOrAlias__c;
            orderLine.cod_bodega = lineItem.Bodega__c!=null?lineItem.Bodega__r.bodega__c:'';
            //orderLine.cod_localizacion = lstTempTipoCargo[0].Work_Order_Line_Item__r.Localizacion__c;//lineItem.cod_localizacion;
            orderLine.cod_localizacion = tempTipoCargo.Work_Order_Line_Item__r.Localizacion__c;//lineItem.cod_localizacion;
            orderLine.comentario = comentario;
            //Ajuste del servicio
            //orderLine.tipo_trabajo=lstTempTipoCargo[0].Work_Order_Line_Item__r.trabajo__c;
            orderLine.tipo_trabajo=tempTipoCargo.Work_Order_Line_Item__r.trabajo__c;
            orderLine.precio_unitario = String.valueOf(lineItem.UnitPrice);
            
            
            orderLine.cantidad = String.valueOf(cantidad);
            
            
            
            orderLine.centro_costo = lineItem.centroCosto__r.centroCosto__c!=null?lineItem.centroCosto__r.centroCosto__c:'';
            orderLine.cuenta_contable = lineItem.cuentaContable__r.cuentaContable__c!=null?lineItem.cuentaContable__r.cuentaContable__c:'';
            orderLine.cod_impuesto = lineItem.Impuesto__r.codigoImpuesto__c;
            
            //orderLine.id_linea = lstTempTipoCargo[0].Work_Order_Line_Item__c;
            orderLine.id_linea = tempTipoCargo.Work_Order_Line_Item__c;
            
            //--------------- Tipos de cargo relacionados ---------------
            List<orderSoftlandWrapper.tipoCargo> tiposCargo = new List<orderSoftlandWrapper.tipoCargo>();
            /*List<TipoCargo__c> lstTipoCargo = 	[
                									SELECT Id,tipoCargo__c,Garant_a_Otobai__c,cliente__r.codigoSoftland__c,porcentaje__c,totalMercaderia2__c,totalDescuento2__c,totalImpuesto2__c,
                										totalFacturar2__c,centroCosto__r.centroCosto__c 
                									FROM TipoCargo__c 
                									WHERE productoPedido__C = :lineItem.Id
            									];*/
            List<TipoCargo__c> lstTipoCargo = mapTipoCargo.get(lineItem.Id);
            Integer cantidadCargos = lstTipoCargo.size();
            Integer indiceTipoCargo = 1;
            
            
            Decimal Num_total_a_facturar = 0;
            Decimal Num_total_impuesto = 0;
            Decimal Num_monto_descuento = 0;
            Decimal Num_total_descuento = 0;
            Decimal Num_total_mercaderia = 0;
            
            for(TipoCargo__c tipoCargo : lstTipoCargo)
            {
                String clienteCargo ='';
                if(tipoCargo.tipoCargo__c=='3'){
                    clienteCargo = tipoCargo.cliente__r.codigoSoftland__c!=null?tipoCargo.cliente__r.codigoSoftland__c:'';
                }else{
                    clienteCargo = tipoCargo.Garant_a_Otobai__c!=null?tipoCargo.Garant_a_Otobai__c:'';
                }
                
                orderSoftlandWrapper.tipoCargo vTipoCargo = new orderSoftlandWrapper.tipoCargo();
                vTipoCargo.tipo_cargo = tipoCargo.tipoCargo__c;
                vTipoCargo.cliente = clienteCargo;
                vTipoCargo.porcentage = String.valueOf(tipoCargo.porcentaje__c/100);
                vTipoCargo.total_mercaderia = String.valueOf(tipoCargo.totalMercaderia2__c);
                vTipoCargo.total_descuento = String.valueOf(tipoCargo.totalDescuento2__c);
                vTipoCargo.total_impuesto = String.valueOf(tipoCargo.totalImpuesto2__c);
                vTipoCargo.total_a_facturar = String.valueOf(tipoCargo.totalFacturar2__c);
                vTipoCargo.centro_costo = tipoCargo.centroCosto__r.centroCosto__c!=null?tipoCargo.centroCosto__r.centroCosto__c:'';
                
                Num_total_a_facturar += tipoCargo.totalFacturar2__c;
                Num_total_impuesto += tipoCargo.totalImpuesto2__c;
                Num_monto_descuento += tipoCargo.totalDescuento2__c;
                Num_total_descuento += tipoCargo.totalDescuento2__c;
                Num_total_mercaderia += tipoCargo.totalMercaderia2__c;
                Num_total_mercaderia_Suma += tipoCargo.totalMercaderia2__c;
                
                tiposCargo.add(vTipoCargo);
            }
            
            orderLine.total_a_facturar = String.valueOf(Num_total_a_facturar);
            orderLine.total_descuento =  String.valueOf(Num_monto_descuento);
            orderLine.total_impuesto =   String.valueOf(Num_total_impuesto);
            orderLine.monto_descuento =  String.valueOf(Num_monto_descuento);
            orderLine.porc_descuento =   Num_total_mercaderia!=0?String.valueOf((Num_total_descuento/Num_total_mercaderia)*100):'';
            orderLine.total_mercaderia = String.valueOf(Num_total_mercaderia);
            //--------------- Fin Tipos cargo ---------------
            orderLine.tipoCargos = tiposCargo;
            orderLines.add(orderLine);
        }
        
        
        vOrder.total_mercaderia = String.valueOf(Num_total_mercaderia_Suma);
        
        vOrder.lineas = orderLines;        
        return vOrder; 
    }
}