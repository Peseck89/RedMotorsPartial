@isTest
public class PreventDuplicateHours_test {

 
    
    @isTest
    static void testPreventDuplicateAccounts() {
        // Test data with a duplicate email
        Hora_global__c newAccountWithDuplicateEmail = new Hora_global__c( Service_Territory__c = '0Hh4U0000010wWcSAI', Nivel_de_aplicaci_n__c  = 'Servicio Específico', Tipo_de_Cita__c = 'Formulario' , Tipo_de_veh_culo__c = 'Carro');
        
        //Hora_global__c newAccountWithDuplicateEmail = new Hora_global__c( Service_Territory__c = '0Hh8N00000005nQSAQ', Nivel_de_aplicaci_n__c  = 'Servicio Específico', Tipo_de_Cita__c = 'Formulario' , Tipo_de_veh_culo__c = 'Carro');    
            
        // Test data with a unique email
        
        // Attempt to insert the records
        List<Hora_global__c> accountsToInsert = new List<Hora_global__c>{ newAccountWithDuplicateEmail };
        Test.startTest();
        insert accountsToInsert;
        update accountsToInsert;
        Test.stopTest();

    }

}