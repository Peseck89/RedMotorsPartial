/**
 * Clase que realiza el cambio de ubicacion de un vehiculo y lo notifica a Softland
 * @TestClass RM_VN_CambiarUbicacion_Ctrl_Test
 * @author Redmotors
 * @since 06-09-2024
 * @ChangeLog se agrega ajuste para enviar dinamicamente la compañia RMBAVARIAN si la empresa es BAVARIAN y RMOTOBAI cuando es OTOBAI
 */
public with sharing class RM_VN_CambiarUbicacion_Ctrl {

    @AuraEnabled
    public static Map<String,Object> guardar(String productoXBodegaOrigenId,String bodegaDestinoId){
        Map<String,Object> respuesta = new Map<String,Object>();
        
        //validar campos requeridos
        if(String.isBlank(productoXBodegaOrigenId) || String.isBlank(bodegaDestinoId)){
            throw new AuraHandledException('Los campos (productoXBodegaOrigenId,bodegaDestinoId) son requeridos');
        }

        try {

            //consultar la bodega inicio
            List<Bodega__c> bodegas = [SELECT Id, ID_EXTERNO_BODEGA__c FROM Bodega__c WHERE Id =: bodegaDestinoId];

            //validar que la bodega exista
            if(bodegas.size() == 0){
                throw new AuraHandledException('No se encontró la bodega destino');
            }

            //Actualizar la disponibilidad a 0
            List<ProductoXBodega__c> productoXBodegas = [SELECT Id, Producto__c,Producto__r.Empresa__c,Producto__r.vin__c, Bodega__c,Bodega__r.Name,Disponible__c, Bodega__r.ID_EXTERNO_BODEGA__c FROM ProductoXBodega__c WHERE Id = :productoXBodegaOrigenId];
            
            //validar que el producto exista en la bodega
            if(productoXBodegas.size() == 0){
                throw new AuraHandledException('No se encontró el producto en la bodega existente');
            }

            String empresa = getCompanyName(productoXBodegas[0]?.Producto__r?.Empresa__c);
            String vin = productoXBodegas[0].Producto__r.vin__c;
            String codigoBodegaOrigen = productoXBodegas[0].Bodega__r.ID_EXTERNO_BODEGA__c;
            String codigoBodegaDestino = bodegas[0].ID_EXTERNO_BODEGA__c;
            
            //validar que no sean nulos y que no sean iguales
            if(String.isBlank(vin) || String.isBlank(codigoBodegaOrigen) || String.isBlank(codigoBodegaDestino)){
                throw new AuraHandledException('Alguno de los campos (vin,código bodega origen,código bodega destino) esta vacio');
            }

            //validar que la bodega origen y destino no sean iguales
            if(codigoBodegaOrigen == codigoBodegaDestino){
                throw new AuraHandledException('El código de la bodega origen y destino no pueden ser iguales');
            }

            RM_SoftlandClient softlandClient = new RM_SoftlandClient();
            Map<String,Object> result = softlandClient.postData('/softlandAPI/Catalogs/vehiculoTransfer',prepareParams(vin,empresa,codigoBodegaOrigen,codigoBodegaDestino));

            String data = (String) result.get('data');
            System.debug('************** data **************');
            System.debug(data);
            //check if the response is not null
            if(String.isBlank(data)){
                throw new AuraHandledException('No se pudo realizar el cambio de ubicación');
            }

            //parse the response intto RM_SoftlandClientResponse class
            RM_SoftlandClientResponse response = (RM_SoftlandClientResponse) JSON.deserialize(data, RM_SoftlandClientResponse.class);

            //check if the response is not null
            if(response == null){
                throw new AuraHandledException('No fue posible extraer la información de la respuesta');
            }

            if (response.operationResult.code == '00') {
                respuesta.put('success',true);
                respuesta.put('message',response.operationResult.description);
                RM_VN_CambiarUbicacionQueueable executeUpdateCambioUbicacion = new RM_VN_CambiarUbicacionQueueable(productoXBodegaOrigenId,bodegaDestinoId);
                System.enqueueJob(executeUpdateCambioUbicacion);
            }else {
                throw new AuraHandledException(response.operationResult.description);
            }

            System.debug('************** response **************');
            System.debug(response);

            return respuesta;
        } catch (DmlException e) {
            //check the context
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static String getCompanyName(String empresa){
        if(String.isNotBlank(empresa) && empresa == 'OTOBAI'){
            return 'RMOTOBAI';
        }
        return 'RMBAVARIAN';
    }

    /**
     * jsonMap.put('compania', 'RMBAVARIAN');
     * jsonMap.put('origen', 'VN01');
    *  jsonMap.put('destino', 'VN02');
     * @param codigoProducto 
     * @param bodega 
     * @return  `String`
     */
    public static String prepareParams(String vin,String empresa,String bodegaOrigen,String bodegaDestino) {
        return JSON.serialize(new Map<String, Object>{
            'VIN' => vin,
            // 'compania' => 'RMBAVARIAN',
            'compania' => empresa,
            'origen' => bodegaOrigen,
            'destino' => bodegaDestino
        });
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchBodegas(String searchTerm, List<String> selectedIds, String firedElement, String objName, String displayedObjName, String icon, String additionalConditions) {
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        try {
            String trimmedSearchTerm = '%' + searchTerm.trim() + '%';
            String query = 'SELECT Id, Name FROM Bodega__c WHERE Name LIKE :trimmedSearchTerm';
            
            // Append additional conditions if provided
            if (String.isNotBlank(additionalConditions)) {
                query += additionalConditions;
            }
            
            // Add ORDER BY clause to sort by Name
            query += ' ORDER BY Name LIMIT 10';
            
            List<Bodega__c> bodegas = Database.query(query);

            for (Bodega__c bodega : bodegas) {
                String subtitle = 'Bodega';
                String resultName = bodega.Name;
                results.add(new LookupSearchResult(bodega.Id, objName, icon, resultName, subtitle));
            }
        } catch (Exception e) {
            System.debug('Error in searchBodegas: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while searching for Bodegas.');
        }
        return results;
    }
}