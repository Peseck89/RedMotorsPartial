public class BatchGetActividadComercialSoftland implements Queueable,Database.AllowsCallouts{
    public String company;

    public BatchGetActividadComercialSoftland(String company)
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
            HttpCalloutActividadComercial httpActividadComercial = new HttpCalloutActividadComercial();
            List<ActividadComercial__c> lstAC = new List<ActividadComercial__c>(); 
            calloutWS(url,auth.token_type,auth.access_token,1,lstAC,httpActividadComercial,company);
            System.debug('--------- End Process --------');
        }
        catch(System.CalloutException e) {
            System.Debug(e);
        }
    }

    public static String calloutWS(String url,String tokenType,String token,Integer actualPage,List<ActividadComercial__c> lstAC,HttpCalloutActividadComercial httpActividadComercial, String company)
    {
        
        try {
            HttpResponse res = httpActividadComercial.getActividadComercialCallout(company,tokenType,token,actualPage);
            String jsonStr = res.getBody();
            //Pretty print debug
            //Object o = JSON.deserializeUntyped(jsonStr);
            //System.debug(Json.serializePretty(o));
            //-----------------------------
            if(Test.isRunningTest()) jsonStr = '{"Paging":{"TotalThisViewCount":1,"TotalRecordCount":1,"PageSize":1,"PageNo":1,"PageCount":1},"Data":[{"telefono2":null,"telefono1":null,"provincia":null,"pais":null,"otras_senas":null,"nombre":null,"moneda":null,"id":null,"distrito":null,"contacto":null,"condicionPago":"test","cliente":"df","cargo":null,"canton":null,"barrio":null,"alias":null}]}';
            cls_ActividadComercialJSON ActividadComercial = cls_ActividadComercialJSON.parseActividadComercialResponse(jsonStr);
            Integer pageCount = ActividadComercial.Paging.PageCount;
            for(cls_ActividadComercial vActividadComercial : ActividadComercial.Data)
            {
                ActividadComercial__c imp = new ActividadComercial__c();
                imp.Name = vActividadComercial.descripcion;
                imp.codigo__c = vActividadComercial.codigo;
                imp.descripcion__c = vActividadComercial.descripcion;
                lstAC.add(imp);
            }
            if(actualPage < pageCount)
            {
                return calloutWS(url,tokenType,token,actualPage+1,lstAC,httpActividadComercial,company);
            } else {
                Schema.SObjectField sdId = ActividadComercial__c.Fields.codigo__c;
                Database.UpsertResult[] saveCP = Database.upsert(lstAC,sdId, false);
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
}