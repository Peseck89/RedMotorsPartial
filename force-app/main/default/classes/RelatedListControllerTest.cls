/******************************************************************************************************************
Nombre de la Clase Apex: RelatedListControllerTest
Versión : 1.0
Fecha de Creación : 09/10/2025
Funcionalidad : 
Clase de Prueba: 
Historial de Modificaciones:
-------------------------------------------------------------------------------------------------------------------
* Desarrollador        - Fecha –        Descripción
* ------------------------------------------------------------------------------------------------------------------
* Kevn Garcia       09/10/2025       Versión original
*-------------------------------------------------------------------------------------------------------------------
*********************************************************************************************************************/
@isTest
private class RelatedListControllerTest {

    @isTest
    static void tstRealted() {
        Id mlRT = Schema.SObjectType.Tecnico__c.getRecordTypeInfosByDeveloperName().get('MecanicoLider').getRecordTypeId();
        Id tecRT = Schema.SObjectType.Tecnico__c.getRecordTypeInfosByDeveloperName().get('Tecnico').getRecordTypeId();


        Tecnico__c ml = new Tecnico__c(
            Name = 'kevin',
            RecordTypeId = mlRT
        );
        insert ml;

        Tecnico__c tec = new Tecnico__c(
            Name = 'cesar',
            RecordTypeId = tecRT,
            MecanicoLider__c = ml.Id
        );
        insert tec;

        Test.startTest();
            RelatedListController.getRecords('500Nq00000QvRiWIAV','NotaTecnica__c','Name');
            RelatedListController.getUserInfo();
            RelatedListController.getMecLider(tec.Id);
        Test.stopTest();

    }
}