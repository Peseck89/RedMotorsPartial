@RestResource(urlMapping='/actualizarFechaFacturacionVehiculo')
global class actualizarFechaFacturacionVehiculo {
    
    @HttpPost
    global static void actualizarOportunidad() {        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String jsonStr = RestContext.request.requestBody.toString();
        System.debug('JSON Recieved ' + jsonStr);
        
        /*
        if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }
		*/

        try {
            // Analizar el JSON recibido
            // 
            actualizarFacturacionRequest wrapRespuestaJSON = actualizarFacturacionRequest.parseRespuesta(jsonStr);
            String opportunityId = wrapRespuestaJSON.OpportunityId;
            String fechaFacturacion = wrapRespuestaJSON.FechaDeFacturacion;
            String vinVehiculo = wrapRespuestaJSON.VINVehiculo;
            String estado = wrapRespuestaJSON.Estado;
            // 
            //
            /* 
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            String opportunityId = (String) jsonMap.get('OpportunityId');
            String fechaFacturacion = (String) jsonMap.get('FechaDeFacturacion');
            String vinVehiculo = (String) jsonMap.get('VINVehiculo');
            String estado = (String) jsonMap.get('Estado');
			*/
            // Buscar la oportunidad por el OpportunityId
            Opportunity opportunity = [SELECT Id, Name, ConsecutivoOportunidad__c FROM Opportunity WHERE ConsecutivoOportunidad__c = :opportunityId LIMIT 1];

            if (opportunity != null) {
                // Buscar el producto de oportunidad por el VINVehiculo
                OpportunityLineItem opportunityProduct = [SELECT Id, Name FROM OpportunityLineItem WHERE VinProduct2__c = :vinVehiculo AND OpportunityId = :opportunity.Id LIMIT 1];

                if (opportunityProduct != null) {
                    // Actualizar los campos FechaDeFacturación y Estado del producto de oportunidad
                    opportunityProduct.FechaDeFacturacion__c = Date.valueOf(fechaFacturacion);
                    opportunityProduct.Estado__c = estado;
                    
                    // Guardar los cambios
                    update opportunityProduct;
                    res.responseBody = Blob.valueOf('{"message": "Actualización realizada con éxito"}');
                    res.statusCode = 200;
                } else {
                    res.responseBody = Blob.valueOf('{"message": "No se encontró ningún producto de oportunidad con el VINVehiculo especificado."}');
                    res.statusCode = 404;
                }
            } else {
                res.responseBody = Blob.valueOf('{"message": "No se encontró ninguna oportunidad con el OpportunityId especificado."}');
                res.statusCode = 404;
            }
        } catch (Exception e) {
            res.responseBody = Blob.valueOf('{"message": "Ocurrió un error en el proceso: ' + e.getMessage() + '"}');
            res.statusCode = 500;
        }
    }
    
    public class actualizarFacturacionRequest {
        public String OpportunityId;
        public String FechaDeFacturacion;
        public String VINVehiculo;
        public String Estado;
    }
    
    public static actualizarFacturacionRequest parseRespuesta(String json) {
        return(actualizarFacturacionRequest) System.JSON.deserialize(json, actualizarFacturacionRequest.class);
    }
    
}