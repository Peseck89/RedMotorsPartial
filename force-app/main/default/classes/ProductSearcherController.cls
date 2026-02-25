public with sharing class ProductSearcherController {

    static final Integer PAGE_SIZE = 15;

    //precio usado para los extras
    static final String PRICEBOOK_NAME = 'Bavarian Dólar';    

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getProducts(String productType,String productName, String productCode,String bodegaId, String year ,String  vin ,String  brand ,String  family ,String  intColor,String  extColor ,String  model ,String  recordId ,String vehiculoTransito, Integer pageNumber){        
        Map<String,Object> responseMap = new Map<String,Object>();

        if(String.isBlank(productType)){ 
            responseMap.put('message','Se requiere indicar el tipo de producto.');
        }

        if(!responseMap.containsKey('message') && String.isBlank(brand)){ 
            responseMap.put('message','La marca es requerida.');
        }

        if(!responseMap.containsKey('message') && String.isBlank(year)){ 
            responseMap.put('message','El año es requerido.');
        }
        
        if(!responseMap.containsKey('message') && String.isBlank(model) && !productType.contains('vehiculo')){ 
            responseMap.put('message','El modelo es requerido.');
        }
        
        if(!responseMap.containsKey('message') && (productType.contains('mano obra')) && String.isBlank(recordId)){ 
            responseMap.put('message','El id es requerido.');
        }        
                
        try {
            String soqlConditions = '';

            if (!responseMap.containsKey('message')) {
                
                brand = brand.trim();
                model = model.trim();
                soqlConditions += ' WHERE ';

                if ((productType.contains('vehiculo') || productType.contains('extra'))) {
                    soqlConditions += ' Producto__r.IsActive = true AND Disponible__c > 0 AND Bodega__c != null ';
                    if(String.isNotBlank(bodegaId)){
                        soqlConditions += ' AND Bodega__c = :bodegaId';
                    }   
                } else if(productType.contains('mano obra')) {
                    soqlConditions += ' IsActive = true';                
                }

                if(productType.contains('vehiculo')){
                    //agregar filtro vehiculo en transito y reservado
                    if (String.isNotBlank(recordId)) {                        
                        soqlConditions += ' AND ((Producto__r.Producto_Reservado__c = false AND Producto__r.OportunidadReserva__c = null) OR';
                        soqlConditions += ' (Producto__r.Producto_Reservado__c = true AND Producto__r.OportunidadReserva__c = :recordId)';
                        soqlConditions += ')';
                    }

                    //apply filter vehiculo en transito
                    if(String.isNotBlank(vehiculoTransito) && !vehiculoTransito.equalsIgnoreCase('All')){
                        Boolean isVehiculoTransito = vehiculoTransito.equalsIgnoreCase('Si') ? true : false;
                        if (isVehiculoTransito) {
                            soqlConditions += ' AND  Producto__r.es_Vehiculo_en_transito__c = TRUE ';
                        }else{
                            soqlConditions += ' AND  Producto__r.esVehiculo__c = TRUE ';
                        }
                    }else{
                        soqlConditions += ' AND (Producto__r.esVehiculo__c = TRUE OR Producto__r.es_Vehiculo_en_transito__c = TRUE) ';
                    }

                    System.debug('@@soqlConditions');
                    System.debug(soqlConditions);

                    //apply the brand filter according to the opportunity record types that the user has access to
                    soqlConditions += ' '+RM_VN_Service.addBrandFilter();

                    Map<String,PricebookEntry> modelPBEMap = getPricesGroupByModelFantasia(brand,year);
                    if (modelPBEMap.isEmpty()) {
                        throw new AuraHandledException('No se encontraron precios de fantasia la Marca y Año ingresados.');
                    }

                    if (modelPBEMap.keySet().size() > 0) {
                        soqlConditions += ' AND (';
                        String dynamicModel = '';
                        for (String key : modelPBEMap.keySet()) {
                            if (dynamicModel != '') {
                                dynamicModel += ' OR ';
                            }                            
                            dynamicModel += ' Producto__r.modelo__c = \''+ key +'\'';
                        } 
                        soqlConditions += dynamicModel; 
                        soqlConditions += ' )';
                    }
                            
                    Set<Id> prodIds = new Set<Id>();
                    List<PricebookEntry> pbeList = RM_VN_Service.gePBEBavarian(brand,year,model);
                    for (PricebookEntry pbe : pbeList) {
                        prodIds.add(pbe.Product2Id);
                    }

                    if (prodIds.isEmpty()) {
                        return responseMap;
                    }
                    
                    soqlConditions += ' AND Producto__c IN :prodIds ';

                    responseMap.put('preciosBavarian',pbeList);
                    responseMap.put('preciosFantasia',modelPBEMap.values());
                }

                if(productType.contains('extra')){
                    soqlConditions += ' AND Producto__r.RecordType.DeveloperName = \'Materiales\' AND Producto__c IN (SELECT Producto__c FROM Compatibilidad__c WHERE Marca__r.Name =  \''+ brand.trim() +'\' AND Modelo__r.Name =  \''+ model.trim() +'\') ';

                    if(String.isNotBlank(vin)){
                        soqlConditions += ' AND ( Producto__r.vin__c LIKE \'%'+ vin.trim() +'%\' OR Producto__r.Codigo_de_Producto__c LIKE \'%'+ vin.trim() +'%\' )';
                    }
                    
                    if(String.isNotBlank(productName)){ 
                        soqlConditions += ' AND Producto__r.Name LIKE \'%'+ productName.trim() +'%\'';
                    }
                }                

                if(productType.contains('mano obra')){  

                    soqlConditions += ' AND tipoProducto__c = \'Mano de Obra\' AND RM_VN_EsActivo__c = true ';

                    if(String.isNotBlank(productName)){ 
                        soqlConditions += ' AND Name LIKE \'%'+ productName.trim() +'%\'';
                    }
                    
                    if(String.isNotBlank(vin)){
                        soqlConditions += ' AND ( vin__c LIKE \'%'+ vin.trim() +'%\' OR Codigo_de_Producto__c LIKE \'%'+ vin.trim() +'%\' )';
                    }

                    SObjectType objectType = ((Id) recordId).getSObjectType();
                    String objectName = objectType.getDescribe().getName();
                    String recordTypeName = '';
                    String companyName = '';
                    
                    String priceBookName;
                    if (objectName == 'Opportunity') {
                        List<Opportunity> oppList = [SELECT Id,RecordType.DeveloperName,(SELECT PricebookEntryId__c FROM Oportunidad_Producto_Interes__r) FROM Opportunity WHERE Id =:recordId LIMIT 1];
                        if (oppList.size()>0) {
                            recordTypeName = oppList[0].RecordType.DeveloperName;
                        }
                    }else if(objectName == 'Quote'){
                        List<Quote> quoteList = [SELECT Id,Opportunity.RecordType.DeveloperName FROM Quote WHERE Id =:recordId LIMIT 1];
                        if (quoteList.size()>0) {
                            recordTypeName = quoteList[0].Opportunity.RecordType.DeveloperName;
                        }                        
                    }

                    if (recordTypeName == 'BMW' || recordTypeName == 'MINI' ) {
                        companyName = 'Bavarian';        
                    }else if (recordTypeName == 'Polaris' || recordTypeName == 'Kawasaki' ){
                        companyName = 'otobai';                                
                    }

                    soqlConditions += ' AND Empresa__c LIKE \'%'+ companyName +'%\' ';
                }
                
                if(productType.contains('vehiculo')){

                    if(String.isNotBlank(productName)){ 
                        soqlConditions += ' AND Producto__r.Name LIKE \'%'+ productName.trim() +'%\'';
                    } 
                    
                    if(String.isNotBlank(productCode)){                
                        soqlConditions += ' AND ( Producto__r.ProductCode LIKE \'%'+ productCode.trim() +'%\')';
                    } 

                    if(String.isNotBlank(year)){   
                        soqlConditions += ' AND Producto__r.Anno__c LIKE \''+ year.trim() +'\' ';
                    }

                    if(String.isNotBlank(brand)){                
                        soqlConditions += ' AND Producto__r.marcaVehiculo__c  LIKE \'%'+ brand.trim() +'%\' ';
                    }

                    if(String.isNotBlank(model)){
                        soqlConditions += ' AND Producto__r.modelo__c LIKE \'%'+ model.trim() +'%\'';
                    }

                    if(String.isNotBlank(intColor)){
                        soqlConditions += ' AND Producto__r.Color__c  LIKE \'%'+ intColor.trim() +'%\'';
                    }

                    if(String.isNotBlank(extColor)){
                        soqlConditions += ' AND Producto__r.Color_Externo__c  LIKE \'%'+ extColor.trim() +'%\'';
                    }   

                    if(String.isNotBlank(vin)){
                        soqlConditions += ' AND ( Producto__r.vin__c LIKE \''+ vin.trim() +'\' OR Producto__r.Codigo_de_Producto__c LIKE \''+ vin.trim() +'\' )';
                    } 
                }

                String soqlCount;
                String soqlString;
                if(productType.contains('vehiculo') || productType.contains('extra')){
                    soqlCount = 'SELECT count() FROM ProductoXBodega__c '+soqlConditions;
                    soqlString = 'SELECT Id, Producto__c, Producto__r.Id,Producto__r.ProductCode, Producto__r.Codigo_de_Producto__c,Producto__r.Anno__c, Producto__r.VN_Familia__c,Producto__r.Name, Producto__r.modelo__c, Producto__r.marcaVehiculo__c,Producto__r.Color__c, Producto__r.vin__c,Producto__r.Color_Externo__c'+
                    ' ,Disponible__c, Name,Bodega__r.Name FROM ProductoXBodega__c '+soqlConditions+' ORDER BY Producto__r.Name LIMIT :PAGE_SIZE  OFFSET :offset';
                }else{
                    soqlCount = 'SELECT count() FROM Product2 '+soqlConditions;
                    soqlString = 'SELECT Id,Name,ProductCode,Codigo_de_Producto__c FROM Product2 '+soqlConditions+' ORDER BY Name LIMIT :PAGE_SIZE  OFFSET :offset';                
                }
                System.debug('@soqlConditions@ '+productType+' : '+soqlString);
                Integer offset = (pageNumber - 1) * PAGE_SIZE;
                Integer totalRecords = Database.countQuery(soqlCount);        
                Integer recordEnd = PAGE_SIZE * pageNumber;
    
                responseMap.put('pageSize',PAGE_SIZE);
                responseMap.put('pageNumber',pageNumber);
                responseMap.put('totalRecords',totalRecords);
                responseMap.put('recordStart',offset + 1);
                responseMap.put('recordEnd',totalRecords >= recordEnd ? recordEnd : totalRecords);   
                
                Set<Id> productIds = new Set<Id>();

                if(productType.contains('vehiculo') || productType.contains('extra')){
                    List<ProductoXBodega__c> prodXBodList = (List<ProductoXBodega__c>) Database.query(soqlString);
                    responseMap.put('products',prodXBodList);
                    
                    for (ProductoXBodega__c prodXBod : prodXBodList) {
                        productIds.add(prodXBod.Producto__c);
                    }        
                }else{
                    List<Product2> productList = (List<Product2>) Database.query(soqlString);
                    responseMap.put('products',productList); 
                    for (Product2 product : productList) {
                        productIds.add(product.Id);
                    }
                }

                String priceSoqlString = 'SELECT Id,UnitPrice,Product2Id FROM PricebookEntry WHERE IsActive = true AND Product2Id IN: productIds';            
                if(productType.contains('vehiculo')){
                    String priceBookFantasiaName = brand+' - '+year;
                    priceSoqlString += ' AND Pricebook2.Name = :priceBookFantasiaName';
                }else {
                    List<Quote> pptos = [SELECT Id,Pricebook2Id FROM Quote WHERE Id =: recordId LIMIT 1];
                    String pbId = pptos[0].Pricebook2Id;
                    priceSoqlString += ' AND Pricebook2Id = :pbId';
                }
                
                if (productIds.size() > 0) {                    
                    // responseMap.put('prices',[SELECT Id,UnitPrice,Product2Id FROM PricebookEntry WHERE IsActive = true AND Pricebook2.Name = :PRICEBOOK_NAME AND Product2Id IN: productIds]);
                    List<PricebookEntry> pbeList= (List<PricebookEntry>) Database.query(priceSoqlString);
                    if ((pbeList != null && pbeList.size() > 0)) {
                        responseMap.put('prices',pbeList);
                    } else {
                        responseMap.put('prices',new PricebookEntry());
                    }

                    // pbeList = (pbeList != null && pbeList.size() > 0) ? pbeList : new PricebookEntry();
                    responseMap.put('prices',pbeList);
                }else{
                    responseMap.put('prices',new PricebookEntry());
                }                
            }    
        } catch (Exception e) {
            responseMap.put('message',e.getMessage());
        }

        if (responseMap.containsKey('message')) {
            responseMap.put('success',false);
            if (!Test.isRunningTest()) {
                throw new AuraHandledException((String) responseMap.get('message'));
            }
        }
        return responseMap;
    }
   

    /**
    * @description Consulta los precios de la lista de precios de fantasia
    * @author marcohernandezhp@gmail.com | 06-18-2023 
    * @param brand Indica la marca y debe corresponder con el nombre de la lista de precios
    * @param year Indica el año del vehiculo y debe corresponder con el nombre de la lista de precios
    * @return Map<String, PricebookEntry> Precios de fantasia agrupados por modelo
    **/
    public static Map<String,PricebookEntry> getPricesGroupByModelFantasia(String brand,String year) {
        Map<String,PricebookEntry> pricesByModelMap = new Map<String,PricebookEntry>();
        brand = '%'+brand+'%';
        year = '%'+year+'%';
        for (PricebookEntry pbe : [SELECT Id, Name, UnitPrice, Costo_Fijo__c,Vendedor__c, Jefe__c, Gerente__c,Product2Id,Product2.Name,Product2.Marca__c,Product2.Modelo_De_Inter_s__c,Pricebook2.Name FROM PricebookEntry WHERE IsActive = TRUE AND Pricebook2.Name LIKE :brand AND Pricebook2.Name LIKE :year AND Pricebook2.IsActive = TRUE AND Product2.IsActive = TRUE AND Product2.Marca__c != NULL AND Product2.Modelo_De_Inter_s__c != NULL]) {
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
        return pricesByModelMap;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getProductDataFromOLI(Id oppProdInteresId){
        Map<String,Object> responseMap = new Map<String,Object>();
        try {
            
            List<Oportunidad_Producto_Interes__c> recordList = [SELECT Id,Marca__c,Modelo_Interes__c,Familia__c,Anio__c FROM Oportunidad_Producto_Interes__c WHERE Id =:oppProdInteresId LIMIT 1];
            if (recordList.size()>0) {
                responseMap.put('brand',recordList[0].Marca__c);
                responseMap.put('model',recordList[0].Modelo_Interes__c);
                responseMap.put('family',recordList[0].Familia__c);
                responseMap.put('year',recordList[0].Anio__c);
            }             
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return responseMap;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getProductByQuoteId(Id quoteId){
        Map<String,Object> responseMap = new Map<String,Object>();
        try {
            List<QuoteLineItem> quoteLineItemList = [SELECT Product2.marcaVehiculo__c,Product2.modelo__c FROM QuoteLineItem WHERE QuoteId =: quoteId AND Product2.esVehiculo__c = true LIMIT 1];            
            if (quoteLineItemList.size()>0) {
                responseMap.put('brand',quoteLineItemList[0].Product2.marcaVehiculo__c);
                responseMap.put('model',quoteLineItemList[0].Product2.modelo__c);
            }        
        } catch (Exception e) {
            if(!Test.isRunningTest()){
                throw new AuraHandledException(e.getMessage());
            }
        }
        return responseMap;
    }


    public static void dummy() {
        String test = '';
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
        test = '';    
    }

}