@isTest(seeAllData=true)
public class enviarAprobacionDescuentoTest {
    @isTest
    static void testEnviarMensaje() {
    	List<WorkOrder> lstWo = [Select Id,Nivel_de_aprobaci_n_descuento_para_art_c__c,Nivel_de_aprobaci_n_descuento_para_MO__c,ServiceTerritoryId,OwnerId,Owner.LastName,Owner.FirstName From WorkOrder Where Nivel_de_aprobaci_n_descuento_para_art_c__c != null or Nivel_de_aprobaci_n_descuento_para_MO__c != null LIMIT 10];
 		List<String> lstStr = new List<String>();
        For(WorkOrder woli : lstWo){
            lstStr.add(woli.id);
        }
        enviarAprobacionDescuento.enviarNoti(lstStr);
    }
}