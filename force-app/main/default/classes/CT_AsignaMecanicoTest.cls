@isTest
public with sharing class CT_AsignaMecanicoTest {

    private static testmethod void getFilteredDateTest(){

        OperatingHours oh = new OperatingHours(
            Name = 'test',
            TimeZone = 'America/Costa_Rica'
        );
        insert oh;
        ServiceTerritory territory = new ServiceTerritory(
            Name = 'Uruca',
            IsActive = true,
            OperatingHoursId = oh.Id 
        );
        insert territory;
        
        FSL__User_Territory__c userTerritory = new FSL__User_Territory__c(
            FSL__User__c = UserInfo.getUserId(),
            FSL__ServiceTerritory__c = territory.Id
        );
        insert userTerritory;

         Account acc= new Account();
        acc.Name='Test account';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        acc.codigoSoftland__c = '1234';
        insert acc;

        WorkStep ws = setup(true,acc.Id);
        WorkStep ws1 = setup(true,acc.Id);

        List<WorkOrder> workOrderList = [SELECT Id,ServiceTerritoryId FROM WorkOrder];
        for (WorkOrder workOrder : workOrderList) {
            workOrder.ServiceTerritoryId = territory.Id;
        }
        update workOrderList;
        Contact c = createContact(true,acc.Id);
        List<Id> wsList = new List<Id>();
        wsList.add(ws.Id);
        wsList.add(ws1.Id);
        test.startTest();

        CT_AsignaMecanico.updateWorkSteps(new List<Id>{ws.Id},'asignar',null, c.Id);
        CT_AsignaMecanico.updateWorkSteps(new List<Id>{ws.Id},'reanudar',null, c.Id);
        CT_AsignaMecanico.createTiempoImproductivo(new List<Id> {ws.Id},'test');
        
        CT_AsignaMecanico.getWorkSteps(null,null,null,null,'asignar',false,'all',1);
        CT_AsignaMecanico.getWorkSteps(null,null,null,null,'reasignar',false,'all',1);
        CT_AsignaMecanico.getWorkSteps(null,null,null,null,'iniciar',false,'all',1);
        CT_AsignaMecanico.getWorkSteps(null,null,null,null,'pausar',false,'all',1);
        CT_AsignaMecanico.getWorkSteps(null,null,null,null,'completar',false,'all',1);
        CT_AsignaMecanico.getWorkSteps(null,null,null,null,'reanudar',false,'all',1);
        CT_AsignaMecanico.assignWorkSteps(wsList,c.Id);

        List<Map<String, String>> picklistValues = CT_AsignaMecanico.getTipoCargo();

        Test.setMock(HttpCalloutMock.class, new RM_WS_SMS_Service_Test.WSSMSMock());

        CT_AsignaMecanico.assignAndStartWorkSteps(wsList,c.Id);
        CT_AsignaMecanico.checkTaskRunning(ws.Id);
        CT_AsignaMecanico.getTerritories();

        CT_AsignaMecanico.getErrorMessage('FIELD_FILTER_VALIDATION_EXCEPTION, Error message');
        CT_AsignaMecanico.getErrorMessage('FIELD_CUSTOM_VALIDATION_EXCEPTION, Error message');
        CT_AsignaMecanico.getErrorMessage('INVALID_FIELD, Error message');

        test.stopTest();
    }

    private static WorkStep setup(Boolean value,Id AccountId){
        WorkOrder wo = new WorkOrder();
        wo.CurrencyIsoCode = '';
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