public with sharing class DireccionController {
    
    @AuraEnabled(cacheable=false)
    public static List<Direccion__c> obtenerDirecciones(Id accountId) {
        return [
            SELECT Id, Direccion__c, Provincia__r.Name, Provincia__c, 
                   Canton__r.Name, Canton__c, Distrito__r.Name, Distrito__c,
                   Direccion_principal__c, Tipo_de_direcci_n__c, Tipo_de_direcci_n__r.Name
            FROM Direccion__c
            WHERE Cuenta__c = :accountId
            ORDER BY CreatedDate DESC
        ];
    }
    
    @AuraEnabled
    public static Direccion__c guardarDireccion(Direccion__c direccion) {

        List<Direccion__c> otrasDirecciones = [
            SELECT Id
            FROM Direccion__c
            WHERE Cuenta__c = :direccion.Cuenta__c
        ];
    
        if (otrasDirecciones.isEmpty()) {
            direccion.Direccion_principal__c = true;
        }

        if (direccion.Id == null) {
            insert direccion;
        } else {
            update direccion;
        }

        // Si la dirección es principal, desmarcar las otras
        if (direccion.Direccion_principal__c == true) {
            List<Direccion__c> otrasDireccionesPrincipales = [
                SELECT Id
                FROM Direccion__c
                WHERE Cuenta__c = :direccion.Cuenta__c
                AND Id != :direccion.Id
                AND Direccion_principal__c = true
            ];

            for (Direccion__c d : otrasDireccionesPrincipales) {
                d.Direccion_principal__c = false;
            }

            if (!otrasDireccionesPrincipales.isEmpty()) {
                update otrasDireccionesPrincipales;
            }
        }

        return direccion;
    }

    @AuraEnabled
    public static void eliminarDireccion(Id direccionId) {
        delete [SELECT Id FROM Direccion__c WHERE Id = :direccionId];
    }

    @AuraEnabled(cacheable=true)
    public static List<Provincia__c> obtenerProvincias() {
        return [SELECT Id, Name FROM Provincia__c ORDER BY Name];
    }

    @AuraEnabled(cacheable=true)
    public static List<Canton__c> obtenerCantones() {
        return [
            SELECT Id, Name
            FROM Canton__c
            ORDER BY Name
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Distrito__c> obtenerDistritos() {
        return [SELECT Id, Name FROM Distrito__c ORDER BY Name];
    }

    @AuraEnabled(cacheable=true)
    public static List<Canton__c> obtenerCantonesPorProvincia(Id provinciaId) {
        return [
            SELECT Id, Name
            FROM Canton__c
            WHERE Provincia__c = :provinciaId
            ORDER BY Name
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Distrito__c> obtenerDistritosPorCanton(Id cantonId) {
        return [
            SELECT Id, Name
            FROM Distrito__c
            WHERE Canton__c = :cantonId
            ORDER BY Name
        ];
    }

    @AuraEnabled(cacheable=false)
    public static List<Tipo_de_datos_de_comunicaci_n__c> obtenerTiposDatosComunicacion(Id accountId) {
        return ContactDataChannelService.obtenerTiposDatosComunicacion(
            accountId,
            'ADDRESS',
            true
        );
    }

}
