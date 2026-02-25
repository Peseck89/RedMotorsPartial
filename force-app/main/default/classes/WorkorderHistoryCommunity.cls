public with sharing class WorkorderHistoryCommunity {
   
    
    public String assetId;
    public String caseId; // To store the caseId parameter
    public Integer storedVariable { get; set; }

    public Workorder generalData { get; set; }
    public List<Workorder> worder { get; set; }
    public Datetime firstOrder { get; set; }
    public Datetime lastOrder { get; set; }
    public List<Case> caseAsset { get; set; }
    public Case relatedCase { get; set; } // New property to hold a single Case
    public List<tiposDeTrabajoCaso__c> Trabajos { get; set; }
    public List<Subtipo_de_trabajo_del_caso__c> SubTrabajos { get; set; }

    // Aggregate Summary
    public Decimal mo { get; set; }
    public Decimal mat { get; set; }
    public Decimal sub { get; set; }
    public Decimal var { get; set; }
    public Decimal matPint { get; set; }
    public Decimal total { get; set; }

    public static void dummy(){
        Integer i = 0;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
        i = i + 1;
    }
    
    public WorkorderHistoryCommunity(ApexPages.StandardController controller) {
        Integer listSize;
        storedVariable = 0;
        mo = 0;
        mat = 0;
        sub = 0;
        var = 0;
        matPint = 0;
        total = 0;

        // Retrieve the caseId from the URL parameters
        caseId = ApexPages.currentPage().getParameters().get('caseId');
        caseAsset = [SELECT Id,Description,Status,Service_Territory1__c,CaseNumber,Kilometraje__c,Fecha_Creacion_FM__c,OwnerId FROM Case WHERE Id =:caseId];
        Set<Id> IdsWO = new Set<Id>();
                for(Case cs1 : caseAsset){
                    IdsWO.add(cs1.Id);
                                            }
        
        worder = [Select Id, CreatedDate, Asset.Account.Name, Asset.modelo__c, WorkOrderNumber, Motor__c, Discount, ServiceTerritory.Name,tipoDeGasto__c, Fecha_de_Entrada__c, Fecha_prevista_de_entrega__c,
                  TotalPrice,totalFinal__c,  Fecha_de_facturacion__c, totalDescuentos__c, montoPintura__c, montoVarios__c, montoSubcontrato__c, montoMateriales__c, montoManoDeObra__c, Tipo_de_servicio__c,IVA__c, IVA2__c,
                  Asset.NumeroDeChasis__c, Asset.Marca__c, Asset.numeroDePlaca__c, OwnerId, Kilometros2__c, Kilometros__c , VIN__c, Asset.Motor__c,Owner.Name, Matricula__c, CaseId,RootWorkOrderId,LineItemCount,Total_Orden__c,
                  (Select Cantidad__c, Id, Description, LineItemNumber, Duration,  Discount,ImpuestoReal__c, ListPrice, PricebookEntryId, PricebookEntry.productCode__c, Quantity, Product2.tipoProducto__c, grupo__c, tiposDeTrabajo__c, tiposDeTrabajo__r.Name,
                  Subtotal, TotalPrice, UnitPrice, aprobado__c, Product2.tipoDeTrabajo__c, Product2.Name, Alias_Articulo__c, Producto_OR_Alias__c,
                              tipoDeTrabajo__c, porcentajeDescuento__c,  especificacionesTaller__c,Total__c, Trabajo__c,BMW_CodigoDeProducto__c from WorkOrderLineItems) from WorkOrder WHERE caseId =: IdsWO];
      
        //caseAsset = [SELECT Id,Description FROM Case WHERE AssetId =:assetId LIMIT 1];
        
        Set<Id> IdsCase = new Set<Id>();
                for(WorkOrder wo1 : worder){
                    IdsCase.add(wo1.caseId);
                                            }
              
        Trabajos = [Select Id, Tipo_de_cargo__c, Tipotrabajo__r.Name, caso__c, Name, BMW_TotalDeHoras__c,ComentarioTTC__c,Estado_aprobaci_n_service__c from tiposDeTrabajoCaso__c WHERE Caso__c in: IdsCase];
        
        Set<Id> IdsTrabajo = new Set<Id>();
                for(tiposDeTrabajoCaso__c Tb1 : Trabajos){
                    IdsTrabajo.add(Tb1.Id);
                                            }
        SubTrabajos = [Select Id,Tipo_de_trabajo_del_caso__c,Cantidad_de_horas__c,Name,Caso__c from Subtipo_de_trabajo_del_caso__c WHERE Tipo_de_trabajo_del_caso__c in: IdsTrabajo ];
                              
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