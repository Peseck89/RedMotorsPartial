public class BatchGetAseguradoraSoftland implements Queueable,Database.AllowsCallouts{
    public String company;

    public BatchGetAseguradoraSoftland(String company)
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
            HttpCalloutAseguradora httpAseguradora = new HttpCalloutAseguradora();
            List<Account> lstAseguradoras = new List<Account>(); 
            calloutWS(url,auth.token_type,auth.access_token,1,lstAseguradoras,httpAseguradora,company);
            System.debug('--------- End Process --------');
        }
        catch(System.CalloutException e) {
            System.Debug(e);
        }
    }

    public String calloutWS(String url,String tokenType,String token,Integer actualPage,List<Account> lstAseguradoras,HttpCalloutAseguradora httpAseguradora, String company)
    {
        try {
            HttpResponse res = httpAseguradora.getAseguradoraCallout(company,tokenType,token,actualPage);
            String jsonStr = res.getBody();
            jsonStr = res.getBody();
            //Pretty print debug
            //Object o = JSON.deserializeUntyped(jsonStr);
            //System.debug(Json.serializePretty(o));
            //-----------------------------
            if(Test.isRunningTest()) jsonStr = '{"Paging":{"TotalThisViewCount":1,"TotalRecordCount":1,"PageSize":1,"PageNo":1,"PageCount":1},"Data":[{"telefono2":null,"telefono1":null,"provincia":null,"pais":null,"otras_senas":null,"nombre":null,"moneda":null,"id":null,"distrito":null,"contacto":null,"condicionPago":"test","cliente":"df","cargo":null,"canton":null,"barrio":null,"alias":null}]}';
            cls_AseguradoraJSON aseguradoras = cls_AseguradoraJSON.parseAseguradoraResponse(jsonStr);
            Integer pageCount = aseguradoras.Paging.PageCount;
            for(cls_Aseguradora vAseguradora : aseguradoras.Data)
            {
                condicionPago__c vCondicionPago = [SELECT Id,condicionPago__c FROM condicionPago__c WHERE condicionPago__c=:vAseguradora.condicionPago];
                RecordType recordType = [SELECT Id FROM RecordType WHERE Name='Aseguradora' AND SobjectType ='Account'];
                
                Account acc = new Account();
                acc.codigoSoftland__c = vAseguradora.cliente;
                acc.Name = vAseguradora.nombre;
                acc.Cedula__c = vAseguradora.id;
                acc.Monedas_Iden__c = vAseguradora.moneda; 
                acc.condicionPago__c = vCondicionPago.Id;
                acc.pais__c = vAseguradora.pais;
                acc.provincia__c = vAseguradora.provincia;
                acc.canton__c = vAseguradora.canton;
                acc.distrito__c = vAseguradora.distrito;
                acc.barrio__c = vAseguradora.barrio;
                acc.Direccion__c = vAseguradora.otras_senas;
                String telefono1 = '+506'+vAseguradora.telefono1; 
                System.debug('telefono1: '+telefono1);
                acc.Phone = telefono1;
                String telefono2 = '+506'+vAseguradora.telefono2; 
                acc.Telefono2__c = telefono2;
                acc.RecordTypeId = recordType.Id;
                lstAseguradoras.add(acc);
            }
            if(actualPage < pageCount)
            {
                return calloutWS(url,tokenType,token,actualPage+1,lstAseguradoras,httpAseguradora,company);
            } else {
                Schema.SObjectField cpId = Account.Fields.codigoSoftland__c;
                Database.UpsertResult[] saveCP = Database.upsert(lstAseguradoras,cpId, false);
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