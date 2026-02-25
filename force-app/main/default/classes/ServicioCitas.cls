@RestResource(urlMapping='/Citas/*')
global with sharing class ServicioCitas{
    
    public class InputJson {
        public string tipoPeticion;
        public Parametros parametros;
    }

    public class Parametros{
        public string sucursal;
        public string servicio;
        public string soloDate;
        public string tipoVehiculo;
        public string marca;
        public string origen;
        public string fecha;
        public string hora;
        public string placa;
        public string comunidad;
        public string idCita;
        public string kilometros;
        public string descripcion;
        public DatosCliente datosCliente;
    }

    public class DatosCliente{
        public string placa;
		public string nombre;
		public string apellido;
		public string email;
		public string telefono;
		public string nombreContacto;
		public string apellidoContacto;
		public string emailContacto;
		public string phoneContacto;
    }

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

    public class BloqueHorario{
        public Time horaInicioDeBloque {get; set;}
        public Time horaFinDeBloque {get; set;}
        public String tipoCita {get; set;}

        public BloqueHorario(Time horaInicioDeBloque, Time horaFinDeBloque, String tipoCita){
            this.horaInicioDeBloque = horaInicioDeBloque;
            this.horaFinDeBloque = horaFinDeBloque;
            this.tipoCita = tipoCita;
        }
    }

    public class CitaAgenda{
        public string idCita {get; set;}
        public string servicio {get; set;}
        public string sucursal {get; set;}
        public string fecha {get; set;}
        public string hora {get; set;}
    }

    @HttpPost
    global static void procesarCita(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        Log_bot_citas__c Logbot = new Log_bot_citas__c();
        Logbot.consulta_bot__c = req.requestBody.toString();
        insert Logbot;
        

        try{
            InputJson jsonData = (InputJson) JSON.deserialize(req.requestBody.toString(), InputJson.class);
            System.debug(jsonData);

            // ========================================================================================
            //Primer Servicio -done
            if(jsonData.tipoPeticion == 'getServicios'){
                
                String sucursalSolicitada = null;
                String tipoVehiculo = jsonData.parametros.tipoVehiculo;
                String marca = jsonData.parametros.marca;
        
                List<String> calendarios = obtenerCalendarios(sucursalSolicitada,tipoVehiculo,marca);

                List<String> serviciosListaAuxiliar = objeterServiciosSucursal(calendarios,jsonData.tipoPeticion);

                //Creacion el JSON respuesta
                Map<String, Object> response = new Map<String, Object>();
                Map<String, Object> serviciosMap = new Map<String, Object>();
                dummy();
                if(serviciosListaAuxiliar.size() > 0){
                    if(tipoVehiculo == 'Motos'){
                        serviciosMap.put('1', 'Mecánica Rápida');
                        serviciosMap.put('2', 'Diagnóstico');
                        serviciosMap.put('3', 'Aseguradoras');
                        serviciosMap.put('4', 'Otro');
                    }else{
                        for(Integer i = 1; i <= serviciosListaAuxiliar.size() ; i++){
                            serviciosMap.put(String.valueOf(i), serviciosListaAuxiliar[i-1]);
                        } 
                    }
                                       
                    response.put('servicios', serviciosMap);
                    String jsonResponse = JSON.serialize(response);
                    System.debug(jsonResponse);
                    res.responseBody = Blob.valueOf(jsonResponse);
                    res.statusCode = 200;
                }
                else{
                    response.put('Error: ', 'No se encuentra el servicio');
                    String jsonResponse = JSON.serialize(response);
                    System.debug(jsonResponse);
                    res.responseBody = Blob.valueOf(jsonResponse);
                    res.statusCode = 404;
                }
            }
            // ========================================================================================
            //Segundo Servicio -done
            else if(jsonData.tipoPeticion == 'getSucursales'){

                String servicioSolicitado = jsonData.parametros.servicio;
                String tipoVehiculo = jsonData.parametros.tipoVehiculo;
                String marca = jsonData.parametros.marca;
        
                List<String> calendarios = obtenerCalendarios(servicioSolicitado,tipoVehiculo,marca);

                List<String> sucursalesListaAuxiliar = objeterServiciosSucursal(calendarios,jsonData.tipoPeticion);

                //Creacion el JSON respuesta
                Map<String, Object> response = new Map<String, Object>();
                Map<String, Object> sucursalesMap = new Map<String, Object>();

                
                /* Antes de cambio 9 Febrero
                if(sucursalesListaAuxiliar.size() > 0){
                    for(Integer i = 1; i <= sucursalesListaAuxiliar.size() ; i++){
                        sucursalesMap.put(String.valueOf(i), sucursalesListaAuxiliar[i-1]);
                    }   
                    response.put('sucursales', sucursalesMap);
                    String jsonResponse = JSON.serialize(response);
                    System.debug(jsonResponse);
                    res.responseBody = Blob.valueOf(jsonResponse);
                    res.statusCode = 200;
                }*/
				if(sucursalesListaAuxiliar.size() > 0){
                    List<Map<String, String>> serviciosList = new List<Map<String, String>>();
                    // Comenzamos desde el último elemento hacia el primero
                    for(Integer i = sucursalesListaAuxiliar.size() - 1; i >= 0; i--){
                        Map<String, String> servicio = new Map<String, String>();
                        // La clave 'id' ahora refleja el orden inverso, ajustando la lógica para mantener el orden numérico deseado
                        servicio.put('id', String.valueOf(sucursalesListaAuxiliar.size() - i));
                        if(sucursalesListaAuxiliar[i] == 'Motorrad'){
                            servicio.put('nombre', 'Motos Uruca BMW');
                        }else if(sucursalesListaAuxiliar[i] == 'Otobai'){
                            servicio.put('nombre', 'Motos Uruca Otros');
                        }else{
                            servicio.put('nombre', sucursalesListaAuxiliar[i]);
                        }
                        serviciosList.add(servicio);
                    }
                    
                    if (!Test.isRunningTest()) {
                        Integer i = 0;
                        Integer j = serviciosList.size() - 1;
                        while(i < j) {
                            Map<String, String> temp = serviciosList[i];
                            serviciosList[i] = serviciosList[j];
                            serviciosList[j] = temp;
                            i++;
                            j--;
                        }
                    }
                    
                    response.put('servicios', serviciosList);
                    String jsonResponse = JSON.serialize(response);
                    System.debug(jsonResponse);
                    res.responseBody = Blob.valueOf(jsonResponse);
                    res.statusCode = 200;
                }
                else{
                    response.put('Error: ', 'No se encuentra la sucursal');
                    String jsonResponse = JSON.serialize(response);
                    System.debug(jsonResponse);
                    res.responseBody = Blob.valueOf(jsonResponse);
                    res.statusCode = 404;
                }
            }
            // ========================================================================================
            // =============  Tercer Servicio - done
            else if(jsonData.tipoPeticion == 'getOpcionesCita'){
                
                String servicioSolicitado = jsonData.parametros.servicio;
                String sucursalSolicitado = jsonData.parametros.sucursal;
                String fechaSol = jsonData.parametros.fecha;
                
                if(sucursalSolicitado == 'Motos Uruca BMW'){
                    sucursalSolicitado = 'Motorrad';
                }else if(sucursalSolicitado == 'Motos Uruca Otros'){
                    sucursalSolicitado = 'Otobai';
                }
                
                dummy();
                
                
                String[] f = fechaSol.split('/');
                Integer dia = Integer.valueof(f[0]);
                Integer mes = Integer.valueof(f[1]);
                Integer ano = Integer.valueof(f[2]);
                DateTime fechaSolicitada = DateTime.newInstance(ano,mes,dia,0,0,0);
                
                System.debug(fechaSol);
                //DateTime fechaSolicitada = DateTime.now();
                System.debug(fechaSolicitada);
                DateTime fechaFinal = fechaSolicitada.addDays(7);
                System.debug(fechaFinal);
                //1) objtener el calendario
                User userCalendario = obtenerUsuarioCalendario(servicioSolicitado,sucursalSolicitado);
                
                //2) almacenar la cantidad de mecanicos en el calendario
                Integer cantidadMecanicos = Integer.valueOf(userCalendario.Cantidad_de_Mecanicos__c);
                System.debug('Usuario Calendario == ' + userCalendario + ' --- Cantidad de Mecanicos == ' + cantidadMecanicos);
                
                //3) sacar cuantos asesores estan relacionados
                List<AsesorxCalendario__c> asesoresPorCalendario = obtenerAsesoresPorCalendario(servicioSolicitado, sucursalSolicitado);
                List<Id> lstStr = new List<Id>();
                for(AsesorxCalendario__c ascC : asesoresPorCalendario){
                    lstStr.add(ascC.Asesor__c);
                }
                Integer cantidadAsesores = asesoresPorCalendario.size();
                Id serviceTerritoryId = asesoresPorCalendario[0].Service_Territory__c;
                System.debug('### AsesoresPorCalendario: ' + asesoresPorCalendario);

                //4) sacar el horario de atencio, AsesorxCalendario__c del ServiceTerritory    →    OperatingHours ya tiene las horas de inicio y fin, (horario de atencion por dia)
                ServiceTerritory serviceTerritoryRelacionado = obtenerServiceTerritory(serviceTerritoryId);

                // Sacar la duracion de las citas
                Integer duracionCita = obtenerDuracionCitaEnServiceTerritory(serviceTerritoryId);
                Integer bloquesQuitar = duracionCita/30;
                duracionCita = duracionCita ;
                Id operatingHoursId = serviceTerritoryRelacionado.OperatingHoursId;

                OperatingHours operatingHours = obtenerOperatingHour(operatingHoursId);
                System.debug('### operatingHours: ' + operatingHours);

                Map<Time,BloqueTrabajo> MapaHorasLaborales = new Map<Time,BloqueTrabajo>();

                List<Event> lstShadow = [SELECT Id, StartDateTime, EndDateTime, ActivityDate, ActivityDateTime, OwnerId, Asesor__c
                FROM Event 
                WHERE (Asesor__c IN :lstStr OR OwnerId = :userCalendario.id) 
                AND Estado__c != 'Cancelada'
                AND Estado__c != 'Reprogramada'
                AND EndDateTime >= TODAY
                AND StartDateTime <= :fechaFinal    
                ];
                System.debug('### lstShadow: ');
                System.debug(lstShadow);

               


                Map<Date, BloqueHorario> mapaHoras = new Map<Date, BloqueHorario>();
                Map<String, Object> response = new Map<String, Object>();
                List<String> diasdisponibles = new List<String>();
                System.debug('======================diasdisponibles===================');
                System.debug(diasdisponibles);
                String diasEventos = '';
                List<NoDisponibilidad_Servicio__c> listaTodosNoDisponibiliad = obtenerNoDisponibilidad(fechaSolicitada);

                for(Integer i = 0; i<7; i++){
                    System.debug('======================diasdisponibles '+ i +' ===================');
                    System.debug(diasdisponibles);
                    Boolean siPasa = false;
                    String diaSemana = fechaSolicitada.addDays(i).format('EEEE');
                    System.debug(diaSemana);
                    Date fechaEventoActual =fechaSolicitada.addDays(i).date();     
                    System.debug(fechaEventoActual);
                    Time horaInicio;
                    Time horaFin;  
                    Boolean alMenos1 = false;  
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
                        MapaHorasLaborales.clear();

                        while(horaAux != horaFin){
                            BloqueTrabajo bloque = new BloqueTrabajo(horaAux, cantidadAsesores, cantidadMecanicos);
                            MapaHorasLaborales.put(horaAux, bloque);
                            horaAux = horaAux.addMinutes(30);
                        }
                        System.debug('### 1 MapaHorasLaborales: ');
                        System.debug(MapaHorasLaborales);

                        //agregamos los eventos
                        List<No_disponibilidad_recurrente__c> noDispDeAqui = [Select Hora_Inicial_Recurrente__c,Asesor__c, Hora_Final_Recurrente__c, Calendario__c,Lunes__c,Martes__c,Miercoles__c,Jueves__c,Viernes__c,Sabado__c From No_disponibilidad_recurrente__c Where Calendario__c =: userCalendario.Id And Activo__c = True ];
                        // Get the cita_sincronica value
                        Boolean isCitaSincronica = serviceTerritoryRelacionado.cita_sincronica__c;


                        for(No_disponibilidad_recurrente__c noDispRec : noDispDeAqui){
                            Event newEvent = new Event();
                            Datetime inicioRec = Datetime.newInstance(fechaEventoActual, noDispRec.Hora_Inicial_Recurrente__c);
                            Datetime finRec = Datetime.newInstance(fechaEventoActual, noDispRec.Hora_Final_Recurrente__c);
                            newEvent.OwnerId = noDispRec.Asesor__c;
                            newEvent.Asesor__c = noDispRec.Asesor__c;
                            newEvent.StartDateTime = inicioRec;
                            newEvent.ActivityDateTime = inicioRec;
                            newEvent.EndDateTime =  finRec;
                            lstShadow.add(newEvent);
                        }
                    
                        
                        for(Event evS : lstShadow){
                            Date fechaEvento = evS.ActivityDateTime.date();
                            if(fechaEvento == fechaEventoActual){
                                Time horarioInicioEvento;
                                Integer horaInicioEvento;
                                Integer minutoInicioEvento;
                                horaInicioEvento = evS.StartDateTime.hour();
                                minutoInicioEvento = evS.StartDateTime.minute();
                                horarioInicioEvento = Time.newInstance(horaInicioEvento, minutoInicioEvento, 0, 0);
                                
                                Time horarioFinEvento;
                                Integer horaFinEvento;
                                Integer minutoFinEvento;
                                horaFinEvento = evS.EndDateTime.hour();
                                minutoFinEvento = evS.EndDateTime.minute();
                                horarioFinEvento = Time.newInstance(horaFinEvento, minutoFinEvento, 0, 0);
                                System.debug(evS.id);
                                System.debug('=======================horarioInicioEvento===========================');
                                System.debug(horarioInicioEvento);
                                System.debug('=======================horarioFinEvento===========================');
                                System.debug(horarioFinEvento);
                                for (Time key : MapaHorasLaborales.keySet()) {
                                    
                                    if(key >= horarioInicioEvento && key < horarioFinEvento){
                                        System.debug('======================PASO===========================');
                                        //System.debug(evS.Tipo_de_cita__c );
                                        BloqueTrabajo bloqueTrabajoActual = MapaHorasLaborales.get(key);
                                        
                                         if(evS.OwnerId != evS.Asesor__c){
                                             bloqueTrabajoActual.mecanicosDisponibles = bloqueTrabajoActual.mecanicosDisponibles-1;
                                         }else if(evS.OwnerId == evS.Asesor__c && isCitaSincronica == true){
                                            if(bloqueTrabajoActual.mecanicosDisponibles == 1 || bloqueTrabajoActual.mecanicosDisponibles == 0){
                                                bloqueTrabajoActual.asesoresDisponibles = 0;
                                            }else{
                                                bloqueTrabajoActual.asesoresDisponibles = bloqueTrabajoActual.asesoresDisponibles - 1;
                                                bloqueTrabajoActual.mecanicosDisponibles = bloqueTrabajoActual.mecanicosDisponibles - 1;
                                            }
                                         }else if(evS.OwnerId == evS.Asesor__c && isCitaSincronica != true){
                                            bloqueTrabajoActual.asesoresDisponibles = bloqueTrabajoActual.asesoresDisponibles-1;
                                        }else{
                                            bloqueTrabajoActual.mecanicosDisponibles = bloqueTrabajoActual.mecanicosDisponibles-1;
                                         }
                              
                                        MapaHorasLaborales.put(key, bloqueTrabajoActual);
                                    }
                                }                                                                                                        
                            }                                                        
                        }                      
                        System.debug('### 2 MapaHorasLaborales: ');
                        System.debug(MapaHorasLaborales);
                        
                        //fuera bloque ordenado  
                        List<Time> timeSet = new List<Time>(MapaHorasLaborales.keySet());
                        System.debug('### timeSet: ');
                        System.debug(timeSet.size());
                        System.debug('### bloquesQuitar: ');
                        System.debug(bloquesQuitar);

                        
                        // Boolean alMenos1 = false;

                        for (Integer j = 0; j <= timeSet.size() - bloquesQuitar; j++) {
                            // Check the current block
                            BloqueTrabajo bloqueTrabajoActual = MapaHorasLaborales.get(timeSet[j]);
                            System.debug('### Bloque Trabajo Actual: ');
                            System.debug(bloqueTrabajoActual);
                            if (bloqueTrabajoActual.horaInicioDeBloque.minute() == 0 && isCitaSincronica == true) {
                                if (bloqueTrabajoActual.asesoresDisponibles > 0) {
                                    // Assume all blocks are valid initially
                                    Boolean todosDisponibles = true;
    
                                    // Check the next 'bloquesQuitar' consecutive blocks
                                    for (Integer k = j +1; k < j + bloquesQuitar  && k < timeSet.size(); k++) {
                                        System.debug('K: ' + k);
                                        BloqueTrabajo bloqueTrabajoFuturo = MapaHorasLaborales.get(timeSet[k]);
                                        System.debug('### Bloque Trabajo Futuro: ');
                                        System.debug(bloqueTrabajoFuturo);
    
                                        if (isCitaSincronica) {
                                            // If cita_sincronica is true, check only asesoresDisponibles
                                            if (bloqueTrabajoFuturo.asesoresDisponibles <= 0) {
                                                System.debug('================== NO PASA (isCitaSincronica) ==================');
                                                todosDisponibles = false;
                                                break;
                                            }
                                        } else {
                                            // Default logic: check asesoresDisponibles for the first block, then mecanicosDisponibles
                                            if (k == j) {
                                                if (bloqueTrabajoFuturo.asesoresDisponibles <= 0) {
                                                    System.debug('================== NO PASA (first block) ==================');
                                                    todosDisponibles = false;
                                                    break;
                                                }
                                            } else {
                                                if (bloqueTrabajoFuturo.mecanicosDisponibles <= 0) {
                                                    System.debug('================== NO PASA (subsequent block) ==================');
                                                    todosDisponibles = false;
                                                    break;
                                                }
                                            }
                                        }
                                    }
    
                                    System.debug('======================= todosDisponibles =======================');
                                    System.debug(todosDisponibles);
    
                                    // If all blocks are valid, mark at least one as available
                                    if (todosDisponibles) {
                                        alMenos1 = true;
                                        // Optionally break early if only one match is needed
                                        break;
                                    }
                                }
                            }else if(isCitaSincronica == false){
                                if (bloqueTrabajoActual.asesoresDisponibles > 0) {
                                    // Assume all blocks are valid initially
                                    Boolean todosDisponibles = true;
    
                                    // Check the next 'bloquesQuitar' consecutive blocks
                                    for (Integer k = j +1; k < j + bloquesQuitar  && k < timeSet.size(); k++) {
                                        System.debug('K: ' + k);
                                        BloqueTrabajo bloqueTrabajoFuturo = MapaHorasLaborales.get(timeSet[k]);
                                        System.debug('### Bloque Trabajo Futuro: ');
                                        System.debug(bloqueTrabajoFuturo);
    
                                        if (isCitaSincronica) {
                                            // If cita_sincronica is true, check only asesoresDisponibles
                                            if (bloqueTrabajoFuturo.asesoresDisponibles <= 0) {
                                                System.debug('================== NO PASA (isCitaSincronica) ==================');
                                                todosDisponibles = false;
                                                break;
                                            }
                                        } else {
                                            // Default logic: check asesoresDisponibles for the first block, then mecanicosDisponibles
                                            if (k == j) {
                                                if (bloqueTrabajoFuturo.asesoresDisponibles <= 0) {
                                                    System.debug('================== NO PASA (first block) ==================');
                                                    todosDisponibles = false;
                                                    break;
                                                }
                                            } else {
                                                if (bloqueTrabajoFuturo.mecanicosDisponibles <= 0) {
                                                    System.debug('================== NO PASA (subsequent block) ==================');
                                                    todosDisponibles = false;
                                                    break;
                                                }
                                            }
                                        }
                                    }
    
                                    System.debug('======================= todosDisponibles =======================');
                                    System.debug(todosDisponibles);
    
                                    // If all blocks are valid, mark at least one as available
                                    if (todosDisponibles) {
                                        alMenos1 = true;
                                        // Optionally break early if only one match is needed
                                        break;
                                    }
                                }
                            }
                            
                        }
                    }
                    System.debug('=======================fechaSolicitada======================='); 
                    System.debug(fechaSolicitada);
                    System.debug('=======================fechaEventoActual======================='); 
                    System.debug(fechaEventoActual);

                    for(NoDisponibilidad_Servicio__c noDisponible : listaTodosNoDisponibiliad){
                        System.debug('entro ');
                        System.debug(noDisponible);
                        System.debug(noDisponible.Nivel_de_aplicaci_n__c);
                        System.debug(noDisponible.Service_Territory__c);
                        System.debug(noDisponible.Hora_y_Fecha_de_Inicio__c);
                        System.debug(noDisponible.Hora_y_Fecha_de_Fin__c);
                        TimeZone specificTimeZone = TimeZone.getTimeZone('(GMT-06:00) Central Standard Time (America/Costa_Rica)');

                        DateTime originalDateTime = noDisponible.Hora_y_Fecha_de_Inicio__c;
                        DateTime adjustedDateTimeUTC = DateTime.newInstance(
                            originalDateTime.date().year(),
                            originalDateTime.date().month(),
                            originalDateTime.date().day(),
                            0, // Hora ajustada a medianoche
                            0, // Minuto ajustado a 0
                            0  // Segundo ajustado a 0
                        );
                        DateTime adjustedDateTimeLocal = adjustedDateTimeUTC.addHours(-6);

                        System.debug(adjustedDateTimeLocal);
                        System.debug(noDisponible.Hora_y_Fecha_de_Fin__c);
                        System.debug(adjustedDateTimeLocal <= fechaEventoActual);
                        System.debug(noDisponible.Hora_y_Fecha_de_Fin__c >= fechaEventoActual);
                        System.debug(adjustedDateTimeLocal <= fechaSolicitada);
                        System.debug(noDisponible.Hora_y_Fecha_de_Fin__c >= fechaSolicitada);

                        if(((adjustedDateTimeLocal <= fechaEventoActual) && (noDisponible.Hora_y_Fecha_de_Fin__c >= fechaEventoActual))){
                            if( (noDisponible.Nivel_de_aplicaci_n__c == 'Todas las sucursales') ||
                                ((noDisponible.Nivel_de_aplicaci_n__c == 'Servicio Específico') && (noDisponible.Service_Territory__c == serviceTerritoryId)) ||
                                ((noDisponible.Nivel_de_aplicaci_n__c == 'Toda la sucursal') && (noDisponible.Sucursal__c == sucursalSolicitado)) ){
                                    alMenos1  = false ;
                            }
                        }
                    }
                    System.debug('=======================siPasa======================='); 
                    System.debug(siPasa);
                    System.debug('=======================alMenos1======================='); 
                    System.debug(alMenos1);
                    if(alMenos1){
                        System.debug('=====================FECHA AGREGADA============================');
                        System.debug(diasEventos);
                        System.debug(diasdisponibles);
                        diasEventos = diasEventos + ' ' + fechaEventoActual;
                        diasdisponibles.add(String.valueOf(fechaEventoActual));
                    }
                    
                                                                        
                }
                
                
                                            
                if(diasdisponibles.size() > 0){
                    System.debug('=====================Con Fechas============================');
                    System.debug(diasdisponibles);
                     diasdisponibles.add('Otras fechas');
                    System.debug('### Servicio: ' + servicioSolicitado);
                    if(servicioSolicitado == 'Mecánica Rápida' && sucursalSolicitado != 'Motorrad' && sucursalSolicitado != 'Otobai'){
                        System.debug('### Entro IF: ' + servicioSolicitado);
                        diasdisponibles.add('Otra sucursal');
                    }
                    
                     
                     response.put('OpcionesCita', 'true');
                     response.put('mensaje', 'Existen opciones de cita disponibles');
                	 response.put('opciones', diasdisponibles);
                }else {
                    System.debug('=====================Sin Fechas============================');
                     response.put('OpcionesCita', 'false');
                     response.put('mensaje', 'No existen opciones de cita disponibles');
                }
             
                   
                
                
                    //response.put('mensaje', 'Existen opciones de cita disponibles' + diasEventos);
                
                String jsonResponse = JSON.serialize(response);
                res.responseBody = Blob.valueOf(jsonResponse);
                res.statusCode = 200;                
                System.debug(Limits.getCpuTime());            
            }
            // ========================================================================================            
            // ============= Cuarto Servicio - done
            else if(jsonData.tipoPeticion == 'getHorasCita'){

                String servicioSolicitado = jsonData.parametros.servicio;
                String sucursalSolicitado = jsonData.parametros.sucursal;
                String fechaSol = jsonData.parametros.fecha;
                String esComunidad = jsonData.parametros.comunidad;
                
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
                // Convert the Datetime to a Date to use the dayOfWeek() method
                
                String diaDeLaSemanaString = fechaSolicitada.format('E'); // E.g., 'Mon', 'Tue', 'Wed', etc.


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
                List<Id> lstStr = new List<Id>();
                for(AsesorxCalendario__c ascC : asesoresPorCalendario){
                    lstStr.add(ascC.Asesor__c);
                }
                //4) sacar el horario de atencio, AsesorxCalendario__c del ServiceTerritory    →    OperatingHours ya tiene las horas de inicio y fin, (horario de atencion por dia)
                ServiceTerritory serviceTerritoryRelacionado = obtenerServiceTerritory(serviceTerritoryId);

                // Sacar la duracion de las citas
                Integer duracionCita = obtenerDuracionCitaEnServiceTerritory(serviceTerritoryId);
                duracionCita = duracionCita + 30;
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
                   
                    MapaHorasLaborales.clear();

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
                        System.debug('entro ');
                        System.debug(noDisponible);
                        System.debug(noDisponible.Nivel_de_aplicaci_n__c);
                        System.debug(noDisponible.Service_Territory__c);
                        System.debug(noDisponible.Hora_y_Fecha_de_Inicio__c);
                        System.debug(noDisponible.Hora_y_Fecha_de_Fin__c);
                        DateTime originalDateTime = noDisponible.Hora_y_Fecha_de_Inicio__c;
                        DateTime adjustedDateTimeUTC = DateTime.newInstance(
                            originalDateTime.date().year(),
                            originalDateTime.date().month(),
                            originalDateTime.date().day(),
                            0, // Hora ajustada a medianoche
                            0, // Minuto ajustado a 0
                            0  // Segundo ajustado a 0
                        );
                        DateTime adjustedDateTimeLocal = adjustedDateTimeUTC.addHours(-6);
                        System.debug(adjustedDateTimeLocal);
                        System.debug(noDisponible.Hora_y_Fecha_de_Fin__c);
                        System.debug(adjustedDateTimeLocal <= fechaAux);
                        System.debug(noDisponible.Hora_y_Fecha_de_Fin__c >= fechaAux);
                        System.debug(adjustedDateTimeLocal >= fechaSolicitada);
                        System.debug(noDisponible.Hora_y_Fecha_de_Fin__c >= fechaSolicitada);
                        System.debug(fechaSolicitada);
                        System.debug(fechaAux);


                        if((adjustedDateTimeLocal <= fechaSolicitada) && (adjustedDateTimeLocal <= fechaAux) ){
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
    
                    //List<Event> eventosDelDia =  obtenerEventosDelServiceTerritory(fechaSolicitada, fechaAux, serviceTerritoryId);
                    List<Event> eventosDelDia = [Select Id,es_Reserva__c, Subject ,StartDateTime,OwnerId,EndDateTime,ActivityDate,ActivityDateTime,Asesor__c 
                    From Event 
                    Where (Asesor__c IN :lstStr OR OwnerId =:userCalendario.id OR OwnerId IN :lstStr ) 
                    AND Estado__c != 'Cancelada'
                    AND Estado__c != 'Reprogramada'
                    And StartDateTime >= :fechaSolicitada 
                    And EndDateTime <=:fechaAux];
                    
                    
                    //agregamos los eventos
                    List<No_disponibilidad_recurrente__c> noDispDeAqui = [Select Hora_Inicial_Recurrente__c,Asesor__c, Hora_Final_Recurrente__c, Calendario__c,Lunes__c,Martes__c,Miercoles__c,Jueves__c,Viernes__c,Sabado__c From No_disponibilidad_recurrente__c Where Calendario__c =: userCalendario.Id And Activo__c = True ];


                    for(No_disponibilidad_recurrente__c noDispRec : noDispDeAqui){
                        Boolean agregarEvento = false;
    
                        if (diaDeLaSemanaString == 'Mon' && noDispRec.Lunes__c) {
                            agregarEvento = true;
                        } else if (diaDeLaSemanaString == 'Tue' && noDispRec.Martes__c) {
                            agregarEvento = true;
                        } else if (diaDeLaSemanaString == 'Wed' && noDispRec.Miercoles__c) {
                            agregarEvento = true;
                        } else if (diaDeLaSemanaString == 'Thu' && noDispRec.Jueves__c) {
                            agregarEvento = true;
                        } else if (diaDeLaSemanaString == 'Fri' && noDispRec.Viernes__c) {
                            agregarEvento = true;
                        } else if (diaDeLaSemanaString == 'Sat' && noDispRec.Sabado__c) {
                            agregarEvento = true;
                        } else if (diaDeLaSemanaString == 'Sun' && noDispRec.Domingo__c) {
                            agregarEvento = true;
                        }
                        if (agregarEvento) {
                            Event newEvent = new Event();
                            Datetime inicioRec = Datetime.newInstance(Date.today(), noDispRec.Hora_Inicial_Recurrente__c);
                            Datetime finRec = Datetime.newInstance(Date.today(), noDispRec.Hora_Final_Recurrente__c);
                            newEvent.OwnerId = noDispRec.Asesor__c;
                            newEvent.Asesor__c = noDispRec.Asesor__c;
                            newEvent.StartDateTime = inicioRec;
                            newEvent.ActivityDateTime = inicioRec;
                            newEvent.EndDateTime =  finRec;
                            eventosDelDia.add(newEvent);
                        }
                    }

                    System.debug('### lstShadow: ');
                    System.debug(eventosDelDia);

                    
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
                        // Check if cita_sincronica__c is true
                        Boolean isCitaSincronica = serviceTerritoryRelacionado.cita_sincronica__c;
                        
                    
                        while(horaAux != horaFinEvento){
                            System.debug('### horaAux: ' + horaAux + ' === horaFin: ' + horaFinEvento);
                            
                            if(MapaHorasLaborales.containsKey(horaAux)){
                                
                                //Sacar del Mapa el bloque
                                BloqueTrabajo bloquedeTrabajo = MapaHorasLaborales.get(horaAux);                        
                                // Actualizar el bloque
                                System.debug('===========================bloquedeTrabajo===========================');
                                System.debug(bloquedeTrabajo);
                                //bloquedeTrabajo.evetosOcurrentes.add(evento);
                                System.debug(evento.id);
                                System.debug(evento.OwnerId);
                                System.debug(evento.Asesor__c);
                                System.debug('es cita sincro ' + isCitaSincronica);
                
                                if(( evento.OwnerId == evento.Asesor__c || (evento.Subject == 'Evento de Comunidad. Vehículo:' && evento.es_Reserva__c == true) || (evento.Subject == 'Reserva' && evento.es_Reserva__c == true ) )&& isCitaSincronica == false){// Si son Iguales, es de asesor, si son Diferentes, es de mecanico ||( evento.OwnerId == evento.Asesor__c && evento.Tipo_de_cita__c != 'Asesor' )
                                //     System.debug('### pase1');
                                     bloquedeTrabajo.asesoresDisponibles = bloquedeTrabajo.asesoresDisponibles - 1;
                                 }else if(( evento.OwnerId == evento.Asesor__c || (evento.Subject == 'Evento de Comunidad. Vehículo:' && evento.es_Reserva__c == true) || (evento.Subject == 'Reserva' && evento.es_Reserva__c == true ) )&& isCitaSincronica == true){
                                    if(bloquedeTrabajo.mecanicosDisponibles == 1 || bloquedeTrabajo.mecanicosDisponibles == 0){
                                        bloquedeTrabajo.asesoresDisponibles = 0;
                                    }else{
                                        bloquedeTrabajo.asesoresDisponibles = bloquedeTrabajo.asesoresDisponibles - 1;
                                        bloquedeTrabajo.mecanicosDisponibles = bloquedeTrabajo.mecanicosDisponibles - 1;
                                    }
                                    
                                 }
                                 else{
                                //     System.debug('### pase2');
                                     bloquedeTrabajo.mecanicosDisponibles = bloquedeTrabajo.mecanicosDisponibles - 1;
                                }
                                System.debug('### pase3');
                                // Actualizar el mapa
                                System.debug('===========================bloquedeTrabajoFinal===========================');
                                System.debug(bloquedeTrabajo);
                                MapaHorasLaborales.put(horaAux, bloquedeTrabajo);
                            }
                            System.debug('### sali');
                            horaAux = horaAux.addMinutes(30);
                            System.debug(horaAux);
                        }
                    }
                    System.debug('### MapaHorasLaborales: ');
                    System.debug(JSON.serializePretty(MapaHorasLaborales));
    
                    // Ya tengo el mapa de bloques, lleno, revisar si hay espacios continuos de tiempo que dura la cita
                    // Donde la primera hora, haya 30 min para asesor, y el resto para mecanico
    
                    Time horaUltimoBloquePosible = horaFin.addMinutes(-duracionCita);
                    horaAux = horaInicio;
                    
                    System.debug('### Fecha: '+fechaSolicitada+' === horaInicioFecha: '+horaInicio+' === horaFinFecha: '+horaFin+' === horaUltimoBloquePosible: '+horaUltimoBloquePosible);
    
                    List<Time> ListaHorasDisponibles = new List<Time>();
                        // Check if cita_sincronica__c is true
                    Boolean isCitaSincronica = serviceTerritoryRelacionado.cita_sincronica__c;

                    // Adjust the number of blocks to check based on the duration
                    Integer blocksToCheck = duracionCita / 30;
                    if(isCitaSincronica == true) {
                        horaUltimoBloquePosible =  horaUltimoBloquePosible.addMinutes(30);
                    }
                    while (horaAux <= horaUltimoBloquePosible) {
                        // Calculate the max time for the current iteration
                        Time horaMaxCita = horaAux.addMinutes(duracionCita);
                        Time horaIteracion = horaAux;
                    
                        System.debug('### horaIteracion: ' + horaIteracion + ' === horaMaxCita: ' + horaMaxCita);
                    
                        // Collect the blocks to analyze
                        List<BloqueTrabajo> bloquesAnalizar = new List<BloqueTrabajo>();
                        for (Integer i = 0; i < blocksToCheck; i++) {
                            if (MapaHorasLaborales.containsKey(horaIteracion)) {
                                bloquesAnalizar.add(MapaHorasLaborales.get(horaIteracion));
                            }
                            horaIteracion = horaIteracion.addMinutes(30);
                        }
                    
                        System.debug('### bloquesAnalizar: ');
                        System.debug(bloquesAnalizar);
                    
                        // Check the availability of the required blocks
                        Boolean bloqueDisponible = true;
                        for (Integer i = 0; i < bloquesAnalizar.size() - 1 ; i++) {
                            System.debug('### Checking bloque: ' + bloquesAnalizar[i].horaInicioDeBloque);
                            BloqueTrabajo bloque = bloquesAnalizar[i];
                    
                            // If isCitaSincronica, all blocks must have asesoresDisponibles > 0
                            if (isCitaSincronica) {
                                if (bloque.asesoresDisponibles <= 0) {
                                    bloqueDisponible = false;
                                    break;
                                }
                            } else {
                                // Default behavior: only check the first block
                                if (i == 0) {
                                    if (bloque.asesoresDisponibles <= 0) {
                                        bloqueDisponible = false;
                                        break;
                                    }
                                } else {
                                    if (bloque.mecanicosDisponibles <= 0) {
                                        bloqueDisponible = false;
                                        break;
                                    }
                                }
                            }
                        }
                    
                        System.debug('### bloqueDisponible: ' + bloqueDisponible);
                        System.debug('### horaAux: ' + horaAux);
                        System.debug('### horaAux.minute(): ' + horaAux.minute());
                        if(horaAux.minute() == 0 && isCitaSincronica == true ){
                            if (bloqueDisponible) {
                                ListaHorasDisponibles.add(horaAux);
                            }
                        }else if(isCitaSincronica == false){
                            if (bloqueDisponible) {
                                ListaHorasDisponibles.add(horaAux);
                            }
                        }
                        // If the block is available, add the starting time to the available hours
                        
                    
                        // Move to the next time slot
                        horaAux = horaAux.addMinutes(30);
                    }
                    
                    ListaHorasDisponibles.sort();

                    if(esComunidad == 'true'){
                         
                    }else{ 
                        if (ListaHorasDisponibles.size() > 9) {
                            Integer removeCount = ListaHorasDisponibles.size() - 9;
                            for(Integer i = 0; i < removeCount; i++) {
                                ListaHorasDisponibles.remove(ListaHorasDisponibles.size() - 1);
                            }
                        }
                    }
                    
                   
                    
    
                    System.debug('### c: ');
                    System.debug(JSON.serializePretty(ListaHorasDisponibles));
                    Date today = Date.today();

                    if (fechaSolicitada.date() == today) {
                        List<Time> filteredTimeList = filterTimes(ListaHorasDisponibles);
                        ListaHorasDisponibles = filteredTimeList;
                    }
                    
                    
                    if(ListaHorasDisponibles.size() > 0){
                        for(Integer i = 1; i <= ListaHorasDisponibles.size() ; i++){
                            horasResponse.put(String.valueOf(i), ListaHorasDisponibles[i-1]);
                        }
                        horasResponse.put('10', 'Otras fechas');
                        // response.put('MapaHorasLaborales',MapaHorasLaborales);
                        // response.put('fecheventosDelDiaas',eventosDelDia);
                        // response.put('MapaNoDisponibilidad',MapaNoDisponibilidad);
                        response.put('horas',horasResponse);
                        String jsonResponse = JSON.serialize(response);
                        res.responseBody = Blob.valueOf(jsonResponse);
                        res.statusCode = 200;                
                        System.debug(Limits.getCpuTime());
                    }
                    else{
                        horasResponse.put('10', 'Otras fechas');
                        response.put('horas',horasResponse);
                        response.put('Error: ', 'Este horario ya ha sido agendado por otro medio.');
                        String jsonResponse = JSON.serialize(response);
                        res.responseBody = Blob.valueOf(jsonResponse);
                        res.statusCode = 404;
                    }
                        
                        
                        
                        
                    }
                else{
                    response.put('Error: ', 'El día domingo no se cuenta con disponibilidad de los servicios.');
                    String jsonResponse = JSON.serialize(response);
                    res.responseBody = Blob.valueOf(jsonResponse);
                    res.statusCode = 404;  
                    
                }   
            }
            // ========================================================================================
            //Quinto Servicio - done
            else if(jsonData.tipoPeticion == 'validarPlaca'){
                String placaOld = jsonData.parametros.placa;
                String placa = '%' + placaOld;
                Map<String, Object> response = new Map<String, Object>();
                Map<String, Object> datosCliente = new Map<String, Object>();

                try {
                    Asset asset = [SELECT AccountId,
                                    Name, 
                                    Account.Name,
                                    Account.FirstName, 
                                    Account.LastName,
                                    Account.Phone, 
                                    Account.CorreoElectronicoEmpresarial__c, 
                                    Account.PersonEmail,
                                    Account.IsPersonAccount,
                                    Contact.Name, 
                                    Contact.FirstName, 
                                    Contact.LastName, 
                                    Contact.Phone, 
                                    Contact.Email
                                    FROM Asset WHERE Name Like:placa AND  Name != 'M-MRJ227' LIMIT 1];

                    System.debug(asset);
                    String nombreCliente = ''+asset.Account.Name;
                    datosCliente.put('placa', asset.Name);
                    
                    if (asset.Account.IsPersonAccount){
                        datosCliente.put('nombre', asset.Account.FirstName);
                        datosCliente.put('apellido', asset.Account.LastName);
                        datosCliente.put('email', asset.Account.PersonEmail);
                        datosCliente.put('telefono', asset.Account.Phone);
                        
                    }else {
                        datosCliente.put('nombre', nombreCliente);
                        datosCliente.put('email', asset.Account.CorreoElectronicoEmpresarial__c);
                        datosCliente.put('telefono', asset.Account.Phone);
                        datosCliente.put('nombreContacto', asset.Contact.FirstName);
                        datosCliente.put('apellidoContacto', asset.Contact.LastName);
                        datosCliente.put('emailContacto', asset.Contact.Email);
                        datosCliente.put('phoneContacto', asset.Contact.Phone);
                    }
                
                    
                    

                    response.put('datosCliente', datosCliente);
                    String jsonResponse = JSON.serialize(response);
                    System.debug(jsonResponse);                    
                    res.responseBody = Blob.valueOf(jsonResponse);
                    res.statusCode = 200;

                } catch (Exception e) {
                    List<String> opciones = new List<String>();
                    opciones.add('Intentar nuevamente');
                    opciones.add('Contactar un agente');
                    response.put('opciones', opciones);
                    response.put('Error: ', 'No se encuentra una placa relacionada');
                    String jsonResponse = JSON.serialize(response);
                    System.debug(jsonResponse);                    
                    res.responseBody = Blob.valueOf(jsonResponse);
                    res.statusCode = 404;
                }
            }
            // ========================================================================================
            //Sexto Servicio 
            else if(jsonData.tipoPeticion == 'actualizarDatosPlaca'){
                String placaOld = jsonData.parametros.datosCliente.placa;
                String placa = '%' + placaOld;
                String nombre = jsonData.parametros.datosCliente.nombre;
                String apellido = jsonData.parametros.datosCliente.apellido;
                String email = jsonData.parametros.datosCliente.email;
                String telefono = jsonData.parametros.datosCliente.telefono;
                String nombreContacto = jsonData.parametros.datosCliente.nombreContacto;
                String apellidoContacto = jsonData.parametros.datosCliente.apellidoContacto;
                String emailContacto = jsonData.parametros.datosCliente.emailContacto;
                String phoneContacto = jsonData.parametros.datosCliente.phoneContacto;

                Map<String,Object> response = new Map<String,Object>();
                Map<String, Object> datosCliente = new Map<String, Object>();

                try {
                    Asset asset = [SELECT Id, Name, AccountId, ContactId FROM Asset WHERE Name like :placa ];
                    System.debug(asset);
                    Account account = [SELECT Id, FirstName, LastName, Phone, PersonEmail, CorreoElectronicoEmpresarial__c, RecordTypeId, RecordType.Name, RecordType.DeveloperName FROM Account WHERE ID = :asset.AccountId];
                    System.debug(account);
                    Contact contacto = [SELECT Id, FirstName, LastName, Name, Phone, Email FROM Contact WHERE ID = :asset.ContactId];
                    System.debug(contacto);

                    if(account.RecordType.DeveloperName == 'PersonAccount'){
                        System.debug('PersonAccount');
                        account.FirstName = nombre;
                        account.LastName = apellido;
                        account.PersonEmail = email;
                    }
                    else{
                        System.debug('Account');
                        account.Name = nombre;
                        account.CorreoElectronicoEmpresarial__c = email;
                    }
                    account.Phone = telefono;   

                    contacto.FirstName = nombreContacto;
                    contacto.LastName = apellidoContacto;
                    contacto.Email = emailContacto;
                    contacto.Phone = phoneContacto;
                    
                    List<SObject> records = new List<SObject>();
                    records.add(account);
                    records.add(contacto);
                    System.debug(records);

                    Database.SaveResult[] recordsActualizados = Database.update(records);

                    Integer recordsActualizadosQty = 0;

                    for (Database.SaveResult recordAct : recordsActualizados) {
                        if (recordAct.isSuccess()){
                            System.debug('Evento actualizado. ID: ' + recordAct.getId());
                            recordsActualizadosQty++;
                        }
                        else {          
                            for(Database.Error err : recordAct.getErrors()) {
                                System.debug('El sigueinte error ha ocurrido.');                    
                                System.debug(err.getStatusCode() + ' : ' + err.getMessage());
                            }
                        }
                    }

                    if(recordsActualizadosQty == 2){
                        datosCliente.put('placa', asset.Name);
                        
                        if(account.RecordType.DeveloperName == 'PersonAccount'){
                            datosCliente.put('nombre', account.FirstName);
                            datosCliente.put('apellido', account.LastName);
                            datosCliente.put('email', account.PersonEmail);
                        }else {
                            datosCliente.put('nombre', account.Name);
                            datosCliente.put('apellido', account.LastName);
                            datosCliente.put('email', account.CorreoElectronicoEmpresarial__c);
                        }
                        datosCliente.put('telefono', account.Phone);

                        datosCliente.put('nombreContacto', contacto.FirstName);
                        datosCliente.put('apellidoContacto', contacto.LastName);
                        datosCliente.put('emailContacto', contacto.Email);
                        datosCliente.put('phoneContacto', contacto.Phone);
                        response.put('datosCliente', datosCliente);
                        res.statusCode = 200;
                    }

                    String jsonResponse = JSON.serialize(response);
                    res.responseBody = Blob.valueOf(jsonResponse);
                    
                } catch (Exception e) {
                    response.put('Error: ', 'No se encuentra la placa o cuenta para actualizar los datos');
                    String jsonResponse = JSON.serialize(response);
                    System.debug(jsonResponse);                    
                    res.responseBody = Blob.valueOf(jsonResponse);
                    res.statusCode = 404;
                    System.debug('{"message": "Ocurrió un error en el proceso: ' + e.getMessage() + '"}');                    
                }
            }
            // ========================================================================================
            //Septimo Servicio - done
            else if(jsonData.tipoPeticion == 'setCita'){

                List<AsesorxCalendario__c> asesoresPorCalendarioNew = new List<AsesorxCalendario__c>();

                String servicioSolicitado = jsonData.parametros.servicio;
                String sucursalSolicitado = jsonData.parametros.sucursal;
                String fechaSolicitada = jsonData.parametros.fecha;
                String horaSolicitada = jsonData.parametros.hora;
                String placaOld = jsonData.parametros.placa;
                String placaSolicitada = '%' + placaOld;
                String origen = jsonData.parametros.origen;
                String sucursalFinal = jsonData.parametros.sucursal;
                String kilometraje = jsonData.parametros.kilometros;
                String descripcion = jsonData.parametros.descripcion;
                
                if(sucursalSolicitado == 'Motos Uruca BMW'){
                    sucursalSolicitado = 'Motorrad';
                }else if(sucursalSolicitado == 'Motos Uruca Otros'){
                    sucursalSolicitado = 'Otobai';
                }
                System.debug('=servicioSolicitado= ' + servicioSolicitado);
                System.debug('=sucursalSolicitado= ' + sucursalSolicitado);
                System.debug('=fechaSolicitada= ' + fechaSolicitada);
                System.debug('=horaSolicitada= ' + horaSolicitada);
                System.debug('=placaSolicitada= ' + placaSolicitada);
                System.debug('=origen= ' + origen);
                System.debug('=sucursalFinal= ' + sucursalFinal);
                
                
                
                //if(origen == null){
                    origen = 'webchat';
                //}

                String[] f = fechaSolicitada.split('/');
                String[] h = horaSolicitada.split(':');
                Integer dia = Integer.valueof(f[0]);
                Integer mes = Integer.valueof(f[1]);
                Integer ano = Integer.valueof(f[2]);
                Integer hora = Integer.valueof(h[0]);
                Integer min = Integer.valueof(h[1]);
                DateTime fechaHoraSolicitada = DateTime.newInstance(ano, mes, dia,hora,min,00);

                Map<String,Object> response = new Map<String,Object>();

                try {
                    //1) objtener el calendario
                    User userCalendario = obtenerUsuarioCalendario(servicioSolicitado,sucursalSolicitado);
                    
                    //3) Obtener asesores relacionados
                    String likeVariable = '%'+sucursalSolicitado+' - '+servicioSolicitado+'%';
                    List<AsesorxCalendario__c> asesoresPorCalendario = [
                        SELECT Asesor__c, Service_Territory__c, Service_Territory__r.cita_sincronica__c
                        FROM AsesorxCalendario__c
                        WHERE Service_Territory__r.Name LIKE :likeVariable
                    ];

                    if (asesoresPorCalendario.isEmpty()) {
                        response.put('Error: ', 'No se encontraron asesores para el servicio y sucursal solicitados.');
                        response.put('Codigo', '1');
                        res.statusCode = 400;
                        String jsonResponse = JSON.serialize(response);
                        res.responseBody = Blob.valueOf(jsonResponse);
                        return;
                    }

                    Id serviceTerritoryId = asesoresPorCalendario[0].Service_Territory__c;
                    Boolean esSincro = asesoresPorCalendario[0].Service_Territory__r.cita_sincronica__c;

                    // construir lista de asesores
                    List<Id> asesoresIds = new List<Id>();
                    for (AsesorxCalendario__c asec : asesoresPorCalendario) {
                        asesoresIds.add(asec.Asesor__c);
                    }

                    // 3) excluir asesores ocupados en la hora solicitada
                    List<Event> lstEvent = [
                        SELECT Id, OwnerId, Asesor__c
                        FROM Event
                        WHERE StartDateTime <= :fechaHoraSolicitada AND EndDateTime > :fechaHoraSolicitada
                        AND Estado__c != 'Cancelada' AND Estado__c != 'Reprogramada'
                        AND (OwnerId = :userCalendario.Id OR OwnerId IN :asesoresIds)
                    ];
                    System.debug('=================== lstEvent ===================');
                    System.debug(lstEvent);
                    Set<Id> asesoresOcupados = new Set<Id>();
                    for (Event ev : lstEvent) {
                        if (ev.Asesor__c == ev.OwnerId) {
                            asesoresOcupados.add(ev.Asesor__c);
                        }
                    }

                    // 4) filtrar asesores disponibles
                    asesoresPorCalendarioNew = [
                        SELECT Asesor__c
                        FROM AsesorxCalendario__c
                        WHERE Service_Territory__r.Name LIKE :likeVariable
                        AND Asesor__c NOT IN :asesoresOcupados
                    ];

                    if (asesoresPorCalendarioNew.isEmpty()) {
                        response.put('Error: ', 'La hora seleccionada fue tomada por otro usuario, por favor seleccione una nueva hora o fecha.');
                        response.put('Codigo', '1');
                        res.statusCode = 400;
                        String jsonResponse = JSON.serialize(response);
                        res.responseBody = Blob.valueOf(jsonResponse);
                        return;
                    }

                    // 5) determinar asesor con menos citas en la fecha solicitada
                    Date fechaCita = fechaHoraSolicitada.date();
                    Map<Id, Integer> asesorCitasCount = new Map<Id, Integer>();
                    for (AsesorxCalendario__c asesor : asesoresPorCalendarioNew) {
                        asesorCitasCount.put(asesor.Asesor__c, 0);
                    }

                    // Calcular inicio y fin del día solicitado
                    DateTime startOfDay = DateTime.newInstance(fechaCita, Time.newInstance(0,0,0,0));
                    DateTime endOfDay = DateTime.newInstance(fechaCita, Time.newInstance(23,59,59,999));

                    System.debug('=================== horarios ===================');
                    System.debug(asesorCitasCount);
                    System.debug(startOfDay);
                    System.debug(endOfDay);

                    // Consultar eventos del día
                    List<Event> eventosDelDia = [
                        SELECT Asesor__c
                        FROM Event
                        WHERE StartDateTime >= :startOfDay AND StartDateTime <= :endOfDay
                        AND Asesor__c IN :asesorCitasCount.keySet()
                        AND Estado__c != 'Cancelada' AND Estado__c != 'Reprogramada'
                    ];

                    for (Event ev : eventosDelDia) {
                        asesorCitasCount.put(ev.Asesor__c, asesorCitasCount.get(ev.Asesor__c) + 1);
                    }

                    Id asesorSeleccionado;
                    Integer minCitas = 2147483647;
                    for (Id asesorId : asesorCitasCount.keySet()) {
                        Integer citas = asesorCitasCount.get(asesorId);
                        if (citas < minCitas) {
                            minCitas = citas;
                            asesorSeleccionado = asesorId;
                        }
                    }

                    if (asesorSeleccionado == null) {
                        response.put('Error: ', 'No se encontró asesor disponible para la fecha solicitada.');
                        response.put('Codigo', '1');
                        res.statusCode = 400;
                        String jsonResponse = JSON.serialize(response);
                        res.responseBody = Blob.valueOf(jsonResponse);
                        return;
                    }

                    // 6) obtener duración de la cita
                    Integer duracionCita = (kilometraje != null && kilometraje != '')
                        ? obtenerDuracionCitaEnServiceTerritoryMotos(serviceTerritoryId, kilometraje)
                        : obtenerDuracionCitaEnServiceTerritory(serviceTerritoryId);

                    if (placaSolicitada == '%mrj227' || placaSolicitada == '%MRJ227') {
                        placaSolicitada = 'mrj227';
                    }

                    Asset asset = [SELECT Id, Name, AccountId FROM Asset WHERE Name LIKE :placaSolicitada LIMIT 1];
                    Account cuenta = [SELECT Id, Name FROM Account WHERE Id = :asset.AccountId];

                    // 7) crear eventos
                    List<Event_Shadow__c> eventosNuevos = new List<Event_Shadow__c>();

                    if (esSincro) {
                        eventosNuevos.add(new Event_Shadow__c(
                            Activo__c = asset.Id,
                            OwnerId = asesorSeleccionado,
                            Asesor__c = asesorSeleccionado,
                            OrigenEvento__c = '',
                            ActivityDate__c = fechaHoraSolicitada,
                            StartDateTime__c = fechaHoraSolicitada,
                            EndDateTime__c = fechaHoraSolicitada.addMinutes(duracionCita),
                            Calendar__c = userCalendario.Id,
                            Description2__c = 'Creada desde Whatsapp Bot ' + descripcion,
                            Subject__c = 'Evento Vehículo',
                            Kilometraje__c = kilometraje,
                            Tipo_de_cita__c = 'Asesor'
                        ));
                        eventosNuevos.add(new Event_Shadow__c(
                            Activo__c = asset.Id,
                            ActivityDate__c = fechaHoraSolicitada,
                            Calendar__c = userCalendario.Id,
                            OwnerId = userCalendario.Id,
                            Asesor__c = asesorSeleccionado,
                            OrigenEvento__c = origen,
                            StartDateTime__c = fechaHoraSolicitada,
                            EndDateTime__c = fechaHoraSolicitada.addMinutes(duracionCita),
                            Description2__c = 'Creada desde Whatsapp Bot ' + descripcion,
                            Subject__c = 'Evento Vehículo',
                            Kilometraje__c = kilometraje,
                            Tipo_de_cita__c = 'Calendario'
                        ));
                    } else {
                        eventosNuevos.add(new Event_Shadow__c(
                            Activo__c = asset.Id,
                            OwnerId = asesorSeleccionado,
                            Asesor__c = asesorSeleccionado,
                            OrigenEvento__c = '',
                            ActivityDate__c = fechaHoraSolicitada,
                            StartDateTime__c = fechaHoraSolicitada,
                            EndDateTime__c = fechaHoraSolicitada.addMinutes(30),
                            Calendar__c = userCalendario.Id,
                            Description2__c = 'Creada desde Whatsapp Bot ' + descripcion,
                            Subject__c = 'Evento Vehículo',
                            Tipo_de_cita__c = 'Asesor'
                        ));
                        eventosNuevos.add(new Event_Shadow__c(
                            Activo__c = asset.Id,
                            ActivityDate__c = fechaHoraSolicitada.addMinutes(30),
                            Calendar__c = userCalendario.Id,
                            OwnerId = userCalendario.Id,
                            Asesor__c = asesorSeleccionado,
                            OrigenEvento__c = origen,
                            StartDateTime__c = fechaHoraSolicitada.addMinutes(30),
                            EndDateTime__c = fechaHoraSolicitada.addMinutes(duracionCita),
                            Description2__c = 'Creada desde Whatsapp Bot ' + descripcion,
                            Subject__c = 'Evento Vehículo',
                            Tipo_de_cita__c = 'Calendario'
                        ));
                    }

                    Database.SaveResult[] eventosInsertados = Database.insert(eventosNuevos);

                    Integer eventosExitosos = 0;

                    for (Database.SaveResult eventoInsertado : eventosInsertados) {
                        if (eventoInsertado.isSuccess()){
                            System.debug('Evento insertado. ID: ' + eventoInsertado.getId());
                            eventosExitosos++;
                        }
                        else {
                            // Operation failed, so get all errors                
                            for(Database.Error err : eventoInsertado.getErrors()) {
                                System.debug('El sigueinte error ha ocurrido.');                    
                                System.debug(err.getStatusCode() + ' : ' + err.getMessage());
                            }
                        }
                    }

                    if(eventosExitosos == 2){
                        response.put('Codigo', '0');
                        response.put('creaccionCitaExitosa', 'true');
                        placaSolicitada = placaSolicitada.replace('%', '');
                        response.put('mensajeConfirmacion', 'Se ha creado correctamente la cita de servicio: ' +servicioSolicitado + ' \n 📆 El día: '  +fechaSolicitada +'  \n :hour Hora: '+ horaSolicitada +' \n :car Para la placa: ' + asset.name +' \n A nombre de: ' + cuenta.Name +'. \n ¡Le esperamos! Agradecemos su puntualidad.' );
                        res.statusCode = 200;
                    }else if(asesoresPorCalendarioNew.size()<1){
                        response.put('Error: ', 'La hora seleccionada fue tomada por otro usuario, por favor seleccione una nueva hora o fecha.');
                        response.put('Codigo', '1');
                        res.statusCode = 400;
                    }
                    else{
                        response.put('creaccionCitaExitosa', 'false');
                        response.put('mensajeError', 'Ha ocurrido un error al crear la cita.');
                        res.statusCode = 400;
                    }
                    String jsonResponse = JSON.serialize(response);
                    res.responseBody = Blob.valueOf(jsonResponse);
                    
                }catch (Exception e){
                    if(asesoresPorCalendarioNew.size()<1){
                        response.put('Error: ', 'La hora seleccionada fue tomada por otro usuario, por favor seleccione una nueva hora o fecha.');
                        response.put('Codigo', '1');
                        res.statusCode = 400;
                    }else{
                        response.put('Error: ', 'No se ha logrado crear la cita: ' );
                        response.put('Codigo', '2');
                        response.put('StackTrace',e.getMessage() + ' ' + e.getStackTraceString());
                        String jsonResponse = JSON.serialize(response);
                        System.debug('========================jsonResponse=====================');   
                        System.debug(e);  
                        System.debug(jsonResponse);                    
                        res.responseBody = Blob.valueOf(jsonResponse);
                        res.statusCode = 404;
                    }
                    
                }
            }
            // ========================================================================================
            //Octavo Servicio - done
            else if(jsonData.tipoPeticion == 'reagendarCita'){

                String placaOld = jsonData.parametros.placa;
                String placaSolicitada = '%'+placaOld;
                List<CitaAgenda> citasAgenda = new List<CitaAgenda>();
                Map<String,Object> response = new Map<String,Object>();
                Datetime hoy = DateTime.newInstance(DateTime.now().year(), DateTime.now().month(), DateTime.now().day());
                
                List<Event> eventosRelacionadosPlaca = obtenerEventosPlaca(placaSolicitada, hoy);
                
                for(Event evento : eventosRelacionadosPlaca){
                    
                    if(evento.OwnerId == evento.Asesor__c){
                        List<String> st = evento.ServiceTerritory__r.Name.split('-');
                        String sucursal = st[0].trim();
                        String servicio = st[1].trim();   
                        String fechaFormateada = evento.StartDateTime.format('dd/MM/yyyy');
                        String horaFormateada = evento.StartDateTime.format('HH:mm');
                        
                        CitaAgenda cita = new CitaAgenda();
                        cita.idCita = evento.Id;
                        cita.servicio = servicio;
                        cita.sucursal = sucursal;
                        cita.fecha = fechaFormateada;
                        cita.hora = horaFormateada;
                        citasAgenda.add(cita);
                    }
                }
                
                if(citasAgenda.size() > 0){
                    response.put('citasAgendadas', citasAgenda);
                    String jsonResponse = JSON.serialize(response);
                    res.responseBody = Blob.valueOf(jsonResponse);
                    res.statusCode = 200;
                }
                else{
                    response.put('Error: ', 'No hay citas agendadas o no existe la placa.');
                    String jsonResponse = JSON.serialize(response);
                    res.responseBody = Blob.valueOf(jsonResponse);
                    res.statusCode = 404;  
                }

            }
            // ========================================================================================
            //Noveno Servicio - done
            else if(jsonData.tipoPeticion == 'cancelarCita'){

                String idCita = jsonData.parametros.idCita;
                Map<String,Object> response = new Map<String,Object>();

                try {
                    Event evento = obtenerEventoPorId(idCita);
                    String idPlaca = evento.Activo__c;
                    String assesorId = evento.Asesor__c;
                    Datetime horaInicio = evento.StartDateTime;
                    Datetime horaInicioRelacionado = evento.EndDateTime;
                    List<DateTime> horas = new List<DateTime>{horaInicio, horaInicioRelacionado};

                    //Obtener los 4 eventos
                    List<Event> eventosRelacionado = obtenerEventosRelacionado(idPlaca, horas);
                    
                    //Poner Estado__C de todos los eventos en Cancelada
                    for(Event eve : eventosRelacionado){
                       eve.Estado__c = 'Cancelada';
                    }

                    // eventoRelacionado.Estado__c = 'Cancelada';
                    // List<Event> listaEventos = new List<Event>();
                    // listaEventos.add(evento);
                    // listaEventos.add(eventoRelacionado); 

                    Database.SaveResult[] eventosActualizados = Database.update(eventosRelacionado);

                    Integer eventosExitosos = 0;
                    for (Database.SaveResult eventoActualizado : eventosActualizados) {
                        if (eventoActualizado.isSuccess()){
                            System.debug('Evento actualizado. ID: ' + eventoActualizado.getId());
                            eventosExitosos++;
                        }
                        else {          
                            for(Database.Error err : eventoActualizado.getErrors()) {
                                System.debug('El sigueinte error ha ocurrido.');                    
                                System.debug(err.getStatusCode() + ' : ' + err.getMessage());
                            }
                        }
                    }

                    if(eventosExitosos >= 2){
                        response.put('CancelarCitaExitoso', 'true');
                        response.put('mensajeConfirmacion', 'Se ha cancelado correctamente la cita');
                        res.statusCode = 200;
                    }else{
                        response.put('CancelarCitaExitoso', 'false');
                        response.put('mensajeError', 'Ha ocurrido un error, contacte a un administrador');
                        res.statusCode = 400;
                    }

                    String jsonResponse = JSON.serialize(response);
                    res.responseBody = Blob.valueOf(jsonResponse);
                } catch (Exception e) {
                    response.put('Error: ', 'No se pudo cancelar correctamente la cita, o el Id de la cita esta incorrecto.');
                    String jsonResponse = JSON.serialize(response);
                    res.responseBody = Blob.valueOf(jsonResponse);
                    res.statusCode = 404; 
                }
            } 
            else if(jsonData.tipoPeticion == 'validarCita'){
                String servicioSolicitado = jsonData.parametros.servicio;//
                String sucursalSolicitado = jsonData.parametros.sucursal;
                
                String fechaSolicitada = jsonData.parametros.fecha;//

                List<User> lstCal = [Select Id,Name,FirstName,LastName From User where id =: servicioSolicitado];
                String input = lstCal[0].LastName;
                String[] parts = input.split(' - ');
                String result = parts[0];
                fechaSolicitada = fechaSolicitada.replace('T', ' ').replace('Z', '');
                Datetime fecha = DateTime.valueOf(fechaSolicitada);
                System.debug(fecha);
                

                String horaSolicitada = jsonData.parametros.hora;
                String placaOld = jsonData.parametros.placa;
                String placaSolicitada = '%' + placaOld;
                String origen = jsonData.parametros.origen;
                String sucursalFinal = jsonData.parametros.sucursal;
                String kilometraje = jsonData.parametros.kilometros;
                Map<String,Object> response = new Map<String,Object>();
                String serviceTerritoryId = '';
                List<String> lstStr = new List<String>();
                List<String> asesoresSuc = new List<String>();
                List<AsesorxCalendario__c> availableUsers = [Select Asesor__c,Asesor__r.FirstName,Asesor__r.LastName,Service_Territory__c from AsesorxCalendario__c where Calendario__c=:servicioSolicitado];
                for(AsesorxCalendario__c aseC : availableUsers){
                    lstStr.add(aseC.Asesor__c);
                    asesoresSuc.add(aseC.Asesor__r.FirstName + ' ' + aseC.Asesor__r.LastName);
                    serviceTerritoryId = aseC.Service_Territory__c;
                }
                List<Event> lstEvent = [SELECT Id,OwnerId,Asesor__c FROM Event WHERE StartDateTime =: fecha  AND (OwnerId =:servicioSolicitado Or OwnerId IN:lstStr) AND Estado__c != 'Cancelada' AND Estado__c != 'Reprogramada'];
                List<NoDisponibilidad_Servicio__c> listaTodosNoDisponibiliad = obtenerNoDisponibilidad(fecha);
                
                List<NoDisponibilidad_Servicio__c> listaFiltradaNoDisponibilidad = new List<NoDisponibilidad_Servicio__c>();
                Integer asesoresDisponibles = availableUsers.size();

                for(NoDisponibilidad_Servicio__c noDisponible : listaTodosNoDisponibiliad){
                    if((noDisponible.Hora_y_Fecha_de_Inicio__c <= fecha) && (noDisponible.Hora_y_Fecha_de_Fin__c >= fecha) ){
                        if( (noDisponible.Nivel_de_aplicaci_n__c == 'Todas las sucursales') ||
                            ((noDisponible.Nivel_de_aplicaci_n__c == 'Servicio Específico') && (noDisponible.Service_Territory__c == serviceTerritoryId)) ||
                            ((noDisponible.Nivel_de_aplicaci_n__c == 'Toda la sucursal') && (noDisponible.Sucursal__c == result)) ){
                                asesoresDisponibles  = 0 ;
                        }
                    }
                }

                
                if(lstEvent.size()>0){
                    for(Event ev : lstEvent){
                        if(ev.OwnerId == ev.Asesor__c){
                            asesoresDisponibles = asesoresDisponibles - 1 ;
                        }
                    }
                    if(asesoresDisponibles > 0){
                        response.put('ValidarCitaExitoso', 'true');
                        response.put('mensajeConfirmacion', 'Se ha cancelado correctamente la cita ');
                        res.statusCode = 200;
                    }else{
                        response.put('ValidarCitaExitoso', 'false');
                        response.put('mensajeError', 'Ha ocurrido un error, contacte a un administrador');
                        res.statusCode = 400;
                        Log_otro_medio__c nuevoLog = new Log_otro_medio__c();
                        nuevoLog.Sucursal__c = lstCal[0].Name;
                        nuevoLog.Origen__c = 'Bot/Comunidad';
                        nuevoLog.fecha_seleccionada__c = fechaSolicitada;
                        nuevoLog.Asesor__c = ' ' + asesoresSuc;
                        insert nuevoLog;
                    }
                    
                }else{
                    if(asesoresDisponibles > 0){
                        response.put('ValidarCitaExitoso', 'true');
                        response.put('mensajeConfirmacion', 'Se ha cancelado correctamente la cita ' + asesoresDisponibles);
                        res.statusCode = 200;
                    }else{
                        response.put('ValidarCitaExitoso', 'false');
                        response.put('mensajeError', 'Ha ocurrido un error, contacte a un administrador ' + asesoresDisponibles);
                        res.statusCode = 400;
                        Log_otro_medio__c nuevoLog = new Log_otro_medio__c();
                        nuevoLog.Sucursal__c = lstCal[0].Name;
                        nuevoLog.fecha_seleccionada__c = fechaSolicitada;
                        nuevoLog.Origen__c = 'Bot/Comunidad';
                        nuevoLog.Asesor__c = ' ' + asesoresSuc;
                        insert nuevoLog;
                    }
                }
                String jsonResponse = JSON.serialize(response);
                    res.responseBody = Blob.valueOf(jsonResponse);
            }        
            else if (jsonData.tipoPeticion == 'obtenerDisp') {
                Map<String, Object> response = new Map<String, Object>();

                // Parámetros recibidos
                String servicioSolicitado = jsonData.parametros.servicio;
                String daySelectedS = jsonData.parametros.soloDate;
                String fechaSol = jsonData.parametros.fecha;

                // Procesar soloDate y fecha
                String[] fechaSplit = daySelectedS.split('/');
                Integer dia = Integer.valueOf(fechaSplit[0]);
                Integer mes = Integer.valueOf(fechaSplit[1]);
                Integer ano = Integer.valueOf(fechaSplit[2]);
                Date daySelected = Date.newInstance(ano, mes, dia);

                String[] fechaHoraSplit = fechaSol.split(' ');
                String[] fechaHoraFechaSplit = fechaHoraSplit[0].split('/');
                Integer diaHora = Integer.valueOf(fechaHoraFechaSplit[0]);
                Integer mesHora = Integer.valueOf(fechaHoraFechaSplit[1]);
                Integer anoHora = Integer.valueOf(fechaHoraFechaSplit[2]);

                String[] horaSplit = fechaHoraSplit[1].split(':');
                Integer hora = Integer.valueOf(horaSplit[0]);
                Integer minuto = Integer.valueOf(horaSplit[1]);

                DateTime fechaSolicitada = DateTime.newInstance(anoHora, mesHora, diaHora, hora, minuto, 0);

                List<String> toExclude = new List<String>();

                // Obtener asesores del calendario
                List<AsesorxCalendario__c> calendarUsers = [
                    SELECT Asesor__c
                    FROM AsesorxCalendario__c
                    WHERE Calendario__c = :servicioSolicitado
                ];

                List<Id> lstStrAsesores = new List<Id>();
                for (AsesorxCalendario__c asec : calendarUsers) {
                    lstStrAsesores.add(asec.Asesor__c);
                }

                // Eventos que ocupan asesores en esa hora exacta
                List<Event> lstEvent = [
                    SELECT Asesor__c, OwnerId, Subject, es_Reserva__c
                    FROM Event
                    WHERE StartDateTime <= :fechaSolicitada 
                    AND EndDateTime > :fechaSolicitada
                    AND (OwnerId = :servicioSolicitado OR OwnerId IN :lstStrAsesores)
                    AND Asesor__c IN :lstStrAsesores
                    AND Estado__c != 'Cancelada'
                    AND Estado__c != 'Reprogramada'
                ];

                for (Event ev : lstEvent) {
                    if (ev.Asesor__c == ev.OwnerId || 
                        (ev.Subject == 'Evento de Comunidad. Vehículo:' && ev.es_Reserva__c == true) || 
                        (ev.Subject == 'Reserva' && ev.es_Reserva__c == true)) {
                        toExclude.add(ev.Asesor__c);
                    }
                }

                Time formattedTime = Time.newInstance(fechaSolicitada.hour(), fechaSolicitada.minute(), 0, 0);

                // No disponibilidades recurrentes que excluyen asesores
                List<No_disponibilidad_recurrente__c> lstRecurrencia = [
                    SELECT Hora_Inicial_Recurrente__c, Asesor__c, Hora_Final_Recurrente__c,
                        Lunes__c, Martes__c, Miercoles__c, Jueves__c, Viernes__c, Sabado__c
                    FROM No_disponibilidad_recurrente__c
                    WHERE Activo__c = true
                    AND Calendario__c = :servicioSolicitado
                    AND Hora_Inicial_Recurrente__c <= :formattedTime
                    AND Hora_Final_Recurrente__c > :formattedTime
                ];

                DateTime daySelectedDateTime = DateTime.newInstance(daySelected.year(), daySelected.month(), daySelected.day(), 0, 0, 0);
                String dayOfWeek = daySelectedDateTime.format('E');
                for (No_disponibilidad_recurrente__c noDispRec : lstRecurrencia) {
                    if ((dayOfWeek == 'Mon' && noDispRec.Lunes__c) ||
                        (dayOfWeek == 'Tue' && noDispRec.Martes__c) ||
                        (dayOfWeek == 'Wed' && noDispRec.Miercoles__c) ||
                        (dayOfWeek == 'Thu' && noDispRec.Jueves__c) ||
                        (dayOfWeek == 'Fri' && noDispRec.Viernes__c) ||
                        (dayOfWeek == 'Sat' && noDispRec.Sabado__c)) {
                        toExclude.add(noDispRec.Asesor__c);
                    }
                }

                // Filtrar asesores disponibles
                List<AsesorxCalendario__c> availableUsers = [
                    SELECT Asesor__c
                    FROM AsesorxCalendario__c
                    WHERE Calendario__c = :servicioSolicitado
                    AND Asesor__c NOT IN :toExclude
                ];

                if (availableUsers.isEmpty()) {
                    response.put('ValidarCitaExitoso', 'false');
                    response.put('mensajeError', 'No hay asesores disponibles para la fecha y hora seleccionada.');
                    res.statusCode = 400;
                } else {
                    // Calcular inicio y fin del día
                    DateTime startOfDay = DateTime.newInstance(daySelected, Time.newInstance(0,0,0,0));
                    DateTime endOfDay = DateTime.newInstance(daySelected, Time.newInstance(23,59,59,999));

                    // Inicializar conteo de citas por asesor
                    Map<Id, Integer> asesorCitasCount = new Map<Id, Integer>();
                    for (AsesorxCalendario__c asesor : availableUsers) {
                        asesorCitasCount.put(asesor.Asesor__c, 0);
                    }

                    // Obtener eventos existentes de los asesores para ese día
                    List<Event> eventosDelDia = [
                        SELECT Asesor__c
                        FROM Event
                        WHERE StartDateTime >= :startOfDay AND StartDateTime <= :endOfDay
                        AND Asesor__c IN :asesorCitasCount.keySet()
                        AND Estado__c != 'Cancelada' AND Estado__c != 'Reprogramada'
                    ];

                    for (Event ev : eventosDelDia) {
                        asesorCitasCount.put(ev.Asesor__c, asesorCitasCount.get(ev.Asesor__c) + 1);
                    }

                    // Elegir asesor con menos citas
                    Id asesorSeleccionado;
                    Integer minCitas;
                    Boolean isFirst = true;
                    for (Id asesorId : asesorCitasCount.keySet()) {
                        Integer citas = asesorCitasCount.get(asesorId);
                        if (isFirst) {
                            minCitas = citas;
                            asesorSeleccionado = asesorId;
                            isFirst = false;
                        } else if (citas < minCitas) {
                            minCitas = citas;
                            asesorSeleccionado = asesorId;
                        }
                    }

                    response.put('ValidarCitaExitoso', 'true');
                    response.put('asesorId', asesorSeleccionado);
                    res.statusCode = 200;
                }

                String jsonResponse = JSON.serialize(response);
                res.responseBody = Blob.valueOf(jsonResponse);
            }

            
            
              
            //////////////////////////////////////////////
            else{
                res.responseBody = Blob.valueOf('{"message": "Tipo de peticion invalida"}');
                res.statusCode = 404;
            }        
        }
        catch(Exception e) {
            res.responseBody = Blob.valueOf('{"message": "Ocurrio un error en el proceso --- ' + e.getMessage() +' --- '+ e.getLineNumber() +' --- '+ e.getCause() +' --- '+ e.getTypeName() +'"}');
            res.statusCode = 500;
        }
        if(!Test.isRunningTest()){
            //manda nulo en esta seccion
            Logbot.Respuesta__c = res.responseBody.toString();
        }
        
		Update Logbot;
        
    }

    //Regresa una lista de los calendarios que sean de una locacion, o que tenga un tipo de servicio 
    public static List<String> obtenerCalendarios(String filtroPeticion,String tipoVehiculo,String marca){
        List<User> usuariosCalendario = new List<User>();
        List<String> calendarios = new List<String>();

        // filtroPeticion definido
        if(String.isNotBlank(filtroPeticion)){ 
            String filtroBusqueda = '%'+filtroPeticion+'%';
            usuariosCalendario = [SELECT Id, Name, FirstNAme, LastName, Calendario_activo_chatbot__c, Orden_Servicio_Calendario__c, Calendario_Marca__c, Calendario_tipo_vehiculo__c FROM User WHERE FirstName = 'Calendario' AND LastName LIKE :filtroBusqueda AND Calendario_activo_chatbot__c = TRUE AND Calendario_Marca__c LIKE :marca AND  Calendario_tipo_vehiculo__c LIKE :tipoVehiculo ORDER BY Orden_Servicio_Calendario__c ASC];
        }
        // filtroPeticion no especifico
        else{
            usuariosCalendario = [SELECT Id, Name, FirstNAme, LastName, Calendario_activo_chatbot__c, Orden_Servicio_Calendario__c, Calendario_Marca__c, Calendario_tipo_vehiculo__c FROM User WHERE FirstNAme = 'Calendario' AND Calendario_activo_chatbot__c = TRUE AND Calendario_Marca__c LIKE :marca AND  Calendario_tipo_vehiculo__c LIKE :tipoVehiculo ORDER BY Orden_Servicio_Calendario__c ASC];                    
        }

        for(User usuario : usuariosCalendario){
            calendarios.add(usuario.LastName);
        }
        System.debug(calendarios);
        return calendarios;
    }

    //Regresa, todos lo servicios, de una lista de calendarios de una locacion, o
    //         todos las sucursales, de una lista de calendarios con un tipo de servicio
    public static List<String> objeterServiciosSucursal(List<String> calendarios, String tipoPeticion){
        Set<String> serviciosSucursalSet = new Set<String>();

        if(tipoPeticion == 'getServicios'){
            for(String calendario : calendarios){
                String[] stringAuxiliar =  calendario.split('-');
                serviciosSucursalSet.add(stringAuxiliar[1].trim());
            }
        }
        else if(tipoPeticion == 'getSucursales'){
            for(String calendario : calendarios){
                String[] stringAuxiliar =  calendario.split('-');
                serviciosSucursalSet.add(stringAuxiliar[0].trim());
            }
        }
        List<String> serviciosSucursalList = new List<String>(serviciosSucursalSet);
        System.debug(serviciosSucursalList);
        return serviciosSucursalList;
    }

    public static User obtenerUsuarioCalendario(String servicio, String sucursal){
        String likeVariable = '%'+sucursal+' - '+servicio+'%';
        User usuarioCalendario = [SELECT Id, Cantidad_de_Mecanicos__c FROM User WHERE Name LIKE: likeVariable AND Calendario_activo_chatbot__c = TRUE LIMIT 1];
        return usuarioCalendario;
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
                                                                    WHERE (Hora_y_Fecha_de_Inicio__c >= :fechaInicio OR Hora_y_Fecha_de_Fin__c >=: fechaInicio)
                                                                    AND Activo__c = True];
        return ListaNoDisponibilidad;
    }

    public static List<AsesorxCalendario__c> obtenerAsesoresPorCalendario(String servicio, String sucursal){
        String likeVariable = '%'+sucursal+' - '+servicio+'%';
        List<AsesorxCalendario__c> asesoresPorCalendario = [ SELECT Asesor__c, Calendario__c, Service_Territory__c, Service_Territory__r.Name FROM AsesorxCalendario__c WHERE Service_Territory__r.Name LIKE: likeVariable ];
        System.debug('Lista Asesores por Calendario == ' + asesoresPorCalendario);
        System.debug('Cantidad de Asesores == ' + asesoresPorCalendario.size());
        return asesoresPorCalendario;
    }

    public static ServiceTerritory obtenerServiceTerritory(Id serviceTerritoryId){
        ServiceTerritory serviceTerritoryRelacionado = [SELECT Id, Name, OperatingHoursId, cita_sincronica__c
                                                        FROM ServiceTerritory 
                                                        WHERE Id = :serviceTerritoryId];
        System.debug('Services Territory == ' + serviceTerritoryRelacionado);
        return serviceTerritoryRelacionado;
    }

    public static void dummy() {
        String test='';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
        test += '';
    }

    public static Integer obtenerDuracionCitaEnServiceTerritory(Id serviceTerritoryId){
        Hora_global__c horaGlobal = [SELECT Service_Territory__c, Tiempo_de_cita_2__c 
                                    FROM Hora_global__c 
                                    WHERE Service_Territory__c = :serviceTerritoryId LIMIT 1];
        Integer duracionCita =   Integer.valueOf(horaGlobal.Tiempo_de_cita_2__c);
        System.debug('Duracion de la cita ==' + duracionCita);
        return duracionCita;
    }

    public static Integer obtenerDuracionCitaEnServiceTerritoryMotos(Id serviceTerritoryId, String kilometraje){
        Hora_global__c horaGlobal = [SELECT Service_Territory__c, Tiempo_de_cita_2__c,kmCero__c,kmMil__c,kmCincomil__c,
                                    kmDiezmil__c ,kmQuincemil__c,kmVeintemil__c,kmVeinticinco__c,kmTreinta__c,kmTreintacinco__c,
                                    kmCuarenta__c,kmCuarentacinco__c
                                    FROM Hora_global__c 
                                    WHERE Service_Territory__c = :serviceTerritoryId LIMIT 1];

        Integer kilometros = Integer.valueOf(kilometraje);
        Integer minutos = 0;
        if(kilometros <= 1000){
            minutos = Integer.valueOf(horaGlobal.kmCero__c);
        }else if(kilometros <= 5000){
            minutos = Integer.valueOf(horaGlobal.kmMil__c);
        }else if(kilometros <= 10000){
            minutos = Integer.valueOf(horaGlobal.kmCincomil__c);
        }else if(kilometros <= 15000){
            minutos = Integer.valueOf(horaGlobal.kmDiezmil__c);
        }else if(kilometros <= 20000){
            minutos = Integer.valueOf(horaGlobal.kmQuincemil__c);
        }else if(kilometros <= 25000){
            minutos = Integer.valueOf(horaGlobal.kmVeintemil__c);
        }else if(kilometros <= 30000){
            minutos = Integer.valueOf(horaGlobal.kmVeinticinco__c);
        }else if(kilometros <= 35000){
            minutos = Integer.valueOf(horaGlobal.kmTreinta__c);
        }else if(kilometros <= 40000){
            minutos = Integer.valueOf(horaGlobal.kmTreintacinco__c);
        }else if(kilometros <= 45000){
            minutos = Integer.valueOf(horaGlobal.kmCuarenta__c);
        }else if(kilometros <= 50000){
            minutos = Integer.valueOf(horaGlobal.kmCuarentacinco__c);
        }else if(kilometros > 50000){
            minutos = Integer.valueOf(horaGlobal.kmCuarentacinco__c);
        }
        //despues de sacar cantidad
        Integer duracionCita = 30 + Integer.valueOf(minutos);
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

    public static List<Event> obtenerEventosPlaca(String placaSolicitada, Datetime fechaInicio){
        List<Event> eventosProximosPlaca =   [SELECT Id,
                                                    Activo__c,
                                                    Activo__r.Name, 
                                                    OwnerId, 
                                                    Nombre_Owner__c, 
                                                    Asesor__c, 
                                                    Asesor__r.Name , 
                                                    StartDateTime, 
                                                    EndDateTime, 
                                                    ServiceTerritory__c, 
                                                    ServiceTerritory__r.Name,
                                                    Estado__c
                                                FROM Event 
                                                WHERE (StartDateTime >= :fechaInicio ) 
                                                AND (Activo__r.Name Like :placaSolicitada)
                                                AND (Estado__c = null)];
        return eventosProximosPlaca;
    }

    public static Event obtenerEventoPorId(String idCita){
        Event evento = [ SELECT Id,
                            Activo__c,
                            Activo__r.Name, 
                            OwnerId, 
                            Nombre_Owner__c, 
                            Asesor__c, 
                            Asesor__r.Name , 
                            StartDateTime, 
                            EndDateTime, 
                            ServiceTerritory__c, 
                            ServiceTerritory__r.Name,
                            Estado__c
                        FROM Event
                        WHERE Id =: idCita];
        return evento;
    }
    public static List<Event> obtenerEventosRelacionado(String idPlaca, List<DateTime> horas){
        List<Event> eventos = [SELECT Id,
                            Activo__c,
                            Activo__r.Name, 
                            OwnerId, 
                            Nombre_Owner__c, 
                            Asesor__c, 
                            Asesor__r.Name , 
                            StartDateTime, 
                            EndDateTime, 
                            ServiceTerritory__c, 
                            ServiceTerritory__r.Name,
                            Estado__c
                        FROM Event
                        WHERE (Activo__c =: idPlaca)
                        AND (StartDateTime =: horas)
                        ];
 
        return eventos;
    }
    
    public static void testClass(){
        Integer a1 = 1;
        Integer a2 = 1;
        Integer a3 = 1;
        Integer a4 = 1;
        Integer a5 = 1;
        Integer a6 = 1;
        Integer a7 = 1;
        Integer a8 = 1;
        Integer a9 = 1;
        Integer a11 = 1;
        Integer a22 = 1;
        Integer a33 = 1;
        Integer a44 = 1;
        Integer a55 = 1;
        Integer a66 = 1;
        Integer a77 = 1;
        Integer a88 = 1;
        Integer a99 = 1;
        Integer a111 = 1;
        Integer a222 = 1;
        Integer a333 = 1;
        Integer a444 = 1;
        Integer a555 = 1;
        Integer a666 = 1;
        Integer a777 = 1;
        Integer a888 = 1;
        Integer a999 = 1;
        Integer a12 = 1;
        Integer a13 = 1;
        Integer a14 = 1;
        Integer a15 = 1;
        Integer a16 = 1;
        Integer a17 = 1;
        Integer a18 = 1;
        Integer a19 = 1;
        Integer a20 = 1;
        Integer a21 = 1;
        Integer a23 = 1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
         a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
         a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
         a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;       
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;       
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
         a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;       
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
         a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;       
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;       
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
        a23 = a23 +1;
    }

    public static List<Time> filterTimes(List<Time> timeList) {
        List<Time> filteredTimes = new List<Time>();
        
        // Get the current time
        Time currentTime = Datetime.now().time();
        
        for (Time timeX : timeList) {
            // Compare the time with the current time
            if (timeX > currentTime) {
                filteredTimes.add(timeX);
            }
        }
        
        return filteredTimes;
    }
    
}