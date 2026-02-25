public with sharing class RM_VU_Inventario_Ctrl {

    static Integer PAGE_SIZE = RM_VU_Service.PAGE_SIZE;

    private static String getTipoVehiculo(String recordTypeDevName){
        String tipoVehiculo = '';
        if (recordTypeDevName.equalsIgnoreCase('Autos_Usados')) {
            tipoVehiculo = ' AND Producto__r.Tipo_vehiculo__c IN (\'A\',\'Automóvil\') ';
        } else if (recordTypeDevName.equalsIgnoreCase('Motos_Usados')) {
            tipoVehiculo = ' AND Producto__r.Tipo_vehiculo__c IN (\'M\',\'Motocicleta\') ';
        }
        return tipoVehiculo;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getRecords(String tipoVehiculo,String brand, String year,String  model,String productCode, String placa ,String  internalColor,String  externalColor ,String  tipoCombustible, Integer pageNumber, Boolean skipPagination, String priceBook){                
        Map<String,Object> responseMap = new Map<String,Object>();
        String priceBookId;        
        String currencyCode;

        if(skipPagination != null && skipPagination){
            PAGE_SIZE = 50000;
        }
        
        if(String.isBlank(priceBook)){
            throw new AuraHandledException('La lista de precios es requerida.');
        }

        List<Pricebook2> pbList =[SELECT Id FROM Pricebook2 WHERE Name = :priceBook AND IsActive = TRUE LIMIT 1];
        if (pbList.isEmpty()) {
            throw new AuraHandledException('La lista de precios no existe.');
        }    
        priceBookId = pbList[0].Id;

        RM_Config__mdt cfgMdtDPLVUCC = RM_Config__mdt.getInstance('Default_Price_List_VU_Currency_Code');
        if (String.isBlank(cfgMdtDPLVUCC.Value__c)) {
            throw new AuraHandledException('Se requiere el código de la moneda en el metadato de configuracion.');
        }
        currencyCode = cfgMdtDPLVUCC.Value__c;

        List<PricebookEntry> pbeList = RM_VU_Service.gePBEBavarian(priceBookId,currencyCode,brand,year,model, placa);

        if (pbeList.isEmpty()) {
            return responseMap;
        }

        Set<Id> prodIdsWithPrice = new Set<Id>();
        for (PricebookEntry pbe : pbeList) {
            prodIdsWithPrice.add(pbe.Product2Id);
        }

        try {
            String soqlConditions = '';

            soqlConditions += ' WHERE Producto__c IN :prodIdsWithPrice AND Producto__r.IsActive = TRUE AND Producto__r.es_Vehiculo_usado__c = true AND Producto__r.Producto_Reservado__c = false AND Disponible__c > 0 AND Bodega__c != null AND (Producto__r.OportunidadReserva__c = null OR Producto__r.OportunidadReserva__r.Owner.Id = \''+UserInfo.getUserId()+'\' ) '; 

            if(String.isNotBlank(tipoVehiculo)){
                soqlConditions += getTipoVehiculo(tipoVehiculo);
            }

            if(String.isNotBlank(brand)){
                brand = '%'+String.escapeSingleQuotes(brand.trim())+'%';
                soqlConditions += ' AND Producto__r.marcaVehiculo__c  LIKE :brand';
            }

            if(String.isNotBlank(year)){
                year = String.escapeSingleQuotes(year.trim());
                soqlConditions += ' AND Producto__r.Anno__c = :year';
            }

            if(String.isNotBlank(model)){
                model = '%'+String.escapeSingleQuotes(model.trim())+'%';
                soqlConditions += ' AND (Producto__r.modelo__c LIKE :model OR Producto__r.Name LIKE :model)';
            }            

            if(String.isNotBlank(productCode)){                
                soqlConditions += ' AND ( Producto__r.ProductCode LIKE \'%'+ productCode.trim() +'%\')';
            }

            if(String.isNotBlank(tipoCombustible) && !tipoCombustible.equalsIgnoreCase('all')){
                soqlConditions += ' AND Producto__r.combustible__c = :tipoCombustible ';
            }            

            if(String.isNotBlank(internalColor)){
                internalColor = '%'+String.escapeSingleQuotes(internalColor.trim())+'%';
                soqlConditions += ' AND Producto__r.Color__c  LIKE :internalColor ';
            }

            if(String.isNotBlank(externalColor)){
                externalColor = '%'+String.escapeSingleQuotes(externalColor.trim())+'%';
                soqlConditions += ' AND Producto__r.Color_Externo__c  LIKE :externalColor ';
            }   

            if(String.isNotBlank(placa)){
                placa = '%'+String.escapeSingleQuotes(placa.trim())+'%';
                soqlConditions += ' AND ( Producto__r.vin__c LIKE :placa OR Producto__r.Codigo_de_Producto__c LIKE :placa )';
            }

            pageNumber = pageNumber != null ? pageNumber : 1;

            Integer offset = (pageNumber - 1) * PAGE_SIZE;

            String soqlCount;
            String soqlString;

            soqlCount = 'SELECT count() FROM ProductoXBodega__c '+soqlConditions;
            soqlString = 'SELECT Id, Producto__c, Producto__r.combustible__c, Producto__r.Id,Producto__r.ProductCode, Producto__r.Codigo_de_Producto__c,Producto__r.Anno__c, Producto__r.VN_Familia__c,Producto__r.Name, Producto__r.modelo__c, Producto__r.marcaVehiculo__c,Producto__r.Color__c, Producto__r.vin__c,Producto__r.Color_Externo__c'+
            ' ,Disponible__c, Name,Bodega__r.Name FROM ProductoXBodega__c '+soqlConditions+' ORDER BY Producto__r.Name LIMIT :PAGE_SIZE  OFFSET :offset ';

            Integer totalRecords = Database.countQuery(soqlCount);        
            Integer recordEnd = PAGE_SIZE * pageNumber;

            responseMap.put('pageSize',PAGE_SIZE);
            responseMap.put('pageNumber',pageNumber);
            responseMap.put('totalRecords',totalRecords);
            responseMap.put('recordStart',offset + 1);
            responseMap.put('recordEnd',totalRecords >= recordEnd ? recordEnd : totalRecords);
              
            List<ProductoXBodega__c> prodXBodList = (List<ProductoXBodega__c>) Database.query(soqlString);
            responseMap.put('prodXBodItems',prodXBodList);
            responseMap.put('priceBookEntries',pbeList);

        } catch (Exception e) {
            System.debug('@debug@'+e.getMessage());
            if (!Test.isRunningTest()) {
                throw new AuraHandledException(e.getMessage());
            }
        }

        return responseMap;
    }

    @AuraEnabled(cacheable=true)
    public static List<RM_SelectOption_Wrapper> getTipoGasolina()
    {
       List<RM_SelectOption_Wrapper> options = new List<RM_SelectOption_Wrapper>();
       options.add(new RM_SelectOption_Wrapper('Todos', 'All'));
       Schema.DescribeFieldResult fieldResult = Product2.combustible__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry f : ple)
       {
            if (f.isActive()) {                
                options.add(new RM_SelectOption_Wrapper(f.getLabel(), f.getValue()));
            }
       }     
       return options;
    }

    @AuraEnabled(cacheable=true)
    public static Opportunity getOpportunity(String oppId){
        try {
            return [SELECT Id,Pricebook2Id,Pricebook2.Name,CurrencyIsoCode FROM Opportunity WHERE Id = :oppId LIMIT 1];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Pricebook2> getPriceBooks(){
        try {
            RM_Config__mdt cfgMdtDPLVU = RM_Config__mdt.getInstance('Default_Price_List_VU');          
            return [SELECT Id,Name FROM Pricebook2 WHERE IsActive = TRUE AND Name = :cfgMdtDPLVU.Value__c WITH SECURITY_ENFORCED ORDER BY Name ASC];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getUsadoRecordTypeOptions() {
        List<Map<String, String>> options = new List<Map<String, String>>();
        Map<String, Schema.RecordTypeInfo> recordTypeInfos = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        for (String recordTypeName : recordTypeInfos.keySet()) {
            Schema.RecordTypeInfo recordTypeInfo = recordTypeInfos.get(recordTypeName);
            if (recordTypeInfo.getName().contains('usado') && recordTypeInfo.isAvailable() && recordTypeInfo.isActive()) {
                options.add(new Map<String, String>{
                    'label' => recordTypeInfo.getName().toUpperCase(),
                    'value' => recordTypeInfo.getDeveloperName()
                });
            }
        }
        return options;
    }

    
}