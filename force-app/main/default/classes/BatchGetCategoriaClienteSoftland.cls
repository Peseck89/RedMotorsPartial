public class BatchGetCategoriaClienteSoftland implements Queueable,Database.AllowsCallouts{
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
            List<categoriaCliente__c> lstCC = new List<categoriaCliente__c>(); 
            calloutWS(url,ambiente,auth.token_type,auth.access_token,1,lstCC);
            System.debug('--------- End Process --------');
        }
        catch(System.CalloutException e) {
            System.Debug(e);
        }
    }

    public static String calloutWS(String url,String ambiente,String tokenType,String token,Integer actualPage,List<categoriaCliente__c> lstCC)
    {
        Http h = new Http();
        string response = '';

        HttpRequest req = new HttpRequest();
        System.debug(url+'/'+ambiente+'/softlandAPI/Catalogs/getCategorias_Cliente?pageNo='+actualPage+'&pageSize=10&compania=RMBAVARIAN');
        req.setEndpoint(url+'/'+ambiente+'/softlandAPI/Catalogs/getCategorias_Cliente?pageNo='+actualPage+'&pageSize=10&compania=RMBAVARIAN');
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
            CategoriaClienteJSON CategoriaCliente = CategoriaClienteJSON.parseCategoriaClienteResponse(jsonStr);
            Integer pageCount = CategoriaCliente.Paging.PageCount;
            for(CategoriaCliente vCC : CategoriaCliente.Data)
            {
                CategoriaCliente__c cc = new CategoriaCliente__c();
                cc.Name = vCC.descripcion;
                cc.CategoriaCliente__c = vCC.CategoriaCliente;
                cc.descripcion__c = vCC.descripcion;
                lstCC.add(cc);
            }
            if(actualPage < pageCount)
            {
                return calloutWS(url,ambiente,tokenType,token,actualPage+1,lstCC);
            } else {
                Schema.SObjectField cpId = CategoriaCliente__c.Fields.CategoriaCliente__c;
                Database.UpsertResult[] saveCP = Database.upsert(lstCC,cpId, false);
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

    public class CategoriaClienteJSON
    {
        public List<CategoriaCliente> Data;
        public Paging Paging;
    }

    public static CategoriaClienteJSON parseCategoriaClienteResponse(String json) {
        return(CategoriaClienteJSON) System.JSON.deserialize(json, CategoriaClienteJSON.class);
    }

    public class CategoriaCliente
    {
        public String categoriaCliente;
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