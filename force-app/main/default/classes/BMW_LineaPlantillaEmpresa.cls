public with sharing class BMW_LineaPlantillaEmpresa {
    @AuraEnabled(cacheable=true)
    public static String getEmpresa(Id IdPlantilla) {
        if (IdPlantilla == null) {
            throw new EmpresaConfigurationException(
                'El Id de la plantilla de presupuesto es requerido.'
            );
        }

        List<Plantilla_de_Presupuesto__c> plantillas = [
            SELECT Id, BMW_Compania__c, Empresa_Operadora__c
            FROM Plantilla_de_Presupuesto__c
            WHERE Id = :IdPlantilla
            LIMIT 1
        ];
        if (plantillas.isEmpty()) {
            throw new EmpresaConfigurationException(
                'No existe la plantilla de presupuesto solicitada.'
            );
        }

        Plantilla_de_Presupuesto__c plantilla = plantillas[0];
        if (plantilla.Empresa_Operadora__c != null) {
            return EmpresaResolver.resolve(plantilla.Empresa_Operadora__c).codigo;
        }

        if (plantilla.BMW_Compania__c == 'Bavarian') {
            return 'RMBAVARIAN';
        }
        if (plantilla.BMW_Compania__c == 'Otobai') {
            return 'RMOTOBAI';
        }
        if (String.isBlank(plantilla.BMW_Compania__c)) {
            throw new EmpresaConfigurationException(
                'La plantilla no tiene una Empresa configurada.'
            );
        }
        throw new EmpresaConfigurationException(
            'La compañía heredada ' + plantilla.BMW_Compania__c + ' no está configurada.'
        );
    }
}
