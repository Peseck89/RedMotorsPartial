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

    // Marcas (Opportunity.RecordType.Name) confirmadas para cada empresa ERP.
    // Otobai: Record Types de marca reales (Harley-Davidson, Indian, Kawasaki, KTM, Polaris),
    // confirmados en Partial y ya validados como RMOTOBAI en otros bloques de Sprint 1
    // (ProductSearcherController, BLOQUE18/19). Excluye Record Types que no son de marca
    // (Autos usados, Cartera Madura, Mostrador, Motos usados, Planes de Venta, Taller):
    // esos nunca fueron una empresa real, solo caían en el else genérico por accidente.
    private static final Set<String> BAVARIAN_RECORD_TYPES = new Set<String>{'BMW', 'MINI', 'Motorrad'};
    private static final Set<String> PEKING_RECORD_TYPES = new Set<String>{'Omoda', 'Jaecoo'};
    private static final Set<String> OTOBAI_RECORD_TYPES = new Set<String>{'Harley-Davidson', 'Indian', 'Kawasaki', 'KTM', 'Polaris'};

    @future(callout=true)
    public static void sendCreateKitRequest(List <Id> OppIds){
        List <Opportunity> Opps = [Select Id, Name, ConsecutivoOportunidad__c, RecordType.Name, Amount, CurrencyIsoCode, Empresa_Operadora__c, (Select Id ,Product2.Codigo_de_Producto__c ,Product2.RecordType.Name ,Quantity ,Preciodefacturacion__c, UnitPrice,Product2.esVehiculo__c FROM OpportunityLineItems where esRegalia__c = false ) from Opportunity where id IN: OppIds];
        List <HttpCalloutCreateKit> mapCalls = new List <HttpCalloutCreateKit> ();
        for(Opportunity opp: Opps){
            Boolean sendRequest = false;
            String tipo = resolveTipo(opp);
            String compania = resolveCompania(opp);
            HttpCalloutCreateKit temp = new HttpCalloutCreateKit(opp.ConsecutivoOportunidad__c,opp.Name,tipo,compania,0,opp.CurrencyIsoCode);
            //HttpCalloutCreateKit temp = new HttpCalloutCreateKit(opp.ConsecutivoOportunidad__c,opp.Name,'M','RMBAVARIAN',opp.Amount,opp.CurrencyIsoCode);
            for(OpportunityLineItem ol: opp.OpportunityLineItems){
                if(ol.Product2.RecordType.Name == 'Vehiculos' && ol.Product2.esVehiculo__c){
                    sendRequest = true;
                    temp.precio += ol.UnitPrice * ol.Quantity;
                    //temp.precio += ol.Preciodefacturacion__c * ol.Quantity;
                }else{
                    temp.precio += ol.UnitPrice * ol.Quantity;
                }
                temp.addComponent(ol.Product2.Codigo_de_Producto__c,ol.Quantity);
                //temp.precio += ol.Product2.RecordType.Name == 'Vehiculos' ? ol.Preciodefacturacion__c * ol.Quantity :  ol.UnitPrice * ol.Quantity;
                //System.debug(temp.precio); System.debug(ol.Product2.RecordType.Name);
            }
            system.debug('Se envía el KIT a Softland--->'+sendRequest);
            if(sendRequest){
            	temp.createKit();
            }
        }
    }
    
    // Empresa principal: Empresa_Operadora__c -> Empresa__c.Codigo_ERP__c.
    // RecordType es fallback temporal solo mientras Empresa_Operadora__c esté vacío
    // (hoy es el único camino real porque la migración de Empresa_Operadora__c no se ha completado).
    @TestVisible
    private static String resolveCompania(Opportunity opp) {
        if (opp.Empresa_Operadora__c != null) {
            EmpresaContext empresaContext = EmpresaResolver.resolve(opp.Empresa_Operadora__c);
            return empresaContext.requireCodigoErp();
        }
        String recordTypeName = opp.RecordType != null ? opp.RecordType.Name : null;
        if (BAVARIAN_RECORD_TYPES.contains(recordTypeName)) {
            return 'RMBAVARIAN';
        }
        if (PEKING_RECORD_TYPES.contains(recordTypeName)) {
            return 'RMPEKING';
        }
        if (OTOBAI_RECORD_TYPES.contains(recordTypeName)) {
            return 'RMOTOBAI';
        }
        throw new EmpresaConfigurationException('No se pudo determinar la empresa para el Record Type de Opportunity: ' + recordTypeName);
    }

    // Mismo criterio (RecordType.Name) que ya usaba el código para tipo V/M; se extiende
    // únicamente para incluir Omoda/Jaecoo dentro del grupo 'V', según lo confirmado por Diego.
    private static String resolveTipo(Opportunity opp) {
        String recordTypeName = opp.RecordType != null ? opp.RecordType.Name : null;
        if (BAVARIAN_RECORD_TYPES.contains(recordTypeName) || PEKING_RECORD_TYPES.contains(recordTypeName)) {
            return 'V';
        }
        if (OTOBAI_RECORD_TYPES.contains(recordTypeName)) {
            return 'M';
        }
        throw new EmpresaConfigurationException('No se pudo determinar el tipo para el Record Type de Opportunity: ' + recordTypeName);
    }

    @InvocableMethod
    public static void sendCreateKitRequestFlow(List <Id> OppIds) {
        system.debug('Flow Create Kit in Sofland (Won Opportunities)');
        system.debug(OppIds);
    	HttpCalloutCreateKit.sendCreateKitRequest(OppIds);
  }
}