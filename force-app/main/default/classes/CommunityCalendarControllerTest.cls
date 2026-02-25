@isTest
public class CommunityCalendarControllerTest {
	@IsTest(SeeAllData=true) 
    public static void CommunityCalendarController () {
        Test.setMock(HttpCalloutMock.class, new CallExternalApiDatesMock());
        Test.startTest();
        String marcaSel = 'marcaSel';
     	CommunityCalendarController.getMarcasConfig(marcaSel);
        community_config__c comConf = new community_config__c();
        comConf.SubServicios__c = 'Filtro de aire';
        comConf.Name = 'BMW test';	
		comConf.Marca__c = 'BMW';
        comConf.Servicios__c  = 'Mecanica Rapida';

        
        List<AsesorxCalendario__c> lstAsesor = [Select id,Calendario__c,Calendario__r.Name,Service_Territory__r.Name from AsesorxCalendario__c where Calendario__c != null AND Calendario__r.Name != null AND Calendario__c != 'a2q8N0000008QLMQA2' ];
		String idAsesor = lstAsesor[0].Calendario__c;
        String territory = lstAsesor[0].Service_Territory__r.Name;

        
        List<ServiceTerritory> lstService = [Select Id,Name FROM ServiceTerritory WHERE Name != null];

       	
        list<ServiceTerritory> lstServiceTerritory = [Select id,OperatingHoursId from ServiceTerritory WHERE OperatingHoursId != null LIMIT 1];
         Map<String, List<Time>> operatingHours = new Map<String, List<Time>> ();
        Time myTime = Time.newInstance(1, 2, 3, 4);
        Time myTime2 = Time.newInstance(2, 2, 3, 4);
        List<Time> lstTime = new List<Time>();
        lstTime.add(myTime);
        lstTime.add(myTime2);
        operatingHours.put(lstServiceTerritory[0].OperatingHoursId + '',lstTime );

        List<Asset> contacto = [Select Id,Name,ContactId from Asset where ContactId != null LIMIT 3];
        String idContacto = '';
        String idAsset = '';
        String nombreAsset = '';
        if(contacto.size()>0){
            nombreAsset = contacto[0].Name;
            idContacto = contacto[0].ContactId;
            idAsset = contacto[0].id;
        }
        List<String> lstString = new List<String>();

        List<User> calendarioPinares = [Select id from User where LastName Like 'Pinares - Mecánica Rápida'];        

        
        
        List<User> lstUser = [Select id,ContactId From User WHERE ContactId != null];
        CommunityCalendarController.getUserHistory(lstUser[0].id);
        CommunityCalendarController.getUserHistoryActive(lstUser[0].id);
        CommunityCalendarController.getVehicleRegistrationId(idAsset);
        CommunityCalendarController.getCalendarName(idAsesor);
        CommunityCalendarController.getAvailability();
        CommunityCalendarController.getCalendarsObjects('Diagnostico','BMW');
        
        CommunityCalendarController.createCalendarEventW('12',null,lstString,calendarioPinares[0].id,null,date.today(),date.today(),date.today(),null,null,null,null,null);

        CommunityCalendarController.getHoraGlobal('','Mecanica Rapida','Pinares');
        CommunityCalendarController.getMecanicosSucursal('','Mecanica Rapida','Pinares');
        
        CommunityCalendarController.getHoraGlobal('','Diagnostico','Pinares');
        CommunityCalendarController.getMecanicosSucursal('','Diagnostico','Pinares');
        CommunityCalendarController.getReportarFallo('Diagnostico','BMW');
        CommunityCalendarController.setTerminosYCondi();
        CommunityCalendarController.getTerminosYCondi();
        CommunityCalendarController.getPreguntas();
        CommunityCalendarController.getHoursAvailability();
        CommunityCalendarController.createCaseComunidad('test');
        Test.stopTest();
    }    
    // Clase mock para simular la respuesta del servicio externo
    private class CallExternalApiDatesMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);

            // Respuesta simulada del servicio externo
            res.setBody('{"opciones": ["26/01/2025", "27/01/2025"], "mensaje": "Opciones encontradas"}');
            return res;
        }
    }
}