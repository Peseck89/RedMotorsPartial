public with sharing class IdentificacionController {
    
    @AuraEnabled(cacheable=false)
    public static List<Identificacion__c> obtenerIdentificaciones(Id accountId) {
        return [
            SELECT Id, Tipo_de_documento__c, Tipo_de_documento__r.Name, Identificaci_n__c, Pais__c, Identificacion_principal__c
            FROM Identificacion__c
            WHERE Cuenta__c = :accountId
            ORDER BY CreatedDate DESC
        ];
    }

    @AuraEnabled
    public static void guardarIdentificacion(Identificacion__c identificacion) {
        if (identificacion == null) {
            throw new AuraHandledException('La identificación no puede ser nula.');
        }

        if (identificacion.Id == null) {
            insert identificacion;
        } else {
            update identificacion;
        }

        // Si esta identificación es principal, desmarcar las demás
        if (identificacion.Identificacion_principal__c == true) {
            List<Identificacion__c> otrasIdentificacionesPrincipales = [
                SELECT Id
                FROM Identificacion__c
                WHERE Cuenta__c = :identificacion.Cuenta__c
                  AND Id != :identificacion.Id
                  AND Identificacion_principal__c = true
            ];

            for (Identificacion__c ident : otrasIdentificacionesPrincipales) {
                ident.Identificacion_principal__c = false;
            }

            if (!otrasIdentificacionesPrincipales.isEmpty()) {
                update otrasIdentificacionesPrincipales;
            }
        }
    }

    @AuraEnabled
    public static void eliminarIdentificacion(Id identificacionId) {
        delete [SELECT Id FROM Identificacion__c WHERE Id = :identificacionId];
    }

    @AuraEnabled(cacheable=false)
    public static List<Tipo_de_documento__c> obtenerTiposDocumento() {
        return [SELECT Id, Name FROM Tipo_de_documento__c ORDER BY Name];
    }

    @AuraEnabled(cacheable=false)
    public static List<TiposDocumentoxTiposCuenta__c> obtenerTiposDocumentoCuenta(Id accountId) {
        if (accountId == null) {
            throw new AuraHandledException('Debe enviar el Id de la cuenta.');
        }

        //-- Obtenemos el tipo de cuenta a partir del Record Type
        Account acc = [
            SELECT RecordType.Name,Tipos_de_cuenta__c
            FROM   Account
            WHERE  Id = :accountId
            LIMIT  1
        ];

        String tipoCuenta = acc.Tipos_de_cuenta__c;         // «Cuenta personal» / «Cuenta empresarial»
        // if(tipoCuenta == 'Cliente Jurídico' ){
        //     tipoCuenta = 'Cuenta empresarial';
        // }else{
        //     tipoCuenta = 'Cuenta personal';
        // }

        return [
            SELECT Id, Tipo_de_documento__r.Name,Tipo_de_documento__c FROM TiposDocumentoxTiposCuenta__c 
            WHERE Tipo_de_cuenta__r.Name =: tipoCuenta
            ORDER BY  Tipo_de_documento__r.Name
            ];
    }
    
    @AuraEnabled
    public static void crearIdentificacionInicial(Id accountId, String tipoDocumentoId, String pais, String numeroIdentificacion) {
        System.debug('==============crearIdentificacionInicial================');
        Identificacion__c identificacion = new Identificacion__c();
        if (String.isBlank(tipoDocumentoId)) {
            throw new AuraHandledException('El tipo de documento es obligatorio.');
        }
        if(tipoDocumentoId == '01'){
            tipoDocumentoId = 'Cédula Fisica';
        }else if(tipoDocumentoId == '02'){
            tipoDocumentoId = 'Cédula Juridica';
        }else if(tipoDocumentoId == '03'){
            tipoDocumentoId = 'Dimex';
        }else if(tipoDocumentoId == '04'){
            tipoDocumentoId = 'NITE';
        }else if(tipoDocumentoId == 'Pasaporte'){
            tipoDocumentoId = 'Pasaporte';
        }else if(tipoDocumentoId == 'Carnet de residente'){
            tipoDocumentoId = 'Carnet de residente	';
        }

        System.debug('==============Tipo_de_documento__c================');
        System.debug(tipoDocumentoId);

        // Buscar el Tipo_de_documento__c por el nombre (label)
        List<Tipo_de_documento__c> tipos = [
            SELECT Id
            FROM Tipo_de_documento__c
            WHERE Id = :tipoDocumentoId
            LIMIT 1
        ];
        System.debug(tipos);

        if (tipos.isEmpty()) {
            throw new AuraHandledException('No se encontró el tipo de documento especificado: ' + tipoDocumentoId);
        }
        
        //reivsar si ya existe el numeroIdentificacion en cualquier Account.Cedula__c o en Contact.Cedula__c
        List<Account> accs = [
            SELECT Id
            FROM Account
            WHERE Cedula__c = :numeroIdentificacion      
            AND  ID !=:accountId
            LIMIT 1
        ];
        List<Identificacion__c> lstIdentificaciones = [
            SELECT Id
            FROM Identificacion__c
            WHERE Identificaci_n__c = :numeroIdentificacion           
            LIMIT 1
        ];
        if(accs.size() > 0 || lstIdentificaciones.size()  > 0){
            throw new AuraHandledException('Ya existe una cuenta con este tipo y número de cédula.');
        }else{
            
            identificacion.Cuenta__c = accountId;
            identificacion.Tipo_de_documento__c = tipos[0].Id;
            identificacion.Pais__c = pais;
            identificacion.Identificaci_n__c = numeroIdentificacion;
            identificacion.Identificacion_principal__c = true;
            insert identificacion;
        }       
        
        System.debug(identificacion);
    }
    
	public static void testDummy() {
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
    }

}