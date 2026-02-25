@IsTest(seeAllData=false)
private class N8N_Test {

    // ====== Mock para callouts (soporta JSON original y alterno) ======
    private class N8NMock implements HttpCalloutMock {
        // Valores esperados
        private final String expectedId;
        private final String expectedWebhookPassword;
        private final Map<String, String> expectedVars;           // variables -> valor
        private final Map<String, String> expectedCustomValues;   // custom_values -> valor
        private final String responseBody;
        private final Integer statusCode;

        N8NMock(
            String expectedId,
            String expectedWebhookPassword,
            Map<String, String> expectedVars,
            Map<String, String> expectedCustomValues,
            String responseBody,
            Integer statusCode
        ){
            this.expectedId = expectedId;
            this.expectedWebhookPassword = expectedWebhookPassword;
            this.expectedVars = expectedVars == null ? new Map<String,String>() : expectedVars;
            this.expectedCustomValues = expectedCustomValues == null ? new Map<String,String>() : expectedCustomValues;
            this.responseBody = responseBody;
            this.statusCode = statusCode == null ? 200 : statusCode;
        }

        public HTTPResponse respond(HTTPRequest req){
            // Validar método y header
            System.assertEquals('POST', req.getMethod(), 'El método HTTP debe ser POST');
            System.assertEquals('application/json', req.getHeader('Content-Type'), 'Content-Type debe ser JSON');

            // Validar payload JSON
            Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(req.getBody());
            System.assertNotEquals(null, body, 'El cuerpo JSON no debe ser nulo');

            System.assertEquals('meta_wa', (String)body.get('channel'), 'channel debe ser meta_wa');
            // Si el test nos da un expectedId, lo validamos (si es null no validamos el id)
            if (expectedId != null) {
                System.assertEquals(expectedId, (String)body.get('id'), 'id enviado no coincide');
            }
            System.assertEquals(expectedWebhookPassword, (String)body.get('webhook_password'), 'webhook_password no coincide');

            // variables: validamos SOLO las claves esperadas
            Map<String, Object> vars = (Map<String, Object>) body.get('variables');
            System.assertNotEquals(null, vars, 'variables no debe ser nulo');
            for (String k : expectedVars.keySet()) {
                System.assert(vars.containsKey(k), 'variables debe contener la clave ' + k);
                System.assertEquals(expectedVars.get(k), (String)vars.get(k), 'Valor de variables[' + k + '] no coincide');
            }

            // custom_values: validamos SOLO las claves esperadas
            Map<String, Object> customValues = (Map<String, Object>) body.get('custom_values');
            System.assertNotEquals(null, customValues, 'custom_values no debe ser nulo');
            for (String k : expectedCustomValues.keySet()) {
                System.assert(customValues.containsKey(k), 'custom_values debe contener la clave ' + k);
                System.assertEquals(expectedCustomValues.get(k), (String)customValues.get(k), 'Valor de custom_values[' + k + '] no coincide');
            }

            // Respuesta simulada
            HttpResponse res = new HttpResponse();
            res.setStatusCode(this.statusCode);
            res.setBody(this.responseBody);
            return res;
        }
    }

    // ========== TEST 1: JSON ORIGINAL - Envía y guarda respuesta ==========
    @IsTest
    static void testSendAndStoreRespuesta_original(){
        // Datos de prueba (Servicio_Alterno__c null/false)
        N8N__c rec = new N8N__c();
        rec.Endpoint__c = 'https://example.com/webhook';
        rec.Id__c = 'cust-001'; // Forzar uso de Id__c
        rec.X1__c = 'v1';
        rec.X2__c = 'v2';
        rec.X3__c = 'v3';
        rec.X4__c = 'v4';
        rec.X5__c = 'v5';
        rec.X6__c = 'v6';
        rec.X7__c = 'v7';
        rec.X8__c = 'mail@example.com'; // email (JSON original)
        rec.X9__c = 'SF-123';           // salesforceId (JSON original)
        rec.X10__c = 'secret-xyz';

        // Esperados para JSON ORIGINAL
        Map<String,String> expectedVars = new Map<String,String>{
            '1' => 'v1', '2' => 'v2', '3' => 'v3',
            '4' => 'v4', '5' => 'v5', '6' => 'v6', '7' => 'v7'
        };
        Map<String,String> expectedCustom = new Map<String,String>{
            'email' => 'mail@example.com',
            'salesforceId' => 'SF-123'
        };

        Test.setMock(HttpCalloutMock.class,
            new N8NMock(
                'cust-001',          // expectedId (Id__c)
                'secret-xyz',        // expectedWebhookPassword
                expectedVars,        // variables 1..7
                expectedCustom,      // custom_values: email + salesforceId
                'OK-BODY',           // response body
                200                  // status code
            )
        );

        Test.startTest();
        insert rec;                  // (Se asume trigger que encola el Queueable)
        Test.stopTest();             // Ejecuta el queueable

        // Verificar que se guardó la respuesta
        N8N__c stored = [SELECT Id, Respuesta__c FROM N8N__c WHERE Id = :rec.Id LIMIT 1];
        System.assertEquals('OK-BODY', stored.Respuesta__c, 'Respuesta__c debe contener el body de la respuesta');
    }

