public class QLIGridController {
    
    @AuraEnabled(cacheable=true)
    public static List<tiposDeTrabajo__c> findTrabajos(String searchKeyTrabajo) {
        return [SELECT Id, Name FROM tiposDeTrabajo__c WHERE Name LIKE :('%' + searchKeyTrabajo + '%') LIMIT 10];
    }
    
    @AuraEnabled(cacheable=false)
    public static List<QliGridWrapper> searchProducts (String productType, String queryValue, Id quote) { 
        QliGridHelper qliSearchHelper = new QliGridHelper(quote);
        return qliSearchHelper.searchProductsbyValue(productType, queryValue); 
    }
    @AuraEnabled(cacheable=true)
    public static Map<Id, Id> getTiposTrabajoPorMO(List<Id> product2Ids) {
        Map<Id, Id> res = new Map<Id, Id>();
        if (product2Ids == null || product2Ids.isEmpty()) return res;
        for (tiposDeTrabajo__c tt : [
            SELECT Id, ManoDeObra__c
            FROM tiposDeTrabajo__c
            WHERE ManoDeObra__c IN :product2Ids
        ]) {
            res.put(tt.ManoDeObra__c, tt.Id);
        }
        return res;
    }
    
    @AuraEnabled(cacheable=false)
    public static List<QliGridWrapper> getQlis (string listTosave, Id quote) { 
        QliGridHelper qliCalculation = new QliGridHelper(quote);
        return qliCalculation.qolisToWrappers(listTosave);
    }
    
    @AuraEnabled(cacheable=false)
    public static void saveQlis (String jsonString, Id quote) { 
        QliGridDML qliGridDML = new QliGridDML(jsonString);
        QliGridDML.saveQuoteLineItems(quote);
    }
    
    @AuraEnabled(cacheable=false)
    public static void saveQuantities (String jsonString, Id quote) { 
        QliGridDML qliGridDML = new QliGridDML(jsonString);
        QliGridDML.saveQuantities(quote);
    }
    
    @AuraEnabled(cacheable=false)
    public static void deleteQlis (List<String> quoteIds) {
        QliGridDML.deleteQlis(quoteIds);
    }


    @AuraEnabled(cacheable=false)
    public static String setPublicFileWO (List<String> contentIds, Id quoteId) {
        QliGridHelper qliFileHelper = new QliGridHelper(quoteId);
        return  qliFileHelper.saveAndGetPublicURLFileWO(contentIds);
    }
    @AuraEnabled(cacheable=false)
    public static String setPublicFile (List<String> contentIds, Id quoteId) {
        QliGridHelper qliFileHelper = new QliGridHelper(quoteId);
        return  qliFileHelper.saveAndGetPublicURLFile(contentIds);
    }
    
  /*  @AuraEnabled(cacheable=false)
    public static List<QliGridWrapper> consultarDisponibilidad (String jsonString, Id quote, String quoteNumber) {
        System.debug('JSONSTRING CONSULTAR DISP   ' + jsonString);
        List<QliGridWrapper> quotelineitems = (List<QliGridWrapper>)JSON.deserialize(jsonString, List<QliGridWrapper>.class);
        return consultaDisponibleBodega.consultarDisponibilidad(quotelineitems,quoteNumber);
    }*/
    
   /* @AuraEnabled(cacheable=false)
    public static String requestDespacho (String workOrderNumber, List<String> notAvailableIds, List<String> selectedIDList) {
        System.debug(selectedIDList);
        ServicioReservaApartadoArticulos servicio = new ServicioReservaApartadoArticulos(workOrderNumber, 'entregar',notAvailableIds, selectedIDList);
        return servicio.realizarReservaApartado();
        //return 'Existen artículos que requieren validación.';
    }*/
    /*
    @AuraEnabled(cacheable=false)
    public static String requestApartar (String workOrderNumber, List<String> notAvailableIds, List<String> selectedIDList) {
       System.debug(selectedIDList);
       ServicioReservaApartadoArticulos servicio = new ServicioReservaApartadoArticulos(workOrderNumber, 'apartar', notAvailableIds, selectedIDList);
       return servicio.realizarReservaApartado();
          //return 'Existen artículos que requieren validación.';
    }
    
    @AuraEnabled(cacheable=false)
    public static String requestDevolucion (String workOrderNumber, List<String> devolutionIds) {
        ServicioEliminarReservaArticulo servicio = new ServicioEliminarReservaArticulo(workOrderNumber, devolutionIds);
        return servicio.eliminarReservaArticulos();
         //return 'Existen artículos que requieren validación.';
    }
    
    @AuraEnabled(cacheable=false)
    public static String sendPDF (Id workorder, String email) {
        return savePDFfile.attachPDFinWO(workorder, 'Despacho de repuestos','AlbaranPDFGroupTc?id=' + workorder, false,true, email);
    }

    @AuraEnabled(cacheable=false)
    public static String sendSC (String departamento, String prioridad, String anticipo,  Id quoteId, List<String> idsToSC) {
        System.debug('Quote Number ' + quoteId);
        System.debug('Quote departamento ' + departamento);
        string resultado = ServicioCrearSCQuote.crearSolicitudCompra(quoteId, departamento, prioridad, anticipo, idsToSC);
        System.debug('Resultado ' + resultado);
        return resultado; 
    }

    @AuraEnabled(cacheable=false)
    public static String sendSCWO (String departamento, String prioridad, String anticipo,  Id workOrderId, List<String> idsToSC) {
        System.debug('PRINT PARAMS TO DIEGO ');
        System.debug('Workorder ID ' + workOrderId);
        System.debug('Departamento ' + departamento);
        System.debug('Prioridad ' + prioridad);
        System.debug('Workorder anticipo ' + anticipo);
        System.debug('Workorder IDS de WOLIS ' + idsToSC);
        string resultado = ServicioCrearSCWorkOrder.crearSolicitudCompra(workOrderId, departamento, prioridad, anticipo, idsToSC);
        System.debug('Resultado ' + resultado);
        return resultado; 
        //DIEGO ACA LA LOGICA DE LA WORKORDER para archivos
       /* WoliGridQueryService consultaArchivos = new WoliGridQueryService(workOrderId);
        List<String> listaarchivos = new List<String>();
		listaarchivos = consultaArchivos.getFileUrlsFromWorkOrder();
        consultaArchivos.updateDocsAsSendWO();
        return '00';*/
   /* }*/

}