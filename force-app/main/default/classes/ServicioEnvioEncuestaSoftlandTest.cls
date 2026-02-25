@IsTest
private class ServicioEnvioEncuestaSoftlandTest {

    // Mock sencillo para los callouts HTTP
    private class SimpleHttpMock implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;

        SimpleHttpMock(Integer statusCode, String responseBody) {
            this.statusCode   = statusCode;
            this.responseBody = responseBody;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            return res;
        }
    }

    // ========== OPORTUNIDAD EXITOSA (code = '00') ==========
    @IsTest
    static void testEnviarEncuesta_Opportunity_Success() {
        Opportunity opp = new Opportunity(
            Name      = 'Test Opp',
            StageName = 'Prospecting',   // ajusta si tu org tiene otras etapas obligatorias
            CloseDate = Date.today()
        );
        insert opp;

        String okJson = '{"operationResult":{"code":"00","description":"Mensaje enviado exitosamente"}}';

        Test.setMock(HttpCalloutMock.class, new SimpleHttpMock(200, okJson));

        ServicioEnvioEncuestaSoftland.FlowRequest req =
            new ServicioEnvioEncuestaSoftland.FlowRequest();
        req.recordId  = opp.Id;
        req.compania  = null; // para que use RMBAVARIAN por default
        req.phone     = '88889999';
        req.VIN       = 'VIN-TEST';
        req.OppNumber = 'OPP-0001';

        Test.startTest();
        List<ServicioEnvioEncuestaSoftland.FlowResponse> respList =
            ServicioEnvioEncuestaSoftland.enviarEncuesta(
                new List<ServicioEnvioEncuestaSoftland.FlowRequest>{ req }
            );
        Test.stopTest();

        System.assertEquals(1, respList.size());
        ServicioEnvioEncuestaSoftland.FlowResponse resp = respList[0];

        System.assertEquals(true, resp.success);
        System.assertEquals('00', resp.code);
        System.assertEquals(200, resp.httpStatus);
        System.assertEquals(null, resp.errorMessage);
    }

    // ========== WORK ORDER code != '00' ==========
    @IsTest
    static void testEnviarEncuesta_WorkOrder_CodeNotOk() {
        Account acc = new Account(Name = 'Cuenta Test');
        insert acc;

        WorkOrder wo = new WorkOrder(
            Subject   = 'WO Test',
            Status    = 'New',         // ajusta si tu org usa otros valores
            AccountId = acc.Id
        );
        insert wo;

        String failJson = '{"operationResult":{"code":"01","description":"Algo pasó"}}';
        Test.setMock(HttpCalloutMock.class, new SimpleHttpMock(200, failJson));

        ServicioEnvioEncuestaSoftland.FlowRequest req =
            new ServicioEnvioEncuestaSoftland.FlowRequest();
        req.recordId = wo.Id;
        req.compania = 'MI_COMPANIA';
        req.WoNumber = 'WO-0001';

        Test.startTest();
        List<ServicioEnvioEncuestaSoftland.FlowResponse> respList =
            ServicioEnvioEncuestaSoftland.enviarEncuesta(
                new List<ServicioEnvioEncuestaSoftland.FlowRequest>{ req }
            );
        Test.stopTest();

        System.assertEquals(1, respList.size());
        ServicioEnvioEncuestaSoftland.FlowResponse resp = respList[0];

        System.assertEquals(false, resp.success, 'Si code != 00, success debe ser false');
        System.assertEquals('01', resp.code);
        System.assertEquals(200, resp.httpStatus);
        System.assertEquals(null, resp.errorMessage);
    }

    // ========== ERROR HTTP (500) ==========
    @IsTest
    static void testEnviarEncuesta_HttpError() {
        Opportunity opp = new Opportunity(
            Name      = 'Opp Error',
            StageName = 'Prospecting',
            CloseDate = Date.today()
        );
        insert opp;

        Test.setMock(HttpCalloutMock.class, new SimpleHttpMock(500, 'Internal Server Error'));

        ServicioEnvioEncuestaSoftland.FlowRequest req =
            new ServicioEnvioEncuestaSoftland.FlowRequest();
        req.recordId  = opp.Id;
        req.OppNumber = 'OPP-ERROR';
        req.phone     = '1234';
        req.VIN       = 'VIN-ERROR';

        Test.startTest();
        List<ServicioEnvioEncuestaSoftland.FlowResponse> respList =
            ServicioEnvioEncuestaSoftland.enviarEncuesta(
                new List<ServicioEnvioEncuestaSoftland.FlowRequest>{ req }
            );
        Test.stopTest();

        System.assertEquals(1, respList.size());
        ServicioEnvioEncuestaSoftland.FlowResponse resp = respList[0];

        System.assertEquals(false, resp.success);
        System.assertEquals(500, resp.httpStatus);
        System.assert(
            resp.errorMessage != null &&
            resp.errorMessage.contains('Error HTTP al llamar Softland'),
            'Debe indicar error HTTP en el mensaje'
        );
    }

    // ========== TIPO DE OBJETO NO SOPORTADO ==========
    @IsTest
    static void testEnviarEncuesta_UnsupportedType() {
        Account acc = new Account(Name = 'Cuenta No Soportada');
        insert acc;

        ServicioEnvioEncuestaSoftland.FlowRequest req =
            new ServicioEnvioEncuestaSoftland.FlowRequest();
        req.recordId = acc.Id;

        Test.startTest();
        List<ServicioEnvioEncuestaSoftland.FlowResponse> respList =
            ServicioEnvioEncuestaSoftland.enviarEncuesta(
                new List<ServicioEnvioEncuestaSoftland.FlowRequest>{ req }
            );
        Test.stopTest();

        System.assertEquals(1, respList.size());
        ServicioEnvioEncuestaSoftland.FlowResponse resp = respList[0];

        System.assertEquals(false, resp.success);
        System.assert(
            resp.errorMessage != null &&
            resp.errorMessage.contains('El Id no corresponde a Opportunity ni WorkOrder'),
            'Debe indicar que el tipo no es soportado'
        );
    }

    // ========== RECORD ID NULO ==========
    @IsTest
    static void testEnviarEncuesta_RecordIdNull() {
        ServicioEnvioEncuestaSoftland.FlowRequest req =
            new ServicioEnvioEncuestaSoftland.FlowRequest();
        req.recordId = null;

        Test.startTest();
        List<ServicioEnvioEncuestaSoftland.FlowResponse> respList =
            ServicioEnvioEncuestaSoftland.enviarEncuesta(
                new List<ServicioEnvioEncuestaSoftland.FlowRequest>{ req }
            );
        Test.stopTest();

        System.assertEquals(1, respList.size());
        ServicioEnvioEncuestaSoftland.FlowResponse resp = respList[0];

        System.assertEquals(false, resp.success);
        System.assertEquals('No se recibió recordId en la petición.', resp.errorMessage);
    }
}