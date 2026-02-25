@IsTest
public class GetEventsAndRelatedDataTest {
    @IsTest
    static void testGetEventsAndCampaigns() {
        // Crear un usuario de prueba
        User testUser = [SELECT Id FROM User LIMIT 1]; // Usar un usuario existente para evitar problemas de permisos

        // Crear una cuenta de prueba
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Crear activos de prueba
        Asset testAsset1 = new Asset(Name = 'Test Asset 1', AccountId = testAccount.Id);
        Asset testAsset2 = new Asset(Name = 'Test Asset 2', AccountId = testAccount.Id);
        insert new List<Asset> { testAsset1, testAsset2 };
            
        // Crear campañas de prueba
        Campa_a_t_cnica__c testCampaign1 = new Campa_a_t_cnica__c(Asset__c = testAsset1.Id, Categoria__c = 'Campaign 1', Descripcion__c = 'Description 1', Confirmaci_n_de_lectura__c = false);
        Campa_a_t_cnica__c testCampaign2 = new Campa_a_t_cnica__c(Asset__c = testAsset2.Id, Categoria__c = 'Campaign 2', Descripcion__c = 'Description 2', Confirmaci_n_de_lectura__c = false);
        insert new List<Campa_a_t_cnica__c> { testCampaign1, testCampaign2 };

        // Crear eventos de prueba
        Event testEvent1 = new Event(Subject = 'Test Event 1', StartDateTime = DateTime.now().addDays(2), EndDateTime = DateTime.now().addDays(3), Asesor__c = testUser.Id, BMW_NuevaCita__c = true, Activo__c = testAsset1.Id);
        Event testEvent2 = new Event(Subject = 'Test Event 2', StartDateTime = DateTime.now().addDays(2), EndDateTime = DateTime.now().addDays(3), Asesor__c = testUser.Id, BMW_NuevaCita__c = true, Activo__c = testAsset2.Id);
        insert new List<Event> { testEvent1, testEvent2 };

        

        // Invocar el método con el ID del usuario de prueba
        List<Id> userIds = new List<Id> { testUser.Id };
        List<List<Campa_a_t_cnica_temp__c>> results = GetEventsAndRelatedData.getEventsAndCampaigns(userIds);


    }
}