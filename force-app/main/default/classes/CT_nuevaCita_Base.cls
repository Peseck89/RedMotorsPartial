public with sharing class CT_nuevaCita_Base {

    public static Boolean getKilometros(String cocheId, String cocheVin, Decimal kilometros) {
        Decimal kmActuales = 0;
        List<Asset> lstEvents = [Select Id,Kilometros__c From Asset Where Id =: cocheId Or Id =:cocheVin];
        if(lstEvents.size()>0){
            kmActuales = lstEvents[0].Kilometros__c;
        }
        if(kmActuales > kilometros){
            return false;
        }else{
            return true;
        }        
    }

    public static List<User> getDataAsesor(String asesorId) {
        List<User> lstUser = [Select Id,Name From User Where Id =: asesorId];
        return lstUser;
    }

    public static List<Asset> getDataActivos(String accountId) {
        List<Asset> lstUser = [Select Id,Name From Asset Where AccountId =: accountId];
        return lstUser;
    }

    public static Asset guardarAsset(String numeroPlaca,String tipoVehi,String marca,String modelo,String numeroChasis,String motor,String color, String anio, String kilometros,String accountSelected) {
        
        List<Asset> lstAsset = [Select Id From Asset Where numeroDePlaca__c = :numeroPlaca];
        // try {

            if(lstAsset.size()>0){
                return lstAsset[0];
            }else{
                Asset newAsset = new Asset();
                newAsset.Name = numeroPlaca;
                newAsset.numeroDePlaca__c = numeroPlaca;
                newAsset.Tipo_de_veh_culo__c = tipoVehi;
                newAsset.Marca_Nvo__c = marca;
                newAsset.Modelo_Nvo2__c = modelo;
                newAsset.NumeroDeChasis__c = numeroChasis;
                newAsset.Motor__c = motor;
                newAsset.Color__c = color;
                newAsset.Anio__c = anio;
                newAsset.Kilometros__c = Decimal.valueOf(kilometros);
                newAsset.AccountId = accountSelected;
                insert newAsset;
                return newAsset;
            }
            
        // } catch (Exception e) {
        //     return null;
        // }
        
    }

    public static List<User> getCalendario() {
        List<User> lstUser = [Select Id,FirstName,Name,LastName From User Where FirstName = 'Calendario' and LastName != 'Escazú - Mecánica Rápida 2' AND LastName != 'Uruca - Enderezado y Pintura'];
        return lstUser;
    }

    public static List<User> getDataCalendario(String calendarId) {
        List<User> lstUser = [Select Id,FirstName,Name,LastName From User Where Id = :calendarId];
        return lstUser;
    }

    public static List<User> getAsesores(String calendario) {
        List<User> lstUser = [Select Id,FirstName,Name,LastName From User Where Id In (Select Asesor__c FROM AsesorxCalendario__c WHERE Calendario__c =:calendario)];
        return lstUser;
    }

    public static List<String> getCedula(String cedula){
        List<String> cedulaCliente = new List<String>();
        List<String> cedulaInfo = new List<String>();

        List<Account> lstAccount = [Select Id,FirstName,LastName,PersonEmail,Phone,Tipo_de_Documento__c From Account Where Cedula__c =:cedula ];
        if(lstAccount.size()>0){
            String textCompleto = lstAccount[0].FirstName+';'+lstAccount[0].LastName+';'+';'+lstAccount[0].PersonEmail+';'+lstAccount[0].Phone+';';
            cedulaInfo.add(textCompleto);
            cedulaInfo.add('existe');
        }else{
            cedulaCliente.add(cedula);        
            cedulaInfo = ApiCreditWS.getInfoCliente( cedulaCliente);
            cedulaInfo.add('nuevo');
        }
        
        return cedulaInfo;
    }

    public static List<Seguro__c> getSeguroDetails(String cocheId, String cocheVin)  {
        List<Seguro__c> lstSeguro = new List<Seguro__c>();
        if(cocheId != null && cocheId != 'undefined' && cocheId !=''){
            lstSeguro = [Select Activo__c, Tipo_seguro__c, Asset__c From Seguro__c Where Asset__c = :cocheId LIMIT 1];
        }
        
        return lstSeguro;
    }

    public static List<Asset> getAsset(String cocheId, String cocheVin) {

        List<Asset> lstAsset = new List<Asset>();
        if(cocheId != null && cocheId != 'undefined' && cocheId !=''){
            lstAsset = [Select Id,Tipo_de_veh_culo__c,numeroDePlaca__c,NumeroDeChasis__c ,AccountId
            ,Anio__c,Color__c,marca__c,Modelo_Nvo2__c,Marca_Otros__c,Modelo_Otros__c,Account.Name,Account.PersonEmail,Account.FirstName,Account.LastName,
            Account.CorreoElectronicoEmpresarial__c,Account.PersonContactId,Account.Phone,Account.codigoSoftland__c,Account.Cedula__c, Account.IsPersonAccount,ContactId,Contact.Name,Contact.FirstName,Contact.LastName,Contact.Cedula__c,
            Contact.Account.Cedula__c,Contact.Correo_Electronico__c,Contact.email,Contact.Phone,Garant_a_de_activo__c,
            Garant_a_de_activo__r.AssetWarrantyNumber,Garant_a_de_activo__r.WarrantyTerm.WarrantyTermName,Garant_a_de_activo__r.StartDate,Garant_a_de_activo__r.EndDate,Garant_a_de_activo__r.WarrantyTerm.EffectiveStartDate,Garant_a_de_activo__r.WarrantyType
            From Asset Where Id =:cocheId  LIMIT 1 ];
        }else if(cocheVin != null && cocheVin != 'undefined' && cocheVin !=''){
            lstAsset = [Select Id,Tipo_de_veh_culo__c,numeroDePlaca__c,NumeroDeChasis__c ,AccountId
            ,Anio__c,Color__c,marca__c,Modelo_Nvo2__c,Marca_Otros__c,Modelo_Otros__c,Account.Name,Account.PersonEmail,Account.FirstName,Account.LastName,
            Account.CorreoElectronicoEmpresarial__c,Account.PersonContactId,Account.Phone,Account.codigoSoftland__c,Account.Cedula__c, Account.IsPersonAccount,ContactId,Contact.Name,Contact.FirstName,Contact.LastName,Contact.Cedula__c,Contact.Account.Cedula__c,Contact.Correo_Electronico__c,Contact.email,Contact.Phone,Garant_a_de_activo__c,
            Garant_a_de_activo__r.AssetWarrantyNumber,Garant_a_de_activo__r.WarrantyTerm.WarrantyTermName,Garant_a_de_activo__r.StartDate,Garant_a_de_activo__r.EndDate,Garant_a_de_activo__r.WarrantyTerm.EffectiveStartDate,Garant_a_de_activo__r.WarrantyType
            From Asset Where Id =:cocheVin  LIMIT 1 ];
        }
        

        return lstAsset;
    }

    public static List<Account> updateDataAccount (String cuentaId, String telCuenta, String identificacioCuenta, String correoCuenta) {
        List<Account> lstCuenta = [Select Id,Name,PersonEmail,CorreoElectronicoEmpresarial__c,Phone,codigoSoftland__c,Cedula__c,IsPersonAccount,Tipo_de_Documento__c From Account Where Id =:cuentaId ];
        List<Account> lstExisteCorreo = [Select Id From Account Where (PersonEmail =:correoCuenta Or CorreoElectronicoEmpresarial__c = :correoCuenta )And Id != :cuentaId];
        if(lstExisteCorreo.size()>0){
            throw new AuraHandledException('Correo duplicado');
        }else{
            for(Account cuenta : lstCuenta){
                cuenta.Phone = telCuenta;
                //cuenta.Cedula__c = identificacioCuenta;
                if(cuenta.IsPersonAccount == true){
                    cuenta.PersonEmail = correoCuenta;
                }else{
                    cuenta.CorreoElectronicoEmpresarial__c = correoCuenta;
                }
            }
            update lstCuenta;
            return lstCuenta;
        }
       
       
    }

    public static List<Contact> updateContactData (String contactId,String nombreC, String apellidoC, String phoneC, String tipoI, String emailC, String cedulaCont,String cocheId, String cocheVin ) {
        List<Contact> lstContact = [Select Id,FirstName,LastName,Email,Phone,Cedula__c,Tipo_de_Documento__c From Contact Where Id =:contactId ];

        for(Contact contacto : lstContact){
            contacto.FirstName = nombreC;
            contacto.LastName = apellidoC;
            contacto.Email = emailC;
            contacto.Phone = phoneC;
            contacto.Tipo_de_Documento__c = tipoI;
            //contacto.Cedula__c = cedulaCont;
            contacto.Vehiculo_relacionado__c = cocheId;
        }
        List<Asset> lstAsset = [Select Id,ContactId From Asset Where Id =:cocheId ];
        if(lstAsset.size() > 0){
            lstAsset[0].ContactId = contactId;
            update lstAsset;
        }
        
        update lstContact;
        return lstContact;
    }

    public static List<Contact> updateContact (String cocheId, String cocheVin, String contactId) {
        List<Asset> lstAsset = new List<Asset>();
        if(cocheId != null && cocheId != 'undefined' && cocheId !=''){
            lstAsset = [Select Id,AccountId,ContactId
            From Asset Where Id =:cocheId  LIMIT 1 ];
        }else if(cocheVin != null && cocheVin != 'undefined' && cocheVin !=''){
            lstAsset = [Select Id,AccountId,ContactId
            From Asset Where Id =:cocheVin  LIMIT 1 ];
        }        
        for(Asset coche : lstAsset){
            coche.ContactId = contactId;
        }
        
        update lstAsset;
         List<Contact> lstContact = [Select Id,Name,FirstName,LastName,Email,Phone,Tipo_de_Documento__c From Contact Where Id =:contactId ];
        return lstContact;
        
    }

    public static Event actualizarHorarios (String recordId,Datetime fecha) {
        System.debug('=========================Log Antonio ======================');
        System.debug(fecha);
        //System.debug(horario);
        System.debug(recordId);
        
        // Parse the date and time
        //DateTime combinedDateTime = combineDateAndTime(fecha, horario);
        DateTime combinedDateTime = fecha;
        System.debug('Combined DateTime: ' + fecha);
        List<Event> lstEvento = [SELECT Id,StartDateTime,EndDateTime,ActivityDateTime,StartDateTimeF__c,puedeCambiar__c FROM Event WHERE Id =: recordId];
        for(Event evento : lstEvento){
            evento.StartDateTime = combinedDateTime;
            evento.ActivityDateTime = combinedDateTime;
            evento.EndDateTime = combinedDateTime.addMinutes(30);
            evento.puedeCambiar__c = true;
            update evento;
        }
        // Query an account to update (Example: Update the first account found)
        
        return lstEvento[0];

    }

    public static List<Contact> createContact (String cocheId, String cocheVin,String cuenta, String nombreContacto,String apellidoContacto,String telefonoContacto,String correoContacto) {
        List<Asset> lstAsset = new List<Asset>();
        //List<Account> lstAcc = [Select Id From Account Where CorreoElectronicoEmpresarial__c = 'bavariancitas@testemail.com'];
        if(cocheId != null && cocheId != 'undefined' && cocheId !=''){
            lstAsset = [Select Id,AccountId,Account.IsPersonAccount,ContactId
            From Asset Where Id =:cocheId  LIMIT 1 ];
        }else if(cocheVin != null && cocheVin != 'undefined' && cocheVin !=''){
            lstAsset = [Select Id,Account.IsPersonAccount,AccountId,ContactId
            From Asset Where Id =:cocheVin  LIMIT 1 ];
        }    
        //crear contacto
        String idCreado = '';
        Contact newContact = new Contact();  
        if(lstAsset[0].Account.IsPersonAccount == false){
            newContact.Accountid = cuenta;
            newContact.FirstName = nombreContacto;
            newContact.LastName = apellidoContacto;
            newContact.Phone = telefonoContacto;
            newContact.Email = correoContacto;
            insert newContact;
            idCreado =  newContact.id;
            for(Asset coche : lstAsset){
                coche.ContactId = newContact.id;
            }
            update lstAsset;
        }else{
            Account newAccount = new Account();
            newAccount.RecordTypeId = '0120P000000aqoLQAQ';
            newAccount.FirstName = nombreContacto;
            newAccount.LastName = apellidoContacto;
            newAccount.PersonEmail = correoContacto;    
            newAccount.Phone = telefonoContacto;  
            newAccount.Vehiculo_relacionado__pc = cocheId;
            //newContact.Accountid = lstAcc[0].Id;
            insert newAccount;  
            List<Account> lstAcc = [Select Id, PersonContactId From Account Where id =:newAccount.id];
            if(lstAcc.size()>0){
                idCreado = lstAcc[0].PersonContactId;
            }
            List<Asset>  lstAsset1 = [Select Id,AccountId,ContactId
            From Asset Where Id =:cocheId  LIMIT 1 ];
            for(Asset coche : lstAsset1){
                coche.ContactId =  idCreado;
            }
            update lstAsset1;
        }              
        
        

        
        
       
         List<Contact> lstContact = [Select Id,Name From Contact Where Id =:idCreado ];
        return lstContact;
        
    }

    public static Account createAccount (String nombreCuenta,String apellido,String cedula,String telefono,String fechaNacimiento,String correoElectronico,String nombreEncargado,String telefonoEncargado,Boolean esEmpresarial) {
        List<Account> lstAcc = [Select Id,Name,LastName,FirstName,PersonEmail,CorreoElectronicoEmpresarial__c,Phone,Cedula__c,Tipo_de_Documento__c From Account Where Cedula__c =:cedula ];
    
        if(lstAcc.size()>0){
            return lstAcc[0]; 
        }else{            
            Account newAccount = new Account();
            if(esEmpresarial == true){
                newAccount.RecordTypeId = '0120P000000aqmZQAQ';
                newAccount.Name = nombreCuenta;
                newAccount.CorreoElectronicoEmpresarial__c = correoElectronico;
                newAccount.NombreEncargadoCuenta__c = nombreEncargado;
                newAccount.TelefonoEncargadoCuenta__c = telefonoEncargado;
            }else{
                newAccount.RecordTypeId = '0120P000000aqoLQAQ';
                newAccount.FirstName = nombreCuenta;
                newAccount.LastName = apellido;
                newAccount.PersonEmail = correoElectronico;            
            }            
            newAccount.Cedula__c = cedula;
            newAccount.Phone = telefono;  
            insert newAccount;  
            return newAccount;    
        }               
    }

    public static List<Event> otrosEventos(String cocheId, String cocheVin){
        List<Event> lstEventos = new List<Event>();
        List<Event> lstEventosFinales = new List<Event>();
        try {            
            if(cocheId != null && cocheId != 'undefined' && cocheId !=''){
                lstEventos = [Select Id,OwnerId,Owner.FirstName,Asesor__r.Name,StartDateTimeF__c,AsignedUserFormula__c,OrigenEvento__c,Calendario__c,StartDateTime,Activo__c From Event Where StartDateTime >= yesterday AND Activo__c =:cocheId order by StartDateTime desc];
            }else if(cocheVin != null && cocheVin != 'undefined' && cocheVin !=''){
                lstEventos = [Select Id,OwnerId,Owner.FirstName,Asesor__r.Name,StartDateTimeF__c,AsignedUserFormula__c,OrigenEvento__c,Calendario__c,StartDateTime,Activo__c From Event Where StartDateTime >= yesterday AND Activo__c =:cocheVin order by StartDateTime desc];
            }
            for(Event evento : lstEventos){
                if(!evento.Owner.FirstName.contains('Calendario') && !evento.Asesor__r.Name.contains('Calendario')){
                    lstEventosFinales.add(evento);
                }                
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return lstEventosFinales;
    }

    public static Map<String, List<String>> getDependentMap( String controlField, String depentField) {

        Asset myObject = new Asset();

        String controllingField     = controlField.toLowerCase();
        String dependentField       = depentField.toLowerCase();
                
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = myObject.getSObjectType();
        if (objType==null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        System.debug('valores: '+ objResults);
        return objResults;
    }

    public static String getServiceT (String calendarioSel){

        String serviceTerritory = '';
        List<AsesorxCalendario__c> lstServiceTerritory = [Select Id,Service_Territory__r.Name From AsesorxCalendario__c Where Calendario__c =:calendarioSel];
        for(AsesorxCalendario__c aseC : lstServiceTerritory){
            serviceTerritory = aseC.Service_Territory__r.Name;
        }
        return serviceTerritory;
    }

    public static Boolean buscarDuplicado (String asesorId, String sucursal,DateTime fechaHoraSolicitada,String esteEvento ){
        List<Event> lstEvent = [select Id,Asesor__r.Name,Owner.Name From Event Where (Asesor__r.Name =:asesorId Or Asesor__c =:asesorId)  AND (OwnerId =:asesorId Or  Owner.Name =:asesorId) AND StartDateTime <=:fechaHoraSolicitada  AND EndDateTime > :fechaHoraSolicitada AND id != :esteEvento];
        
        if(lstEvent.size()>0){
            Log_otro_medio__c nuevoLog = new Log_otro_medio__c();
                        nuevoLog.Sucursal__c = lstEvent[0].Owner.Name;
                        nuevoLog.Origen__c = 'Cita Salesforce';
                        nuevoLog.fecha_seleccionada__c = '' +fechaHoraSolicitada;
                        nuevoLog.Asesor__c = ' ' + lstEvent[0].Asesor__r.Name;
                        insert nuevoLog;
            return true;
            
        }else {
            return false;
        }
       
    }

    public static String createEvent (String contactId,String cocheId,String asesorId, String sucursal,DateTime fechaHoraSolicitada,String kilometros,string serviceTerritoryBuscar,String origenCita, String comentarios, Boolean ignorarDuplicado){
        
        
        List<Asset> lstAsset = [Select Id,ContactId From Asset Where Id =:cocheId  ];
        if(lstAsset.size() > 0){
            //if( contactId != null && (lstAsset[0].ContactId == null || lstAsset[0].ContactId == '')){
                lstAsset[0].ContactId = contactId;
                update lstAsset;
            //}                                        
        }
        
        
        String servicioSolicitado = sucursal; // mecanica rapida, general, diagnostico
        String sucursalSolicitado = sucursal;
        
        String placaOld = cocheId;// buscar la placa
        String placaSolicitada = '%' + placaOld;
        String origen = '';
        String sucursalFinal = sucursal;
        String kilometraje = kilometros;
        
        if(sucursalSolicitado == 'Motos Uruca BMW'){
            sucursalSolicitado = 'Motorrad';
        }else if(sucursalSolicitado == 'Motos Uruca Otros'){
            sucursalSolicitado = 'Otobai';
        }
        
        
        System.debug('=servicioSolicitado= ' + servicioSolicitado);
        System.debug('=sucursalSolicitado= ' + sucursalSolicitado);

        System.debug('=placaSolicitada= ' + placaSolicitada);
        
        System.debug('=sucursalFinal= ' + sucursalFinal);
        
        System.debug('=sucursalFinal= ' + origenCita);
        
        origen = origenCita;
        //origen = 'Formulario Web';
        if(origen == null || origen == '' || origen != 'Campaña previo de entrega'){
            origen = 'Formulario Web';
        }
        
        System.debug('=origen= ' + origen);

        // String[] f = fechaSolicitada.split('/');
        // String[] h = horaSolicitada.split(':');
        // Integer dia = Integer.valueof(f[0]);
        // Integer mes = Integer.valueof(f[1]);
        // Integer ano = Integer.valueof(f[2]);
        // Integer hora = Integer.valueof(h[0]);
        // Integer min = Integer.valueof(h[1]);
        // DateTime fechaHoraSolicitada = DateTime.newInstance(ano, mes, dia,hora,min,00);

        Map<String,Object> response = new Map<String,Object>();

      
            //1) objtener el calendario
            User userCalendario = obtenerUsuarioCalendario(serviceTerritoryBuscar);
            String asesoraBuscar = '%'+asesorId+'%';
            //3) Obtener asesores relacionados
            String likeVariable = serviceTerritoryBuscar;//'%'+sucursalSolicitado+' - '+servicioSolicitado+'%';
            List<AsesorxCalendario__c> asesoresPorCalendario = new List<AsesorxCalendario__c>();
            if(test.isRunningTest()){
                asesoresPorCalendario = [SELECT Asesor__c, Calendario__c, Service_Territory__c, Service_Territory__r.Name, Service_Territory__r.cita_sincronica__c FROM AsesorxCalendario__c 
                WHERE Service_Territory__r.Name LIKE: likeVariable  ];
            }else{
                asesoresPorCalendario = [SELECT Asesor__c, Calendario__c, Service_Territory__c, Service_Territory__r.Name, Service_Territory__r.cita_sincronica__c FROM AsesorxCalendario__c 
                                                                WHERE Service_Territory__r.Name LIKE: likeVariable AND (Asesor__r.Name like: asesorId OR Asesor__c = :asesorId) ];
            }
                                              
            // Integer cantidadAsesores = asesoresPorCalendario.size();
            Id serviceTerritoryId = asesoresPorCalendario[0].Service_Territory__c;                
            Boolean esSincro = asesoresPorCalendario[0].Service_Territory__r.cita_sincronica__c;

            System.debug('=====================duracionCita=====================');                    
            // Obtener la duracion de las citas
            Integer duracionCita = 0;
            Asset asset = [SELECT Id, Name, AccountId,Tipo_de_veh_culo__c FROM Asset WHERE Id =:cocheId ];

            if(kilometraje != '' && kilometraje != null && asset.Tipo_de_veh_culo__c != 'Automóvil'){
                duracionCita = obtenerDuracionCitaEnServiceTerritoryMotos(serviceTerritoryId,kilometraje);
            }else{
                duracionCita = obtenerDuracionCitaEnServiceTerritory(serviceTerritoryId);
            }

            System.debug(duracionCita);
            
            // Obtener el Asset relacionado
            System.debug(placaSolicitada);
            Account cuenta = [SELECT Id, Name FROM Account WHERE Id =:asset.AccountId ];

            List<Event_Shadow__c> eventosNuevos = new List<Event_Shadow__c>();
            // Crear evento ASESOR (Sucursal == Asesor)

            if(esSincro){
                duracionCita =  duracionCita -30;
                eventosNuevos.add( 
                            new Event_Shadow__c(
                                Activo__c = asset.Id,
                                OwnerId = asesoresPorCalendario[0].Asesor__c, //Sucursal
                                Asesor__c = asesoresPorCalendario[0].Asesor__c, //Asesor
                                OrigenEvento__c = origen,
                                ActivityDate__c = fechaHoraSolicitada,
                                StartDateTime__c = fechaHoraSolicitada,
                                EndDateTime__c = fechaHoraSolicitada.addMinutes(duracionCita),
                                Calendar__c =  userCalendario.Id,
                                Description2__c = comentarios ,
                                Subject__c = 'Evento Vehículo',
                                ignorarDuplicado__c = ignorarDuplicado,
                                Tipo_de_cita__c = 'Asesor') 
                            );
                
                // Crear evento SUCURSA (Sucursal == CALENDARIO)
                eventosNuevos.add(
                            new Event_Shadow__c(
                                Activo__c = asset.Id,
                                ActivityDate__c = fechaHoraSolicitada,
                                Calendar__c = userCalendario.Id,
                                OwnerId = userCalendario.Id, //Sucursal
                                Asesor__c = asesoresPorCalendario[0].Asesor__c, //Asesor
                                OrigenEvento__c = origen,
                                StartDateTime__c = fechaHoraSolicitada,
                                EndDateTime__c = fechaHoraSolicitada.addMinutes(duracionCita),
                                Description2__c = comentarios,
                                Subject__c = 'Evento Vehículo',
                                Kilometraje__c = kilometraje,
                                ignorarDuplicado__c = ignorarDuplicado,
                                Tipo_de_cita__c = 'Calendario' )
                            );

            }else{
                eventosNuevos.add( 
                    new Event_Shadow__c(
                        Activo__c = asset.Id,
                        OwnerId = asesoresPorCalendario[0].Asesor__c, //Sucursal
                        Asesor__c = asesoresPorCalendario[0].Asesor__c, //Asesor
                        OrigenEvento__c = origen,
                        ActivityDate__c = fechaHoraSolicitada,
                        StartDateTime__c = fechaHoraSolicitada,
                        EndDateTime__c = fechaHoraSolicitada.addMinutes(30),
                        Calendar__c =  userCalendario.Id,
                        Description2__c = comentarios ,
                        ignorarDuplicado__c = ignorarDuplicado,
                        Subject__c = 'Evento Vehículo',
                        Tipo_de_cita__c = 'Asesor') 
                    );
        
                // Crear evento SUCURSA (Sucursal == CALENDARIO)
                eventosNuevos.add(
                    new Event_Shadow__c(
                        Activo__c = asset.Id,
                        ActivityDate__c = fechaHoraSolicitada.addMinutes(30),
                        Calendar__c = userCalendario.Id,
                        OwnerId = userCalendario.Id, //Sucursal
                        Asesor__c = asesoresPorCalendario[0].Asesor__c, //Asesor
                        OrigenEvento__c = origen,
                        StartDateTime__c = fechaHoraSolicitada.addMinutes(30),
                        EndDateTime__c = fechaHoraSolicitada.addMinutes(duracionCita),
                        ignorarDuplicado__c = ignorarDuplicado,
                        Description2__c = comentarios,
                        Subject__c = 'Evento Vehículo',
                        Tipo_de_cita__c = 'Calendario' )
                    );
            }
            
            System.debug('====================eventosNuevos====================');
            System.debug(eventosNuevos);
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
            String recordCreado = '';
            for(Event_Shadow__c evS :eventosNuevos){
                if(evS.Tipo_de_cita__c == 'Calendario'){
                    recordCreado = evS.Id;
                }
            }
            
            return recordCreado;
    }

    public static Boolean updateEventOrigen (String idShadow,String origenCorrecto){
        List<Event> lstEvento = [Select Id,OrigenEvento__c From Event Where Event_Shadow__c = :idShadow];
        for(Event evento: lstEvento){
            if((evento.OrigenEvento__c != origenCorrecto && evento.OrigenEvento__c != 'twilio_wa' && evento.OrigenEvento__c != 'Contact Center' ) || (evento.OrigenEvento__c == 'Contact Center' && origenCorrecto == 'Whatsapp_EDNA' )){
                evento.OrigenEvento__c = origenCorrecto;
            }
            
        }
        update lstEvento;
        return true;
    }

    public static String getUrlEvent (String idShadow,String esteRecord,String origenCorrecto){
       
        List<Event> lstEvento = [SELECT Id, OrigenEvento__c, OwnerId, Asesor__c, Activo__c, StartDateTime, EndDateTime
                         FROM Event 
                         WHERE Event_Shadow__c = :idShadow  AND Owner.FirstName != 'Calendario'];
         
        for(Event evento: lstEvento){
            if((evento.OrigenEvento__c != origenCorrecto && evento.OrigenEvento__c != 'twilio_wa' && evento.OrigenEvento__c != 'Contact Center') || (evento.OrigenEvento__c == 'Contact Center' && origenCorrecto == 'Whatsapp_EDNA' ) ){
                evento.OrigenEvento__c = origenCorrecto;
            }
            
        }


        if (!lstEvento.isEmpty()) {
            Event firstEvent = lstEvento[0]; // Obtener el primer evento

            // Buscar eventos de 30 minutos que coincidan en Activo__c y StartDateTime pero tengan un OwnerId diferente
            List<Event> matchingEvents = [SELECT Id, OrigenEvento__c, OwnerId, Asesor__c, Activo__c, StartDateTime, EndDateTime
                                        FROM Event
                                        WHERE Activo__c = :firstEvent.Activo__c
                                        AND StartDateTime = :firstEvent.StartDateTime
                                        AND EndDateTime = :firstEvent.EndDateTime // 30 minutos
                                        AND OwnerId != :firstEvent.Asesor__c AND UpdateOrigin__c !=  'ReplicateEventFromCommunity'];

            // Aquí puedes hacer algo con matchingEvents, como imprimirlos o actualizar algún campo
            System.debug('Eventos coincidentes: ' + matchingEvents);
            if(matchingEvents.size()>0){
                delete matchingEvents;
            }
           
        }
        update lstEvento;

        String urlId = '';
        if(lstEvento.size()>0){
            urlId = lstEvento[0].Id;
            List<Event> lstEventoF = [Select Id, es_Reserva__c From Event Where Id =: esteRecord];
            if(lstEventoF.size()>0){
                try {
                    lstEventoF[0].es_Reserva__c = false;
                    update lstEventoF;
                } catch(DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }
            }
        }
        return urlId;
    }

    public static User getCurrentUser() {
        return [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
    }

    public static Boolean verifyContactData(String contactId, String accountId) {
        try {
            // Query Contact and Account records
            Contact contact = [SELECT Id, FirstName, LastName FROM Contact WHERE Id = :contactId LIMIT 1];
            Account account = [SELECT Id, Name, IsPersonAccount FROM Account WHERE Id = :accountId LIMIT 1];

            // Handle the case where FirstName is empty
            String contactFullName;
            if (String.isBlank(contact.FirstName)) {
                contactFullName = contact.LastName;
            } else {
                contactFullName = contact.FirstName + ' ' + contact.LastName;
            }

            // Compare the Account name with the Contact full name
            return account.Name == contactFullName;
        } catch (Exception e) {            
            throw new AuraHandledException(e.getMessage());
        }
    }




    public static User obtenerUsuarioCalendario(String sucursalBuscada){
        String likeVariable = '%'+sucursalBuscada+'%';        
        User usuarioCalendario = [SELECT Id, Cantidad_de_Mecanicos__c FROM User WHERE Name LIKE :likeVariable AND Name != 'Calendario Escazú - Mecánica Rápida 2' LIMIT 1];
        return usuarioCalendario;
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



    public static Integer obtenerDuracionCitaEnServiceTerritory(Id serviceTerritoryId){
        Hora_global__c horaGlobal = [SELECT Service_Territory__c, Tiempo_de_cita_2__c 
                                    FROM Hora_global__c 
                                    WHERE Service_Territory__c = :serviceTerritoryId LIMIT 1];
        Integer duracionCita = 30 + Integer.valueOf(horaGlobal.Tiempo_de_cita_2__c);
        System.debug('Duracion de la cita ==' + duracionCita);
        return duracionCita;
    }






    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }


    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';

    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }


    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }

    public static List<Campa_a_t_cnica__c> getCampaniasByAssetId(String assetId) {
        if (String.isBlank(assetId)) {
            throw new AuraHandledException('Debe proporcionar un AssetId');
        }
        
        return [SELECT Active__c, Categoria__c, 
                Confirmaci_n_de_lectura__c, 
                Confirmado_por__c, Name,
                Descripcion__c
                FROM Campa_a_t_cnica__c 
                WHERE Asset__c = :assetId 
                AND Active__c = true]; 
    }

    public static void confirmarCampanias(String assetId) {
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        List<Campa_a_t_cnica__c> campanias = [
            SELECT Id 
            FROM Campa_a_t_cnica__c 
            WHERE Asset__c = :assetId 
            AND Active__c = true
        ];

        for(Campa_a_t_cnica__c camp : campanias) {
            camp.Confirmaci_n_de_lectura__c = true;
            camp.Confirmado_por__c = currentUser.Id;
        }

        update campanias;
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
