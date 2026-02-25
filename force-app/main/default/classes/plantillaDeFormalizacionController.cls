public without sharing class plantillaDeFormalizacionController {
    
    public Id idPlantilla{get;set;}
    public Plantilla_Formalizacion__c record {get;set;}
    public String plantilla{get;set;}
    public String par{get;set;}
    
    public plantillaDeFormalizacionController(){}
    
    public plantillaDeFormalizacionController(ApexPages.StandardController planilla){
        this.idPlantilla = planilla.getId();
        this.record = (Plantilla_Formalizacion__c)planilla.getRecord();  
        
        Plantilla_Formalizacion__c currentRecord = new Plantilla_Formalizacion__c();
        currentRecord = [select id, name, Plantilla__c from Plantilla_Formalizacion__c WHERE Id = :ApexPages.currentPage().getParameters().get('Id')];
        
        plantilla = currentRecord.Plantilla__c;
        
        System.debug(  currentRecord);
    }
    public void setpar(String n) {
        par =n;        
    }
  
    @RemoteAction
    public static Boolean updateFieldValue(Id recordId, String fieldName, Object fieldValue, String name)
    {
        String sObjectName = recordId.getSObjectType().getDescribe().getName();
        String queryString = 'Select Id, Nombre_de_Plantilla__c,' + String.escapeSingleQuotes(fieldName) + ' From ' + String.escapeSingleQuotes(sObjectName) + ' Where Id = \'' + String.escapeSingleQuotes(recordId) + '\'';
        Sobject record = Database.query(queryString);
        
        record.put(fieldName, fieldValue);
        record.put('Nombre_de_Plantilla__c', name);
        update record;
        
        return true;
        
    }
}