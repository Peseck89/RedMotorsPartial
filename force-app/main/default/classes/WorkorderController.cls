public class WorkorderController 
{
    public String workorderId {get;set;}
    public Workorder worder {get;set;}
    public List<ProductConsumed> pcList {get;set;}
    public List<ProductsConsumedWrapper> pcwList {get;set;}
    public List<WorkorderLIGroupWrapper> wliList {get;set;}
    
    public double serviciosAdicionales {get;set;}  
    public double manodeObra {get;set;}  
    public double materiales  {get;set;}  
    public double descuento {get;set;}  
    public double subtotal {get;set;}  
    public double IV {get;set;}  
    public double moneda {get;set;}  
    public double total {get;set;}  
    
    public WorkorderController(ApexPages.StandardController controller) {
        workorderId = ApexPages.currentPage().getParameters().get('id');
        worder = [SELECT Id, OwnerId, Cedula_Propietario__c, Direccion_propietario__c, Telefono_del_contacto__c, Subtotal__c, CurrencyISOCode,
                  Marca__c, Modelo__c, VIN__c, Matricula__c, Duration, Tipo_de_Cargo__c, WorkOrderNumber, CreatedDate,
                  Asset.ContactId, Asset.Account.Cedula__c, Asset.Account.ShippingStreet, Asset.Account.Type,Asset.Account.Phone, Asset.Account.PersonMobilePhone,
                  Asset.Account.Name,Asset.Account.Pais__c, Asset.Account.Provincia__pr.Name, Asset.Account.Canton__r.Name, Asset.Account.Distrito__r.Name,
                  Asset.Account.Barrio__c, Asset.Account.Calle__c, Asset.Account.Direccion_Residencial__c, Asset.Account.Direccion__c,
                  Asset.marca__c, Asset.modelo__c, Asset.NumeroDeChasis__c, Asset.numeroDePlaca__c, Nombre_del_propietario__c,Asset.Account.Description,
                  Asset.Anio__c, Description, Original_Order__c, Original_Order__r.Name, montoManoDeObra__c, montoMateriales__c,
                  montoSubcontrato__c,Presupuesto__c, Kilometros__c,montoPintura__c, IVA__c,Fecha_de_entrega_estimada__c ,Fecha_prevista_de_entrega__c, Fecha_Cita__c, Fecha_de_Apertura__c,
                  Fecha_de_Entrada__c,EndDate ,Fecha_de_inscrpcion__c, Tipo_de_servicio__c, Observaciones__c, Tipo_de_recepci_n__c,
                  Asset.Color__c, ContactId, Contact.Email, Contact.Name, montoVarios__c, Tasas__c, B_I__c, 
                 (SELECT Id, Description, Discount, ListPrice, PricebookEntryId, ProductConsumedNumber, QuantityConsumed,
                  QuantityUnitOfMeasure, Subtotal, TotalPrice, UnitPrice, WorkOrderLineItemId, Aprobar__c
                  FROM ProductsConsumed),
                 (SELECT Id, Description, Duration,  Discount, ListPrice, PricebookEntryId, Quantity, Product2.tipoProducto__c, Grupo__c, porcentajeDescuento__c,
                  Subtotal, TotalPrice, UnitPrice, aprobado__c, Product2.tipoDeTrabajo__c, Product2.Name, especificacionesTaller__c
                  FROM WorkorderLineItems Order by Grupo__c, Product2.tipoProducto__c )
                  FROM Workorder
                  WHERE Id =: workorderId];
        
        pcList = worder.ProductsConsumed;
        
        pcwList = new List<ProductsConsumedWrapper>();
        for(ProductConsumed pc : pcList)
        {
            pcwList.add(new ProductsConsumedWrapper(pc.Id,
                                                    pc.ProductConsumedNumber,
                                                    pc.QuantityConsumed,
                                                    pc.UnitPrice,
                                                    pc.Discount,
                                                    pc.TotalPrice,
                                                    pc.Aprobar__c));
        }
        
        serviciosAdicionales = manodeObra = materiales = descuento = subtotal = IV = moneda = total = 0;
        
        wliList = new List<WorkorderLIGroupWrapper>();
        Map<String, List<WorkorderLineItem>> wliMap = new Map<String, List<WorkorderLineItem>>();
        
        for(WorkorderLineItem wli : worder.WorkorderLineItems)
        {
            List<WorkorderLineItem> tempList = wliMap.get(wli.Product2.tipoProducto__c);
            
            if(tempList == null) tempList = new List<WorkorderLineItem>();
            
            tempList.add(wli);
            
            wliMap.put(wli.Product2.tipoProducto__c, tempList);
            
            if(wli.TotalPrice != null)
            {
                total += wli.TotalPrice;
                if(wli.Product2.tipoDeTrabajo__c == 'Servicios Adicionales')
                    serviciosAdicionales += wli.TotalPrice;
                if(wli.Product2.tipoProducto__c == 'Mano de Obra')
                    manodeObra += wli.TotalPrice;
                if(wli.Product2.tipoProducto__c == 'Materiales')
                    materiales += wli.TotalPrice;
            }
        }
        
        IV = ((materiales+manodeObra) * .13);
        
        for(String s : wliMap.keyset())
        {
            wliList.add(new WorkorderLIGroupWrapper(s, wliMap.get(s)));
        }
    }

    public PageReference saveProductsConsumed()
    {
        update pcList;
        
        List<WorkorderLineItem > wliUpdateList = new List<WorkorderLineItem >();
        
        for(WorkorderLIGroupWrapper rec : wliList)
        {
            for(WorkorderLineItem wli : rec.wliList)
            {
                wliUpdateList.add(wli);
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
        
        for(WorkorderLIGroupWrapper rec : wliList)
        {
            for(WorkorderLineItemWrapper wli : rec.wliwList)
            {
                wli.wli.aprobado__c = wli.aprobar;
                wliUpdateList.add(wli.wli);
            }
        }
            
        if(wliUpdateList.size() > 0)
            update wliUpdateList;
            
        List<ProductConsumed> pcList = new List<ProductConsumed>();
        
        for(ProductsConsumedWrapper pcw : pcwList)
        {
            pcList.add(new ProductConsumed(Id = pcw.productConsumedId,
                                           Aprobar__c = pcw.aprobar));
        }
        
        if(pcList.size() > 0)
            update pcList;
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
        public Decimal unitPrice {get;set;}
        public Decimal discount {get;set;}
        public Decimal totalPrice {get;set;}
        public Boolean aprobar {get;set;}
        
        public ProductsConsumedWrapper(String productConsumedId,
                                       String productConsumedNumber,
                                       Decimal quantityConsumed,
                                       Decimal unitPrice,
                                       Decimal discount,
                                       Decimal totalPrice,
                                       Boolean aprobar)
        {
            this.productConsumedId = productConsumedId;
            this.productConsumedNumber = productConsumedNumber;
            this.quantityConsumed = quantityConsumed;
            this.unitPrice = unitPrice;
            this.discount = discount;
            this.totalPrice = totalPrice;
            this.aprobar = aprobar;
        }
    }
}