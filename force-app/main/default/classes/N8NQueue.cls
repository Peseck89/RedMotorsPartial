public with sharing class N8NQueue implements Queueable, Database.AllowsCallouts {

    private final List<Id> recordIds;
    public N8NQueue(List<Id> recordIds){
        this.recordIds = recordIds;
    }

    public void execute(QueueableContext qc){
        System.debug(' [N8NQueue] Iniciando ejecución del Queueable. recordIds=' + recordIds);

        List<N8N__c> toProcess = [
            SELECT Id, Id__c, Endpoint__c, Servicio_Alterno__c,
                   X1__c, X2__c, X3__c, X4__c, X5__c, X6__c, X7__c, X8__c, X9__c, X10__c,
                   X11_c__c, X12_c__c, X13_c__c,
                   Respuesta__c
            FROM N8N__c
            WHERE Id IN :recordIds AND Endpoint__c != null
        ];

        System.debug(' [N8NQueue] Registros encontrados para procesar: ' + toProcess.size());

        if (toProcess.isEmpty()) {
            System.debug(' [N8NQueue] No hay registros con Endpoint__c para procesar. Terminando.');
            return;
        }

        Http http = new Http();
        List<N8N__c> toUpdate = new List<N8N__c>();

        for (N8N__c rec : toProcess) {
            System.debug(' [N8NQueue] Procesando registro: Id=' + rec.Id + ' | Id__c=' + rec.Id__c + ' | Endpoint=' + rec.Endpoint__c);
            try {
                // ===== Construcción del JSON (normal vs alterno) =====
                String idToUse = String.isBlank(rec.Id__c) ? (String)rec.Id : rec.Id__c;
                Map<String, Object> body = new Map<String, Object>();

                if (rec.Servicio_Alterno__c == true) {
                    System.debug(' [N8NQueue] Servicio_Alterno__c=TRUE. Usando estructura JSON alterna.');

                    body.put('id', idToUse); // usa Id__c si viene, si no el Id de SF
                    body.put('channel', 'meta_wa');
                    body.put('webhook_password', rec.X10__c);

                    // variables: solo "1": X1__c
                    Map<String, Object> variablesAlt = new Map<String, Object>{
                        '1' => rec.X1__c
                    };
                    body.put('variables', variablesAlt);

                    // custom_values (mapeo solicitado)
                    Map<String, Object> customValuesAlt = new Map<String, Object>{
                        'FirstName' => rec.X1__c,
                        'LastName' => rec.X2__c,
                        'Tipotrafico' => rec.X3__c,
                        'FechaPosibleCompra' => rec.X4__c,
                        'Sucursal' => rec.X5__c,
                        'Familia1' => rec.X6__c,
                        // Mantengo exactamente el nombre de clave que enviaste:
                        'Modelo_De_Inter_s1' => rec.X7__c,
                        'Ano1' => rec.X8__c,
                        'Email' => rec.X9__c,
                        'salesforceId' => rec.X11_c__c,
                        'SFLeadAssigneeEmail' => rec.X12_c__c,
                        'stage_name' => rec.X13_c__c
                    };
                    body.put('custom_values', customValuesAlt);

                } else {
                    System.debug(' [N8NQueue] Servicio_Alterno__c=NULL/FALSE. Usando estructura JSON original.');

                    body.put('id', idToUse);
                    body.put('channel', 'meta_wa');
                    body.put('webhook_password', rec.X10__c);

                    Map<String, Object> variables = new Map<String, Object>{
                        '1' => rec.X1__c,
                        '2' => rec.X2__c,
                        '3' => rec.X3__c,
                        '4' => rec.X4__c,
                        '5' => rec.X5__c,
                        '6' => rec.X6__c,
                        '7' => rec.X7__c
                    };
                    body.put('variables', variables);

                    Map<String, Object> customValues = new Map<String, Object>{
                        'email' => rec.X8__c,
                        'salesforceId' => rec.X9__c
                    };
                    body.put('custom_values', customValues);
                }

                String bodyJson = JSON.serialize(body);
                System.debug(' [N8NQueue] JSON que se enviará para registro ' + rec.Id + ': ' + bodyJson);

                // ===== Request =====
                HttpRequest req = new HttpRequest();
                req.setEndpoint(rec.Endpoint__c);
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setBody(bodyJson);

                System.debug(' [N8NQueue] Enviando POST a Endpoint=' + rec.Endpoint__c);

                HttpResponse res = http.send(req);

                System.debug(' [N8NQueue] Respuesta HTTP para registro ' + rec.Id + ': Status=' + res.getStatusCode() + ' Body=' + res.getBody());

                // Guardar SOLO 255 chars en Respuesta__c
                String resp = res.getBody();
                if (resp != null && resp.length() > 255) {
                    System.debug(' [N8NQueue] Respuesta >255 chars. Truncando...');
                    resp = resp.substring(0, 255);
                }

                toUpdate.add(new N8N__c(
                    Id = rec.Id,
                    Respuesta__c = resp
                ));

            } catch (Exception e) {
                String err = 'Error: ' + e.getMessage();
                if (err.length() > 255) err = err.substring(0, 255);

                System.debug(' [N8NQueue] Error procesando registro ' + rec.Id + ': ' + e.getMessage() + '\nStack: ' + e.getStackTraceString());

                toUpdate.add(new N8N__c(
                    Id = rec.Id,
                    Respuesta__c = err
                ));
            }
        }

        if (!toUpdate.isEmpty()) {
            System.debug(' [N8NQueue] Actualizando ' + toUpdate.size() + ' registros con la respuesta.');
            update toUpdate;
            System.debug(' [N8NQueue] Actualización completada.');
        } else {
            System.debug(' ️[N8NQueue] No hay registros para actualizar.');
        }

        System.debug(' [N8NQueue] Ejecución finalizada.');
    }
}