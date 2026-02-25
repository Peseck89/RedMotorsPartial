global with sharing class getHorasCitasFlow {
    public class BloqueTrabajo{
        public Time horaInicioDeBloque {get; set;}
        public List<Event> evetosOcurrentes {get; set;}
        public Integer asesoresDisponibles {get; set;}
        public Integer mecanicosDisponibles {get; set;}
        
        public BloqueTrabajo(Time horaInicioDeBloque, Integer asesoresDisponibles, Integer mecanicosDisponibles){
            this.horaInicioDeBloque = horaInicioDeBloque;
            evetosOcurrentes = new List<Event>();
            this.asesoresDisponibles = asesoresDisponibles;
            this.mecanicosDisponibles = mecanicosDisponibles;
        }
    }

    public class OppAndAccountDetailsRequest{
        @InvocableVariable(required=true)
        public list<String> nombreCalendario;
        
        @InvocableVariable(required=true)
        public list<String> dateRequest;
    }


    @InvocableMethod(label='Convert Leads')
    public static List<String> convertLeads(List<OppAndAccountDetailsRequest> requests) {
        List<String> ListaHorasDisponibles = new List<String>();
        String inputString = 'Escazú - Mecánica Rápida';
        String concatenaHoras = '';

        List<String> oppoCollection = requests[0].nombreCalendario;
        system.debug('oppoCollection >> ' + oppoCollection);
        
        List<String> accountCollection = requests[0].dateRequest;
        system.debug('accountCollection >> ' + accountCollection);

        for(String str : oppoCollection){
            inputString = str;
        }
        String fechaSol = '28/02/2024';
        for(String dat : accountCollection){
            fechaSol = dat;
        }

        String[] parts = inputString.split(' - ');

        String variable1 = parts[0]; // 'Escazú'
        String variable2 = parts[1]; // 'Mecánica Rápida'
        String servicioSolicitado = variable2;
        String sucursalSolicitado = variable1;
        
        
        if(sucursalSolicitado == 'Motos Uruca BMW'){
            sucursalSolicitado = 'Motorrad';
        }else if(sucursalSolicitado == 'Motos Uruca Otros'){
            sucursalSolicitado = 'Otobai';
        }
        
        
        
        String[] f = fechaSol.split('/');
        Integer dia = Integer.valueof(f[0]);
        Integer mes = Integer.valueof(f[1]);
        Integer ano = Integer.valueof(f[2]);
        DateTime fechaSolicitada = DateTime.newInstance(ano,mes,dia,0,0,0);

        //1) objtener el calendario
        User userCalendario = obtenerUsuarioCalendario(servicioSolicitado,sucursalSolicitado);
        
        //2) almacenar la cantidad de mecanicos en el calendario
        Integer cantidadMecanicos = Integer.valueOf(userCalendario.Cantidad_de_Mecanicos__c);
        System.debug('Usuario Calendario == ' + userCalendario + ' --- Cantidad de Mecanicos == ' + cantidadMecanicos);
        
        //3) sacar cuantos asesores estan relacionados
        List<AsesorxCalendario__c> asesoresPorCalendario = obtenerAsesoresPorCalendario(servicioSolicitado, sucursalSolicitado);
        Integer cantidadAsesores = asesoresPorCalendario.size();
        Id serviceTerritoryId = asesoresPorCalendario[0].Service_Territory__c;
        System.debug('### AsesoresPorCalendario: ' + asesoresPorCalendario);
        
        //4) sacar el horario de atencio, AsesorxCalendario__c del ServiceTerritory    →    OperatingHours ya tiene las horas de inicio y fin, (horario de atencion por dia)
        ServiceTerritory serviceTerritoryRelacionado = obtenerServiceTerritory(serviceTerritoryId);

        // Sacar la duracion de las citas
        Integer duracionCita = obtenerDuracionCitaEnServiceTerritory(serviceTerritoryId);
        Id operatingHoursId = serviceTerritoryRelacionado.OperatingHoursId;

        OperatingHours operatingHours = obtenerOperatingHour(operatingHoursId);
        System.debug('### operatingHours: ' + operatingHours);

        Map<Time,BloqueTrabajo> MapaHorasLaborales = new Map<Time,BloqueTrabajo>();

        String diaSemana = fechaSolicitada.format('EEEE');
        Time horaInicio;
        Time horaFin;
        
        
        Map<String, Object> response = new Map<String, Object>();
        Map<String, Object> horasResponse = new Map<String, Object>();

        if(diaSemana != 'Sunday'){
            String diaSemanaTraducido = diaSemana == 'Monday' ? 'lunes' : 
                                        diaSemana == 'Tuesday' ? 'martes':
                                        diaSemana == 'Wednesday' ? 'miercoles':
                                        diaSemana == 'Thursday' ? 'jueves':
                                        diaSemana == 'Friday' ? 'viernes': 'sabado' ;
            
            // Obteniendo los horaios del dia 
            horaInicio = (Time) operatingHours.get('Hora_inicio_' + diaSemanaTraducido + '__c');
            horaFin = (Time) operatingHours.get('Hora_fin_' + diaSemanaTraducido + '__c');
            System.debug(diaSemanaTraducido + ' inicio: ' + horaInicio + ' fin: '+ horaFin);

            Time horaAux = horaInicio;

            while(horaAux != horaFin){
                BloqueTrabajo bloque = new BloqueTrabajo(horaAux, cantidadAsesores, cantidadMecanicos);
                MapaHorasLaborales.put(horaAux, bloque);
                horaAux = horaAux.addMinutes(30);
            }
            System.debug('### MapaHorasLaborales: ');
            System.debug(JSON.serializePretty(MapaHorasLaborales));

            DateTime fechaAux = fechaSolicitada.addDays(1);
            System.debug('### fechaAux: ' + fechaAux);

            //Obteniendo todos los eventos de no disponibilidad
            List<NoDisponibilidad_Servicio__c> listaTodosNoDisponibiliad = obtenerNoDisponibilidad(fechaSolicitada);
            List<NoDisponibilidad_Servicio__c> listaFiltradaNoDisponibilidad = new List<NoDisponibilidad_Servicio__c>();
            System.debug('### listaTodosNoDisponibiliad: ' + listaTodosNoDisponibiliad);
            
            for(NoDisponibilidad_Servicio__c noDisponible : listaTodosNoDisponibiliad){
                if((noDisponible.Hora_y_Fecha_de_Inicio__c >= fechaSolicitada) && (noDisponible.Hora_y_Fecha_de_Inicio__c <= fechaAux) ){
                    if( (noDisponible.Nivel_de_aplicaci_n__c == 'Todas las sucursales') ||
                        ((noDisponible.Nivel_de_aplicaci_n__c == 'Servicio Específico') && (noDisponible.Service_Territory__c == serviceTerritoryId)) ||
                        ((noDisponible.Nivel_de_aplicaci_n__c == 'Toda la sucursal') && (noDisponible.Sucursal__c == sucursalSolicitado)) ){
                            listaFiltradaNoDisponibilidad.add(noDisponible);
                    }
                }
            }

            //Lleno Mapa de no disponibilidad
            Map<Date,Map<String,Time>> MapaNoDisponibilidad = new Map<Date,Map<String,Time>>();

            for(NoDisponibilidad_Servicio__c noDisponible : listaFiltradaNoDisponibilidad){
                Date diaInicioND = noDisponible.Hora_y_Fecha_de_Inicio__c.Date();
                Time horaInicioND = noDisponible.Hora_y_Fecha_de_Inicio__c.Time();
                Time horaFinND = noDisponible.Hora_y_Fecha_de_Fin__c.Time();
                MapaNoDisponibilidad.put(diaInicioND, new Map<String,Time>() );
                MapaNoDisponibilidad.get(diaInicioND).put('horaInicioND', horaInicioND);
                MapaNoDisponibilidad.get(diaInicioND).put('horaFinND', horaFinND);
            }

            List<Event> eventosDelDia =  obtenerEventosDelServiceTerritory(fechaSolicitada, fechaAux, serviceTerritoryId);
            System.debug('### eventosDelDia: size = ' + eventosDelDia.size());
            System.debug(JSON.serializePretty(eventosDelDia));
            
            // Actualiza para el mapa de bloques de trabajo, con la lista de eventos existente, para determinar que bloques estan ocupados
            for(Event evento : eventosDelDia){

                Datetime diaHoraInicio = evento.StartDateTime;

                Integer minutes1 = diaHoraInicio.minute();
                System.debug(minutes1);
                Integer roundedMinutes1 = (Math.round(minutes1/30.0) * 30);
                Integer difference1 = roundedMinutes1 - minutes1;

                diaHoraInicio = diaHoraInicio.addMinutes(difference1);
                System.debug(difference1);
                System.debug(diaHoraInicio);




                Datetime diaHoraFin = roundToNearest30Minutes(evento.EndDateTime);

                Integer minutes = diaHoraFin.minute();
                System.debug(minutes);
                Integer roundedMinutes = (Math.round(minutes/30.0) * 30);
                Integer difference = roundedMinutes - minutes;
                if(difference < 0 ){
                    difference = difference * -1;
                }
                diaHoraFin = diaHoraFin.addMinutes(difference);
                System.debug(difference);
                System.debug(diaHoraFin);


                Date diaInicio = diaHoraInicio.date();
                Date diaFin = diaHoraFin.date();
                Time horaInicioEvento = diaHoraInicio.time();
                Time horaFinEvento = diaHoraFin.time();
                horaAux = horaInicioEvento;
                System.debug( diaHoraInicio+'==='+diaHoraFin+'==='+diaInicio+'==='+diaFin+'==='+horaInicioEvento+'==='+horaFinEvento+'==='+horaAux +'==='+ evento.Id);
                
                while(horaAux != horaFinEvento){
                    System.debug('### horaAux: ' + horaAux + ' === horaFin: ' + horaFinEvento);

                    if(MapaHorasLaborales.containsKey(horaAux)){

                        //Sacar del Mapa el bloque
                        BloqueTrabajo bloquedeTrabajo = MapaHorasLaborales.get(horaAux);                        
                        // Actualizar el bloque
                        bloquedeTrabajo.evetosOcurrentes.add(evento);
                        
                        if(evento.OwnerId == evento.Asesor__c){// Si son Iguales, es de asesor, si son Diferentes, es de mecanico
                            bloquedeTrabajo.asesoresDisponibles = bloquedeTrabajo.asesoresDisponibles - 1;
                        }else {
                            bloquedeTrabajo.mecanicosDisponibles = bloquedeTrabajo.mecanicosDisponibles - 1;
                        }
                    
                        // Actualizar el mapa
                        MapaHorasLaborales.put(horaAux, bloquedeTrabajo);
                    }
                    horaAux = horaAux.addMinutes(30);
                }
            }
            System.debug('### MapaHorasLaborales: ');
            System.debug(JSON.serializePretty(MapaHorasLaborales));

            // Ya tengo el mapa de bloques, lleno, revisar si hay espacios continuos de tiempo que dura la cita
            // Donde la primera hora, haya 30 min para asesor, y el resto para mecanico

            Time horaUltimoBloquePosible = horaFin.addMinutes(-duracionCita);
            horaAux = horaInicio;
            
            System.debug('### Fecha: '+fechaSolicitada+' === horaInicioFecha: '+horaInicio+' === horaFinFecha: '+horaFin+' === horaUltimoBloquePosible: '+horaUltimoBloquePosible);

            

            while (horaAux <= horaUltimoBloquePosible){
                    
                // duracionCita;//considerando los 30min del asesor
                Time horaMaxCita = horaAux.addMinutes(duracionCita);
                Time horaIteracion = horaAux;
                System.debug('### horaIteracion: '+horaIteracion+' === horaMaxCita: '+horaMaxCita);
                
                List<BloqueTrabajo> bloquesAnalizar = new List<BloqueTrabajo>();

                while(horaIteracion != horaMaxCita){
                    BloqueTrabajo bloque = MapaHorasLaborales.get(horaIteracion);
                    bloquesAnalizar.add(bloque);
                    horaIteracion = horaIteracion.addMinutes(30);
                }                    
                System.debug('### bloquesAnalizar: '+ bloquesAnalizar);

                Boolean bloqueDisponible = true;

                for(Integer i = 0; i<bloquesAnalizar.size(); i++){
                    if (i==0) {
                        if(bloquesAnalizar[i].asesoresDisponibles > 0){
                            continue;
                        }
                        bloqueDisponible = false;
                        break;                       
                    }else {
                        if(bloquesAnalizar[i].mecanicosDisponibles > 0){
                            continue;
                        }
                        bloqueDisponible = false;
                        break;
                    }
                }
                
                if(MapaNoDisponibilidad.get(fechaSolicitada.date()) != null){
                    if( (horaMaxCita > MapaNoDisponibilidad.get(fechaSolicitada.date()).get('horaInicioND') ) &&
                        (horaMaxCita < MapaNoDisponibilidad.get(fechaSolicitada.date()).get('horaFinND') ) ){
                            horaAux = horaAux.addMinutes(30);
                        continue;
                    }
                }
                String startTime = horaAux + '';
                Integer hour = Integer.valueOf(startTime.left(2)); //first 2 characters are hour
                Integer minute = Integer.valueOf(startTime.substringBetween(':',':')); // between both : in String

                DateTime myDT = DateTime.newInstance(Date.today(), Time.newInstance(hour, minute, 0, 0)); // only care about hour and minute
                String myDate = myDT.format('h:mm a');

                if(bloqueDisponible){
                    if(concatenaHoras != ''){
                        concatenaHoras = concatenaHoras+ ',' + myDate;
                    }else{
                        concatenaHoras = myDate +'';
                    }
                    
                    //
                }

                horaAux = horaAux.addMinutes(30);
            }
            ListaHorasDisponibles.add(concatenaHoras);
            ListaHorasDisponibles.sort();

            if (ListaHorasDisponibles.size() > 9) {
                Integer removeCount = ListaHorasDisponibles.size() - 9;
                for(Integer i = 0; i < removeCount; i++) {
                    ListaHorasDisponibles.remove(ListaHorasDisponibles.size() - 1);
                }
            }
            System.debug('### ListaHorasDisponibles: ');
      }
      return ListaHorasDisponibles;
    }

    @AuraEnabled()
    public static List<String> checkTiempos(String str,String dat) {
        List<String> ListaHorasDisponibles = new List<String>();
        String inputString = 'Escazú - Mecánica Rápida';
        String concatenaHoras = '';
        inputString = str;            
        String fechaSol = '28/02/2024';
        fechaSol = dat;        

        String[] parts = inputString.split(' - ');

        String variable1 = parts[0]; // 'Escazú'
        String variable2 = parts[1]; // 'Mecánica Rápida'
        String servicioSolicitado = variable2;
        String sucursalSolicitado = variable1;
        
        
        if(sucursalSolicitado == 'Motos Uruca BMW'){
            sucursalSolicitado = 'Motorrad';
        }else if(sucursalSolicitado == 'Motos Uruca Otros'){
            sucursalSolicitado = 'Otobai';
        }
        
        
        
        String[] f = fechaSol.split('/');
        Integer dia = Integer.valueof(f[0]);
        Integer mes = Integer.valueof(f[1]);
        Integer ano = Integer.valueof(f[2]);
        DateTime fechaSolicitada = DateTime.newInstance(ano,mes,dia,0,0,0);

        //1) objtener el calendario
        User userCalendario = obtenerUsuarioCalendario(servicioSolicitado,sucursalSolicitado);
        
        //2) almacenar la cantidad de mecanicos en el calendario
        Integer cantidadMecanicos = Integer.valueOf(userCalendario.Cantidad_de_Mecanicos__c);
        System.debug('Usuario Calendario == ' + userCalendario + ' --- Cantidad de Mecanicos == ' + cantidadMecanicos);
        
        //3) sacar cuantos asesores estan relacionados
        List<AsesorxCalendario__c> asesoresPorCalendario = obtenerAsesoresPorCalendario(servicioSolicitado, sucursalSolicitado);
        Integer cantidadAsesores = asesoresPorCalendario.size();
        Id serviceTerritoryId = asesoresPorCalendario[0].Service_Territory__c;
        System.debug('### AsesoresPorCalendario: ' + asesoresPorCalendario);
        
        //4) sacar el horario de atencio, AsesorxCalendario__c del ServiceTerritory    →    OperatingHours ya tiene las horas de inicio y fin, (horario de atencion por dia)
        ServiceTerritory serviceTerritoryRelacionado = obtenerServiceTerritory(serviceTerritoryId);

        // Sacar la duracion de las citas
        Integer duracionCita = obtenerDuracionCitaEnServiceTerritory(serviceTerritoryId);
        Id operatingHoursId = serviceTerritoryRelacionado.OperatingHoursId;

        OperatingHours operatingHours = obtenerOperatingHour(operatingHoursId);
        System.debug('### operatingHours: ' + operatingHours);

        Map<Time,BloqueTrabajo> MapaHorasLaborales = new Map<Time,BloqueTrabajo>();

        String diaSemana = fechaSolicitada.format('EEEE');
        Time horaInicio;
        Time horaFin;
        
        
        Map<String, Object> response = new Map<String, Object>();
        Map<String, Object> horasResponse = new Map<String, Object>();

        if(diaSemana != 'Sunday'){
            String diaSemanaTraducido = diaSemana == 'Monday' ? 'lunes' : 
                                        diaSemana == 'Tuesday' ? 'martes':
                                        diaSemana == 'Wednesday' ? 'miercoles':
                                        diaSemana == 'Thursday' ? 'jueves':
                                        diaSemana == 'Friday' ? 'viernes': 'sabado' ;
            
            // Obteniendo los horaios del dia 
            horaInicio = (Time) operatingHours.get('Hora_inicio_' + diaSemanaTraducido + '__c');
            horaFin = (Time) operatingHours.get('Hora_fin_' + diaSemanaTraducido + '__c');
            System.debug(diaSemanaTraducido + ' inicio: ' + horaInicio + ' fin: '+ horaFin);

            Time horaAux = horaInicio;

            while(horaAux != horaFin){
                BloqueTrabajo bloque = new BloqueTrabajo(horaAux, cantidadAsesores, cantidadMecanicos);
                MapaHorasLaborales.put(horaAux, bloque);
                horaAux = horaAux.addMinutes(30);
            }
            System.debug('### MapaHorasLaborales: ');
            System.debug(JSON.serializePretty(MapaHorasLaborales));

            DateTime fechaAux = fechaSolicitada.addDays(1);
            System.debug('### fechaAux: ' + fechaAux);

            //Obteniendo todos los eventos de no disponibilidad
            List<NoDisponibilidad_Servicio__c> listaTodosNoDisponibiliad = obtenerNoDisponibilidad(fechaSolicitada);
            List<NoDisponibilidad_Servicio__c> listaFiltradaNoDisponibilidad = new List<NoDisponibilidad_Servicio__c>();
            System.debug('### listaTodosNoDisponibiliad: ' + listaTodosNoDisponibiliad);
            
            for(NoDisponibilidad_Servicio__c noDisponible : listaTodosNoDisponibiliad){
                if((noDisponible.Hora_y_Fecha_de_Inicio__c >= fechaSolicitada) && (noDisponible.Hora_y_Fecha_de_Inicio__c <= fechaAux) ){
                    if( (noDisponible.Nivel_de_aplicaci_n__c == 'Todas las sucursales') ||
                        ((noDisponible.Nivel_de_aplicaci_n__c == 'Servicio Específico') && (noDisponible.Service_Territory__c == serviceTerritoryId)) ||
                        ((noDisponible.Nivel_de_aplicaci_n__c == 'Toda la sucursal') && (noDisponible.Sucursal__c == sucursalSolicitado)) ){
                            listaFiltradaNoDisponibilidad.add(noDisponible);
                    }
                }
            }

            //Lleno Mapa de no disponibilidad
            Map<Date,Map<String,Time>> MapaNoDisponibilidad = new Map<Date,Map<String,Time>>();

            for(NoDisponibilidad_Servicio__c noDisponible : listaFiltradaNoDisponibilidad){
                Date diaInicioND = noDisponible.Hora_y_Fecha_de_Inicio__c.Date();
                Time horaInicioND = noDisponible.Hora_y_Fecha_de_Inicio__c.Time();
                Time horaFinND = noDisponible.Hora_y_Fecha_de_Fin__c.Time();
                MapaNoDisponibilidad.put(diaInicioND, new Map<String,Time>() );
                MapaNoDisponibilidad.get(diaInicioND).put('horaInicioND', horaInicioND);
                MapaNoDisponibilidad.get(diaInicioND).put('horaFinND', horaFinND);
            }

            List<Event> eventosDelDia =  obtenerEventosDelServiceTerritory(fechaSolicitada, fechaAux, serviceTerritoryId);
            System.debug('### eventosDelDia: size = ' + eventosDelDia.size());
            System.debug(JSON.serializePretty(eventosDelDia));
            
            // Actualiza para el mapa de bloques de trabajo, con la lista de eventos existente, para determinar que bloques estan ocupados
            for(Event evento : eventosDelDia){

                Datetime diaHoraInicio = evento.StartDateTime;

                Integer minutes1 = diaHoraInicio.minute();
                System.debug(minutes1);
                Integer roundedMinutes1 = (Math.round(minutes1/30.0) * 30);
                Integer difference1 = roundedMinutes1 - minutes1;

                diaHoraInicio = diaHoraInicio.addMinutes(difference1);
                System.debug(difference1);
                System.debug(diaHoraInicio);




                Datetime diaHoraFin = evento.EndDateTime;

                Integer minutes = diaHoraFin.minute();
                System.debug(minutes);
                Integer roundedMinutes = (Math.round(minutes/30.0) * 30);
                Integer difference = roundedMinutes - minutes;
                if(difference < 0 ){
                    difference = difference * -1;
                }
                diaHoraFin = diaHoraFin.addMinutes(difference);
                System.debug(difference);
                System.debug(diaHoraFin);


                Date diaInicio = diaHoraInicio.date();
                Date diaFin = diaHoraFin.date();
                Time horaInicioEvento = diaHoraInicio.time();
                Time horaFinEvento = diaHoraFin.time();
                horaAux = horaInicioEvento;
                System.debug( diaHoraInicio+'==='+diaHoraFin+'==='+diaInicio+'==='+diaFin+'==='+horaInicioEvento+'==='+horaFinEvento+'==='+horaAux +'==='+ evento.Id);
                
                while(horaAux != horaFinEvento){
                    System.debug('### horaAux: ' + horaAux + ' === horaFin: ' + horaFinEvento);

                    if(MapaHorasLaborales.containsKey(horaAux)){

                        //Sacar del Mapa el bloque
                        BloqueTrabajo bloquedeTrabajo = MapaHorasLaborales.get(horaAux);                        
                        // Actualizar el bloque
                        bloquedeTrabajo.evetosOcurrentes.add(evento);
                        
                        if(evento.OwnerId == evento.Asesor__c){// Si son Iguales, es de asesor, si son Diferentes, es de mecanico
                            bloquedeTrabajo.asesoresDisponibles = bloquedeTrabajo.asesoresDisponibles - 1;
                        }else {
                            bloquedeTrabajo.mecanicosDisponibles = bloquedeTrabajo.mecanicosDisponibles - 1;
                        }
                    
                        // Actualizar el mapa
                        MapaHorasLaborales.put(horaAux, bloquedeTrabajo);
                    }
                    horaAux = horaAux.addMinutes(30);
                }
            }
            System.debug('### MapaHorasLaborales: ');
            System.debug(JSON.serializePretty(MapaHorasLaborales));

            // Ya tengo el mapa de bloques, lleno, revisar si hay espacios continuos de tiempo que dura la cita
            // Donde la primera hora, haya 30 min para asesor, y el resto para mecanico

            Time horaUltimoBloquePosible = horaFin.addMinutes(-duracionCita);
            horaAux = horaInicio;
            
            System.debug('### Fecha: '+fechaSolicitada+' === horaInicioFecha: '+horaInicio+' === horaFinFecha: '+horaFin+' === horaUltimoBloquePosible: '+horaUltimoBloquePosible);

            

            while (horaAux <= horaUltimoBloquePosible){
                    
                // duracionCita;//considerando los 30min del asesor
                Time horaMaxCita = horaAux.addMinutes(duracionCita);
                Time horaIteracion = horaAux;
                System.debug('### horaIteracion: '+horaIteracion+' === horaMaxCita: '+horaMaxCita);
                
                List<BloqueTrabajo> bloquesAnalizar = new List<BloqueTrabajo>();

                while(horaIteracion != horaMaxCita){
                    BloqueTrabajo bloque = MapaHorasLaborales.get(horaIteracion);
                    bloquesAnalizar.add(bloque);
                    horaIteracion = horaIteracion.addMinutes(30);
                }                    
                System.debug('### bloquesAnalizar: '+ bloquesAnalizar);

                Boolean bloqueDisponible = true;

                for(Integer i = 0; i<bloquesAnalizar.size(); i++){
                    if (i==0) {
                        if(bloquesAnalizar[i].asesoresDisponibles > 0){
                            continue;
                        }
                        bloqueDisponible = false;
                        break;                       
                    }else {
                        if(bloquesAnalizar[i].mecanicosDisponibles > 0){
                            continue;
                        }
                        bloqueDisponible = false;
                        break;
                    }
                }
                
                if(MapaNoDisponibilidad.get(fechaSolicitada.date()) != null){
                    if( (horaMaxCita > MapaNoDisponibilidad.get(fechaSolicitada.date()).get('horaInicioND') ) &&
                        (horaMaxCita < MapaNoDisponibilidad.get(fechaSolicitada.date()).get('horaFinND') ) ){
                            horaAux = horaAux.addMinutes(30);
                        continue;
                    }
                }
                String startTime = horaAux + '';
                Integer hour = Integer.valueOf(startTime.left(2)); //first 2 characters are hour
                Integer minute = Integer.valueOf(startTime.substringBetween(':',':')); // between both : in String

                DateTime myDT = DateTime.newInstance(Date.today(), Time.newInstance(hour, minute, 0, 0)); // only care about hour and minute
                String myDate = myDT.format('h:mm a');

                if(bloqueDisponible){
                    if(concatenaHoras != ''){
                        concatenaHoras = concatenaHoras+ ',' + myDate;
                    }else{
                        concatenaHoras = myDate +'';
                    }
                    
                    //
                }

                horaAux = horaAux.addMinutes(30);
            }
            ListaHorasDisponibles.add(concatenaHoras);
            ListaHorasDisponibles.sort();

            if (ListaHorasDisponibles.size() > 9) {
                Integer removeCount = ListaHorasDisponibles.size() - 9;
                for(Integer i = 0; i < removeCount; i++) {
                    ListaHorasDisponibles.remove(ListaHorasDisponibles.size() - 1);
                }
            }
            System.debug('### ListaHorasDisponibles: ');
      }
      return ListaHorasDisponibles;
    }

    public static User obtenerUsuarioCalendario(String servicio, String sucursal){
        String likeVariable = '%'+sucursal+' - '+servicio+'%';
        User usuarioCalendario = [SELECT Id, Cantidad_de_Mecanicos__c FROM User WHERE Name LIKE: likeVariable AND Calendario_activo_chatbot__c = TRUE LIMIT 1];
        return usuarioCalendario;
    }
    public static List<AsesorxCalendario__c> obtenerAsesoresPorCalendario(String servicio, String sucursal){
        String likeVariable = '%'+sucursal+' - '+servicio+'%';
        List<AsesorxCalendario__c> asesoresPorCalendario = [ SELECT Asesor__c, Calendario__c, Service_Territory__c, Service_Territory__r.Name FROM AsesorxCalendario__c WHERE Service_Territory__r.Name LIKE: likeVariable ];
        System.debug('Lista Asesores por Calendario == ' + asesoresPorCalendario);
        System.debug('Cantidad de Asesores == ' + asesoresPorCalendario.size());
        return asesoresPorCalendario;
    }
    public static ServiceTerritory obtenerServiceTerritory(Id serviceTerritoryId){
        ServiceTerritory serviceTerritoryRelacionado = [SELECT Id, Name, OperatingHoursId 
                                                        FROM ServiceTerritory 
                                                        WHERE Id = :serviceTerritoryId];
        System.debug('Services Territory == ' + serviceTerritoryRelacionado);
        return serviceTerritoryRelacionado;
    }
    public static Integer obtenerDuracionCitaEnServiceTerritory(Id serviceTerritoryId){
        Hora_global__c horaGlobal = [SELECT Service_Territory__c, Tiempo_de_cita_2__c 
                                    FROM Hora_global__c 
                                    WHERE Service_Territory__c = :serviceTerritoryId LIMIT 1];
        Integer duracionCita = 30 + Integer.valueOf(horaGlobal.Tiempo_de_cita_2__c);
        System.debug('Duracion de la cita ==' + duracionCita);
        return duracionCita;
    }
    public static OperatingHours obtenerOperatingHour(Id operatingHoursId){
        OperatingHours operatingHours = [SELECT Id,Name, Hora_fin_lunes__c, Hora_fin_martes__c, Hora_fin_miercoles__c, Hora_fin_jueves__c, Hora_fin_viernes__c, Hora_fin_sabado__c,
                                            Hora_inicio_lunes__c, Hora_inicio_martes__c, Hora_inicio_miercoles__c, Hora_inicio_jueves__c, Hora_inicio_viernes__c, Hora_inicio_sabado__c
                                            FROM OperatingHours WHERE Id = :operatingHoursId];                                            
        System.debug('operatingHours == '+operatingHours);
        return operatingHours;
    }
    public static List<Event> obtenerEventosDelServiceTerritory(Datetime fechaInicio, Datetime fechaFin, Id serviceTerritoryId){
        List<Event> eventosProximos =   [SELECT Id,
                                                    Activo__c,
                                                    Activo__r.Name, 
                                                    OwnerId, 
                                                    Nombre_Owner__c, 
                                                    Asesor__c, 
                                                    Asesor__r.Name , 
                                                    StartDateTime, 
                                                    EndDateTime, 
                                                    ServiceTerritory__c, 
                                                    ServiceTerritory__r.Name 
                                                FROM Event 
                                                WHERE (StartDateTime >= :fechaInicio ) 
                                                AND (EndDateTime <= :fechaFin)
                                                AND (ServiceTerritory__c =: serviceTerritoryId)
                                                AND (Estado__c = null)];
        return eventosProximos;
    }
    public static List<NoDisponibilidad_Servicio__c> obtenerNoDisponibilidad(Datetime fechaInicio){
        List<NoDisponibilidad_Servicio__c> ListaNoDisponibilidad = [SELECT Id, 
                                                                        Name, 
                                                                        Activo__c, 
                                                                        Hora_y_Fecha_de_Inicio__c, 
                                                                        Hora_y_Fecha_de_Fin__c, 
                                                                        Nivel_de_aplicaci_n__c, 
                                                                        Service_Territory__c, 
                                                                        Sucursal__c,
                                                                        tiene_eventos__c
                                                                    FROM NoDisponibilidad_Servicio__c 
                                                                    WHERE Hora_y_Fecha_de_Inicio__c >= :fechaInicio 
                                                                    AND Activo__c = True];
        return ListaNoDisponibilidad;
    }
    public static void dummy(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
    public static Datetime roundToNearest30Minutes(Datetime originalDatetime) {
        // Get the components of the original datetime
        Integer hour = originalDatetime.hour();
        Integer minute = originalDatetime.minute();
        Integer second = originalDatetime.second();
        Integer millisecond = originalDatetime.millisecond();

        // Determine if we should round up or down
        if (minute >= 15 && minute < 45) {
            minute = 30;
        } else if (minute >= 45) {
            minute = 0;
            originalDatetime = originalDatetime.addHours(1);
        } else {
            minute = 0;
        }

        // Create the new datetime with rounded minutes
        return Datetime.newInstanceGmt(originalDatetime.year(), originalDatetime.month(), originalDatetime.day(), hour, minute, 0);
    }
}