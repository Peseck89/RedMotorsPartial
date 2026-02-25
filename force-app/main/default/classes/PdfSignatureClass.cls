public with sharing class PdfSignatureClass {

    @AuraEnabled
    public static String getLastContentDocumentId(String caseId) {
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :caseId 
            AND ContentDocument.LatestPublishedVersion.Title LIKE '%Firmada%'
            ORDER BY SystemModstamp DESC 
            LIMIT 1
        ];
        if (!links.isEmpty()) {
            return links[0].ContentDocumentId;
        }
        return null;
    }

    @AuraEnabled
    public static void sendSignedPDFEmail(String recordId, String contentDocumentId) {
        try {
            // Traemos info del caso, contacto, owner (asesor) y asset
            Case caso = [
                SELECT Id,
                       CaseNumber,
                       ContactId,
                       Contact.Name,
                       Contact.Email,
                       Owner.FirstName,
                       Owner.LastName,
                       Owner.Title,
                       Owner.Email,
                       Owner.Phone,
                       AssetId
                FROM Case 
                WHERE Id = :recordId 
                LIMIT 1
            ];

            if (caso.Contact == null || String.isBlank(caso.Contact.Email)) {
                System.debug('No hay contacto o correo para el caso: ' + recordId);
                return;
            }

            // Traemos el PDF firmado
            ContentVersion cv = [
                SELECT VersionData, Title 
                FROM ContentVersion 
                WHERE ContentDocumentId = :contentDocumentId 
                ORDER BY VersionNumber DESC 
                LIMIT 1
            ];

            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName(cv.Title + '.pdf');
            attachment.setBody(cv.VersionData);
            attachment.setContentType('application/pdf');

            // ===== Datos dinámicos para el correo =====
            String nombreCliente = caso.Contact.Name;

            String nombreAsesor = '';
            if (caso.Owner != null) {
                if (caso.Owner.FirstName != null) {
                    nombreAsesor += caso.Owner.FirstName + ' ';
                }
                if (caso.Owner.LastName != null) {
                    nombreAsesor += caso.Owner.LastName;
                }
                nombreAsesor = nombreAsesor.trim();
            }

            String tituloAsesor    = (caso.Owner != null) ? caso.Owner.Title   : null;
            String correoAsesor    = (caso.Owner != null) ? caso.Owner.Email   : null;
            String telefonoAsesor  = (caso.Owner != null) ? caso.Owner.Phone   : null;

            // Imagen del vehículo: tomamos el último File ligado al Asset del caso
            String idImagen = '';
            if (caso.AssetId != null) {
                List<ContentDocumentLink> assetLinks = [
                    SELECT ContentDocumentId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = :caso.AssetId
                    ORDER BY SystemModstamp DESC
                    LIMIT 1
                ];
                if (!assetLinks.isEmpty()) {
                    idImagen = assetLinks[0].ContentDocumentId;
                }
            }

            String orgId = UserInfo.getOrganizationId();

            // ===== Cuerpo de texto plano (backup si no renderiza HTML) =====
            String textoPlano  = 'Estimado señor ' + nombreCliente + ',' + '\n\n';
            textoPlano        += 'Adjunto encontrará la orden de trabajo firmada correspondiente a su vehículo (Placa).' + '\n\n';
            textoPlano        += 'Agradecemos la confianza depositada en Red Motors y le informamos que próximamente nos estaremos comunicando con usted para brindarle actualizaciones sobre el avance del servicio.' + '\n\n';
            textoPlano        += 'Quedamos a su disposición para cualquier consulta adicional.' + '\n\n';
            textoPlano        += 'Atentamente,' + '\n\n';
            textoPlano        += nombreAsesor + '\n';
            if (!String.isBlank(tituloAsesor))   textoPlano += tituloAsesor + '\n';
            if (!String.isBlank(correoAsesor))   textoPlano += correoAsesor + '\n';
            if (!String.isBlank(telefonoAsesor)) textoPlano += telefonoAsesor + '\n';

            // ===== Cuerpo HTML con el layout igual al template =====
            String htmlBody = buildEmailHtml(
                nombreCliente,
                nombreAsesor,
                tituloAsesor,
                correoAsesor,
                telefonoAsesor,
                idImagen,
                orgId
            );

            // Enviamos el correo
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { caso.Contact.Email });
            mail.setSubject('Orden de trabajo firmada – Caso ' + caso.CaseNumber);
            mail.setPlainTextBody(textoPlano);
            mail.setHtmlBody(htmlBody);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            System.debug('Correo enviado correctamente a: ' + caso.Contact.Email);

        } catch (Exception e) {
            System.debug('Error al enviar correo: ' + e.getMessage());
            throw new AuraHandledException('Hubo un problema al enviar el correo: ' + e.getMessage());
        }
    }

    /**
     * Construye el HTML del correo con el mismo layout que el template
     * (logo superior, imagen del auto, saludo, bloque de confirmación,
     * asesor/owner, logos y banner azul inferior).
     */
    private static String buildEmailHtml(
        String nombreCliente,
        String nombreAsesor,
        String tituloAsesor,
        String correoAsesor,
        String telefonoAsesor,
        String idImagen,
        String orgId
    ) {
        // Template base (sin comillas simples para que compile bien en Apex)
        String htmlTemplate =
            '<!DOCTYPE html><html lang="es" dir="ltr"><head>  <meta charset="UTF-8" />  <meta name="viewport" content="width=device-width, initial-scale=1.0" />  <title>Correo Confirmación</title></head><body clas' +
            's="body" style="width:100%;height:100%;padding:0;margin:0;"><div style="background-color:#F6F6F6;"><table width="100%" cellspacing="0" cellpadding="0" role="none" style="border-collapse:collapse' +
            ';width:100%;background-color:#F6F6F6;">      <tr>        <t' +
            'd valign="top" style="padding:0;margin:0;">          <!-- HEADER -->          <table cellspacing="0" cellpadding="0" align="center" role="none" style="border-collapse:collapse;width:100%;background-co' +
            'lor:transparent;">            <tr>              <td align="center" style="padding:0;margin:0;">                <table cellspacing="0" cellpadding="0" align="center" role="none" style="border-collapse:colla' +
            'pse;background-color:#f1f1f1;width:600px;">                  <tr>                    <td align="center" style="padding:20px;margin:0;">                      <img src="https://ehxeqpz.stripocdn.email/content/guids/' +
            'CABINET_e4ac78898a5a137a0bde70053963fdbb4c13384644304b6bae409721f353e760/images/redmlogocolor.png" alt="" width="100" style="display:block;border:0;outline:none;text-decoration:none;font-size:14px;" />' +
            '                    </td>                  </tr>                </table>              </td>            </tr>          </table>          <!-- CONTENT -->          <table cellspacing="0" cellpadding="0" align="center" role="none" style="border-collapse:collapse;width:100%;">            ' +
            '<tr>              <td align="center" style="padding:0;margin:0;">                <table cellspacing="0" cellpadding="0" align="center" role="none" style="border-collapse:collapse;background-color:#f1f1f1;width:600px;">                  <tr>             ' +
            '       <td align="left" style="padding:20px;margin:0;">                      <table width="100%" cellspacing="0" cellpadding="0" role="none" style="border-collapse:collapse;">                        <tr>               ' +
            '           <td valign="top" align="center" style="padding:0;margin:0;width:560px;">                            <table width="100%" cellspacing="0" cellpadding="0" role="presentation" style="border-collapse:collapse;background-color:#ffffff;">                              <!-- aquí va carImgRow -->                              <tr>                                <td align="center" ' +
            'style="padding:0;margin:0;font-size:0px;">                                  CAR_IMG_ROW                                </td>                              </tr>                              <tr>                                ' +
            '<td align="center" style="padding:0;margin:0;">                                  <p style="margin:0;font-family:arial, helvetica neue, helvetica, sans-serif;line-height:38px;letter-spacing:0;color:#333333;font-size:25px;">                                    Hola <strong>NOMBRE_CLIENTE</strong>                    ' +
            '              </p>                                </td>                              </tr>                              <tr>                                <td align="left" style="padding-top:5px;padding-bottom:5px;margin:0;">                                  <p style="margin:0;text-align:center;font-family:arial, helvetica neue, helvetica, sans-serif;line-height:23px;letter-spacing:0;color:#333333;font-size:15px;">                                    Gracias por reservar su cita con nosotros                                  </p>                                </td>          ' +
            '                    </tr>                              <tr>                                <td align="left" style="padding-bottom:15px;padding-top:20px;margin:0;">                                  <p style="margin:0;text-align:center;font-family:arial, helvetica neue, helvetica, sans-serif;line-height:30px;letter-spacing:0;color:#333333;font-size:20px;">                                    <strong>Confirmación</strong>                                  </p>                                </td>                              </tr>             ' +
            '                 <tr>                                <td align="left" style="padding-left:40px;padding-right:40px;margin:0;">                                  <p style="margin:0;font-family:arial, helvetica neue, helvetica, sans-serif;line-height:23px;letter-spacing:0;color:#333333;font-size:15px;">                                    Estimado señor NOMBRE_CLIENTE,                                  </p>                                  <p style="margin:0;margin-top:10px;font-family:arial, helvetica neue, helvetica, sans-serif;line-height:23px;letter-spacing:0;color:#333333;font-size:15px;">                                    Adjunto encontrará la orden de trabajo firmada correspondiente a su vehículo (Placa).                                  </p>                                  <p style="margin:0;margin-top:10px;font-family:arial, helvetica neue, helvetica, sans-serif;line-height:23px;letter-spacing:0;color:#333333;font-size:15px;">                                    Agradecemos la confianza depositada en Red Motors y le informamos que próximamente nos estaremos comunicando con usted para brindarle actualizaciones sobre el avance del servicio.                                  </p>                                  <p style="margin:0;margin-top:10px;font-family:arial, helvetica neue, helvetica, sans-serif;line-height:23px;letter-spacing:0;color:#333333;font-size:15px;">                                    Quedamos a su disposición para cualquier consulta adicional.                                  </p>                                </td>                              </tr>                              <tr>                                <td align="left" style="padding-left:40px;padding-right:40px;padding-top:20px;padding-bottom:20px;margin:0;">                                  <p style="margin:0;font-family:arial, helvetica neue, helvetica, sans-serif;line-height:23px;letter-spacing:0;color:#333333;font-size:15px;">                                    Atentamente,                                  </p>                                </td>                              </tr>                              <tr>                                <td align="left" style="margin:0;padding-top:15px;padding-bottom:15px;padding-left:40px;padding-right:40px;background-color:#fdfdfd;">                                  <p style="margin:0;font-family:arial, helvetica neue, helvetica, sans-serif;line-height:23px;letter-spacing:0;color:#333333;font-size:14px;">                                    <strong>NOMBRE_ASESOR</strong>                                  </p>                                  <p style="margin:0;font-family:arial, helvetica neue, helvetica, sans-serif;line-height:23px;letter-spacing:0;color:#333333;font-size:14px;">                                    TITULO_ASESOR                                  </p>                                </td>                              </tr>                              <tr>                                <td style="padding-bottom:15px;background-color:#fdfdfd;margin:0;">                                  <table role="presentation" style="border-collapse:collapse;">                                    CORREO_ROW                                    TELEFONO_ROW                                  </table>                               ' +
            ' </td>                              </tr>                            </table>                          </td>                        </tr>                      </table>                    </td>                  </tr>                </table>              </td>            </tr>          </table>          <!-- FOOTER -->          <table cellspacing="0" cellpadding="0" align="center" role="none" style="border-collapse:collapse;width:100%;background-color:transparent;">            <tr>              <td align="center" style="padding:0;margin:0;">                <table cellspacing="0" cellpadding="0" align="center" role="none" style="border-collapse:collapse;background-color:#f1f1f1;width:600px;">                  <tr>                    <td align="left" style="padding-right:20px;padding-left:20px;margin:0;">                      <table cellspacing="0" cellpadding="0" width="100%" role="none" style="border-collapse:collapse;">                        <tr>                          <td align="left" style="padding:0;margin:0;width:560px;">                            <table width="100%" cellspacing="0" cellpadding="0" role="presentation" style="border-collapse:collapse;">                              <tr>                                <td align="center" style="padding:20px;margin:0;font-size:0;">                                  <table border="0" width="100%" height="100%" cellpadding="0" cellspacing="0" role="presentation" style="border-collapse:collapse;">                                    <tr>                                      <td style="padding:0;margin:0;border-bottom:1px solid #cccccc;background-color:transparent;height:1px;width:100%;"></td>                                    </tr>                                  </table>                                </td>                              </tr>                            </table>                          </td>                        </tr>                      </table>                    </td>                  </tr>                  <tr>                    <td align="left" style="padding-top:20px;padding-right:20px;padding-left:20px;margin:0;">                      <table cellpadding="0" cellspacing="0" align="left" role="none" style="border-collapse:collapse;float:left;">                        <tr>                          <td style="padding:0;margin:0;width:270px;">                            <table cellpadding="0" cellspacing="0" width="100%" role="presentation" style="border-collapse:collapse;">                              <tr>                                <td align="left" style="padding-left:40px;margin:0;">                                  <p style="margin:0;font-family:arial, helvetica neue, helvetica, sans-serif;line-height:21px;letter-spacing:0;color:#333333;font-size:14px;">                                    <strong>Red Motors</strong>                                  </p>                                  <p style="margin:0;font-family:arial, helvetica neue, helvetica, sans-serif;line-height:21px;letter-spacing:0;color:#333333;font-size:14px;">                                    2547-5000                                  </p>                                  <p style="margin:0;font-family:arial, helvetica neue, helvetica, sans-serif;line-height:21px;letter-spacing:0;color:#333333;font-size:14px;">                                    Uruca - Escazú - Pinares                                  </p>                                </td>                              </tr>                            </table>                          </td>                        </tr>                      </table>                      <table cellpadding="0" cellspacing="0" align="right" role="none" style="border-collapse:collapse;float:right;">                        <tr>                          <td align="left" style="padding:0;margin:0;width:270px;">                            <table cellpadding="0" cellspacing="0" width="100%" role="presentation" style="border-collapse:collapse;">                              <tr>                                <td align="center" style="padding:0;margin:0;font-size:0;">                                  <img src="https://ehxeqpz.stripocdn.email/content/guids/CABINET_e4ac78898a5a137a0bde70053963fdbb4c13384644304b6bae409721f353e760/images/bmwminilogos.png" alt="" style="display:block;font-size:14px;border:0;outline:none;text-decoration:none;" width="115" />                                </td>                              </tr>                            </table>                          </td>                        </tr>                      </table>                    </td>                  </tr>                  <tr>                    <td align="left" style="padding-top:20px;padding-right:20px;padding-left:20px;margin:0;">                      <table cellpadding="0" cellspacing="0" width="100%" role="none" style="border-collapse:collapse;">                        <tr>                          <td align="center" valign="top" style="padding:0;margin:0;width:560px;">                            <table cellpadding="0" cellspacing="0" width="100%" role="presentation" style="border-collapse:collapse;">                              <tr>                                <td align="center" style="padding:20px;margin:0;font-size:0;">                                  <table border="0" width="100%" height="100%" cellpadding="0" cellspacing="0" role="presentation" style="border-collapse:collapse;">                                    <tr>                                      <td style="padding:0;margin:0;border-bottom:1px solid #cccccc;background-color:transparent;height:1px;width:100%;"></td>                                    </tr>                                  </table>                                </td>                              </tr>                            </table>                          </td>                        </tr>                      </table>                    </td>                  </tr>                  <tr>                    <td align="left" style="padding:20px;margin:0;background-color:#0062a6;">                      <table cellpadding="0" cellspacing="0" align="left" role="none" style="border-collapse:collapse;float:left;">                        <tr>                          <td align="center" style="padding:0;margin:0;width:150px;">                            <table cellpadding="0" cellspacing="0" width="100%" role="presentation" style="border-collapse:collapse;">                              <tr>                                <td align="center" style="padding:0;margin:0;font-size:0;">                                  <img src="https://ehxeqpz.stripocdn.email/content/guids/CABINET_e4ac78898a5a137a0bde70053963fdbb4c13384644304b6bae409721f353e760/images/redmlogowb.png" alt="" style="display:block;font-size:14px;border:0;outline:none;text-decoration:none;" width="100" />                                </td>                              </tr>                            </table>                          </td>                          <td style="padding:0;margin:0;width:20px;"></td>                        </tr>                      </table>                      <table cellpadding="0" cellspacing="0" align="left" role="none" style="border-collapse:collapse;float:left;">                        <tr>                          <td align="center" style="padding:0;margin:0;width:200px;">                            <table cellpadding="0" cellspacing="0" width="100%" role="presentation" style="border-collapse:collapse;">                              <tr>                                <td align="right" style="padding:0;margin:0;padding-bottom:20px;">                                  <p style="margin:0;font-family:arial, helvetica neue, helvetica, sans-serif;line-height:18px;letter-spacing:0;color:#ffffff;font-size:12px;">                                    Conoce nuestros canales para reservar tu cita en nuestros talleres                                  </p>                                </td>                              </tr>                              <tr>                                <td align="right" style="padding:0;margin:0;">                                  <p style="margin:0;font-family:arial, helvetica neue, helvetica, sans-serif;line-height:18px;letter-spacing:0;color:#ffffff;font-size:12px;">                                    Accede por medio del WhatsApp o por medio de nuestra App Web                                  </p>                                </td>                              </tr>                            </table>                          </td>                        </tr>                      </table>                      <table cellpadding="0" cellspacing="0" align="right" role="none" style="border-collapse:collapse;float:right;">                        <tr>                          <td align="center" style="padding:0;margin:0;width:170px;">                            <table cellpadding="0" cellspacing="0" width="100%" role="presentation" style="border-collapse:collapse;">                              <tr>                                <td align="center" style="padding:0;margin:0;font-size:0;">                                  <img src="https://ehxeqpz.stripocdn.email/content/guids/CABINET_e4ac78898a5a137a0bde70053963fdbb4c13384644304b6bae409721f353e760/images/whatsapp.png" alt="" style="display:block;font-size:14px;border:0;outline:none;text-decoration:none;" width="170" />                                </td>                              </tr>                            </table>                          </td>                        </tr>                      </table>                    </td>                  </tr>                </table>              </td>            </tr>          </table>        </td>      </tr>    </table>  </div></body></html>';

        // Imagen del carro (si existe)
        String carImgRow = '';
        if (!String.isBlank(idImagen)) {
            String carTemplate = '<img class="adapt-img" src="https://redmotors.my.salesforce.com/servlet/servlet.ImageServer?id=IMG_ID&oid=ORG_ID" alt="" style="display:block;font-size:14px;border:0;outline:none;text-decoration:none;" width="250" />';
            carImgRow = carTemplate.replace('IMG_ID', idImagen)
                                   .replace('ORG_ID', orgId);
        }

        // Fila para correo del asesor
        String correoRow = '';
        if (!String.isBlank(correoAsesor)) {
            String correoTemplate = '<tr><td style="padding:0;margin:0;padding-right:10px;padding-left:40px;" class="logo-adapt"><img src="https://ehxeqpz.stripocdn.email/content/guids/CABINET_e4ac78898a5a137a0bde70053963fdbb4c13384644304b6bae409721f353e760/images/mail.png" width="20" style="display:block;font-size:14px;border:0;outline:none;text-decoration:none;" /></td><td style="padding:0;margin:0;"><p style="margin:0;font-family:arial, helvetica neue, helvetica, sans-serif;line-height:21px;letter-spacing:0;color:#333333;font-size:14px;">CORREO_ASESOR</p></td></tr>';
            correoRow = correoTemplate.replace('CORREO_ASESOR', correoAsesor);
        }

        // Fila para teléfono del asesor
        String telefonoRow = '';
        if (!String.isBlank(telefonoAsesor)) {
            String telTemplate = '<tr><td style="padding:0;margin:0;padding-right:10px;padding-left:40px;" class="logo-adapt"><img src="https://ehxeqpz.stripocdn.email/content/guids/CABINET_e4ac78898a5a137a0bde70053963fdbb4c13384644304b6bae409721f353e760/images/call.png" width="20" style="display:block;font-size:14px;border:0;outline:none;text-decoration:none;" /></td><td style="padding:0;margin:0;"><p style="margin:0;font-family:arial, helvetica neue, helvetica, sans-serif;line-height:21px;letter-spacing:0;color:#333333;font-size:14px;">TELEFONO_ASESOR</p></td></tr>';
            telefonoRow = telTemplate.replace('TELEFONO_ASESOR', telefonoAsesor);
        }

        // Reemplazamos los placeholders del template
        if (tituloAsesor == null) {
            tituloAsesor = '';
        }

        String htmlBody = htmlTemplate
            .replace('CAR_IMG_ROW', carImgRow)
            .replace('NOMBRE_CLIENTE', nombreCliente)
            .replace('NOMBRE_ASESOR', nombreAsesor)
            .replace('TITULO_ASESOR', tituloAsesor)
            .replace('CORREO_ROW', correoRow)
            .replace('TELEFONO_ROW', telefonoRow);

        return htmlBody;
    }

    @AuraEnabled
    public static String SaveSignature(String nombre, String recordId, String visualforce, String visualforceFirmado,String fromButton, String signatureBase64) {
        if (String.isEmpty(recordId) || String.isEmpty(signatureBase64)) {
            throw new AuraHandledException('Faltan datos obligatorios.');
        }
        if(nombre == null || nombre == ''){
            nombre = 'Sin nombre';
        }
        try {
            // Crear registro en Firma__c
            Firma__c nuevaFirma = new Firma__c(
                Nombre__c = nombre,
                ReccordId__c = recordId,
                Case__c = recordId,
                Visualforce__c = visualforce
            );
            insert nuevaFirma;
            
            // Crear el archivo en ContentVersion
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Firma_' + nombre;
            cv.PathOnClient = 'Firma.png';
            cv.VersionData = EncodingUtil.base64Decode(signatureBase64);
            cv.FirstPublishLocationId = nuevaFirma.Id; // Relacionar con Firma__c
            insert cv;
            return nuevaFirma.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error al guardar la firma: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getContactInfo(String caseId) {
        Map<String, String> result = new Map<String, String>{
            'name' => '',
            'email' => ''
        };
    
        try {
            Case caso = [
                SELECT Id, Contact.Name, Contact.Email 
                FROM Case 
                WHERE Id = :caseId 
                LIMIT 1
            ];
    
            if (caso.Contact != null) {
                result.put('name', caso.Contact.Name);
                result.put('email', caso.Contact.Email);
            }
        } catch (Exception e) {
            // Devuelve mapa vacío si algo falla
        }
    
        return result;
    }

    @AuraEnabled
    public static String GeneratePDF(String recordId, String fromButton, String visualforceFirmado) {
        try {
            // Generar el PDF
            String savePDF = savePDFfile.attachPDFinCase(recordId, fromButton, visualforceFirmado + '?id=' + recordId);
            // Obtener el ContentDocumentId del PDF recién creado
            Case caso = [SELECT Id, Status, (SELECT ContentDocumentId FROM ContentDocumentLinks ORDER BY SystemModstamp DESC LIMIT 1) FROM Case WHERE Id = :recordId];
            caso.Status = 'Recibido'; 
            update caso;
            return caso.ContentDocumentLinks[0].ContentDocumentId;
        }catch (Exception e) {
            String errorMessage = 'Error en GeneratePDF - Tipo: '  + 
                                  ' - Mensaje: ' + e.getMessage() + 
                                  ' - Stack Trace: ' + e.getStackTraceString();
            throw new AuraHandledException(errorMessage);
        }
    }

    public class ValidacionInfo {
        @AuraEnabled public Boolean infoInComplete;
        @AuraEnabled public Boolean direccionIncomplete;
        @AuraEnabled public Boolean kilometrajeIncomplete;
        @AuraEnabled public Boolean requiresValidation;
    }

    @AuraEnabled
    public static ValidacionInfo getValidacionCase(String caseId) {
        ValidacionInfo result = new ValidacionInfo();
        result.infoInComplete = false;
        result.direccionIncomplete = false;
        result.kilometrajeIncomplete = false;
		
        try {
            Case caso = [SELECT Id, Actualizo_direccion__c, Actualizo_Kilometraje__c, 
                        AssetId, Asset.Tipo_de_veh_culo__c, ContactId, Kilometraje__c, 
                        Cuenta_de_Facturacion__c, OwnerId 
                        FROM Case WHERE Id = :caseId];

            // Validación de dirección solo para tipos específicos
            if(caso.AssetId != null && 
            new Set<String>{'Motocicleta', 'Cuadraciclo', 'Mula'}.contains(caso.Asset.Tipo_de_veh_culo__c)) {
                result.direccionIncomplete = !Boolean.valueOf(caso.Actualizo_direccion__c);
            }

            // Validación de kilometraje solo si dirección está actualizada y para tipos específicos
            if(!result.direccionIncomplete && caso.AssetId != null && 
            new Set<String>{'Cuadraciclo', 'Mula'}.contains(caso.Asset.Tipo_de_veh_culo__c)) {
                result.kilometrajeIncomplete = !Boolean.valueOf(caso.Actualizo_Kilometraje__c);
            }

            // Validación de otros campos solo si las anteriores están completas
            if(!result.direccionIncomplete && !result.kilometrajeIncomplete) {
                result.infoInComplete = (
                    caso.ContactId == null ||
                    caso.OwnerId == null ||
                    caso.Cuenta_de_Facturacion__c == null
                );
            }

        } catch (Exception e) {
            result.direccionIncomplete = true;
            result.kilometrajeIncomplete = true;
            result.infoInComplete = true;
        }

        return result;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getImageFromAsset(String caseId) {
        String tipoImagen = 'Auto';
        System.debug('caseId '+caseId);
        Map<String, String> tipoVehiculoAMapa = new Map<String, String>{
            'Automóvil' => 'Auto',
            'Motocicleta' => 'Moto',
            'Mula' => 'Mula',
            'Cuadraciclo' => 'Cuadra'
        };
        try {
            Case caso = [Select Id, AssetId, Asset.Tipo_de_veh_culo__c From Case Where Id =: caseId];
            System.debug('caso.Asset.Tipo_de_veh_culo__c '+caso.Asset.Tipo_de_veh_culo__c);
            if(caso.Asset.Tipo_de_veh_culo__c != null){
                tipoImagen = tipoVehiculoAMapa.get(caso.Asset.Tipo_de_veh_culo__c);
                System.debug('tipoImagen '+tipoImagen);
            }
            return tipoImagen;
        } catch (Exception e) {
            return 'Auto';
        }
    }

    @AuraEnabled
    public static String SaveDibujo(String recordId, String dibujoBase64, String tipoVehiculo) {
        if (String.isEmpty(recordId) || String.isEmpty(dibujoBase64)) {
            throw new AuraHandledException('Faltan datos obligatorios.');
        }
        try {
            // Crear registro en dibujo vehículo
            DibujoVehiculo__c nuevoDibujoVehiculo = new DibujoVehiculo__c(
                Case__c = recordId,
                TipoDeVehiculo__c = tipoVehiculo
            );
            insert nuevoDibujoVehiculo;
            
            // Crear el archivo en ContentVersion
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Dibujo_' + recordId + '_'+tipoVehiculo;
            cv.PathOnClient = 'DibujoVehiculo.png';
            cv.VersionData = EncodingUtil.base64Decode(dibujoBase64);
            cv.FirstPublishLocationId = nuevoDibujoVehiculo.Id; 
            insert cv;
            return nuevoDibujoVehiculo.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error al guardar el dibujo del vehículo: ' + e.getMessage());
        }
    }
}