@isTest
private class ShowWorkStepControllerTest {
    
    private static testmethod void getAllTerritoyTest(){
        OperatingHours oh = new OperatingHours();
        oh.Name = 'testOperatingHours';
        insert oh;
        
        ServiceTerritory st = new ServiceTerritory();
        st.OperatingHoursId = oh.Id;
        st.Name = 'test';
        insert st;
        
        test.startTest();
        List<String> strList = ShowWorkStepController.getAllTerritoy();
        test.stopTest();
        System.assertNotEquals(null, strList);
    }
    
    private static testmethod void getTipoDeServicioTest(){
        test.startTest();
        List<String> strList = ShowWorkStepController.getTipoDeServicio();
        test.stopTest();
        System.assertNotEquals(null, strList);
    }
    
    private static testmethod void getuserListTest(){
        test.startTest();
        List<String> strList = ShowWorkStepController.getuserList();
        test.stopTest();
        System.assertNotEquals(null, strList);
    }
    
    private static testmethod void getStatusTest(){
        test.startTest();
        List<String> strList = ShowWorkStepController.getStatus();
        test.stopTest();
        System.assertNotEquals(null, strList);
    }
    
    private static testmethod void getFilteredDateTest(){
        WorkStep ws = setup(true);
        WorkStep ws1 = setup(true);
        test.startTest();
        ShowWorkStepController.getFilteredDate('test1', 'test2', 'test3', '2020-02-02', '2020-12-02', 'test6', '1', '1');
        test.stopTest();
    }

    private static testmethod void getFilteredDateTest1(){
        WorkStep ws = setup(true);
        WorkStep ws1 = setup(true);
        test.startTest();
        ShowWorkStepController.getFilteredDate(null, null, null, null, null, null, '1', '1');
        test.stopTest();
    }
    /*
    private static testmethod void getFilteredDateTestForNull(){
        WorkStep ws = setup(true);
        case cs = new case();
        cs.subject = 'testCase';
        insert cs;
        tiposDeTrabajo__c tt = new tiposDeTrabajo__c();
        tt.Name = 'testtiposDeTrabajo__c';
        insert tt;
        tiposDeTrabajoCaso__c td = new tiposDeTrabajoCaso__c();
        td.Caso__c = cs.Id;
        td.Tipotrabajo__c = tt.id;
        insert td;
        Subtipo_de_trabajo_del_caso__c st = new Subtipo_de_trabajo_del_caso__c();
        st.Paso_de_trabajo__c = ws.Id;
        st.Cantidad_de_horas__c = 10;
        st.Tipo_de_trabajo_del_caso__c = td.id;
        st.Name = 'test123';
        insert st;
        Mec_nicos_por_Worsktep__c mc = new Mec_nicos_por_Worsktep__c();
        mc.Work_Step__c = ws.Id;
        mc.Contact__c = createContact(true).Id;
        insert mc;
        test.startTest();
        ShowWorkStepController.getFilteredDate(null, null, null, null, null, null, '1', '1');
        test.stopTest();
    }
    */
    private static testmethod void updateNewStatusTest(){
        WorkStep ws = setup(true);
        test.startTest();
        String str = ShowWorkStepController.updateNewStatus(ws.Id);
        test.stopTest();
        WorkStep ws1 = [select Status from WorkStep where Id =:ws.Id];
        System.assertEquals('Nueva', ws1.Status);
    }
    
    private static testmethod void updateNewStatusTestForCatch(){
        test.startTest();
        String strList = ShowWorkStepController.updateNewStatus(null);
        test.stopTest();
        System.assertNotEquals(null, strList);
    }
    
    private static testmethod void updatePauseStatusTest(){
       	WorkStep ws = setup(true);        
        test.startTest();
        String str = ShowWorkStepController.updatePauseStatus(ws.Id);
        test.stopTest();
        WorkStep ws1 = [select Status from WorkStep where Id =:ws.Id];
        System.assertEquals('En pausa', ws1.Status);
    }
    
