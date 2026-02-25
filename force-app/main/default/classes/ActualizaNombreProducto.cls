public class ActualizaNombreProducto {
    public static void ActualizaProdu(Integer anhoIni,Integer mesIni,Integer diaIni,Integer anhoFin,Integer mesFin,Integer diaFin){
        DateTime fechaIni = Datetime.newInstance(anhoIni,mesIni,diaIni,01,00,00);
        Datetime fechaFin = Datetime.newInstance(anhoFin,mesFin,diaFin,23,59,59);
        List<Opportunity>listOpp = [Select Id,Name from Opportunity where CreatedDate >=: fechaIni And CreatedDate <=: fechaFin];
        System.debug('Produ: '+listOpp);
        List<Opportunity> oppUpdate = new List<Opportunity>();
        for(Opportunity opp : listOpp){
            Opportunity oppUp = new Opportunity();
            List<OpportunityLineItem> oppProdu = [Select id,Product2.Name,CreatedDate From OpportunityLineItem where
                                                  OpportunityId =: opp.Id Order By CreatedDate DESC Limit 1 ];
            if(oppProdu.size() > 0){
              oppUp.Id = opp.Id;
            	//oppUp.NombreProducto__c = oppProdu[0].Product2.Name;
            	//oppUpdate.add(oppUp);  
            }
            
            
        }
        if(oppUpdate.size()>0){
            //update oppUpdate;
        }
    }
}