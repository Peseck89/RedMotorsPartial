public with sharing class cT_nuevaCitaGarantia_controller {

    @AuraEnabled(Cacheable = true)
    public static Boolean getKilometros(String cocheId, String cocheVin, Decimal kilometros) {
        return CT_nuevaCita_Base.getKilometros(cocheId, cocheVin, kilometros);
    }

    @AuraEnabled(Cacheable = true)
    public static List<Event> getActives(String recordId) {
        List<Event> lstEvents = [Select Id,StartDateTimeF__c,idCalendarioFlow__c,Asesor__c,Asesor__r.Name,Activo__c,Activo__r.numeroDePlaca__c,StartDateTime,OwnerId,Description,ServiceTerritory__c,Service_Territory_Formula__c,ServiceTerritory__r.Name,OrigenEvento__c From Event Where Id =: recordId];
        //we need to know if Asesor__r.Name contains Calendar 
        String esteEvento = lstEvents[0].id;
        if (lstEvents[0].Asesor__r != null && lstEvents[0].Asesor__r.Name != null 
        && lstEvents[0].Asesor__r.Name.contains('Calendar')) {
        // Perform your logic here
            String calendarioSelec =  lstEvents[0].Asesor__c;
            System.debug('Asesor__r.Name contains "Calendar".');
            List<String> lstStr = new List<String>();
            List<User> lstUser = [Select Id,FirstName,Name,LastName From User Where Id In (Select Asesor__c FROM AsesorxCalendario__c WHERE Calendario__c =:calendarioSelec)];
            for(User ur : lstUser){
                lstStr.add(ur.id);
            }
            List<Event> lstEvent = [select Id,Asesor__r.Name,Owner.Name,Asesor__c From Event Where ( Asesor__c IN :lstStr)  AND (OwnerId IN:lstStr ) AND StartDateTime <=:lstEvents[0].StartDateTime  AND EndDateTime > :lstEvents[0].StartDateTime AND id != :esteEvento];
            if(lstEvent.size()>0){
                for (Event evt : lstEvent) {
                    // Check if the Asesor__c value exists in lstStr
                    Integer index = lstStr.indexOf(evt.Asesor__c);
                    if (index != -1) {
                        // Remove the item by index
                        lstStr.remove(index);
                    }
                }
            }
            if(lstStr.size()>0){
                lstEvents[0].Asesor__c = lstStr[0];
                //update lstEvents;
            }
        } else {
            System.debug('Asesor__r.Name does not contain "Calendar" or is null.');
        }
        return lstEvents;
    }

    @AuraEnabled(Cacheable = true)
    public static List<User> getDataAsesor(String asesorId) {
        return CT_nuevaCita_Base.getDataAsesor(asesorId);
    }

    @AuraEnabled(Cacheable = true)
    public static List<Asset> getDataActivos(String accountId) {
        return CT_nuevaCita_Base.getDataActivos(accountId);
    }

    
    @AuraEnabled()
    public static Asset guardarAsset(String numeroPlaca,String tipoVehi,String marca,String modelo,String numeroChasis,String motor,String color, String anio, String kilometros,String accountSelected) {
        return CT_nuevaCita_Base.guardarAsset(numeroPlaca, tipoVehi, marca, modelo, numeroChasis, motor, color, anio, kilometros, accountSelected);
    }

    @AuraEnabled(Cacheable = true)
    public static List<User> getCalendario() {
        return CT_nuevaCita_Base.getCalendario();
    }

    @AuraEnabled(Cacheable = true)
    public static List<User> getDataCalendario(String calendarId) {
        return CT_nuevaCita_Base.getDataCalendario(calendarId);
    }

    @AuraEnabled(Cacheable = true)
    public static List<User> getAsesores(String calendario) {
        return CT_nuevaCita_Base.getAsesores(calendario);
    }

    @AuraEnabled
    public static List<String> getCedula(String cedula) {
        return CT_nuevaCita_Base.getCedula(cedula);
    }

    @AuraEnabled(cacheable=true)
    public static List<Seguro__c> getSeguroDetails(String cocheId, String cocheVin) {
        return CT_nuevaCita_Base.getSeguroDetails(cocheId, cocheVin);
    }

    @AuraEnabled(Cacheable = true)
    public static List<Asset> getAsset(String cocheId, String cocheVin) {
        return CT_nuevaCita_Base.getAsset(cocheId, cocheVin);
    }
    @AuraEnabled()
    public static List<Account> updateDataAccount (String cuentaId, String telCuenta, String identificacioCuenta, String correoCuenta) {
        return CT_nuevaCita_Base.updateDataAccount(cuentaId, telCuenta, identificacioCuenta, correoCuenta);
    }
    

    @AuraEnabled()
    public static List<Account> updateAccount (String cocheId, String cocheVin, String cuentaId) {
        List<Asset> lstAsset = new List<Asset>();
        if(cocheId != null && cocheId != 'undefined' && cocheId !=''){
            lstAsset = [Select Id,AccountId,ContactId
            From Asset Where Id =:cocheId  LIMIT 1 ];
        }else if(cocheVin != null && cocheVin != 'undefined' && cocheVin !=''){
            lstAsset = [Select Id,AccountId,ContactId
            From Asset Where Id =:cocheVin  LIMIT 1 ];
        }        
        for(Asset coche : lstAsset){
            coche.AccountId = cuentaId;
        }
        List<Account> lstCuenta = [Select Id,Name,PersonEmail,PersonContactId,PersonContact.FirstName,PersonContact.Name,PersonContact.LastName,PersonContact.phone,PersonContact.email,CorreoElectronicoEmpresarial__c,Phone,codigoSoftland__c,Cedula__c,Tipo_de_Documento__c From Account Where Id =:cuentaId ];
        if(lstCuenta.size()>0){
            if(lstCuenta[0].PersonContactId != null ){
                for(Asset coche : lstAsset){
                    coche.ContactId = lstCuenta[0].PersonContactId;
                }                
            }
        }
        
        update lstAsset;         
        return lstCuenta;
        
    }


    @AuraEnabled()
    public static List<Contact> updateContactData (String contactId,String nombreC, String apellidoC, String phoneC, String tipoI, String emailC, String cedulaCont,String cocheId, String cocheVin ) {
        return CT_nuevaCita_Base.updateContactData(contactId, nombreC, apellidoC, phoneC, tipoI, emailC, cedulaCont, cocheId, cocheVin);
    }

    @AuraEnabled()
    public static List<Contact> updateContact (String cocheId, String cocheVin, String contactId) {
        return CT_nuevaCita_Base.updateContact(cocheId, cocheVin, contactId);
    }
    @AuraEnabled()
    public static Event actualizarHorarios (String recordId,Datetime fecha) {
        return CT_nuevaCita_Base.actualizarHorarios(recordId, fecha);
    }



    @AuraEnabled()
    public static List<Contact> createContact (String cocheId, String cocheVin,String cuenta, String nombreContacto,String apellidoContacto,String telefonoContacto,String correoContacto) {
        return CT_nuevaCita_Base.createContact(cocheId, cocheVin, cuenta, nombreContacto, apellidoContacto, telefonoContacto, correoContacto);
    }

    @AuraEnabled()
    public static Account createAccount (String nombreCuenta,String apellido,String cedula,String telefono,String fechaNacimiento,String correoElectronico,String nombreEncargado,String telefonoEncargado,Boolean esEmpresarial) {
        return CT_nuevaCita_Base.createAccount(nombreCuenta, apellido, cedula, telefono, fechaNacimiento, correoElectronico, nombreEncargado, telefonoEncargado, esEmpresarial);
    }

    @AuraEnabled(Cacheable = true)
    public static List<Event> otrosEventos(String cocheId, String cocheVin) {
        return CT_nuevaCita_Base.otrosEventos(cocheId, cocheVin);
    }

    @AuraEnabled(Cacheable = true)
    public static Map<String, List<String>> getDependentMap( String controlField, String depentField) {
        return CT_nuevaCita_Base.getDependentMap(controlField, depentField);
    }
    
    @AuraEnabled()
    public static String getServiceT (String calendarioSel) {
        return CT_nuevaCita_Base.getServiceT(calendarioSel);
    }

    @AuraEnabled()
    public static Boolean buscarDuplicado (String asesorId, String sucursal,DateTime fechaHoraSolicitada,String esteEvento ) {
        return CT_nuevaCita_Base.buscarDuplicado(asesorId, sucursal, fechaHoraSolicitada, esteEvento);
    }

    @AuraEnabled()
    public static String createEvent (String contactId,String cocheId,String asesorId, String sucursal,DateTime fechaHoraSolicitada,String kilometros,string serviceTerritoryBuscar,String origenCita, String comentarios, Boolean ignorarDuplicado) {
        return CT_nuevaCita_Base.createEvent(contactId, cocheId, asesorId, sucursal, fechaHoraSolicitada, kilometros, serviceTerritoryBuscar, origenCita, comentarios, ignorarDuplicado);
    }

    @AuraEnabled()
    public static Boolean updateEventOrigen (String idShadow,String origenCorrecto) {
        return CT_nuevaCita_Base.updateEventOrigen(idShadow, origenCorrecto);
    }

    @AuraEnabled()
    public static String getUrlEvent (String idShadow,String esteRecord,String origenCorrecto) {
        return CT_nuevaCita_Base.getUrlEvent(idShadow, esteRecord, origenCorrecto);
    }

    @AuraEnabled(cacheable=true)
    public static User getCurrentUser() {
        return CT_nuevaCita_Base.getCurrentUser();
    }

    @AuraEnabled
    public static Boolean verifyContactData(String contactId, String accountId) {
        return CT_nuevaCita_Base.verifyContactData(contactId, accountId);
    }


    public static User obtenerUsuarioCalendario(String sucursalBuscada) {
        return CT_nuevaCita_Base.obtenerUsuarioCalendario(sucursalBuscada);
    }
    public static Integer obtenerDuracionCitaEnServiceTerritoryMotos(Id serviceTerritoryId, String kilometraje) {
        return CT_nuevaCita_Base.obtenerDuracionCitaEnServiceTerritoryMotos(serviceTerritoryId, kilometraje);
    }

    public static Integer obtenerDuracionCitaEnServiceTerritory(Id serviceTerritoryId) {
        return CT_nuevaCita_Base.obtenerDuracionCitaEnServiceTerritory(serviceTerritoryId);
    }




    public static String decimalToBinary(Integer val) {
        return CT_nuevaCita_Base.decimalToBinary(val);
    }
    
    public static String base64ToBits(String validFor) {
        return CT_nuevaCita_Base.base64ToBits(validFor);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Campa_a_t_cnica__c> getCampaniasByAssetId(String assetId) {
        return CT_nuevaCita_Base.getCampaniasByAssetId(assetId);
    }

    @AuraEnabled
    public static void confirmarCampanias(String assetId) {
        CT_nuevaCita_Base.confirmarCampanias(assetId);
    }

    // @AuraEnabled
    // public static List<Map<String, Object>> obtenerDisponibilidadProximosDias() {
    //     // Paso 1: Obtener los IDs de los asesores
    //     Set<Id> idsAsesores = new Set<Id>();

    //     // Asesor principal
    //     List<User> calendarioPrincipal = [SELECT Id FROM User WHERE Name = 'Calendario Garantías' LIMIT 1];
    //     if (!calendarioPrincipal.isEmpty()) {
    //         idsAsesores.add(calendarioPrincipal[0].Id);
    //     }

    //     // Asesores relacionados
    //     List<AsesorxCalendario__c> asesoresRelacionados = [
    //         SELECT Asesor__c 
    //         FROM AsesorxCalendario__c 
    //         WHERE Calendario__r.Name = 'Calendario Garantías'
    //     ];
    //     for (AsesorxCalendario__c ac : asesoresRelacionados) {
    //         if (ac.Asesor__c != null) {
    //             idsAsesores.add(ac.Asesor__c);
    //         }
    //     }

    //     // Paso 2: Preparar los horarios por día (10:00 - 18:00 cada 30 min)
    //     List<Map<String, Object>> resultado = new List<Map<String, Object>>();
    //     Date hoy = Date.today();
    //     Integer dias = 5;

    //     for (Integer d = 0; d < dias; d++) {
    //         Date fechaActual = hoy.addDays(d);
    //         List<Datetime> bloques = new List<Datetime>();

    //         for (Integer h = 07; h < 16; h++) {
    //             bloques.add(Datetime.newInstance(fechaActual, Time.newInstance(h, 0, 0, 0)));
    //             bloques.add(Datetime.newInstance(fechaActual, Time.newInstance(h, 30, 0, 0)));
    //         }

    //         // Buscar eventos que crucen con ese día
    //         Datetime inicioDia = Datetime.newInstance(fechaActual, Time.newInstance(0, 0, 0, 0));
    //         Datetime finDia = Datetime.newInstance(fechaActual, Time.newInstance(23, 59, 59, 999));

    //         List<Event> eventosOcupados = [
    //             SELECT StartDateTime, EndDateTime 
    //             FROM Event 
    //             WHERE Asesor__c IN :idsAsesores 
    //             AND StartDateTime < :finDia 
    //             AND EndDateTime > :inicioDia
    //         ];

    //         List<String> horasDisponibles = new List<String>();

    //         for (Datetime bloque : bloques) {
    //             Boolean ocupado = false;
    //             for (Event evt : eventosOcupados) {
    //                 if (evt.StartDateTime < bloque.addMinutes(30) && evt.EndDateTime > bloque) {
    //                     ocupado = true;
    //                     break;
    //                 }
    //             }
    //             if (!ocupado) {
    //                 horasDisponibles.add(bloque.format('HH:mm', 'es_MX'));
    //             }

    //             if (horasDisponibles.size() == 5) break; // solo los primeros 5
    //         }

    //         String fechaFormateada = 
    //         (fechaActual.day() < 10 ? '0' + fechaActual.day() : String.valueOf(fechaActual.day())) + '/' +
    //         (fechaActual.month() < 10 ? '0' + fechaActual.month() : String.valueOf(fechaActual.month())) + '/' +
    //         fechaActual.year();
    //         Map<String, Object> dia = new Map<String, Object>();
    //         dia.put('fecha', fechaActual);
    //         dia.put('horarios', horasDisponibles);
    //         resultado.add(dia);
    //     }

    //     return resultado;
    // }

    @AuraEnabled
    public static List<Map<String, Object>> obtenerDisponibilidadProximosDias(Date fechaInicial) {
        system.debug('=====================fechaInicial=======================');
        system.debug(fechaInicial);
        //Date hoy = Date.valueOf(fechaInicial);

        // Paso 1: Obtener los IDs de los asesores
        Set<Id> idsAsesores = new Set<Id>();
        Id idCalendarioPrincipal = null;

        // Asesor principal
        // List<User> calendarioPrincipal = [SELECT Id FROM User WHERE Name = 'Calendario Garantías' LIMIT 1];
        // if (!calendarioPrincipal.isEmpty()) {
        //     idsAsesores.add(calendarioPrincipal[0].Id);
        // }

        List<User> calendarioPrincipal = [SELECT Id FROM User WHERE Name = 'Calendario Garantías' LIMIT 1];
            if (!calendarioPrincipal.isEmpty()) {
            idCalendarioPrincipal = calendarioPrincipal[0].Id;
            idsAsesores.add(idCalendarioPrincipal);
        }

        // Asesores relacionados
        // List<AsesorxCalendario__c> asesoresRelacionados = [
        //     SELECT Asesor__c 
        //     FROM AsesorxCalendario__c 
        //     WHERE Calendario__r.Name = 'Calendario Garantías'
        // ];
        // for (AsesorxCalendario__c ac : asesoresRelacionados) {
        //     if (ac.Asesor__c != null) {
        //         idsAsesores.add(ac.Asesor__c);
        //     }
        // }

        List<AsesorxCalendario__c> asesoresRelacionados = [
            SELECT Asesor__c 
            FROM AsesorxCalendario__c 
            WHERE Calendario__r.Name = 'Calendario Garantías'
        ];
        for (AsesorxCalendario__c ac : asesoresRelacionados) {
            if (ac.Asesor__c != null) {
                idsAsesores.add(ac.Asesor__c);
            }
        }

        // Paso 2: Configuración de zona horaria
        final String TZ = 'America/Costa_Rica';
        Date hoy = fechaInicial; // evita valueOf innecesario
        final String todayCRStr = System.now().format('yyyy-MM-dd', TZ);
        final String nowCR_HHMM = System.now().format('HH:mm', TZ);

        List<Map<String, Object>> resultado = new List<Map<String, Object>>();
        

        List<No_disponibilidad_recurrente__c> lstNoDisp = [Select Id,Hora_Inicial_Recurrente__c,Hora_Final_Recurrente__c,Lunes__c,Martes__c,Miercoles__c,Jueves__c,Viernes__c From No_disponibilidad_recurrente__c Where Calendario__r.Name = 'Calendario Garantías' AND Activo__c = true AND Asesor__c IN :idsAsesores ];
        Integer valoresTotales = 0;
        for (Integer d = 0; valoresTotales < 6; d++) {
            Date fechaActual = hoy.addDays(d);
            Datetime dt = Datetime.newInstance(fechaActual, Time.newInstance(0, 0, 0, 0));
            
            // Saltar fines de semana
            String diaSemana = dt.format('E', 'America/Costa_Rica');
            if (diaSemana == 'sáb.' || diaSemana == 'Sat' || diaSemana == 'dom.' || diaSemana == 'Sun') continue;

            final String fechaActualCRStr = dt.format('yyyy-MM-dd', TZ);


            // Generar bloques de tiempo de 7:00 a 16:30 cada 30 minutos
            List<Time> bloques = new List<Time>();
            for (Integer hora = 7; hora <= 16; hora++) {
                
                if(lstNoDisp.size()>0){
                    for (Integer minuto : new List<Integer>{0, 30}) {
                        Time posibleBloque = Time.newInstance(hora, minuto, 0, 0);
                        Boolean bloquearBloque = false;
                        
                        for (No_disponibilidad_recurrente__c noDisp : lstNoDisp) {
                            Boolean diaCoincide = false;

                            if ((diaSemana == 'Mon' || diaSemana == 'lun.') && noDisp.Lunes__c) diaCoincide = true;
                            if ((diaSemana == 'Tue' || diaSemana == 'mar.') && noDisp.Martes__c) diaCoincide = true;
                            if ((diaSemana == 'Wed' || diaSemana == 'mié.') && noDisp.Miercoles__c) diaCoincide = true;
                            if ((diaSemana == 'Thu' || diaSemana == 'jue.') && noDisp.Jueves__c) diaCoincide = true;
                            if ((diaSemana == 'Fri' || diaSemana == 'vie.') && noDisp.Viernes__c) diaCoincide = true;

                            if (diaCoincide) {
                                if (noDisp.Hora_Inicial_Recurrente__c != null && noDisp.Hora_Final_Recurrente__c != null) {
                                    if (posibleBloque >= noDisp.Hora_Inicial_Recurrente__c &&
                                        posibleBloque <  noDisp.Hora_Final_Recurrente__c) {
                                        bloquearBloque = true;
                                        break; // Ya sabemos que este bloque no se debe agregar
                                    }
                                }
                            }
                        }
                        
                        if (!bloquearBloque) {
                            bloques.add(posibleBloque);
                        }
                    }                    
                }else{
                    bloques.add(Time.newInstance(hora, 0, 0, 0));
                    if (hora < 16) { // Evitar crear 16:30 si no es necesario
                        bloques.add(Time.newInstance(hora, 30, 0, 0));
                    }
                }                
            }

            // Buscar eventos para este día
            Datetime inicioDia = Datetime.newInstance(fechaActual, Time.newInstance(0, 0, 0, 0));
            Datetime finDia = Datetime.newInstance(fechaActual, Time.newInstance(23, 59, 59, 999));

            List<Event> eventosOcupados = [
                SELECT Id, StartDateTime, EndDateTime, IsAllDayEvent 
                FROM Event 
                WHERE Asesor__c IN :idsAsesores
                AND (
                    (StartDateTime >= :inicioDia AND StartDateTime <= :finDia) OR
                    (EndDateTime >= :inicioDia AND EndDateTime <= :finDia) OR
                    (StartDateTime <= :inicioDia AND EndDateTime >= :finDia)
                )
                ORDER BY StartDateTime
            ];

            List<String> horasDisponibles = new List<String>();

            for (Time bloqueTime : bloques) {
                Datetime bloque = Datetime.newInstance(fechaActual, bloqueTime);
                System.debug('============= Fecha ============');
                System.debug(fechaActual);
                System.debug(Date.today());
                System.debug(bloque);
                System.debug(Datetime.now());

                String bloqueHHMM = bloque.format('HH:mm', TZ);
                if (fechaActualCRStr == todayCRStr && bloqueHHMM <= nowCR_HHMM) {
                    continue;
                }

                Datetime finBloque = bloque.addMinutes(60);
                
                Boolean ocupado = false;
                
                for (Event evt : eventosOcupados) {
                    // Manejar eventos de todo el día
                    if (evt.IsAllDayEvent) {
                        ocupado = true;
                        break;
                    }
                    
                    // Verificar superposición más precisa
                    if ((evt.StartDateTime < finBloque) && (evt.EndDateTime > bloque)) {
                        ocupado = true;
                        break;
                    }
                }
                
                if (!ocupado) {
                    // Formatear hora según zona horaria de Costa Rica
                    //horasDisponibles.add(bloque.format('HH:mm', 'America/Costa_Rica'));
                    horasDisponibles.add(bloqueHHMM);

                }
            }

            String fechaFormateada = dt.format('dd/MM/yyyy', 'America/Costa_Rica');
            
            Map<String, Object> dia = new Map<String, Object>();
            dia.put('fecha', fechaFormateada);
            if(horasDisponibles.size()>0){
                dia.put('horarios', horasDisponibles);
                valoresTotales = valoresTotales +1;
                resultado.add(dia);
            }
            
            
        }

        return resultado;
    }

    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
        
    }
}
