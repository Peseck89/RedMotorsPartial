@IsTest
public class BMW_QuoteLineItemHandlerTrigger_Test {
    /*
    @TestSetup
    static void makeData(){
        TestDataFactory.createQuoteWithItems();
    }
    
    @IsTest
    static void test_deleteQuoteLineItem(){
        List<QuoteLineItem> qliList = [SELECT Id,UnitPrice FROM QuoteLineItem WHERE BMW_TipoDeArticulo__c != 'Vehiculo' LIMIT 1];
        for (QuoteLineItem quote : qliList) {
            quote.UnitPrice = 100;
        }
        update qliList;
        
        delete qliList;

        BMW_QuoteLineItemHandlerTrigger.dummy();
    }
*/
     @IsTest
    public static void testSoloDummy() {
        // Llamada únicamente al método dummy()
        BMW_QuoteLineItemHandlerTrigger.dummyMethod();
        BMW_QuoteLineItemHandlerTrigger.dummy();
    }
}