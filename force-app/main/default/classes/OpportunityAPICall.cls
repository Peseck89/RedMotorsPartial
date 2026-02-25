public without sharing class OpportunityAPICall {
    
    public static void sendOpportunityDataToAws(){
        String reportId = '00O4U000004mIGBUA2'; 
        Map<Integer,String> labelJson = new Map<Integer,String>{0=>'Subject',1=>'ActivityID',2=>'IdActividad',3=>'CreatedDate',
            4=>'NombredelProducto',5=>'OpportunityID',6=>'CreatedDate__1',7=>'OpportunityOwner:FullName',8=>'ContactID',9=>'ContactId(Numérico)',10=>'CreatedDate__2',
            11=>'SalaVentas',12=>'OpportunityRecordType',13=>'LeadSource',14=>'Stage',15=>'Facturado',16=>'RazóndeVentaPerdida',17=>'Entregado',
            18=>'IdOportunidad',19=>'Campaña:CampaignName'};
                
                FinaljsonWrapper FinaljsonWrapperOb = new FinaljsonWrapper();
        Reports.reportResults results = Reports.ReportManager.runReport(reportId, true);
        String stringResults = (String) JSON.serialize(results);
        Map<String,Object> jsonBody =(Map<String,Object>)Json.deserializeUntyped(stringResults);
        Map<String,Object> factMap = (Map<String,Object>)jsonBody.get('factMap');
        Object innerfactMap = factMap.get('T!T');
        Map<String, Object> innerfactMap_map = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(innerfactMap));
        List<List<Object>> finallst = new List<List<Object>>();
        //List<String> finallst = new List<String>();
        List<Map<String,Object>> finalJsonlst = new List<Map<String,Object>>();
        for (Object instance : (List<Object>)innerfactMap_map.get('rows')){
            Map<String, Object> instanceMap = (Map<String, Object>)instance;
            Object lableobs = instanceMap.get('dataCells');
            Integer i = 0;
            Map<String, Object> finalinnermap = new Map<String, Object>();
            Map<String, Object> finalinnerreversemap = new Map<String, Object>();
            for (Object instance1 : (List<Object>)instanceMap.get('dataCells')){
                Map<String, Object> instance1Map = (Map<String, Object>)instance1;
                object assignvalue = instance1Map.get('label');
                if(instance1Map.get('label') == '-'){
                    assignvalue = '';
                }
                finalinnermap.put(labelJson.get(i), assignvalue);
                i++;
            }
            
            for(Integer j=finalinnermap.size()-1 ;j>=0;j--){
                finalinnerreversemap.put(labelJson.get(j),finalinnermap.get(labelJson.get(j)));
            }
            finalJsonlst.add(finalinnerreversemap);
        }
        FinaljsonWrapperOb.type = 'oportunidades';
        FinaljsonWrapperOb.data = finalJsonlst;
        System.debug('FinaljsonWrapperOb'+FinaljsonWrapperOb);
        System.debug('FinaljsonWrapperOb11'+JSON.serialize(FinaljsonWrapperOb) );
        //  System.assert(false, FinaljsonWrapperOb.data.size());
        
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('x-api-key', 'R4U5GsFTTtvyRv0gEnZZ5PkETjDBXit5KWgAnos8');
        req.setEndpoint('https://0hs5zi6d76.execute-api.sa-east-1.amazonaws.com/v1/data-collection');
        req.setMethod('POST');
        req.setTimeout(120000);
        req.setBody(JSON.serialize(FinaljsonWrapperOb));
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();
        System.debug('responseBody = ' +responseBody);
        System.debug('res.getStatusCode = ' +res.getStatusCode());
        System.debug('res.getStatus = ' +res.getStatus());
        if(res.getStatusCode() != 200)
        {
            System.assert(false, ' Opportunity Sync Process failed');
        }  
    }
    public class FinaljsonWrapper{
        String type;
        List<Map<String,Object>> data;
    }
}