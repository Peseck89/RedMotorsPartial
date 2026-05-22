public with sharing class CommunityCalendarController {


    @AuraEnabled
    public static void createCaseDesasocia(String vehiculoId,String motivoBaja){
       
        User userr = fetchUser();
        String cocheBuscado = '';
        List<Asset> lstAsset = [Select Id From Asset Where  AccountId = :userr.Contact?.AccountId ];
        if(lstAsset.size()>0){
            cocheBuscado = lstAsset[0].id;
        }else{
            
        }
        Case newCase = new Case();
        newCase.RecordTypeId = '012PH00000HBor9YAD';
        newCase.Origin = 'BMW Service Desasociar';
        newCase.Creado_por_service__c = true;
        newCase.FechaEntrada__c = Date.today();
        newCase.AccountId = userr.Contact?.AccountId;
        newCase.Subject = 'Se ha solicitado la desasociación de un vehiculo.';
        newCase.Description = 'Se ha solicitado la desasociación de este vehiculo, por el motivo: ' + motivoBaja ;
        if(lstAsset.size()>0){
            newCase.AssetId  = lstAsset[0].Id;
            newCase.AccountId = lstAsset[0].AccountId;
        }
        newCase.Priority = 'Media';
        newCase.Type = 'Solicitud';
        newCase.suppliedLastName__c = userr.Lastname;
        newCase.SuppliedName = userr.FirstName;
        newCase.Service_Territory1__c  = '0HhPH0000003NEb0AM';
        insert newCase;
        // return capacity;
    }

    @AuraEnabled
    public static void createCaseAsocia(String vinVehiculo,String codModelo,String matricula,String marca,String vehiculoTipo){
       
        User userr = fetchUser();
        String cocheBuscado = '';
        List<Asset> lstAsset = [Select Id,AccountId From Asset Where  AccountId = :userr.Contact?.AccountId ];
        if(lstAsset.size()>0){
            cocheBuscado = lstAsset[0].id;
        }else{
            cocheBuscado = '02i4U00000Hn9k8QAB';
        }

        Case newCase = new Case();
        newCase.RecordTypeId = '012PH00000HBor9YAD';
        newCase.Origin = 'BMW Service Contactanos';
        newCase.FechaEntrada__c = Date.today();
        newCase.Creado_por_service__c = true;
        newCase.Type = 'Solicitud';
        newCase.Priority = 'Media';
        newCase.Subject = 'Se ha solicitado el agregado de un nuevo vehiculo.';
        newCase.Description = 'Se ha solicitado el agregado de este vehiculo: Matricula - ' + matricula + ' ';
        if(lstAsset.size()>0){
            newCase.AssetId  = lstAsset[0].Id;
            newCase.AccountId = userr.Contact?.AccountId;
        }
        newCase.suppliedLastName__c = userr.Lastname;
        newCase.SuppliedName = userr.FirstName;
        newCase.Service_Territory1__c  = '0HhPH0000003NEb0AM';
        insert newCase;
        
        // return capacity;
    }


    @AuraEnabled(cacheable=true)
    public static List<community_config__c> getMarcasConfig(String marcaSel){
            List <community_config__c> userAssets = [Select Servicios__c,Servicio_con_acentos__c,Descripcion_de_servicio__c,Orden_servicio__c from community_config__c WHERE Marca__c =: marcaSel order by Orden_servicio__c];
            

                    return userAssets;
            
    }

    @AuraEnabled(cacheable=true)
    public static Boolean mandarMensaje(String cliente, String placa, String fecha, String calendarId){
        String placaVehiculo = '';

        if(placa != null){
            list<Asset> lstAsset = [SELECT Name FROM Asset WHERE Id =: placa];
            if(lstAsset.size()>0){
                placaVehiculo = lstAsset[0].Name;
            }
        }
        
        List<AsesorxCalendario__c> availableUsers = [Select Asesor__c,Asesor__r.Email,correoDeAsesor__c from AsesorxCalendario__c where Calendario__c=:calendarId ];
        String correoAsesor = '';
        for(AsesorxCalendario__c aseCal : availableUsers){
            correoAsesor = aseCal.correoDeAsesor__c;
        }
        List<User> lstUserC = new List<User> ();
        if(correoAsesor == '' || correoAsesor == null){
            lstUserC = [Select Id,Email From User Where Id =: availableUsers[0].Asesor__c];
            correoAsesor = lstUserC[0].Email;
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //mail.setReplyTo('escsol1f@gmail.com');
        //String correoEnviar = availableUsers[0].Asesor__r.Email;
        String ccAddresses = 'antonio.dorantesperez@outlook.com';
        //correoEnviar = 'antonio.dorantesperez@outlook.com';
        mail.setToAddresses(new String[]{correoAsesor});
        mail.setCcAddresses(new String[]{ccAddresses});
        mail.setSubject('Nueva solicitud de cita movil');
        mail.setHtmlBody('<html><body><p>Cliente: '+cliente+'</p><p>Placa: '+placaVehiculo+'</p><p>Dia: '+fecha+'</p><p>Solicita servicio móvil bajo solicitud</p></body></html>');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        return true;
    }

    @AuraEnabled(cacheable=true)
    public static List<Object> getPreguntas(){
        List<Cuestionario_Comunidad__c> lstCuestionario = [Select Id,Numero_de_pregunta__c,Pregunta__c FROM Cuestionario_Comunidad__c order by Numero_de_pregunta__c];
        if(lstCuestionario.size()>0){
            return lstCuestionario;
        }else{
            return null;
        }        
    }

    @AuraEnabled(cacheable=true)
    public static List<User> obtenerDatosUsuario(){
        List<User> estadoActual = new List<User>();
        Id userIdActual = UserInfo.getUserId();
        estadoActual = [Select Id,FirstName,Lastname,Email,UserName,MobilePhone From User Where Id =:userIdActual];

        return estadoActual;
    }

    //Saber si es Sincro
    @AuraEnabled(cacheable=true)
    public static Boolean saberEsSincronica(String marcaSel,String servicioSelec, String selectedService){
        if(servicioSelec == 'Mecanica Rapida'){
            servicioSelec = 'Mecánica Rápida';
        }else if(servicioSelec == 'Diagnostico'  ){
            servicioSelec = 'Diagnóstico';
        }else if(servicioSelec == 'Mecanica General'  ){
            servicioSelec = 'Mecánica General';
        }
        String sucursalBuscada = '%' + selectedService + ' - ' + servicioSelec;
        List<ServiceTerritory> lstServiceTerritory = [SELECT Id,cita_sincronica__c FROM ServiceTerritory WHERE ComunidadServiceName__c LIKE :sucursalBuscada];
        if(lstServiceTerritory.size() > 0){
            return lstServiceTerritory[0].cita_sincronica__c;
        }else {
            return false;
        }
    }

    //PROCESO DE BUSQUEDA 
    @AuraEnabled(cacheable=true)
    public static List<Object> getHoraGlobal(String marcaSel,String servicioSelec, String selectedService){
        if(servicioSelec == 'Mecanica Rapida'){
            servicioSelec = 'Mecánica Rápida';
        }else if(servicioSelec == 'Diagnostico'  ){
            servicioSelec = 'Diagnóstico';
        }else if(servicioSelec == 'Mecanica General'  ){
            servicioSelec = 'Mecánica General';
        }
        Boolean extraValida = false;
        Date currentDate = Date.today();
        // Set the time to midnight (00:00:00)
        Time midnightTime = Time.newInstance(0, 0, 0, 0);
        // Combine the date and time to get the DateTime value
        Datetime resultDateTime = Datetime.newInstanceGmt(currentDate.year(), currentDate.month(), currentDate.day(), midnightTime.hour(), midnightTime.minute(), midnightTime.second());
        String formattedDateTime = resultDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');


        List <Hora_global__c> horasGlobales = new List <Hora_global__c> ();
        List <hora_extraordinaria__c> horasExtra = new List <hora_extraordinaria__c> ();
        String sucursalBuscada = '%' + selectedService + ' - ' + servicioSelec;
        List<ServiceTerritory> lstServiceTerritory = [SELECT Id FROM ServiceTerritory WHERE ComunidadServiceName__c LIKE :sucursalBuscada];
        if(lstServiceTerritory.size() > 0){

            if(marcaSel == 'Motorrad'){
                horasGlobales = [SELECT Tipo_de_Cita__c,Tiempo_de_cita_2__c,kmCero__c, kmMil__c, kmCincomil__c, kmDiezmil__c, kmQuincemil__c, kmVeintemil__c, kmVeinticinco__c, kmTreinta__c, kmTreintacinco__c, kmCuarenta__c, kmCuarentacinco__c FROM Hora_global__c WHERE Service_Territory__c = : lstServiceTerritory[0].id ];
                horasExtra = [SELECT Tipo_de_Cita__c,Tiempo_de_cita_2__c,Hora_y_Fecha_de_Inicio__c,Hora_y_Fecha_de_Fin__c,kmCero__c, kmMil__c, kmCincomil__c, kmDiezmil__c, kmQuincemil__c, kmVeintemil__c, kmVeinticinco__c, kmTreinta__c, kmTreintacinco__c, kmCuarenta__c, kmCuarentacinco__c FROM hora_extraordinaria__c WHERE Service_Territory__c = : lstServiceTerritory[0].id ];
            }else{
                horasGlobales = [SELECT Tipo_de_Cita__c,Tiempo_de_cita_2__c FROM Hora_global__c WHERE Service_Territory__c = : lstServiceTerritory[0].id ];
                horasExtra = [SELECT Tipo_de_Cita__c,Tiempo_de_cita_2__c,Hora_y_Fecha_de_Inicio__c,Hora_y_Fecha_de_Fin__c FROM hora_extraordinaria__c WHERE Service_Territory__c = : lstServiceTerritory[0].id ];
            }


           


        }        
        
        if (extraValida) {
        return horasExtra;
        }else {
        return horasGlobales;
        }
        
            
    }



    @AuraEnabled(cacheable=true)
    public static List<Object> getSubServicios(String marcaSel,String servicioSelec){
        List <community_config__c> userAssets = [Select SubServicios__c from community_config__c WHERE Marca__c =: marcaSel AND Servicios__c =: servicioSelec];

        List<Object> options = new List<Object>();
        String strID = 'Test';
        Schema.DescribeFieldResult fieldResult = community_config__c.SubServicios__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            for (community_config__c comValue : userAssets) {                
                if (comValue.SubServicios__c.contains( f.getValue())) {
                    List<Object> newRow = new List<Object> ();
                    newRow.add(f.getValue()) ;
                    List<document>  lstDoc = [SELECT id,name FROM document WHERE name =:f.getValue()];
                    if (lstDoc.size()>0) {
                        strID = lstDoc[0].id;   
                    }else{
                        List<document>  lstDoc2 = [SELECT id,name FROM document WHERE name = 'Generico'];
                        strID = lstDoc2[0].id; 
                    }
                    newRow.add(strID) ;
                    options.add( newRow);    
                }                
            }
        }    
        
        return options;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getMarcasSubSer(String marcaSel,String servicioSelec){
            
        List <community_config__c> userAssets = [Select SubServicios__c from community_config__c WHERE Marca__c =: marcaSel AND Servicios__c =: servicioSelec];
        List <String> lstString = new List<String>();
        for (community_config__c subSer : userAssets) {
            lstString.addAll(subSer.SubServicios__c.split(';'));
        }
        return lstString;       
    }

    @AuraEnabled(cacheable=true)
    public static List<Asset> getAssetBuscado(String cocheBuscado){
            
        List <Asset> userAssets = [Select id,Name,AccountId,NumeroDeChasis__c,marca__c,modelo__c,Anio__c,color__c,numeroDePlaca__c from Asset WHERE Name =: cocheBuscado];
        
        return userAssets;       
    }

    @AuraEnabled(cacheable=true)
    public static Decimal getMecanicosSucursal(String marcaSel,String servicioSelec, String selectedService){
        
        Date currentDate = Date.today();
        // Set the time to midnight (00:00:00)
        Time midnightTime = Time.newInstance(0, 0, 0, 0);
        // Combine the date and time to get the DateTime value
        Datetime resultDateTime = Datetime.newInstanceGmt(currentDate.year(), currentDate.month(), currentDate.day(), midnightTime.hour(), midnightTime.minute(), midnightTime.second());
        String formattedDateTime = resultDateTime.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');




        Decimal cantidadMecanicos = 0;
        if(servicioSelec == 'Mecanica Rapida'){
            servicioSelec = 'Mecánica Rápida';
        }else if(servicioSelec == 'Diagnostico'  ){
            servicioSelec = 'Diagnóstico';
        }else if(servicioSelec == 'Mecanica General'  ){
            servicioSelec = 'Mecánica General';
        }
        List <Hora_global__c> horasGlobales = new List <Hora_global__c> ();
        String sucursalBuscada =  selectedService + ' - ' + servicioSelec;
        List<User> lstServiceTerritory = [SELECT Cantidad_de_Mecanicos__c FROM User  WHERE LastName LIKE :sucursalBuscada];
        if(lstServiceTerritory.size() > 0){
            cantidadMecanicos = lstServiceTerritory[0].Cantidad_de_Mecanicos__c;
        }
        sucursalBuscada = selectedService + ' - ' + servicioSelec;
        if(servicioSelec == 'Mecanica Rapida'){
            servicioSelec = 'Mecánica Rápida';
        }else if(servicioSelec == 'Diagnostico'  ){
            servicioSelec = 'Diagnóstico';
        }else if(servicioSelec == 'Mecanica General'  ){
            servicioSelec = 'Mecánica General';
        }
        sucursalBuscada =  selectedService + ' - ' + servicioSelec;
        List<ServiceTerritory> lstService = [SELECT Id, ComunidadServiceName__c FROM ServiceTerritory WHERE ComunidadServiceName__c LIKE :sucursalBuscada];
        if(lstService.size()>0){
            List <hora_extraordinaria__c> horasExtra = new List <hora_extraordinaria__c> ();
            // horasExtra = [SELECT Mecanicos__c,Hora_y_Fecha_de_Inicio__c,Hora_y_Fecha_de_Fin__c FROM hora_extraordinaria__c WHERE Service_Territory__c = : lstService[0].id ];
            // if(horasExtra.size()>0){
            //     if(horasExtra[0].Hora_y_Fecha_de_Inicio__c <= resultDateTime  && horasExtra[0].Hora_y_Fecha_de_Fin__c >= Datetime.now()){
            //         cantidadMecanicos = horasExtra[0].Mecanicos__c;
            //     }
                
            // }
        }
        

        return cantidadMecanicos;   
    }

    @AuraEnabled
    public static List<Object> getAsesoresDeCalendario() {
       
        List<Object> capacityBySucursal = [Select Asesor__c, Calendario__c from AsesorxCalendario__c  ];
        return capacityBySucursal;
    }
        

    
    @AuraEnabled
    public static List<Object> getCalendarAvailabilityForService(String selectedService) {
        
        String likeVariable = '%'+selectedService+'%';
        if(likeVariable == '%Mecanica Rapida%'  ){
            likeVariable = '%Mecánica Rápida%';
        }else if(likeVariable == '%Diagnostico%'  ){
            likeVariable = '%Diagnóstico%';
        }else if(likeVariable == '%Mecanica General%'  ){
            likeVariable = '%Mecánica General%';
        }

        list<Object> capacidadMecanicos = [Select Cantidad_de_Mecanicos__c , id From User Where Name like: likeVariable ];
        String likeVariable2 = '%'+selectedService+'%';
        if(likeVariable2 == '%Mecanica Rapida%'  ){
            likeVariable2 = '%Mecánica Rápida%';
        }else if(likeVariable2 == '%Diagnostico%'  ){
            likeVariable2 = '%Diagnóstico%';
        }else if(likeVariable2 == '%Mecanica General%'  ){
            likeVariable2 = '%Mecánica General%';
        }
        List<Object> capacityBySucursal = [Select Count(Asesor__c), Calendario__r.Id from AsesorxCalendario__c where Service_Territory__r.ComunidadServiceName__c like: likeVariable2 group by Calendario__r.Id];
        if(capacityBySucursal.size()>0){

        }else {
            //proceso por si no es el mismo service territory relacionado
            capacityBySucursal = [Select Count(Asesor__c), Calendario__r.Id from AsesorxCalendario__c where Calendario__r.Name like: likeVariable group by Calendario__r.Id];
        }

        List<community_config__c> lstComm = [SELECT Id FROM community_config__c WHERE Servicios__c LIKE :likeVariable OR Servicio_con_acentos__c LIKE :likeVariable ];
        // List of spaces that are going to be unavailable in the community based on events and Capacity of "Asesores by Sucursal"
        List<Event_Shadow__c> events = [Select Id,Tipo_de_cita__c, ActivityDate__c,Asesor__c, StartDateTime__c, EndDateTime__c, OwnerId /*, ActivityDateTime__c*/ from
        Event_Shadow__c where OwnerId IN (Select Calendario__c from AsesorxCalendario__c where Calendario__r.Name like: likeVariable) and OwnerId != null and Estado2__c <>'Cancelada' and ActivityDate__c > :Date.today() LIMIT 100];

        List<Event_Shadow__c> events2 = [Select Id,Tipo_de_cita__c, ActivityDate__c,Asesor__c,Calendar__c,Calendar__r.LastName, StartDateTime__c, EndDateTime__c, OwnerId /*, ActivityDateTime__c*/ from
        Event_Shadow__c where OwnerId IN (Select Asesor__c from AsesorxCalendario__c where Service_Territory__r.ComunidadServiceName__c like: likeVariable2) and Estado2__c <>'Cancelada' and ActivityDate__c > :Date.today() LIMIT 100];
        
        List<Object> asesoresByCalendar = [select Calendario__r.LastName, Asesor__c from AsesorxCalendario__c];
        List<AsesorxCalendario__c> asesoresXCalendar = [select Calendario__r.LastName, Asesor__c,Calendario__c from AsesorxCalendario__c];
        List<Object> eventsResult = new List<Object>();
        List<Object> eventsResult2 = new List<Object>();
        for (Event_Shadow__c a: events){
            List<Object> newRow = new List<Object> ();
                                    
            Long StartTimeGetTime = a.StartDateTime__c.getTime();
            Long EndTimeGetTime = a.EndDateTime__c.getTime();
            
            Date activityDate = date.newinstance(a.ActivityDate__c.year(), a.ActivityDate__c.month(), a.ActivityDate__c.day());
            newRow.add(activityDate);
            newRow.add(a.StartDateTime__c.format('h:mm a'));
            newRow.add(a.EndDateTime__c.format('h:mm a'));
            newRow.add(a.Asesor__c);
            newRow.add(a.OwnerId);
            newRow.add(a.Tipo_de_cita__c);
            eventsResult.add(newRow);
        }

        for (Event_Shadow__c a2: events2){
            List<Object> newRow = new List<Object> ();
                                    
            Long StartTimeGetTime = a2.StartDateTime__c.getTime();
            Long EndTimeGetTime = a2.EndDateTime__c.getTime();
            
            Date activityDate = date.newinstance(a2.ActivityDate__c.year(), a2.ActivityDate__c.month(), a2.ActivityDate__c.day());
            newRow.add(activityDate);
            newRow.add(a2.StartDateTime__c.format('h:mm a'));
            newRow.add(a2.EndDateTime__c.format('h:mm a'));
            newRow.add(a2.Asesor__c);
            String nombreCal = a2.Calendar__r.LastName;
            String nombreSinSimbolo = likeVariable.replace('%','');
            //newRow.add(a2.Calendar__c);
            Boolean cambia = false;
            String variableCalendario = '';
            if(nombreCal.contains(nombreSinSimbolo)){
                newRow.add(a2.Calendar__c);
            }else {
                for(AsesorxCalendario__c obj : asesoresXCalendar){
                    if(a2.Asesor__c == obj.Asesor__c ){
                        String nombreCal2 = obj.Calendario__r.LastName;
                        if(nombreCal2.contains(nombreSinSimbolo)){
                            cambia = true;
                            variableCalendario = obj.Calendario__c;
                            newRow.add(variableCalendario);

                        }
                    }
                }
                
            }
            // if(cambia){
            //     newRow.add(variableCalendario);
            // }
            
            newRow.add(a2.Tipo_de_cita__c);
            eventsResult2.add(newRow);
        }
        
        List<Object> joinEvents = new List<Object>();
        joinEvents.addAll(eventsResult);
        joinEvents.addAll(eventsResult2);
        //proceso de creacion de eventos no servicio
        joinEvents.addAll(generateNoAvailabilityDataWholeCompany(likeVariable));
        joinEvents.addAll(generateNoAvailabilityDataForSucursal());
        joinEvents.addAll(generateNoAvailabilityDataForSpecificService());
        
        List<Object> results = new List <Object> ();
        
        // [0] = Capacity by Sucursal 		| [1] = Asesores By Calendar 		| [2] = Event Results		| [3] = Mecanicos by Sucursal
        results.add(capacityBySucursal);
        results.add(asesoresByCalendar);
        results.add(joinEvents);
        results.add(capacidadMecanicos);
        return results;
    }
    
    
    @AuraEnabled
    public static Map<String, List<Time>> convertListToMapOperatingHour () {
        List<OperatingHours> operatingHours = [Select Id, format(Hora_inicio_comunidad__c), format(Hora_fin_comunidad__c) from OperatingHours];
        Map<String, List<Time>> result = new Map<String, List<Time>>();
        if (operatingHours.size() > 0){
            for (OperatingHours opp: operatingHours){
                List<Time> hours = new List<Time>();
                hours.add(opp.Hora_inicio_comunidad__c);
                hours.add(opp.Hora_fin_comunidad__c);
                result.put(opp.Id, hours);
            }
        }
        return result;
    }
    
    
    @AuraEnabled
    public static Map<Object, List<Object>> convertListToMapServiceTAndCalendarId () {
        AggregateResult[] calendarByServiceTerritory = [Select Calendario__c, Service_Territory__c, Max(Asesor__c) max, count(Asesor__c)w1 from AsesorxCalendario__c group by Calendario__c, Service_Territory__c ];
        Map<Object, List<Object>> result = new Map<Object, List<Object>>();
        if (calendarByServiceTerritory.size() > 0){
            for (Integer i=0; i<calendarByServiceTerritory.size(); i++){
                List<Object> calendarAndRandomAsesor = new List<Object>();
                calendarAndRandomAsesor.add(calendarByServiceTerritory[i].get('Calendario__c'));
                calendarAndRandomAsesor.add(calendarByServiceTerritory[i].get('max'));
                calendarAndRandomAsesor.add(calendarByServiceTerritory[i].get('w1'));
                result.put(calendarByServiceTerritory[i].get('Service_Territory__c'), calendarAndRandomAsesor);
            }
        }
        return result;
    }
    
    @AuraEnabled 
    public static List<Object> generateFakeEventsForServiceT (List<ServiceTerritory> serviceTerritory, Map<String, List<Time>> operatingHours, Date currentDate, List<Object> events){
        // Map<Object, List<Object>> calendarAndServiceT = convertListToMapServiceTAndCalendarId();
        // for(ServiceTerritory service: serviceTerritory){
        //     List<Object> newRow = new List<Object> ();
        //     List<Object> newRow2 = new List<Object> ();
            
        //     Datetime startDate = Datetime.newInstance(currentDate, operatingHours.get(service.OperatingHoursId).get(0)); // 0 = Start Time
        //     Datetime endDate = Datetime.newInstance(currentDate, operatingHours.get(service.OperatingHoursId).get(1)); 	 // 1 = End Time
        //     newRow.add(currentDate);
        //     newRow.add('04:00 AM'); 	// 0 = Start Time
        //     newRow.add(endDate.format('h:mm a')); 	// 1 = End Time
        //     newRow.add(calendarAndServiceT.get(service.Id)[0]);// Asesor Random
        //     newRow.add(calendarAndServiceT.get(service.Id)[0]);// Asesor Random
        //     newRow.add('Asesor');
        //     newRow.add(calendarAndServiceT.get(service.Id)[0]); 
        //     Integer maxNumberOfAsesores = Integer.valueOf(calendarAndServiceT.get(service.Id)[2]); 

        //     newRow2.add(currentDate);
        //     newRow2.add('07:30 AM'); 	// 0 = Start Time
        //     newRow2.add('07:30 AM'); 	// 1 = End Time
        //     newRow2.add(calendarAndServiceT.get(service.Id)[0]);// Asesor Random
        //     newRow2.add(calendarAndServiceT.get(service.Id)[0]);// Asesor Random
        //     newRow2.add('Asesor');
        //     newRow2.add(calendarAndServiceT.get(service.Id)[0]); 


        //     for(Integer i = 0; i < maxNumberOfAsesores;i++){
        //         if(!test.isRunningTest()){
        //             events.add(newRow);
        //             events.add(newRow2);
        //         }
                
        //     }
        // }

        return events;
    }
    
    @AuraEnabled 
    public static List<Object> generateFakeEventsForServiceTOneDay (List<ServiceTerritory> serviceTerritory, Map<String, List<Time>> operatingHours, Date currentDate, List<Object> events, Datetime startDateTime, Datetime endDateTime){
        Map<Object, List<Object>> calendarAndServiceT = convertListToMapServiceTAndCalendarId();
    
	    //List<Object> newRow = new List<Object> ();
            
        for(ServiceTerritory service: serviceTerritory){
            if (calendarAndServiceT.containsKey(service.Id)) {
                List<Object> newRow = new List<Object> ();
                List<Object> newRow2 = new List<Object> ();
    
                Datetime startDate = startDateTime; // 0 = Start Time
                Datetime endDate = endDateTime; 	 // 1 = End Time
                
                DateTime dt = currentDate +1;
                String formattedDate = dt.format('yyyy-MM-dd');
                String calendar = String.valueof(calendarAndServiceT.get(service.Id)[0]);
                   List<AsesorxCalendario__c> lstAseCal = [Select  Service_Territory__r.ComunidadServiceName__c from AsesorxCalendario__c where Calendario__c =:calendar ];
                Integer cantidadDeAsesores = lstAseCal.size();
                newRow.add(formattedDate);                        
                newRow.add('04:00 AM'); 	// 0 = Start Time
                newRow.add(endDate.format('h:mm a')); 	// 1 = End Time
                newRow.add(calendarAndServiceT.get(service.Id)[0]);
                newRow.add(calendarAndServiceT.get(service.Id)[0]);// Asesor Random
                newRow.add('Asesor');
                newRow.add(calendarAndServiceT.get(service.Id)[0]); 
    
                newRow2.add(formattedDate);
                newRow2.add('07:30 AM'); 	// 0 = Start Time
                newRow2.add('07:30 AM'); 	// 1 = End Time
                newRow2.add(calendarAndServiceT.get(service.Id)[0]);// Asesor Random
                newRow2.add(calendarAndServiceT.get(service.Id)[0]);// Asesor Random
                newRow2.add('Asesor');
                newRow2.add(calendarAndServiceT.get(service.Id)[0]); 
    
                Integer maxNumberOfAsesores = Integer.valueOf(calendarAndServiceT.get(service.Id)[2]); 
                for(Integer i = 0; i < maxNumberOfAsesores;i++){
                   if(!test.isRunningTest()){
                    events.add(newRow);
                    events.add(newRow2);
                   }
                }
            }           
        }
        return events;
    }
    
    
    @AuraEnabled
    public static List<Object> generateNoAvailabilityDataWholeCompany (String likeVariable/*, List<Object> asesoresByCalendar, List<Object> capacityBySucursal*/) {
        List<Object> events = new List<Object> ();
        // serviceTWOH = service territories with operating hours
        List<AsesorxCalendario__c> lstAseCal =  new List<AsesorxCalendario__c>();
        List<ServiceTerritory> serviceTerritory = [Select Id, ComunidadServiceName__c, OperatingHoursId from ServiceTerritory where ComunidadServiceName__c like: likeVariable];
        if(serviceTerritory.size()>0){

        }else {
            //proceso por si no es el mismo service territory relacionado
            lstAseCal = [Select  Service_Territory__r.ComunidadServiceName__c from AsesorxCalendario__c where Calendario__r.Name like: likeVariable];
            if(lstAseCal.size()>0){
                List<String> calendarios = new List<String>();
                for(AsesorxCalendario__c asec : lstAseCal){
                    calendarios.add(asec.Service_Territory__r.ComunidadServiceName__c);
                }
                serviceTerritory = [Select Id, ComunidadServiceName__c, OperatingHoursId from ServiceTerritory where ComunidadServiceName__c In: calendarios];
            }
        }

        Map<String, List<Time>> operatingHours = convertListToMapOperatingHour();
        List<NoDisponibilidad_Servicio__c> wholeCompany = [Select Id, Hora_y_Fecha_de_Inicio__c, Hora_y_Fecha_de_Fin__c from NoDisponibilidad_Servicio__c where Hora_y_Fecha_de_Fin__c>= :date.today() and Activo__c=True and Nivel_de_aplicaci_n__c ='Todas las sucursales' order by Hora_y_Fecha_de_Inicio__c desc];
        if(!wholeCompany.isEmpty()){
            // This list is going to be used as simulation of Events in Calendar. It means the spaces are set of hours not available in the Community.
            for (NoDisponibilidad_Servicio__c record: wholeCompany){
                
                Date firstDay = date.newinstance(record.Hora_y_Fecha_de_Inicio__c.year(), record.Hora_y_Fecha_de_Inicio__c.month(), record.Hora_y_Fecha_de_Inicio__c.day());
                Date lastDay = date.newinstance(record.Hora_y_Fecha_de_Fin__c.year(), record.Hora_y_Fecha_de_Fin__c.month(), record.Hora_y_Fecha_de_Fin__c.day());
                if(firstDay < lastDay){
                    Date currentDate = firstDay;
                    while(currentDate <= lastDay){
                        events = generateFakeEventsForServiceT(serviceTerritory, operatingHours, currentDate, events);
                        currentDate = Date.newInstance(currentDate.year(), currentDate.month(), currentDate.day()+1);
                    }
                }
                if(firstDay == lastDay){
                    events = generateFakeEventsForServiceTOneDay(serviceTerritory, operatingHours, firstDay, events, record.Hora_y_Fecha_de_Inicio__c, record.Hora_y_Fecha_de_Fin__c);
                }
        	}
        }
        return events;
    }
    
    @AuraEnabled
    public static List<Object> generateNoAvailabilityDataForSucursal () {
        List<Object> events = new List<Object> ();
        Map<String, List<Time>> operatingHours = convertListToMapOperatingHour();
        List<NoDisponibilidad_Servicio__c> noAvailabilityBySucursal = [Select Sucursal__c, Hora_y_Fecha_de_Inicio__c, Hora_y_Fecha_de_Fin__c from NoDisponibilidad_Servicio__c where  Hora_y_Fecha_de_Fin__c>= TODAY and Activo__c=True and Nivel_de_aplicaci_n__c ='Toda la sucursal' order by Hora_y_Fecha_de_Inicio__c desc];
        List<AsesorxCalendario__c> lstAseCal =  new List<AsesorxCalendario__c>();
        if(noAvailabilityBySucursal.size()>0){
            // This list is going to be used as simulation of Events in Calendar. It means the spaces are set of hours not available in the Community.
            for (NoDisponibilidad_Servicio__c record: noAvailabilityBySucursal){
                String likeVariable =  '%'+ record.Sucursal__c +'%';
                List<serviceTerritory> serviceTerritory = [Select Id, ComunidadServiceName__c, OperatingHoursId from ServiceTerritory where ComunidadServiceName__c like: likeVariable];
                if(serviceTerritory.size()>0){

                }else {
                    //proceso por si no es el mismo service territory relacionado
                    lstAseCal = [Select  Service_Territory__r.ComunidadServiceName__c from AsesorxCalendario__c where Calendario__r.Name like: likeVariable];
                    if(lstAseCal.size()>0){
                        List<String> calendarios = new List<String>();
                        for(AsesorxCalendario__c asec : lstAseCal){
                            calendarios.add(asec.Service_Territory__r.ComunidadServiceName__c);
                        }
                        serviceTerritory = [Select Id, ComunidadServiceName__c, OperatingHoursId from ServiceTerritory where ComunidadServiceName__c In: calendarios];
                    }
                }
                Date firstDay = date.newinstance(record.Hora_y_Fecha_de_Inicio__c.year(), record.Hora_y_Fecha_de_Inicio__c.month(), record.Hora_y_Fecha_de_Inicio__c.day());
                Date lastDay = date.newinstance(record.Hora_y_Fecha_de_Fin__c.year(), record.Hora_y_Fecha_de_Fin__c.month(), record.Hora_y_Fecha_de_Fin__c.day());
                if(firstDay < lastDay){
                    Date currentDate = firstDay;
                    while(currentDate <= lastDay){
                        events = generateFakeEventsForServiceT(serviceTerritory, operatingHours, currentDate, events);
                        currentDate = Date.newInstance(currentDate.year(), currentDate.month(), currentDate.day()+1);
                    }
                }
                if(firstDay == lastDay){
                    events = generateFakeEventsForServiceTOneDay(serviceTerritory, operatingHours, firstDay, events, record.Hora_y_Fecha_de_Inicio__c, record.Hora_y_Fecha_de_Fin__c);
                }
        	}
        }
        return events;
    }
    
    @AuraEnabled
    public static List<Object> generateNoAvailabilityDataForSpecificService () {
        List<Object> events = new List<Object> ();
        Map<String, List<Time>> operatingHours = convertListToMapOperatingHour();
        List<NoDisponibilidad_Servicio__c> noAvailabilityByService = [Select Service_Territory__r.ComunidadServiceName__c, Hora_y_Fecha_de_Inicio__c, Hora_y_Fecha_de_Fin__c from NoDisponibilidad_Servicio__c where Hora_y_Fecha_de_Fin__c>= TODAY and Activo__c=True and Nivel_de_aplicaci_n__c ='Servicio Específico' ];
        
        if(noAvailabilityByService.size()>0){
            // This list is going to be used as simulation of Events in Calendar. It means the spaces are set of hours not available in the Community.
            for (NoDisponibilidad_Servicio__c record: noAvailabilityByService){
                String likeVariable =  '%'+ record.Service_Territory__r.ComunidadServiceName__c +'%';
                List<AsesorxCalendario__c> lstAseCal =  new List<AsesorxCalendario__c>();
                List<serviceTerritory> serviceTerritory = [Select Id, ComunidadServiceName__c, OperatingHoursId from ServiceTerritory where ComunidadServiceName__c like: likeVariable];
                if(serviceTerritory.size()>0){

                }else {
                    //proceso por si no es el mismo service territory relacionado
                    lstAseCal = [Select  Service_Territory__r.ComunidadServiceName__c from AsesorxCalendario__c where Calendario__r.Name like: likeVariable];
                    if(lstAseCal.size()>0){
                        List<String> calendarios = new List<String>();
                        for(AsesorxCalendario__c asec : lstAseCal){
                            calendarios.add(asec.Service_Territory__r.ComunidadServiceName__c);
                        }
                        serviceTerritory = [Select Id, ComunidadServiceName__c, OperatingHoursId from ServiceTerritory where ComunidadServiceName__c In: calendarios];
                    }
                }
                Date firstDay = date.newinstance(record.Hora_y_Fecha_de_Inicio__c.year(), record.Hora_y_Fecha_de_Inicio__c.month(), record.Hora_y_Fecha_de_Inicio__c.day());
                Date lastDay = date.newinstance(record.Hora_y_Fecha_de_Fin__c.year(), record.Hora_y_Fecha_de_Fin__c.month(), record.Hora_y_Fecha_de_Fin__c.day());
                if(firstDay < lastDay){
                    Date currentDate = firstDay;
                    while(currentDate <= lastDay){
                        events = generateFakeEventsForServiceT(serviceTerritory, operatingHours, currentDate, events);
                        currentDate = Date.newInstance(currentDate.year(), currentDate.month(), currentDate.day()+1);
                    }
                }
                if(firstDay == lastDay){
                    events = generateFakeEventsForServiceTOneDay(serviceTerritory, operatingHours, firstDay, events, record.Hora_y_Fecha_de_Inicio__c, record.Hora_y_Fecha_de_Fin__c);
                }
        	}
        }
        
        return events;
    }
    
   @AuraEnabled 
    public static user fetchUser(){
       User u = [select Id,FirstName,LastName, Name, ProfileId,Contact.AccountId, Profile.Name, ContactId, Contact.Name, Contact.Email, Contact.Phone from User where id =: userInfo.getUserId()];
       return u;
    }

    @AuraEnabled 
    public static Object getNextUserCitation(Id contactRelatedToUser){
        //Id contactRelatedToUser = [Select ContactId from User where Id =: '0058N000000sq4xQAA' limit 1].ContactId;
        //userId='0038N000006hxhgQAA';
        List<Contact> lstAccRelated = [Select AccountId FROM Contact WHERE Id =: contactRelatedToUser];
        List<Event_Shadow__c> event = [Select Id, StartDateTime__c, WhatId__c, WhatId__r.Name, Location__c, CalendarName__c,Tipo_de_cita__c from Event_Shadow__c where WhatId__c IN 
                       (Select Id from Asset where AccountId =: lstAccRelated[0].AccountId) 
                       and StartDateTime__c>= TODAY
                       and Estado2__c <>'Cancelada' and ActivityDate__c > :Date.today()];
        if(!event.isEmpty()){
            return event;
        }
        return '';
    }
    
    @AuraEnabled 
    public static Object getNextVehiculeIdCitation(String vehiculeId){
        List<Event_Shadow__c> event = [Select Id, StartDateTime__c from Event_Shadow__c where Activo__r.Name =: vehiculeId
                                       and StartDateTime__c>= TODAY
                                       and ActivityDate__c > :Date.today()
                                       and Estado2__c <>'Cancelada' limit 1];
        if(event.size()>0){
            return event;
        }
        return '';
    }
    
    @AuraEnabled
    public static Object getUserAssets(String contactId,String modeoSel){
        String accId = '';
        List<Contact> lstContact = [Select AccountId From Contact where Id =: contactId ];
        List <Asset> userAssets  = new List <Asset>();
        if(lstContact.size()>0){
            accId = lstContact[0].AccountId;
        }
        if(modeoSel == 'Motorrad'){
            modeoSel = 'Moto BMW';
            userAssets = [Select Id, Name, Anio__c, marca__c, modelo__c, color__c, numeroDePlaca__c from Asset where AccountId =: accId AND marca__c =: modeoSel AND Tipo_de_veh_culo__c = 'Motocicleta'];
        }else {
            userAssets = [Select Id, Name, Anio__c, marca__c, modelo__c, color__c, numeroDePlaca__c from Asset where AccountId =: accId AND marca__c =: modeoSel AND Tipo_de_veh_culo__c != 'Motocicleta'];
        }

         
        if(userAssets.size()>0){
            return userAssets;
        }
        return '';
    }

    @AuraEnabled
    public static Object getOperartingHours(){
        Map<Object, List<Object>> serviceTCalendar = convertListToMapServiceTAndCalendarId();
        List <List<Object>> result = new List<List<Object>>();
        if(serviceTCalendar.size()>0){
            List <ServiceTerritory> opsHours = [Select Id, ComunidadServiceName__c, OperatingHoursId, format(OperatingHours.Hora_inicio_comunidad__c), format(OperatingHours.Hora_fin_comunidad__c) from ServiceTerritory];
            if(opsHours.size()>0){
                for(ServiceTerritory opHour: opsHours){
                    if(!test.isRunningTest() && serviceTCalendar.get(opHour.Id) != null){
                        List<Object> newLine = new List<Object>();
                        newline.add(opHour.Id);
                        newline.add(serviceTCalendar.get(opHour.Id)[0]); //To get the CalendarId

                        Datetime inicio = Datetime.newInstance(Date.today(), opHour.OperatingHours.Hora_inicio_comunidad__c);
                        Datetime fin 	= Datetime.newInstance(Date.today(), opHour.OperatingHours.Hora_fin_comunidad__c);
                        newline.add(inicio.format('h:mm a'));
                        newline.add(fin.format('h:mm a'));
                        result.add(newline);
                    }
                   
            	}
                return result;
        	}
        	return result;
        }
        return result;
    }
       
    @AuraEnabled 
    public static Object getSetupInformation(String marcaSel){
        
        List<Object> results = new List <Object> ();
        User userr = fetchUser();
        Id contactRelatedToUser = null;
        if(!test.isRunningTest()){
        	contactRelatedToUser = [Select ContactId from User where Id =: userr.Id limit 1].ContactId;
        }else{
            
            contactRelatedToUser = [Select ContactId from User where ContactId !=null limit 1].ContactId;
        }
        
        Object nextCitation = getNextUserCitation(contactRelatedToUser);
        Object userAssets = getUserAssets(contactRelatedToUser,marcaSel);
        Object availabilityInformation = getAvailability();
        Object sucursalOperatingHours = getOperartingHours();
        
        //Case dataAccess = [Select Id, CreatedDate, LastModifiedById from Case];
        //lstObj => ["0Hh8N00000009ZLSAY", "0054U000009hiwWQAQ", "8:00 AM", "5:00 PM"] este es el formato
        List<ServiceTerritory> lstService = [SELECT ID,cita_sincronica__c,ComunidadServiceName__c,OperatingHours.Hora_inicio_comunidad__c,OperatingHours.Hora_fin_comunidad__c ,
        OperatingHours.Hora_inicio_lunes__c,OperatingHours.Hora_inicio_martes__c,OperatingHours.Hora_inicio_miercoles__c,OperatingHours.Hora_inicio_jueves__c,OperatingHours.Hora_inicio_viernes__c,OperatingHours.Hora_inicio_sabado__c ,
        OperatingHours.Hora_fin_lunes__c,OperatingHours.Hora_fin_martes__c,OperatingHours.Hora_fin_miercoles__c,OperatingHours.Hora_fin_jueves__c,OperatingHours.Hora_fin_viernes__c,OperatingHours.Hora_fin_sabado__c FROM ServiceTerritory WHERE IsActive = true];
        List <List<Object>> result = new List<List<Object>>();
        List <List<Object>> resultL = new List<List<Object>>();
        List <List<Object>> resultM = new List<List<Object>>();
        List <List<Object>> resultMi = new List<List<Object>>();
        List <List<Object>> resultJ = new List<List<Object>>();
        List <List<Object>> resultV = new List<List<Object>>();
        List <List<Object>> resultSa = new List<List<Object>>();
        List<List<Object>> lstObject = new List<List<Object>>();
        List<No_disponibilidad_recurrente__c> lstRecurrencia = [Select Hora_Inicial_Recurrente__c,Asesor__c, Hora_Final_Recurrente__c, Calendario__c,Lunes__c,Martes__c,Miercoles__c,Jueves__c,Viernes__c,Sabado__c From No_disponibilidad_recurrente__c WHERE Activo__c = true];
        
        
        for(No_disponibilidad_recurrente__c noDispRec : lstRecurrencia){
            List<Object> lstObjRec = new List<Object>();
            Datetime inicioRec = Datetime.newInstance(Date.today(), noDispRec.Hora_Inicial_Recurrente__c);
            Datetime finRec = Datetime.newInstance(Date.today(), noDispRec.Hora_Final_Recurrente__c);
            lstObjRec.add(noDispRec.Calendario__c);
            lstObjRec.add(noDispRec.Asesor__c);
            lstObjRec.add(inicioRec.format('h:mm a'));
            lstObjRec.add(finRec.format('h:mm a'));
            lstObjRec.add(noDispRec.Lunes__c);
            lstObjRec.add(noDispRec.Martes__c);
            lstObjRec.add(noDispRec.Miercoles__c);
            lstObjRec.add(noDispRec.Jueves__c);
            lstObjRec.add(noDispRec.Viernes__c);
            lstObjRec.add(noDispRec.Sabado__c);
            lstObject.add(lstObjRec);
        }
        
        Integer minutosAgregados = 30; 
        for(ServiceTerritory serv : lstService){
            if (serv.cita_sincronica__c == true) {
                minutosAgregados = 60;
            }else{
                minutosAgregados = 30;
            }
            List<AsesorxCalendario__c> lstAsesor = [SELECT Id,Service_Territory__c,Calendario__c FROM AsesorxCalendario__c WHERE Service_Territory__c =:serv.id ];
            if(lstAsesor.size()>0){
                for(AsesorxCalendario__c asesor : lstAsesor  ){                    
                    List<User> lstUser = [SELECT Id FROM User WHERE Id =: asesor.Calendario__c];
                    if (lstUser.size() > 0 ) {                
                        Datetime inicio = Datetime.newInstance(Date.today(), serv.OperatingHours.Hora_inicio_comunidad__c).addMinutes(30);
                        Datetime fin 	= Datetime.newInstance(Date.today(), serv.OperatingHours.Hora_fin_comunidad__c).addMinutes(minutosAgregados);

                        Datetime inicioL = Datetime.newInstance(Date.today(), serv.OperatingHours.Hora_inicio_lunes__c).addMinutes(30);
                        Datetime finL 	= Datetime.newInstance(Date.today(), serv.OperatingHours.Hora_fin_lunes__c).addMinutes(minutosAgregados);

                        Datetime inicioM = Datetime.newInstance(Date.today(), serv.OperatingHours.Hora_inicio_martes__c).addMinutes(30);
                        Datetime finM 	= Datetime.newInstance(Date.today(), serv.OperatingHours.Hora_fin_martes__c).addMinutes(minutosAgregados);

                        Datetime inicioMi = Datetime.newInstance(Date.today(), serv.OperatingHours.Hora_inicio_miercoles__c).addMinutes(30);
                        Datetime finMi 	= Datetime.newInstance(Date.today(), serv.OperatingHours.Hora_fin_miercoles__c).addMinutes(minutosAgregados);

                        Datetime inicioJ = Datetime.newInstance(Date.today(), serv.OperatingHours.Hora_inicio_jueves__c).addMinutes(30);
                        Datetime finJ 	= Datetime.newInstance(Date.today(), serv.OperatingHours.Hora_fin_jueves__c).addMinutes(minutosAgregados);

                        Datetime inicioV = Datetime.newInstance(Date.today(), serv.OperatingHours.Hora_inicio_viernes__c).addMinutes(30);
                        Datetime finV 	= Datetime.newInstance(Date.today(), serv.OperatingHours.Hora_fin_viernes__c).addMinutes(minutosAgregados);
                        if(serv.OperatingHours.Hora_inicio_sabado__c == serv.OperatingHours.Hora_fin_sabado__c ){
                            minutosAgregados= 30;
                        }
                        Datetime inicioSa = Datetime.newInstance(Date.today(), serv.OperatingHours.Hora_inicio_sabado__c).addMinutes(30);
                        Datetime finSa 	= Datetime.newInstance(Date.today(), serv.OperatingHours.Hora_fin_sabado__c).addMinutes(minutosAgregados);
                        
                        List<Object> lstObj = new List<Object>();
                        lstObj.add(serv.Id);
                        lstObj.add(lstUser[0].Id);
                        lstObj.add(inicio.format('h:mm a'));
                        lstObj.add(fin.format('h:mm a'));
                        result.add(lstObj);

                        List<Object> lstObjL = new List<Object>();
                        lstObjL.add(serv.Id);
                        lstObjL.add(lstUser[0].Id);
                        lstObjL.add(inicioL.format('h:mm a'));
                        lstObjL.add(finL.format('h:mm a'));
                        resultL.add(lstObjL);

                        List<Object> lstObjM = new List<Object>();
                        lstObjM.add(serv.Id);
                        lstObjM.add(lstUser[0].Id);
                        lstObjM.add(inicioM.format('h:mm a'));
                        lstObjM.add(finM.format('h:mm a'));
                        resultM.add(lstObjM);

                        List<Object> lstObjMi = new List<Object>();
                        lstObjMi.add(serv.Id);
                        lstObjMi.add(lstUser[0].Id);
                        lstObjMi.add(inicioMi.format('h:mm a'));
                        lstObjMi.add(finMi.format('h:mm a'));
                        resultMi.add(lstObjMi);

                        List<Object> lstObjJ = new List<Object>();
                        lstObjJ.add(serv.Id);
                        lstObjJ.add(lstUser[0].Id);
                        lstObjJ.add(inicioJ.format('h:mm a'));
                        lstObjJ.add(finJ.format('h:mm a'));
                        resultJ.add(lstObjJ);

                        List<Object> lstObjV = new List<Object>();
                        lstObjV.add(serv.Id);
                        lstObjV.add(lstUser[0].Id);
                        lstObjV.add(inicioV.format('h:mm a'));
                        lstObjV.add(finV.format('h:mm a'));
                        resultV.add(lstObjV);

                        List<Object> lstObjS = new List<Object>();
                        lstObjS.add(serv.Id);
                        lstObjS.add(lstUser[0].Id);
                        lstObjS.add(inicioSa.format('h:mm a'));
                        lstObjS.add(finSa.format('h:mm a'));
                        resultSa.add(lstObjS);
                    }
                }                
            }
        }
        
        
        


        results.add(userr);
        results.add(nextCitation);
        results.add(userAssets);
        results.add(availabilityInformation);
        results.add(result);

        //new section dias
        results.add(resultL);
        results.add(resultM);
        results.add(resultMi);
        results.add(resultJ);
        results.add(resultV);
        results.add(resultSa);
        results.add(lstObject);
        //results.add(dataAccess);

        return results;
    }
    
    @AuraEnabled
    public static Object getReportarFallo(String serviceSelected,String marcaSel ){
        List <Object> result = new List<Object>();
        List<String> lstAlpha = new List<String>();
        List<community_config__c> lstCommConf = [Select Id,Reporta_el_fallo__c From community_config__c WHERE Marca__c =: marcaSel AND Servicios__c =: serviceSelected];
        if(lstCommConf.size()>0){
            
            for (community_config__c commConf : lstCommConf) {
                if(commConf.Reporta_el_fallo__c != null){
                    lstAlpha = commConf.Reporta_el_fallo__c.split(';');
                    for (String nombrePregunta : lstAlpha) {
                        result.add(nombrePregunta);
                    }
                }                                              
            }
            
        }
        return result;
    }

    @AuraEnabled
    public static Object getCalendarsObjects(String serviceSelected,String marcaSel ){
            List <Object> result = new List<Object>();
            String servicioAcento = '';
            List<String> lstAlpha = new List<String>();
            List<Hora_global__c> lstHoraGlobal = new List<Hora_global__c> ();
            List<community_config__c> lstCommConf = [Select Id,Calendario__c,Servicio_con_acentos__c From community_config__c WHERE Marca__c =: marcaSel AND Servicios__c =: serviceSelected];
            if(lstCommConf.size()>0){
                for (community_config__c commConf : lstCommConf) {
                    lstAlpha = commConf.Calendario__c.split(';');
                    servicioAcento = commConf.Servicio_con_acentos__c;
                }
            }
            String tipoVehiculo = 'Carro';
            if (marcaSel == 'Motorrad') {
                tipoVehiculo = 'Moto';
            }
            //hacer la combinacion Nombre - Servicio
            if (lstAlpha.size()>0) {
             for (String nombreSuc : lstAlpha) {
                String Nombre = '%' + nombreSuc + ' - ' + servicioAcento + '%';
                List<User> lstCalend = [Select id From User Where FirstName Like '%Calendario%' AND LastName Like :Nombre AND  LastName != 'Escazú - Mecánica Rápida 2']; 
                if(lstCalend.size()>0) {
                    String newSearchText = '';
                    // if(servicioAcento == 'Diagnóstico'){
                        // newSearchText = '%' + nombreSuc + ' - Mecánica General%';
                    // }else{
                        newSearchText = Nombre;
                    // }
                    
                    lstHoraGlobal = [Select Service_Territory__r.ComunidadServiceName__c From Hora_global__c Where Service_Territory__r.ComunidadServiceName__c Like :newSearchText AND Tipo_de_veh_culo__c =: tipoVehiculo]; 
                    for (User calendario : lstCalend) {
                        List<Object> lstCalendarios = new List<Object>();
                        // lstCalendarios.add(nombreSuc);
                        // lstCalendarios.add(calendario.id);
                        listaSucursales temp = new listaSucursales();
                        temp.label = nombreSuc;
                        temp.id = calendario.id;
                        if(lstHoraGlobal.size() > 0){
                            for (Hora_global__c horaGlobal : lstHoraGlobal) {
                                if (horaGlobal.Service_Territory__r.ComunidadServiceName__c.contains(temp.label) ) {
                                    result.add(temp);
                                }
                                
                            }
                            
                        }
                        
                    }
                }
             }   
            }
          
            return result;
    }




    @AuraEnabled 
    public static void cancelCitation(Id citationId){
        Event_Shadow__c citation = [Select Id,ActivityDate__c, Estado2__c,WhatId__c,Activo__c from Event_Shadow__c where Id=:citationId limit 1];
        Datetime fechaBuscar = null;
        String Activo = '';
        String WhatId = '';
        List<Event_Shadow__c> lstEventos = new List<Event_Shadow__c>();
        if(citation.Activo__c != null || citation.Activo__c != ''  ){
            Activo = citation.Activo__c;
            fechaBuscar = citation.ActivityDate__c;
            lstEventos = [Select Id,ActivityDate__c, Estado2__c,WhatId__c,Activo__c from Event_Shadow__c where ActivityDate__c =:fechaBuscar AND  Activo__c =: Activo ];
        }else if(citation.WhatId__c != null || citation.WhatId__c != ''){
            WhatId = citation.WhatId__c;
            fechaBuscar = citation.ActivityDate__c;
            lstEventos = [Select Id,ActivityDate__c, Estado2__c,WhatId__c,Activo__c from Event_Shadow__c where  ActivityDate__c =:fechaBuscar AND  WhatId__c =: WhatId ];
        }
        if(lstEventos.size()>0){
            for(Event_Shadow__c evento : lstEventos){
                evento.Estado2__c = 'Cancelada';
                evento.ToBeProcessed__c= true;
            }
            if(!test.isRunningTest()){
                update lstEventos;
            }
            
        }
        citation.Estado2__c = 'Cancelada';
        citation.ToBeProcessed__c= true;
        if(!test.isRunningTest()){
        	update citation;
        }
        
    }

    @AuraEnabled
    public static void createCaseComunidad(String mensaje){
       
        User userr = fetchUser();
        String cocheBuscado = '';
        List<Asset> lstAsset = [Select Id,AccountId From Asset Where  AccountId = :userr.Contact?.AccountId ];
        if(lstAsset.size()>0){
            cocheBuscado = lstAsset[0].id;
        }else{
            cocheBuscado = '02i4U00000Hn9k8QAB';
        }

        Case newCase = new Case();
        newCase.RecordTypeId = '012PH00000HBor9YAD';
        newCase.Creado_por_service__c = true;
        newCase.Origin = 'BMW Service Contactanos';
        newCase.FechaEntrada__c = Date.today();
        newCase.Priority = 'Media';
        //newCase.AccountId = userr.Contact?.AccountId;
        newCase.Subject = 'Nuevo Caso Interno Comunidad';
        newCase.Description = mensaje;
        if(lstAsset.size()>0){
            newCase.AssetId  = lstAsset[0].Id;
            newCase.AccountId = userr.Contact?.AccountId;
        }
        newCase.suppliedLastName__c = userr.Lastname;
        newCase.SuppliedName = userr.FirstName;
        newCase.Type = 'Solicitud';
        newCase.Service_Territory1__c  = '0HhPH0000003NEb0AM';
        insert newCase;
        // return capacity;
    }
    
    
    @AuraEnabled
    public static Object getSucursalCapacity(Id sucursal){
        AggregateResult[] groupedResuls = [Select Count(Asesor__c) from AsesorxCalendario__c where Calendario__c =: sucursal];
        Object capacity = groupedResuls[0].get('expr0');
        return capacity;
    }
    
    @AuraEnabled
    public static List<Object> getHourAvailability( Id calendarId, Date horaSelc) {
        List <Horas_Reserva__c> horasOcupadas = [Select Id,Calendario__c,fecha_reserva__c from Horas_Reserva__c  WHERE Estado__c = 'Apartado'];

        List<Object> options = new List<Object>();

        List <Horas_Reserva__c> horasOcupadasExiste = [SELECT Id,Calendario__c,fecha_reserva__c FROM Horas_Reserva__c WHERE Calendario__c =: calendarId AND fecha_reserva__c =: horaSelc AND Estado__c = 'Apartado'];

        if(horasOcupadasExiste.size()>0){
            
        }else{
            Horas_Reserva__c newReserva = new Horas_Reserva__c();
            newReserva.fecha_reserva__c  = horaSelc;
            newReserva.Calendario__c = calendarId;
            insert newReserva;
    
            
        }
        
        return horasOcupadas;
    }

    @AuraEnabled
    public static List<Object> getHoursAvailability() {
        List <Horas_Reserva__c> horasOcupadas = [SELECT Id,Calendario__c,fecha_reserva__c FROM Horas_Reserva__c WHERE  Estado__c = 'Apartado'];
        return horasOcupadas;
    }

    @AuraEnabled
    public static Boolean getTerminosYCondi() {
        User userr = fetchUser();
        Boolean contesto = false;
        List <User> horasOcupadas = [SELECT Id,Terminos_y_condiciones__c FROM User WHERE Id=: userInfo.getUserId()];
        If(horasOcupadas.size()>0){
            contesto = horasOcupadas[0].Terminos_y_condiciones__c;
        }
        return contesto;
    }

    @AuraEnabled
    public static Boolean setTerminosYCondi() {
        Boolean contesto = true;
        List <User> horasOcupadas = [SELECT Id,Terminos_y_condiciones__c FROM User WHERE Id=: userInfo.getUserId()];
        If(horasOcupadas.size()>0){
            horasOcupadas[0].Terminos_y_condiciones__c = true;
        }
        update horasOcupadas;
        return contesto;
    }


    @AuraEnabled
    public static List<Object> releaseHoursAvailability(Id calendarId, Date horaSelc) {
        List <Horas_Reserva__c> horasOcupadasExiste = [SELECT Id,Calendario__c,fecha_reserva__c,Estado__c FROM Horas_Reserva__c WHERE Calendario__c =: calendarId AND fecha_reserva__c =: horaSelc AND Estado__c = 'Apartado'];
        if(horasOcupadasExiste.size()>0){
            for(Horas_Reserva__c hr : horasOcupadasExiste){
                hr.Estado__c = 'Cancelado';
            }
            update horasOcupadasExiste;
        }else{

        }
        List <Horas_Reserva__c> horasOcupadas = [Select Id,Calendario__c,fecha_reserva__c from Horas_Reserva__c  WHERE Estado__c = 'Apartado'];
        
        return horasOcupadas;
    }

    @AuraEnabled 
    public static Boolean validarEventoVacio (Id userId, List<string> usersToExclude, Id calendarId, Id whatId, Date daySelected, DateTime selectedStartHour, DateTime selectedEndHour, String selectedVehicle, String vehicleId, String ownVehicleId, String description, String selectedServiceCenter){
        List<Event_Shadow__c> lstEvent = [SELECT Id,OwnerId,Asesor__c,Tipo_de_cita__c,Description2__c FROM Event_Shadow__c WHERE StartDateTime__c =: selectedStartHour  AND Calendar__c =:calendarId AND Estado2__c != 'Cancelada' AND Tipo_de_cita__c != 'Calendario' ];
        List<AsesorxCalendario__c> availableUsers = [Select Asesor__c from AsesorxCalendario__c where Calendario__c=:calendarId];
        Integer asesoresDisponibles = availableUsers.size();
        if(lstEvent.size()>0){
            for(Event_Shadow__c ev : lstEvent){
                if(ev.Tipo_de_cita__c == 'Asesor' && ev.Description2__c != 'creado desde trigger'){
                    asesoresDisponibles = asesoresDisponibles - 1 ;
                }
            }
            if(asesoresDisponibles > 0){
                return true;
            }else{
                return false;
            }
            
        }else{
            return true;
        }

        
    }


    @AuraEnabled 
    public static Event_Shadow__c createCalendarEventW(String KilimeEsti,Id userId, List<string> usersToExclude, Id calendarId, Id whatId, Date daySelected, DateTime selectedStartHour, DateTime selectedEndHour, String selectedVehicle, String vehicleId, String ownVehicleId, String description, String selectedServiceCenter){

        String origenFinal = '';
        if(userId == null){
            origenFinal = 'Contact Center';
        }else{
            origenFinal = 'Formulario Web';
        }

        //================================================================================================================================
        //================================================================================================================================
        //================================================================================================================================
        //================================================================================================================================
        //================================================================================================================================
        //================================================================================================================================
        String asesorId ='';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        // Get the OAuth access token
        String accessToken = OAuthTokenService.getAccessToken();        
        // Set the REST endpoint

        request.setEndpoint('https://redmotors.my.salesforce.com/services/apexrest/Citas/');
        //request.setEndpoint('https://redmotors--partial.sandbox.my.salesforce.com/services/apexrest/CitasField2/');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        // Convertir las fechas al formato esperado por el servicio
            String formattedDateTime = selectedStartHour.format('dd/MM/yyyy HH:mm'); // Fecha y hora (ej: 28/02/2025 11:00)
            DateTime daySelectedDateTime = DateTime.newInstance(daySelected.year(), daySelected.month(), daySelected.day(), 0, 0, 0);
            String formattedDate = daySelectedDateTime.format('dd/MM/yyyy'); // Ahora funciona correctamente
            
            // Construir el cuerpo de la petición
            String requestBody = '{ ' +
                '"tipoPeticion": "obtenerDisp", ' +
                '"parametros": { ' +
                '"servicio": "' + calendarId + '", ' +
                '"fecha": "' + formattedDateTime + '", ' +
                '"soloDate": "' + formattedDate + '" ' +
                '} ' +
                '}';
            request.setBody(requestBody);
        
        // Send the request
        String mensajeRespuesta ='';
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            if ((String) responseBody.get('ValidarCitaExitoso') == 'true') {
                asesorId = (String) responseBody.get('asesorId');
                // Guardar el ID del asesor en la variable
                // Ejemplo: this.asesorId = asesorId;
            } else {
            }
        } else {
            throw new AuraHandledException('Error: ' + response.getStatusCode() + ' ' + response.getBody());
        }
        
        if(asesorId != '' && asesorId != null){

            String randomAsesor  = asesorId;

            
            
            
            //userId='0038N000006hxhgQAA';
            //Id contactRelatedToUser = [Select ContactId from User where Id =: userId limit 1].ContactId;
            String placaVehiculo = '';
            Boolean esExtraordinaria = false;
            if(vehicleId != null){
                list<Asset> lstAsset = [SELECT Name FROM Asset WHERE Id =: vehicleId];
                if(lstAsset.size()>0){
                    placaVehiculo = lstAsset[0].Name;
                }
            }
            //proceso para calculo de horarios
            String nombrecalendario = getCalendarName(calendarId);
            String idServiceT = '';
            Integer minutosAgregar = 0;
            Decimal mecanicosExtra = 0;
            if(!nombrecalendario.contains('Calendario')){
                List<User> lstUser = [Select Id From User wehr];
            }
            Boolean citaSincro = false;
            List<ServiceTerritory> lstServiceT = [SELECT Id,cita_sincronica__c FROM ServiceTerritory WHERE ComunidadServiceName__c LIKE : nombrecalendario];
            if(lstServiceT.size()>0){
                idServiceT = lstServiceT[0].Id;
                if (lstServiceT[0].cita_sincronica__c == true) {
                    citaSincro = true;
                }
            }
            
            List<Hora_global__c> lstHora = [SELECT Id,Tiempo_de_cita_2__c FROM Hora_global__c WHERE Service_Territory__c = :idServiceT];
            if(lstHora.size()>0){
                List<hora_extraordinaria__c> lstHoraExtra = [SELECT Id,Tiempo_de_cita_2__c,Mecanicos__c,Hora_y_Fecha_de_Inicio__c,Hora_y_Fecha_de_Fin__c FROM hora_extraordinaria__c WHERE Service_Territory__c = :idServiceT ];
                if(lstHoraExtra.size()>0){

                    if(lstHoraExtra[0].Hora_y_Fecha_de_Inicio__c <= selectedStartHour.addMinutes(30) && lstHoraExtra[0].Hora_y_Fecha_de_Fin__c >= selectedStartHour.addMinutes(30) ){
                        minutosAgregar = integer.valueof(lstHoraExtra[0].Tiempo_de_cita_2__c);
                        esExtraordinaria = true;
                        mecanicosExtra = lstHoraExtra[0].Mecanicos__c;
                    }                
                }else{
                    minutosAgregar = integer.valueof(lstHora[0].Tiempo_de_cita_2__c);
                }            
            }
            //AND Hora_y_Fecha_de_Inicio__c <= :selectedStartHour AND Hora_y_Fecha_de_Fin__c  >= :selectedStartHour 
            //xselectedEndHour = selectedEndHour.addMinutes(minutosAgregar);
            Event_Shadow__c newEvent = new Event_Shadow__c();
            newEvent.ActivityDate__c = daySelected;
            if(selectedVehicle == 'esReserva' ){
                newEvent.StartDateTime__c = selectedStartHour;			// Date.parse('2022-09-14 05:56:45');
                newEvent.EndDateTime__c = selectedStartHour.addMinutes(30);
            }else if( citaSincro == true){
                newEvent.StartDateTime__c = selectedStartHour;			// Date.parse('2022-09-14 05:56:45');
                newEvent.EndDateTime__c = selectedEndHour; 
            }else{
                newEvent.StartDateTime__c = selectedStartHour.addMinutes(30);				// Date.parse('2022-09-14 05:56:45');
                newEvent.EndDateTime__c = selectedEndHour.addMinutes(30);
            }
            
            newEvent.Subject__c = 'Evento de Comunidad. Vehículo: ' + placaVehiculo;
            newEvent.VehicleId__c =placaVehiculo;
            newEvent.Activo__c = vehicleId;
            if(selectedVehicle == 'esReserva'){
                newEvent.esReserva__c = true;
            }
            newEvent.Description2__c = 'Evento de Comunidad. Vehículo: ' + placaVehiculo + '\n'+ description;
            newEvent.WhatId__c = vehicleId;
            newEvent.Kilometraje__c = KilimeEsti;
            newEvent.OwnerId = randomAsesor; 				// Calendario - Based on the first selection after login.
            newEvent.Asesor__c = randomAsesor;
            newEvent.ToBeProcessed__c = true;
            newEvent.OrigenEvento__c = origenFinal;
            newEvent.ServiceAndCenter__c = getCalendarName(calendarId);
            newEvent.Calendar__c = calendarId;
            if(selectedVehicle == 'esReserva'){
                newEvent.Tipo_de_cita__c = 'Asesor';
            }else{
                newEvent.Tipo_de_cita__c = 'Calendario';
            }
            
            
            //newEvent.IsReminderSet = true;
            //newEvent.IsPrivate = false;
            //newEvent.IsVisibleInSelfService = true;
            
                
                
            List<User> lstHoraGlobal = [SELECT id,Cantidad_de_Mecanicos__c FROM user WHERE id = :calendarId   ];
            
            if(lstHoraGlobal.size()>0){
                List<AsesorxCalendario__c> availableUsers1 = [Select Asesor__c from AsesorxCalendario__c where Calendario__c=:calendarId];
                Integer cantidadAvailableUsers = availableUsers1.size();
                Double cantidadMecanicos = 0;
                if(esExtraordinaria){
                    cantidadMecanicos = mecanicosExtra;
                }else{
                    cantidadMecanicos = lstHoraGlobal[0].Cantidad_de_Mecanicos__c;
                }

                
                
                // if(cantidadMecanicos > cantidadAvailableUsers){
                //     Double numberOfRecords = cantidadMecanicos - cantidadAvailableUsers;
                //     List<Event_Shadow__c> recordsToCreate = new List<Event_Shadow__c>();
                //     for (Integer i = 0; i < numberOfRecords; i++) {
                if(selectedVehicle != 'esReserva'){
                    
                    Event_Shadow__c newEventN = new Event_Shadow__c();
                    newEventN.ActivityDate__c = daySelected;
                    newEventN.StartDateTime__c = selectedStartHour;	
                            // Date.parse('2022-09-14 05:56:45');
                    if( citaSincro == true){		// Date.parse('2022-09-14 05:56:45');
                        newEventN.EndDateTime__c = selectedEndHour; 
                    }else{
                        newEventN.EndDateTime__c = selectedStartHour.addMinutes(30);
                    }
                    

                    newEventN.Subject__c = 'Evento de Comunidad. Vehículo: ' + placaVehiculo;
                    newEventN.VehicleId__c =placaVehiculo;
                    newEventN.Activo__c = vehicleId;
                    newEventN.Kilometraje__c = KilimeEsti;
                    newEventN.Description2__c = 'Evento de Comunidad. Vehículo: ' + placaVehiculo + '\n'+ description;
                    newEventN.WhatId__c = vehicleId;
                    newEventN.OwnerId = calendarId; 				// Calendario - Based on the first selection after login.
                    newEventN.Asesor__c = randomAsesor;
                    newEventN.ToBeProcessed__c = true;
                    newEventN.OrigenEvento__c = '';
                    newEventN.ServiceAndCenter__c = getCalendarName(calendarId);
                    newEventN.Calendar__c = calendarId;
                    newEventN.Tipo_de_cita__c = 'Asesor';
                    if(!test.isRunningTest()){
                        insert newEventN;
                    }   
                    
                }
       
                if(!test.isRunningTest()){
                        
                    insert newEvent;
                    return newEvent;
                }
            }else {
                //availableUsers = [Select Asesor__c from AsesorxCalendario__c where Calendario__c=:calendarId];
            }
        }
        
        return null;
    }
    @AuraEnabled 
    public static Object getUserActualInfo(String userId){
        User userr = fetchUser();
        Id contactRelatedToUser = [Select ContactId from User where Id =: userr.Id limit 1].ContactId;
        String accId = '';

        List<Contact> lstContact = [Select AccountId From Contact where Id =: contactRelatedToUser ];
        if(lstContact.size()>0){
            accId = lstContact[0].AccountId;
        }
        List<Asset> result = [SELECT Id,Name FROM Asset WHERE AccountId =: accId ];
        return result;
    }

    @AuraEnabled 
    public static Object getUserHistory(String userId, String marca){
        
        User userr = fetchUser();

        Id contactRelatedToUser = [
            SELECT ContactId 
            FROM User 
            WHERE Id = :userr.Id 
            LIMIT 1
        ].ContactId;

        String accId = null;

        List<Contact> lstContact = [
            SELECT AccountId 
            FROM Contact 
            WHERE Id = :contactRelatedToUser
        ];

        if (!lstContact.isEmpty()) {
            accId = lstContact[0].AccountId;
        }

         List<Asset> userAssets = new  List<Asset>();

        if(marca == 'Motorrad'){
         userAssets = [SELECT Id, Name, Anio__c, marca__c, modelo__c, color__c, numeroDePlaca__c 
                FROM Asset 
                WHERE AccountId = :accId AND Tipo_de_veh_culo__c = 'Motocicleta'];
        }else{
            userAssets = [
                SELECT Id, Name, Anio__c, marca__c, modelo__c, color__c, numeroDePlaca__c 
                FROM Asset 
                WHERE AccountId = :accId AND marca__c =: marca
            ];
        }


        // ===============================
        // 1) TRAER TODOS LOS EVENTOS
        // ===============================

        List<Event_Shadow__c> rawList = [
            SELECT 
                Id, StartDatetime__c, CreatedDate,
                Activo__r.numeroDePlaca__c, VehicleId__c, 
                Activo__r.AccountId, CalendarName__c, 
                AssessorName__c, Activo__c, 
                Activo__r.ContactId, Estado__c, Estado2__c,Tipo_de_cita__c
            FROM Event_Shadow__c
            WHERE Activo__c IN :userAssets 
            AND Activo__c != null 
            AND Activo__c != '' 
            AND Tipo_de_cita__c = 'Asesor'
           
            ORDER BY StartDatetime__c DESC
        ];

        // ======================================
        // 2) MAPA PARA FILTRAR DUPLICADOS
        // ======================================

        Map<Datetime, Event_Shadow__c> uniqueMap = new Map<Datetime, Event_Shadow__c>();

        for (Event_Shadow__c ev : rawList) {
            Datetime key = ev.CreatedDate;

            if (!uniqueMap.containsKey(key)) {
                uniqueMap.put(key, ev);
            }
        }

        // ======================================
        // 3) OBTENER LISTA FINAL SIN DUPLICADOS
        // ======================================

        List<Event_Shadow__c> uniqueList = uniqueMap.values();


        // ======================================
        // 4) REGRESAR LISTA SIN DUPLICADOS
        // ======================================
        if(uniqueList.size()>0){
            return uniqueList;

        }        
        
        return '';

    }
    
    @AuraEnabled 
    public static Object getUserHistoryActive(String userId, String marca){
        
        User userr = fetchUser();
        Id contactRelatedToUser = [Select ContactId from User where Id =: userr.Id limit 1].ContactId;
        String accId = '';

        List<Contact> lstContact = [Select AccountId From Contact where Id =: contactRelatedToUser ];
        if(lstContact.size()>0){
            accId = lstContact[0].AccountId;
        }

        List <Asset> userAssets = new List <Asset>();

        if(marca == 'Motorrad'){
            userAssets = [Select Id, Name, Anio__c, marca__c, modelo__c, color__c, numeroDePlaca__c from Asset where AccountId =: accId And Tipo_de_veh_culo__c = 'Motocicleta'];
        }else{
            userAssets = [Select Id, Name, Anio__c, marca__c, modelo__c, color__c, numeroDePlaca__c from Asset where AccountId =: accId And  marca__c =: marca];
        }

         
       
     
        List<Event_Shadow__c> result = [Select Id, StartDatetime__c, VehicleId__c, Activo__r.AccountId,CalendarName__c, AssessorName__c, Activo__c, Activo__r.ContactId, Estado2__c,Estado__c  from Event_Shadow__c 
                                        where Activo__c IN: userAssets  AND Estado2__c = null  and Tipo_de_cita__c = 'Asesor' order by StartDatetime__c desc];
        if(result.size()>0){
            return result;
        }
        
        
        
        return '';

    }

    public static String getVehicleRegistrationId(String vehicleId){
        String regId = [Select Name from Asset where Id=:vehicleId limit 1].Name;
        return regId;
    }
    
    public static String getCalendarName(String calendarId){
        String calendarName = [Select LastName from User where id=:calendarId limit 1].LastName;
        return calendarName;
    }
    
    @AuraEnabled 
    public static Object getAvailability(){
        
        List<Object> availability = new List<Object>();
        availability.add(getWholeCompanyAvailability());
        availability.add(getSucursalAvailability());
        availability.add(getServiceAvailability());
        
        return availability;
    }
    
    @AuraEnabled 
    public static Object getWholeCompanyAvailability(){
        List<NoDisponibilidad_Servicio__c> result = [Select Id, Hora_y_Fecha_de_Inicio__c, Hora_y_Fecha_de_Fin__c from NoDisponibilidad_Servicio__c where  Hora_y_Fecha_de_Inicio__c>= TODAY and Activo__c=True and Nivel_de_aplicaci_n__c ='Todas las sucursales'];
        if(result.size()>0){
            return result;
        }
        return '';
    }
    
    @AuraEnabled 
    public static Object getSucursalAvailability(){
        List<NoDisponibilidad_Servicio__c> result = [Select Sucursal__c, Hora_y_Fecha_de_Inicio__c, Hora_y_Fecha_de_Fin__c from NoDisponibilidad_Servicio__c where  Hora_y_Fecha_de_Inicio__c>= TODAY and Activo__c=True and Nivel_de_aplicaci_n__c ='Toda la sucursal'];
        if(result.size()>0){
            return result;
        }
        return '';
    }
    
    @AuraEnabled 
    public static Object getServiceAvailability(){
        List<NoDisponibilidad_Servicio__c> result = [Select Service_Territory__r.ComunidadServiceName__c, Hora_y_Fecha_de_Inicio__c, Hora_y_Fecha_de_Fin__c from NoDisponibilidad_Servicio__c where  Hora_y_Fecha_de_Inicio__c>= TODAY and Activo__c=True and Nivel_de_aplicaci_n__c ='Servicio Específico'];
        if(result.size()>0){
            return result;
        }
        return '';
    }

    @AuraEnabled
    public static String callExternalApi(String servicio, String sucursal, String fecha) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        // Get the OAuth access token
        String accessToken = OAuthTokenService.getAccessToken();        
        // Set the REST endpoint

        List<User> lstUser = [Select Id,FirstName,LastName FROM User WHERE Id =:sucursal];
        String nombre = lstUser[0].LastName;
        List<String> parts = nombre.split(' - ');

        sucursal = parts[0];
        String service = parts[1];

        request.setEndpoint('https://redmotors.my.salesforce.com/services/apexrest/Citas/');
        //request.setEndpoint('https://redmotors--partial.sandbox.my.salesforce.com/services/apexrest/CitasField2/');
        //request.setEndpoint('https://redmotors--partial.sandbox.my.salesforce.com/services/apexrest/Citas/');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        // Construct the request body
        String requestBody = '{ "tipoPeticion": "getHorasCita", "parametros": { "servicio": "' + service + '","sucursal": "' + sucursal + '","fecha": "' + fecha + '" ,"comunidad": "true" } }';
        request.setBody(requestBody);
        // Send the request
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            return response.getBody();
        } else {
            throw new AuraHandledException('Error: ' + response.getStatusCode() + ' ' + response.getBody());
        }
    }

    @AuraEnabled
    public static String callExternalApiOcupied(String servicio, String sucursal, String fecha) {
        //Id userId, List<string> usersToExclude, Id calendarId, Id whatId, Date daySelected, DateTime selectedStartHour, 
        //DateTime selectedEndHour, String selectedVehicle, String vehicleId, String ownVehicleId, String description, 
        //String selectedServiceCenter

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        // Get the OAuth access token
        String accessToken = OAuthTokenService.getAccessToken();        
        // Set the REST endpoint

        List<User> lstUser = [Select Id,FirstName,LastName FROM User WHERE Id =:sucursal];
        String nombre = lstUser[0].LastName;
        List<String> parts = nombre.split(' - ');

        sucursal = parts[0];
        String service = parts[1];

        request.setEndpoint('https://redmotors.my.salesforce.com/services/apexrest/Citas/');
        //request.setEndpoint('https://redmotors--partial.sandbox.my.salesforce.com/services/apexrest/CitasField2/');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'application/json');
        // Construct the request body
        String requestBody = '{ "tipoPeticion": "validarCita", "parametros": { "servicio": "' + servicio + '","sucursal": "' + sucursal + '","fecha": "' + fecha + '" ,"comunidad": "true" } }';
        request.setBody(requestBody);
        // Send the request
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            return response.getBody();
        } else {
            throw new AuraHandledException('Error: ' + response.getStatusCode() + ' ' + response.getBody());
        }
    }

    @AuraEnabled
    public static String callExternalApiDates(String sucursal, String fecha) {

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String accessToken = OAuthTokenService.getAccessToken();
        List<User> lstUser = [SELECT Id, FirstName, LastName FROM User WHERE Id = :sucursal];
        String nombre = lstUser[0].LastName;
        List<String> parts = nombre.split(' - ');
        sucursal = parts[0];
        String service = parts[1];
        
        Set<String> allDatesSet = new Set<String>(); // Use Set to avoid duplicates
        Integer callCount = 0;
        Boolean hasMoreDates = true;
        
        while (callCount < 14) {
            // Guardar la fecha que vamos a consultar
            String fechaConsultada = fecha;
            
            request = new HttpRequest(); // nuevo request por iteración
            request.setEndpoint('https://redmotors.my.salesforce.com/services/apexrest/Citas/');
            request.setMethod('POST');
            request.setHeader('Authorization', 'Bearer ' + accessToken);
            request.setHeader('Content-Type', 'application/json');
            
            String requestBody = '{ "tipoPeticion": "getOpcionesCita", "parametros": { "servicio": "' + service + '","sucursal": "' + sucursal + '","fecha": "'+fecha+'"} }';
            request.setBody(requestBody);
            
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> opciones = (List<Object>) jsonResponse.get('opciones');

                if (opciones != null) {
                    for (Object dateS : opciones) {
                        String dateStr = (String) dateS;
                        if (dateStr != 'Otras fechas' && dateStr != 'Otra sucursal') {
                            allDatesSet.add(dateStr);
                        }
                    }
                }

                // Siempre avanzar 7 días desde la fecha consultada
                List<String> dateParts = fechaConsultada.split('/');
                Date currentFecha = Date.newInstance(
                    Integer.valueOf(dateParts[2]), 
                    Integer.valueOf(dateParts[1]), 
                    Integer.valueOf(dateParts[0])
                );
                Date newFecha = currentFecha.addDays(7);
                DateTime newFechaDateTime = DateTime.newInstance(newFecha.year(), newFecha.month(), newFecha.day());
                fecha = newFechaDateTime.format('dd/MM/yyyy');
                
                callCount++;
            } else {
                throw new AuraHandledException('Error: ' + response.getStatusCode() + ' ' + response.getBody());
            }
        }
        
        // Convert Set to List for final response
        List<String> allDates = new List<String>(allDatesSet);
        // Construct the final response to send back to the Aura component
        Map<String, Object> finalResponse = new Map<String, Object>();
        finalResponse.put('opciones', allDates);
        finalResponse.put('mensaje', allDates.isEmpty() ? 'No hay opciones de cita disponibles' : 'Existen opciones de cita disponibles');
        finalResponse.put('OpcionesCita', allDates.isEmpty() ? 'false' : 'true');
        return JSON.serialize(finalResponse);
    }




    public class listaSucursales {
        @AuraEnabled
        //Identificador del formulario
        public String label;
        @AuraEnabled
        public String id;
    }



    @AuraEnabled
    public static List<Cita_trafico_online__c> buscarCitaPorCedula(String cedula) {
        if (String.isBlank(cedula)) {
            return new List<Cita_trafico_online__c>();
        }
        
        List<Cita_trafico_online__c> citas = [
            SELECT Id, Name,Nombre__c, Modelo__c, Inicio__c, Sucursal__c, Cedula__c, Status__c
            FROM Cita_trafico_online__c
            WHERE Cedula__c = :cedula
            AND Status__c = 'Agendada'
            ORDER BY Inicio__c DESC
        ];
        
        return citas;
    }


    @AuraEnabled
    public static void createOportunidad(String leadId) {
        // 1. Obtener el Lead entrante
        Lead trafico = [
            SELECT Id, FirstName, LastName, Email, MobilePhone, Phone,
                Marca__c, Familia1__c, Modelo_De_Inter_s1__c,
                Numero_de_Identificacion_del__c, Sucursal__c,
                FechaPosibleCompra__c, RecordTypeId, RecordType.Name,
                LeadSource, Action__c, Campana__c, Campa_aNew__c,
                Fuente__c, Medio__c, Ano1__c, CreatedDate,
                Codigo_de_producto__c, CodigoProducto__c,
                Tipo_de_Identificaci_n__c, Convertido_custom__c, OwnerId
            FROM Lead
            WHERE Id = :leadId
            LIMIT 1
        ];

        if (trafico.Convertido_custom__c == true) {
            return;
        }

        String marca = trafico.Marca__c;
        String cedula = trafico.Numero_de_Identificacion_del__c;

        // 2. Obtener RecordTypes de Opportunity según marca
        Set<Id> oppRecordTypeIds = new Set<Id>();
        String oppRecordTypeIdPrincipal = null;

        if (marca == 'BMW') {
            oppRecordTypeIdPrincipal = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
            oppRecordTypeIds.add(oppRecordTypeIdPrincipal);
        } else if (marca == 'MINI') {
            oppRecordTypeIdPrincipal = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('MINI').getRecordTypeId();
            oppRecordTypeIds.add(oppRecordTypeIdPrincipal);
        } else if (marca == 'Motorrad' || marca == 'Kawasaki' || marca == 'Polaris' || marca == 'Indian') {
            oppRecordTypeIdPrincipal = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(marca).getRecordTypeId();
            oppRecordTypeIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Motorrad').getRecordTypeId());
            oppRecordTypeIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Kawasaki').getRecordTypeId());
            oppRecordTypeIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Polaris').getRecordTypeId());
            oppRecordTypeIds.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Indian').getRecordTypeId());
        }

        // 3. Buscar Opp existente — solo 'Oportunidad Calificada' y < 6 meses
        Date sixMonthsBefore = Date.today().addMonths(-6);

        List<Opportunity> lstOpp = new List<Opportunity>();
        if (String.isNotBlank(cedula) && !oppRecordTypeIds.isEmpty()) {
            lstOpp = [
                SELECT Id, CreatedDate, Trafico__c, ModeloDeInteresOriginal__c,
                    Trafico__r.Marca__c, Trafico__r.Modelo_De_Inter_s1__c
                FROM Opportunity
                WHERE Cedula_formula__c = :cedula
                    AND StageName = 'Oportunidad Calificada'
                    AND RecordTypeId IN :oppRecordTypeIds
                    AND CreatedDate >= :sixMonthsBefore
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
        }

        // 4. Si hay Opp candidata, verificar si tiene reserva
        if (!lstOpp.isEmpty()) {
            Opportunity oppExistente = lstOpp[0];

            // Verificar reserva en OLI o en Product2
            List<OpportunityLineItem> olisReservados = [
                SELECT Id
                FROM OpportunityLineItem
                WHERE OpportunityId = :oppExistente.Id
                    AND (Reservado__c = true OR Product2.Producto_Reservado__c = true)
                LIMIT 1
            ];

            Boolean tieneReserva = !olisReservados.isEmpty();
            if (!tieneReserva) {
                // Opp reutilizable — verificar mismo vehículo
                String marcaOppAnterior = oppExistente.Trafico__r.Marca__c;
                String modeloOppAnterior = oppExistente.Trafico__r.Modelo_De_Inter_s1__c;

                Boolean mismoVehiculo = (marcaOppAnterior == trafico.Marca__c)
                    && (modeloOppAnterior == trafico.Modelo_De_Inter_s1__c);

                if (mismoVehiculo) {
                    // CASO 1: Opp reutilizable + mismo vehículo
                    actualizarTrafico(trafico);

                    // Actualizar Opp existente
                    actualizarOppExistente(trafico, oppExistente.Id);

                    // Crear Walking
                    crearRegistroWalking(trafico, oppExistente.Id);

                    // Marcar Lead como convertido
                    trafico.Convertido_custom__c = true;
                    trafico.Status = 'Qualified';
                    update trafico;
                    return;

                } else {
                    // CASO 2: Opp reutilizable + diferente vehículo
                    crearOppCompleta(trafico, cedula, oppRecordTypeIdPrincipal);
                    return;
                }
            }
        }

        // CASO 3: Sin Opp reutilizable (no existe, reservada, stage diferente o > 6 meses)
        crearOppCompleta(trafico, cedula, oppRecordTypeIdPrincipal);
    }


    // ============================================================
    // Método auxiliar: Actualizar Lead entrante + enviar correo
    // ============================================================
    private static void actualizarTrafico(Lead trafico) {
        // El objeto trafico ya está en memoria, solo enviamos el correo
        // Los datos ya vienen actualizados desde el formulario de cita
        if (trafico.Marca__c == 'BMW' || trafico.Marca__c == 'MINI') {
            enviarCotizacionWalking(trafico.Id, trafico.Marca__c);
        }
    }


    // ============================================================
    // Método auxiliar: Actualizar Opp existente
    // ============================================================
    public static void actualizarOppExistente(Lead trafico, String oppId) {

        String nombreProducto = null;
        String currencyCode = null;
        String pricebook2Id = null;

        if (String.isNotBlank(trafico.Codigo_de_producto__c)) {
            List<PricebookEntry> lstPBE = [
                SELECT CurrencyIsoCode, Product2.Name, Pricebook2Id
                FROM PricebookEntry
                WHERE Id = :trafico.Codigo_de_producto__c
                LIMIT 1
            ];
            if (!lstPBE.isEmpty()) {
                currencyCode = lstPBE[0].CurrencyIsoCode;
                nombreProducto = lstPBE[0].Product2.Name;
                pricebook2Id = lstPBE[0].Pricebook2Id;
            }
        } else if (String.isNotBlank(trafico.CodigoProducto__c)) {
            nombreProducto = trafico.CodigoProducto__c;
        }

        // Eliminar OLIs y OPIs existentes antes de cambiar Pricebook2Id
        List<OpportunityLineItem> olisExistentes = [
            SELECT Id FROM OpportunityLineItem
            WHERE OpportunityId = :oppId
        ];
        if (!olisExistentes.isEmpty()) {
            List<Oportunidad_Producto_Interes__c> opisExistentes = [
                SELECT Id FROM Oportunidad_Producto_Interes__c
                WHERE Oportunidad__c = :oppId
            ];
            if (!opisExistentes.isEmpty()) {
                delete opisExistentes;
            }
            delete olisExistentes;
        }

        // Actualizar Opp
        Opportunity oppToUpdate = new Opportunity(Id = oppId);
        oppToUpdate.Trafico__c = trafico.Id; // Reemplazar con el Lead entrante
        oppToUpdate.Asesor_Online__c = trafico.OwnerId;
        oppToUpdate.OwnerId = trafico.OwnerId;
        if (nombreProducto != null) oppToUpdate.NombreProducto__c = nombreProducto;
        if (currencyCode != null)   oppToUpdate.CurrencyIsoCode = currencyCode;
        if (pricebook2Id != null)   oppToUpdate.Pricebook2Id = pricebook2Id;
        update oppToUpdate;

        // Insertar nuevos OLIs y OPIs desde el Lead actual
        RM_TransferirProductoInteres.inputTransferirProductoInteres input = new RM_TransferirProductoInteres.inputTransferirProductoInteres();
        input.leadId = trafico.Id;
        input.oppId = oppId;
        RM_TransferirProductoInteres.transferirProductoInteres(
            new List<RM_TransferirProductoInteres.inputTransferirProductoInteres>{ input }
        );

    }

    // ============================================================
    // Método auxiliar: Crear registro Walking
    // ============================================================
    private static void crearRegistroWalking(Lead trafico, String oppId) {
        List<Cita_trafico_online__c> lstCita = [
            SELECT Id, Name, Status__c, OwnerId
            FROM Cita_trafico_online__c
            WHERE Trafico__c = :trafico.Id
            LIMIT 1
        ];
        Cita_trafico_online__c citaSel = !lstCita.isEmpty() ? lstCita[0] : null;
        Registro_WalkIn__c nuevoRegistro = new Registro_WalkIn__c();
        nuevoRegistro.Nombre__c = trafico.FirstName + ' ' + trafico.LastName;
        nuevoRegistro.Correo__c = trafico.Email;
        nuevoRegistro.Descripcion__c = '';
        if(citaSel != null){
            nuevoRegistro.OwnerId = citaSel.OwnerId;
        }
        
        nuevoRegistro.Modelo_Walking__c = trafico.Modelo_De_Inter_s1__c;
        nuevoRegistro.Trafico__c = trafico.Id;
        nuevoRegistro.Opportunity__c = oppId;
        insert nuevoRegistro;
        if (trafico.Marca__c == 'BMW' || trafico.Marca__c == 'MINI') {
            enviarCotizacionWalking(trafico.Id, trafico.Marca__c);
        }
    }

    // ============================================================
    // MÉTODO: crearOppCompleta
    // Sin cambios respecto a v1 — Pricebook2Id asignado antes del insert
    // ============================================================
    private static void crearOppCompleta(Lead trafico, String cedula, String oppRecordTypeId) {
    
        // 1. Buscar Account existente por cédula
        Account cuentaExistente = null;
        if (String.isNotBlank(cedula)) {
            List<Account> lstCuenta = [
                SELECT Id, IsPersonAccount, PersonEmail, FirstName, LastName
                FROM Account
                WHERE Cedula__c = :cedula OR PersonEmail = :trafico.email
                LIMIT 1
            ];
            if (!lstCuenta.isEmpty()) {
                cuentaExistente = lstCuenta[0];
            }
        }
    
        // 2. Si no existe cuenta, crear Person Account
        if (cuentaExistente == null) {
            RecordType rtPersonAccount = [
                SELECT Id FROM RecordType
                WHERE SobjectType = 'Account' AND DeveloperName = 'PersonAccount'
                LIMIT 1
            ];
    
            Account nuevaCuenta = new Account();
            nuevaCuenta.RecordTypeId = rtPersonAccount.Id;
            nuevaCuenta.FirstName = trafico.FirstName;
            nuevaCuenta.LastName = trafico.LastName;
            nuevaCuenta.PersonEmail = trafico.Email;
            nuevaCuenta.Phone = trafico.Phone;
            nuevaCuenta.Cedula__c = cedula;
    
            if (String.isNotBlank(cedula)) {
                if (cedula.length() == 9) {
                    nuevaCuenta.Tipo_de_Documento__c = '01';
                } else if (cedula.length() == 12) {
                    nuevaCuenta.Tipo_de_Documento__c = '03';
                } else {
                    nuevaCuenta.Tipo_de_Documento__c = '04';
                }
            }
    
            insert nuevaCuenta;
            cuentaExistente = [SELECT Id, IsPersonAccount, PersonEmail FROM Account WHERE Id = :nuevaCuenta.Id];
        }
    
        // 3. Buscar Contact
        String contactoId = null;
        if (cuentaExistente.IsPersonAccount) {
            List<Contact> lstContact = [
                SELECT Id FROM Contact
                WHERE AccountId = :cuentaExistente.Id
                LIMIT 1
            ];
            if (!lstContact.isEmpty()) {
                contactoId = lstContact[0].Id;
            }
        }
    
        // 4. Obtener currency y Pricebook del PriceBookEntry
        String currencyCode = null;
        String nombreProducto = null;
        String pricebook2Id = null;
    
        if (String.isNotBlank(trafico.Codigo_de_producto__c)) {
            List<PricebookEntry> lstPBE = [
                SELECT CurrencyIsoCode, Product2.Name, Pricebook2Id
                FROM PricebookEntry
                WHERE Id = :trafico.Codigo_de_producto__c
                LIMIT 1
            ];
            if (!lstPBE.isEmpty()) {
                currencyCode = lstPBE[0].CurrencyIsoCode;
                nombreProducto = lstPBE[0].Product2.Name;
                pricebook2Id = lstPBE[0].Pricebook2Id;
            }
        } else if (String.isNotBlank(trafico.CodigoProducto__c)) {
            nombreProducto = trafico.CodigoProducto__c;
        }
    
        // 5. Crear la Opportunity
        Opportunity nuevaOpp = new Opportunity();
        nuevaOpp.AccountId = cuentaExistente.Id;
        nuevaOpp.StageName = 'Oportunidad Calificada';
        nuevaOpp.CloseDate = Date.today().addDays(57);
        nuevaOpp.Tipo_de_Cliente__c = 'Conquista';
        nuevaOpp.LeadSource = trafico.LeadSource;
        nuevaOpp.aniodelvehiculo__c = trafico.Ano1__c;
        nuevaOpp.CampaignId = trafico.Campana__c;
        nuevaOpp.Campana__c = trafico.Campana__c;
        nuevaOpp.Familia__c = trafico.Familia1__c;
        nuevaOpp.FechaDeIngreso__c = Date.valueOf(trafico.CreatedDate);
        nuevaOpp.FechaDeConversion__c = Date.today();
        nuevaOpp.ModeloDeInteresOriginal__c = trafico.Modelo_De_Inter_s1__c;
        nuevaOpp.Sucursal__c = trafico.Sucursal__c;
        nuevaOpp.Fecha_Posible_Compra__c = trafico.FechaPosibleCompra__c;
        nuevaOpp.Acci_n__c = trafico.Action__c;
        nuevaOpp.Fuente__c = trafico.Fuente__c;
        nuevaOpp.Medio__c = trafico.Medio__c;
        nuevaOpp.Campa_aNew__c = trafico.Campa_aNew__c;
        nuevaOpp.Trafico__c = trafico.Id;
        nuevaOpp.RT_Lead__c = trafico.RecordType.Name;
    
        if (oppRecordTypeId != null) {
            nuevaOpp.RecordTypeId = oppRecordTypeId;
        }
        if (contactoId != null) {
            nuevaOpp.contacto__c = contactoId;
        }
        if (currencyCode != null) {
            nuevaOpp.CurrencyIsoCode = currencyCode;
        }
        if (nombreProducto != null) {
            nuevaOpp.NombreProducto__c = nombreProducto;
        }
        if (pricebook2Id != null) {
            nuevaOpp.Pricebook2Id = pricebook2Id;
        }
    
        insert nuevaOpp;
        // 6. Crear registro Walking para la nueva Opp
        crearRegistroWalking(trafico, nuevaOpp.Id);
    
        // 7. Vincular WalkIns previos del tráfico
        List<Registro_WalkIn__c> walkInsPrevios = [
            SELECT Id, Opportunity__c
            FROM Registro_WalkIn__c
            WHERE Trafico__c = :trafico.Id
                AND Opportunity__c = null
        ];
        if (!walkInsPrevios.isEmpty()) {
            for (Registro_WalkIn__c w : walkInsPrevios) {
                w.Opportunity__c = nuevaOpp.Id;
            }
            update walkInsPrevios;
        }
    
        // 8. Transferir OLIs y OPIs
        RM_TransferirProductoInteres.inputTransferirProductoInteres input = new RM_TransferirProductoInteres.inputTransferirProductoInteres();
        input.leadId = trafico.Id;
        input.oppId = nuevaOpp.Id;
        RM_TransferirProductoInteres.transferirProductoInteres(
            new List<RM_TransferirProductoInteres.inputTransferirProductoInteres>{ input }
        );
    
        // 9. Marcar Lead como convertido
        trafico.Convertido_custom__c = true;
        trafico.Status = 'Qualified';
        update trafico;
    
        // 10. Mover Tasks del Lead a la Opportunity
        List<Task> tasks = [
            SELECT Id, WhatId, WhoId
            FROM Task
            WHERE WhoId = :trafico.Id
        ];
        if (!tasks.isEmpty()) {
            for (Task t : tasks) {
                t.WhatId = nuevaOpp.Id;
                t.WhoId = null;
            }
            update tasks;
        }
    
    }
    public static void enviarCotizacionWalking(String leadId, String marca) {
        if (marca != 'BMW' && marca != 'MINI') return;

        Lead lead = [
            SELECT Id, Email, OwnerId
            FROM Lead
            WHERE Id = :leadId
            LIMIT 1
        ];

        if (String.isBlank(lead.Email)) return;

        String templateDeveloperName = marca == 'BMW' ? 'Cotizacion_BMW' : 'Cotizacion_MINI';

        EmailTemplate template = [
            SELECT Id FROM EmailTemplate
            WHERE DeveloperName = :templateDeveloperName
            LIMIT 1
        ];

        OrgWideEmailAddress[] owea = marca == 'BMW'
            ? [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'bmwcr@redmotorscr.com']
            : [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'minicr@redmotorscr.com'];

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTemplateId(template.Id);
        email.setTargetObjectId(leadId);       // Lead es el recipient
        email.setWhatId(leadId);              // relatedTo también es el Lead
        email.setSaveAsActivity(false);
        if (!owea.isEmpty()) {
            email.setOrgWideEmailAddressId(owea[0].Id);
        }

        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
        }

    @AuraEnabled
    public static void marcarAsistenciaCita(String citaId) {
        Cita_trafico_online__c citaSel = [
            SELECT Id, Name, Status__c
            FROM Cita_trafico_online__c
            WHERE Id = :citaId
            LIMIT 1
        ];
        
        citaSel.Status__c = 'Asistió';
        update citaSel;
        
        List<Lead> lstLeadOriginal = [
            SELECT Id
            FROM Lead 
            WHERE Cita_trafico_online__c = :citaSel.Id
        ];

        if (!lstLeadOriginal.isEmpty()) {
            CommunityCalendarController.createOportunidad(
                lstLeadOriginal[0].Id                
            );
        }
        
    }

}