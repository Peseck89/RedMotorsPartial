/**
 * @description       : Clase de prueba para cT_vistaTradicional
 * @author            : Marco Hernandez
 * @group             : Redmotors
 * @last modified on  : 12-09-2022
 * @last modified by  : marcohernandezhp@gmail.com
**/
@isTest
public with sharing class cT_vistaTradicionalTest {
    private static testmethod void getInfoTallerEstadoTest(){
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

        List<String> territoryList = new List<String>(); 
        territoryList.add(userTerritory.Id);
                
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
        
        List<String> statusList = new List<String>();
        Schema.DescribeFieldResult statusFieldDetail =WorkStep.Status.getDescribe();         
        for (Schema.PicklistEntry values : statusFieldDetail.getPicklistValues()) {
            if (values.isActive()) {                
                statusList.add(values.getValue());
            }
        }

        Map<String,Object> workStepReponse = cT_vistaTradicional.getWorkSteps(statusList,territoryList,null,null,null,null,null,null,System.today().addYears(-100),System.today().addYears(100),1);
        List<ServiceTerritory> getListas = cT_vistaTradicional.getTalleres();
        List<Map<String,String>> getListas2 = cT_vistaTradicional.getTalleresForSelect();
        List<WorkOrder> getOrdenes = cT_vistaTradicional.getOrdenes();
        List<Contact> getContact = cT_vistaTradicional.getContact();    
        ws.StartTime = expected.addDays(-5);
        ws.Mec_nico_asignado__c = c.Id;
        update ws;

        List<WorkStep> workStepList = [ SELECT CT_NombreOrdenDeTrabajo__c, CT_TipoDeTrabajoDelCaso__c,CT_AsignadoA__c,WorkOrder.Status__c,
                        WorkOrder.WorkOrderNumber, Id, WorkOrderId,AcumuladoMinutosPausas__c,Mec_nico_asignado__r.FirstName,Mec_nico_asignado__r.LastName,
                        Name,StartTime,EndTime,WorkOrder.MecanicoLider__c,Hora_de_inicio_de_pausa__c,
                        WorkOrder.AssetId,WorkOrder.Asset.Name,WorkOrder.AccountNumber__c,
                        Status, Mec_nico_asignado__c,Mec_nico_asignado__r.Name,Total_de_tiempo_trabajado_en_minutos__c,
                        CT_Placa__c,WorkOrder.CreatedDate,WorkOrder.Owner.Name,WorkOrder.Account.Name,WorkOrder.Tipo_de_servicio__c,
                        Tipo_de_trabajo_del_caso__c, Tipo_de_trabajo_del_caso__R.Name,WorkOrder.Contact.Name,WorkOrder.ServiceTerritory.Name,
                        (select Cantidad_de_horas__c from Subtipos_de_trabajos_del_caso__r) 
                        FROM WorkStep ];

        System.debug('@@@@@@ws@@@@@@@'+ws);
        cT_vistaTradicional.updateRecordComp(ws.Id, expected);
        cT_vistaTradicional.updateRecordMeca(ws.Id,c.Id);        
        cT_vistaTradicional.updateRecordEnCurso(ws.Id);
        test.stopTest();

        cT_vistaTradicional.getErrorMessage('FIELD_FILTER_VALIDATION_EXCEPTION, Error message');
        cT_vistaTradicional.getErrorMessage('FIELD_CUSTOM_VALIDATION_EXCEPTION, Error message');
        cT_vistaTradicional.getErrorMessage('INVALID_FIELD, Error message');
        

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