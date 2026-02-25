@isTest
public class cT_tiempoIproductivo_test {
 private static testmethod void getInfoTallerEstadoTest(){        
        Account acc= new Account();
        acc.Name='Test account1';
        acc.Cedula__c='9876543210';
        acc.Tipo_de_Documento__c='02';
        acc.codigoSoftland__c = '1234';
        insert acc;
        
        WorkStep ws = setup(true,acc.Id);
        Contact c = createContact(true,acc.Id);
        List<Id> wsList = new List<Id>();
        wsList.add(ws.Id);
        test.startTest();
        Datetime expected = Datetime.newInstance(1960, 2, 19);
        cT_vistaTradicional.getInfoTallerEstado('%','%','%','1900-01-01','9999-01-01','%','%');
        List<ServiceTerritory> getListas = cT_vistaTradicional.getTalleres();
        List<WorkOrder> getOrdenes = cT_vistaTradicional.getOrdenes();
        List<Contact> getContact = cT_vistaTradicional.getContact();
        cT_tiempoIproductivo.getTrabajos();
        cT_tiempoIproductivo.getContact();
        test.stopTest();
    }
    private static WorkStep setup(Boolean value,Id AccountId){
        OperatingHours oh = new OperatingHours();
        oh.CurrencyIsoCode ='CRC';
        oh.Name = 'Horario Regular 34';
        oh.TimeZone = 'America/Costa_Rica';
        insert oh;
        ServiceTerritory st = new ServiceTerritory();
        st.Name = 'TesteoUruca - Mecánica General';     
        st.OperatingHoursId = oh.Id;
        insert st;
        WorkOrder wo = new WorkOrder();
        wo.CurrencyIsoCode = '';
        insert wo;
        WorkPlan wp = new WorkPlan();
        wp.Name = 'test';
        wp.WorkOrderId =wo.id;
        insert wp;
        WorkStep ws = new WorkStep();
        ws.Name = 'test';
        Datetime myDateTime = Datetime.newInstance(1960, 2, 17);
        ws.Hora_de_inicio_de_pausa__c = myDateTime;
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