@isTest(seeAllData=true)
public class CT_nuevaCita_test {
@IsTest
    static void testGetData(){
        List<Asset> lstAsset = [Select Id From Asset Where Name = 'DBZ0981'];
		String strAsset = lstAsset[0].Id;
        List<Event> lstEvent = [Select Id From Event Where Activo__c = :strAsset AND StartDateTime > today];
        
        List<User> lstUser = CT_nuevaCita_controller.getCalendario();      
		CT_nuevaCita_controller.getActives(lstEvent[0].id);
        CT_nuevaCita_controller.getAsesores(lstUser[0].id);
        CT_nuevaCita_controller.getCedula('123,4556,7890');
        CT_nuevaCita_controller.getDataAsesor(lstUser[0].id);
        CT_nuevaCita_controller.getAsset(strAsset,strAsset);
     	CT_nuevaCita_controller.otrosEventos(strAsset,strAsset);
        List<Account> lstAcc = [Select id FROM Account Where Name = 'PORTAL NET'];
        List<Contact> lstCtc = [Select id FROM Contact Where Name = 'Antonio Dorantes'];
        CT_nuevaCita_controller.updateAccount(strAsset,strAsset,lstAcc[0].id);
        CT_nuevaCita_controller.updateContact(strAsset,strAsset,lstCtc[0].id);
        CT_nuevaCita_controller.getServiceT('0054U000009hiwMQAQ');
        CT_nuevaCita_controller.obtenerUsuarioCalendario('Escazú - Mecánica Rápida');
        CT_nuevaCita_controller.getDependentMap('Tipo_de_veh_culo__c','Marca_Nvo__c');
        List<Event_Shadow__c> lstEventS = [Select Id From Event_Shadow__c Where id != null LIMIT 1];
        CT_nuevaCita_controller.getUrlEvent(lstEventS[0].id,lstEvent[0].id,'Presencial');
        Date fechaHoy = Date.today().addDays(2) ;
        CT_nuevaCita_controller.actualizarHorarios(lstEvent[0].id,fechaHoy);
        CT_nuevaCita_controller.getKilometros(strAsset,strAsset,10);
        CT_nuevaCita_controller.createContact(strAsset,strAsset,lstAcc[0].id,'Test','apellido','+50644266931','test@antonio.com');
        CT_nuevaCita_controller.guardarAsset('Placa123Prueba123','Automóvil','BMW Automovil','X1','A1234563890123458','','rojo','2024','1',lstAcc[0].id);
        List<AsesorxCalendario__c> asesoresPorCalendario = [SELECT Asesor__c, Calendario__c, Service_Territory__c, Service_Territory__r.Name FROM AsesorxCalendario__c LIMIT 1];
        Datetime ahora = Datetime.now();
        try{
	        CT_nuevaCita_controller.createEvent(null,strAsset,asesoresPorCalendario[0].Asesor__c,'Uruca - Mecánica Rápida',ahora,'','Uruca - Mecánica Rápida','','Presencial',false);
        }catch(DmlException e){
            
        }
        CT_nuevaCita_controller.dummy();
    }
}