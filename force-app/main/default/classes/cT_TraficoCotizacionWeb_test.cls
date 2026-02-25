@istest(seeAllData = true)
public class cT_TraficoCotizacionWeb_test {
	static testMethod void RTAsignadoDefecto() {
        List<Lead> lstLead = [Select Id From Lead Where Accesorios_cotizacion__c != null];
    	cT_TraficoCotizacionWeb quotePDF = new cT_TraficoCotizacionWeb(new ApexPages.StandardController(lstLead[0]));
        test.startTest();
            cT_TraficoCotizacionWeb.dummy();
        	ApexPages.currentPage().getParameters().put('Id',lstLead[0].id);
        test.stopTest();
    }
}