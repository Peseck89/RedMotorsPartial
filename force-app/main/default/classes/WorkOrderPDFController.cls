public with sharing class WorkOrderPDFController {
    String workOrderId;
    public Workorder workOrder {get;set;}
    public List<tiposDeTrabajoCaso__c> tiposDeTrabajoCaso {get;set;}
    public Map<String,WorkTypeWrapper> works {get;set;}
    public List<String> workList {get;set;}
    public decimal kilometros {get;set;}

    public static Map<String,String> tipoActividadMap = new Map<String,String>{
        'recomendado' => '#50b81e',
        'sugerido' => '#f5d52b',
        'necesario' => '#fd0e01'
    };

    public WorkOrderPDFController(ApexPages.StandardController controller) {
        workOrderId = ApexPages.currentPage().getParameters().get('id');
        works = getWorkTypeList(workOrderId);
        workList = new List<String>();
        workList.addAll(works.keySet());
        workList.sort();
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
        Asset.Color__c, ContactId, Contact.Email, Contact.Name, ServiceTerritoryId, Tasas__c , B_I__c , Fecha_de_di_gnostico__c,
       (SELECT Id, Description,CurrencyIsoCode, Duration, Discount, ListPrice, PricebookEntryId, Quantity, Product2.tipoProducto__c, grupo__c, tiposDeTrabajo__c,Product2.CurrencyIsoCode,TipoTrabajoCaso__c,Subtotal,Product2.Name, TotalPrice, aprobado__c, Product2.tipoDeTrabajo__c, Alias_Articulo__c, Producto_OR_Alias__c,  tipoDeTrabajo__c, porcentajeDescuento__c,  especificacionesTaller__c, Trabajo__c,Product2.Codigo_de_Producto__c,UnitPrice,Priority
        FROM WorkorderLineItems ORDER BY tiposDeTrabajo__c, especificacionesTaller__c, Trabajo__c)
        FROM Workorder
        WHERE Id =: workorderId];

        if (workOrder == null) {
            return workTypeWrapperMap;
        }

        WorkOrder lastWorkOrder = [Select Id, AssetId, Kilometros__c,Kilometros2__c  From WorkOrder Where AssetId =: workOrder.AssetId AND CaseId =: workOrder.CaseId ORDER BY CreatedDate DESC limit 1];
        kilometros = lastWorkOrder.Kilometros__c;

        String key = '';                
        for (WorkOrderLineItem workOrderLineItem : workOrder.WorkorderLineItems) {
            tiposDeTrabajoCaso = [SELECT Id, Nombre_TTC__c FROM tiposDeTrabajoCaso__c WHERE Id =: workOrderLineItem.TipoTrabajoCaso__c LIMIT 1];
            if(tiposDeTrabajoCaso.size() > 0) {
                key =  tiposDeTrabajoCaso[0].Nombre_TTC__c+ '_' + workOrderLineItem.especificacionesTaller__c;
                if (!workTypeWrapperMap.containsKey(key)) {
                workTypeWrapperMap.put(key,new WorkTypeWrapper(tiposDeTrabajoCaso[0].Nombre_TTC__c,tipoActividadMap.get((String) workOrderLineItem.especificacionesTaller__c.toLowercase())));
                }

                WorkTypeWrapper workTypeWrapper = workTypeWrapperMap.get(key);
                if (!workTypeWrapper.workMap.containsKey(workOrderLineItem.Trabajo__c)) {
                    workTypeWrapper.workMap.put(workOrderLineItem.Trabajo__c, new List<WorkOrderLineItemWrapper>());
                }
                List<WorkOrderLineItemWrapper> existingWOLIWrapperList = workTypeWrapper.workMap.get(workOrderLineItem.Trabajo__c);
                existingWOLIWrapperList.add(new WorkOrderLineItemWrapper(
                    workOrderLineItem.Producto_OR_Alias__c,                
                    workOrderLineItem.Priority != null ? workOrderLineItem.Priority : '-',                
                    workOrderLineItem.Quantity != null ?workOrderLineItem.Quantity : 0,
                    workOrderLineItem.porcentajeDescuento__c != null ? workOrderLineItem.porcentajeDescuento__c : 0,
                    workOrderLineItem.TotalPrice != null ?workOrderLineItem.TotalPrice : 0,
                    workOrderLineItem.Product2.CurrencyIsoCode
                ));
                workTypeWrapper.workMap.put(workOrderLineItem.Trabajo__c,existingWOLIWrapperList);
                workTypeWrapperMap.put(key,workTypeWrapper);
            }
            
            
        }
        return workTypeWrapperMap;
    }

    class WorkTypeWrapper {
        public String name {get;set;}
        public String color {get;set;}
        public Map<String,List<WorkOrderLineItemWrapper>> workMap {get;set;}
        WorkTypeWrapper(String name,String color){
            this.name = name;
            this.color = color;
            this.workMap = new Map<String,List<WorkOrderLineItemWrapper>>();
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

        WorkOrderLineItemWrapper(){

        }

        WorkOrderLineItemWrapper(String description,String priority,Decimal quantity,Decimal discount,Decimal total,String currencyIsoCode){
            this.description = description;
            this.priority = priority;
            this.quantity = quantity;
            this.unitPrice = total/quantity;
            this.discount = discount;
            this.currencyIsoCode = currencyIsoCode;
            this.total = total;
        }
    }
}