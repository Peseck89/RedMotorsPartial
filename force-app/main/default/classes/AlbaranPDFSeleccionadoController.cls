public with sharing class AlbaranPDFSeleccionadoController {
    String workOrderId;
    public Workorder workOrder {get;set;}
    public List<tiposDeTrabajoCaso__c> tiposDeTrabajoCaso {get;set;}
    public List<tipoCargo__c> tipoCargos {get;set;}
    public Map<String,WorkTypeWrapper> works {get;set;}
    public List<String> workList {get;set;}
    public decimal kilometros {get;set;}
    public List<String> cargosSeleccionados {get;set;}
    public decimal montoManoDeObraReporte {get;set;}
    public decimal montoMaterialesReporte {get;set;}
    public decimal montoSubcontratoReporte {get;set;}
    public decimal montoPinturaReporte {get;set;}
    public decimal montoVariosReporte {get;set;}
    public decimal montoIVAReporte {get;set;}
    public decimal montoTotalReporte {get;set;}

    public List<pedidoWrapper> pedWrap {get;set;}
    public List<String> pedido {get;set;}
    public String tipoPedido {get;set;}

    public string bodega {get;set;}
    public string dateNow {get;set;}
    public string currencycode {get;set;} 
    public static Map<String,String> tipoActividadMap = new Map<String,String>{
        'recomendado' => '#50b81e',
        'sugerido' => '#f5d52b',
        'necesario' => '#fd0e01'
    };
                
    public AlbaranPDFSeleccionadoController(ApexPages.StandardController controller) {
        workOrderId = ApexPages.currentPage().getParameters().get('id');
        cargosSeleccionados = ApexPages.currentPage().getParameters().get('cargosSelected').split(',');
        System.debug('------'+cargosSeleccionados);
        works = getWorkTypeList(workOrderId);
        workList = new List<String>();
        workList.addAll(works.keySet());
        workList.sort();

        // String city = 'America/Costa_Rica';
        
        dateNow = System.now().format('dd/MM/yyyy HH:mm:ss', UserInfo.getTimeZone().toString());
        
    }
    
    public Map<String,WorkTypeWrapper> getWorkTypeList(Id workOrderId) {
        Map<String,WorkTypeWrapper> workTypeWrapperMap = new Map<String,WorkTypeWrapper>();
        
        workOrder = [SELECT Id,CaseId, BMW_CodigoDeProducto__c,AssetId, OwnerId, Cedula_Propietario__c, Direccion_propietario__c, Telefono_del_contacto__c, Subtotal__c, CurrencyISOCode,
                     Marca__c, Modelo__c, VIN__c, Matricula__c, Duration, Tipo_de_Cargo__c, WorkOrderNumber, CreatedDate, totalFinal__c,
                     Asset.ContactId, Asset.Account.Cedula__c, Asset.Account.ShippingStreet, Asset.Account.Type,Asset.Account.Phone, Asset.Account.PersonMobilePhone,
                     Asset.Account.Name,Asset.Account.Pais__c, Asset.Account.Provincia__pr.Name, Asset.Account.Canton__r.Name, Asset.Account.Distrito__r.Name,
                     Asset.Account.Barrio__c, Asset.Account.Calle__c, Asset.Account.Direccion_Residencial__c, Asset.Account.Direccion__c,
                     Asset.marca__c, Asset.modelo__c, Asset.NumeroDeChasis__c, Asset.numeroDePlaca__c, Nombre_del_propietario__c,Asset.Account.Description,
                     Asset.Anio__c, Description, Original_Order__c, montoManoDeObra__c, montoMateriales__c, montoVarios__c, Enderezado__c,
                     montoSubcontrato__c,Presupuesto__c, Kilometros__c, Kilometros2__c,Combustible__c,montoPintura__c, IVA__c,Fecha_de_entrega_estimada__c ,Fecha_prevista_de_entrega__c, Fecha_Cita__c, Fecha_de_Apertura__c,
                     Fecha_de_Entrada__c,EndDate ,Fecha_de_inscrpcion__c  , Tipo_de_servicio__c, F_Impresi_n__c ,Ampliaci_n__c,Pinturas__c,Eq_Interior__c ,Cambio__c, Motor__c, Comp_Seguros__c , Observaciones__c, Tipo_de_recepci_n__c,
                     Asset.Color__c, ContactId, Contact.Email, Contact.Name, ServiceTerritoryId, Tasas__c , B_I__c , Fecha_de_di_gnostico__c, MecanicoLider__c, tipoDeGasto__c,
                     (SELECT Id, Description,CurrencyIsoCode, Duration, Discount, ListPrice, PricebookEntryId, Quantity, Product2.tipoProducto__c, grupo__c, tiposDeTrabajo__c,Product2.CurrencyIsoCode,TipoTrabajoCaso__c,Subtotal,Product2.Name, 
                      TotalPrice, aprobado__c, Product2.tipoDeTrabajo__c, Alias_Articulo__c, Producto_OR_Alias__c,  tipoDeTrabajo__c, porcentajeDescuento__c,  especificacionesTaller__c, Trabajo__c,
                      Product2.Codigo_de_Producto__c,UnitPrice,Priority, Localizacion__c, Descuento_Formula__c,Estado_entrega__c
                      FROM WorkorderLineItems Order by LineItemNumber)
                     FROM Workorder
                     WHERE Id =: workorderId];
    currencycode = workOrder.CurrencyISOCode;
        WorkOrder lastWorkOrder = [Select Id, AssetId, Kilometros__c,Kilometros2__c  From WorkOrder Where AssetId =: workOrder.AssetId AND CaseId =: workOrder.CaseId ORDER BY CreatedDate DESC limit 1];
        kilometros = lastWorkOrder.Kilometros__c;
        
        montoManoDeObraReporte = 0.00;
        montoMaterialesReporte = 0.00;
        montoSubcontratoReporte = 0.00;
        montoVariosReporte = 0.00;
        montoPinturaReporte = 0.00;
        List<String> pedTemp = new List<String>();
                     String pedTempTipo = '';
                     
                    List<pedidoWrapper> pedWrapLst = new List<pedidoWrapper>();
                    List<Respuesta_pedido__c> pedidos = [SELECT ID, ID_Pedido_Softland__c,Tipo_cargo__c FROM Respuesta_pedido__c WHERE Work_Order__c =: workorderId AND Estado__c = 'En Proceso' AND Tipo_cargo__c IN :cargosSeleccionados];
                    if (pedidos.size() > 0) {
                        for (Respuesta_pedido__c ped : pedidos) {
                            pedidoWrapper pedidoAct = new pedidoWrapper(ped.ID_Pedido_Softland__c,ped.Tipo_cargo__c);

                            pedWrapLst.add(pedidoAct);
                        }
                        
                    }
                    pedWrap = pedWrapLst;
        String key = '';                
        for (WorkOrderLineItem workOrderLineItem : workOrder.WorkorderLineItems) {
            tipoCargos = [SELECT Id,Tipo_de_Cargo_Formula__c, tipoCargo__c, Work_Order_Line_Item__r.Trabajo__c, Work_Order_Line_Item__r.Bodega__r.bodega__c, totalMercaderia2__c FROM tipoCargo__c WHERE Work_Order_Line_Item__c =: workOrderLineItem.Id AND Work_Order_Line_Item__r.Trabajo__c = 'Materiales'];
            for (tipoCargo__c tCarg : tipoCargos){
                bodega = tCarg.Work_Order_Line_Item__r.Bodega__r.bodega__c;
                if (cargosSeleccionados.contains(tCarg.Tipo_de_Cargo_Formula__c)){
                   
                    Decimal totalByTipoCargo = 0;
                    Decimal unitPrice = tCarg.totalMercaderia2__c/ workOrderLineItem.Quantity;
                    Decimal total = ( unitPrice - ( unitPrice * ( workOrderLineItem.Descuento_Formula__c/100)) )* workOrderLineItem.Quantity;

                    if(tCarg.tipoCargo__c == '1'){
                        totalByTipoCargo += total;
                    } 
                    
                    if(tCarg.tipoCargo__c == '3'){
                        totalByTipoCargo += total;
                    } 
                    
                    if(tCarg.tipoCargo__c == '4'){
                        totalByTipoCargo += total;
                    } 
                    
                    if(tCarg.tipoCargo__c == '5'){
                        totalByTipoCargo += total;
                    } 
                    
                    if(tCarg.tipoCargo__c == '2'){
                        totalByTipoCargo += total;
                    } 
                    
                    if(tCarg.tipoCargo__c == '6'){
                        totalByTipoCargo += total;
                    }
                    
                    key =  tCarg.Tipo_de_Cargo_Formula__c+ '_' + workOrderLineItem.especificacionesTaller__c;
                    if (!workTypeWrapperMap.containsKey(key)) {
                        workTypeWrapperMap.put(key,new WorkTypeWrapper(tCarg.Tipo_de_Cargo_Formula__c,tipoActividadMap.get((String) workOrderLineItem.especificacionesTaller__c.toLowercase()),totalByTipoCargo));
                    }
                    
                    WorkTypeWrapper workTypeWrapper = workTypeWrapperMap.get(key);
                    if (!workTypeWrapper.workMap.containsKey(workOrderLineItem.Trabajo__c)) {
                        workTypeWrapper.workMap.put(workOrderLineItem.Trabajo__c, new List<WorkOrderLineItemWrapper>());
                    }

                    List<WorkOrderLineItemWrapper> existingWOLIWrapperList = workTypeWrapper.workMap.get(workOrderLineItem.Trabajo__c);
                    existingWOLIWrapperList.add(new WorkOrderLineItemWrapper(
                        workOrderLineItem.Product2.Codigo_de_Producto__c,
                        workOrderLineItem.Producto_OR_Alias__c,      
                        workOrderLineItem.Priority != null ? workOrderLineItem.Priority : '-',               
                        workOrderLineItem.Quantity != null ?workOrderLineItem.Quantity : 0,
                        workOrderLineItem.porcentajeDescuento__c != null ? workOrderLineItem.porcentajeDescuento__c : 0,
                        unitPrice,
                        workOrderLineItem.Product2.CurrencyIsoCode,
                        workOrderLineItem.Localizacion__c,
                        workOrderLineItem.Estado_entrega__c !=null ? workOrderLineItem.Estado_entrega__c : '',
                        total
                        
                    ));
                    workTypeWrapper.workMap.put(workOrderLineItem.Trabajo__c,existingWOLIWrapperList);
                    workTypeWrapperMap.put(key,workTypeWrapper);
                    if (workOrderLineItem.Trabajo__c == 'Mano de Obra'){
                    montoManoDeObraReporte = montoManoDeObraReporte + total;
                  } else if (workOrderLineItem.Trabajo__c == 'Materiales'){
                    montoMaterialesReporte = montoMaterialesReporte + total;    
                  } else if (workOrderLineItem.Trabajo__c == 'Subcontrato'){
                    montoSubcontratoReporte = montoSubcontratoReporte + total; 
                  } else if (workOrderLineItem.Trabajo__c == 'Pintura'){
                    montoPinturaReporte = montoPinturaReporte + total;
                  } else if (workOrderLineItem.Trabajo__c == 'Varios'){
                    montoVariosReporte = montoVariosReporte + total;
                  } 
                }
                // break;
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