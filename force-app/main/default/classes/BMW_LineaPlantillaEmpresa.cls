public with sharing class BMW_LineaPlantillaEmpresa {
    @AuraEnabled(cacheable=true)
    public static String getEmpresa(Id IdPlantilla) {
        Plantilla_de_Presupuesto__c plantilla = [Select Id, BMW_Compania__c 
                                                From Plantilla_de_Presupuesto__c
                                                Where Id=: IdPlantilla];
        String Empresa;
        if(plantilla.BMW_Compania__c == 'Bavarian'){
            Empresa = 'RMBAVARIAN';
        }else{
            Empresa = 'RMOTOBAI';
        }
        return Empresa;
    }
}