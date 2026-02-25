@istest
public class ct_traficoOrigenWeb_test {
     @isTest(SeeAllData=True)
    public static void TestActualizar()
    {
		List<Lead> leadsId = [SELECT id,Marca__c,Cuota_mensual_cotizacion__c FROM Lead WHERE Vehiculo_cotizacion__c != null AND Marca__c = 'BMW' Order by createddate Desc Limit 1];
        List<String> ldStr = new List<String>();
        ldStr.add(leadsId[0].id);
        ct_traficoOrigenWeb.insertAccounts(ldStr);
    }    
}