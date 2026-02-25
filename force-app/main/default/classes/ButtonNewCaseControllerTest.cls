@isTest
private class ButtonNewCaseControllerTest {
    @isTest
    static void testGetUserIsAsesor() {
        // Create a test profile
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];

        // Create test user with IsAsesor__c set to true
        User testUser = new User(
            FirstName = 'admin',
            LastName = 'Portalnet',
            IsAsesor__c = true,
            Username = 'admin@portalnetcr.com.partialp3', // Example username
            Email = 'admin@portalnetcr.com',               // Example email
            Alias = 'tuser',                               // Example alias
            TimeZoneSidKey = 'America/Los_Angeles',        // Example time zone
            LocaleSidKey = 'en_US',                        // Example locale
            EmailEncodingKey = 'UTF-8',                    // Example email encoding
            ProfileId = p.Id,                              // ProfileId
            LanguageLocaleKey = 'en_US'                    // Example language
        );

        insert testUser;

        // Set the test user as the current user
        System.runAs(testUser) {
            Boolean isUserAsesor = ButtonNewCaseController.getUserIsAsesor();
            System.assertEquals(true, isUserAsesor);
        }
    }
}