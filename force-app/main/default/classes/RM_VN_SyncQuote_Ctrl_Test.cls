@IsTest
public without sharing class RM_VN_SyncQuote_Ctrl_Test {
    @TestSetup
    static void makeData(){
        TestDataFactory.createQuoteWithItems();
    }

    @IsTest
    public static void test_syncQuoteNull(){
        String message;
        try {    
            RM_VN_SyncQuote_Ctrl.sync(null);
        } catch(Exception e) {
            message = e.getMessage();
        }
        System.assertNotEquals(null, message, 'Se esperaba una excepion');        
    }  

    @IsTest
    public static void test_syncQuoteNoValido(){
        String message;
        try {    
            RM_VN_SyncQuote_Ctrl.sync('abc123456789');
        } catch(Exception e) {
            message = e.getMessage();
        }
        System.assertNotEquals(null, message, 'Se esperaba una excepion');    
    }     
    
    @IsTest
    public static void test_syncQuoteValido(){
        Quote quote = [SELECT Id FROM Quote LIMIT 1];

        String message;
        try {    
            RM_VN_SyncQuote_Ctrl.sync(quote.Id);
        } catch(Exception e) {
            message = e.getMessage();
        }
        System.assertEquals(null, message, 'Se esperaba que el proceso no lanzara una excepción.');
    }  

    @IsTest
    public static void test_syncQuoteHasRelatedRecords(){
        Quote quote = [SELECT Id FROM Quote LIMIT 1];

        String message;
        try {    
            RM_VN_SyncQuote_Ctrl.hasRelatedPlanMttos(quote.Id);
        } catch(Exception e) {
            message = e.getMessage();
        }
        System.assertEquals(null, message, 'Se esperaba que el proceso no lanzara una excepción.');
    }     
}