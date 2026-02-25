public with sharing class DespachoDeRepuestosPDFController
{
    public String workorderId {get;set;}
    public Workorder worder {get;set;}
    public List<ProductConsumed> pcList {get;set;}
    public List<ProductsConsumedWrapper> pcwList {get;set;}
    public List<WorkorderLIGroupWrapper> wliList {get;set;}
    public List<WorkorderGroupWrapper> wtList {get;set;}
    public List<tipoCargo__c> tipoCargo {get;set;}
    
    public double serviciosAdicionales {get;set;}  
    public double manodeObra {get;set;}  
    public double materiales  {get;set;}  
    public double descuento {get;set;}  
    public double subtotal {get;set;}  
    public double IV {get;set;}  
    public double moneda {get;set;}  
    public double total {get;set;}
    public String TotalTexto {get;set;}
    public Integer Centavos {get;set;}
    public decimal kilometros {get;set;}
    public string bodega {get;set;}
    public List<String> cargosSeleccionados {get;set;}
    /*----------------------------------------*/
    //Esteban Segura Benavides
    //05-01-2022
    public List<ProductsConsumedWrapper> itemsWO_MT {get; set;}
    public List<ProductsConsumedWrapper> itemsWO_MO {get; set;}
    /*----------------------------------------*/
    
    public DespachoDeRepuestosPDFController(ApexPages.StandardController controller) {
        
        workorderId = ApexPages.currentPage().getParameters().get('id');
        cargosSeleccionados = ApexPages.currentPage().getParameters().get('cargosSelected').split(',');
        // cargosSeleccionados = 'BSI Interno, Garantia'.split(',');
        
        itemsWO_MT = new List<ProductsConsumedWrapper>();
        itemsWO_MO = new List<ProductsConsumedWrapper>();

        worder = [SELECT Id, LocationId, Asesor_de_la_orden__c, MecanicoLider__c, tipoVenta__c, Address, BMW_CodigoDeProducto__c,AssetId, OwnerId, Cedula_Propietario__c, Direccion_propietario__c, Telefono_del_contacto__c, Subtotal__c, CurrencyISOCode,
                  Marca__c, Modelo__c, VIN__c, Matricula__c, Duration, Tipo_de_Cargo__c, WorkOrderNumber, CreatedDate, totalFinal__c,
                  Asset.ContactId, Asset.Account.Cedula__c, Asset.Account.ShippingStreet, Asset.Account.Type,Asset.Account.Phone, Asset.Account.PersonMobilePhone,
                  Asset.Account.Name,Asset.Account.Pais__c, Asset.Account.Provincia__pr.Name, Asset.Account.Canton__r.Name, Asset.Account.Distrito__r.Name,
                  Asset.Account.Barrio__c, Asset.Account.Calle__c, Asset.Account.Direccion_Residencial__c, Asset.Account.Direccion__c,
                  Asset.marca__c, Asset.modelo__c, Asset.NumeroDeChasis__c, Asset.numeroDePlaca__c, Nombre_del_propietario__c,Asset.Account.Description,
                  Asset.Anio__c, Description, Original_Order__c, montoManoDeObra__c, montoMateriales__c, montoVarios__c, Enderezado__c,
                  montoSubcontrato__c,Presupuesto__c, Kilometros__c, Kilometros2__c,Combustible__c,montoPintura__c, IVA__c,Fecha_de_entrega_estimada__c ,Fecha_prevista_de_entrega__c, Fecha_Cita__c, Fecha_de_Apertura__c,
                  Fecha_de_Entrada__c,EndDate ,Fecha_de_inscrpcion__c  , Tipo_de_servicio__c, F_Impresi_n__c ,Ampliaci_n__c,Pinturas__c,Eq_Interior__c ,Cambio__c, Motor__c, Comp_Seguros__c , Observaciones__c, Tipo_de_recepci_n__c,
                  Asset.Color__c, ContactId, Contact.Email, Contact.Name, ServiceTerritoryId, Tasas__c , B_I__c , Fecha_de_di_gnostico__c, CaseId,tipoDeGasto__c, GrandTotal,
                 
                  (SELECT Id, Description, Discount, ListPrice, PricebookEntryId, ProductConsumedNumber, QuantityConsumed, 
                  QuantityUnitOfMeasure, Subtotal, TotalPrice, UnitPrice, WorkOrderLineItemId, Aprobar__c
                  FROM ProductsConsumed),
                
                 (SELECT Id, Description, Duration,  Discount, ListPrice, PricebookEntryId, Quantity, Product2.tipoProducto__c, grupo__c, tiposDeTrabajo__c, tiposDeTrabajo__r.Name,
                  Subtotal, TotalPrice, UnitPrice, aprobado__c, Product2.tipoDeTrabajo__c, Product2.Name, Alias_Articulo__c, Producto_OR_Alias__c,  tipoDeTrabajo__c, porcentajeDescuento__c,  especificacionesTaller__c, Trabajo__c
                  FROM WorkorderLineItems Order by tiposDeTrabajo__c, especificacionesTaller__c, Trabajo__c)
                  FROM Workorder
                  WHERE Id =: workorderId];
                WorkOrder OT = [Select Id, AssetId,Kilometros__c From WorkOrder Where AssetId =: worder.AssetId AND CaseId =: worder.CaseId ORDER BY CreatedDate DESC limit 1];
                 kilometros = OT.Kilometros__c;

        // itemsWO_MT = [
        //                 SELECT Id, CurrencyIsoCode, Description, Duration, Discount, ListPrice, PricebookEntryId, Quantity, Product2.tipoProducto__c, Product2.tipoDeTrabajo__c, Product2.CurrencyIsoCode,
        //                 Product2.Name, Product2.Codigo_de_Producto__c, grupo__c, tiposDeTrabajo__c, tiposDeTrabajo__r.Name, Alias_Articulo__c, Producto_OR_Alias__c, Subtotal, TotalPrice, UnitPrice, aprobado__c, tipoDeTrabajo__c, 
        //                 porcentajeDescuento__c, especificacionesTaller__c, Trabajo__c
        //                 FROM WorkorderLineItem  
        //                 WHERE WorkOrderId = :workorderId AND Trabajo__c <> 'Mano de Obra'
        //             ];

        if(worder.GrandTotal != null && worder.GrandTotal >= 0) {
            Decimal centavoDecimal;
            centavoDecimal = (worder.GrandTotal - Integer.valueOf(worder.GrandTotal))*100;
            Centavos = Integer.valueOf(centavoDecimal);
            Long n = worder.GrandTotal.longValue();
            TotalTexto = NumberToWord.english_number(n);
        } else {
            TotalTexto = null;
        }

        System.debug('Work Order tipoDeGasto__c: '+ worder.tipoDeGasto__c);

        serviciosAdicionales = manodeObra = materiales = descuento = subtotal = IV = moneda = total = 0;        
        
        Map<String,String> tipoCargoMap = new Map<String,String>{
            '1' => 'Cliente',
            '2' => 'Interno',
            '3' => 'Aseguradora',
            '4' => 'Garantia',
            '5' => 'BSI',
            '6' => 'BSI Interno'
        };

        List<TipoCargo__c> tipoCargoMTList = new List<TipoCargo__c>();
        for(tipoCargo__c tipoCargo : [SELECT tipoCargo__c, Work_Order_Line_Item__r.Localizacion__c, Work_Order_Line_Item__r.Discount, Work_Order_Line_Item__r.Duration, Work_Order_Line_Item__r.Description, Work_Order_Line_Item__r.CurrencyIsoCode, Work_Order_Line_Item__r.ListPrice, Work_Order_Line_Item__r.PricebookEntryId, Work_Order_Line_Item__r.Quantity, Work_Order_Line_Item__r.Product2.tipoProducto__c, Work_Order_Line_Item__r.Product2.tipoDeTrabajo__c, Work_Order_Line_Item__r.Product2.CurrencyIsoCode, Work_Order_Line_Item__r.Product2.Name, Work_Order_Line_Item__r.Product2.Codigo_de_Producto__c, Work_Order_Line_Item__r.grupo__c, Work_Order_Line_Item__r.tiposDeTrabajo__c, Work_Order_Line_Item__r.tiposDeTrabajo__r.Name, Work_Order_Line_Item__r.Alias_Articulo__c, Work_Order_Line_Item__r.Producto_OR_Alias__c, Work_Order_Line_Item__r.Subtotal, Work_Order_Line_Item__r.TotalPrice, Work_Order_Line_Item__r.UnitPrice, Work_Order_Line_Item__r.aprobado__c, Work_Order_Line_Item__r.tipoDeTrabajo__c, Work_Order_Line_Item__r.porcentajeDescuento__c, Work_Order_Line_Item__r.especificacionesTaller__c, Work_Order_Line_Item__r.Trabajo__c, Work_Order_Line_Item__r.Bodega__r.bodega__c, totalMercaderia2__c, Tipo_de_Cargo_Formula__c FROM 
        TipoCargo__c 
        // WHERE Work_Order_Line_Item__r.WorkOrderId =:workorderId AND Work_Order_Line_Item__r.Trabajo__c = 'Materiales'])
        WHERE Work_Order_Line_Item__r.WorkOrderId =:workorderId AND Work_Order_Line_Item__r.Trabajo__c = 'Materiales'])

        {
            String tc = tipoCargoMap.get(tipoCargo.tipoCargo__c);
            System.debug('@@@@@@@@@@@@@@@@@ tipo cargo @@@@@@@@@@@@@@@@@@@@@@ '+ tc);
            System.debug('@@@@@@@@@@@@@@@@@ tipo cargo @@@@@@@@@@@@@@@@@@@@@@ '+ worder.tipoDeGasto__c);
            // if (tc != null && worder.tipoDeGasto__c !=null && tc.equalsIgnoreCase(worder.tipoDeGasto__c) ) {
            if (tc != null && worder.tipoDeGasto__c !=null && cargosSeleccionados.contains(tipoCargo.Tipo_de_Cargo_Formula__c) ) {


                Decimal unitPrice = tipoCargo.totalMercaderia2__c / tipoCargo.Work_Order_Line_Item__r.Quantity;
                materiales += tipoCargo.totalMercaderia2__c;
                bodega = tipoCargo.Work_Order_Line_Item__r.Bodega__r.bodega__c;
                
                itemsWO_MT.add(new ProductsConsumedWrapper(
                    null,
                    null,
                    tipoCargo.Work_Order_Line_Item__r.Producto_OR_Alias__c,
                    tipoCargo.Work_Order_Line_Item__r.CurrencyIsoCode,
                    tipoCargo.Work_Order_Line_Item__r.Quantity,
                    unitPrice,
                    tipoCargo.Work_Order_Line_Item__r.porcentajeDescuento__c,
                    tipoCargo.totalMercaderia2__c,
                    false,   
                    tipoCargo.Work_Order_Line_Item__r.Localizacion__c,
                    tipoCargo.Work_Order_Line_Item__r.Product2.Codigo_de_Producto__c 
                    // tipoCargo.Work_Order_Line_Item__r.Trabajo__c + '- ' + tipoCargo.Tipo_de_Cargo_Formula__c
                ));   
            }
        }

        System.debug('itemsWO size: '+ itemsWO_MT.size());
        System.debug('itemsWO_MT: '+ itemsWO_MT);

        // itemsWO_MO = [
        //                 SELECT Id, CurrencyIsoCode, Description, Duration, Discount, ListPrice, PricebookEntryId, Quantity, Product2.tipoProducto__c, Product2.tipoDeTrabajo__c, Product2.CurrencyIsoCode,
        //                 Product2.Name, Product2.Codigo_de_Producto__c, grupo__c, tiposDeTrabajo__c, tiposDeTrabajo__r.Name, Alias_Articulo__c, Producto_OR_Alias__c, Subtotal, TotalPrice, UnitPrice, aprobado__c, tipoDeTrabajo__c, 
        //                 porcentajeDescuento__c, especificacionesTaller__c, Trabajo__c 
        //                 FROM WorkorderLineItem  
        //                 WHERE WorkOrderId = :workorderId AND Trabajo__c =: 'Mano de Obra'
        //             ];
        
        // for(tipoCargo__c tipoCargo : [SELECT tipoCargo__c, Work_Order_Line_Item__r.Localizacion__c, Work_Order_Line_Item__r.Discount, Work_Order_Line_Item__r.Duration, Work_Order_Line_Item__r.Description, Work_Order_Line_Item__r.CurrencyIsoCode, Work_Order_Line_Item__r.ListPrice, Work_Order_Line_Item__r.PricebookEntryId, Work_Order_Line_Item__r.Quantity, Work_Order_Line_Item__r.Product2.tipoProducto__c, Work_Order_Line_Item__r.Product2.tipoDeTrabajo__c, Work_Order_Line_Item__r.Product2.CurrencyIsoCode, Work_Order_Line_Item__r.Product2.Name, Work_Order_Line_Item__r.Product2.Codigo_de_Producto__c, Work_Order_Line_Item__r.grupo__c, Work_Order_Line_Item__r.tiposDeTrabajo__c, Work_Order_Line_Item__r.tiposDeTrabajo__r.Name, Work_Order_Line_Item__r.Alias_Articulo__c, Work_Order_Line_Item__r.Producto_OR_Alias__c, Work_Order_Line_Item__r.Subtotal, Work_Order_Line_Item__r.TotalPrice, Work_Order_Line_Item__r.UnitPrice, Work_Order_Line_Item__r.aprobado__c, Work_Order_Line_Item__r.tipoDeTrabajo__c, Work_Order_Line_Item__r.porcentajeDescuento__c, Work_Order_Line_Item__r.especificacionesTaller__c, Work_Order_Line_Item__r.Trabajo__c, Work_Order_Line_Item__r.Bodega__r.bodega__c ,  totalMercaderia2__c FROM TipoCargo__c WHERE Work_Order_Line_Item__r.WorkOrderId =:workorderId AND Work_Order_Line_Item__r.Trabajo__c = 'Mano de Obra'])
        // {
        //     String tc = tipoCargoMap.get(tipoCargo.tipoCargo__c);
        //     System.debug('@@@@@@@@@@@@@@@@@ tipo cargo @@@@@@@@@@@@@@@@@@@@@@ '+ tc);
        //     System.debug('@@@@@@@@@@@@@@@@@ tipo cargo @@@@@@@@@@@@@@@@@@@@@@ '+ worder.tipoDeGasto__c);
        //     if (tc != null && worder.tipoDeGasto__c !=null && tc.equalsIgnoreCase(worder.tipoDeGasto__c)) {

        //         Decimal unitPrice = tipoCargo.totalMercaderia2__c / tipoCargo.Work_Order_Line_Item__r.Quantity;
        //         manodeObra += tipoCargo.totalMercaderia2__c;
        //           bodega = tipoCargo.Work_Order_Line_Item__r.Bodega__r.bodega__c;

        //         itemsWO_MO.add(new ProductsConsumedWrapper(
        //             null,
        //             null,
        //             tipoCargo.Work_Order_Line_Item__r.Producto_OR_Alias__c,
        //             tipoCargo.Work_Order_Line_Item__r.CurrencyIsoCode,
        //             tipoCargo.Work_Order_Line_Item__r.Quantity,
        //             unitPrice,
        //             tipoCargo.Work_Order_Line_Item__r.porcentajeDescuento__c,
        //             tipoCargo.totalMercaderia2__c,
        //             false,
        //             tipoCargo.Work_Order_Line_Item__r.Localizacion__c,
        //             tipoCargo.Work_Order_Line_Item__r.Product2.Codigo_de_Producto__c         
        //         ));   
        //     }
        // }        
        
        pcList = worder.ProductsConsumed;
        
        pcwList = new List<ProductsConsumedWrapper>();
        for(ProductConsumed pc : pcList)
        {
            pcwList.add(new ProductsConsumedWrapper(pc.Id,
                                                    pc.ProductConsumedNumber,
                                                    null,
                                                    null,
                                                    pc.QuantityConsumed,
                                                    pc.UnitPrice,
                                                    pc.Discount,
                                                    pc.TotalPrice,
                                                    pc.Aprobar__c,
                                                    'NA',
                                                    'NA'
                                                    ));
        }
    
        
        wliList = new List<WorkorderLIGroupWrapper>();
        wtList = new List<WorkorderGroupWrapper>();
        
        Map<String, List<WorkorderLineItem>> wliMap = new Map<String, List<WorkorderLineItem>>();
        Map<String, List<WorkorderLineItem>> wliWrapMap = new Map<String, List<WorkorderLineItem>>();
        
        for(WorkorderLineItem wli : worder.WorkorderLineItems)
        {
            List<WorkorderLineItem> tempList = wliMap.get(wli.Product2.tipoProducto__c);
            
            if(tempList == null) tempList = new List<WorkorderLineItem>();
            
            tempList.add(wli);
            
            wliMap.put(wli.Product2.tipoProducto__c, tempList);
            
            List<WorkorderLineItem> tempWList = wliWrapMap.get(wli.tiposDeTrabajo__r.Name + '~~~' + wli.especificacionesTaller__c);
            
            if(tempWList == null) 
            tempWList = new List<WorkorderLineItem>();
            
            tempWList.add(wli);
            
            wliWrapMap.put(wli.tiposDeTrabajo__r.Name + '~~~' + wli.especificacionesTaller__c, tempWList);
            
            // if(wli.TotalPrice != null)
            // {
                //total += wli.TotalPrice;
            //     if (worder.totalFinal__c != null && worder.totalFinal__c >= 0) {
            //         Decimal centavoDecimal;
            //    centavoDecimal = (worder.totalFinal__c - Integer.valueOf(worder.totalFinal__c))*100;
            //    Centavos = Integer.valueOf(centavoDecimal);
            //     Long n = worder.totalFinal__c.longValue();
            // }
                // if(wli.Product2.tipoDeTrabajo__c == 'Servicios Adicionales')
                //     serviciosAdicionales += wli.TotalPrice;
                // if(wli.Product2.tipoProducto__c == 'Mano de Obra'){
                //     manodeObra += wli.TotalPrice;
                // }
                // if(wli.Product2.tipoProducto__c == 'Materiales'){
                //     materiales += wli.TotalPrice;
                // }
            // }
        }
        
        IV = ((materiales+manodeObra) * .13);
        total += materiales +manodeObra + IV;

        if (total >= 0) {
            Decimal centavoDecimal;
            centavoDecimal = (total - Integer.valueOf(total))*100;
            Centavos = Integer.valueOf(centavoDecimal);             
        }
                 
        for(String s : wliMap.keyset())
        {
            wliList.add(new WorkorderLIGroupWrapper(s, wliMap.get(s)));
        }
        
        for(String s : wliWrapMap.keyset())
        {
            List<String> sList = s.split('~~~');
            List<WorkorderTrabajoWrapper> wliTempList = new List<WorkorderTrabajoWrapper>();
            List<WorkorderLineItem> wliRecList = new List<WorkorderLineItem>();
            String trabajo;
            
            for(WorkorderLineItem wli : wliWrapMap.get(s))
            {
                if(trabajo != null && trabajo != wli.Trabajo__c)
                {
                    wliTempList.add(new WorkorderTrabajoWrapper(wliRecList[0].Trabajo__c, sList[1], wliRecList));
                    wliRecList = new List<WorkorderLineItem>();
                    wliRecList.add(wli);
                }
                else{
                    wliRecList.add(wli);
                }
                trabajo = wli.Trabajo__c;
            }
            
            if(wliRecList.size() > 0)
                wliTempList.add(new WorkorderTrabajoWrapper(trabajo, sList[1], wliRecList));
            
            WorkorderGroupWrapper wogwrap = new WorkorderGroupWrapper(sList[0], sList[1], wliTempList);
            wtList.add(wogwrap);
        }
        //System.assert(false, wliList);
    }

    public PageReference saveProductsConsumed()
    {
        update pcList;
        
        List<WorkorderLineItem > wliUpdateList = new List<WorkorderLineItem >();
        
        for(WorkorderGroupWrapper rec : wtList)
        {
            for(WorkorderTrabajoWrapper wlt : rec.wliList)
            {
                for(WorkorderLineItem wli : wlt.wliList)
                {    
                    wliUpdateList.add(wli);
                }
            }
        }
            
        if(wliUpdateList.size() > 0)
            update wliUpdateList;
        
        System.debug('wliUpdateList :::::' + wliUpdateList.size());
        System.debug('wliUpdateList :::::' + wliUpdateList);
        
        return new PageReference('/'+workorderId).setRedirect(true);
    } 
    
    public void submit()
    {
        List<WorkorderLineItem> wliUpdateList = new List<WorkorderLineItem>();
        
        for(WorkorderGroupWrapper rec : wtList)
        {
            for(WorkorderTrabajoWrapper wlt : rec.wliList)
            {
                for(WorkorderLineItemWrapper wli : wlt.wliwList)
                {    
                    wli.wli.aprobado__c = wli.aprobar;
                    wliUpdateList.add(wli.wli);
                }
            }
        }
            
        if(wliUpdateList.size() > 0)
            update wliUpdateList;
    }    
    
    public class WorkorderLIGroupWrapper
    {
        public String tipoDeTrabajo {get;set;}
        public decimal groupTotal {get;set;}
        public List<WorkorderLineItem> wliList {get;set;}
        public List<WorkorderLineItemWrapper> wliwList {get;set;}
        
        public WorkorderLIGroupWrapper(String tipoDeTrabajo,
                                       List<WorkorderLineItem> wliList)
        {
            this.tipoDeTrabajo = tipoDeTrabajo;
            this.wliList = wliList;
            this.groupTotal = 0;
            this.wliwList = new List<WorkorderLineItemWrapper>();
            
            for(WorkorderLineItem woli : wliList)
            {
                if(woli.TotalPrice != null)
                    groupTotal += woli.TotalPrice;
                
                wliwList.add(new WorkorderLineItemWrapper(woli, woli.aprobado__c));
            }
        }
    }
    
    public class WorkorderGroupWrapper
    {
        public String groupName {get;set;}
        public String className {get;set;}
        public decimal groupTotal {get;set;}
        public List<WorkorderTrabajoWrapper> wliList {get;set;}
        
        public WorkorderGroupWrapper(String groupName,
                                     String className,
                                     List<WorkorderTrabajoWrapper> wliList)
        {
            this.groupName = groupName;
            this.className = className;
            this.wliList = wliList;
            this.groupTotal = 0;
        }
    }
    
    public class WorkorderTrabajoWrapper
    {
        public String trabajoName {get;set;}
        public String className {get;set;}
        public decimal trabajoTotal {get;set;}
        public List<WorkorderLineItem> wliList {get;set;}
        public List<WorkorderLineItemWrapper> wliwList {get;set;}
        
        public WorkorderTrabajoWrapper(String trabajoName,
                                       String className,
                                       List<WorkorderLineItem> wliList)
        {
            this.trabajoName = trabajoName;
            this.className = className;
            this.wliList = wliList;
            this.trabajoTotal = 0;
            this.wliwList = new List<WorkorderLineItemWrapper>();
            
            for(WorkorderLineItem woli : wliList)
            {
                if(woli.TotalPrice != null)
                    trabajoTotal += woli.TotalPrice;
                
                wliwList.add(new WorkorderLineItemWrapper(woli, woli.aprobado__c));
            }
        }
    }
    
    public class WorkorderLineItemWrapper
    {
        public WorkorderLineItem wli {get;set;}
        public Boolean aprobar {get;set;}
        
        public WorkorderLineItemWrapper(WorkorderLineItem wli,
                                        Boolean aprobar)
        {
            this.wli = wli;
            this.aprobar = aprobar;
        }
    }
    
    public class ProductsConsumedWrapper
    {
        public String productConsumedId {get;set;}
        public String productConsumedNumber {get;set;}
        public Decimal quantityConsumed {get;set;}
        public String description {get;set;}
        public String currencyCode {get;set;}
        public Decimal unitPrice {get;set;}
        public Decimal discount {get;set;}
        public Decimal totalPrice {get;set;}
        public Boolean aprobar {get;set;}
        public String localizacion {get;set;}
        public String codigoDeProductoCustom {get;set;}

        public ProductsConsumedWrapper(String productConsumedId,
                                       String productConsumedNumber,
                                       String description,
                                       String currencyCode,
                                       Decimal quantityConsumed,
                                       Decimal unitPrice,
                                       Decimal discount,
                                       Decimal totalPrice,
                                       Boolean aprobar,
                                       String localizacion,
                                       String codigoDeProductoCustom
                                       )
        {
            this.productConsumedId = productConsumedId;
            this.productConsumedNumber = productConsumedNumber;
            this.description = description;
            this.currencyCode = currencyCode;
            this.quantityConsumed = quantityConsumed;
            this.unitPrice = unitPrice;
            this.discount = discount;
            this.totalPrice = totalPrice;
            this.aprobar = aprobar;
            this.localizacion = localizacion;
            this.codigoDeProductoCustom = codigoDeProductoCustom;
        }
    }
}