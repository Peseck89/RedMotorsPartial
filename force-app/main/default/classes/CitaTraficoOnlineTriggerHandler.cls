public with sharing class CitaTraficoOnlineTriggerHandler {

    private static final String ENDPOINT = 'https://console.chathub.ai/api/webhook/workflow/trigger-automation?botId=147&workflowName=despues_del_formulario_de_visita&workflowId=1182&type=chat';
    private static final String WEBHOOK_PASSWORD = 'O!na#3E*OA';
    // TEMPORAL - Quitar después de pruebas
    private static final String ADMIN_TEST_USER_ID = '0054U000009i0CoQAI';
    private static final String ADMIN_TEST_EMAIL = 'antonio.dorantesperez@outlook.com';
    private static final String ORG_BASE_URL = 'https://redmotors.lightning.force.com/lightning/r/Cita_trafico_online__c/';
    private static final String OPP_BASE_URL = 'https://redmotors.lightning.force.com/lightning/r/Opportunity/';


    // TEMPORAL - Agregar destinatarios de prueba
    private static Set<String> agregarDestinatariosPrueba(Set<String> destinatarios) {
        destinatarios.add(ADMIN_TEST_USER_ID);
        return destinatarios;
    }

    private static String buildCitaLink(String citaId) {
        return ORG_BASE_URL + citaId + '/view';
    }

    private static List<Messaging.SingleEmailMessage> agregarEmailPrueba(List<Messaging.SingleEmailMessage> emails,String subject, String body) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{ ADMIN_TEST_EMAIL });
        email.setSubject('[TEST] ' + subject);
        if (body != null && (body.contains('<!DOCTYPE') || body.contains('<html'))) {
            email.setHtmlBody(body);
        } else {
            email.setPlainTextBody(body);
        }
        email.setSaveAsActivity(false);
        emails.add(email);
        return emails;
    }

    // =============================================
    // AFTER INSERT: N8N (WhatsApp) + Notificaciones nueva cita
    // =============================================
    public static void handleAfterInsert(List<Cita_trafico_online__c> newCitas) {

        Set<Id> citaIds = new Set<Id>();
        for (Cita_trafico_online__c c : newCitas) {
            citaIds.add(c.Id);
        }

        List<Cita_trafico_online__c> citas = [
            SELECT Id, Telefono__c, Sucursal__c, Inicio__c,
                   Trafico__c,
                   Trafico__r.Marca__c,
                   Trafico__r.FirstName,
                   Trafico__r.LastName,
                   Trafico__r.Modelo_De_Inter_s1__c,
                   OwnerId,
                   Owner.Name,
                   Owner.Phone,
                   Owner.Email,
                   Asesor_de_piso__c,
                   Asesor_de_piso__r.Name,
                   Asesor_de_piso__r.Email,
                   Notas_del_asesor__c
            FROM Cita_trafico_online__c
            WHERE Id IN :citaIds
        ];

        if (citas.isEmpty()) {
            return;
        }

        // --- N8N (WhatsApp al cliente) ---
        List<N8N__c> n8nRecords = new List<N8N__c>();

        for (Cita_trafico_online__c cita : citas) {
            if (String.isBlank(cita.Telefono__c)) {
                continue;
            }

            String marca = cita.Trafico__r != null ? cita.Trafico__r.Marca__c : '';
            String nombre = cita.Trafico__r != null ? cita.Trafico__r.FirstName : '';
            String modelo = cita.Trafico__r != null ? cita.Trafico__r.Modelo_De_Inter_s1__c : '';
            String sucursal = cita.Sucursal__c;
            String fecha = cita.Inicio__c != null ? cita.Inicio__c.format('dd/MM/yyyy HH:mm') : '';
            String nombreAsesor = cita.Owner.Name;
            String telefonoAsesor = cita.Owner.Phone;
            String correoAsesor = cita.Owner.Email;

            N8N__c n8n = new N8N__c();
            n8n.Id__c = cita.Telefono__c;
            n8n.Endpoint__c = ENDPOINT;
            n8n.Servicio_Alterno__c = false;
            n8n.X1__c = marca;                            // 1: Marca
            n8n.X2__c = nombre;                           // 2: Nombre
            n8n.X3__c = marca;                            // 3: Marca
            n8n.X4__c = sucursal;                         // 4: Sucursal
            n8n.X5__c = marca;                            // 5: Marca
            n8n.X6__c = modelo;                           // 6: Modelo
            n8n.X7__c = fecha;                            // 7: Fecha
            n8n.X8__c = correoAsesor;                     // 8: Correo Asesor
            n8n.X9__c = String.valueOf(cita.Id);          // 9: Id Cita SF
            n8n.X10__c = WEBHOOK_PASSWORD;                // webhook_password
            n8n.X11_c__c = marca;                         // 10: Marca
            n8n.X12_c__c = nombreAsesor;                  // 11: Nombre Asesor
            n8n.X13_c__c = telefonoAsesor;               // 12: Teléfono Asesor

            n8nRecords.add(n8n);
        }

        if (!n8nRecords.isEmpty()) {
            insert n8nRecords;
            List<Id> n8nIds = new List<Id>();
            for (N8N__c n : n8nRecords) {
                n8nIds.add(n.Id);
            }
            System.enqueueJob(new N8NQueue(n8nIds));
        }

        // --- Notificaciones nueva cita (campanita + email) ---
        notificarNuevaCita(citas);

    }

    
    // =============================================
    // AFTER UPDATE: Notificaciones Asistió, Cancelada, Reprogramada
    // =============================================
    public static void handleAfterUpdate(List<Cita_trafico_online__c> newCitas, Map<Id, Cita_trafico_online__c> oldMap) {

        Set<Id> citasAsistio = new Set<Id>();
        Set<Id> citasCancelada = new Set<Id>();
        Set<Id> citasReprogramada = new Set<Id>();
        Set<Id> citasCambioOwner = new Set<Id>();

        for (Cita_trafico_online__c cita : newCitas) {
            Cita_trafico_online__c old = oldMap.get(cita.Id);
            if (cita.Status__c != old.Status__c) {
                if (cita.Status__c == 'Asistió') {
                    citasAsistio.add(cita.Id);
                } else if (cita.Status__c == 'Cancelada') {
                    citasCancelada.add(cita.Id);
                } else if (cita.Status__c == 'Reprogramada') {
                    citasReprogramada.add(cita.Id);
                }
            }
            if (cita.OwnerId != old.OwnerId) {
                citasCambioOwner.add(cita.Id);

                // Aquí tu lógica (notificar, reasignar, etc.)
            }
        }

         if (!citasCambioOwner.isEmpty()) {

            List<Cita_trafico_online__c> citasOwnerChanged = [
                SELECT Id, Sucursal__c, Inicio__c,
                    Trafico__c,
                    Trafico__r.FirstName,
                    Trafico__r.LastName,
                    Trafico__r.Modelo_De_Inter_s1__c,
                    OwnerId,
                    Owner.Name,
                    Owner.Email,
                    Owner.Phone
                FROM Cita_trafico_online__c
                WHERE Id IN :citasCambioOwner
            ];

            // Obtener Opportunities
            Set<Id> traficoIds = new Set<Id>();
            for (Cita_trafico_online__c c : citasOwnerChanged) {
                if (c.Trafico__c != null) {
                    traficoIds.add(c.Trafico__c);
                }
            }

            Map<Id, Id> traficoToOpp = new Map<Id, Id>();

            if (!traficoIds.isEmpty()) {
                for (Registro_WalkIn__c w : [
                    SELECT Trafico__c, Opportunity__c
                    FROM Registro_WalkIn__c
                    WHERE Trafico__c IN :traficoIds
                    AND Opportunity__c != null
                    ORDER BY CreatedDate DESC
                ]) {
                    if (!traficoToOpp.containsKey(w.Trafico__c)) {
                        traficoToOpp.put(w.Trafico__c, w.Opportunity__c);
                    }
                }
            }

            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

            for (Cita_trafico_online__c cita : citasOwnerChanged) {

                if (cita.Owner.Email == null) continue;

                String nombreLead = buildNombreLead(cita);
                String modelo = cita.Trafico__r != null ? cita.Trafico__r.Modelo_De_Inter_s1__c : '';
                String sucursal = cita.Sucursal__c != null ? cita.Sucursal__c : '';
                String fecha = cita.Inicio__c != null ? cita.Inicio__c.format('dd/MM/yyyy HH:mm') : '';

                Id oppId = traficoToOpp.get(cita.Trafico__c);

                // 🔘 Botón SOLO de Opportunity
                List<String> botones = new List<String>();

                if (oppId != null) {
                    botones.add(
                        buildBoton(OPP_BASE_URL + oppId + '/view', 'Ver Oportunidad', '#28a745')
                    );
                }

                String contenido = 
                    'El Check-In del lead <strong>' + nombreLead + '</strong> ha sido completado.<br><br>' +
                    '&bull; Fecha: ' + fecha + '<br>' +
                    '&bull; Modelo: ' + modelo + '<br>' +
                    '&bull; Sucursal: ' + sucursal + '<br>';

                String htmlBody = buildHtmlEmail(
                    cita.Owner.Name,
                    'Check-In Completado',
                    contenido,
                    cita.Owner.Name,
                    cita.Owner.Email,
                    cita.Owner.Phone,
                    botones
                );

                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new List<String>{ cita.Owner.Email });
                email.setSubject('Check-In Completado');
                email.setHtmlBody(htmlBody);
                email.setSaveAsActivity(false);

                emails.add(email);

                // 👇 opcional tu email de prueba
                agregarEmailPrueba(emails, 'Check-In Completado', htmlBody);
            }

            if (!emails.isEmpty()) {
                Messaging.sendEmail(emails);
            }
        }

        // Consolidar todos los Ids para un solo query
        Set<Id> allIds = new Set<Id>();
        allIds.addAll(citasAsistio);
        allIds.addAll(citasCancelada);
        allIds.addAll(citasReprogramada);

        if (allIds.isEmpty()) {
            return;
        }

        List<Cita_trafico_online__c> citas = [
            SELECT Id, Sucursal__c, Inicio__c, Status__c,
                Trafico__c,
                Trafico__r.FirstName,
                Trafico__r.LastName,
                Trafico__r.Modelo_De_Inter_s1__c,
                OwnerId,
                Owner.Name,
                Owner.Email,
                Owner.Phone,
                Asesor_de_piso__c,
                Asesor_de_piso__r.Name,
                Asesor_de_piso__r.Email,
                Notas_del_asesor__c
            FROM Cita_trafico_online__c
            WHERE Id IN :allIds
        ];

       

        if (citas.isEmpty()) return;

        // Separar por tipo
        List<Cita_trafico_online__c> listAsistio = new List<Cita_trafico_online__c>();
        List<Cita_trafico_online__c> listCancelada = new List<Cita_trafico_online__c>();
        List<Cita_trafico_online__c> listReprogramada = new List<Cita_trafico_online__c>();

        for (Cita_trafico_online__c c : citas) {
            if (citasAsistio.contains(c.Id)) listAsistio.add(c);
            if (citasCancelada.contains(c.Id)) listCancelada.add(c);
            if (citasReprogramada.contains(c.Id)) listReprogramada.add(c);
        }

        if (!listAsistio.isEmpty()) notificarVisitaCompletada(listAsistio);
        if (!listCancelada.isEmpty()) notificarCambioStatus(listCancelada, 'Cancelada');
        if (!listReprogramada.isEmpty()) notificarCambioStatus(listReprogramada, 'Reprogramada');

        

    }


    private static String buildHtmlEmail(String nombreDestinatario, String titulo, String contenido, 
                                        String ownerName, String ownerEmail, String ownerPhone,
                                        List<String> botones) {
        String botonesHtml = '';
        if (botones != null) {
            for (String btn : botones) {
                botonesHtml += btn;
            }
        }

        return '<!DOCTYPE html>' +
            '<html dir="ltr" xmlns="http://www.w3.org/1999/xhtml" lang="es">' +
            '<head><meta charset="UTF-8"><meta content="width=device-width, initial-scale=1" name="viewport"></head>' +
            '<body style="width:100%;padding:0;Margin:0;background-color:#F6F6F6">' +
            '<div style="background-color:#F6F6F6">' +
            '<table width="100%" cellspacing="0" cellpadding="0" style="border-collapse:collapse;background-color:#F6F6F6">' +
            '<tr><td align="center">' +
            '<table cellspacing="0" cellpadding="0" bgcolor="#f1f1f1" align="center" style="border-collapse:collapse;background-color:#f1f1f1;width:600px">' +
            // Logo
            '<tr><td align="center" style="padding:20px 20px 0 20px">' +
            '<img src="https://ehxeqpz.stripocdn.email/content/guids/CABINET_e4ac78898a5a137a0bde70053963fdbb4c13384644304b6bae409721f353e760/images/redmlogocolor.png" ' +
            'alt="RedMotors" width="100" style="display:block;border:0;outline:none;text-decoration:none">' +
            '</td></tr>' +
            // Contenido principal
            '<tr><td align="center" style="padding:20px">' +
            '<table cellspacing="0" cellpadding="0" bgcolor="#ffffff" width="560" style="border-collapse:collapse;background-color:#ffffff">' +
            // Saludo
            '<tr><td align="center" style="padding:20px 40px 0 40px">' +
            '<p style="Margin:0;font-family:arial,helvetica,sans-serif;line-height:38px;color:#333333;font-size:25px">' +
            'Hola <strong>' + nombreDestinatario + '</strong></p>' +
            '</td></tr>' +
            // Título
            '<tr><td align="center" style="padding:20px 40px 0 40px">' +
            '<p style="Margin:0;font-family:arial,helvetica,sans-serif;line-height:30px;color:#333333;font-size:20px">' +
            '<strong>' + titulo + '</strong></p>' +
            '</td></tr>' +
            // Contenido
            '<tr><td align="left" style="padding:20px 40px">' +
            '<p style="Margin:0;font-family:arial,helvetica,sans-serif;line-height:23px;color:#333333;font-size:15px">' +
            contenido + '</p>' +
            '</td></tr>' +
            // Botones
            (String.isNotBlank(botonesHtml) ? 
            '<tr><td align="center" style="padding:10px 40px 20px 40px">' + botonesHtml + '</td></tr>' : '') +
            // Despedida
            '<tr><td align="left" style="padding:0 40px 20px 40px">' +
            '<p style="Margin:0;font-family:arial,helvetica,sans-serif;line-height:23px;color:#333333;font-size:15px">' +
            'Saludos,<br>RedMotors CRM</p>' +
            '</td></tr>' +
            // Datos del asesor
            '<tr><td align="left" bgcolor="#fdfdfd" style="padding:15px 40px">' +
            '<p style="Margin:0;font-family:arial,helvetica,sans-serif;line-height:23px;color:#333333;font-size:14px">' +
            '<strong>' + (ownerName != null ? ownerName : '') + '</strong></p>' +
            (ownerEmail != null ? '<p style="Margin:0;font-family:arial,helvetica,sans-serif;line-height:23px;color:#333333;font-size:14px">' + ownerEmail + '</p>' : '') +
            (ownerPhone != null ? '<p style="Margin:0;font-family:arial,helvetica,sans-serif;line-height:23px;color:#333333;font-size:14px">' + ownerPhone + '</p>' : '') +
            '</td></tr>' +
            '</table>' +
            '</td></tr>' +
            // Footer
            '<tr><td style="padding:20px">' +
            '<table width="100%" cellspacing="0" cellpadding="0" style="border-collapse:collapse">' +
            '<tr><td style="border-bottom:1px solid #cccccc;height:1px"></td></tr>' +
            '</table>' +
            '</td></tr>' +
            '<tr><td style="padding:0 20px 20px 20px">' +
            '<table width="100%" cellspacing="0" cellpadding="0" style="border-collapse:collapse">' +
            '<tr>' +
            '<td align="left" style="padding-left:20px">' +
            '<p style="Margin:0;font-family:arial,helvetica,sans-serif;line-height:21px;color:#333333;font-size:14px"><strong>Red Motors</strong></p>' +
            '<p style="Margin:0;font-family:arial,helvetica,sans-serif;line-height:21px;color:#333333;font-size:14px">2547-5000</p>' +
            '<p style="Margin:0;font-family:arial,helvetica,sans-serif;line-height:21px;color:#333333;font-size:14px">Uruca - Escaz\u00FA - Pinares</p>' +
            '</td>' +
            '<td align="right">' +
            '<img src="https://ehxeqpz.stripocdn.email/content/guids/CABINET_e4ac78898a5a137a0bde70053963fdbb4c13384644304b6bae409721f353e760/images/bmwminilogos.png" ' +
            'alt="" width="115" style="display:block;border:0;outline:none;text-decoration:none">' +
            '</td>' +
            '</tr>' +
            '</table>' +
            '</td></tr>' +
            '</table>' +
            '</td></tr>' +
            '</table>' +
            '</div>' +
            '</body></html>';
    }

    private static String buildBoton(String url, String label, String bgColor) {
        return '<table cellspacing="0" cellpadding="0" style="border-collapse:collapse;margin:5px auto">' +
            '<tr><td align="center" bgcolor="' + bgColor + '" style="border-radius:5px;padding:12px 25px">' +
            '<a href="' + url + '" target="_blank" style="font-family:arial,helvetica,sans-serif;font-size:15px;' +
            'color:#ffffff;text-decoration:none;display:inline-block">' + label + '</a>' +
            '</td></tr></table>';
    }

    // =============================================
    // NOTIFICAR: Cita Cancelada o Reprogramada
    // =============================================
    private static void notificarCambioStatus(List<Cita_trafico_online__c> citas, String nuevoStatus) {
        CustomNotificationType notifType = [
            SELECT Id FROM CustomNotificationType 
            WHERE DeveloperName = 'Redmotors_Notification' LIMIT 1
        ];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Cita_trafico_online__c cita : citas) {
            String nombreLead = buildNombreLead(cita);
            String modelo = cita.Trafico__r != null ? cita.Trafico__r.Modelo_De_Inter_s1__c : '';
            String sucursal = cita.Sucursal__c != null ? cita.Sucursal__c : '';
            String fecha = cita.Inicio__c != null ? cita.Inicio__c.format('dd/MM/yyyy HH:mm') : '';

            // --- Campanita al Owner del tráfico ---
            String bellTitle = 'Cita ' + nuevoStatus.toLowerCase() + ' - ' + nombreLead;
            String bellBody = 'La cita del lead ' + nombreLead + ' ha sido ' + nuevoStatus.toLowerCase()
                            + '. Fecha: ' + fecha + ' | ' + modelo + ' | ' + sucursal;

            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle(bellTitle);
            notification.setBody(bellBody);
            notification.setNotificationTypeId(notifType.Id);
            notification.setTargetId(cita.Id);

            try {
                notification.send(agregarDestinatariosPrueba(new Set<String>{ cita.OwnerId }));
            } catch (Exception e) {
            }

            // --- Email HTML al Owner ---
            if (cita.Owner.Email != null) {
                String contenido = 'La cita del lead <strong>' + nombreLead + '</strong> ha sido ' + nuevoStatus.toLowerCase() + '.<br><br>'
                    + '&bull; Fecha de la cita: ' + fecha + '<br>'
                    + '&bull; Modelo: ' + modelo + '<br>'
                    + '&bull; Sucursal: ' + sucursal;

                List<String> botones = new List<String>{
                    buildBoton(buildCitaLink(cita.Id), 'Ver Cita', '#0062a6')
                };

                String htmlBody = buildHtmlEmail(
                    cita.Owner.Name,
                    'Cita ' + nuevoStatus,
                    contenido,
                    cita.Owner.Name,
                    cita.Owner.Email,
                    cita.Owner.Phone,
                    botones
                );

                String emailSubject = 'Cita ' + nuevoStatus.toLowerCase() + ' - ' + nombreLead;
                emails.add(buildHtmlEmailMessage(cita.Owner.Email, emailSubject, htmlBody));
                agregarEmailPrueba(emails, emailSubject, htmlBody);
            }
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

    // =============================================
    // NOTIFICAR: Nueva cita (After Insert)
    // =============================================
    private static void notificarNuevaCita(List<Cita_trafico_online__c> citas) {
        CustomNotificationType notifType = [
            SELECT Id FROM CustomNotificationType 
            WHERE DeveloperName = 'Redmotors_Notification' LIMIT 1
        ];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Cita_trafico_online__c cita : citas) {
            String nombreLead = buildNombreLead(cita);
            String modelo = cita.Trafico__r != null ? cita.Trafico__r.Modelo_De_Inter_s1__c : '';
            String sucursal = cita.Sucursal__c != null ? cita.Sucursal__c : '';
            String fecha = cita.Inicio__c != null ? cita.Inicio__c.format('dd/MM/yyyy HH:mm') : '';
            String notas = cita.Notas_del_asesor__c != null ? cita.Notas_del_asesor__c : '';
            String nombreAsesorOnline = cita.Asesor_de_piso__r != null ? cita.Asesor_de_piso__r.Name : '';

            // Destinatarios únicos (Owner y Asesor Online pueden ser el mismo)
            Set<String> destinatarios = new Set<String>();
            destinatarios.add(cita.OwnerId);
            if (cita.Asesor_de_piso__c != null) {
                destinatarios.add(cita.Asesor_de_piso__c);
            }

            // --- Campanita ---
            String bellTitle = 'Nueva cita programada';
            String bellBody = 'Próxima visita: ' + fecha + ' | ' + modelo + ' | ' + sucursal
                            + '. Gestión: ' + nombreAsesorOnline;

            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle(bellTitle);
            notification.setBody(bellBody);
            notification.setNotificationTypeId(notifType.Id);
            notification.setTargetId(cita.Id);

            try {
                notification.send(agregarDestinatariosPrueba(destinatarios));
            } catch (Exception e) {
            }

            // --- Email al Owner ---
            if (cita.Owner.Email != null) {
                String ownerName = cita.Owner.Name;
                String emailBody = 'Hola ' + ownerName + ',\n\n'
                    + 'Se ha programado una nueva cita:\n\n'
                    + '• Próxima visita: ' + fecha + '\n'
                    + '• Modelo: ' + modelo + '\n'
                    + '• Sucursal: ' + sucursal + '\n'
                    + '• Gestión realizada por: ' + nombreAsesorOnline + '\n'
                    + (String.isNotBlank(notas) ? '• Notas del asesor: ' + notas + '\n' : '')
                    + '\nVer cita: ' + buildCitaLink(cita.Id) + '\n'
                    + '\nSaludos,\nRedMotors CRM';

                emails.add(buildEmail(cita.Owner.Email, 'Nueva cita programada - ' + nombreLead, emailBody));
            }

            // --- Email al Asesor Online (si es diferente al Owner) ---
            if (cita.Asesor_de_piso__c != null 
                && cita.Asesor_de_piso__c != cita.OwnerId 
                && cita.Asesor_de_piso__r.Email != null) {
                
                String emailBody = 'Hola ' + nombreAsesorOnline + ',\n\n'
                    + 'Se ha programado una nueva cita para el lead ' + nombreLead + ':\n\n'
                    + '• Próxima visita: ' + fecha + '\n'
                    + '• Modelo: ' + modelo + '\n'
                    + '• Sucursal: ' + sucursal + '\n'
                    + (String.isNotBlank(notas) ? '• Notas del asesor: ' + notas + '\n' : '')
                    + '\nVer cita: ' + buildCitaLink(cita.Id) + '\n'
                    + '\nSaludos,\nRedMotors CRM';

                //emails.add(buildEmail(cita.Asesor_de_piso__r.Email, 'Nueva cita programada - ' + nombreLead, emailBody));
                agregarEmailPrueba(emails,'Nueva cita programada - ' , emailBody);
            }


                    // TEMPORAL - Email de prueba
        
            
        }

        

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

    // =============================================
    // NOTIFICAR: Visita completada (After Update - Asistió)
    // =============================================
    private static void notificarVisitaCompletada(List<Cita_trafico_online__c> citas) {
        CustomNotificationType notifType = [
            SELECT Id FROM CustomNotificationType 
            WHERE DeveloperName = 'Redmotors_Notification' LIMIT 1
        ];

        // Obtener Opportunities a través de Registro_WalkIn__c
        Set<Id> traficoIds = new Set<Id>();
        for (Cita_trafico_online__c c : citas) {
            if (c.Trafico__c != null) traficoIds.add(c.Trafico__c);
        }

        Map<Id, Id> traficoToOpp = new Map<Id, Id>();
        if (!traficoIds.isEmpty()) {
            List<Registro_WalkIn__c> walkIns = [
                SELECT Trafico__c, Opportunity__c
                FROM Registro_WalkIn__c
                WHERE Trafico__c IN :traficoIds
                AND Opportunity__c != null
                ORDER BY CreatedDate DESC
            ];
            for (Registro_WalkIn__c w : walkIns) {
                if (!traficoToOpp.containsKey(w.Trafico__c)) {
                    traficoToOpp.put(w.Trafico__c, w.Opportunity__c);
                }
            }
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Cita_trafico_online__c cita : citas) {
            String nombreLead = buildNombreLead(cita);
            String modelo = cita.Trafico__r != null ? cita.Trafico__r.Modelo_De_Inter_s1__c : '';
            String sucursal = cita.Sucursal__c != null ? cita.Sucursal__c : '';
            String fecha = cita.Inicio__c != null ? cita.Inicio__c.format('dd/MM/yyyy HH:mm') : '';
            String notas = cita.Notas_del_asesor__c != null ? cita.Notas_del_asesor__c : '';
            String nombreAsesorOnline = cita.Asesor_de_piso__r != null ? cita.Asesor_de_piso__r.Name : '';

            // --- Campanita al Owner ---
            String bellTitle = 'Visita completada - ' + nombreLead;
            String bellBody = 'El lead ' + nombreLead + ' completó su visita. ' + fecha + ' | ' + modelo + ' | ' + sucursal;

            Messaging.CustomNotification notifOwner = new Messaging.CustomNotification();
            notifOwner.setTitle(bellTitle);
            notifOwner.setBody(bellBody);
            notifOwner.setNotificationTypeId(notifType.Id);
            notifOwner.setTargetId(cita.Id);

            try {
                notifOwner.send(agregarDestinatariosPrueba(new Set<String>{ cita.OwnerId }));
            } catch (Exception e) {
            }

            // --- Email HTML al Owner ---
            if (cita.Owner.Email != null) {
                String contenido = 'La visita del lead <strong>' + nombreLead + '</strong> ha sido completada.<br><br>'
                    + '&bull; Fecha de visita: ' + fecha + '<br>'
                    + '&bull; Modelo: ' + modelo + '<br>'
                    + '&bull; Sucursal: ' + sucursal + '<br>'
                    + '&bull; Gestión realizada por: ' + nombreAsesorOnline + '<br>'
                    + (String.isNotBlank(notas) ? '&bull; Notas del asesor: ' + notas + '<br>' : '');

                List<String> botones = new List<String>{
                    buildBoton(buildCitaLink(cita.Id), 'Ver Cita', '#0062a6')
                };

                // Agregar botón de Opportunity si existe
                Id oppId = traficoToOpp.get(cita.Trafico__c);
                if (oppId != null) {
                    botones.add(buildBoton(OPP_BASE_URL + oppId + '/view', 'Ver Oportunidad', '#28a745'));
                }

                String htmlBody = buildHtmlEmail(
                    cita.Owner.Name,
                    'Visita Completada',
                    contenido,
                    cita.Owner.Name,
                    cita.Owner.Email,
                    cita.Owner.Phone,
                    botones
                );

                String emailSubject = 'Visita completada - ' + nombreLead;
                emails.add(buildHtmlEmailMessage(cita.Owner.Email, emailSubject, htmlBody));
                agregarEmailPrueba(emails, emailSubject, htmlBody);
            }
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

    // =============================================
    // HELPERS
    // =============================================
    private static String buildNombreLead(Cita_trafico_online__c cita) {
        String firstName = cita.Trafico__r != null ? cita.Trafico__r.FirstName : '';
        String lastName = cita.Trafico__r != null ? cita.Trafico__r.LastName : '';
        return ((firstName != null ? firstName : '') + ' ' + (lastName != null ? lastName : '')).trim();
    }

    private static Messaging.SingleEmailMessage buildHtmlEmailMessage(String toAddress, String subject, String htmlBody) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{ toAddress });
        email.setSubject(subject);
        email.setHtmlBody(htmlBody);
        email.setSaveAsActivity(false);
        return email;
    }

    private static Messaging.SingleEmailMessage buildEmail(String toAddress, String subject, String body) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{ toAddress });
        email.setSubject(subject);
        email.setPlainTextBody(body);
        email.setSaveAsActivity(false);
        return email;
    }
}
