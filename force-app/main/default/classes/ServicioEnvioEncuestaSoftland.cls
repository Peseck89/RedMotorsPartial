public with sharing class ServicioEnvioEncuestaSoftland {

    // ====== CONSTANTES URL DIRECTA (SIN NAMED CREDENTIAL) ======
    // Mismo esquema que ServicioReservaApartadoArticulos
    private static final String SERVICE_BASE_URL = 'http://172.176.136.132:5080';

    //'/ServiciosSoftlandProductivos/softlandAPI/reserve/sendSurvey'
    private static final String ENDPOINT_OPP = '/ServiciosSoftlandProductivos/softlandAPI/Opportunities/sendSurvey';
    
    private static final String ENDPOINT_WO  = '/ServiciosSoftlandProductivos/softlandAPI/reserve/sendSurvey';

    // ====== Clases para Flow (entrada / salida) ======
    public class FlowRequest {
        @InvocableVariable(required=true)
        public Id recordId;          // Puede ser Opportunity o WorkOrder

        @InvocableVariable
        public String compania;      // Opcional, default "RMBAVARIAN"
        
        @InvocableVariable
        public String phone; 
        
        @InvocableVariable
        public String VIN;
        
        @InvocableVariable
        public String OppNumber;
        
        @InvocableVariable
        public String WoNumber; 
    }

    public class FlowResponse {
        @InvocableVariable
        public Boolean success;

        @InvocableVariable
        public String code;

        @InvocableVariable
        public String description;

        @InvocableVariable
        public Integer httpStatus;

        @InvocableVariable
        public String errorMessage;

        @InvocableVariable
        public String rawResponse;
    }

    // ====== DTO para la respuesta de Softland ======
    public class SoftlandSurveyResponse {
        public OperationResult operationResult;
    }

    public class OperationResult {
        public String code;
        public String description;
    }

    // ====== MÉTODO INVOCABLE PARA FLOW ======
    @InvocableMethod(
        label='Enviar encuesta Softland'
        description='Envía una encuesta a Softland para Oportunidad u Orden de trabajo según el Id enviado.'
        category='Softland'
    )
    public static List<FlowResponse> enviarEncuesta(List<FlowRequest> requests){
        List<FlowResponse> results = new List<FlowResponse>();

        for (FlowRequest req : requests) {
            FlowResponse resp = new FlowResponse();
            results.add(resp);

            if (req == null || req.recordId == null) {
                resp.success = false;
                resp.errorMessage = 'No se recibió recordId en la petición.';
                continue;
            }

            // Default de compañía
            String compania = String.isBlank(req.compania) ? 'RMBAVARIAN' : req.compania;

            try {
                // Detectar tipo de objeto según el Id
                String sObjectName = req.recordId.getSObjectType().getDescribe().getName();
                System.debug('### ServicioEnvioEncuestaSoftland - sObjectName: ' + sObjectName);

                String endpointPath;
                String bodyJson;

                if (sObjectName == 'Opportunity') {
                    endpointPath = ENDPOINT_OPP;
                    bodyJson = buildOpportunityPayload(
                        req.recordId,
                        compania,
                        req.phone,
                        req.OppNumber,
                        req.VIN
                    );
                } else if (sObjectName == 'WorkOrder') {
                    endpointPath = ENDPOINT_WO;
                    bodyJson = buildWorkOrderPayload(
                        req.recordId,
                        compania,   // usar el default también para WO
                        req.WoNumber
                    );
                } else {
                    resp.success = false;
                    resp.errorMessage = 'El Id no corresponde a Opportunity ni WorkOrder. Tipo: ' + sObjectName;
                    continue;
                }

                System.debug('### Endpoint: ' + endpointPath);
                System.debug('### Body JSON: ' + bodyJson);

                // Callout HTTP POST (SIN NAMED CREDENTIAL)
                HttpRequest httpReq = new HttpRequest();
                httpReq.setMethod('POST');
                httpReq.setEndpoint(SERVICE_BASE_URL + endpointPath);
                httpReq.setHeader('Content-Type', 'application/json');

                if (!Test.isRunningTest()) {
                    // Reutilizamos el mismo esquema que tu otro servicio
                    String token = ExternalAuthService.authenticate();
                    httpReq.setHeader('Authorization', 'Bearer ' + token);
                }

                httpReq.setBody(bodyJson);

                Http http = new Http();
                HTTPResponse httpRes = http.send(httpReq);

                resp.httpStatus  = httpRes.getStatusCode();
                resp.rawResponse = httpRes.getBody();
                System.debug('### HTTP Status: ' + resp.httpStatus);
                System.debug('### HTTP Body: ' + resp.rawResponse);

                if (resp.httpStatus >= 200 && resp.httpStatus < 300 && !String.isBlank(resp.rawResponse)) {
                    // Parsear JSON de respuesta:
                    // {"operationResult":{"code":"00","description":"Mensaje enviado exitosamente"}}
                    SoftlandSurveyResponse sr =
                        (SoftlandSurveyResponse) JSON.deserialize(resp.rawResponse, SoftlandSurveyResponse.class);

                    if (sr != null && sr.operationResult != null) {
                        resp.code        = sr.operationResult.code;
                        resp.description = sr.operationResult.description;
                        resp.success     = (sr.operationResult.code == '00');
                    } else {
                        resp.success      = false;
                        resp.errorMessage = 'Respuesta de Softland sin operationResult.';
                    }
                } else {
                    resp.success      = false;
                    resp.errorMessage = 'Error HTTP al llamar Softland: ' + resp.httpStatus
                                        + ' - ' + resp.rawResponse;
                }

            } catch (Exception e) {
                resp.success      = false;
                resp.errorMessage = 'Excepción al enviar encuesta: '
                                    + e.getMessage() + ' | Linea: ' + e.getLineNumber();
                System.debug('### ERROR ServicioEnvioEncuestaSoftland: ' + e.getMessage());
                System.debug(e.getStackTraceString());
            }
        }

        return results;
    }

    // ====== Construcción de payload para Oportunidad ======
    private static String buildOpportunityPayload(
        Id oppId,
        String compania,
        String phone,
        String oppNumber,
        String VIN
    ){
        Map<String, Object> body = new Map<String, Object>();
        body.put('compania',    compania);
        body.put('vin',         VIN);
        body.put('oportunidad', oppNumber);
        body.put('telefono',    phone);

        return JSON.serialize(body);
    }

    // ====== Construcción de payload para Orden de Trabajo ======
    private static String buildWorkOrderPayload(
        Id woId,
        String compania,
        String woNumber
    ){
        Map<String, Object> body = new Map<String, Object>();
        body.put('compania',         compania);
        body.put('orden_salesforce', woNumber); // "00012345" en tu ejemplo

        return JSON.serialize(body);
    }
}