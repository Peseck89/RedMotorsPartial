@isTest
public class cT_reporteHorasFac_test {
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
        String dateI = '2020-01-25';
        String dateF = '2025-12-25';
        test.startTest();
        Datetime expected = Datetime.newInstance(1960, 2, 19);
        List<WorkOrder> getOrdenes = cT_reporteHorasFac.getOrdenes(dateI,dateF);
        List<Contact> getContact = cT_reporteHorasFac.getContacto();
		List<cT_reporteHorasFac.WorkStepWrapper> getWorkStep= cT_reporteHorasFac.getWorkStep(dateI,dateF);
        List<cT_reporteHorasFac.WorkStepCantWrapper> getWorkStepCant= cT_reporteHorasFac.getCantidad(dateI,dateF);
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
        Contact c = createContact(true,AccountId);
        WorkOrder wo = new WorkOrder();
        wo.CurrencyIsoCode = '';
        wo.ContactId = c.Id;
        insert wo;
        WorkPlan wp = new WorkPlan();
        wp.Name = 'test';
        wp.WorkOrderId =wo.id;
        insert wp;
        DateTime dt = DateTime.newInstance(2022, 1, 2);
        tiposDeTrabajo__c tipoT = new tiposDeTrabajo__c();
        tipoT.Name = 'testeo';
        insert tipoT;
        Horas_improductivas_por_mec_nico__c hI = new Horas_improductivas_por_mec_nico__c(); 
        hI.Mecanico__c = c.Id;
        hI.Inicio_de_tiempo_Improductivo__c = dt;
        hI.Fin_de_tiempo_Improductivo__c = dt.addHours(3);
        hI.Se_repite__c = null;
        hI.Tipo_de_Trabajo__c = tipoT.Id;
        insert hI;
        WorkStep ws = new WorkStep();
        ws.Name = 'test';
        ws.CT_CantidadDeHoras__c = 3;
        ws.Mec_nico_asignado__c = c.Id;
        Datetime myDateTime = Datetime.newInstance(1960, 2, 17);
        ws.Hora_de_inicio_de_pausa__c = myDateTime;
        ws.WorkPlanId = wp.Id;
        
        ws.StartTime = dt;
        ws.Cuenta__c = AccountId;
        if(value)
            insert ws;
        return ws;
    }
    private static Contact createContact(Boolean value,Id AccountId){
        Id recordTypeId =
        Schema.SObjectType.Contact.getRecordTypeInfosByName()
        .get('Contacto de Taller').getRecordTypeId();
        
        Contact con = new Contact();
        con.LastName = 'testContact';
        con.AccountId = AccountId;
        con.RecordTypeId = recordTypeId;
        if(value)
            insert con;
        return con;
    }
}