    private static testmethod void updatePauseStatusTestForCatch(){
        test.startTest();
        String strList = ShowWorkStepController.updatePauseStatus(null);
        test.stopTest();
        System.assertNotEquals(null, strList);
    }
    
    private static testmethod void updateUnPauseStatusTest(){
        WorkStep ws = setup(true);
        test.startTest();
        String str = ShowWorkStepController.updateUnPauseStatus(ws.Id, '2022-03-16T12:59:38.000Z');
        test.stopTest();
        WorkStep ws1 = [select Status from WorkStep where Id =:ws.Id];
        System.assertEquals('En curso', ws1.Status);
    }
    
    private static testmethod void updateUnPauseStatusTestForCatch(){
        test.startTest();
        String strList = ShowWorkStepController.updateUnPauseStatus(null, '2022-03-16T12:59:38.000Z');
        test.stopTest();
        System.assertNotEquals(null, strList);
    }
    
    private static testmethod void updateCompleteStatusTest(){
        WorkStep ws = setup(true);
        test.startTest();
        String str = ShowWorkStepController.updateCompleteStatus(ws.Id);
        test.stopTest();
        WorkStep ws1 = [select Status from WorkStep where Id =:ws.Id];
        System.assertEquals('Completada', ws1.Status);
    }
    
    private static testmethod void updateCompleteStatusTestForCatch(){
        test.startTest();
        String strList = ShowWorkStepController.updateCompleteStatus(null);
        test.stopTest();
        System.assertNotEquals(null, strList);
    }
    
    private static testmethod void associateCreatedContactWithWorkStepTest(){
        WorkStep ws = setup(true);
        Contact c = createContact(true);
        test.startTest();
        String strList = ShowWorkStepController.associateCreatedContactWithWorkStep(ws.Id, c.Id);
        test.stopTest();
        System.assertNotEquals(null, strList);
    }
    
    private static testmethod void associateCreatedContactWithWorkStepTestForCatch(){
        test.startTest();
        String strList = ShowWorkStepController.associateCreatedContactWithWorkStep('test', 'test');
        test.stopTest();
        System.assertNotEquals(null, strList);
    }
    
    private static testmethod void updateWorkStepOnCompleteTest(){
        WorkStep ws = setup(true);
        //Contact c = createContact(true);
        test.startTest();
        String strList = ShowWorkStepController.updateWorkStepOnComplete(ws.Id, 'Nueva', '2022-03-16T12:59:38.000Z', '2022-03-16T07:05:51.905Z');
        test.stopTest();
        System.assertNotEquals(null, strList);
    }
    
    private static testmethod void updateWorkStepOnCompleteTestForCatch(){
        test.startTest();
        String strList = ShowWorkStepController.updateWorkStepOnComplete(null, 'Nueva', '2022-03-16T12:59:38.000Z', '2022-03-16T07:05:51.905Z');
        test.stopTest();
        System.assertNotEquals(null, strList);
    }
    
    private static testmethod void updateWorkStepOnStartTest(){
        WorkStep ws = setup(true);
        Contact c = createContact(true);
        test.startTest();
        String strList = ShowWorkStepController.updateWorkStepOnStart(ws.Id, 'testDescription', 'Nueva', c.id, '2022-03-16T12:59:38.000Z');
        test.stopTest();
        System.assertNotEquals(null, strList);
    }
    
    private static testmethod void updateWorkStepOnStartTestForCatch(){
        test.startTest();
        String strList = ShowWorkStepController.updateWorkStepOnStart(null, 'testDescription', 'Nueva', null, '2022-03-16T12:59:38.000Z');
        test.stopTest();
        System.assertNotEquals(null, strList);
    }
    
    private static WorkStep setup(Boolean value){
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
        if(value)
            insert ws;
        return ws;
    }
    
    private static Contact createContact(Boolean value){
        Contact con = new Contact();
        con.LastName = 'testContact';
        if(value)
            insert con;
        return con;
    }
}