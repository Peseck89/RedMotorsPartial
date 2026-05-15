public class CaseChecklistController_v2 {	
    public String caseId {get;set;}	
    public Case cs {get;set;}	
    public DateTime apertura {get;set;}	
    public String fechaEntrada {get;set;}	
    public String fechaPrevistaEntrega {get;set;}	
    public String fechaVehiculo {get;set;}	
    public List<Subtipo_de_trabajo_del_caso__c> subtipos {get;set;}	
    public List<WorkOrder> ordenesTrabajo {get;set;}	
    public decimal kilometros {get;set;}	
    public String workOrderNumber {get;set;}	
    public String assetDinam {get;set;}	
    public List<WorkOrder> Ubi {get; set;}
    public List<tiposDeTrabajoCaso__c> trabajosarealizar {get; set;}
    public String imageUrl{get; set;}
    public String imageUrl1{get; set;}
    public String imageUrl2{get; set;}
    public String imageUrl3{get; set;}
    public String imageUrl4{get; set;}
    public Cambio_de_Propietario__c cambioPropietario {get; set;}
    
    	
    public CaseChecklistController_v2(ApexPages.StandardController controller) {	
        caseId = controller.getId();	
        String currentId = ApexPages.currentPage().getParameters().get('id');
        //caseId = ApexPages.currentPage().getParameters().get('id');	
        System.debug('controller.getId()');	
        System.debug('RECORD ID IN CaseChecklistController ----- ' + caseId);	
        	
        cs = [SELECT Id, CaseNumber,RecordType.Name, Asset.marca__c,AssetId, Asset.numeroDePlaca__c, Asset.NumeroDeChasis__c, Asset.Kilometros__c,	
              OwnerId, Asset.Combustible__c, Asset.modelo__c,Asset.motor__c, Asset.Color__c, 	
              Account.Name, Account.BillingStreet, Account.Tipo_de_Documento__c,  Account.Phone, Account.Cedula__c, Contact.Email, Contact.MobilePhone,	
              Contact.Name, Contact.Phone, Fecha_Hora_de_apertura__c, FechaEntrada__c,CreatedDate, 	
             (
                SELECT Id, Name, Tipo_de_cargo__c, FechaAlta__c, Status__c, Taller__c,Horaa__c, ComentarioTTC__c,Tipotrabajo__r.Name,Tipotrabajo__c,Ordenamiento__c
                FROM Tipos_de_Trabajo__r 
                WHERE RM_TipoTrabajoCaso__c = null
                ORDER BY Ordenamiento__c ASC
              )
              FROM Case	
              WHERE Id =: caseId	
              LIMIT 1];	
        
         trabajosarealizar = [SELECT Id, Name, Tipo_de_cargo__c, FechaAlta__c, Status__c, Taller__c,Horaa__c, ComentarioTTC__c,Tipotrabajo__r.Name,
              Tipotrabajo__c,Ordenamiento__c
              FROM tiposDeTrabajoCaso__c 
              WHERE caso__c =: caseId AND RM_TipoTrabajoCaso__c = null 
              ORDER BY Ordenamiento__c ASC];
        
        List<Cambio_de_Propietario__c> cambios = CaseChecklistBase.getCambioPropietarioPendiente(caseId, cs.AssetId);
            if (!cambios.isEmpty()) {
               cambioPropietario = cambios[0];
             }
        
        List<ContentDocumentLink> ListOfCDL = [SELECT ContentDocumentId FROM ContentDocumentLink
                                                                        WHERE LinkedEntityId IN (SELECT Id FROM Case WHERE Id =: currentId)];
        Set<Id> imagesIds = new Set<Id>();
        for(ContentDocumentLink ImaId : ListOfCDL){
         imagesIds.add(ImaId.ContentDocumentId);
          }
        
        ContentVersion[] cvs  = [SELECT Id,title FROM  ContentVersion  WHERE ContentDocumentId in: imagesIds ];
        System.debug('cvs'+cvs);
        
        for(ContentVersion CVI: cvs ){
            IF(CVI.title == 'Carrocería#1'){
            imageUrl = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + CVI.Id;
            }
            IF(CVI.title == 'Carrocería#2'){
            imageUrl1 = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + CVI.Id;
            }
            IF(CVI.title == 'Carrocería#3'){
            imageUrl2 = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + CVI.Id;
            }
            IF(CVI.title == 'Carrocería#4'){
            imageUrl3 = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + CVI.Id;
            }
            IF(CVI.title == 'Carrocería#5'){
            imageUrl4 = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + CVI.Id;
            }
        }
        
        
        
        
        System.debug('Cs ********** ' + cs);	
        List<WorkOrder> OT = new List<WorkOrder>();	
        try {	
            OT = [SELECT Id, AssetId,Kilometros__c,Fecha_de_Entrada__c,Fecha_prevista_de_entrega__c,Asset.Anio__c FROM WorkOrder WHERE AssetId =: cs.AssetId AND CaseId =:caseId ORDER BY CreatedDate DESC limit 1];	
        } catch(DmlException e) {	
            	
        }	
        System.debug('OT ************ :' + OT);	
            	
        kilometros = CaseChecklistBase.calcularKilometros(OT, cs.Asset.Kilometros__c);
        List<tiposDeTrabajoCaso__c> listTipos = [SELECT Id FROM tiposDeTrabajoCaso__c WHERE Caso__c =:caseId AND RM_TipoTrabajoCaso__c = null ORDER BY Ordenamiento__c ASC];	
        List<WorkOrder> ordenesTrabajo = [SELECT Id,Fecha_de_Apertura__c,Fecha_de_Entrada__c, Fecha_prevista_de_entrega__c,Asset.Anio__c, WorkOrderNumber FROM WorkOrder WHERE CaseId =:caseId];	
        System.debug('listTipos ******************** :' + listTipos);	
        System.debug('ordenesTrabajo ********************** : ' + ordenesTrabajo);	
        if(ordenesTrabajo.size()>0){	
            apertura = ordenesTrabajo[0].Fecha_de_Apertura__c;	
            workOrderNumber = ordenesTrabajo[0].WorkOrderNumber;	
            fechaEntrada = ordenesTrabajo[0].Fecha_de_Entrada__c != null ? ordenesTrabajo[0].Fecha_de_Entrada__c.format() : '';	
            fechaPrevistaEntrega = ordenesTrabajo[0].Fecha_prevista_de_entrega__c != null ? ordenesTrabajo[0].Fecha_prevista_de_entrega__c.format() : '';	
            fechaVehiculo = ordenesTrabajo[0].Asset != null ? ordenesTrabajo[0].Asset.Anio__c: '';	
        }else{	
            apertura = cs.CreatedDate;	
        }	
        if(listTipos.size()>0){	
            subtipos = [SELECT Id, Name, Cantidad_de_horas__c, Tipo_de_trabajo_del_caso__r.Name FROM Subtipo_de_trabajo_del_caso__c WHERE Tipo_de_trabajo_del_caso__c IN: listTipos AND RM_SubtipoTrabajoCaso__c = NULL];	
        }      	
        	
       Ubi = CaseChecklistBase.getUbicacionPorCaso(caseId);
       System.debug('Ubi *********************** : ' + Ubi);	
        	
    }	
    	
}