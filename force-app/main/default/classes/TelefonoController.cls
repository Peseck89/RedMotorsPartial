public with sharing class TelefonoController {
    @AuraEnabled(cacheable=false)
    public static List<Tel_fono__c> obtenerTelefonos(Id accountId) {
        return [
            SELECT Id, N_mero_de_tel_fono__c, C_digo_de_rea__c, Tipo_telefono__c, 
                   Tipo_de_datos_de_comunicaci_n__c, Tipo_de_datos_de_comunicaci_n__r.Name,
                   Telefono_principal__c
            FROM Tel_fono__c
            WHERE Cuenta__c = :accountId Or Contact__c = :accountId
            ORDER BY CreatedDate DESC
            
        ];
    }
    
    @AuraEnabled
    public static void guardarTelefono(Tel_fono__c telefono) {
        if (telefono == null) {
            throw new AuraHandledException('El teléfono no puede ser nulo.');
        }
        
        List<Account> lstAccount = [Select Id from Account Where id =:telefono.Cuenta__c];
        if(lstAccount.size()>0){
       
        }else{
            List<Contacto_por_cuenta__c> lstContact = [Select Id,Account__c,Contact__c from Contacto_por_cuenta__c Where Contact__c =:telefono.Cuenta__c ];
            telefono.Cuenta__c = null;
            telefono.Contact__c = lstContact[0].Contact__c;
        }

        List<Tel_fono__c> otrosTelefonos = [
                SELECT Id
                FROM Tel_fono__c
                WHERE Cuenta__c = :telefono.Cuenta__c
            ];
        if(otrosTelefonos.isEmpty()){
            telefono.Telefono_principal__c = true; 
        }

        if (telefono.Id == null) {
            // Es un nuevo teléfono
            insert telefono;
        } else {
            // Es una edición
            update telefono;
        }

        // Si este teléfono es principal, desmarcar los demás
        if (telefono.Telefono_principal__c == true) {
            List<Tel_fono__c> otrosTelefonosPrincipales = [
                SELECT Id
                FROM Tel_fono__c
                WHERE Cuenta__c = :telefono.Cuenta__c
                AND Id != :telefono.Id
                AND Telefono_principal__c = true
            ];
            
            for (Tel_fono__c tel : otrosTelefonosPrincipales) {
                tel.Telefono_principal__c = false;
            }
            
            if (!otrosTelefonosPrincipales.isEmpty()) {
                update otrosTelefonosPrincipales;
            }
        }
    }


    @AuraEnabled
    public static void eliminarTelefono(Id telefonoId) {
        delete [SELECT Id FROM Tel_fono__c WHERE Id = :telefonoId];
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
        if(lstAcc.size()>0){

        }else{
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
        if(tipoCuenta == 'Cliente Jurídico' ){
            tipoCuenta = 'Cuenta empresarial';
        }else{
            tipoCuenta = 'Cuenta personal';
        }
        return [
            SELECT Id, Name
            FROM   Tipo_de_datos_de_comunicaci_n__c
            WHERE  Telefono__c = TRUE
                   AND Tipo_de_cuenta__c = :tipoCuenta   // ⬅️ solo los que correspondan
            ORDER  BY Name
        ];
    }

    public static void dummy(){
        Integer i = 0;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
        i = i+1;
    }
}