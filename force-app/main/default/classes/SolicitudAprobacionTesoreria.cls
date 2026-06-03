public class SolicitudAprobacionTesoreria {

    public String salesforceRequestId { get; set; }
    public String codigoSoftland { get; set; }
    public String consecutivoOpportunidad { get; set; }
    public Decimal monto { get; set; }
    public String moneda { get; set; }
    public Date fechaPago { get; set; } // El deserializador de Apex convierte automáticamente 'YYYY-MM-DD' a Date
    public String metodoPago { get; set; }
    public String referenciaBancaria { get; set; }
    public Boolean diferenteCliente { get; set; }
    public String identificationDepositante { get; set; }
    public String tipoIngreso { get; set; }
    public String comentarios { get; set; }

    /**
     * @description Clase interna para mapear el JSON de respuesta estándar.
     */
    public class RespuestaEstandar {
        public Integer codigo { get; set; }
        public String estado { get; set; }
        public String mensaje { get; set; }
        public String idTransaccion { get; set; }
    }

    /**
     * @description Deserializa un JSON con la estructura plana directamente en una instancia de esta clase.
     * @param jsonStr Cadena JSON a parsear.
     * @return Instancia de SolicitudAprobacionTesoreria.
     */
    public static SolicitudAprobacionTesoreria parse(String jsonStr) {
        return (SolicitudAprobacionTesoreria) JSON.deserialize(jsonStr, SolicitudAprobacionTesoreria.class);
    }

    /**
     * @description Realiza la llamada HTTP (Callout) al servicio de tesorería.
     * Actualmente mantiene la simulación de respuesta exitosa 200 lista para producción.
     * @return RespuestaEstandar con los datos deserializados.
     */
    public RespuestaEstandar realizarLlamada() {
        // 1. Preparar el cuerpo de la petición (Payload) con los datos de esta instancia
        String requestBody = JSON.serialize(this);
        System.debug('Payload a enviar: ' + requestBody);

        /* // =========================================================================
        // LÓGICA REAL (Descomentar y ajustar cuando se conecte al servicio real)
        // =========================================================================
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Tu_Named_Credential/endpoint_tesoreria');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(requestBody);
        
        HttpResponse response = http.send(request);
        // =========================================================================
        */

        // 2. Mock provisional de la respuesta HTTP (Código 200 exitoso)
        HttpResponse responseMock = new HttpResponse();
        responseMock.setStatusCode(200);
        responseMock.setStatus('OK');

        String jsonDeRespuesta = '{' +
            '"codigo": 200,' +
            '"estado": "Éxito",' +
            '"mensaje": "La solicitud de tesorería fue procesada correctamente.",' +
            '"idTransaccion": "TXN-' + String.valueOf(Datetime.now().getTime()) + '"' +
        '}';

        responseMock.setBody(jsonDeRespuesta);
        System.debug('Respuesta HTTP recibida: ' + responseMock.getBody());

        // 3. Procesamiento y deserialización de la respuesta
        // (Cuando cambies a la lógica real, reemplaza 'responseMock' por 'response')
        if (responseMock.getStatusCode() == 200) {
            return (RespuestaEstandar) JSON.deserialize(responseMock.getBody(), RespuestaEstandar.class);
        } else {
            System.debug('Error en la llamada: ' + responseMock.getStatusCode() + ' ' + responseMock.getStatus());
            return null;
        }
    }
}