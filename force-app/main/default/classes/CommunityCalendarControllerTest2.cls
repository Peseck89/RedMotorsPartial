@IsTest
public class CommunityCalendarControllerTest2 {
@IsTest(SeeAllData=true) 
    public static void CommunityCalendarController () {

        Test.startTest();
        CommunityCalendarController.dummy();
        CommunityCalendarController.dummy2();
        CommunityCalendarController.dummy3();
        String marcaSel = 'marcaSel';
     	CommunityCalendarController.getMarcasConfig(marcaSel);
        community_config__c comConf = new community_config__c();
        comConf.SubServicios__c = 'Filtro de aire';
        comConf.Name = 'BMW test';	
		comConf.Marca__c = 'BMW';
        comConf.Servicios__c  = 'Mecanica Rapida';
        CommunityCalendarController.getSubServicios('BMW','Mecanica Rapida');
        
        CommunityCalendarController.getMarcasSubSer('BMW','Mecanica Rapida');

        //CommunityCalendarController.getCalendarAvailabilityForService('Mecanica Rapida');

        
        List<AsesorxCalendario__c> lstAsesor = [Select id,Calendario__c,Calendario__r.Name,Service_Territory__r.Name from AsesorxCalendario__c where Calendario__c != null AND Calendario__r.Name != null AND Calendario__c != 'a2q8N0000008QLMQA2' ];
		String idAsesor = lstAsesor[0].Calendario__c;
        String territory = lstAsesor[0].Service_Territory__r.Name;

        
        List<ServiceTerritory> lstService = [Select Id,Name FROM ServiceTerritory WHERE Name != null];
        CommunityCalendarController.convertListToMapServiceTAndCalendarId();
       	
        list<ServiceTerritory> lstServiceTerritory = [Select id,OperatingHoursId from ServiceTerritory WHERE OperatingHoursId != null LIMIT 1];
         Map<String, List<Time>> operatingHours = new Map<String, List<Time>> ();
        Time myTime = Time.newInstance(1, 2, 3, 4);
        Time myTime2 = Time.newInstance(2, 2, 3, 4);
        List<Time> lstTime = new List<Time>();
        lstTime.add(myTime);
        lstTime.add(myTime2);
        operatingHours.put(lstServiceTerritory[0].OperatingHoursId + '',lstTime );
        CommunityCalendarController.generateFakeEventsForServiceT(lstServiceTerritory,operatingHours,date.today(),null);
		//CommunityCalendarController.generateFakeEventsForServiceTOneDay(lstServiceTerritory,null,date.today(),null,date.today(),date.today());
        CommunityCalendarController.fetchUser();
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
        CommunityCalendarController.getNextUserCitation(idContacto);
		CommunityCalendarController.getNextVehiculeIdCitation(nombreAsset);
        CommunityCalendarController.getUserAssets(idContacto,'BMW');
        CommunityCalendarController.getOperartingHours();
        //CommunityCalendarController.getHoraGlobal('Motorrad','Mecanica Rapida','Pinares');
        CommunityCalendarController.getSucursalCapacity(idAsesor);
        //CommunityCalendarController.callExternalApi('', '0054U000009hiwMQAQ', '29/10/2024');
        List<User> calendarioPinares = [Select id from User where LastName Like 'Pinares - Mecánica Rápida'];        
        CommunityCalendarController.getHourAvailability(calendarioPinares[0].id,date.today());
        //CommunityCalendarController.cancelCitation('a4MPH0000000ert2AA');
        
        Test.stopTest();
    }    
}