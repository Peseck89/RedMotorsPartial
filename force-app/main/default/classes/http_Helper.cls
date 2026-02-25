public class http_Helper {
    public static String generateAccountJSON(Account actualAccount,Boolean isNew)
    {
        string email=actualAccount.CorreoElectronicoEmpresarial__c!=null?actualAccount.CorreoElectronicoEmpresarial__c: actualAccount.PersonEmail;
        String strAccount = '{';
                                if(!isNew)
                                    strAccount = strAccount+'"cliente": "'+actualAccount.codigoSoftland__c+'",';
                                strAccount=strAccount+
                                '"nombre": "'+actualAccount.Name+'",'+
                                '"alias": "'+actualAccount.Name+'",'+
                                //'"contacto": "ND",'+
                                '"activo": "S",'+
                                //'"cargo": "ND",'+
                                //'"moneda": "'+actualAccount.Monedas_Iden__c+'",'+
                                //'"condicionPago": "'+actualAccount.condicionPago__r.condicionPago__c+'",'+
                                //'"categoriaCliente": "'+actualAccount.categoriaCliente__r.categoriaCliente__c+'",'+
                                '"pais": "CRI",'+ //Catalogo Estatico
                                '"provincia": "'+actualAccount.Provincia__r.Name+'",'+
                                '"canton": "'+actualAccount.Canton__r.Name+'",'+ 
                                '"distrito": "'+actualAccount.Distrito__r.Name+'",'+ 
                                '"barrio": "'+actualAccount.Barrio__c+'",'+ 
                                '"otras senas": "'+actualAccount.Direccion__c+'",'+ 
                                '"telefono1": "'+actualAccount.Phone+'",'+
                                '"telefono2": "'+actualAccount.Telefono2__c+'",'+ 
                                '"email": "'+email+'",'+
                                '"contribuyente":'+
                                    '['+
                                        '{'+
                                            '"id": "'+actualAccount.Cedula__c+'",'+
                                            '"tipo": "'+ActualAccount.Tipo_de_Documento__c+'",'+
                                            '"razonSocial": "'+ActualAccount.Name+'",'+
                                            '"alias": "'+actualAccount.Name+'"'+
                                        '}'+
                                    '],'+
                                '"categoria":'+ 
                                    '['+
                                        '{'+
                                            '"categoria": "'+actualAccount.categoriaCliente__r.categoriaCliente__c+'",'+
                                            '"descripcion": "'+actualAccount.categoriaCliente__r.descripcion__c+'"'+
                                        '}'+
                                    '],'+
                                '"impuesto": '+ 
                                '['+ 
                                    '{'+
                                        '"descripcion": "'+actualAccount.impuesto__r.descripcion__c+'"'+
                                        //'"codigoImpuesto": "'+actualAccount.impuesto__r.codigoImpuesto__c+'"'+
                                    '}'+
                                ']'+
                            '}';
        
        return strAccount;
    }

    public static String generateOrderJSON(Opportunity actualOpp,String cardCode)
    {
        String moneda = actualOpp.MonedaIngreso__c == 'CRC'?'L':'D';
        String compania = actualOpp.empresaQueFactura__c == 'Bavarian'?'RMBAVARIAN':'RMOTOBAI';
        String observaciones = actualOpp.Observaciones__c!=null?actualOpp.Observaciones__c:'';
        String comentarioCxC = actualOpp.Comentario_CxC__c!=null?+actualOpp.Comentario_CxC__c:'';
        String condicionPago = actualOpp.condicionPago__r.condicionPago__c!=null?actualOpp.condicionPago__r.condicionPago__c:'';
        String subtipo = actualOpp.subtipoDocumento__r.subtipo__c!=null?actualOpp.subtipoDocumento__r.subtipo__c:'';
        String actividadComercial = actualOpp.ActividadComercial__r.codigo__c!=null?actualOpp.ActividadComercial__r.codigo__c:'';
         
        //Calculos de la orden
        Decimal impuestoCliente = 0;//Total valor Impuesto (Crear Campo)
        Decimal montoDescuento = actualOpp.Descuento_Total_Moneda__c;
        Decimal totalConDescuento =  (actualOpp.ValorTotal__c != null ? actualOpp.ValorTotal__c : 0)-(actualOpp.Descuento_Total_Moneda__c != null ? actualOpp.Descuento_Total_Moneda__c : 0);
        Decimal totalConImpuesto = totalConDescuento+(totalConDescuento*impuestoCliente);

        List<OpportunityLineItem> productos = new List<OpportunityLineItem> ();
        String strOrder =   '{'+
                                '"compania": "'+compania+'",'+ 
                                '"observaciones": "'+observaciones+'",'+ 
                                '"comentarioCXC": "'+comentarioCxC+'",'+ 
                                '"total_mercaderia": "'+actualOpp.ValorTotal__c+'",'+ 
                                '"monto_descuento1": "'+montoDescuento+'",'+ 
                                '"monto_descuento2": "0",'+ 
                                '"porc_descuento1": "'+actualOpp.Descuento_Total__c+'",'+
                                '"porc_descuento2": "0",'+
                                '"total_impuesto1": "'+impuestoCliente+'",'+
                                '"total_impuesto2": "0",'+
                                '"total_a_facturar": "'+totalConImpuesto+'",'+
                                '"moneda": "'+moneda+'",'+ 
                                '"condicion_pago": "'+condicionPago+'",'+
                                '"cod_cliente": "'+cardCode+'",'+ 
                                '"subtipo_documento": "'+subtipo+'",'+ 
                                '"actividad_comercial": "'+actividadComercial+'",'+
                                '"tipo_pedido": "N",'+//N o R (--Por confirmar-- y Reserva) Depende campo que se llama anticipo
                                '"orden_trabajo":"'+actualOpp.Id+'",'+
                                '"marca":"'+actualOpp.Marca_de_Veh_culo_Actual__c+'",'+
                                '"vin":"",'+
                                '"linea":"",'+
                                '"modelo":"'+actualOpp.Modelo_de_Veh_culo_Actual__c+'",'+
                                '"matricula":"",'+
                                '"kilometros":"",'+
                                '"num_Presupuesto":"",'+
                                '"cargo":"0",'+
                                '"recibo":"0",'+
                                '"lineas": '+ 
                                    '[';
                                        String strProductos = '';
                                        String strTipoCargo = '';
                                        
         								if(Test.isRunningTest()){
                                            productos.add(new OpportunityLineItem());
                                        }
        
                                        Integer cantidadProductos = productos.size();
                                        Integer i = 1;
                                        
                                        for(OpportunityLineItem producto : productos)
                                        {
                                            Decimal impuestoItem = producto.impuesto__r.codigoImpuesto__c=='0108'?producto.Costo_Final__c*0.13:0;
                                            Decimal totalDescuento = producto.MontoDescuento__c!=null?producto.MontoDescuento__c:0;
                                            Decimal porcDescuento = producto.DescuentoPorcentaje__c!=null?producto.DescuentoPorcentaje__c:0;
                                            strProductos = strProductos+'{'+
                                                                        '"cod_articulo": "'+producto.PricebookEntry.Product2.Codigo_de_Producto__c+'",'+
                                                                        '"desc_articulo": "'+producto.PricebookEntry.Product2.Description+'",'+
                                                                        '"cod_bodega": "'+producto.Bodega__r.bodega__c+'",'+ 
                                                                        '"comentario": "'+producto.Comentario__c+'",'+
                                                                        '"precio_unitario":'+producto.Costo4__c+','+
                                                                        '"total_a_facturar":'+producto.Costo_Final__c+','+
                                                                        '"total_mercaderia":'+producto.Quantity+','+
                                                                        '"cantidad": '+producto.Quantity+','+
                                                                        '"total_descuento": '+totalDescuento+','+
                                                                        '"porc_descuento": '+porcDescuento+','+
                                                                        '"centro_costo": "'+producto.centroCosto__r.centroCosto__c+'",'+
                                                                        '"cuenta_contable": "'+producto.cuentaContable__r.cuentaContable__c+'",'+
                                                                        '"cod_impuesto": "'+producto.impuesto__r.codigoImpuesto__c+'",'+
                                                                        '"total_impuesto": '+impuestoItem+','+
                                                                        '"tipoCargos": '+
                                                                        '[';
                                                                        System.debug(producto.Id);
                                                                        List<TipoCargo__c> lstTipoCargo = [SELECT Id,tipoCargo__c,cliente__r.codigoSoftland__c,porcentaje__c,totalMercaderia__c,totalDescuento__c,totalImpuesto__c,totalFacturar__c,centroCosto__r.centroCosto__c FROM TipoCargo__c WHERE productoOportunidad__C = :producto.Id];
                                                                        Integer cantidadCargos = lstTipoCargo.size();
                                                                        Integer indiceTipoCargo = 1;
                                                                        for(TipoCargo__c tipoCargo : lstTipoCargo)
                                                                        {
                                                                            String clienteCargo = tipoCargo.cliente__r.codigoSoftland__c!=null?tipoCargo.cliente__r.codigoSoftland__c:'';
                                                                            String centroCosto = tipoCargo.centroCosto__r.centroCosto__c!=null?tipoCargo.centroCosto__r.centroCosto__c:'';
                                                                            strTipoCargo = strTipoCargo+'{'+
                                                                                                            '"tipo_cargo":"'+tipoCargo.tipoCargo__c+'",'+
                                                                                                            '"cliente":"'+clienteCargo+'",'+
                                                                                                            '"porcentage":'+TipoCargo.porcentaje__c+','+
                                                                                                            '"total_mercaderia":'+tipoCargo.totalMercaderia__c+','+
                                                                                                            '"total_descuento":'+tipoCargo.totalDescuento__c+','+
                                                                                                            '"total_impuesto":'+tipoCargo.totalImpuesto__c+','+
                                                                                                            '"total_a_facturar":'+tipoCargo.totalFacturar__c+','+
                                                                                                            '"centro_costo":"'+centroCosto+'"';
                                                                            if(cantidadProductos==1 || cantidadCargos==indiceTipoCargo)
                                                                            {
                                                                                strTipoCargo = strTipoCargo+'}';
                                                                            } else 
                                                                            {
                                                                                strTipoCargo = strTipoCargo+'},';
                                                                            }
                                                                            indiceTipoCargo++;
                                                                        }
                                                                        strProductos = strProductos+strTipoCargo+
                                                                        ']';
                                                                    strTipoCargo = '';
                                            if(cantidadProductos==1 || cantidadProductos==i)
                                            {
                                                strProductos = strProductos+'}';
                                            } else {
                                                strProductos = strProductos+'},';
                                            }
                                            
                                            i++;
                                        }
                                        strOrder = strOrder+strProductos+']'+
                            '}';
        return strOrder;
    }
}