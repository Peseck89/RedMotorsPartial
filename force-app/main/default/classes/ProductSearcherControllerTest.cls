@isTest
public class ProductSearcherControllerTest {
            
    @TestSetup
    static void makeData(){ 
        TestDataFactory.createQuoteWithItems();
        // RM_VN_DataFactoryHelper.createRecordsVN();
    }

    @IsTest
    static void testGetWorkSteps(){        
        Test.startTest();

        List<Product2> productList = [SELECT Id,Name,Anno__c,vin__c,Color__c,ProductCode,modelo__c,Marca__c,Familia__c FROM Product2]; 
        List<Quote> quoteList = [SELECT Id FROM Quote LIMIT 1];     

        List<ProductoXBodega__c> prodXBodList = [SELECT Id,Name,Producto__c,Bodega__c FROM ProductoXBodega__c]; 
        // System.debug('@prodXBodList@'+prodXBodList);
        ProductSearcherController.getProducts(null, null, null, null, null, null, null, null, null, null, null, null,null,1);
        Map<String,Object> responseMap = new Map<String,Object>();
                           responseMap = ProductSearcherController.getProducts('vehiculo', null, null, null, '2023', null, 'BMW', null, null,null, 'MW-X1-SDRIVE18D-XLINE',null,null, 1);
                           System.debug('@responseMap vehiculo@'+responseMap);

                           responseMap = ProductSearcherController.getProducts('extra', null, null, null, '2023', null, 'BMW', null, null,null, 'MW-X1-SDRIVE18D-XLINE',null,null, 1);
                           System.debug('@responseMap extra@'+responseMap);

                           responseMap = ProductSearcherController.getProducts('mano obra', null, null, null, null, null, 'BMW', null, null,null, 'MW-X1-SDRIVE18D-XLINE',quoteList[0].Id,null, 1);
                            System.debug('@responseMap mano obra@'+responseMap);
        Test.stopTest();        
    }

    @IsTest
    static void test_GetProductDataFromOLI(){
        List<Opportunity> oppList = [SELECT Id FROM Opportunity LIMIT 1]; 
        if (oppList.size() > 0) {
            Oportunidad_Producto_Interes__c oppProdInt = TestDataFactory.createOportunidadProductoInteres('BMW','ABC MODEL','X1','2023',oppList[0],true);
            Map<String,Object> responseMap = ProductSearcherController.getProductDataFromOLI(oppProdInt.Id);  
        }      
    }

    @IsTest
    static void test_GetOpportunityByQuote(){
        List<Quote> quoteList = [SELECT Id FROM Quote LIMIT 1]; 
        if (quoteList.size() > 0) {
            Map<String,Object> responseMap = ProductSearcherController.getProductByQuoteId(quoteList[0].Id);   
        }
        
        ProductSearcherController.dummy();
    }    
}