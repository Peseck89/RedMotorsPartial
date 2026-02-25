public class BatchGetBodegaSoftland implements Queueable, Database.AllowsCallouts{
    public String company;

    public BatchGetBodegaSoftland(String company)
    {
        this.company = company;
    }

    public void execute(QueueableContext context)
    {
        String url = Label.URLSoftland;
        String clientId = Label.ClientIdSoftland;
        String clientSecret = Label.clientSecretSoftland;
        
        try {
            String jsonStr;
            HttpCalloutAuth httpAuth = new HttpCalloutAuth(clientId,clientSecret);
            HttpResponse res = httpAuth.getAuth();
            jsonStr = res.getBody();
            cls_AuthorizationJSON auth = cls_AuthorizationJSON.parseAutorizationResponse(jsonStr);
            System.debug('--------- Start Process ---------');
            HttpCalloutBodega httpBodega = new HttpCalloutBodega();
            List<Bodega__c> lstBod = new List<Bodega__c>(); 
            calloutWS(url,auth.token_type,auth.access_token,1,lstBod,httpBodega,company);
            System.debug('--------- End Process --------');
        }
        catch(System.CalloutException e) {
            System.Debug(e);
        }
    }

    public static String calloutWS(String url,String tokenType,String token,Integer actualPage,List<Bodega__c> lstBod,HttpCalloutBodega httpBodega, String company)
    {
        try {
            HttpResponse res = httpBodega.getBodegaCallout(company,tokenType,token,actualPage);
            String jsonStr = res.getBody();
            //Pretty print debug
            Object o = JSON.deserializeUntyped(jsonStr);
            System.debug(Json.serializePretty(o));
            //-----------------------------
            if(Test.isRunningTest()) jsonStr = '{"Paging":{"TotalThisViewCount":1,"TotalRecordCount":1,"PageSize":1,"PageNo":1,"PageCount":1},"Data":[{"telefono2":null,"telefono1":null,"provincia":null,"pais":null,"otras_senas":null,"nombre":null,"moneda":null,"id":null,"distrito":null,"contacto":null,"condicionPago":"test","cliente":"df","cargo":null,"canton":null,"barrio":null,"alias":null}]}';
            cls_BodegaJSON BodegaJSON = cls_BodegaJSON.parseBodegaResponse(jsonStr);
            Integer pageCount = BodegaJSON.Paging.PageCount;
            for(cls_Bodega vBodega : BodegaJSON.Data)
            {
                Bodega__c bodega = new Bodega__c();
                bodega.Name = vBodega.nombre;
                bodega.bodega__c = vBodega.bodega;
                if(company=='RMOTOBAI')
                    bodega.ID_EXTERNO_BODEGA__c = 'RMOTOBAI'+vBodega.bodega;
                else
                    bodega.ID_EXTERNO_BODEGA__c = vBodega.bodega;
                lstBod.add(bodega);
            }
            if(actualPage < pageCount)
            {
                return calloutWS(url,tokenType,token,actualPage+1,lstBod,httpBodega,company);
            } else {
                Schema.SObjectField sdId = Bodega__c.Fields.ID_EXTERNO_BODEGA__c;
                Database.UpsertResult[] saveCP = Database.upsert(lstBod,sdId, false);
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

    public class BodegaJSON
    {
        public List<Bodega> Data;
        public Paging Paging;
    }

    public static BodegaJSON parseBodegaResponse(String json) {
        return(BodegaJSON) System.JSON.deserialize(json, BodegaJSON.class);
    }

    public class Bodega
    {
        public String nombre;
        public String bodega;
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