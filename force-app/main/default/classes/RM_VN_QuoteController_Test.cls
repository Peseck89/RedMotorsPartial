@IsTest
public class RM_VN_QuoteController_Test {

    @TestSetup
    static void makeData(){
        RM_VN_DataFactoryHelper.createRecordsVN();
    }

    @IsTest
    static void test_AgregarInventarioParametrosNull(){
       
            Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

            Oportunidad_Producto_Interes__c opi = [SELECT Id,Modelo_Interes__c FROM Oportunidad_Producto_Interes__c LIMIT 1];
            String modeloInteres = opi.Modelo_Interes__c;
            // String modeloInteres = 'BM166 - X1 sDrive18d';
            ProductoXBodega__c pxb = [SELECT Id FROM ProductoXBodega__c WHERE Producto__r.esVehiculo__c = true AND Producto__r.IsActive = true LIMIT 1];
    
            String oppId = opp.Id;
            String oppProdIntId = opi.Id;
            String prodXBodegaId = pxb.Id;
            String existingQuoteId;
          
            try {
                RM_VN_QuoteController.addVehicle(null, oppProdIntId, prodXBodegaId, existingQuoteId);
            } catch (Exception e) {
            }  
            try {
                RM_VN_QuoteController.addVehicle(oppId, null, prodXBodegaId, existingQuoteId);
            } catch (Exception e) {
            }
            try {
                RM_VN_QuoteController.addVehicle(oppId, oppProdIntId, null, existingQuoteId);
            } catch (Exception e) {
                
            }
            try {
                RM_VN_QuoteController.addVehicle(oppId, oppProdIntId, '001', null);
            } catch (Exception e) {
            }

            try {
                RM_VN_QuoteController.addVehicle(oppId, '001', prodXBodegaId, null);
            } catch (Exception e) {
            }
            try {
                RM_VN_QuoteController.addVehicle('001', oppProdIntId, prodXBodegaId, existingQuoteId);
            } catch (Exception e) {
            }
    }

    /*    
    @IsTest
    static void test_AgregarInventarioMismoModeloDeInteres(){ 
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Oportunidad_Producto_Interes__c opi = [SELECT Id,Modelo_Interes__c FROM Oportunidad_Producto_Interes__c WHERE Oportunidad__c = :opp.Id LIMIT 1];
        ProductoXBodega__c pxb = [SELECT Id FROM ProductoXBodega__c WHERE Producto__r.modelo__c = :opi.Modelo_Interes__c AND Producto__r.esVehiculo__c = true AND Producto__r.IsActive = true LIMIT 1];

        String oppId = opp.Id;
        String oppProdIntId = opi.Id;
        String prodXBodegaId = pxb.Id;
        String existingQuoteId;
        
        Test.startTest();
            RM_VN_QuoteController.getQuotes(oppId);
            RM_VN_QuoteController.addVehicle(oppId, oppProdIntId, prodXBodegaId, existingQuoteId);
        Test.stopTest();

        QuoteLineItem qli = [SELECT Id,QuoteId FROM QuoteLineItem WHERE Product2.esVehiculo__c = true LIMIT 1];

        ProductoXBodega__c pxbManoObra = [SELECT Id FROM ProductoXBodega__c WHERE Producto__r.esVehiculo__c = false AND Producto__r.IsActive = true LIMIT 1];

        QuoteService.addLineItem(qli.QuoteId, pxbManoObra.Id, qli.Id, true, false, 'mano obra', 'mano obra', 0, 100);
        QuoteService.addLineItem(qli.QuoteId, pxbManoObra.Id, qli.Id, true, false, 'mano obra', 'mano obra', 1, 0);
        QuoteService.addLineItem(qli.QuoteId, pxbManoObra.Id, qli.Id, true, false, 'mano obra', 'mano obra', 1, 100);
        QuoteService.addLineItem(qli.QuoteId, pxbManoObra.Id, qli.Id, true, false, 'extra', 'extra', 1, 100);
    }

    @IsTest
    static void test_AgregarInventarioDiferenteModeloDeInteres(){

        Oportunidad_Producto_Interes__c opi = [SELECT Id,Modelo_Interes__c,Oportunidad__c FROM Oportunidad_Producto_Interes__c WHERE Marca__c != null AND Oportunidad__c != NULL LIMIT 1];

        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id = :opi.Oportunidad__c LIMIT 1];

        String modeloInteres = opi.Modelo_Interes__c;
        ProductoXBodega__c pxb = [SELECT Id FROM ProductoXBodega__c WHERE Producto__r.modelo__c != :opi.Modelo_Interes__c AND Producto__r.esVehiculo__c = true AND Producto__r.IsActive = true LIMIT 1];

        String oppId = opp.Id;
        String oppProdIntId = opi.Id;
        String prodXBodegaId = pxb.Id;
        String existingQuoteId;
        
        Test.startTest();
            RM_VN_QuoteController.getQuotes(oppId);
            RM_VN_QuoteController.addVehicle(oppId, oppProdIntId, prodXBodegaId, existingQuoteId);
        Test.stopTest();
    }*/

    @IsTest
    static void test_GetPricebookName(){
        List<Opportunity> opps = [SELECT Id FROM Opportunity LIMIT 1];
        Assert.areEqual(opps.size()>0,true, 'No hay oportunidades disponibles para la prueba.');
        QuoteService.getPricebookName(opps[0].Id);

        QuoteService.name();
    }
}