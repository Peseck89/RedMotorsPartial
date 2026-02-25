@RestResource(urlMapping='/ActualizaWOEncuesta')
global class ActualizaWorkOrderEncuesta {

    @HttpPost
    global static String actualizaWOEncuesta() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        Map<String, Object> requestPayload = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
        List<Encuesta__c> encuestasToInsert = new List<Encuesta__c>();
        List<Respuesta__c> respuestasToInsert = new List<Respuesta__c>();
        
        List<Object> encuestasList = (List<Object>) requestPayload.get('encuestas');
        for(Object encuestaObj : encuestasList) {
            Map<String, Object> encuesta = (Map<String, Object>) encuestaObj;
            String ConsecutivoWorkOrder = (String) encuesta.get('ConsecutivoWorkOrder');

            List<WorkOrder> workOrders = [SELECT Id FROM WorkOrder WHERE WorkOrderNumber = :ConsecutivoWorkOrder LIMIT 1];

            if (workOrders.isEmpty()) {
                return 'Error: No encontró la Work Order';
            }
            
            WorkOrder wo = workOrders[0];
            
            Encuesta__c encuestaNueva = new Encuesta__c(
                WorkOrder__c = wo.Id,
                Name = (String) encuesta.get('nombre')
            );
            
            encuestasToInsert.add(encuestaNueva);

            List<Object> respuestasList = (List<Object>) encuesta.get('repuestas');
            for(Object respuestaObj : respuestasList) {
                Map<String, Object> respuesta = (Map<String, Object>) respuestaObj;
                String pregunta = (String) respuesta.get('pregunta');
                String valorRespuesta = (String) respuesta.get('respuesta');
                String tipo = (String) respuesta.get('tipo');

                // Aquí puedes continuar procesando las respuestas y asociarlas con la encuesta y la Work Order.
                // Dependiendo de tu estructura de base de datos, podrías guardar estas respuestas en registros relacionados.
            }
            
            for(Object respuestaObj : respuestasList) {
                Map<String, Object> respuesta = (Map<String, Object>) respuestaObj;
                String pregunta = (String) respuesta.get('pregunta');
                String valorRespuesta = (String) respuesta.get('respuesta');
                String tipo = (String) respuesta.get('tipo');
                
                Respuesta__c respuestaNueva = new Respuesta__c(
                    //Encuesta__c = encuesta.Id, // Esto se asignará después de insertar la encuesta
                    Pregunta__c = pregunta,
                    Respuesta__c = valorRespuesta,
                    Tipo__c = tipo
                );
                respuestasToInsert.add(respuestaNueva);
            }
            
			}            
            

            try {
            insert encuestasToInsert;
            
            // Asignando el ID de la encuesta a las respuestas después de insertarlas.
            for (Respuesta__c respuesta : respuestasToInsert) {
                respuesta.Encuesta__c = encuestasToInsert[0].Id; // Esto es una suposición simplificada. Ajusta según lo necesario.
            }
            
            insert respuestasToInsert;
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }

        return 'WorkOrder y Encuestas actualizadas con éxito';
    }
}