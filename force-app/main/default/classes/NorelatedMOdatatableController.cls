public with sharing class NorelatedMOdatatableController {
    
    public class mowrapper {
        @AuraEnabled public String ProductCode;
        @AuraEnabled public String ProductName;
        @AuraEnabled public decimal unitPrice;
        @AuraEnabled public String wolId;
        @AuraEnabled public String wrappId; 
        @AuraEnabled public String ProductXBodegaID;
        @AuraEnabled public String currencyCode;
        @AuraEnabled public string chargeType;
        @AuraEnabled public string alias;
        @AuraEnabled public string workTypeID;
        @AuraEnabled public string workTypeName;
        @AuraEnabled public decimal cantidadHoras;
        @AuraEnabled public double ut;
        @AuraEnabled public decimal discount;
        @AuraEnabled public String caseId;
        
        
        public mowrapper(String ProductCode,String ProductName,decimal unitPrice,string wolId,String wrappId,String ProductXBodegaID,String currencyCode,string chargeType,string alias,String caseId,decimal cantidadHoras,decimal discount){
            this.ProductCode = ProductCode;
            this.ProductName = ProductName;
            this.unitPrice = unitPrice;
            this.wolId = wolId;
           	this.wrappId = wrappId; 
            this.ProductXBodegaID = ProductXBodegaID;
            this.currencyCode = currencyCode;
            this.chargeType = chargeType;
            this.alias = alias != null? alias:this.ProductName;
            this.caseId = caseId;
            this.cantidadHoras = cantidadHoras;
            this.discount = discount/100;
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static List<mowrapper> getNoRelatedMOs(id workorder){
        List<mowrapper> lwcresoponse = new List<mowrapper> ();
        List<WorkOrderLineItem> MOwolis=[SELECT Id,Product__c,Product__r.Codigo_de_Producto__c,Product__r.Name,Product__r.costoLocal__c,Product__r.tipoProducto__c,
                                               Bodega__r.Name,Bodega__c,ProductoPorBodega__c,PricebookEntryId,PricebookEntry.UnitPrice,PricebookEntry.CurrencyIsoCode,
                                       		   Alias_Articulo__c,Quantity,porcentajeDescuento__c,UnitPrice,WorkOrder.tipoDeGasto__c,WorkOrder.CaseId
                                 			   FROM WorkOrderLineItem 
                                               WHERE WorkOrderId=:workorder and Trabajo__c ='Mano de Obra' and created_From__c != 'caseWorkTypes' and isRelatedToCase__c = false order by LineItemNumber desc];
        system.debug(MOwolis.size());
        for(WorkOrderLineItem wo:MOwolis){
            mowrapper wrapper = new mowrapper(wo.Product__r.Codigo_de_Producto__c,wo.Product__r.Name,wo.UnitPrice,wo.id,wo.id,wo.ProductoPorBodega__c,wo.PricebookEntry.CurrencyIsoCode,wo.WorkOrder.tipoDeGasto__c,wo.Alias_Articulo__c,wo.WorkOrder.CaseId,wo.Quantity,wo.porcentajeDescuento__c);
            lwcresoponse.add(wrapper);
        }
        
        return lwcresoponse;
        
    }
    
    @AuraEnabled(cacheable=false)
    public static string getWorkTypeName(id workType){
        return [select name from tiposDeTrabajo__c where id=:workType limit 1].name;
        
    }
    
    @AuraEnabled(cacheable=false)
    public static List<mowrapper> saveUnrelatedMOs(String JSONmowrapper,id workorder, String selectedCaseWorkTypeId){
        System.debug('JSON OBJECT');
        System.debug(JSONmowrapper);
        
        List<mowrapper> mowrappers=( List<mowrapper>)JSON.deserialize(JSONmowrapper,List<mowrapper>.class);
        
        Map <Id, tiposDeTrabajoCaso__c> workTypesMap = new Map <Id, tiposDeTrabajoCaso__c>();
        if(String.isBlank(selectedCaseWorkTypeId)){
            for(mowrapper mo:mowrappers){
                tiposDeTrabajoCaso__c wktype= new tiposDeTrabajoCaso__c( 
                                                  Caso__c= mo.caseId,
                                                  Tipo_de_cargo__c =mo.chargeType,
                                                  RM_WorkOrder__c = workorder,
                                                  //Taller__c = sugerenciaTaller, 
                                                  //ComentarioTTC__c = comments,
                                                  Tipotrabajo__c= mo.workTypeID);
                System.debug('mo.workTypeID');
                 System.debug(mo.workTypeID);
                if(!workTypesMap.containsKey(mo.workTypeID)){
                    System.debug('AGREGANDO');
                    workTypesMap.put(mo.workTypeID,wktype);
                }
                
            }
            insert workTypesMap.values();
        }
        saveSubWorks(workTypesMap , mowrappers,  workorder, selectedCaseWorkTypeId);
        updateRelatedWOLIS(mowrappers);
        System.debug(workTypesMap);
        return mowrappers;
    }
    
    private static void saveSubWorks(Map <Id, tiposDeTrabajoCaso__c> workTypesMap , List<mowrapper> mowrappers, Id workorder, String selectedCaseWorkTypeId){
        List <Subtipo_de_trabajo_del_caso__c> subWorkTypesList = new List <Subtipo_de_trabajo_del_caso__c>();
        for (mowrapper mo:mowrappers){
            Subtipo_de_trabajo_del_caso__c subWktype =new Subtipo_de_trabajo_del_caso__c
                										 (Articulo_Mano_de_Obra__c=mo.wolId,
                                                          Tipo_de_trabajo_del_caso__c= String.isNotBlank(selectedCaseWorkTypeId) ? selectedCaseWorkTypeId : workTypesMap.get(mo.workTypeID).Id,
                                                          Caso__c=mo.caseId, Orden_de_trabajo__c=workorder,
                                                          Name=mo.alias, Cantidad_de_horas__c=mo.cantidadHoras,
                                                          created_From__c='MOnoRelacionadaCaso');
            subWorkTypesList.add(subWktype);
      
        }
        insert subWorkTypesList;
    }
    
     private static void updateRelatedWOLIS(List<mowrapper> mowrappers){
        List <WorkOrderLineItem> wolis = new List <WorkOrderLineItem>();
        for (mowrapper wl:mowrappers){
            WorkOrderLineItem woli = new WorkOrderLineItem(Id=wl.wolId,isRelatedToCase__c=true);
            wolis.add(woli);
      
        }
        update wolis;
    }

    @AuraEnabled(cacheable=true)
    public static List<tiposDeTrabajoCaso__c> getCaseWorkTypesNotStarted(Id workOrderId){
        try {
            return [SELECT Id, Name, Caso__c, Tipotrabajo__c, Plan_de_trabajo__c,Paso_de_trabajo__r.Name,
                Paso_de_trabajo__c, RM_WorkOrder__c, Paso_de_trabajo__r.Status,
                RM_ModoTrabajo__c, RM_TipoTrabajoCaso__c
            FROM tiposDeTrabajoCaso__c
            WHERE RM_WorkOrder__c = :workOrderId AND Paso_de_trabajo__r.Status = 'Nueva' AND (RM_ModoTrabajo__c = '' OR RM_ModoTrabajo__c = 'Tarea hija')];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}