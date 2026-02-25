@isTest
public with sharing class CT_VistaKanbanControllerTest {
    private static testmethod void testVistaKanban(){
        OperatingHours hl = new OperatingHours();
        hl.Name = 'test horario';
        insert hl;
        ServiceTerritory st = new ServiceTerritory();
        st.Name = 'testSt';
        st.OperatingHoursId = hl.Id;
        st.IsActive = true;
        insert st;
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);
        insert u;
                FSL__User_Territory__c usTer = new FSL__User_Territory__c();
		usTer.FSL__ServiceTerritory__c = st.Id;
        usTer.FSL__User__c = u.Id;
         Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        acc.codigoSoftland__c = '1234';
        insert acc;
         Contact c = createContact(true,acc.Id);
        WorkStep ws = setup(true,acc.Id,c.Id, st.Id);
        WorkStep ws1 = setup(true,acc.Id,c.Id, st.Id);
        List<Id> wsList = new List<Id>();
        wsList.add(ws.Id);
        wsList.add(ws1.Id);
         
        
         WorkOrder wo = [Select Id, WorkOrderNumber From WorkOrder limit 1];
        Asset asst = [Select Id from Asset LIMIT 1];
        test.startTest();
            System.runAs(u) {
                CT_VistaKanbanController.getInfoTallerEstado2(true,'%','%','1900-01-01','9999-01-01',wo.iD,asst.Id);
            }
        test.stopTest();
    }
    private static WorkStep setup(Boolean value,Id AccountId, Id ContactId, Id ServiceTId){
        Asset asst = new Asset();
        asst.Name = 'test asset';
        asst.AccountId = AccountId;
        asst.ContactId = ContactId;
        insert asst;
        WorkOrder wo = new WorkOrder();
        wo.AssetId = asst.Id;
        wo.CurrencyIsoCode = '';
        wo.ServiceTerritoryId = ServiceTId;
        insert wo;
        WorkPlan wp = new WorkPlan();
        wp.Name = 'test';
        wp.WorkOrderId =wo.id;
        insert wp;
        WorkStep ws = new WorkStep();
        ws.Name = 'test';
        ws.WorkPlanId = wp.Id;
        ws.Cuenta__c = AccountId;
        if(value)
            insert ws;
        return ws;
    }
    private static Contact createContact(Boolean value,Id AccountId){
        Contact con = new Contact();
        con.LastName = 'testContact';
        con.AccountId = AccountId;
        if(value)
            insert con;
        return con;
    }

}