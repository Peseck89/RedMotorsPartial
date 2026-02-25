public without sharing class LeadAPIBatchCall {
    
    @future(CallOut=true)
    public static void sendDataToAws()
    {
        String query = 'Select Id,ToLabel(LeadSource),Owner.Name,ToLabel(Status),ToLabel(Marca__c),ToLabel(FechaPosibleCompra__c),CreatedDate,Modelo_De_Inter_s1__c,LeadIdNumerico__c,IsConverted,ConvertedDate,ConvertedOpportunitY.Opportunity_ID__c,Campana__r.Name from Lead where (CreatedDate >= 2021-12-01T06:00:00.000+0000  and CreatedDate <= 2022-04-19T06:00:00.000+0000 ) and  Marca__c IN(\'BMW\',\'MINI\',\'Motorrad\')';
        if(Test.isRunningTest())
        { 
            query = 'Select Id,ToLabel(LeadSource),Owner.Name,ToLabel(Status),ToLabel(Marca__c),ToLabel(FechaPosibleCompra__c),CreatedDate,Modelo_De_Inter_s1__c,LeadIdNumerico__c,IsConverted,ConvertedDate,ConvertedOpportunitY.Opportunity_ID__c,Campana__r.Name from Lead where Marca__c IN(\'BMW\',\'MINI\',\'Motorrad\')';
        }
        List<Lead> records = Database.query(query);
        Map<String, Object> mapMain = new Map<String, Object>(); 
        List<Map<String, String>> dataList = new List<Map<String, String>>();
        for(Lead ld : records){
            Map<String, String> mapData = new Map<String, String>(); 
            if(ld.Campana__c == null)
                mapData.put('Campaña', '');  
            else
                mapData.put('Campaña', ld.Campana__r.Name);
            
            if(ld.ConvertedOpportunitY != null && ld.ConvertedOpportunitY.Opportunity_ID__c != null)
                mapData.put('IdOportunidad', ld.ConvertedOpportunitY.Opportunity_ID__c);
            else
                mapData.put('IdOportunidad', '');
            
            String dt2 = '';
            if(ld.ConvertedDate != null)
                dt2 = ld.ConvertedDate.day()+'/'+ld.ConvertedDate.month()+'/'+ld.ConvertedDate.year();
            mapData.put('ConvertedDate', dt2);
            mapData.put('Converted', String.ValueOf(ld.IsConverted).toUppercase());
            mapData.put('LeadId(Numérico)', ld.LeadIdNumerico__c);
            mapData.put('ModeloDeInterés1', ld.Modelo_De_Inter_s1__c);
            String dt1 = ld.CreatedDate.day()+'/'+ld.CreatedDate.month()+'/'+ld.CreatedDate.year();
            mapData.put('CreatedDate', dt1);
            mapData.put('FechaPosibledeCompra', ld.FechaPosibleCompra__c);
            mapData.put('Marca1', ld.Marca__c);
            mapData.put('LeadStatus', ld.Status);
            mapData.put('LeadOwner', ld.Owner.Name);
            mapData.put('LeadSource', ld.LeadSource);
            mapData.put('LeadID', ld.Id);            
            dataList.add(mapData);
        }
        mapMain.put('data', dataList);
        mapMain.put('type', 'leads');
        System.Debug('OrginalBody '+ JSON.serializePretty(mapMain));
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('x-api-key', 'R4U5GsFTTtvyRv0gEnZZ5PkETjDBXit5KWgAnos8');
        req.setEndpoint('https://0hs5zi6d76.execute-api.sa-east-1.amazonaws.com/v1/data-collection');
        req.setMethod('POST');
        req.setTimeout(120000);
        req.setBody(JSON.serializePretty(mapMain));
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();
        System.debug('responseBody = ' +responseBody);
        System.debug('res.getStatusCode = ' +res.getStatusCode());
        System.debug('res.getStatus = ' +res.getStatus());
        if(res.getStatusCode() != 200)
        {
            System.assert(false, ' Sync Process failed');
        }
        
    }
    
}