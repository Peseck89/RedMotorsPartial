@isTest(SeeAllData = false)
public with sharing class WorkOrderListControllerTest {

    @IsTest
    static void getWorkOrderListTest(){

        Id pricebookId = Test.getStandardPricebookId();

        
        Test.startTest();

        Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        insert acc;

        Case casito = new Case();
        casito.Description='TEst';
        casito.Subject = 'Test';
        casito.AccountId=acc.Id;
        insert casito;

        WorkOrder wo = new WorkOrder();
        wo.AccountId=acc.Id;
        wo.subject ='title';
        wo.Pricebook2Id=pricebookId;
        wo.tipoDeGasto__c='Cliente';
        wo.CurrencyIsoCode = 'CRC';
        wo.caseId = casito.Id;
        wo.OwnerId = UserInfo.getUserId();
        wo.StatusDetail__c = 'Recibido';
        insert wo;

        WorkOrder wo2 = new WorkOrder();
        wo2.AccountId=acc.Id;
        wo2.subject ='title';
        wo2.Pricebook2Id=pricebookId;
        wo2.tipoDeGasto__c='Cliente';
        wo2.CurrencyIsoCode = 'CRC';
        wo2.caseId = casito.Id;
        wo2.OwnerId = UserInfo.getUserId();
        wo2.StatusDetail__c = 'Recibido';
        insert wo2;

        List<WorkOrder> workOrderList = WorkOrderListController.getWorkOrderList(casito.Id);
        System.assertEquals(2, workOrderList.size(), 'Error: Algo salio mal en getWorkOrderList');
        
        Test.stopTest();
        
    }
}