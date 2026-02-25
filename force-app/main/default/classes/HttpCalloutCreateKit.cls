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
        List<String> rmbavarian = new List<String>{'BMW', 'MINI', 'Motorrad'};
        List <Opportunity> Opps = [Select Id, Name, ConsecutivoOportunidad__c, RecordType.Name, Amount, CurrencyIsoCode, (Select Id ,Product2.Codigo_de_Producto__c ,Product2.RecordType.Name ,Quantity ,Preciodefacturacion__c, UnitPrice,Product2.esVehiculo__c FROM OpportunityLineItems where esRegalia__c = false ) from Opportunity where id IN: OppIds];            
        List <HttpCalloutCreateKit> mapCalls = new List <HttpCalloutCreateKit> ();
		Boolean sendRequest = false;
        for(Opportunity opp: Opps){
            String tipo = rmbavarian.contains(opp.RecordType.Name) ? 'V' : 'M';
            String compania =  rmbavarian.contains(opp.RecordType.Name) ? 'RMBAVARIAN' : 'RMOTOBAI';
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
    
    @InvocableMethod
    public static void sendCreateKitRequestFlow(List <Id> OppIds) {
        system.debug('Flow Create Kit in Sofland (Won Opportunities)');
        system.debug(OppIds);
    	HttpCalloutCreateKit.sendCreateKitRequest(OppIds);
  }
}