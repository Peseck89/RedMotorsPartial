public class SolicitudAprobacionTesoreria {

    // ─── Request fields ───────────────────────────────────────────────────────
    public String  salesforceRequestId       { get; set; }
    public String  codigoSoftland            { get; set; }
    public String  cliente                   { get; set; }
    public String  consecutivoOpportunidad   { get; set; }
    public String  monto                     { get; set; }
    public String  moneda                    { get; set; }
    public String  fechaPago                 { get; set; }
    public String  metodoPago                { get; set; }
    public String  referenciaBancaria        { get; set; }
    public String  diferenteCliente          { get; set; }
    public String  identificationDepositante { get; set; }
    public String  tipoIngreso               { get; set; }
    public String  comentarios               { get; set; }
    public String  compania                  { get; set; }
    public String  nombreArchivo             { get; set; }
    public String  archivo                   { get; set; }

    // ─── Endpoint ─────────────────────────────────────────────────────────────
    private static final String BASE_URL      = 'http://172.176.136.132:5080';
    private static final String SANDBOX_ENV   = 'IntegrationServices';
    private static final String PROD_ENV      = 'ServiciosSoftlandProductivos';
    private static final String RELATIVE_PATH = 'softlandAPI/Opportunities/validateReceipt';

    private static String getEndpoint() {
        Boolean isSandbox;

        try {
            isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        } catch (System.QueryException qe) {
            String domain = System.Url.getOrgDomainUrl().toExternalForm().toLowerCase();
            isSandbox = domain.contains('--') || domain.contains('.sandbox.');
        }

        return BASE_URL + '/' + (isSandbox ? SANDBOX_ENV : PROD_ENV) + '/' + RELATIVE_PATH;
    }

    // ─── Instance callout (used by VN_RQ106_AnticipoController.sendToTreasury) ──
    public RespuestaEstandar realizarLlamada() {
        try {
            if (String.isNotBlank(salesforceRequestId)) {
                Set<Id> docIds = new Set<Id>();
                for (ContentDocumentLink cdl : [
                    SELECT ContentDocumentId
                    FROM ContentDocumentLink
                    WHERE LinkedEntityId = :salesforceRequestId
                ]) {
                    docIds.add(cdl.ContentDocumentId);
                }
                if (!docIds.isEmpty()) {
                    List<ContentVersion> cvList = [
                        SELECT Title, FileExtension, VersionData
                        FROM ContentVersion
                        WHERE ContentDocumentId IN :docIds
                            AND IsLatest = true
                        ORDER BY CreatedDate DESC
                        LIMIT 1
                    ];
                    if (!cvList.isEmpty()) {
                        ContentVersion cv = cvList[0];
                        this.nombreArchivo = cv.Title + (String.isNotBlank(cv.FileExtension) ? '.' + cv.FileExtension : '');
                        this.archivo = EncodingUtil.base64Encode(cv.VersionData);
                    }
                }
            }

            String token = ExternalAuthService.authenticate();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(getEndpoint());
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + token);
            req.setHeader('Content-Type', 'application/json');
            String jsonBody = JSON.serialize(this);
            System.debug('SolicitudAprobacionTesoreria.realizarLlamada - JSON enviado: ' + jsonBody);
            req.setBody(jsonBody);
            HttpResponse res = new Http().send(req);
            System.debug('SolicitudAprobacionTesoreria.realizarLlamada - Respuesta (' + res.getStatusCode() + '): ' + res.getBody());

            RespuestaEstandar respuesta = new RespuestaEstandar();
            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                respuesta.codigo = 200;
                respuesta.estado = 'Éxito';
                respuesta.mensaje = res.getBody();
                if (String.isNotBlank(salesforceRequestId)) {
                    try {
                        ServiceResponse parsed = (ServiceResponse) JSON.deserialize(res.getBody(), ServiceResponse.class);
                        if (parsed?.operationResult?.code == '00' && String.isNotBlank(parsed?.operationResult?.description)) {
                            Anticipo__c anticipo = new Anticipo__c(
                                Id = salesforceRequestId,
                                Identificador_Helios__c = parsed.operationResult.description
                            );
                            update anticipo;
                            System.debug('SolicitudAprobacionTesoreria.realizarLlamada - Identificador_Helios__c guardado: ' + parsed.operationResult.description);
                        }
                    } catch (Exception parseEx) {
                        System.debug('SolicitudAprobacionTesoreria.realizarLlamada - No se pudo guardar Identificador_Helios__c: ' + parseEx.getMessage());
                    }
                }
            } else {
                respuesta.codigo = res.getStatusCode();
                respuesta.estado = 'Error';
                respuesta.mensaje = res.getBody();
            }
            return respuesta;
        } catch (Exception e) {
            RespuestaEstandar respuesta = new RespuestaEstandar();
            respuesta.codigo = 500;
            respuesta.estado = 'Error';
            respuesta.mensaje = e.getMessage();
            return respuesta;
        }
    }

    // ─── Legacy static callout. VN-RQ106 uses realizarLlamada() through its controller. ──
    @AuraEnabled
    public static String enviar(Id anticipoId) {
        if (anticipoId == null) {
            throw new AuraHandledException('El id del anticipo es requerido.');
        }

        Anticipo__c anticipo = [
            SELECT Id, Monto__c, CurrencyIsoCode, Tipo_Ingreso__c,
                   Medio_Pago__c, Fecha_Ingreso__c, Referencia_Comprobante__c,
                   Depositante__c, Comentarios_Asesor__c,
                   Oportunidad__c, Oportunidad__r.Id_Oportunidad__c,
                   Oportunidad__r.empresaQueFactura__c,
                   Oportunidad__r.Account.codigoSoftland__c
            FROM Anticipo__c
            WHERE Id = :anticipoId
            LIMIT 1
        ];

        SolicitudAprobacionTesoreria solicitud = new SolicitudAprobacionTesoreria();
        solicitud.salesforceRequestId       = anticipoId;
        solicitud.codigoSoftland            = anticipo.Oportunidad__r?.Account?.codigoSoftland__c;
        solicitud.cliente                   = solicitud.codigoSoftland;
        solicitud.consecutivoOpportunidad   = anticipo.Oportunidad__r?.Id_Oportunidad__c;
        solicitud.monto                     = anticipo.Monto__c != null ? String.valueOf(anticipo.Monto__c) : null;
        solicitud.moneda                    = anticipo.CurrencyIsoCode;
        solicitud.fechaPago                 = anticipo.Fecha_Ingreso__c != null ? String.valueOf(anticipo.Fecha_Ingreso__c) : null;
        solicitud.metodoPago                = anticipo.Medio_Pago__c;
        solicitud.referenciaBancaria        = anticipo.Referencia_Comprobante__c;
        solicitud.diferenteCliente          = 'false';
        solicitud.identificationDepositante = null;
        solicitud.tipoIngreso               = anticipo.Tipo_Ingreso__c;
        solicitud.comentarios               = anticipo.Comentarios_Asesor__c;
        solicitud.compania                  = anticipo.Oportunidad__r?.empresaQueFactura__c == 'Bavarian'
            ? 'RMBAVARIAN'
            : (anticipo.Oportunidad__r?.empresaQueFactura__c == 'Otobay' ? 'RMOTOBAI' : null);

        String token = ExternalAuthService.authenticate();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(getEndpoint());
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(solicitud));

        HttpResponse res = new Http().send(req);
        ServiceResponse parsed = (ServiceResponse) JSON.deserialize(res.getBody(), ServiceResponse.class);

        if (parsed?.operationResult?.code == '00') {
            update new Anticipo__c(
                Id = anticipo.Id,
                Identificador_Helios__c = parsed.operationResult.description
            );
            return parsed.operationResult.description;
        }

        throw new AuraHandledException(
            String.isNotBlank(parsed?.operationResult?.description)
                ? parsed.operationResult.description
                : 'El servicio de Tesorería no respondió correctamente.'
        );
    }

    // ─── Parse ────────────────────────────────────────────────────────────────
    public static SolicitudAprobacionTesoreria parse(String jsonStr) {
        return (SolicitudAprobacionTesoreria) JSON.deserialize(jsonStr, SolicitudAprobacionTesoreria.class);
    }

    // ─── Response wrappers ────────────────────────────────────────────────────
    public class RespuestaEstandar {
        public Integer codigo  { get; set; }
        public String  estado  { get; set; }
        public String  mensaje { get; set; }
    }

    public class ServiceResponse {
        public OperationResult operationResult { get; set; }
    }

    public class OperationResult {
        public String code        { get; set; }
        public String description { get; set; }
    }
}