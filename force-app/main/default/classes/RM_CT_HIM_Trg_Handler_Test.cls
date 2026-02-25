@IsTest
public class RM_CT_HIM_Trg_Handler_Test {
    @IsTest
    static void methodName(){
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SobjectType = 'Contact' AND IsActive = TRUE AND DeveloperName = 'Contacto_de_Taller'];
        Contact contact = RM_CT_TestDataFactory.createContact('mecanico', 'test', 'test2', recordTypes[0].Id , false);
        INSERT contact;
        Horas_improductivas_por_mec_nico__c him = new Horas_improductivas_por_mec_nico__c();
        him.Mecanico__c = contact.Id;
        INSERT him;
        DELETE him;
    }
}