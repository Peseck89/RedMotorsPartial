public with sharing class WorkorderHistory_v3 {
    public String assetId;
    public Integer storedVariable {get;set;}

    public Workorder generalData {get;set;}
    public List<Workorder> worder {get;set;}
    public Datetime firstOrder {get;set;}
    public Datetime lastOrder {get;set;}
    public Case caseAsset {get;set;}
    public List<tiposDeTrabajoCaso__c> Trabajos {get;set;}

    
    // Aggregate Summary
    Public Decimal mo {get;set;}
    Public Decimal mat {get;set;}
    Public Decimal sub {get;set;}
    Public Decimal var {get;set;}
    Public Decimal matPint {get;set;}
    Public Decimal total {get;set;}
    
    public WorkorderHistory_v3(ApexPages.StandardController controller) {
        Integer listSize;
        storedVariable = 0;
        mo = 0;
        mat =0;
        sub =0;
        var =0;
        matPint =0;
        total =0;
        
        assetId =ApexPages.currentPage().getParameters().get('id');
        
        worder = [Select Id, CreatedDate, Asset.Account.Name, Asset.modelo__c, WorkOrderNumber, Motor__c, Discount, ServiceTerritory.Name,tipoDeGasto__c, Fecha_de_Entrada__c, Fecha_prevista_de_entrega__c,
                  TotalPrice,totalFinal__c,  Fecha_de_facturacion__c, totalDescuentos__c, montoPintura__c, montoVarios__c, montoSubcontrato__c, montoMateriales__c, montoManoDeObra__c, Tipo_de_servicio__c,IVA__c, IVA2__c,
                  Asset.NumeroDeChasis__c, Asset.Marca__c, Asset.numeroDePlaca__c, OwnerId, Kilometros2__c, Kilometros__c , VIN__c, Asset.Motor__c,Owner.Name, Matricula__c, CaseId,RootWorkOrderId,
                  (Select Cantidad__c, Id, Description, LineItemNumber, Duration,  Discount,ImpuestoReal__c, ListPrice, PricebookEntryId, PricebookEntry.productCode__c, Quantity, Product2.tipoProducto__c, grupo__c, tiposDeTrabajo__c, tiposDeTrabajo__r.Name,
                  Subtotal, TotalPrice, UnitPrice, aprobado__c, Product2.tipoDeTrabajo__c, Product2.Name, Alias_Articulo__c, Producto_OR_Alias__c,
                              tipoDeTrabajo__c, porcentajeDescuento__c,  especificacionesTaller__c,Total__c, Trabajo__c from WorkOrderLineItems) from WorkOrder WHERE AssetId =: AssetId];
      
        Set<Id> IdsCase = new Set<Id>();
                for(WorkOrder wo1 : worder){
                    IdsCase.add(wo1.caseId);
                                            }
              
        Trabajos = [Select Id, Tipo_de_cargo__c, Tipotrabajo__r.Name, caso__c, Name, BMW_TotalDeHoras__c,ComentarioTTC__c from tiposDeTrabajoCaso__c WHERE Caso__c in: IdsCase];
                              
        generalData = worder[0];
        listSize= worder.size()-1;
        
        firstOrder = (Datetime)worder[0].CreatedDate;
    lastOrder = (Datetime) worder[listSize].CreatedDate;
        
        for (WorkOrder wo: worder){ // Iterando WorkOrder
            mo     += wo.montoManoDeObra__c;
            mat   += wo.montoMateriales__c;
            sub   += wo.montoSubcontrato__c;
            var   += wo.montoVarios__c;
            matPint += wo.montoPintura__c;
            total   += wo.totalFinal__c;
        }   
    }
}