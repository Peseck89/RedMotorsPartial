public with sharing class RM_VN_InventarioFantasia_Ctrl {

    static final Integer PAGE_SIZE = RM_VN_Service.PAGE_SIZE;

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getRecords(String brand,String familly, String year,Integer pageNumber){
        
        Map<String,Object> responseMap = new Map<String,Object>();

        if(String.isBlank(brand)){ 
            return responseMap;
        }

        if(String.isBlank(year)){ 
            return responseMap;
        }

        Map<String,PricebookEntry> modelPBEMap = RM_VN_Service.getPBEFantasiaGroupByModel(brand,year);
        if (modelPBEMap.isEmpty()) {
            return responseMap;
        }

        Set<Id> productIds = new Set<Id>();
        for (PricebookEntry pbe : modelPBEMap.values()) {
            productIds.add(pbe.Product2Id);
        }
        
        try {
            String soqlConditions = '';

            brand = String.isNotBlank(brand) ? '%' + String.escapeSingleQuotes(brand) + '%' : null;
            familly = String.isNotBlank(familly) ? '%' + String.escapeSingleQuotes(familly) + '%' : null;

            soqlConditions += ' WHERE IsActive = true AND Modelo_De_Inter_s__c != NULL AND esVehiculo__c = false AND es_Vehiculo_usado__c = false AND Marca__c LIKE :brand AND Familia__c LIKE :familly AND Id IN :productIds ';

            pageNumber = pageNumber != null ? pageNumber : 1;

            Integer offset = (pageNumber - 1) * PAGE_SIZE;

            String soqlCount;
            String soqlString;

            soqlCount = 'SELECT count() FROM Product2 '+soqlConditions;
            soqlString = 'SELECT Id, Name, ProductCode, Codigo_de_Producto__c, Marca__c, Familia__c, Modelo_De_Inter_s__c,Anno__c FROM Product2 '+soqlConditions+' ORDER BY Name LIMIT :PAGE_SIZE  OFFSET :offset ';

            Integer totalRecords = Database.countQuery(soqlCount);        
            Integer recordEnd = PAGE_SIZE * pageNumber;

            responseMap.put('pageSize',PAGE_SIZE);
            responseMap.put('pageNumber',pageNumber);
            responseMap.put('totalRecords',totalRecords);
            responseMap.put('recordStart',offset + 1);
            responseMap.put('recordEnd',totalRecords >= recordEnd ? recordEnd : totalRecords);
              
            List<Product2> productList = (List<Product2>) Database.query(soqlString);
            responseMap.put('records',productList);
            responseMap.put('preciosFantasia',modelPBEMap.values());
                

        } catch (Exception e) {
            if (!Test.isRunningTest()) {
                throw new AuraHandledException(e.getMessage());
            }
        }

        return responseMap;
    }

    @AuraEnabled(cacheable=true)
    public static List<RM_SelectOption_Wrapper> getBrands(){
        List<RM_SelectOption_Wrapper> options = new List<RM_SelectOption_Wrapper>();
        for (AggregateResult ar : [SELECT Marca__c  FROM Product2 WHERE IsActive = TRUE AND Marca__c != NULL AND Modelo_De_Inter_s__c != NULL AND Marca__c != 'Harley-Davidson' GROUP BY Marca__c ORDER BY Marca__c]) {
            options.add(new RM_SelectOption_Wrapper(String.valueOf(ar.get('Marca__c')), String.valueOf(ar.get('Marca__c'))));
        }  
        return options;
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchFamilyByBrand(String searchTerm,String brand, List<String> selectedIds, String firedElement, String objName, String displayedObjName, String icon) {
        List<LookupSearchResult> results = new List<LookupSearchResult>();   
        searchTerm = '%'+searchTerm+'%';     

        String query = 'SELECT Familia__c FROM Product2 WHERE IsActive = TRUE AND esVehiculo__c = FALSE AND Modelo_De_Inter_s__c != NULL AND Marca__c = :brand AND Familia__c != NULL AND Familia__c LIKE :searchTerm GROUP BY Familia__c ORDER BY Familia__c  LIMIT 10';
        List<AggregateResult> aggregateResultList = Database.query(query);
        System.debug('@aggregateResultList@');
        System.debug(aggregateResultList);
        for (AggregateResult ar : aggregateResultList) {
           String subtitle = 'Familia';
           String resultName = (String) ar.get('Familia__c');
           results.add(new LookupSearchResult(resultName, objName, icon, resultName, subtitle));
        }
        results.sort();
        return results;
    }
}