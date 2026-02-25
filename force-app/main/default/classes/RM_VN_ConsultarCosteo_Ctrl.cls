/**
 * Consulta de costeo de vehiculos
 * @author Marco Hernandez
 * @since Marzo 2024
 * @version 1.0
 * 8-4-2024 Se agrega filtro de marca y año
 * 8-4-2024 Se agrego filtro de bodega el ultimo registro creado en Productos por bodega
 * 9-4-2024 Se agrego filtro que no muestre vehiculos vendidos
 */
public with sharing class RM_VN_ConsultarCosteo_Ctrl {
    
    public static Integer PAGE_SIZE = RM_VN_Service.PAGE_SIZE;

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getData(String brand, String year,String  model,String bodegaId, String  vin ,String  internalColor,String  externalColor ,String  tipoCombustible,String status, Integer pageNumber, Boolean skipPagination){
        Map<String,Object> responseMap = new Map<String,Object>();
        try {
            
            if(skipPagination != null && skipPagination){
                PAGE_SIZE = 50000;
            }

            // Set<Id> vehiculoVendidoIds = getVehiculoVendidoIds(brand,year);

            String filters = ' WHERE isActive = true AND es_Vehiculo_usado__c = false ';

            // if(!vehiculoVendidoIds.isEmpty()){
            //     filters += ' AND Id NOT IN :vehiculoVendidoIds ';
            // }

            //apply the brand filter according to the opportunity record types that the user has access to
            filters += ' '+RM_VN_Service.addBrandFilter(false);

            if(String.isNotBlank(brand)){
                filters += ' AND marcaVehiculo__c = :brand ' ;
            }
            
            if(String.isNotBlank(tipoCombustible)){
                tipoCombustible = '%' + tipoCombustible + '%';
                filters += ' AND combustible__c LIKE \'' + tipoCombustible+'\'' ;
            }

            if(String.isNotBlank(model)){
                model = '%' + model.trim() + '%';
                filters += ' AND (modelo__c LIKE \''+ model+'\' OR Name LIKE \''+model+'\')';
            }
           

            if(String.isNotEmpty(year)){
                year = '%'+year.trim()+'%';
                filters += ' AND (Anno__c LIKE \''+year+'\')';
            }
            

            if(String.isNotBlank(internalColor)){
                internalColor = '%' + internalColor.trim() + '%';
                filters += ' AND Color__c  LIKE \''+internalColor+'\'';
            }
            

            if(String.isNotBlank(externalColor)){
                externalColor = '%' + externalColor.trim() + '%';
                filters += ' AND Color_Externo__c  LIKE \''+externalColor+'\'';
            }   
            

            if(String.isNotBlank(vin)){
                vin = '%' + vin.trim() + '%';
                filters += ' AND ( vin__c LIKE \''+vin+'\' OR Codigo_de_Producto__c LIKE \''+vin +'\')';
            }

            if(String.isNotBlank(status)){
                if (status.equalsIgnoreCase('Disponible')) {
                    filters += ' AND esVehiculo__c = true AND es_Vehiculo_en_transito__c = false AND  Producto_Reservado__c = false AND OportunidadReserva__c = NULL AND Id IN (select producto__c from ProductoXBodega__c where disponible__c > 0) ';
                }else if (status.equalsIgnoreCase('Reservado')) {
                    filters += '  AND esVehiculo__c = true  AND es_Vehiculo_en_transito__c = false AND Producto_Reservado__c = true AND OportunidadReserva__c != null AND Id IN (select producto__c from ProductoXBodega__c where disponible__c > 0) ';
                }else if (status.equalsIgnoreCase('En transito')) {
                    filters += ' AND es_Vehiculo_en_transito__c = true ';
                }
            }
            //este filtro controla que el producto fantasia exista
            if(model != null && model != '' && year != null && year != '' ){
                List<String> lstStr = getNombresProds(model,year);
                filters += ' AND  modelo__c In : lstStr ';
                System.debug('===============================TONIO=============================');
                System.debug(' AND  modelo__c In  '+lstStr+'  ');
            }
            
            pageNumber = pageNumber!= null ? pageNumber : 1;
            
            Integer offset = (pageNumber - 1) * PAGE_SIZE;

            String soqlCount;
            String soqlString;

            soqlCount = 'SELECT count() FROM Product2 '+filters;
            System.debug('@soqlCount@');
            System.debug(soqlCount);
            soqlString = 'SELECT Id,es_Vehiculo_en_transito__c, combustible__c,ProductCode, Codigo_de_Producto__c,Anno__c, VN_Familia__c, modelo__c, marcaVehiculo__c,Color__c, vin__c,Color_Externo__c,RM_NoDiasInventario__c , Name,(SELECT Monto_Dolar__c,Monto_local__c FROM Detalles_Costo_Productos__r),(SELECT Id,Name,Bodega__r.Name FROM Productos_por_Bodega__r WHERE Disponible__c > 0 ) FROM Product2  '+filters+' AND ID IN (Select Producto__c From ProductoXBodega__c WHERE Disponible__c > 0)  ORDER BY Name LIMIT :PAGE_SIZE  OFFSET  :offset ';
            
            System.debug('@soqlString@');
            System.debug(soqlString);
            Integer totalRecords = Database.countQuery(soqlCount);        
            Integer recordEnd = PAGE_SIZE * pageNumber;

            responseMap.put('pageSize',PAGE_SIZE);
            responseMap.put('pageNumber',pageNumber);
            responseMap.put('totalRecords',totalRecords);
            responseMap.put('recordStart',offset + 1);
            responseMap.put('recordEnd',totalRecords >= recordEnd ? recordEnd : totalRecords);
        
            List<Product2> prodXBodList = (List<Product2>) Database.query(soqlString);
            responseMap.put('records',prodXBodList);
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return responseMap;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getDataError(Integer pageNumber){
        Id devRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Vehiculos').getRecordTypeId();
        String recordString = String.valueOf(devRecordTypeId);
        Map<String,Object> responseMap = new Map<String,Object>();
        try {
                    
            pageNumber = pageNumber!= null ? pageNumber : 1;
            
            Integer offset = (pageNumber - 1) * PAGE_SIZE;

            String soqlCount;
            String soqlString;

            String filters = ' WHERE (isActive = false OR marcaVehiculo__c = null OR modelo__c = null OR Anno__c = null  ) AND Producto_Reservado__c = false AND esVehiculo__c = true AND Grupo2__c != \'' + 'Autos Usados' + '\' AND es_Vehiculo_usado__c = false AND RecordTypeId = \'' + recordString + '\' ' ;

            soqlCount = 'SELECT count() FROM Product2 ' + filters + ' AND ID IN (Select Producto__c From ProductoXBodega__c  WHERE Disponible__c > 0)';
            System.debug('@soqlCount@');
            System.debug(soqlCount);
            soqlString = 'SELECT Id, isActive,es_Vehiculo_en_transito__c, esVehiculo__c,Producto_Reservado__c, combustible__c,ProductCode, Codigo_de_Producto__c,Anno__c, VN_Familia__c, modelo__c, marcaVehiculo__c,Color__c, vin__c,Color_Externo__c,RM_NoDiasInventario__c , Name,(SELECT Monto_Dolar__c,Monto_local__c FROM Detalles_Costo_Productos__r),(SELECT Id,Name,Bodega__r.Name FROM Productos_por_Bodega__r WHERE Disponible__c > 0 ) FROM Product2 '+filters+' AND ID IN (Select Producto__c From ProductoXBodega__c  WHERE Disponible__c > 0) ORDER BY Name LIMIT :PAGE_SIZE  OFFSET  :offset ';
            
            System.debug('@soqlString@');
            System.debug(soqlString);
            Integer totalRecords = Database.countQuery(soqlCount);        
            Integer recordEnd = PAGE_SIZE * pageNumber;

            responseMap.put('pageSize',PAGE_SIZE);
            responseMap.put('pageNumber',pageNumber);
            responseMap.put('totalRecords',totalRecords);
            responseMap.put('recordStart',offset + 1);
            responseMap.put('recordEnd',totalRecords >= recordEnd ? recordEnd : totalRecords);
        
            List<Product2> prodXBodList = (List<Product2>) Database.query(soqlString);
            responseMap.put('records',prodXBodList);
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return responseMap;
    }
    // private static List<ProductoXBodega__c> getProductosXBodegas(String marca, String anio) {
    //     return [SELECT Producto__c,Bodega__c,Bodega__r.Name FROM ProductoXBodega__c WHERE Disponible__c > 0 AND Bodega__c != null];        
    // }

    private static List<String> getNombresProds(String modelo, String anio) {
        System.debug('================================TONIO=============================');
            System.debug('modelo ' + modelo);
            System.debug('anio ' + anio);
        Id devRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Producto Red Motors').getRecordTypeId();
        String anioLike = '%' + anio + '%';
        List<String> lstStr = new List<String>();
        List<Product2> lstProd = [Select Name From Product2 Where Name Like: modelo And recordTypeId =: devRecordTypeId AND ID IN (Select Product2Id From PricebookEntry Where 	Pricebook2.Description Like: anioLike )];        
        for(Product2 prod : lstProd){
            lstStr.add(prod.Name);
        }
        return lstStr;
    }   

    // private static List<Bodega__c> getBodegas(List<ProductoXBodega__c> pxbs) {
    //     Map<Id,Bodega__c> bodegas = new Map<Id,Bodega__c>();
    //     for (ProductoXBodega__c pxb : pxbs) {
    //         bodegas.put(pxb.Bodega__c,pxb.Bodega__r);
    //     }
    //     return bodegas.values();
    // }

    // private static Set<Id> getVehiculosDisponibles(List<ProductoXBodega__c> pxbs) {
    //     Set<Id> vehiculoDisponibles = new Set<Id>();
    //     for(ProductoXBodega__c pxb : pxbs){
    //         if(pxb.Bodega__r.Name.toLowerCase().contains('trán') || pxb.Bodega__r.Name.toLowerCase().contains('tran')){
    //             continue;
    //         }
    //         vehiculoDisponibles.add(pxb.Producto__c);
    //     }
    //     return vehiculoDisponibles;
    // }

    // private static Set<Id> getVehiculoVendidoIds(String marca, String anio) {
    //     Set<Id> vehiculoVendidoIds = new Set<Id>();
    //     List<OpportunityLineItem> oppLineItems = [SELECT Product2Id FROM OpportunityLineItem WHERE Opportunity.StageName = 'Cerrada Ganada' ];
    //     for(OpportunityLineItem oppLineItem : oppLineItems){
    //         vehiculoVendidoIds.add(oppLineItem.Product2Id);
    //     }
    //     return vehiculoVendidoIds;
    // }

    // private static Set<Id> getProductoXBodegaIds(String marca, String anio) {
    //     Set<Id> productoXBodegaIds = new Set<Id>();
    //     List<Product2> products = [SELECT Id,(SELECT Id FROM Productos_por_Bodega__r WHERE Bodega__c != NULL ORDER BY CreatedDate DESC LIMIT 1) FROM Product2 WHERE IsActive = true AND Modelo_De_Inter_s__c = NULL and modelo__c != NULL AND Producto_Reservado__c = true];
    //     for(Product2 product : products){
    //         if(product.Productos_por_Bodega__r.size() > 0){
    //             productoXBodegaIds.add(product.Productos_por_Bodega__r[0].Id);
    //         }
    //     }
    //     return productoXBodegaIds;
    // }

    @AuraEnabled(cacheable=true)
    public static List<Detalle_Costo_Producto__c> getDetalleCosto(String vehiculoId){
        try {
            return [SELECT Id,Name,id_linea_gasto__c,Monto_Dolar__c,Monto_local__c,Rubro__c,Product__c,Product__r.Name FROM Detalle_Costo_Producto__c WHERE Product__c = :vehiculoId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}