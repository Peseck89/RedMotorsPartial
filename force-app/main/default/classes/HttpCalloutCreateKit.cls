public class HttpCalloutCreateKit extends HttpCallout {
    public String codigo_articulo;
    public String descripcion;
    public String tipo;
    public String compania;
    public Decimal precio;
    public String Moneda;
    public List<component> componentes;

    public HttpCalloutCreateKit(String codigo_articulo,String descripcion,String tipo,String compania,Decimal precio,String Moneda) {
       this.codigo_articulo = codigo_articulo;
       this.descripcion = descripcion;
       this.tipo = tipo;
       this.compania = compania;
       this.precio = precio;
       this.Moneda = Moneda;
       this.componentes = new List<component> ();
    }

    public class component{
        public String codigo_articulo;
        public decimal cantidad;

        public component(String codigo_articulo, Decimal cantidad ){
            this.codigo_articulo = codigo_articulo;
            this.cantidad = cantidad;
        }
    }

    public void addComponent(String vcodigo_articulo,decimal vcantidad){
        component comp = new component(vcodigo_articulo, vcantidad);
        this.componentes.add(comp);
    }

    public String serializeJSONRequest(){
        system.debug(JSON.serialize(this));
        return EncodingUtil.urlEncode(JSON.serialize(this),'UTF-8');
    }

    public HttpResponse createKit(){
       system.debug('Enviando creación de KIT a SOFTLAND:');
       String jsonStr;
       HttpCalloutAuth htppAuth= new HttpCalloutAuth(label.ClientIdSoftland,label.ClientSecretSoftland);//cambiar por custom label
       HttpResponse resauth = htppAuth.getAuth();
       jsonStr = resauth.getBody();
       cls_AuthorizationJSON auth = cls_AuthorizationJSON.parseAutorizationResponse(jsonStr);
       String fullUrl = Label.URLSoftland+'/'+Label.ambienteSoftland+'/softlandAPI/products/addKit?json=' + this.serializeJSONRequest();
       HttpResponse res = super.callRequest('GET',fullUrl,auth.token_type,auth.access_token);
       system.debug('Respuesta Creación de KIT SOFTLAND:');
       system.debug(res.getBody());
       return res;
    }

    @future(callout=true)
    public static void sendCreateKitRequest(List <Id> OppIds){
        List <Opportunity> Opps = [Select Id, Name, ConsecutivoOportunidad__c, Amount, CurrencyIsoCode,
            Empresa_Operadora__c, BMW_Compania__c,
            (Select Id ,Product2.Codigo_de_Producto__c ,Product2.RecordType.Name ,Quantity ,Preciodefacturacion__c, UnitPrice,Product2.esVehiculo__c FROM OpportunityLineItems where esRegalia__c = false ) from Opportunity where id IN: OppIds];

        Map<Id, EmpresaKitConfiguration> configurationsById = new Map<Id, EmpresaKitConfiguration>();
        Map<String, EmpresaKitConfiguration> configurationsByCode = new Map<String, EmpresaKitConfiguration>();
        loadEmpresaConfigurations(Opps, configurationsById, configurationsByCode);

        for(Opportunity opp: Opps){
            try {
                EmpresaKitConfiguration configuration = resolveEmpresaConfiguration(
                    opp,
                    configurationsById,
                    configurationsByCode
                );
                HttpCalloutCreateKit temp = new HttpCalloutCreateKit(
                    opp.ConsecutivoOportunidad__c,
                    opp.Name,
                    configuration.tipoKit,
                    configuration.codigoErp,
                    0,
                    opp.CurrencyIsoCode
                );
                Boolean sendRequest = false;
                for(OpportunityLineItem ol: opp.OpportunityLineItems){
                    if(ol.Product2.RecordType.Name == 'Vehiculos' && ol.Product2.esVehiculo__c){
                        sendRequest = true;
                        temp.precio += ol.UnitPrice * ol.Quantity;
                    }else{
                        temp.precio += ol.UnitPrice * ol.Quantity;
                    }
                    temp.addComponent(ol.Product2.Codigo_de_Producto__c,ol.Quantity);
                }
                system.debug('Se envía el KIT a Softland--->'+sendRequest);
                if(sendRequest){
                    temp.createKit();
                }
            } catch (Exception e) {
                // Una Opportunity sin configuración inequívoca o un callout fallido no debe
                // impedir que las demás Opportunities del mismo @future sean procesadas.
                System.debug(LoggingLevel.ERROR,
                    'No se pudo crear el KIT de la Opportunity ' + opp.Id + ': ' + e.getMessage()
                );
            }
        }
    }

    private class EmpresaKitConfiguration {
        Id empresaId;
        String codigo;
        String codigoErp;
        String tipoKit;

        EmpresaKitConfiguration(Empresa__c empresa) {
            empresaId = empresa.Id;
            codigo = normalize(empresa.Codigo__c);
            codigoErp = empresa.Codigo_ERP__c;
            tipoKit = empresa.Tipo_Kit_Softland__c;
        }
    }

    private static void loadEmpresaConfigurations(
        List<Opportunity> opportunities,
        Map<Id, EmpresaKitConfiguration> configurationsById,
        Map<String, EmpresaKitConfiguration> configurationsByCode
    ) {
        Set<Id> empresaIds = new Set<Id>();
        Set<String> legacyCodes = new Set<String>();
        for (Opportunity opp : opportunities) {
            if (opp.Empresa_Operadora__c != null) {
                empresaIds.add(opp.Empresa_Operadora__c);
            } else {
                String legacyCode = resolveLegacyCompanyCode(opp.BMW_Compania__c);
                if (legacyCode != null) {
                    legacyCodes.add(legacyCode);
                }
            }
        }

        if (empresaIds.isEmpty() && legacyCodes.isEmpty()) {
            return;
        }

        for (Empresa__c empresa : [
            SELECT Id, Codigo__c, Codigo_ERP__c, Tipo_Kit_Softland__c, Activa__c
            FROM Empresa__c
            WHERE Id IN :empresaIds OR Codigo__c IN :legacyCodes
        ]) {
            EmpresaKitConfiguration configuration = new EmpresaKitConfiguration(empresa);
            if (empresa.Activa__c == true) {
                configurationsById.put(empresa.Id, configuration);
                if (configuration.codigo != null) {
                    if (configurationsByCode.containsKey(configuration.codigo)) {
                        // Un código duplicado deja de ser una resolución legacy inequívoca.
                        configurationsByCode.put(configuration.codigo, null);
                    } else {
                        configurationsByCode.put(configuration.codigo, configuration);
                    }
                }
            }
        }
    }

    private static EmpresaKitConfiguration resolveEmpresaConfiguration(
        Opportunity opp,
        Map<Id, EmpresaKitConfiguration> configurationsById,
        Map<String, EmpresaKitConfiguration> configurationsByCode
    ) {
        EmpresaKitConfiguration configuration;
        if (opp.Empresa_Operadora__c != null) {
            configuration = configurationsById.get(opp.Empresa_Operadora__c);
        } else {
            String legacyCode = resolveLegacyCompanyCode(opp.BMW_Compania__c);
            if (legacyCode != null) {
                configuration = configurationsByCode.get(legacyCode);
            }
        }

        if (configuration == null) {
            throw new AuraHandledException(
                'No fue posible resolver una Empresa activa e inequívoca para la Oportunidad ' + opp.Id + '.'
            );
        }
        if (String.isBlank(configuration.codigoErp) || String.isBlank(configuration.tipoKit)) {
            throw new AuraHandledException(
                'La Empresa de la Oportunidad ' + opp.Id + ' no tiene configuración completa para crear el KIT.'
            );
        }
        return configuration;
    }

    @TestVisible
    private static String resolveLegacyCompanyCode(String legacyCompany) {
        String normalizedCompany = normalize(legacyCompany);
        if (normalizedCompany == 'BAVARIAN' || normalizedCompany == 'RMBAVARIAN') {
            return 'RMBAVARIAN';
        }
        if (normalizedCompany == 'OTOBAI' || normalizedCompany == 'RMOTOBAI') {
            return 'RMOTOBAI';
        }
        return null;
    }

    private static String normalize(String value) {
        return String.isBlank(value) ? null : value.trim().toUpperCase();
    }

    private static EmpresaKitConfiguration resolveEmpresaConfiguration(Opportunity opp) {
        Map<Id, EmpresaKitConfiguration> configurationsById = new Map<Id, EmpresaKitConfiguration>();
        Map<String, EmpresaKitConfiguration> configurationsByCode = new Map<String, EmpresaKitConfiguration>();
        loadEmpresaConfigurations(
            new List<Opportunity>{ opp },
            configurationsById,
            configurationsByCode
        );
        return resolveEmpresaConfiguration(opp, configurationsById, configurationsByCode);
    }

    /**
     * Resuelve el código ERP de Empresa a partir de Opportunity.Empresa_Operadora__c, sin usar
     * Record Type. Cualquier Empresa activa configurada (Bavarian, Otobai, PEKING o una futura)
     * resuelve por esta misma ruta; si no hay Empresa configurada, produce un error controlado
     * en vez de asumir Otobai por defecto.
     */
    @TestVisible
    private static String resolveCompanyErpCode(Opportunity opp) {
        return resolveEmpresaConfiguration(opp).codigoErp;
    }

    /**
     * Resuelve el tipo de kit Softland ('V'/'M') desde la configuración de la Empresa
     * (Empresa__c.Tipo_Kit_Softland__c), sin depender de Record Type. Bavarian y Otobai
     * conservan exactamente su comportamiento actual ('V' y 'M' respectivamente); PEKING usa
     * provisionalmente el valor equivalente de Bavarian mientras no exista definición propia.
     */
    @TestVisible
    private static String resolveTipoKitSoftland(Opportunity opp) {
        return resolveEmpresaConfiguration(opp).tipoKit;
    }

    @InvocableMethod
    public static void sendCreateKitRequestFlow(List <Id> OppIds) {
        system.debug('Flow Create Kit in Sofland (Won Opportunities)');
        system.debug(OppIds);
    	HttpCalloutCreateKit.sendCreateKitRequest(OppIds);
  }
}
