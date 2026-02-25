@IsTest
public with sharing class RM_VU_TestDataFactory {
    
    public static void prepareRecords(){
        List<Product2> productList = new List<Product2>();  
        Product2 vehicleBM166X1sDrive18d = TestDataFactory.createProduct('BM166 - X1 sDrive18d', 'BMW-X1', 'BMW', 'X1', 'BM166 - X1 sDrive18d', '2021', 'Rojo','Negro','Vehiculo',false, false);
        vehicleBM166X1sDrive18d.Marca__c = null;
        vehicleBM166X1sDrive18d.Modelo_De_Inter_s__c = null;
        vehicleBM166X1sDrive18d.Anno__c = '2021';
        vehicleBM166X1sDrive18d.es_Vehiculo_usado__c = true;
        vehicleBM166X1sDrive18d.Tipo_vehiculo__c = 'A';

        productList.add(vehicleBM166X1sDrive18d);

        insert productList;

        Bodega__c bodegaUruca = TestDataFactory.createBodega('Uruca',true);

        List<ProductoXBodega__c> prodXBodList = new List<ProductoXBodega__c>();
        for (Product2 product : productList) {
            prodXBodList.add(TestDataFactory.createProductoXBodega(bodegaUruca,product, false));
        }
        insert prodXBodList;
        
        RM_Config__mdt cfgMdtDPLVU = RM_Config__mdt.getInstance('Default_Price_List_VU');
        RM_Config__mdt cfgMdtDPLVUCC = RM_Config__mdt.getInstance('Default_Price_List_VU_Currency_Code');
        
        Pricebook2 priceBookVU = TestDataFactory.createPriceBook(cfgMdtDPLVU.Value__c, false);
        priceBookVU.CurrencyIsoCode = cfgMdtDPLVUCC.Value__c;
        insert priceBookVU;

        List<PricebookEntry> newPBEList = new List<PricebookEntry>();
        for (Product2 product : productList) {
            PriceBookEntry pbe = TestDataFactory.createPriceBookEntry(priceBookVU, product, 10000, false);
            pbe.CurrencyIsoCode = cfgMdtDPLVUCC.Value__c;
            newPBEList.add(pbe); 
        }
        insert newPBEList;


        Account acc = TestDataFactory.createAccount('Account Test Juan C.', false);

        acc.Cedula__c = '123456789012';

        INSERT acc;

        String rtId = TestDataFactory.getRecordTypeId('Campaign','Campana_Red_Motors');
        Campaign campanna = TestDataFactory.createCampanna('Campaign JC',rtId, true); 

        String pricebookId = priceBookVU.Id;
        
        Opportunity opp = TestDataFactory.createOpportunity(acc, 'Oportunidad Calificada', campanna, pricebookId, true);

        Quote newQuote = TestDataFactory.createQuote(opp, false);
        newQuote.Pricebook2Id = pricebookId;
        insert newQuote;          

    }
}