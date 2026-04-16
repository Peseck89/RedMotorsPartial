@isTest
public with sharing class CT_VistaKanbanControllerTest {

    @isTest
    static void testVistaKanban() {
        OperatingHours hl = new OperatingHours();
        hl.Name = 'test horario';
        insert hl;

        ServiceTerritory st = new ServiceTerritory();
        st.Name = 'testSt';
        st.OperatingHoursId = hl.Id;
        st.IsActive = true;
        insert st;

        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Administrador del sistema' LIMIT 1];
        User u = new User(
            Alias             = 'standt',
            Email             = 'standarduser@testorg.com',
            EmailEncodingKey  = 'UTF-8',
            LastName          = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey      = 'en_US',
            ProfileId         = p.Id,
            TimeZoneSidKey    = 'America/Los_Angeles',
            UserName          = uniqueUserName
        );
        insert u;

        FSL__User_Territory__c usTer = new FSL__User_Territory__c();
        usTer.FSL__ServiceTerritory__c = st.Id;
        usTer.FSL__User__c = u.Id;
        insert usTer;

        Account acc = new Account();
        acc.Name = 'Test account';
        acc.Cedula__c = '9876543210';
        acc.Tipo_de_Documento__c = '02';
        acc.codigoSoftland__c = '1234';
        insert acc;

        Contact c = createContact(true, acc.Id);
        setup(true, acc.Id, c.Id, st.Id);
        setup(true, acc.Id, c.Id, st.Id);

        WorkOrder wo   = [SELECT Id, WorkOrderNumber FROM WorkOrder LIMIT 1];
        Asset     asst = [SELECT Id FROM Asset LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            // Cubre ramas true de if(strOrden != '%') y if(strVehiculo != '%')
            List<WorkStep> result1 = CT_VistaKanbanController.getInfoTallerEstado2(
                true, '%', '%', '1900-01-01', '9999-01-01', wo.Id, asst.Id
            );
            System.assertNotEquals(null, result1, 'getInfoTallerEstado2 no debe retornar null');

            // Cubre ramas false de if(strOrden != '%') y if(strVehiculo != '%')
            List<WorkStep> result2 = CT_VistaKanbanController.getInfoTallerEstado2(
                true, '%', '%', '1900-01-01', '9999-01-01', '%', '%'
            );
            System.assertNotEquals(null, result2, 'getInfoTallerEstado2 no debe retornar null con wildcards');
        }
        Test.stopTest();
    }

    private static WorkStep setup(Boolean value, Id accountId, Id contactId, Id serviceTId) {
        Asset asst = new Asset();
        asst.Name      = 'test asset';
        asst.AccountId = accountId;
        asst.ContactId = contactId;
        insert asst;

        WorkOrder wo = new WorkOrder();
        wo.AssetId            = asst.Id;
        wo.CurrencyIsoCode    = '';
        wo.ServiceTerritoryId = serviceTId;
        insert wo;

        WorkPlan wp = new WorkPlan();
        wp.Name        = 'test';
        wp.WorkOrderId = wo.Id;
        insert wp;

        WorkStep ws = new WorkStep();
        ws.Name       = 'test';
        ws.WorkPlanId = wp.Id;
        ws.Cuenta__c  = accountId;
        if (value) {
            insert ws;
        }
        return ws;
    }

    private static Contact createContact(Boolean value, Id accountId) {
        Contact con = new Contact();
        con.LastName  = 'testContact';
        con.AccountId = accountId;
        if (value) {
            insert con;
        }
        return con;
    }
}
