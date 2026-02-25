public class BatchGetImpuestoSoftland implements Queueable,Database.AllowsCallouts {
    public static void execute(QueueableContext context)
    {
        String url = Label.URLSoftland;
        String ambiente = Label.ambienteSoftland;
        String clientId = Label.ClientIdSoftland;
        String clientSecret = Label.clientSecretSoftland;
        
        Http h = new Http();
        string response = '';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(url+'/'+ambiente+'/oauth/token');
        req.setBody('clientId='+clientId+'&clientSecret='+clientSecret+'&grant_type=password');
        req.setHeader('Content-Type', 'application/text');
        req.setMethod('GET');
        req.setTimeout(20000);
        try {
            String jsonStr;
            
            HttpResponse res = h.send(req);
            jsonStr = res.getBody();
            AuthorizationJSON auth = AuthorizationJSON.parseAutorizationResponse(jsonStr);
            System.debug('--------- Start Process ---------');
            List<Impuesto__c> lstI = new List<Impuesto__c>(); 
            calloutWS(url,ambiente,auth.token_type,auth.access_token,1,lstI);
            System.debug('--------- End Process --------');
        }
        catch(System.CalloutException e) {
            System.Debug(e);
        }
    }

    public static String calloutWS(String url,String ambiente,String tokenType,String token,Integer actualPage,List<Impuesto__c> lstI)
    {
        Http h = new Http();
        string response = '';

        HttpRequest req = new HttpRequest();
        System.debug(url+'/'+ambiente+'/softlandAPI/Catalogs/getImpuestos?compania=RMBAVARIAN&pageNo='+actualPage+'&pageSize=10');
        req.setEndpoint(url+'/'+ambiente+'/softlandAPI/Catalogs/getImpuestos?compania=RMBAVARIAN&pageNo='+actualPage+'&pageSize=10');
        req.setHeader('Authorization', tokenType+' '+token);
        req.setMethod('GET');
        req.setTimeout(20000);
        
        try {
            HttpResponse res = h.send(req);
            String jsonStr = res.getBody();
            //Pretty print debug
            if(Test.isRunningTest()) jsonStr = '{"Paging":{"TotalThisViewCount":1,"TotalRecordCount":1,"PageSize":1,"PageNo":1,"PageCount":1},"Data":[{"telefono2":null,"telefono1":null,"impuesto":"22.2","pais":null,"otras_senas":null,"nombre":null,"moneda":null,"id":null,"distrito":null,"contacto":null,"condicionPago":"test","cliente":"df","cargo":null,"canton":null,"barrio":null,"alias":null}]}';
            Object o = JSON.deserializeUntyped(jsonStr);
            System.debug(Json.serializePretty(o));
            //-----------------------------
            ImpuestoJSON Impuesto = ImpuestoJSON.parseImpuestoResponse(jsonStr);
            Integer pageCount = Impuesto.Paging.PageCount;
            for(Impuesto vImpuesto : Impuesto.Data)
            {
                Impuesto__c imp = new Impuesto__c();
                imp.Name = vImpuesto.descripcion;
                imp.codigoImpuesto__c = vImpuesto.codigoImpuesto;
                imp.descripcion__c = vImpuesto.descripcion;
                imp.impuesto__c = Decimal.valueOf(vImpuesto.impuesto);
                lstI.add(imp);
            }
            if(actualPage < pageCount)
            {
                return calloutWS(url,ambiente,tokenType,token,actualPage+1,lstI);
            } else {
                Schema.SObjectField cpId = Impuesto__c.Fields.codigoImpuesto__c;
                Database.UpsertResult[] saveCP = Database.upsert(lstI,cpId, false);
                for(Database.UpsertResult resu : saveCP){
                    if(!resu.isSuccess()){
                        system.debug('Error al actualizar la entrada: '+ resu.getErrors());
                    }
                }
                return 'Ok';
            }
        }
        catch(System.CalloutException e) {
            System.Debug(e);
            return e.getMessage();
        }
    }

    public class AuthorizationJSON
    {
         public String access_token;
         public String token_type;
    }

    public static AuthorizationJSON parseAutorizationResponse(String json) {
        return(AuthorizationJSON) System.JSON.deserialize(json, AuthorizationJSON.class);
    }

    public class ImpuestoJSON
    {
        public List<Impuesto> Data;
        public Paging Paging;
    }

    public static ImpuestoJSON parseImpuestoResponse(String json) {
        return(ImpuestoJSON) System.JSON.deserialize(json, ImpuestoJSON.class);
    }

    public class Impuesto
    {
        public String codigoImpuesto;
        public String descripcion;
        public String impuesto;
    }

    public class Paging
    {
        public Integer PageNo;
        public Integer PageSize;
        public Integer PageCount;
        public Integer TotalRecordCount;
        public Integer TotalThisViewCount;
    }
}