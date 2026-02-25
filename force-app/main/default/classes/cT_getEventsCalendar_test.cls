@isTest(Seealldata = true)
public class cT_getEventsCalendar_test {
	private static testmethod void validated(){
    	cT_getEventsCalendar.getModelosVehiculos();
        List<Event> lstEventos = [SELECT Id,Asesor__c From Event WHERE Asesor__c != null ];
        System.debug(lstEventos);
        cT_getEventsCalendar.getUserHistory(lstEventos[0].Asesor__c,date.today());
    }
}