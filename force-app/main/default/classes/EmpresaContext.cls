public class EmpresaContext {
    public static final String STATUS_CONFIGURED = 'CONFIGURED';

    public Id empresaId { get; private set; }
    public String codigo { get; private set; }
    public String codigoErp { get; private set; }
    public String nombreLegal { get; private set; }
    public Boolean activa { get; private set; }
    public String configurationStatus { get; private set; }

    public EmpresaContext(
        Id empresaId,
        String codigo,
        String codigoErp,
        String nombreLegal,
        Boolean activa
    ) {
        if (empresaId == null) {
            throw new EmpresaConfigurationException(
                'El Id de Empresa es requerido para crear el contexto.'
            );
        }
        if (String.isBlank(codigo)) {
            throw new EmpresaConfigurationException(
                'El código de Empresa es requerido para crear el contexto.'
            );
        }
        if (activa != true) {
            throw new EmpresaConfigurationException(
                'La Empresa ' + codigo + ' está inactiva.'
            );
        }
        // Codigo_ERP__c y Nombre_Legal__c NO se exigen aquí: ningún consumidor real de
        // EmpresaContext en producción llama requireNombreLegal() (verificado, 2026-07-31 -
        // remediación hallazgo Luis #1), y los que sí necesitan el código ERP (HttpCalloutCreateKit,
        // QuoteSoftlandPedidoService) ya llaman requireCodigoErp() explícitamente, que sigue
        // exigiéndolo en el punto de uso. Exigirlos aquí bloqueaba rutas (integración ERP, trabajos
        // de Quote) que nunca leen esos campos, con Empresas reales que aún no tienen razón social
        // confirmada (Bavarian/Otobai/PEKING en Partial). Ver
        // docs/empresa-marcas-chinas/REMEDIACION_ANALISIS_LUIS_CODEX_20260731.md.

        this.empresaId = empresaId;
        this.codigo = codigo;
        this.codigoErp = codigoErp;
        this.nombreLegal = nombreLegal;
        this.activa = activa;
        this.configurationStatus = STATUS_CONFIGURED;
    }

    public Boolean isConfigured() {
        return configurationStatus == STATUS_CONFIGURED;
    }

    public Boolean isActive() {
        return activa == true;
    }

    public String requireCodigoErp() {
        if (String.isBlank(codigoErp)) {
            throw new EmpresaConfigurationException(
                'La empresa ' + codigo + ' no tiene código ERP configurado.'
            );
        }
        return codigoErp;
    }

    public String requireNombreLegal() {
        if (String.isBlank(nombreLegal)) {
            throw new EmpresaConfigurationException(
                'La empresa ' + codigo + ' no tiene nombre legal configurado.'
            );
        }
        return nombreLegal;
    }
}
