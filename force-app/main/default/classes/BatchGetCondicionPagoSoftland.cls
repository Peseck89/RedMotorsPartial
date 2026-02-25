public class BatchGetCondicionPagoSoftland implements Queueable,Database.AllowsCallouts
{
    public static void execute(QueueableContext context) {
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
            List<condicionPago__c> lstCP = new List<condicionPago__c>(); 
            calloutWS(url,ambiente,auth.token_type,auth.access_token,1,lstCP);
            System.debug('--------- End Process --------');
        }
        catch(System.CalloutException e) {
            System.Debug(e);
        }
    }
    
    public static String calloutWS(String url,String ambiente,String tokenType,String token,Integer actualPage,List<condicionPago__c> lstCP)
    {
        Http h = new Http();
        string response = '';

        HttpRequest req = new HttpRequest();
        System.debug(url+'/'+ambiente+'/softlandAPI/Catalogs/getCondicionPagos?compania=RMBAVARIAN&pageNo='+actualPage+'&pageSize=10');
        req.setEndpoint(url+'/'+ambiente+'/softlandAPI/Catalogs/getCondicionPagos?compania=RMBAVARIAN&pageNo='+actualPage+'&pageSize=10');
        req.setHeader('Authorization', tokenType+' '+token);
        req.setMethod('GET');
        req.setTimeout(20000);
        
        try {
            HttpResponse res = h.send(req);
            String jsonStr = res.getBody();
            //Pretty print debug
            //Object o = JSON.deserializeUntyped(jsonStr);
            //System.debug(Json.serializePretty(o));
            //-----------------------------
            if(Test.isRunningTest()) jsonStr = '{"Paging":{"TotalThisViewCount":1,"TotalRecordCount":1,"PageSize":1,"PageNo":1,"PageCount":1},"Data":[{"telefono2":null,"telefono1":null,"provincia":null,"pais":null,"otras_senas":null,"nombre":null,"moneda":null,"id":null,"distrito":null,"contacto":null,"condicionPago":"test","cliente":"df","cargo":null,"canton":null,"barrio":null,"alias":null}]}';
            CondicionPagoJSON condicionPago = CondicionPagoJSON.parseCondicionPagoResponse(jsonStr);
            Integer pageCount = condicionPago.Paging.PageCount;
            for(CondicionPago vCP : CondicionPago.Data)
            {
                condicionPago__c cp = new condicionPago__c();
                cp.Name = vCP.descripcion;
                cp.condicionPago__c = vCP.condicionPago;
                cp.descripcion__c = vCP.descripcion;
                lstCP.add(cp);
            }
            if(actualPage < pageCount)
            {
                return calloutWS(url,ambiente,tokenType,token,actualPage+1,lstCP);
            } else {
                Schema.SObjectField cpId = condicionPago__c.Fields.condicionPago__c;
                Database.UpsertResult[] saveCP = Database.upsert(lstCP,cpId, false);
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

    public class CondicionPagoJSON
    {
        public List<CondicionPago> Data;
        public Paging Paging;
    }

    public static CondicionPagoJSON parseCondicionPagoResponse(String json) {
        return(CondicionPagoJSON) System.JSON.deserialize(json, CondicionPagoJSON.class);
    }

    public class CondicionPago
    {
        public String condicionPago;
        public String descripcion;
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