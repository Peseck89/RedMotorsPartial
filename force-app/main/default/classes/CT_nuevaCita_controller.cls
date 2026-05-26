public with sharing class CT_nuevaCita_controller {

    @AuraEnabled(Cacheable = true)
    public static Boolean getKilometros(String cocheId, String cocheVin, Decimal kilometros) {
        return CT_nuevaCita_Base.getKilometros(cocheId, cocheVin, kilometros);
    }

    @AuraEnabled(Cacheable = true)
    public static List<Event> getActives(String recordId) {
        List<Event> lstEvents = [Select Id,StartDateTimeF__c,idCalendarioFlow__c,Asesor__c,Asesor__r.Name,Activo__c,Activo__r.numeroDePlaca__c,StartDateTime,OwnerId,Description,ServiceTerritory__c,ServiceTerritory__r.Name,OrigenEvento__c From Event Where Id =: recordId];
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
        List<Account> lstCuenta = [Select Id,Name,PersonEmail,PersonContactId,PersonContact.FirstName,PersonContact.Name,PersonContact.LastName,PersonContact.phone,PersonContact.email,CorreoElectronicoEmpresarial__c,Phone,codigoSoftland__c,Cedula__c,Tipo_de_Documento__c,Tipos_de_cuenta__c From Account Where Id =:cuentaId ];
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
