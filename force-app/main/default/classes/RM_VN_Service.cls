public with sharing class RM_VN_Service {

    public static final String PRICEBOOK_NAME;//= getDefaultPriceListVN();

    public static final Integer PAGE_SIZE = 15;

    public static String getDefaultPriceListVN() {
        return RM_Config__mdt.getInstance('Default_Price_List_VN')?.Value__c;
    }  

    /**
    * @description Consulta los precios de la lista de precios de fantasia
    * @author marcohernandezhp@gmail.com | 06-18-2023 
    * @param brand Indica la marca y debe corresponder con el nombre de la lista de precios
    * @param year Indica el año del vehiculo y debe corresponder con el nombre de la lista de precios
    * @return Map<String, PricebookEntry> Precios de fantasia agrupados por modelo
    **/
    public static Map<String,PricebookEntry> getPBEFantasiaGroupByModel(String brand,String year) {
        Map<String,PricebookEntry> pricesByModelMap = new Map<String,PricebookEntry>();
        brand = '%'+brand+'%';
        year = '%'+year+'%';
        try {
            for (PricebookEntry pbe : [
                                        SELECT Id, Name, UnitPrice, Costo_Fijo__c,Vendedor__c, Jefe__c, Gerente__c,Product2Id,Product2.Name,Product2.Marca__c,Product2.Modelo_De_Inter_s__c,Pricebook2.Name,IsActive,Pricebook2.IsActive,CurrencyIsoCode,Pricebook2.CurrencyIsoCode,Product2.IsActive,Product2.esVehiculo__c
                                        FROM PricebookEntry 
                                        WHERE IsActive = TRUE AND Pricebook2.IsActive = TRUE AND Pricebook2.CurrencyIsoCode = 'USD' AND CurrencyIsoCode = 'USD' AND Pricebook2.Name LIKE :brand AND Pricebook2.Name LIKE :year AND Product2.IsActive = TRUE AND Product2.Marca__c != NULL AND Product2.Modelo_De_Inter_s__c != NULL  AND Product2.esVehiculo__c = false AND Product2.es_Vehiculo_usado__c = false AND Product2.es_Vehiculo_en_transito__c = false
                                      ]) {
            String modelKey = pbe.Product2.Modelo_De_Inter_s__c;
            Decimal price = 0;
            if (pricesByModelMap.containsKey(modelKey)) {
                price = pricesByModelMap.get(modelKey).UnitPrice;
                if (pbe.UnitPrice > price) {
                    pricesByModelMap.put(modelKey,pbe);
                }
            }else {
                pricesByModelMap.put(modelKey,pbe);                
            }
        }
        } catch(Exception e) {
            return pricesByModelMap;
        }
        return pricesByModelMap;
    }

    public static List<PricebookEntry> getSoftlandPBE(String brand,String year, String modelOrName) {
        return gePBEBavarian(brand,year,modelOrName);
    }

    public static List<PricebookEntry> gePBEBavarian(String brand,String year, String modelOrName) {
        List<PricebookEntry> pbeList = new List<PricebookEntry>();

        if (String.isBlank(brand) || String.isBlank(year)) {
            return pbeList;
        }
        
        Id softlandPBId = getSoftlandPriceBookId(brand,year);

        if (softlandPBId == null) {
            return pbeList;
        }

        String soqlString = 'SELECT Id,(SELECT Product2Id, UnitPrice, Gerente__c, Jefe__c, Vendedor__c,Costo_Fijo__c, Name FROM PricebookEntries WHERE Pricebook2Id = :softlandPBId AND Pricebook2.IsActive = TRUE AND IsActive = TRUE ORDER BY UnitPrice DESC LIMIT 1) FROM Product2 WHERE IsActive = TRUE AND (esVehiculo__c = TRUE OR es_Vehiculo_en_transito__c = TRUE) AND marcaVehiculo__c = :brand AND Anno__c = :year ';
        if(String.isNotBlank(modelOrName)){
            soqlString += ' AND (modelo__c LIKE \'%'+modelOrName+'%\' OR Name LIKE \'%'+modelOrName+'%\')';
        }

        try {
            List<Product2> prodList = (List<Product2>) Database.query(soqlString);
            if (prodList != null){
                for (Product2 product : prodList) {
                    for (PricebookEntry pbe : product.PricebookEntries) {           
                        pbeList.add(pbe);
                    }
                }
            }

        } catch(Exception e) {
            System.debug(e.getMessage());
            return pbeList;
        }
        return pbeList;
    }

    public static Id getSoftlandPriceBookId(String brand, String year) {
        brand = '%'+brand+'%';
        year = '%'+year+'%';
        List<Configuracion_de_ventas__c> marcaListaPrecioList = [SELECT Id, RM_ListaPrecioSoftland__c FROM Configuracion_de_ventas__c  WHERE Marca__c LIKE :brand AND Listas_de_Precios_Vigente__c LIKE :year AND Listas_de_Precios_Vigente__c LIKE :brand AND RM_ListaPrecioSoftland__c != null AND RM_ListaPrecioSoftland__r.IsActive = true AND RM_ListaPrecioSoftland__r.CurrencyIsoCode  = 'USD'  LIMIT 1];
        if (marcaListaPrecioList.isEmpty()) {
            return null;
        }
        return marcaListaPrecioList[0].RM_ListaPrecioSoftland__c;
    }

    public static String addBrandFilter() {
        return addBrandFilter(true);
    }

    public static String addBrandFilter(Boolean esPxB) {
        //show records only according to the opportunity record type that the user has access to, the record type label should match with the Marca__c field  on Product2
        List<RecordType> oppVNRecordTypes = getOppVNRecordTypes();
        Set<String> oppRecordTypeLabels = new Set<String>();
        for (RecordType rt : oppVNRecordTypes) {
            oppRecordTypeLabels.add(rt.Name);
        }

        String soqlConditions = '';
        if (oppRecordTypeLabels.size() > 0) {
            soqlConditions += ' AND (';
            String dynamicRecordType = '';
            for (String label : oppRecordTypeLabels) {
                if (dynamicRecordType != '') {
                    dynamicRecordType += ' OR ';
                }
                if(esPxB){
                    dynamicRecordType += ' Producto__r.';
                }
                dynamicRecordType += 'marcaVehiculo__c LIKE \'%'+ label +'%\'';
            } 
            soqlConditions += dynamicRecordType; 
            soqlConditions += ' )';
        }
        return soqlConditions;
    }


    public static List<RecordType> getOppVNRecordTypes() {
        Map<String, Schema.RecordTypeInfo> recordTypeInfos = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName();
        List<RecordType> recordTypes = new List<RecordType>();
        Set<String> excludedRecordTypes = new Set<String>{'Autos_Usados', 'Cartera_Madura', 'Motos_Usados', 'BMW_Taller', 'Harley_Davidson','Principal','Master'};

        for (String rtDevName : recordTypeInfos.keySet()) {
            //also exclude the main record type for the object
            if (!excludedRecordTypes.contains(rtDevName)) {
                Schema.RecordTypeInfo rtInfo = recordTypeInfos.get(rtDevName);
                if (rtInfo.isAvailable() && rtInfo.isActive()) {
                    RecordType rt = new RecordType();
                    rt.DeveloperName = rtDevName;
                    rt.Name = rtInfo.getName();
                    if (rtDevName == 'Kawasaki') {
                        rt.Name = 'Kawa';
                        rt.DeveloperName = 'Kawa';
                    }
                    recordTypes.add(rt);
                }
            }
        }
    
        return recordTypes;
    }
    
}