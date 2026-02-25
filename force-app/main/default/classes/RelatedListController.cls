/******************************************************************************************************************
Nombre de la Clase Apex: RelatedListController
Versión : 1.0
Fecha de Creación : 09/10/2025
Funcionalidad : 
Clase de Prueba: RelatedListControllerTest
Historial de Modificaciones:
-------------------------------------------------------------------------------------------------------------------
* Desarrollador        - Fecha –        Descripción
* ------------------------------------------------------------------------------------------------------------------
* Kevn Garcia       09/10/2025       Versión original
*-------------------------------------------------------------------------------------------------------------------
*********************************************************************************************************************/
public with sharing class RelatedListController {
    @AuraEnabled(cacheable=true)
    public static List<sObject> getRecords(Id parentId, String objectApi, String fields) {
        String query = 'SELECT Id,' + fields + ' ,Presupuesto__c, Case__r.OwnerId FROM ' + objectApi +
                       ' WHERE ' + getLookupField(objectApi) + ' = :parentId';
        return Database.query(query);
    }
    private static String getLookupField(String objectApi) {
        // Personaliza para diferentes objetos
        if(objectApi == 'NotaTecnica__c') return 'Case__c';
        return null;
    }

    @AuraEnabled(cacheable=true)
    public static User getUserInfo() {
        
        
        return [Select Id,Email, Profile.Name, PN_EsMecanicoLider__c, PN_EsSupervisorNT__c from User where Id=: UserInfo.getUserId()];
    }

    @AuraEnabled(cacheable=false)
    public static String getMecLider(String idTecnico) {
        system.debug('--RelatedListController.getMecLider-- idTecnico: ' + idTecnico);

        String ML = [Select MecanicoLider__r.Name from Tecnico__c where Id=:idTecnico].MecanicoLider__r.Name;

        system.debug('--RelatedListController.getMecLider-- ML: ' + ML);

        return ML;
    }
}