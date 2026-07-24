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
        if (String.isBlank(codigoErp)) {
            throw new EmpresaConfigurationException(
                'La Empresa ' + codigo + ' no tiene código ERP configurado.'
            );
        }
        if (String.isBlank(nombreLegal)) {
            throw new EmpresaConfigurationException(
                'La Empresa ' + codigo + ' no tiene nombre legal configurado.'
            );
        }

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
