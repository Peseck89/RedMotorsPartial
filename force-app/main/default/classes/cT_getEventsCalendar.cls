public with sharing class cT_getEventsCalendar {
    @AuraEnabled
    public static List<User> getModelosVehiculos(){
        List<User> usr = [SELECT Id,Name FROM User WHERE Title LIKE '%Asesor%' Order by Name];
        return usr;
    }

    @AuraEnabled
    public static List<Event> getUserHistory(Id AsesorId , DateTime fechaBuscar ){
        System.debug( 'FechaBuscar');
        System.debug( fechaBuscar);
        //Datetime inputDatetime = Datetime.valueOf(fechaBuscar.replace(' ', 'T') + '.000Z');
        Datetime outputDatetime2 = fechaBuscar.addMinutes(1439);
        
        System.debug( 'fechaBuscar');
        System.debug( fechaBuscar);

        System.debug( 'outputDatetime2');
        System.debug( outputDatetime2);

        List<Event> evnt = [SELECT Id,StartDateTime,EndDateTime,Asesor__r.Name FROM Event WHERE Asesor__c = :AsesorId And StartDateTime >= :fechaBuscar AND StartDateTime <= :outputDatetime2 Order by StartDateTime desc ];
        return evnt;
    }
}