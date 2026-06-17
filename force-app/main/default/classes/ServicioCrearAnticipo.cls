@RestResource(urlMapping='/CrearAnticipo/*')
global with sharing class ServicioCrearAnticipo {
    private static final String PDF_TITLE_PREFIX = 'PDF Softland - ';
    private static final String PDF_DOWNLOAD_PATH = '/sfc/servlet.shepherd/version/download/';

    @HttpPost
    global static RespuestaRest crearAnticipo() {
        RestRequest req = RestContext.request;
        RespuestaRest respuesta = new RespuestaRest();

        try {
            String requestBody = req.requestBody.toString();
            System.debug('ServicioCrearAnticipo.crearAnticipo - JSON recibido: ' + requestBody);
            PeticionAnticipo peticion = (PeticionAnticipo) JSON.deserialize(requestBody, PeticionAnticipo.class);

            if (String.isBlank(peticion.identificadorHelios)) {
                respuesta.exito = false;
                respuesta.mensaje = 'Error: El campo identificadorHelios es obligatorio.';
                return respuesta;
            }

            List<Anticipo__c> anticipos = [
                SELECT Id, Identificador__c, Estatus__c,
                       Comentarios_Aprobacion_Rechazo__c, PDF_Anticipo_Softland__c
                FROM Anticipo__c
                WHERE Identificador_Helios__c = :peticion.identificadorHelios
                LIMIT 1
            ];

            if (anticipos.isEmpty()) {
                respuesta.exito = false;
                respuesta.mensaje = 'Error: No se encontró ningún anticipo con identificadorHelios ' + peticion.identificadorHelios;
                return respuesta;
            }

            Anticipo__c anticipo = anticipos[0];

            if (String.isNotBlank(peticion.identificadorSoftland)) {
                anticipo.Identificador__c = peticion.identificadorSoftland;
            }
            if (String.isNotBlank(peticion.estado)) {
                anticipo.Estatus__c = peticion.estado;
            }
            if (String.isNotBlank(peticion.comentarios)) {
                anticipo.Comentarios_Aprobacion_Rechazo__c = peticion.comentarios;
            }

            if (String.isNotBlank(peticion.pdf)) {
                String pdfUrl = savePdfFile(anticipo.Id, peticion.identificadorHelios, peticion.pdf, respuesta);
                if (String.isNotBlank(pdfUrl)) {
                    anticipo.PDF_Anticipo_Softland__c = pdfUrl;
                }
            } else if (String.isNotBlank(peticion.linkpdf)) {
                anticipo.PDF_Anticipo_Softland__c = peticion.linkpdf;
            }

            update anticipo;

            respuesta.exito = true;
            respuesta.mensaje = String.isBlank(respuesta.advertencia)
                ? 'Anticipo actualizado exitosamente.'
                : 'Anticipo actualizado exitosamente. ' + respuesta.advertencia;
            respuesta.idAnticipo = anticipo.Id;

        } catch (Exception e) {
            respuesta.exito = false;
            respuesta.mensaje = 'Excepción al procesar la solicitud: ' + e.getMessage();
        }

        return respuesta;
    }

    private static String savePdfFile(
        Id anticipoId,
        String identificadorHelios,
        String pdfBase64,
        RespuestaRest respuesta
    ) {
        try {
            Blob pdfBlob = EncodingUtil.base64Decode(pdfBase64);
            String normalizedHeliosId = sanitizeFileToken(identificadorHelios);
            String title = PDF_TITLE_PREFIX + identificadorHelios;
            String pathOnClient = 'PDF_Softland_' + normalizedHeliosId + '.pdf';
            Id existingDocumentId = findExistingPdfDocument(anticipoId, title);

            ContentVersion version = new ContentVersion(
                Title = title,
                PathOnClient = pathOnClient,
                VersionData = pdfBlob
            );

            if (existingDocumentId == null) {
                version.FirstPublishLocationId = anticipoId;
            } else {
                version.ContentDocumentId = existingDocumentId;
            }

            insert version;

            ContentVersion insertedVersion = [
                SELECT Id, ContentDocumentId
                FROM ContentVersion
                WHERE Id = :version.Id
                LIMIT 1
            ];

            return PDF_DOWNLOAD_PATH + insertedVersion.Id;
        } catch (Exception e) {
            respuesta.advertencia = 'Advertencia: no se pudo guardar el PDF Softland recibido.';
            System.debug(LoggingLevel.WARN, 'ServicioCrearAnticipo.crearAnticipo - PDF inválido o no guardado: ' + e.getMessage());
            return null;
        }
    }

    private static Id findExistingPdfDocument(Id anticipoId, String title) {
        Set<Id> documentIds = new Set<Id>();
        for (ContentDocumentLink link : [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :anticipoId
        ]) {
            documentIds.add(link.ContentDocumentId);
        }

        if (documentIds.isEmpty()) {
            return null;
        }

        List<ContentVersion> versions = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE ContentDocumentId IN :documentIds
                AND IsLatest = true
                AND Title = :title
            LIMIT 1
        ];

        return versions.isEmpty() ? null : versions[0].ContentDocumentId;
    }

    private static String sanitizeFileToken(String value) {
        if (String.isBlank(value)) {
            return 'SinIdentificador';
        }
        return value.replaceAll('[^A-Za-z0-9_-]', '_');
    }

    global class PeticionAnticipo {
        public String identificadorHelios    { get; set; }
        public String identificadorSoftland  { get; set; }
        public String estado                 { get; set; }
        public String comentarios            { get; set; }
        public String linkpdf                { get; set; }
        public String pdf                    { get; set; }
    }

    global class RespuestaRest {
        public Boolean exito    { get; set; }
        public String  mensaje  { get; set; }
        public Id      idAnticipo { get; set; }
        public String  advertencia { get; set; }
    }
}
