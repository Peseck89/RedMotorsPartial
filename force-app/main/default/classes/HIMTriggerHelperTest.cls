/**
 * @description       : 
 * @author            : Marco Hernandez
 * @group             : Redmotors
 * @last modified on  : 10-28-2022
 * @last modified by  : marcohernandezhp@gmail.com
**/
@IsTest
public class HIMTriggerHelperTest {

    @IsTest
    public static void unitTestCreateTaskDaily(){
        tiposDeTrabajo__c newTT = new tiposDeTrabajo__c(
            Name = 'test tt'
        );
        insert newTT;

        Id devRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacto de Taller').getRecordTypeId();

        Contact newContact = new Contact(
            LastName = 'Hernandez',
            RecordTypeId = devRecordTypeId
        );


        insert newContact;

        Horas_improductivas_por_mec_nico__c newRecord = new Horas_improductivas_por_mec_nico__c(
            Inicio__c = System.today(),
            Fin__c = System.today().addDays(5),
            Tipo_de_Trabajo__c = newTT.Id,
            Mecanico__c = newContact.Id,
            Se_repite__c = 'Diariamente',
            Observaciones__c = 'test observaciones'
        );
        insert newRecord;

        List<Horas_improductivas_por_mec_nico__c> existingRecordsList = [SELECT Id,Name, Inicio__c, Fin__c, Tipo_de_Trabajo__c, Se_repite__c, HIM__c  FROM Horas_improductivas_por_mec_nico__c];        
        System.assert(existingRecordsList.size() > 1, 'Se esperaba la creación de los registros hijos de horas improductivas. --> ' + existingRecordsList.size() + ' VALORES');

        delete newRecord;
        existingRecordsList = [SELECT Id,Name, Inicio__c, Fin__c, Tipo_de_Trabajo__c, Se_repite__c, HIM__c  FROM Horas_improductivas_por_mec_nico__c];

        System.assert(existingRecordsList.size() == 0, 'La consulta no debio regresar registros de horas improductivas ' + existingRecordsList.size() + ' VALORES');
    }


    @IsTest
    public static void unitTestCreateTaskWeekly(){
        tiposDeTrabajo__c newTT = new tiposDeTrabajo__c(
            Name = 'test tt'
        );
        insert newTT;

        Id devRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contacto de Taller').getRecordTypeId();

        Contact newContact = new Contact(
            LastName = 'Hernandez',
            RecordTypeId = devRecordTypeId
        );


        insert newContact;

        Horas_improductivas_por_mec_nico__c newRecord = new Horas_improductivas_por_mec_nico__c(
            Inicio__c = System.today(),
            Fin__c = System.today().addDays(28),
            Tipo_de_Trabajo__c = newTT.Id,
            Mecanico__c = newContact.Id,
            Se_repite__c = 'Semanalmente',
            Observaciones__c = 'test observaciones',
            L__c = true,
            M__c = true,
            K__c = true,
            J__c = true,
            V__c = true
        );
        insert newRecord;

        List<Horas_improductivas_por_mec_nico__c> existingRecordsList = [SELECT Id,Name, Inicio__c, Fin__c, Tipo_de_Trabajo__c, Se_repite__c, HIM__c  FROM Horas_improductivas_por_mec_nico__c];        
        System.assert(existingRecordsList.size() > 1, 'Se esperaba la creación de mas de 1 registros de horas improductivas. --> ' + existingRecordsList.size() + ' VALORES');
    }    
    
}