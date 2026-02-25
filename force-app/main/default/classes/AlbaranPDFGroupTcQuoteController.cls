public with sharing class AlbaranPDFGroupTcQuoteController {
    String QuoteId;
    public Quote Quote {get;set;}
    public List<tiposDeTrabajoCaso__c> tiposDeTrabajoCaso {get;set;}
    public List<tipoCargo__c> tipoCargos {get;set;}
    public Map<String,WorkTypeWrapper> works {get;set;}
    public List<String> workList {get;set;}
    public decimal kilometros {get;set;}
    // public List<String> cargosSeleccionados {get;set;}
    public decimal montoManoDeObraReporte {get;set;}
    public decimal montoMaterialesReporte {get;set;}
    public decimal montoSubcontratoReporte {get;set;}
    public decimal montoPinturaReporte {get;set;}
    public decimal montoVariosReporte {get;set;}
    public decimal montoIVAReporte {get;set;}
    public decimal montoTotalReporte {get;set;}
    public string bodega {get;set;}
    
    public List<pedidoWrapper> pedWrap {get;set;}
    public List<String> pedido {get;set;}
    public String tipoPedido {get;set;}
    
    public string dateNow {get;set;}
    public string currencycode {get;set;}  
    public static Map<String,String> tipoActividadMap = new Map<String,String>{
        'recomendado' => '#50b81e',
            'sugerido' => '#f5d52b',
            'necesario' => '#fd0e01'
            };
                
                public AlbaranPDFGroupTcQuoteController(ApexPages.StandardController controller) {
                    QuoteId = ApexPages.currentPage().getParameters().get('id');
                    // cargosSeleccionados = ApexPages.currentPage().getParameters().get('cargosSelected').split(',');
                    // System.debug('------'+cargosSeleccionados);
                    works = getWorkTypeList(QuoteId);
                    workList = new List<String>();
                    workList.addAll(works.keySet());
                    workList.sort();
                    
                    dateNow = System.now().format('dd/MM/yyyy HH:mm:ss', UserInfo.getTimeZone().toString());
                    
                }
    
    public Map<String,WorkTypeWrapper> getWorkTypeList(Id QuoteId) {
        Map<String,WorkTypeWrapper> workTypeWrapperMap = new Map<String,WorkTypeWrapper>();
        
        quote = [SELECT Id, BMW_CodigoDeProducto__c, OwnerId, Opportunity.CurrencyISOCode,
                 Name, CreatedDate,BMW_Comentarios__c,CurrencyIsoCode,
                 ContactId, Account.Cedula__c,Account.ShippingStreet,Account.Type,Account.Phone, Account.PersonMobilePhone,Account.IsPersonAccount,
                 Account.Name,Account.Pais__c, Account.Provincia__pr.Name, Account.Canton__r.Name, Account.Distrito__r.Name,
                 Account.Barrio__c, Account.Calle__c, Account.Direccion_Residencial__c, Account.Direccion__c,
                 Opportunity.BMW_PlacaDeVehiculoOElVIN__r.marca__c, Opportunity.BMW_PlacaDeVehiculoOElVIN__r.modelo__c, Opportunity.BMW_PlacaDeVehiculoOElVIN__r.NumeroDeChasis__c, Opportunity.BMW_PlacaDeVehiculoOElVIN__r.numeroDePlaca__c,Account.Description,
                 Opportunity.BMW_PlacaDeVehiculoOElVIN__r.Anio__c, Description,
                 Opportunity.BMW_PlacaDeVehiculoOElVIN__r.Color__c, Contact.Email, Contact.Name, Opportunity.BMW_TallerDeServicio__c,
                 (SELECT id,product2.CurrencyIsoCode, product2id,BMW_TipoDeArticulo__c,Localizacion__c, product2.codigo_de_producto__c, product2.name, product2.costolocal__c, product2.tipoproducto__c, bmw_bodega__r.name, quantity, unitprice, 
                  discount, pricebookentryid, pricebookentry.unitprice,pricebookentry.currencyisocode, bmw_alias__c, bmw_bodega__c, bmw_bodega__r.bodega__c, productoporbodega__c,
                  productoporbodega__r.disponible__c, estado__c,estado_reserva__c, estado_entrega__c, estado_softland__c, cantidad_devolucion__c, estado_solicitud_compra__c,
                  Identificador_solicitud_de_compra__c, CantidadSC__c,Quote.Opportunity.BMW_TallerDeServicio__r.Email_Despacho__c
                  FROM QuoteLineItems)
                 FROM Quote
                 WHERE Id =: QuoteId];
        currencycode = quote.CurrencyISOCode;
        List<String> pedTemp = new List<String>();
        String pedTempTipo = '';
        
        
        // tipoPedido = pedTempTipo;
        // pedido = pedTemp;
      
        montoManoDeObraReporte = 0.00;
        montoMaterialesReporte = 0.00;
        montoSubcontratoReporte = 0.00;
        montoVariosReporte = 0.00;
        montoPinturaReporte = 0.00;
        
        
        String key = ''; 
        Set<Id> woliIds = new Set<Id>();
        for (QuoteLineItem qli : Quote.QuoteLineItems) {
            woliIds.add(qli.Id);
        }
        for (QuoteLineItem qli : Quote.QuoteLineItems) {
            bodega = qli.BMW_Bodega__r.bodega__c;
            
                    Decimal totalByTipoCargo = 0;
                    Decimal unitPrice =  qli.UnitPrice;
                    Decimal total = ( unitPrice* qli.Quantity);
                    totalByTipoCargo += total;

                    key = qli.BMW_TipoDeArticulo__c;
            System.debug('key '+key);
                        System.debug('workTypeWrapperMap.containsKey(key) '+workTypeWrapperMap.containsKey(key));

                    if (!workTypeWrapperMap.containsKey(key)) {
                                                System.debug('tipoActividadMap.get((String) qli.BMW_TipoDeArticulo__c.toLowercase())'+tipoActividadMap.get((String) qli.BMW_TipoDeArticulo__c.toLowercase()));
                        System.debug('totalByTipoCargo '+totalByTipoCargo);

                        workTypeWrapperMap.put(key,new WorkTypeWrapper(qli.BMW_TipoDeArticulo__c,tipoActividadMap.get((String) qli.BMW_TipoDeArticulo__c.toLowercase()),totalByTipoCargo));
                    }
                    WorkTypeWrapper workTypeWrapper = workTypeWrapperMap.get(key);
                    if (!workTypeWrapper.workMap.containsKey(qli.BMW_TipoDeArticulo__c)) {
                        workTypeWrapper.workMap.put(qli.BMW_TipoDeArticulo__c, new List<WorkOrderLineItemWrapper>());
                    }

                    List<WorkOrderLineItemWrapper> existingWOLIWrapperList = workTypeWrapper.workMap.get(qli.BMW_TipoDeArticulo__c);
                    existingWOLIWrapperList.add(new WorkOrderLineItemWrapper(
                        qli.Product2.Codigo_de_Producto__c,
                        qli.BMW_Alias__c,      
                        'Bajo-',                
                        qli.Quantity != null ?qli.Quantity : 0,
                        qli.Discount != null ? qli.Discount : 0, 
                        unitPrice,
                        qli.Product2.CurrencyIsoCode,
                        qli.Localizacion__c,
                        qli.Estado_entrega__c !=null ? qli.Estado_entrega__c : '',
                        total
                    ));
                    workTypeWrapper.workMap.put(qli.BMW_TipoDeArticulo__c,existingWOLIWrapperList);
                    workTypeWrapperMap.put(key,workTypeWrapper);
                    if (qli.BMW_TipoDeArticulo__c == 'Mano de Obra'){
                		montoManoDeObraReporte = montoManoDeObraReporte + total;  
                	} else if (qli.BMW_TipoDeArticulo__c == 'Materiales'){
                		montoMaterialesReporte = montoMaterialesReporte + total;   
                	} else if (qli.BMW_TipoDeArticulo__c == 'Subcontrato'){
                		montoSubcontratoReporte = montoSubcontratoReporte + total;  
                	} else if (qli.BMW_TipoDeArticulo__c == 'Pintura'){
                		montoPinturaReporte = montoPinturaReporte + total;
                	} else if (qli.BMW_TipoDeArticulo__c == 'Varios'){
                		montoVariosReporte = montoVariosReporte + total;
                	} 
        }
        montoIVAReporte = (montoManoDeObraReporte + montoMaterialesReporte + montoSubcontratoReporte + montoPinturaReporte + montoVariosReporte) * 0.13;
        montoTotalReporte = montoManoDeObraReporte + montoMaterialesReporte + montoSubcontratoReporte + montoPinturaReporte + montoVariosReporte + montoIVAReporte; 
        return workTypeWrapperMap;
    }
    
    
    class WorkTypeWrapper {
        public String name {get;set;}
        public String color {get;set;}
        public Map<String,List<WorkOrderLineItemWrapper>> workMap {get;set;}
        public decimal total {get;set;}
        WorkTypeWrapper(String name,String color,Decimal total){
            this.name = name;
            this.color = color;
            this.workMap = new Map<String,List<WorkOrderLineItemWrapper>>();
            this.total = total;
        }
    }
    class pedidoWrapper {
        public String orderCode {get;set;}
        public String orderType {get;set;}
        pedidoWrapper(String orderCode,String orderType){
            this.orderCode = orderCode;
            this.orderType = orderType;
        }
    }
    class WorkOrderLineItemWrapper {
        public String productCode {get;set;}
        public String description {get;set;}
        public String priority {get;set;}
        // public String priority {get;set;}
        public Decimal quantity {get;set;}
        public Decimal unitPrice {get;set;}
        public Decimal discount {get;set;}
        public String availability {get;set;}
        public String currencyIsoCode {get;set;}
        public Decimal total {get;set;}
        public String localizacion {get;set;}
        public String EstadoEntrega {get;set;}
        
        WorkOrderLineItemWrapper(){
            
        }
        
        WorkOrderLineItemWrapper(String productCode, String description,String priority,Decimal quantity,Decimal discount,Decimal unitPrice,String currencyIsoCode, String localizacion,String EstadoEntrega, Decimal total){
            this.productCode = productCode;
            this.description = description;
            this.priority = priority;
            this.quantity = quantity;
            this.unitPrice = unitPrice;
            this.discount = discount;
            this.currencyIsoCode = currencyIsoCode;
            this.total = total;
            this.localizacion = localizacion;
            this.EstadoEntrega = EstadoEntrega;
        }
    }
    
}