    // ========== TEST 2: JSON ORIGINAL - Truncamiento de respuesta larga (255) ==========
    @IsTest
    static void testLongResponseTruncated_original(){
        String longBody = String.valueOf('A').repeat(600);

        N8N__c rec = new N8N__c(
            Endpoint__c = 'https://example.com/webhook',
            X10__c = 'pw',
            X8__c = 'x@y.z',
            X9__c = 'SF-9',
            X1__c = 'a', X2__c = 'b', X3__c = 'c', X4__c = 'd', X5__c = 'e', X6__c = 'f', X7__c = 'g'
        );

        Map<String,String> expectedVars = new Map<String,String>{
            '1' => 'a', '2' => 'b', '3' => 'c',
            '4' => 'd', '5' => 'e', '6' => 'f', '7' => 'g'
        };
        Map<String,String> expectedCustom = new Map<String,String>{
            'email' => 'x@y.z',
            'salesforceId' => 'SF-9'
        };

        Test.setMock(HttpCalloutMock.class,
            new N8NMock(
                null,          // expectedId -> si viene null no validamos el id (usa Id Salesforce)
                'pw',
                expectedVars,
                expectedCustom,
                longBody,
                200
            )
        );

        Test.startTest();
        insert rec;
        Test.stopTest();

        N8N__c stored = [SELECT Id, Respuesta__c FROM N8N__c WHERE Id = :rec.Id LIMIT 1];
        System.assertNotEquals(null, stored.Respuesta__c, 'Respuesta__c no debe ser nula');
        System.assert(stored.Respuesta__c.length() <= 255, 'Respuesta__c debe estar truncada a 255 caracteres');
        System.assertEquals(String.valueOf('A').repeat(255), stored.Respuesta__c, 'El truncamiento debe conservar los primeros 255 caracteres');
    }

    // ========== TEST 3: Registro sin Endpoint no debe actualizar ==========
    @IsTest
    static void testWithoutEndpointNoUpdate(){
        // Sin mock: no debe intentar callout si Endpoint__c es null
        N8N__c rec = new N8N__c(
            X1__c = 'x',
            X10__c = 'pw'
        );

        Test.startTest();
        insert rec;
        Test.stopTest();

        N8N__c stored = [SELECT Id, Respuesta__c FROM N8N__c WHERE Id = :rec.Id LIMIT 1];
        System.assertEquals(null, stored.Respuesta__c, 'No debe actualizar Respuesta__c si no hay Endpoint__c');
    }

    // ========== TEST 4: JSON ALTERNO - Servicio_Alterno__c = true ==========
    @IsTest
    static void testSendWithAlternateJSON(){
        // Datos con Servicio_Alterno__c TRUE
        N8N__c rec = new N8N__c();
        rec.Endpoint__c = 'https://example.com/webhook';
        rec.Id__c = 'cust-ALT';
        rec.Servicio_Alterno__c = true;

        // Variables mapeadas
        rec.X1__c = 'Diego';          // FirstName y variables["1"]
        rec.X2__c = 'Vasquez';        // LastName
        rec.X3__c = 'Orgánico';       // Tipotrafico
        rec.X4__c = '2025-12-01';     // FechaPosibleCompra
        rec.X5__c = 'Pinares';        // Sucursal
        rec.X6__c = 'Motos';          // Familia1
        rec.X7__c = 'CB300R';         // Modelo_De_Inter_s1
        rec.X8__c = '2024';           // Ano1
        rec.X9__c = 'diego@ejemplo.com'; // Email
        rec.X10__c = 'pw-alterno';    // webhook_password
        rec.X11_c__c = 'SF-LEAD-999';   // salesforceId (alterno)
        rec.X12_c__c = 'asesor@empresa.com'; // SFLeadAssigneeEmail

        // Esperados para JSON ALTERNO
        Map<String,String> expectedVars = new Map<String,String>{
            '1' => 'Diego' // solo clave "1"
        };
        Map<String,String> expectedCustom = new Map<String,String>{
            'FirstName' => 'Diego',
            'LastName' => 'Vasquez',
            'Tipotrafico' => 'Orgánico',
            'FechaPosibleCompra' => '2025-12-01',
            'Sucursal' => 'Pinares',
            'Familia1' => 'Motos',
            'Modelo_De_Inter_s1' => 'CB300R',
            'Ano1' => '2024',
            'Email' => 'diego@ejemplo.com',
            'salesforceId' => 'SF-LEAD-999',
            'SFLeadAssigneeEmail' => 'asesor@empresa.com'
        };

        Test.setMock(HttpCalloutMock.class,
            new N8NMock(
                'cust-ALT',        // expectedId (Id__c)
                'pw-alterno',      // expectedWebhookPassword
                expectedVars,      // variables: solo "1"
                expectedCustom,    // custom_values segun alterno
                'OK-ALT',          // response body
                200
            )
        );

        Test.startTest();
        insert rec;   // Se asume el trigger pone en cola el Queueable
        Test.stopTest();

        N8N__c stored = [SELECT Id, Respuesta__c FROM N8N__c WHERE Id = :rec.Id LIMIT 1];
        System.assertEquals('OK-ALT', stored.Respuesta__c, 'Respuesta__c debe contener el body de la respuesta (alterno)');
    }
}