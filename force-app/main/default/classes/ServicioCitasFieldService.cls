@RestResource(urlMapping='/CitasField2/')
global with sharing class ServicioCitasFieldService{
    
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
    
    private static Integer obtenerCantidadMecanicosFSL(Id serviceTerritoryId, Date fecha, Id workTypeId) {
        //datetime starttime = Datetime.newInstance(fecha, Time.newInstance(0,0,0,0));
        //datetime endtime   = Datetime.newInstance(fecha, Time.newInstance(23,59,59,0));
        //p.earliestStart = starttime.addHours(-6);
        //p.dueDate       = endtime.addHours(-6);
        
        
        FSL_SimpleSlotsService.SlotsParams p = new FSL_SimpleSlotsService.SlotsParams();
        p.serviceTerritoryId = serviceTerritoryId;
        p.workTypeId = workTypeId;
        p.earliestStart = Datetime.newInstanceGmt(fecha.year(), fecha.month(), fecha.day(), 8, 0, 0);
        p.dueDate       = Datetime.newInstanceGmt(fecha.year(), fecha.month(), fecha.day(), 17, 0, 0);
        p.windowInLocalTime = true;
        p.returnLocalTime = true;
        p.operatingHoursTimeZone = 'America/Costa_Rica';
        p.excludeAbsences = true;
        p.enforceOperatingHours = false;
        p.capacityPercentage = 80;
        p.slotStepMinutes = 30;
    
        FSL_SimpleSlotsService.SlotsResult r = FSL_SimpleSlotsService.getAvailableSlots(p);
    
        if (!r.success) return 0;
    
        // Cada "slot" viene con resourceId.
        // Queremos contar mecánicos únicos disponibles ese día.
        Set<Id> ids = new Set<Id>();
        for (FSL_SimpleSlotsService.SlotInfo s : r.slots) {
            ids.add(s.resourceId);
        }
        return ids.size();
    }
    
    
    private static Map<Time, Integer> obtenerMapaMecanicosDisponiblesFSL(
    Id serviceTerritoryId,
    Date fecha,
    Id workTypeId
) {

    System.debug('FSL | obtenerMapaMecanicosDisponiblesFSL | Inicio');
    System.debug('FSL | Territorio=' + serviceTerritoryId +
                 ' | Fecha=' + fecha +
                 ' | WorkType=' + workTypeId);

    // =========================================
    // 1) Llamada ÚNICA a FSL
    // =========================================
    FSL_SimpleSlotsService.SlotsParams p =
        new FSL_SimpleSlotsService.SlotsParams();

    p.serviceTerritoryId = serviceTerritoryId;
    p.workTypeId = workTypeId;

    // Ventana amplia del día (local)
    p.earliestStart = Datetime.newInstanceGmt(
        fecha.year(), fecha.month(), fecha.day(), 7, 0, 0
    );
    p.dueDate = Datetime.newInstanceGmt(
        fecha.year(), fecha.month(), fecha.day(), 17, 0, 0
    );

    p.windowInLocalTime = true;
    p.returnLocalTime = true;
    p.operatingHoursTimeZone = 'America/Costa_Rica';

    p.excludeAbsences = true;
    p.enforceOperatingHours = false;
    p.capacityPercentage = 100;
    p.slotStepMinutes = 30;

    FSL_SimpleSlotsService.SlotsResult r =
        FSL_SimpleSlotsService.getAvailableSlots(p);

    if (!r.success) {
        System.debug('FSL | Error: ' + r.errorMessage);
        return new Map<Time, Integer>();
    }

    System.debug('FSL | Slots recibidos: ' + r.slots.size());

    // =========================================
    // 2) Construir mapa temporal
    //     Time -> Set<ResourceId>
    // =========================================
    Map<Time, Set<Id>> mapaTmp = new Map<Time, Set<Id>>();

    for (FSL_SimpleSlotsService.SlotInfo s : r.slots) {

        Datetime ini = s.startTime;
        Datetime fin = s.endTime;

        Time cursor = ini.time();
        Time finTime = fin.time();

        while (cursor < finTime) {

            if (!mapaTmp.containsKey(cursor)) {
                mapaTmp.put(cursor, new Set<Id>());
            }

            mapaTmp.get(cursor).add(s.resourceId);
            cursor = cursor.addMinutes(30);
        }
    }

    // =========================================
    // 3) Convertir a Map<Time, Integer>
    // =========================================
    Map<Time, Integer> mapaFinal = new Map<Time, Integer>();

    for (Time t : mapaTmp.keySet()) {
        mapaFinal.put(t, mapaTmp.get(t).size());
    }

    // =========================================
    // 4) Debug detallado por bloque
    // =========================================
    List<Time> orden = new List<Time>(mapaFinal.keySet());
    orden.sort();

    for (Time t : orden) {
        System.debug(
            'FSL | Bloque ' + t +
            ' | Mecánicos disponibles = ' + mapaFinal.get(t)
        );
    }

    System.debug('FSL | obtenerMapaMecanicosDisponiblesFSL | Fin');

    return mapaFinal;
}




    
    
    @HttpPost
    global static void procesarCita(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String logRequestBody = req.requestBody.toString();
        
        Log_bot_citas__c Logbot = LogBotCitasHelper.buildLog(logRequestBody);
        insert Logbot;
        
        
        try{
            InputJson jsonData = (InputJson) JSON.deserialize(logRequestBody, InputJson.class);
            System.debug(jsonData);
            
            // ========================================================================================
            //Primer Servicio -done
            if(jsonData.tipoPeticion == 'getServicios'){
                
                String sucursalSolicitada = null;
                String tipoVehiculo = jsonData.parametros.tipoVehiculo;
                String marca = jsonData.parametros.marca;
                
                List<String> calendarios = obtenerCalendarios(sucursalSolicitada,tipoVehiculo,marca);
                System.debug('Calendarios ' + calendarios);
                
                List<String> serviciosListaAuxiliar = objeterServiciosSucursal(calendarios,jsonData.tipoPeticion);
                System.debug('serviciosListaAuxiliar ' + serviciosListaAuxiliar );
                
                //Creacion el JSON respuesta
                Map<String, Object> response = new Map<String, Object>();
                Map<String, Object> serviciosMap = new Map<String, Object>();              
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
                    
                    Integer i = 0;
                        Integer j = serviciosList.size() - 1;
                        while(i < j) {
                            Map<String, String> temp = serviciosList[i];
                            serviciosList[i] = serviciosList[j];
                            serviciosList[j] = temp;
                            i++;
                            j--;
                        }
                    
                    /*if (!Test.isRunningTest()) {
                        
                    }*/
                    
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
            // Tercer Servicio - getOpcionesCita (7 Días) - MODIFICADO
            // ========================================================================================
            else if (jsonData.tipoPeticion == 'getOpcionesCita') {

                System.debug('=== INICIO getOpcionesCita (7 días) ===');
            
                String servicioSolicitado   = jsonData.parametros.servicio;
                String sucursalSolicitado   = jsonData.parametros.sucursal;
                String fechaSol             = jsonData.parametros.fecha;
            
                if (sucursalSolicitado == 'Motos Uruca BMW') sucursalSolicitado = 'Motorrad';
                else if (sucursalSolicitado == 'Motos Uruca Otros') sucursalSolicitado = 'Otobai';
            
                // Fecha inicio
                String[] f = fechaSol.split('/');
                DateTime fechaSolicitada = DateTime.newInstance(Integer.valueOf(f[2]), Integer.valueOf(f[1]), Integer.valueOf(f[0]), 0, 0, 0);
                DateTime fechaFinal = fechaSolicitada.addDays(7);
            
                // 1. Obtener datos base
                User userCalendario = obtenerUsuarioCalendario(servicioSolicitado, sucursalSolicitado);
                List<AsesorxCalendario__c> asesores = obtenerAsesoresPorCalendario(servicioSolicitado, sucursalSolicitado);
                
                List<Id> idsAsesores = new List<Id>();
                for (AsesorxCalendario__c a : asesores) idsAsesores.add(a.Asesor__c);
                Integer cantidadAsesores = asesores.size();
            
                ServiceTerritory st = obtenerServiceTerritory(asesores[0].Service_Territory__c);
                Id serviceTerritoryId = st.Id;
                Id workTypeId = st.Work_Type__c;
                Boolean isCitaSincronica = st.cita_sincronica__c;
            
                // CAMBIO 5: bloquesQuitar según sincrónica/asincrónica
                Integer duracionCita = obtenerDuracionCitaEnServiceTerritory(serviceTerritoryId);
                Integer bloquesQuitar;
                if (isCitaSincronica) {
                    bloquesQuitar = duracionCita / 30;
                } else {
                    bloquesQuitar = (duracionCita + 30) / 30;
                }
            
                OperatingHours operatingHours = obtenerOperatingHour(st.OperatingHoursId);

                // CAMBIO 1: Consultar no disponibilidades recurrentes de asesores
                List<No_disponibilidad_recurrente__c> noDispRecurrentes = [
                    SELECT Hora_Inicial_Recurrente__c, Asesor__c, Hora_Final_Recurrente__c, 
                           Calendario__c, Lunes__c, Martes__c, Miercoles__c, Jueves__c, Viernes__c, Sabado__c 
                    FROM No_disponibilidad_recurrente__c 
                    WHERE Calendario__c = :userCalendario.Id 
                    AND Activo__c = true
                ];
            
                // 2. Consulta de Eventos (Citas) masiva
                // CAMBIO 2: Agregar Subject y es_Reserva__c al query
                List<Event> eventosSemana = [
                    SELECT Id, StartDateTime, EndDateTime, OwnerId, Asesor__c, Estado__c, Subject, es_Reserva__c
                    FROM Event
                    WHERE (Asesor__c IN :idsAsesores OR OwnerId IN :idsAsesores)
                    AND Estado__c != 'Cancelada'
                    AND Estado__c != 'Reprogramada'
                    AND StartDateTime <= :fechaFinal
                    AND EndDateTime >= :fechaSolicitada
                ];

                // CAMBIO 1b: Inyectar eventos sintéticos de no disponibilidad recurrente
                for (Integer i = 0; i < 7; i++) {
                    Date fechaActualLoop = fechaSolicitada.addDays(i).date();
                    Datetime dtActualLoop = fechaSolicitada.addDays(i);
                    String diaSemanaLoop = dtActualLoop.format('E');
                    
                    for (No_disponibilidad_recurrente__c noDispRec : noDispRecurrentes) {
                        Boolean agregarEvento = false;
                        if (diaSemanaLoop == 'Mon' && noDispRec.Lunes__c) agregarEvento = true;
                        else if (diaSemanaLoop == 'Tue' && noDispRec.Martes__c) agregarEvento = true;
                        else if (diaSemanaLoop == 'Wed' && noDispRec.Miercoles__c) agregarEvento = true;
                        else if (diaSemanaLoop == 'Thu' && noDispRec.Jueves__c) agregarEvento = true;
                        else if (diaSemanaLoop == 'Fri' && noDispRec.Viernes__c) agregarEvento = true;
                        else if (diaSemanaLoop == 'Sat' && noDispRec.Sabado__c) agregarEvento = true;

                        if (agregarEvento) {
                            Event newEvent = new Event();
                            newEvent.OwnerId = noDispRec.Asesor__c;
                            newEvent.Asesor__c = noDispRec.Asesor__c;
                            newEvent.StartDateTime = Datetime.newInstance(fechaActualLoop, noDispRec.Hora_Inicial_Recurrente__c);
                            newEvent.EndDateTime = Datetime.newInstance(fechaActualLoop, noDispRec.Hora_Final_Recurrente__c);
                            eventosSemana.add(newEvent);
                        }
                    }
                }
                
                List<String> diasDisponibles = new List<String>();
            
                // 3. LOOP DE 7 DÍAS
                for (Integer i = 0; i < 7; i++) {
            
                    Date fechaActual = fechaSolicitada.addDays(i).date();
                    Datetime dtActual = fechaSolicitada.addDays(i);
                    String diaSemana = dtActual.format('EEEE');
                    
                    System.debug('---- Evaluando día: ' + fechaActual + ' (' + diaSemana + ') ----');
            
                    if (diaSemana == 'Sunday') continue;
            
                    String diaTrad = diaSemana == 'Monday' ? 'lunes' :
                                     diaSemana == 'Tuesday' ? 'martes' :
                                     diaSemana == 'Wednesday' ? 'miercoles' :
                                     diaSemana == 'Thursday' ? 'jueves' :
                                     diaSemana == 'Friday' ? 'viernes' : 'sabado';
            
                    Time horaInicio = (Time) operatingHours.get('Hora_inicio_' + diaTrad + '__c');
                    Time horaFin    = (Time) operatingHours.get('Hora_fin_' + diaTrad + '__c');
            
                    if (horaInicio == null || horaFin == null) continue;
            
                    // A. Obtener Mecánicos disponibles (FSL) - mapa por bloque
                    Map<Time, Integer> mapaMecanicos = obtenerMapaMecanicosDisponiblesFSL(serviceTerritoryId, fechaActual, workTypeId);

                    // B. Construir Bloques Base
                    Map<Time,BloqueTrabajo> mapa = new Map<Time,BloqueTrabajo>();
                    Time hAux = horaInicio;
                    while (hAux < horaFin) {
                        Integer mec = mapaMecanicos.containsKey(hAux) ? mapaMecanicos.get(hAux) : 0;
                        mapa.put(hAux, new BloqueTrabajo(hAux, cantidadAsesores, mec));
                        hAux = hAux.addMinutes(30);
                    }
            
                    // C. Restar Citas de Asesores
                    // CAMBIO 3: Considerar eventos de comunidad/reserva
                    for (Event ev : eventosSemana) {
                        if (ev.StartDateTime.date() == fechaActual) {
                            Time evIni = ev.StartDateTime.time();
                            Time evFin = ev.EndDateTime.time();

                            for (Time bloqueTime : mapa.keySet()) {
                                if (bloqueTime >= evIni && bloqueTime < evFin) {
                                    BloqueTrabajo bt = mapa.get(bloqueTime);
                                    
                                    // Evento de asesor O evento de comunidad/reserva
                                    Boolean esEventoAsesor = (ev.OwnerId == ev.Asesor__c);
                                    Boolean esEventoComunidad = (ev.Subject == 'Evento de Comunidad. Vehículo:' && ev.es_Reserva__c == true);
                                    Boolean esReserva = (ev.Subject == 'Reserva' && ev.es_Reserva__c == true);
                                    
                                    if (esEventoAsesor || esEventoComunidad || esReserva) {
                                        if (bt.asesoresDisponibles > 0) bt.asesoresDisponibles--;
                                        if (isCitaSincronica && bt.mecanicosDisponibles > 0) bt.mecanicosDisponibles--;
                                    }
                                    mapa.put(bloqueTime, bt);
                                }
                            }
                        }
                    }

                    // C.1 DEBUG DEL MAPA DE BLOQUES
                    List<Time> ordenHoras = new List<Time>(mapa.keySet());
                    ordenHoras.sort();
                    for(Time t : ordenHoras) {
                        BloqueTrabajo bt = mapa.get(t);
                        System.debug('Bloque ' + t + ' | Asesores=' + bt.asesoresDisponibles + ' | Mecánicos=' + bt.mecanicosDisponibles);
                    }
            
                    // D. Validar si hay hueco
                    // CAMBIO 4: Restricción de hora en punto para sincrónica
                    Boolean hayEspacio = false;
                    for (Integer j = 0; j <= ordenHoras.size() - bloquesQuitar; j++) {
                        Time horaBloque = ordenHoras[j];
                        
                        // Si es sincrónica, solo evaluar bloques que inicien en hora en punto
                        if (isCitaSincronica && horaBloque.minute() != 0) continue;
                        
                        Boolean ok = true;
                        for (Integer k = j; k < j + bloquesQuitar; k++) {
                            BloqueTrabajo bt = mapa.get(ordenHoras[k]);
                            if (isCitaSincronica) {
                                if (bt.asesoresDisponibles <= 0 || bt.mecanicosDisponibles <= 0) { ok = false; break; }
                            } else {
                                if (k == j && bt.asesoresDisponibles <= 0) { ok = false; break; }
                                if (k > j && bt.mecanicosDisponibles <= 0) { ok = false; break; }
                            }
                        }
                        if (ok) {
                            hayEspacio = true;
                            System.debug('>>> Espacio encontrado iniciando a las: ' + ordenHoras[j]);
                            break;
                        }
                    }
            
                    if (hayEspacio) {
                        diasDisponibles.add(String.valueOf(fechaActual));
                    } else {
                        System.debug('>>> Día SIN disponibilidad: ' + fechaActual);
                    }
                }
            
                // 5. Respuesta
                Map<String,Object> responseData = new Map<String,Object>();
                if (!diasDisponibles.isEmpty()) {
                    diasDisponibles.add('Otras fechas');
                    if(servicioSolicitado == 'Mecánica Rápida' && sucursalSolicitado != 'Motorrad' && sucursalSolicitado != 'Otobai'){
                         diasDisponibles.add('Otra sucursal');
                    }
                    responseData.put('OpcionesCita', 'true');
                    responseData.put('mensaje', 'Existen opciones de cita disponibles');
                    responseData.put('opciones', diasDisponibles);
                } else {
                    responseData.put('OpcionesCita', 'false');
                    responseData.put('mensaje', 'No existen opciones de cita disponibles');
                }
                res.responseBody = Blob.valueOf(JSON.serialize(responseData));
                res.statusCode = 200;
            }
            
            
            
            // ========================================================================================
            // Cuarto Servicio - getHorasCita (1 Día Específico) - MODIFICADO
            // ========================================================================================
            else if (jsonData.tipoPeticion == 'getHorasCita') {

                System.debug('getHorasCita | INICIO (1 Día)');
                Map<String, Object> response = new Map<String, Object>();

                String servicioSolicitado  = jsonData.parametros.servicio;
                String sucursalSolicitado  = jsonData.parametros.sucursal;
                String fechaSol            = jsonData.parametros.fecha;

                if (sucursalSolicitado == 'Motos Uruca BMW') sucursalSolicitado = 'Motorrad';
                else if (sucursalSolicitado == 'Motos Uruca Otros') sucursalSolicitado = 'Otobai';

                // 1. Configuración de Fecha
                String[] f = fechaSol.split('/');
                Integer dia = Integer.valueOf(f[0]);
                Integer mes = Integer.valueOf(f[1]);
                Integer ano = Integer.valueOf(f[2]);
                Datetime fechaSolicitada = Datetime.newInstance(ano, mes, dia, 0, 0, 0);

                // 2. Obtener datos base
                User userCalendario = obtenerUsuarioCalendario(servicioSolicitado, sucursalSolicitado);
                List<AsesorxCalendario__c> asesores = obtenerAsesoresPorCalendario(servicioSolicitado, sucursalSolicitado);
                
                Integer cantidadAsesores = asesores.size();
                Id serviceTerritoryIdOriginal = asesores[0].Service_Territory__c;

                List<Id> asesoresIds = new List<Id>();
                for (AsesorxCalendario__c a : asesores) {
                    asesoresIds.add(a.Asesor__c);
                }

                // 3. Configuración del Territorio
                ServiceTerritory st = [SELECT Id, Territorio_Field__c, Work_Type__c, cita_sincronica__c, OperatingHoursId FROM ServiceTerritory WHERE Id = :serviceTerritoryIdOriginal LIMIT 1];
                Boolean isCitaSincronica = st.cita_sincronica__c;
                
                // CAMBIO 5: duracionCita y bloquesNecesarios según sincrónica/asincrónica
                Integer duracionCita = obtenerDuracionCitaEnServiceTerritory(serviceTerritoryIdOriginal);
                Integer bloquesNecesarios;
                if (isCitaSincronica) {
                    bloquesNecesarios = duracionCita / 30;
                } else {
                    duracionCita = duracionCita + 30; // Buffer +30 solo para asincrónica
                    bloquesNecesarios = duracionCita / 30;
                }

                // 4. Horarios Operativos
                OperatingHours oh = obtenerOperatingHour(st.OperatingHoursId);
                String diaSemana = fechaSolicitada.format('EEEE');
                
                if (diaSemana == 'Sunday') {
                    response.put('Error', 'Domingo sin disponibilidad');
                    res.responseBody = Blob.valueOf(JSON.serialize(response));
                    res.statusCode = 404;
                    return;
                }

                String diaTrad = diaSemana == 'Monday' ? 'lunes' : 
                                 diaSemana == 'Tuesday' ? 'martes' : 
                                 diaSemana == 'Wednesday' ? 'miercoles' : 
                                 diaSemana == 'Thursday' ? 'jueves' : 
                                 diaSemana == 'Friday' ? 'viernes' : 'sabado';
                                            
                Time horaInicio = (Time) oh.get('Hora_inicio_' + diaTrad + '__c');
                Time horaFin    = (Time) oh.get('Hora_fin_' + diaTrad + '__c');

                System.debug('Horario operativo: ' + horaInicio + ' - ' + horaFin);

                // Obtener día de la semana abreviado para no disponibilidad recurrente
                String diaDeLaSemanaString = fechaSolicitada.format('E');

                // 5. Obtener Mecánicos disponibles (FSL)
                Map<Time, Integer> mapaMecanicos = obtenerMapaMecanicosDisponiblesFSL(st.Id, fechaSolicitada.date(), st.Work_Type__c);

                // 6. Construir Bloques Base
                Map<Time, BloqueTrabajo> mapaBloques = new Map<Time, BloqueTrabajo>();
                Time t = horaInicio;
                while (t < horaFin) {
                    Integer mec = mapaMecanicos.containsKey(t) ? mapaMecanicos.get(t) : 0;
                    mapaBloques.put(t, new BloqueTrabajo(t, cantidadAsesores, mec));
                    t = t.addMinutes(30);
                }

                // 7. RESTAR CITAS DE ASESORES (Eventos Salesforce)
                DateTime startOfDay = DateTime.newInstance(fechaSolicitada.date(), Time.newInstance(0,0,0,0));
                DateTime endOfDay = DateTime.newInstance(fechaSolicitada.date(), Time.newInstance(23,59,59,0));

                // CAMBIO 2: Agregar Subject y es_Reserva__c al query
                List<Event> eventosAsesores = [
                    SELECT Id, StartDateTime, EndDateTime, OwnerId, Asesor__c, Subject, es_Reserva__c
                    FROM Event 
                    WHERE (Asesor__c IN :asesoresIds OR OwnerId IN :asesoresIds) 
                    AND Estado__c != 'Cancelada' 
                    AND Estado__c != 'Reprogramada' 
                    AND StartDateTime <= :endOfDay 
                    AND EndDateTime >= :startOfDay
                ];
                
                System.debug('Eventos encontrados para hoy: ' + eventosAsesores.size());

                // CAMBIO 1: Inyectar eventos sintéticos de no disponibilidad recurrente
                List<No_disponibilidad_recurrente__c> noDispRecurrentes = [
                    SELECT Hora_Inicial_Recurrente__c, Asesor__c, Hora_Final_Recurrente__c, 
                           Calendario__c, Lunes__c, Martes__c, Miercoles__c, Jueves__c, Viernes__c, Sabado__c 
                    FROM No_disponibilidad_recurrente__c 
                    WHERE Calendario__c = :userCalendario.Id 
                    AND Activo__c = true
                ];

                for (No_disponibilidad_recurrente__c noDispRec : noDispRecurrentes) {
                    Boolean agregarEvento = false;
                    if (diaDeLaSemanaString == 'Mon' && noDispRec.Lunes__c) agregarEvento = true;
                    else if (diaDeLaSemanaString == 'Tue' && noDispRec.Martes__c) agregarEvento = true;
                    else if (diaDeLaSemanaString == 'Wed' && noDispRec.Miercoles__c) agregarEvento = true;
                    else if (diaDeLaSemanaString == 'Thu' && noDispRec.Jueves__c) agregarEvento = true;
                    else if (diaDeLaSemanaString == 'Fri' && noDispRec.Viernes__c) agregarEvento = true;
                    else if (diaDeLaSemanaString == 'Sat' && noDispRec.Sabado__c) agregarEvento = true;

                    if (agregarEvento) {
                        Event newEvent = new Event();
                        newEvent.OwnerId = noDispRec.Asesor__c;
                        newEvent.Asesor__c = noDispRec.Asesor__c;
                        newEvent.StartDateTime = Datetime.newInstance(fechaSolicitada.date(), noDispRec.Hora_Inicial_Recurrente__c);
                        newEvent.EndDateTime = Datetime.newInstance(fechaSolicitada.date(), noDispRec.Hora_Final_Recurrente__c);
                        eventosAsesores.add(newEvent);
                    }
                }

                // CAMBIO 3 y 4: Considerar eventos de comunidad/reserva + redondeo de minutos
                for (Event ev : eventosAsesores) {
                    // CAMBIO 4: Redondeo de minutos al bloque de 30 más cercano
                    Datetime diaHoraInicio = ev.StartDateTime;
                    Integer minutes1 = diaHoraInicio.minute();
                    Integer roundedMinutes1 = (Math.round(minutes1/30.0) * 30);
                    Integer difference1 = roundedMinutes1 - minutes1;
                    diaHoraInicio = diaHoraInicio.addMinutes(difference1);

                    Datetime diaHoraFin = ev.EndDateTime;
                    Integer minutes2 = diaHoraFin.minute();
                    Integer roundedMinutes2 = (Math.round(minutes2/30.0) * 30);
                    Integer difference2 = roundedMinutes2 - minutes2;
                    if (difference2 < 0) difference2 = difference2 * -1;
                    diaHoraFin = diaHoraFin.addMinutes(difference2);

                    Time evIni = diaHoraInicio.time();
                    Time evFin = diaHoraFin.time();
                    
                    for (Time bloqueTime : mapaBloques.keySet()) {
                        if (bloqueTime >= evIni && bloqueTime < evFin) {
                            BloqueTrabajo bt = mapaBloques.get(bloqueTime);
                            
                            // CAMBIO 3: Evento de asesor O evento de comunidad/reserva
                            Boolean esEventoAsesor = (ev.OwnerId == ev.Asesor__c);
                            Boolean esEventoComunidad = (ev.Subject == 'Evento de Comunidad. Vehículo:' && ev.es_Reserva__c == true);
                            Boolean esReserva = (ev.Subject == 'Reserva' && ev.es_Reserva__c == true);
                            
                            if (esEventoAsesor || esEventoComunidad || esReserva) {
                                if (bt.asesoresDisponibles > 0) bt.asesoresDisponibles--;
                            }
                            mapaBloques.put(bloqueTime, bt);
                        }
                    }
                }

                // 7.1 DEBUG DEL MAPA DE BLOQUES
                List<Time> ordenHorasDebug = new List<Time>(mapaBloques.keySet());
                ordenHorasDebug.sort();
                for(Time tDebug : ordenHorasDebug) {
                    BloqueTrabajo bt = mapaBloques.get(tDebug);
                    System.debug('Bloque ' + tDebug + ' | Asesores=' + bt.asesoresDisponibles + ' | Mecánicos=' + bt.mecanicosDisponibles);
                }

                // 8. Validación final
                // CAMBIO 4b: Restricción de hora en punto para sincrónica + ajuste horaUltimoBloquePosible
                List<Time> horasDisponibles = new List<Time>();
                Time cursor = horaInicio;
                Time ultimo = horaFin.addMinutes(-duracionCita);
                
                // CAMBIO 6: Ajuste de último bloque para sincrónica
                if (isCitaSincronica) {
                    ultimo = ultimo.addMinutes(30);
                }

                while (cursor <= ultimo) {
                    // CAMBIO 4b: Si es sincrónica, solo evaluar bloques que inicien en hora en punto
                    if (isCitaSincronica && cursor.minute() != 0) {
                        cursor = cursor.addMinutes(30);
                        continue;
                    }
                    
                    Boolean ok = true;
                    Time iter = cursor;
                    
                    for (Integer i = 0; i < bloquesNecesarios; i++) {
                        if (!mapaBloques.containsKey(iter)) { ok = false; break; }
                        
                        BloqueTrabajo b = mapaBloques.get(iter);
                        
                        if (isCitaSincronica) {
                            if (b.asesoresDisponibles <= 0 || b.mecanicosDisponibles <= 0) { ok = false; break; }
                        } else {
                            if (i == 0 && b.asesoresDisponibles <= 0) { ok = false; break; } // Recepción
                            if (i > 0 && b.mecanicosDisponibles <= 0) { ok = false; break; } // Taller
                        }
                        iter = iter.addMinutes(30);
                    }
                    
                    if (ok) horasDisponibles.add(cursor);
                    cursor = cursor.addMinutes(30);
                }
                
                // Filtrar horas pasadas si es hoy
                if (fechaSolicitada.date() == Date.today()) {
                    horasDisponibles = filterTimes(horasDisponibles);
                }

                // 9. Respuesta
                Map<String, Object> horasResponse = new Map<String, Object>();
                Integer idx = 1;
                for (Time h : horasDisponibles) {
                    horasResponse.put(String.valueOf(idx++), h);
                }
                horasResponse.put('10', 'Otras fechas');
                
                response.put('horas', horasResponse);
                res.responseBody = Blob.valueOf(JSON.serialize(response));
                res.statusCode = 200;
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
                            ActivityDate__c = fechaHoraSolicitada,
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
                        List<String> st2 = evento.ServiceTerritory__r.Name.split('-');
                        String sucursal = st2[0].trim();
                        String servicio = st2[1].trim();   
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
        
        
        /*
        if(!Test.isRunningTest()){
            //manda nulo en esta seccion
            
        }*/
        Logbot.Respuesta__c = res.responseBody.toString();
        
        
        
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
                System.debug('Calendario ' + calendario);
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
        ServiceTerritory serviceTerritoryRelacionado = [SELECT Id, Name, OperatingHoursId, cita_sincronica__c, Territorio_Field__c, Work_Type__c
                                                        FROM ServiceTerritory 
                                                        WHERE Id = :serviceTerritoryId];
        System.debug('Services Territory == ' + serviceTerritoryRelacionado);
        return serviceTerritoryRelacionado;
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
        
        public static String procesarPeticionInterna(String jsonBody) {
        // Deserializar el JSON igual que en procesarCita()
        InputJson jsonData = (InputJson) JSON.deserialize(jsonBody, InputJson.class);
        
        // Crear un mapa para la respuesta
        Map<String, Object> responseData = new Map<String, Object>();
        Integer statusCode = 200;
        
        try {
            // =====================================================================
            // getOpcionesCita - MODIFICADO
            // =====================================================================
            if (jsonData.tipoPeticion == 'getOpcionesCita') {
                
                String servicioSolicitado = jsonData.parametros.servicio;
                String sucursalSolicitado = jsonData.parametros.sucursal;
                String fechaSol           = jsonData.parametros.fecha;
                
                if (sucursalSolicitado == 'Motos Uruca BMW') sucursalSolicitado = 'Motorrad';
                else if (sucursalSolicitado == 'Motos Uruca Otros') sucursalSolicitado = 'Otobai';
                
                String[] f = fechaSol.split('/');
                DateTime fechaSolicitada = DateTime.newInstance(
                    Integer.valueOf(f[2]), Integer.valueOf(f[1]), Integer.valueOf(f[0]), 0, 0, 0
                );
                DateTime fechaFinal = fechaSolicitada.addDays(7);
                
                User userCalendario = obtenerUsuarioCalendario(servicioSolicitado, sucursalSolicitado);
                List<AsesorxCalendario__c> asesores = obtenerAsesoresPorCalendario(servicioSolicitado, sucursalSolicitado);
                
                List<Id> idsAsesores = new List<Id>();
                for (AsesorxCalendario__c a : asesores) idsAsesores.add(a.Asesor__c);
                Integer cantidadAsesores = asesores.size();
                
                ServiceTerritory st = obtenerServiceTerritory(asesores[0].Service_Territory__c);
                Id serviceTerritoryId = st.Id;
                Id workTypeId = st.Work_Type__c;
                Boolean isCitaSincronica = st.cita_sincronica__c;
                
                // CAMBIO 5: bloquesQuitar según sincrónica/asincrónica
                Integer duracionCita = obtenerDuracionCitaEnServiceTerritory(serviceTerritoryId);
                Integer bloquesQuitar;
                if (isCitaSincronica) {
                    bloquesQuitar = duracionCita / 30;
                } else {
                    bloquesQuitar = (duracionCita + 30) / 30;
                }
                
                OperatingHours operatingHours = obtenerOperatingHour(st.OperatingHoursId);

                // CAMBIO 1: Consultar no disponibilidades recurrentes de asesores
                List<No_disponibilidad_recurrente__c> noDispRecurrentes = [
                    SELECT Hora_Inicial_Recurrente__c, Asesor__c, Hora_Final_Recurrente__c, 
                           Calendario__c, Lunes__c, Martes__c, Miercoles__c, Jueves__c, Viernes__c, Sabado__c 
                    FROM No_disponibilidad_recurrente__c 
                    WHERE Calendario__c = :userCalendario.Id 
                    AND Activo__c = true
                ];
                
                // CAMBIO 2: Agregar Subject y es_Reserva__c al query
                List<Event> eventosSemana = [
                    SELECT Id, StartDateTime, EndDateTime, OwnerId, Asesor__c, Estado__c, Subject, es_Reserva__c
                    FROM Event
                    WHERE (Asesor__c IN :idsAsesores OR OwnerId IN :idsAsesores)
                    AND Estado__c != 'Cancelada'
                    AND Estado__c != 'Reprogramada'
                    AND StartDateTime <= :fechaFinal
                    AND EndDateTime >= :fechaSolicitada
                ];

                // CAMBIO 1b: Inyectar eventos sintéticos de no disponibilidad recurrente
                for (Integer i = 0; i < 7; i++) {
                    Date fechaActualLoop = fechaSolicitada.addDays(i).date();
                    Datetime dtActualLoop = fechaSolicitada.addDays(i);
                    String diaSemanaLoop = dtActualLoop.format('E');
                    
                    for (No_disponibilidad_recurrente__c noDispRec : noDispRecurrentes) {
                        Boolean agregarEvento = false;
                        if (diaSemanaLoop == 'Mon' && noDispRec.Lunes__c) agregarEvento = true;
                        else if (diaSemanaLoop == 'Tue' && noDispRec.Martes__c) agregarEvento = true;
                        else if (diaSemanaLoop == 'Wed' && noDispRec.Miercoles__c) agregarEvento = true;
                        else if (diaSemanaLoop == 'Thu' && noDispRec.Jueves__c) agregarEvento = true;
                        else if (diaSemanaLoop == 'Fri' && noDispRec.Viernes__c) agregarEvento = true;
                        else if (diaSemanaLoop == 'Sat' && noDispRec.Sabado__c) agregarEvento = true;

                        if (agregarEvento) {
                            Event newEvent = new Event();
                            newEvent.OwnerId = noDispRec.Asesor__c;
                            newEvent.Asesor__c = noDispRec.Asesor__c;
                            newEvent.StartDateTime = Datetime.newInstance(fechaActualLoop, noDispRec.Hora_Inicial_Recurrente__c);
                            newEvent.EndDateTime = Datetime.newInstance(fechaActualLoop, noDispRec.Hora_Final_Recurrente__c);
                            eventosSemana.add(newEvent);
                        }
                    }
                }
                
                List<String> diasDisponibles = new List<String>();
                
                for (Integer i = 0; i < 7; i++) {
                    Date fechaActual = fechaSolicitada.addDays(i).date();
                    Datetime dtActual = fechaSolicitada.addDays(i);
                    String diaSemana = dtActual.format('EEEE');
                    
                    if (diaSemana == 'Sunday') continue;
                    
                    String diaTrad = diaSemana == 'Monday' ? 'lunes' :
                                    diaSemana == 'Tuesday' ? 'martes' :
                                    diaSemana == 'Wednesday' ? 'miercoles' :
                                    diaSemana == 'Thursday' ? 'jueves' :
                                    diaSemana == 'Friday' ? 'viernes' : 'sabado';
                    
                    Time horaInicio = (Time) operatingHours.get('Hora_inicio_' + diaTrad + '__c');
                    Time horaFin    = (Time) operatingHours.get('Hora_fin_' + diaTrad + '__c');
                    
                    if (horaInicio == null || horaFin == null) continue;
                    
                    // A. Obtener Mecánicos disponibles (FSL) - mapa por bloque
                    Map<Time, Integer> mapaMecanicos = obtenerMapaMecanicosDisponiblesFSL(serviceTerritoryId, fechaActual, workTypeId);
                    
                    // B. Construir Bloques Base
                    Map<Time,BloqueTrabajo> mapa = new Map<Time,BloqueTrabajo>();
                    Time hAux = horaInicio;
                    while (hAux < horaFin) {
                        Integer mec = mapaMecanicos.containsKey(hAux) ? mapaMecanicos.get(hAux) : 0;
                        mapa.put(hAux, new BloqueTrabajo(hAux, cantidadAsesores, mec));
                        hAux = hAux.addMinutes(30);
                    }
                    
                    // CAMBIO 3: Considerar eventos de comunidad/reserva
                    for (Event ev : eventosSemana) {
                        if (ev.StartDateTime.date() == fechaActual) {
                            Time evIni = ev.StartDateTime.time();
                            Time evFin = ev.EndDateTime.time();
                            
                            for (Time bloqueTime : mapa.keySet()) {
                                if (bloqueTime >= evIni && bloqueTime < evFin) {
                                    BloqueTrabajo bt = mapa.get(bloqueTime);
                                    
                                    Boolean esEventoAsesor = (ev.OwnerId == ev.Asesor__c);
                                    Boolean esEventoComunidad = (ev.Subject == 'Evento de Comunidad. Vehículo:' && ev.es_Reserva__c == true);
                                    Boolean esReserva = (ev.Subject == 'Reserva' && ev.es_Reserva__c == true);
                                    
                                    if (esEventoAsesor || esEventoComunidad || esReserva) {
                                        if (bt.asesoresDisponibles > 0) bt.asesoresDisponibles--;
                                        if (isCitaSincronica && bt.mecanicosDisponibles > 0) bt.mecanicosDisponibles--;
                                    }
                                    mapa.put(bloqueTime, bt);
                                }
                            }
                        }
                    }
                    
                    List<Time> ordenHoras = new List<Time>(mapa.keySet());
                    ordenHoras.sort();
                    
                    // CAMBIO 4: Restricción de hora en punto para sincrónica
                    Boolean hayEspacio = false;
                    for (Integer j = 0; j <= ordenHoras.size() - bloquesQuitar; j++) {
                        Time horaBloque = ordenHoras[j];
                        
                        if (isCitaSincronica && horaBloque.minute() != 0) continue;
                        
                        Boolean ok = true;
                        for (Integer k = j; k < j + bloquesQuitar; k++) {
                            BloqueTrabajo bt = mapa.get(ordenHoras[k]);
                            System.debug('=================== dentro dias revision ===================');
                            System.debug(bt);
                            System.debug(bt.asesoresDisponibles);
                            System.debug(bt.mecanicosDisponibles);
                            if (isCitaSincronica) {
                                if (bt.asesoresDisponibles <= 0 || bt.mecanicosDisponibles <= 0) { ok = false; break; }
                            } else {
                                if (k == j && bt.asesoresDisponibles <= 0) { ok = false; break; }
                                if (k > j && bt.mecanicosDisponibles <= 0) { ok = false; break; }
                            }
                        }
                        if (ok) { hayEspacio = true; break; }
                    }
                    
                    if (hayEspacio) {
                        diasDisponibles.add(String.valueOf(fechaActual));
                    }
                }
                System.debug('=================== diasDisponibles ===================');
                System.debug(diasDisponibles);
                
                if (!diasDisponibles.isEmpty()) {
                    diasDisponibles.add('Otras fechas');
                    if (servicioSolicitado == 'Mecánica Rápida' && sucursalSolicitado != 'Motorrad' && sucursalSolicitado != 'Otobai') {
                        diasDisponibles.add('Otra sucursal');
                    }
                    responseData.put('OpcionesCita', 'true');
                    responseData.put('mensaje', 'Existen opciones de cita disponibles');
                    responseData.put('opciones', diasDisponibles);
                } else {
                    responseData.put('OpcionesCita', 'false');
                    responseData.put('mensaje', 'No existen opciones de cita disponibles');
                }
            }
            // =====================================================================
            // getHorasCita - MODIFICADO
            // =====================================================================
            else if (jsonData.tipoPeticion == 'getHorasCita') {
                
                String servicioSolicitado = jsonData.parametros.servicio;
                String sucursalSolicitado = jsonData.parametros.sucursal;
                String fechaSol           = jsonData.parametros.fecha;
                
                if (sucursalSolicitado == 'Motos Uruca BMW') sucursalSolicitado = 'Motorrad';
                else if (sucursalSolicitado == 'Motos Uruca Otros') sucursalSolicitado = 'Otobai';
                
                String[] f = fechaSol.split('/');
                Integer dia = Integer.valueOf(f[0]);
                Integer mes = Integer.valueOf(f[1]);
                Integer ano = Integer.valueOf(f[2]);
                Datetime fechaSolicitada = Datetime.newInstance(ano, mes, dia, 0, 0, 0);
                
                User userCalendario = obtenerUsuarioCalendario(servicioSolicitado, sucursalSolicitado);
                List<AsesorxCalendario__c> asesores = obtenerAsesoresPorCalendario(servicioSolicitado, sucursalSolicitado);
                
                Integer cantidadAsesores = asesores.size();
                Id serviceTerritoryIdOriginal = asesores[0].Service_Territory__c;
                
                List<Id> asesoresIds = new List<Id>();
                for (AsesorxCalendario__c a : asesores) {
                    asesoresIds.add(a.Asesor__c);
                }
                
                ServiceTerritory st = [
                    SELECT Id, Territorio_Field__c, Work_Type__c, cita_sincronica__c, OperatingHoursId 
                    FROM ServiceTerritory 
                    WHERE Id = :serviceTerritoryIdOriginal LIMIT 1
                ];
                Boolean isCitaSincronica = st.cita_sincronica__c;
                
                // CAMBIO 5: duracionCita y bloquesNecesarios según sincrónica/asincrónica
                Integer duracionCita = obtenerDuracionCitaEnServiceTerritory(serviceTerritoryIdOriginal);
                Integer bloquesNecesarios;
                if (isCitaSincronica) {
                    bloquesNecesarios = duracionCita / 30;
                } else {
                    duracionCita = duracionCita + 30;
                    bloquesNecesarios = duracionCita / 30;
                }
                
                OperatingHours oh = obtenerOperatingHour(st.OperatingHoursId);
                String diaSemana = fechaSolicitada.format('EEEE');
                
                if (diaSemana == 'Sunday') {
                    responseData.put('Error', 'Domingo sin disponibilidad');
                    statusCode = 404;
                    return JSON.serialize(new Map<String, Object>{
                        'statusCode' => statusCode,
                        'body' => responseData
                    });
                }
                
                String diaTrad = diaSemana == 'Monday' ? 'lunes' :
                                diaSemana == 'Tuesday' ? 'martes' :
                                diaSemana == 'Wednesday' ? 'miercoles' :
                                diaSemana == 'Thursday' ? 'jueves' :
                                diaSemana == 'Friday' ? 'viernes' : 'sabado';
                
                Time horaInicio = (Time) oh.get('Hora_inicio_' + diaTrad + '__c');
                Time horaFin    = (Time) oh.get('Hora_fin_' + diaTrad + '__c');
                
                String diaDeLaSemanaString = fechaSolicitada.format('E');
                
                // Mecánicos FSL
                Map<Time, Integer> mapaMecanicos = obtenerMapaMecanicosDisponiblesFSL(
                    st.Id, fechaSolicitada.date(), st.Work_Type__c
                );
                
                // Construir bloques
                Map<Time, BloqueTrabajo> mapaBloques = new Map<Time, BloqueTrabajo>();
                Time t = horaInicio;
                while (t < horaFin) {
                    Integer mec = mapaMecanicos.containsKey(t) ? mapaMecanicos.get(t) : 0;
                    mapaBloques.put(t, new BloqueTrabajo(t, cantidadAsesores, mec));
                    t = t.addMinutes(30);
                }
                
                // Restar citas de asesores
                DateTime startOfDay = DateTime.newInstance(fechaSolicitada.date(), Time.newInstance(0,0,0,0));
                DateTime endOfDay = DateTime.newInstance(fechaSolicitada.date(), Time.newInstance(23,59,59,0));
                
                // CAMBIO 2: Agregar Subject y es_Reserva__c
                List<Event> eventosAsesores = [
                    SELECT Id, StartDateTime, EndDateTime, OwnerId, Asesor__c, Subject, es_Reserva__c
                    FROM Event
                    WHERE (Asesor__c IN :asesoresIds OR OwnerId IN :asesoresIds)
                    AND Estado__c != 'Cancelada'
                    AND Estado__c != 'Reprogramada'
                    AND StartDateTime <= :endOfDay
                    AND EndDateTime >= :startOfDay
                ];

                // CAMBIO 1: Inyectar eventos sintéticos de no disponibilidad recurrente
                List<No_disponibilidad_recurrente__c> noDispRecurrentes = [
                    SELECT Hora_Inicial_Recurrente__c, Asesor__c, Hora_Final_Recurrente__c, 
                           Calendario__c, Lunes__c, Martes__c, Miercoles__c, Jueves__c, Viernes__c, Sabado__c 
                    FROM No_disponibilidad_recurrente__c 
                    WHERE Calendario__c = :userCalendario.Id 
                    AND Activo__c = true
                ];

                for (No_disponibilidad_recurrente__c noDispRec : noDispRecurrentes) {
                    Boolean agregarEvento = false;
                    if (diaDeLaSemanaString == 'Mon' && noDispRec.Lunes__c) agregarEvento = true;
                    else if (diaDeLaSemanaString == 'Tue' && noDispRec.Martes__c) agregarEvento = true;
                    else if (diaDeLaSemanaString == 'Wed' && noDispRec.Miercoles__c) agregarEvento = true;
                    else if (diaDeLaSemanaString == 'Thu' && noDispRec.Jueves__c) agregarEvento = true;
                    else if (diaDeLaSemanaString == 'Fri' && noDispRec.Viernes__c) agregarEvento = true;
                    else if (diaDeLaSemanaString == 'Sat' && noDispRec.Sabado__c) agregarEvento = true;

                    if (agregarEvento) {
                        Event newEvent = new Event();
                        newEvent.OwnerId = noDispRec.Asesor__c;
                        newEvent.Asesor__c = noDispRec.Asesor__c;
                        newEvent.StartDateTime = Datetime.newInstance(fechaSolicitada.date(), noDispRec.Hora_Inicial_Recurrente__c);
                        newEvent.EndDateTime = Datetime.newInstance(fechaSolicitada.date(), noDispRec.Hora_Final_Recurrente__c);
                        eventosAsesores.add(newEvent);
                    }
                }
                
                // CAMBIO 3 y 4: Considerar comunidad/reserva + redondeo
                for (Event ev : eventosAsesores) {
                    // CAMBIO 4: Redondeo de minutos
                    Datetime diaHoraInicio = ev.StartDateTime;
                    Integer minutes1 = diaHoraInicio.minute();
                    Integer roundedMinutes1 = (Math.round(minutes1/30.0) * 30);
                    Integer difference1 = roundedMinutes1 - minutes1;
                    diaHoraInicio = diaHoraInicio.addMinutes(difference1);

                    Datetime diaHoraFin = ev.EndDateTime;
                    Integer minutes2 = diaHoraFin.minute();
                    Integer roundedMinutes2 = (Math.round(minutes2/30.0) * 30);
                    Integer difference2 = roundedMinutes2 - minutes2;
                    if (difference2 < 0) difference2 = difference2 * -1;
                    diaHoraFin = diaHoraFin.addMinutes(difference2);

                    Time evIni = diaHoraInicio.time();
                    Time evFin = diaHoraFin.time();
                    
                    for (Time bloqueTime : mapaBloques.keySet()) {
                        if (bloqueTime >= evIni && bloqueTime < evFin) {
                            BloqueTrabajo bt = mapaBloques.get(bloqueTime);
                            
                            Boolean esEventoAsesor = (ev.OwnerId == ev.Asesor__c);
                            Boolean esEventoComunidad = (ev.Subject == 'Evento de Comunidad. Vehículo:' && ev.es_Reserva__c == true);
                            Boolean esReserva = (ev.Subject == 'Reserva' && ev.es_Reserva__c == true);
                            
                            if (esEventoAsesor || esEventoComunidad || esReserva) {
                                if (bt.asesoresDisponibles > 0) bt.asesoresDisponibles--;
                            }
                            mapaBloques.put(bloqueTime, bt);
                        }
                    }
                }

                System.debug('============ mapaBloques ============');
                System.debug(mapaBloques);
                
                // Buscar horas disponibles
                // CAMBIO 4b y 6: Restricción hora en punto + ajuste último bloque
                List<Time> horasDisponibles = new List<Time>();
                Time cursor = horaInicio;
                Time ultimo = horaFin.addMinutes(-duracionCita);
                
                if (isCitaSincronica) {
                    ultimo = ultimo.addMinutes(30);
                }
                
                while (cursor <= ultimo) {
                    if (isCitaSincronica && cursor.minute() != 0) {
                        cursor = cursor.addMinutes(30);
                        continue;
                    }
                    
                    Boolean ok = true;
                    Time iter = cursor;
                    
                    for (Integer i = 0; i < bloquesNecesarios; i++) {
                        if (!mapaBloques.containsKey(iter)) { ok = false; break; }
                        
                        BloqueTrabajo b = mapaBloques.get(iter);
                        System.debug('============ bloques horas revision ============');
                        System.debug(b);
                        if (isCitaSincronica) {
                            if (b.asesoresDisponibles <= 0 || b.mecanicosDisponibles <= 0) { ok = false; break; }
                        } else {
                            if (i == 0 && b.asesoresDisponibles <= 0) { ok = false; break; }
                            if (i > 0 && b.mecanicosDisponibles <= 0) { ok = false; break; }
                        }
                        iter = iter.addMinutes(30);
                    }
                    
                    if (ok) horasDisponibles.add(cursor);
                    cursor = cursor.addMinutes(30);
                }
                
                // Filtrar horas pasadas si es hoy
                if (fechaSolicitada.date() == Date.today()) {
                    horasDisponibles = filterTimes(horasDisponibles);
                }
                
                // Armar respuesta
                Map<String, Object> horasResponse = new Map<String, Object>();
                Integer idx = 1;
                for (Time h : horasDisponibles) {
                    horasResponse.put(String.valueOf(idx++), h);
                }
                horasResponse.put('10', 'Otras fechas');
                
                responseData.put('horas', horasResponse);
            }
            else {
                responseData.put('Error', 'tipoPeticion no soportada en procesarPeticionInterna');
                statusCode = 404;
            }
            
        } catch (Exception e) {
            responseData.put('Error', e.getMessage());
            responseData.put('StackTrace', e.getStackTraceString());
            statusCode = 500;
        }
        
        // Retornar JSON con statusCode y body
        return JSON.serialize(new Map<String, Object>{
            'statusCode' => statusCode,
            'body' => responseData
        });
    }

    
    
    
    
    
    
   
    
    
}