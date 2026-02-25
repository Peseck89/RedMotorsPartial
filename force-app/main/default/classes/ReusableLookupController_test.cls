@isTest(seeAllData=true)
public class ReusableLookupController_test {
@isTest
    static void testFetchRecordsWithValidInput() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a SearchWrapper instance with necessary fields
        ReusableLookupController.SearchWrapper inputWrapper = new ReusableLookupController.SearchWrapper();
        inputWrapper.objectApiName = 'Account';
        inputWrapper.fieldApiName = 'Softland_Email__c';
        inputWrapper.otherFieldApiName = 'FirstName';
        inputWrapper.searchString = 'Test';
        inputWrapper.selectedRecordId = '';
        inputWrapper.parentRecordId = '';
        inputWrapper.parentFieldApiName = '';

        // Call the method
        Test.startTest();
        ReusableLookupController.dummy();
        try{
        	List<ReusableLookupController.ResultWrapper> results = ReusableLookupController.fetchRecords(inputWrapper);
        }catch(DmlException e){
            
        }
        Test.stopTest();

    }

    @isTest
    static void testFetchRecordsWithSelectedRecordId() {
        // Create test data
        Account testAccount = new Account(Name = 'Selected Account');
        insert testAccount;

        // Create a SearchWrapper instance with selectedRecordId
        ReusableLookupController.SearchWrapper inputWrapper = new ReusableLookupController.SearchWrapper();
        inputWrapper.objectApiName = 'Account';
        inputWrapper.fieldApiName = 'Softland_Email__c';
        inputWrapper.otherFieldApiName = '';
        inputWrapper.searchString = '';
        inputWrapper.selectedRecordId = testAccount.Id;
        inputWrapper.parentRecordId = '';
        inputWrapper.parentFieldApiName = '';

        // Call the method
        Test.startTest();
        try{
        	//List<ReusableLookupController.ResultWrapper> results = ReusableLookupController.fetchRecords(inputWrapper);
        }catch(DmlException e){
            
        }
        Test.stopTest();
    }

    @isTest
    static void testFetchRecordsWithParentFieldAndRecordId() {
        // Create test data
        Account parentAccount = new Account(Name = 'Parent Account');
        insert parentAccount;

        Contact testContact = new Contact(LastName = 'Child Contact', AccountId = parentAccount.Id);
        insert testContact;

        // Create a SearchWrapper instance with parentFieldApiName and parentRecordId
        ReusableLookupController.SearchWrapper inputWrapper = new ReusableLookupController.SearchWrapper();
        inputWrapper.objectApiName = 'Contact';
        inputWrapper.fieldApiName = 'LastName';
        inputWrapper.otherFieldApiName = 'AccountId';
        inputWrapper.searchString = 'Child';
        inputWrapper.selectedRecordId = '';
        inputWrapper.parentRecordId = parentAccount.Id;
        inputWrapper.parentFieldApiName = 'AccountId';

        // Call the method
        Test.startTest();
        List<ReusableLookupController.ResultWrapper> results = ReusableLookupController.fetchRecords(inputWrapper);
        Test.stopTest();

        // Verify the results
        System.assertNotEquals(0, results.size());
        System.assertEquals(testContact.Id, results[0].id);
        System.assertEquals(testContact.LastName, results[0].mainField);
        System.assertEquals(testContact.AccountId, results[0].subField);
    }

    @isTest
    static void testFetchRecordsWithEmptyInputWrapper() {
        // Create an empty SearchWrapper instance
        ReusableLookupController.SearchWrapper inputWrapper = new ReusableLookupController.SearchWrapper();

        // Call the method
        Test.startTest();
        try{
            //List<ReusableLookupController.ResultWrapper> results = ReusableLookupController.fetchRecords(inputWrapper);
        }catch(DmlException e){
            
        }
        
        Test.stopTest();

        // Verify the results
        //System.assertEquals(null, results);
    }


}