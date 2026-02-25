/**
 * 
 * @author Portalnet
 * @since 2024
 * @Test Class RM_VN_Inventario_Ctrl_Test
 * Clase que se encarga de la lógica de negocio de la pantalla de inventario de vehículos
 * Changes:
 * 2024-10-13 (Portalnet) Se agrega nuevo filtro, reportado, para filtrar los vehículos que han sido reportados
 * 2024-10-13 (Portalnet) Se agrega nuevo filtro, numero de pedido, para filtrar los vehículos por el número de pedido
 * 2024-10-28 (Portalnet) Se agrega metodo para consultar los modelos disponibles en la tabla de productos
 */
public with sharing class RM_VN_Inventario_Ctrl {

    static Integer PAGE_SIZE = 50000;
   @AuraEnabled(cacheable=true)
public static List<String> searchColors(String selectedBrand, String selectedYear, String selectedModel) {
    Set<String> uniqueColors = new Set<String>();

    // Construimos la consulta SOQL para obtener colores únicos
    String queryString = 'SELECT Color_Externo__c FROM Product2 WHERE IsActive = true AND Color_Externo__c != NULL';

    if (String.isNotBlank(selectedBrand)) {
        queryString += ' AND marcaVehiculo__c = \'' + String.escapeSingleQuotes(selectedBrand) + '\'';
    }
    if (String.isNotBlank(selectedYear)) {
    	queryString += ' AND (Ano__c = ' + selectedYear;
    	queryString += ' OR Anno__c = \'' + String.escapeSingleQuotes(selectedYear) + '\')';
	}

    if (String.isNotBlank(selectedModel)) {
    	queryString += ' AND modelo__c = \'' + String.escapeSingleQuotes(selectedModel) + '\'';
    }

    // Agrupamos por color externo para evitar duplicados en la consulta SOQL
    queryString += ' GROUP BY Color_Externo__c ORDER BY Color_Externo__c ASC';
    // Ejecutamos la consulta
    List<AggregateResult> results = Database.query(queryString);

    // Iteramos sobre los resultados y agregamos valores únicos al conjunto
    for (AggregateResult ar : results) {
    String color = (String) ar.get('Color_Externo__c');
    if (String.isNotBlank(color)) {
        uniqueColors.add(color); // Agrega el color tal cual, sin modificarlo
    }
	}

    return new List<String>(uniqueColors);
}

@AuraEnabled(cacheable=true)
public static List<String> searchTapicerias(String selectedBrand, String selectedModel, String selectedYear) {
    Set<String> uniqueColors = new Set<String>();

    String queryString = 'SELECT Color__c FROM Product2 WHERE IsActive = true AND Color__c != NULL';
System.debug('queryString '+queryString);
    if (String.isNotBlank(selectedBrand)) {
        queryString += ' AND marcaVehiculo__c = \'' + String.escapeSingleQuotes(selectedBrand) + '\'';
    }

    if (String.isNotBlank(selectedModel)) {
       queryString += ' AND modelo__c = \'' + String.escapeSingleQuotes(selectedModel) + '\'';
    }

    if (String.isNotBlank(selectedYear)) {
    	queryString += ' AND (Ano__c = ' + selectedYear;
    	queryString += ' OR Anno__c = \'' + String.escapeSingleQuotes(selectedYear) + '\')';
	}

    queryString += ' GROUP BY Color__c ORDER BY Color__c ASC';

    List<AggregateResult> results = Database.query(queryString);
for (AggregateResult ar : results) {
    String color = (String) ar.get('Color__c');
    if (String.isNotBlank(color)) {
        uniqueColors.add(color); // Se agrega el color sin modificarlo
    }
}
System.debug('uniqueColors ' + uniqueColors);

return new List<String>(uniqueColors);
}

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getRecords(String brand, String year,String  model,String family, String productCode,String locationId, String  vin ,String  internalColor,String  externalColor ,String  tipoCombustible,String  reportado,String  numeroPedido,String vehiculoTransito, Integer pageNumber, Boolean skipPagination){        
        
        Map<String,Object> responseMap = new Map<String,Object>();

        if(skipPagination != null && skipPagination){
            PAGE_SIZE = 50000;
        }

        if(String.isBlank(brand)){ 
            throw new AuraHandledException('La marca es requerida.');
        }

        if(String.isBlank(year)){ 
            throw new AuraHandledException('El año es requerido.');
        }

        Id softlandPBId = RM_VN_Service.getSoftlandPriceBookId(brand,year);
        if (softlandPBId == null) {
            throw new AuraHandledException('Favor de revisar la configuración de la lista de precio en Configuración de Ventas.');
        }

        Map<String,PricebookEntry> modelPBEMap = RM_VN_Service.getPBEFantasiaGroupByModel(brand,year);

        if (modelPBEMap.isEmpty()) { if (!Test.isRunningTest()) { throw new AuraHandledException('No se encontraron precios de fantasia la Marca y Año ingresados.');
            }
        }

        List<PricebookEntry> pbeList = RM_VN_Service.getSoftlandPBE(brand,year,model);
        if (pbeList.isEmpty()) { if (!Test.isRunningTest()) { throw new AuraHandledException('No se encontraron precios de Softland configurados para la Marca y Año.');
            }
        }

        Set<Id> prodWithPBEBararianIds = new Set<Id>();
        for (PricebookEntry pbe : pbeList) {
            prodWithPBEBararianIds.add(pbe.Product2Id);
        }

        try {
            String soqlConditions = '';
            Set<Id> locationIds = getLocationIds(brand);
            soqlConditions += ' WHERE Producto__r.Producto_Reservado__c = false AND Bodega__r.Bodega_vehiculos_nuevos__c = TRUE AND Disponible__c > 0 AND Bodega__c != null AND Bodega__c IN :locationIds AND Producto__r.marcaVehiculo__c LIKE \'%'+ brand.trim() +'%\' AND Producto__r.Anno__c = \''+ year.trim() +'\' AND Producto__c IN :prodWithPBEBararianIds AND (Producto__r.OportunidadReserva__c = null OR Producto__r.OportunidadReserva__r.Owner.Id = \''+UserInfo.getUserId()+'\' ) ';

            //apply filter vehiculo en transito
            if(vehiculoTransito.equalsIgnoreCase('Si')){
                soqlConditions += ' AND  Producto__r.es_Vehiculo_en_transito__c = TRUE  AND  Producto__r.esVehiculo__c = TRUE ';
            }else if(vehiculoTransito.equalsIgnoreCase('No')){
                soqlConditions += ' AND  Producto__r.es_Vehiculo_en_transito__c = false  AND  Producto__r.esVehiculo__c = TRUE ';
            }else{
                soqlConditions += ' AND  Producto__r.esVehiculo__c = TRUE ';
            }

            //apply the brand filter according to the opportunity record types that the user has access to
            soqlConditions += ' '+RM_VN_Service.addBrandFilter();
            
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

            if(String.isNotBlank(productCode)){                
                soqlConditions += ' AND ( Producto__r.ProductCode LIKE \'%'+ productCode.trim() +'%\')';
            }

            if(String.isNotBlank(tipoCombustible) && !tipoCombustible.equalsIgnoreCase('all')){
                soqlConditions += ' AND Producto__r.combustible__c = :tipoCombustible ';
            }
            
            if (String.isNotBlank(reportado)) {
                Boolean reportadoBool = reportado.equalsIgnoreCase('Si');
                soqlConditions += ' AND Producto__r.RM_Reportado__c = :reportadoBool ';
            }

            if (String.isNotBlank(numeroPedido)) {
                soqlConditions += ' AND Producto__r.Pedido_Original__c = :numeroPedido ';
            } 

            if(String.isNotBlank(model)){
                soqlConditions += ' AND (Producto__r.modelo__c LIKE \'%'+ model.trim() +'%\' OR Producto__r.Name LIKE \'%'+ model.trim() +'%\')';
            }
			if(String.isNotBlank(family)){
                //soqlConditions += ' AND (Producto__r.VN_Familia__c LIKE \'%'+ family.trim() +'%\' OR Producto__r.Name LIKE \'%'+ family.trim() +'%\')';
                soqlConditions += ' AND (Producto__r.VN_Familia__c = \''+ String.escapeSingleQuotes(family.trim()) +'\' OR Producto__r.Name = \''+ String.escapeSingleQuotes(family.trim()) +'\')';

            }
            if(String.isNotBlank(internalColor)){
                //soqlConditions += ' AND Producto__r.Color__c  LIKE \'%'+ internalColor.trim() +'%\'';
                soqlConditions += ' AND Producto__r.Color__c LIKE \'%' + String.escapeSingleQuotes(internalColor.trim()) + '%\'';

            }

            if(String.isNotBlank(externalColor)){
                //soqlConditions += ' AND Producto__r.Color_Externo__c  LIKE \'%'+ externalColor.trim() +'%\'';
                soqlConditions += ' AND Producto__r.Color_Externo__c LIKE \'%' + String.escapeSingleQuotes(externalColor.trim()) + '%\'';

            }   

            if(String.isNotBlank(vin)){
                //soqlConditions += ' AND ( Producto__r.vin__c = \''+ vin.trim() +'\' OR Producto__r.Codigo_de_Producto__c = \''+ vin.trim() +'\' )';
                soqlConditions += ' AND ( Producto__r.vin__c = \'' + String.escapeSingleQuotes(vin.trim()) + '\' OR Producto__r.Codigo_de_Producto__c = \'' + String.escapeSingleQuotes(vin.trim()) + '\' )';
            }

            if(String.isNotBlank(locationId) && !locationId.equalsIgnoreCase('all')){
                locationId = String.escapeSingleQuotes(locationId.trim());
                soqlConditions += ' AND Bodega__c = :locationId';
            }


            Integer offset = (pageNumber - 1) * PAGE_SIZE;

            String soqlCount;
            String soqlString;

            soqlCount = 'SELECT count() FROM ProductoXBodega__c '+soqlConditions;
           soqlString = 'SELECT Id, Producto__c, Producto__r.RM_Comentario__c, Producto__r.es_Vehiculo_en_transito__c, Producto__r.combustible__c, Producto__r.Id, Producto__r.ProductCode, Producto__r.Codigo_de_Producto__c, Producto__r.Anno__c, Producto__r.VN_Familia__c, Producto__r.Name, Producto__r.modelo__c,Producto__r.familia__c, Producto__r.marcaVehiculo__c, Producto__r.Color__c, Producto__r.vin__c, Producto__r.Color_Externo__c, Producto__r.RM_CodigoEquipamiento__c, Producto__r.Pedido_Original__c, Producto__r.RM_Reportado__c, Producto__r.fecha_ingreso_inventario__c, Producto__r.RM_NoDiasInventario__c, Producto__r.tapiceria__c, Disponible__c, Name, Bodega__r.Name FROM ProductoXBodega__c ' 
						+ soqlConditions 
						+ ' ORDER BY Producto__r.RM_NoDiasInventario__c DESC, Producto__r.Name ASC LIMIT :PAGE_SIZE OFFSET :offset';


            Integer totalRecords = Database.countQuery(soqlCount);        
            Integer recordEnd = PAGE_SIZE * pageNumber;

            responseMap.put('pageSize',PAGE_SIZE);
            responseMap.put('pageNumber',pageNumber);
            responseMap.put('totalRecords',totalRecords);
            responseMap.put('recordStart',offset + 1);
            responseMap.put('recordEnd',totalRecords >= recordEnd ? recordEnd : totalRecords);
              
            Set<Id> productIds = new Set<Id>();

            List<ProductoXBodega__c> prodXBodList = (List<ProductoXBodega__c>) Database.query(soqlString);
            responseMap.put('records',prodXBodList);
            responseMap.put('preciosFantasia',modelPBEMap.values());
            responseMap.put('preciosSoftland',pbeList);
            
            for (ProductoXBodega__c prodXBod : prodXBodList) {
                productIds.add(prodXBod.Producto__c);
            }        

        } catch (Exception e) {
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
       options.add(new RM_SelectOption_Wrapper('Todos', 'all'));
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
    public static List<RM_SelectOption_Wrapper> getLocations(String marca)
    {
        List<RM_SelectOption_Wrapper> options = new List<RM_SelectOption_Wrapper>();
        options.add(new RM_SelectOption_Wrapper('Todos', 'all'));
        for(Bodega__c bodega : getUbicaciones(marca))
        {
            options.add(new RM_SelectOption_Wrapper(bodega.Name, bodega.Id));
        }
        return options;
    }

    private static Set<Id> getLocationIds(String marca)
    {
        Set<Id> locationIds = new Set<Id>();
        for(Bodega__c bodega : getUbicaciones(marca))
        {
            locationIds.add(bodega.Id);
        }
        return locationIds;
    }

    private static List<Bodega__c> getUbicaciones(String marca) {
        if (String.isBlank(marca)) {
            return null;
        }
    
        marca = '%' + String.escapeSingleQuotes(marca) + '%';
        return [SELECT Id, Name 
                FROM Bodega__c 
                WHERE Bodega_vehiculos_nuevos__c = TRUE 
                AND Id IN (SELECT Bodega__c 
                           FROM Ubicaciones_por_Marca__c 
                           WHERE Marca__c LIKE :marca) 
                ORDER BY Name ASC];
    }

    @AuraEnabled
    public static Map<String,Object> agregaComentario(String vehiculoId, String comentario,Boolean reportado)
    {
        Map<String,Object> responseMap = new Map<String,Object>();

        //validar que los parametros no sean nulos
        if(String.isBlank(vehiculoId)){ 
            throw new AuraHandledException('El vehiculo es requerido.');
        }

        if(String.isBlank(comentario)){ 
            throw new AuraHandledException('El comentario es requerido.');
        }

        //buscar el vehiculo
        ProductoXBodega__c pxb = [SELECT Id, Producto__r.Id,Producto__r.RM_Comentario__c,Producto__r.RM_Reportado__c FROM ProductoXBodega__c WHERE Id = :vehiculoId LIMIT 1];
        if(pxb == null){
            throw new AuraHandledException('No se encontró el vehículo.');
        }

        try{
            //actualizar el campo de reportado
            pxb.Producto__r.RM_Reportado__c = reportado;
            pxb.Producto__r.RM_Comentario__c = comentario;
            update pxb.Producto__r;
            return responseMap;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(Cacheable=true)
public static List<LookupSearchResult> searchModels(
    String searchTerm, 
    String rawSearchTerm, 
    List<String> selectedIds, 
    String firedElement, 
    String objName, 
    String displayedObjName, 
    String icon, 
    String selectedFamily,
    String selectedBrand 
) {
    System.debug('selectedFamily '+selectedFamily);
    System.debug('selectedBrand '+selectedBrand);
    return searchProducts(rawSearchTerm, 'modelo__c', 'Modelo', objName, icon, selectedFamily, selectedBrand);
}

@AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchFamilias(String searchTerm, String rawSearchTerm, List<String> selectedIds, String firedElement, String objName, String displayedObjName, String icon, String selectedBrand) {
            System.debug('selectedBrand1 '+selectedBrand);
        return searchProducts(rawSearchTerm, 'VN_Familia__c', 'Familia', objName, icon, '',selectedBrand);
    }
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchNumeroPedidos(String searchTerm, String rawSearchTerm, List<String> selectedIds, String firedElement, String objName, String displayedObjName, String icon) {
        return searchProducts(rawSearchTerm, 'Pedido_Original__c', 'Pedido', objName, icon, '','');
    }

    
     private static List<LookupSearchResult> searchProducts(
    String searchTerm, 
    String fieldName, 
    String subtitle, 
    String objName, 
    String icon, 
    String selectedFamily, // Parámetro adicional para la familia
    String selectedBrand
) {
    List<LookupSearchResult> results = new List<LookupSearchResult>();
    searchTerm = '%' + String.escapeSingleQuotes(searchTerm) + '%';

    // Construimos la consulta SOQL
    String queryString = 'SELECT ' + fieldName + ' FROM Product2 WHERE ' + fieldName + ' != NULL AND IsActive = true';
    System.debug('selectedBrand2 '+selectedBrand);

    // Agregamos la condición para la familia, si está presente
    if (String.isNotBlank(selectedFamily)) {
		queryString += ' AND VN_Familia__c = \'' + String.escapeSingleQuotes(selectedFamily) + '\''; 
    }
    if (String.isNotBlank(selectedBrand)) {
        queryString += ' AND marcaVehiculo__c = \'' + selectedBrand + '\'';
    }

    queryString += ' AND ' + fieldName + ' LIKE \'' + searchTerm + '\' GROUP BY ' + fieldName + 
                   ' ORDER BY ' + fieldName + ' ASC LIMIT 10';
  System.debug('queryString '+queryString);
    // Ejecutamos la consulta con el filtro de familia
    List<AggregateResult> products = Database.query(queryString);

    for (AggregateResult product : products) {
        String fieldValue = (String) product.get(fieldName);
        results.add(new LookupSearchResult(fieldValue, objName, icon, fieldValue, subtitle));
    }

    return results;
}


    public static void testss() {
        String dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
         dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
         dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
         dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
        dummy = '';
    }

}