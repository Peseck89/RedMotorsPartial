@istest(seeAllData=true)
public with sharing class ct_newFacturaProforma_test {
    static testMethod void RTAsignadoDefecto() {
         
        Opportunity quo = [SELECT Id, SyncedQuoteId,vehiculoProForma__c FROM Opportunity WHERE SyncedQuoteId != null and vehiculoProForma__c != null LIMIT 1 ];

        cT_newFacturaProforma quotePDF = new cT_newFacturaProforma(new ApexPages.StandardController(quo));
       ApexPages.currentPage().getParameters().put('Id',quo.Id);
       test.startTest();
       

       ApexPages.currentPage().getParameters().put('id',quo.Id);

       test.stopTest();

   }
}