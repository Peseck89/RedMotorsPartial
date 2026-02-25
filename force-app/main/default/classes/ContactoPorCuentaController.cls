public with sharing class ContactoPorCuentaController {

    public class WrapperContacto {
        @AuraEnabled public String nombreContacto;
        @AuraEnabled public Id tipoContactoId;
        @AuraEnabled public Boolean esPrimario;
        @AuraEnabled public Id accountId;
        @AuraEnabled public Id contactoId;
        @AuraEnabled public Id relacionId;
        @AuraEnabled public String correo;
        @AuraEnabled public String codigoArea;
        @AuraEnabled public String telefono;

        // CAMPOS ADICIONALES:
        @AuraEnabled public Id tipoDatoCorreoId;         // Tipo_de_datos_de_comunicaci_n__c
        @AuraEnabled public Id tipoDatoTelefonoId;       // Tipo_de_datos_de_comunicaci_n_tel_fono__c
        @AuraEnabled public String tipoTelefono;         // Tipo_telefono__c
    }

    @AuraEnabled
    public static Id guardarContactoPorCuenta(Map<String, Object> data) {
        String nombreContacto = (String)data.get('nombreContacto');
        Id tipoContactoId = (Id)data.get('tipoContactoId');
        Boolean esPrimario = (Boolean)data.get('esPrimario');
        Id accountId = (Id)data.get('accountId');
        Id contactoId = (Id)data.get('contactoId');
        Id relacionId = (Id)data.get('relacionId');
        String correo = (String)data.get('correo');
        String codigoArea = (String)data.get('codigoArea');
        Id tipoDatoCorreoId = (Id)data.get('tipoDatoCorreoId');
        Id tipoDatoTelefonoId = (Id)data.get('tipoDatoTelefonoId');
        String tipoTelefono = (String)data.get('tipoTelefono');

        Object telefonoRaw = data.get('telefono');
        Decimal telefono = null;

        if (telefonoRaw != null) {
            if (telefonoRaw instanceof String) {
                telefono = Decimal.valueOf((String)telefonoRaw);
            } else if (telefonoRaw instanceof Decimal) {
                telefono = (Decimal)telefonoRaw;
            } else {
                throw new AuraHandledException('El campo teléfono tiene un tipo no soportado.');
            }
        }

        if (!String.isBlank(correo)) {
            String correoLower = correo.toLowerCase().trim();
            String dominio = correoLower.contains('@') ? correoLower.split('@')[1] : '';

            // Validar contra tabla de correos bloqueados
            List<Mantenimientos_de_email__c> bloqueados = [
                SELECT Id,Email_Bloqueado__c
                FROM Mantenimientos_de_email__c                        
            ];

            // validar Email_Temporal__mdt
            List<Email_Temporal__mdt> dominiosT = [
                SELECT MasterLabel
                FROM Email_Temporal__mdt            
            ];

            // Validar contra correos bloqueados
            Set<String> bloqueadosSet = new Set<String>();
            for (Mantenimientos_de_email__c b : bloqueados) {
                bloqueadosSet.add(b.Email_Bloqueado__c != null ? b.Email_Bloqueado__c.toLowerCase().trim() : '');
            }
            if (bloqueadosSet.contains(correoLower)) {
                throw new AuraHandledException('El correo '+ correoLower + 'tiene un formato de correo temporal, por favor ingrese uno permanente.');
            }
            // Validar contra correos temporales
            Set<String> temporalesSet = new Set<String>();
            for (Email_Temporal__mdt t : dominiosT) {
                temporalesSet.add(t.MasterLabel != null ? t.MasterLabel.toLowerCase().trim() : '');
            }
            if (temporalesSet.contains(correoLower)) {
                throw new AuraHandledException('El correo '+ correoLower + ' es genérico, ingrese uno real.');
            }


            // Validar contra metadatos de dominio no aceptado
            List<Dominio_no_aceptado__mdt> dominios = [
                SELECT DeveloperName
                FROM Dominio_no_aceptado__mdt
                WHERE DeveloperName = :dominio
                LIMIT 1
            ];

            

            if (!dominios.isEmpty()) {
                throw new AuraHandledException('El correo posee un dominio incorrecto');
            }
        }else{
            throw new AuraHandledException('Debe llenar el campo de correo electrónico.');
        }
        

        if (String.isBlank(nombreContacto) || tipoContactoId == null || accountId == null) {
            throw new AuraHandledException('Todos los campos son obligatorios.');
        }

        Contact c;
        if (contactoId == null) {
            c = new Contact(LastName = nombreContacto, Email = correo, Phone = codigoArea + telefono);
            insert c;
        } else {
            c = [SELECT Id, LastName FROM Contact WHERE Id = :contactoId];
            c.LastName = nombreContacto;
            update c;
        }

        // Quitar primario a otros si esPrimario = true
        if (esPrimario) {
            List<Contacto_por_cuenta__c> existentes = [
                SELECT Id FROM Contacto_por_cuenta__c
                WHERE Account__c = :accountId
                AND Es_primario__c = true
                AND Id != :relacionId
            ];
            for (Contacto_por_cuenta__c cpc : existentes) {
                cpc.Es_primario__c = false;
            }
            if (!existentes.isEmpty()) {
                update existentes;
            }
        }

        if (relacionId == null) {
            insert new Contacto_por_cuenta__c(
                Account__c = accountId,
                Contact__c = c.Id,
                Tipo_de_contacto__c = tipoContactoId,
                Es_primario__c = esPrimario,
                Correo__c = correo,
                C_digo_de_rea__c = codigoArea,
                Tel_fono__c = telefono,
                Tipo_de_datos_de_comunicaci_n__c = tipoDatoCorreoId,
                Tipo_de_datos_de_comunicaci_n_tel_fono__c = tipoDatoTelefonoId,
                Tipo_tel_fono__c = tipoTelefono
            );

            if (correo == null) {
                throw new AuraHandledException('Los datos del correo no pueden estar vacíos.');
            }
    
            if (String.isBlank(correo)) {
                throw new AuraHandledException('El campo Correo es obligatorio.');
            }
    
            // Bloquear correos prohibidos o dominios no permitidos
            String correoLower = correo != null ? correo.toLowerCase().trim() : '';
            if (correoLower == '') {
                throw new AuraHandledException('El correo es obligatorio.');
            }
    
            // Validar contra Mantenimientos_de_email__c
            Set<String> blacklist = new Set<String>();
            for (Mantenimientos_de_email__c b : [SELECT Email_Bloqueado__c FROM Mantenimientos_de_email__c]) {
                blacklist.add(b.Email_Bloqueado__c?.toLowerCase());
            }
            if (blacklist.contains(correoLower)) {
                throw new AuraHandledException('El correo '+ correoLower + ' es genérico, ingrese uno real.');
            }
    
            // Validar contra Dominio_no_aceptado__mdt
            if (correoLower.contains('@')) {
                String dominio = correoLower.substringAfter('@');
                Set<String> dominiosBloqueados = new Set<String>();
                Set<String> dominiosTemporales = new Set<String>();
                for (Dominio_no_aceptado__mdt d : [SELECT DeveloperName FROM Dominio_no_aceptado__mdt]) {
                    dominiosBloqueados.add(d.DeveloperName.toLowerCase());
                }
                if (dominiosBloqueados.contains(dominio)) {
                    throw new AuraHandledException('El correo posee un dominio incorrecto');
                }
    
                for (Email_Temporal__mdt d : [SELECT MasterLabel FROM Email_Temporal__mdt]) {
                    dominiosTemporales.add(d.MasterLabel.toLowerCase());
                }
                if (dominiosTemporales.contains(dominio)) {
                    throw new AuraHandledException('El correo tiene un formato de correo temporal, por favor ingrese uno permanente.');
                }
            }

            Correo__c primerCorreo = new Correo__c();
            primerCorreo.Activo__c = true;
            primerCorreo.Name = correo;
            primerCorreo.Contact__c = c.Id;
            primerCorreo.Principal__c = true;
            primerCorreo.Tipo_de_datos_de_comunicaci_n__c = tipoDatoCorreoId;
            if(!Test.isRunningTest()){
                insert primerCorreo;
            }
            
            
            Tel_fono__c primerTelefono = new Tel_fono__c();
            primerTelefono.Telefono_principal__c = true;
            primerTelefono.N_mero_de_tel_fono__c =  String.valueOf(telefono);
            primerTelefono.C_digo_de_rea__c = codigoArea;
            primerTelefono.Tipo_de_datos_de_comunicaci_n__c = tipoDatoTelefonoId;
            primerTelefono.Tipo_telefono__c = tipoTelefono;
            primerTelefono.Contact__c = c.Id;
            if(!Test.isRunningTest()){
                Insert primerTelefono;
            }
            
        } else {
            Contacto_por_cuenta__c rel = [SELECT Id FROM Contacto_por_cuenta__c WHERE Id = :relacionId];
            rel.Tipo_de_contacto__c = tipoContactoId;
            rel.Es_primario__c = esPrimario;
            rel.Correo__c = correo;
            rel.C_digo_de_rea__c = codigoArea;
            rel.Tel_fono__c = telefono;
            rel.Tipo_de_datos_de_comunicaci_n__c = tipoDatoCorreoId;
            rel.Tipo_de_datos_de_comunicaci_n_tel_fono__c = tipoDatoTelefonoId;
            rel.Tipo_tel_fono__c = tipoTelefono;
            update rel;
        }
        return c.Id; 
    }

    @AuraEnabled
    public static void eliminarContactoPorCuenta(Id relacionId) {
        delete [SELECT Id FROM Contacto_por_cuenta__c WHERE Id = :relacionId];
    }

    @AuraEnabled(cacheable=false)
    public static List<Contacto_por_cuenta__c> obtenerContactos(Id accountId) {
        return [
            SELECT Id, Contact__r.Name, Contact__c, Tipo_de_contacto__r.Name, Tipo_de_contacto__c, Es_primario__c,
                   Correo__c, C_digo_de_rea__c, Tel_fono__c,Tipo_tel_fono__c,Tipo_de_datos_de_comunicaci_n_tel_fono__r.Name,
                   Tipo_de_datos_de_comunicaci_n__r.Name
            FROM Contacto_por_cuenta__c
            WHERE Account__c = :accountId
            ORDER BY CreatedDate DESC
        ];
    }

    @AuraEnabled(cacheable=false)
    public static List<Tipo_de_contacto__c> obtenerTiposContacto() {
        return [SELECT Id, Name FROM Tipo_de_contacto__c ORDER BY Name];
    }

    @AuraEnabled
    public static Boolean verificarCorreoExistente(String correo, Id accountId, Id contactoId) {
        String correoLower = correo?.trim().toLowerCase();
        if (String.isBlank(correoLower)) return false;

        // Buscar en cuentas distintas
        List<Account> cuentas = [
            SELECT Id FROM Account
            WHERE (PersonEmail = :correoLower OR CorreoElectronicoEmpresarial__c = :correoLower)
            AND Id != :accountId
            LIMIT 1
        ];
        if (!cuentas.isEmpty()) return true;

        // Buscar en contactos distintos
        List<Contact> contactos = (contactoId == null) ? [
            SELECT Id FROM Contact
            WHERE Email = :correoLower
            LIMIT 1
        ] : [
            SELECT Id FROM Contact
            WHERE Email = :correoLower AND Id != :contactoId
            LIMIT 1
        ];
        return !contactos.isEmpty();
    }

}