public with sharing class SampleLookupController {
    
    private final static Integer MAX_RESULTS = 5;
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchRecords(String searchTerm, List<String> selectedIds, String firedElement, String objName, String displayedObjName, String icon) {
        String searchKeyword = searchTerm + '*';
        String returningQuery;
        if (objName == 'tiposDeTrabajo__c') {
    		returningQuery = objName + '(Id, Name WHERE Inactivo__c = FALSE)';
		} else {
    		returningQuery = objName + '(Id, Name)';
		}
        String query = 'FIND :searchKeyword IN ALL FIELDS RETURNING '+returningQuery+' LIMIT 10';
        List<List<sObject>> searchResults = Search.query(Query);
       
        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        
        SObject[] genericObjectResults = (List<SObject>) searchResults[0];
        
       for (SObject genericResult : genericObjectResults) {
           String subtitle = genericResult.get('Name') == null ? objName : displayedObjName+' • ' + genericResult.get('Name'); String resultName = (String) genericResult.get('Name'); results.add(new LookupSearchResult(genericResult.Id, objName, icon, resultName, subtitle));
        }
        results.sort();

        return results;
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchCases(String searchTerm, List<String> selectedIds, String firedElement, String objName, String displayedObjName, String icon) {
        String searchKeyword = searchTerm + '*';
        String returningQuery = objName +' ( Id, CaseNumber)';
        
        String query = 'FIND :searchKeyword IN ALL FIELDS RETURNING '+returningQuery+' LIMIT 7';
        List<List<sObject>> searchResults = Search.query(query);
       
        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        
        SObject[] genericObjectResults = (List<SObject>) searchResults[0];
        
       for (SObject genericResult : genericObjectResults) { String subtitle = genericResult.get('CaseNumber') == null ? objName : displayedObjName+' • ' + genericResult.get('CaseNumber'); String resultName = (String) genericResult.get('CaseNumber'); results.add(new LookupSearchResult(genericResult.Id, objName, icon, resultName, subtitle));
        }
        results.sort();

        return results;
    }    
@AuraEnabled(Cacheable=true)
public static List<LookupSearchResult> searchUsersFilterByMecanico(String searchTerm, List<String> selectedIds, String firedElement, String objName, String displayedObjName, String icon) {
    List<LookupSearchResult> results = new List<LookupSearchResult>(); searchTerm = '%' + searchTerm + '%'; Set<Id> territoryIds = getMyTerritories();
    
    String query = 'SELECT RM_Mecanico__r.Id, RM_Mecanico__r.Name ' +
                   'FROM RM_MecanicoTaller__c ' +
                   'WHERE RM_Mecanico__r.RecordType.Name LIKE \'%Contacto de Taller%\' AND RM_Taller__c IN :territoryIds ' +
                   'AND RM_Mecanico__r.Activo__c = TRUE ' +
                   'AND RM_Mecanico__r.Name LIKE :searchTerm ' +
                   'GROUP BY RM_Mecanico__r.Id, RM_Mecanico__r.Name ' +   
                   'ORDER BY RM_Mecanico__r.Name ASC LIMIT 10';   

    List<AggregateResult> queryResults = (List<AggregateResult>) Database.query(query);
    for (AggregateResult ar : queryResults) { Id mechanicId = (String) ar.get('Id'); String mechanicName = (String) ar.get('Name'); String subtitle = 'Mecanico'; results.add(new LookupSearchResult(mechanicId, objName, icon, mechanicName, subtitle));
    }
    
    return results;
}

    private static Set<Id> getMyTerritories() {
        List<FSL__User_Territory__c> userTerritories = [SELECT FSL__ServiceTerritory__c FROM FSL__User_Territory__c WHERE FSL__User__c = :UserInfo.getUserId()];
        Set<Id> territoryIds = new Set<Id>(); for (FSL__User_Territory__c userTerritory : userTerritories) { territoryIds.add(userTerritory.FSL__ServiceTerritory__c);
        }
        return territoryIds;
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchMechanics(String searchTerm, List<String> selectedIds, String firedElement, String objName, String displayedObjName, String icon) {
        return searchUsersFilterByMecanico(searchTerm, selectedIds, firedElement, objName, displayedObjName, icon);
    }
	
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchProductFilterByManoDeObra(String searchTerm, List<String> selectedIds, String firedElement, String objName, String displayedObjName, String icon) {
        List<LookupSearchResult> results = new List<LookupSearchResult>();        
		String query = 'SELECT Id, Name FROM Product2 WHERE tipoProducto__c = \'Mano de Obra\' AND Codigo_de_Producto__c LIKE \'MO%\' AND Name LIKE \'%' + searchTerm.trim() + '%\' AND isActive = TRUE LIMIT 10';
        for (Product2 prod : (List<Product2>) Database.query(query)) {
           String subtitle = 'Mano de Obra';
           String resultName = prod.Name;
           results.add(new LookupSearchResult(prod.Id, objName, icon, resultName, subtitle));
        }
        results.sort();
        return results;
    }  
    
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds, String firedElement, String caseId) {
        String objName ='';
        String displayedObjName='';
        String icon ='';
        
        if(firedElement.contains('Aseguradora')){
            objName = 'Account';
            displayedObjName ='Aseguradora';
            icon = 'standard:account';
        }
        
        if(firedElement.contains('TipoDeTrabajo')){
            objName = 'tiposDeTrabajo__c';
            displayedObjName ='Tipos de Trabajo';
            icon = 'standard:work_type';
        }
        
        if(firedElement.contains('CentroCosto')){
            objName = 'CentroCosto__c';
            displayedObjName ='Centro de Costo';
            icon = 'standard:store_group';
        }

        if(firedElement.contains('Mecanico')){ objName = 'User'; displayedObjName ='Mecanico'; icon = 'standard:user';
            return searchUsersFilterByMecanico(searchTerm, selectedIds, firedElement, objName, displayedObjName, icon);
        }  
        if(firedElement.contains('ManoDeObra')){ objName = 'Product2'; displayedObjName ='Mano de Obra'; icon = 'standard:product';
            return searchProductFilterByManoDeObra(searchTerm, selectedIds, firedElement, objName, displayedObjName, icon);
        }
        if(firedElement.contains('Territorio')){ objName = 'User';  displayedObjName ='Mecanico'; icon = 'standard:store_group';
            return getTerritories(searchTerm, selectedIds, firedElement, objName, displayedObjName, icon);
        }              
        
        return searchRecords(searchTerm, selectedIds, firedElement, objName, displayedObjName, icon);
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> getTerritories(String searchTerm, List<String> selectedIds, String firedElement, String objName, String displayedObjName, String icon) {
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        Set<Id> territoryIds = new Set<Id>(); 
        for (FSL__User_Territory__c ut : [SELECT Id,FSL__ServiceTerritory__c FROM FSL__User_Territory__c WHERE FSL__User__c =: UserInfo.getUserId()]) {
            territoryIds.add(ut.FSL__ServiceTerritory__c); 
        }        

        String query = 'SELECT Id,Name FROM ServiceTerritory WHERE Id IN :territoryIds AND Name LIKE \'%'+searchTerm.trim()+'%\' LIMIT 20';      
        for (ServiceTerritory territory : (List<ServiceTerritory>) Database.query(query)) {
           String subtitle = 'Territorio';  String resultName = territory.Name; results.add(new LookupSearchResult(territory.Id, objName, icon, resultName, subtitle));
        }
        results.sort();
        return results;
    }        

    @AuraEnabled(Cacheable=true)
    public static Id searchWorkOrderId(Id caseIdentificator) {
        Id workOrderId = [Select Id from WorkOrder where CaseId=:caseIdentificator order by CreatedDate desc limit 1].Id;
        return workOrderId;
    }
}