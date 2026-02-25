@RestResource(urlMapping='/encuesta/servicio')
global with sharing class ServicioEncuestaDeServicio {

    // Input structure expected from request
    global class EncuestaInput {
        public String CaseNumber;
        public String ComentariosServicio;
        public String MarcaVehiculo;
        public String MotivoPuntuacionServicio;
        public String PosibilidadMejorarServicio;
        public String ProbabilidadRecomendacionServicio;
        public String Servicio;
    }

    // Response wrapper structure
    global class APIResponse {
        public Integer statusCode;
        public String status;
        public String message;
        public String errorCode;
        public Id encuestaId;

        public APIResponse(Integer code, String stat, String msg, String errCode, Id idVal) {
            statusCode = code;
            status = stat;
            message = msg;
            errorCode = errCode;
            encuestaId = idVal;
        }
    }

    @HttpPost
    global static void insertarEncuesta() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            EncuestaInput input = (EncuestaInput)JSON.deserialize(req.requestBody.toString(), EncuestaInput.class);

            // Validación: CaseNumber requerido
            if (String.isBlank(input.CaseNumber)) {
                sendErrorResponse(res, 400, 'BAD_REQUEST', 'El campo "CaseNumber" es obligatorio.', 'ERR_MISSING_CASENUMBER');
                return;
            }

            // Buscar caso por CaseNumber
            List<Case> casos = [SELECT Id FROM Case WHERE CaseNumber = :input.CaseNumber LIMIT 1];
            if (casos.isEmpty()) {
                sendErrorResponse(res, 404, 'NOT_FOUND', 'No se encontró ningún caso con el CaseNumber proporcionado.', 'ERR_CASE_NOT_FOUND');
                return;
            }

            // Crear registro de encuesta
            Encuesta_de_servicio__c encuesta = new Encuesta_de_servicio__c(
                Case__c = casos[0].Id,
                Comentarios_servicio__c = input.ComentariosServicio,
                Marca_veh_culo__c = input.MarcaVehiculo,
                Motivo_de_puntuaci_n_de_servicio__c = input.MotivoPuntuacionServicio,
                Posibilidad_de_mejorar_servicio__c = input.PosibilidadMejorarServicio,
                Probabilidad_recomendaci_n_de_servicio__c = input.ProbabilidadRecomendacionServicio,
                Servicio__c = input.Servicio
            );

            insert encuesta;

            APIResponse response = new APIResponse(201, 'CREATED', 'Encuesta insertada correctamente.', null, encuesta.Id);
            res.statusCode = 201;
            res.responseBody = Blob.valueOf(JSON.serialize(response));

        } catch (JSONException e) {
            sendErrorResponse(res, 400, 'BAD_REQUEST', 'Error de formato JSON: ' + e.getMessage(), 'ERR_INVALID_JSON');
        } catch (DmlException e) {
            sendErrorResponse(res, 500, 'INTERNAL_ERROR', 'Error al insertar la encuesta: ' + e.getMessage(), 'ERR_DML');
        } catch (Exception e) {
            sendErrorResponse(res, 500, 'INTERNAL_ERROR', 'Error inesperado: ' + e.getMessage(), 'ERR_UNKNOWN');
        }
    }

    // Método reutilizable para errores
    private static void sendErrorResponse(RestResponse res, Integer code, String status, String message, String errorCode) {
        APIResponse errorResponse = new APIResponse(code, status, message, errorCode, null);
        res.statusCode = code;
        res.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
    }
}