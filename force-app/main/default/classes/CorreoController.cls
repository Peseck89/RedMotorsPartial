public with sharing class CorreoController {
    
    
    @AuraEnabled(cacheable=false)
    public static List<Correo__c> obtenerCorreos(Id accountId) {
        return [
            SELECT Id, Name, Activo__c, Principal__c, Tipo_de_datos_de_comunicaci_n__c, Tipo_de_datos_de_comunicaci_n__r.Name
            FROM Correo__c
            WHERE Account__c = :accountId Or Contact__c = :accountId
            ORDER BY CreatedDate DESC
        ];
    }

    @AuraEnabled
    public static void guardarCorreo(Correo__c correo) {
        if (correo == null) {
            throw new AuraHandledException('Los datos del correo no pueden estar vacíos.');
        }

        if (String.isBlank(correo.Name)) {
            throw new AuraHandledException('El campo Correo es obligatorio.');
        }

        // Bloquear correos prohibidos o dominios no permitidos
        String correoLower = correo.Name != null ? correo.Name.toLowerCase().trim() : '';
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

        if (correo.Account__c == null) {
            throw new AuraHandledException('El correo debe estar relacionado a una cuenta.');
        }

        // Verificar duplicado en otros Correo__c
        List<Correo__c> correosExistentes = [
            SELECT Id,Account__r.Name FROM Correo__c
            WHERE Name = :correo.Name
            AND Id != :correo.Id
            LIMIT 1
        ];
        if (!correosExistentes.isEmpty()) {
            throw new AuraHandledException('Este correo ya está registrado en otra cuenta ' + correosExistentes[0].Account__r.Name + ' - ' + correosExistentes[0].Id + ' .');
        }


        
        Account cuenta = new Account();
        // Consultar cuenta para saber si es personal o jurídica
        
        List<Account> lstAccount = [Select Id from Account Where id =:correo.Account__c];
        if(lstAccount.size()>0){
            cuenta = [
                SELECT Id, IsPersonAccount, PersonEmail, CorreoElectronicoEmpresarial__c
                FROM Account
                WHERE Id = :correo.Account__c
                LIMIT 1
            ];
        }else{
            List<Contacto_por_cuenta__c> lstContact = [Select Id,Account__c,Contact__c from Contacto_por_cuenta__c Where Contact__c =:correo.Account__c ];
            correo.Account__c = null;
            correo.Contact__c = lstContact[0].Contact__c;
        }

        Boolean correoYaExisteEnCuenta = false;
        if (cuenta.IsPersonAccount && cuenta.PersonEmail == correo.Name) {
            correoYaExisteEnCuenta = true;
        }
        if (!cuenta.IsPersonAccount && cuenta.CorreoElectronicoEmpresarial__c == correo.Name) {
            correoYaExisteEnCuenta = true;
        }

        if (correoYaExisteEnCuenta) {
            throw new AuraHandledException('El correo ya está asignado a otro cliente.');
        }

        
        
        // Buscar otros correos en la cuenta
        List<Correo__c> otrosCorreos = [
            SELECT Id FROM Correo__c
            WHERE Account__c = :correo.Account__c 
        ];

        if (otrosCorreos.isEmpty()) {
            correo.Principal__c = true;
        }
        
        if (correo.Id == null) {
            insert correo;
        } else {
            update correo;
        }

        // Si es principal, desmarcar los demás
        if (correo.Principal__c == true) {
            List<Correo__c> otrosPrincipales = [
                SELECT Id FROM Correo__c
                WHERE Account__c = :correo.Account__c
                AND Id != :correo.Id
                AND Principal__c = true
            ];
            for (Correo__c c : otrosPrincipales) {
                c.Principal__c = false;
            }
            if (!otrosPrincipales.isEmpty()) {
                update otrosPrincipales;
            }
        }
    }



    @AuraEnabled
    public static void eliminarCorreo(Id correoId) {
        delete [SELECT Id FROM Correo__c WHERE Id = :correoId];
    }

    @AuraEnabled(cacheable=false)
    public static List<Tipo_de_datos_de_comunicaci_n__c> obtenerTiposDatosComunicacion(Id accountId) {

        if (accountId == null) {
            throw new AuraHandledException('Debe enviar el Id de la cuenta.');
        }

        
        List<Account> lstAcc = [
            SELECT Id
            FROM   Account
            WHERE  Id = :accountId
        ];
        if(lstAcc.isEmpty()){
            List<Contacto_por_cuenta__c> lstContact = [Select Id,Account__c from Contacto_por_cuenta__c Where Contact__c =:accountId ];
            accountId = lstContact[0].Account__c;
        }
        //-- Obtenemos el tipo de cuenta a partir del Record Type
        Account acc = [
            SELECT RecordType.Name
            FROM   Account
            WHERE  Id = :accountId
            LIMIT  1
        ];
        String tipoCuenta = acc.RecordType.Name;         // «Cuenta personal» / «Cuenta empresarial»
        if(tipoCuenta == 'Cliente Jurídico' || tipoCuenta == 'Cuenta empresarial' ){
            tipoCuenta = 'Cuenta empresarial';
        }else{
            tipoCuenta = 'Cuenta personal';
        }
        return [
            SELECT Id, Name
            FROM   Tipo_de_datos_de_comunicaci_n__c
            WHERE  Correo_Electrenico__c = TRUE
                   AND Tipo_de_cuenta__c = :tipoCuenta
            ORDER  BY Name
        ];
    }
}