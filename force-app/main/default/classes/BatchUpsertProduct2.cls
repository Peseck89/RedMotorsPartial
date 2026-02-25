public class BatchUpsertProduct2 implements Database.Batchable<Product2>, Database.AllowsCallouts{
    private String url;
    private String tokenType;
    private String token;
    private Integer actualPage;
    private List<Product2> productosSinDuplicados;
    private HttpCalloutInventory httpInventory;
    private String actualCurrency;

    public BatchUpsertProduct2(String tokenType, String token,Integer actualPage,List<Product2> productosSinDuplicados,HttpCalloutInventory httpInventory,String actualCurrency){
        this.url = Label.URLSoftland;
        this.tokenType = tokenType;
        this.token = token;
        this.actualPage = actualPage;
        this.productosSinDuplicados=productosSinDuplicados;
        this.httpInventory = httpInventory;
        this.actualCurrency = actualCurrency;
    }

    public Iterable<Product2> start(Database.BatchableContext BC){
        return new IterableProduct2(productosSinDuplicados);
    }

    public void execute(Database.BatchableContext BC, List<Product2> scope){
        List<Pricebook2> standardPB;
        List<Pricebook2> priceBooks;
        if(actualCurrency=='getLocalListPaged')
        {
            standardPB = [SELECT Id,Name FROM Pricebook2 WHERE IsStandard=true];
            priceBooks = [SELECT Id,Name FROM Pricebook2 WHERE Name='Local'];
        }
        else if(actualCurrency=='getDolarListPaged')
        {
            priceBooks = [SELECT Id,Name FROM Pricebook2 WHERE Name='Dolar'];
        }

        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        Set<Id> setIdProductosSinDuplicados = new Set<Id>();
        Schema.SObjectField productId = Product2.Fields.Codigo_de_Producto__c;
        Database.UpsertResult[] saveProducts = Database.upsert(scope,productId, false);
        for(Database.UpsertResult resu : saveProducts){
            if(resu.isSuccess()){
                setIdProductosSinDuplicados.add(resu.getId());
            } else {
                System.debug('Error al actualizar la entrada: '+ resu.getErrors());
            }
        }
        for(Product2 actualProduct : [SELECT Id,precio__c FROM Product2 WHERE Id IN :setIdProductosSinDuplicados])
        {
            if(actualCurrency=='getLocalListPaged')
            {
                PricebookEntry pbe = new PricebookEntry();
                pbe.UnitPrice = actualProduct.precio__c;
                pbe.Pricebook2Id = (standardPB.size() > 0 ? standardPB[0].Id : null);
                pbe.product2Id = actualProduct.Id;
                pbe.isActive = true;
                pbe.priceBookEntryId__c = (standardPB.size() > 0 ? standardPB[0].Name : null)+'-'+actualProduct.Id;
                pbeList.add(pbe);
            }
            
            PricebookEntry pbeLocal = new PricebookEntry();
            pbeLocal.UnitPrice = actualProduct.precio__c;
            pbeLocal.Pricebook2Id = (priceBooks.size() > 0 ? priceBooks[0].Id : null);
            pbeLocal.product2Id = actualProduct.Id;
            pbeLocal.isActive = true;
            pbeLocal.priceBookEntryId__c = (priceBooks.size() > 0 ? priceBooks[0].Name : null)+'-'+actualProduct.Id;
            pbeList.add(pbeLocal);
        }
        
        //insert pbeList;
        Schema.SObjectField priceBookEntryId = PricebookEntry.Fields.priceBookEntryId__c;
        Database.UpsertResult[] savePriceBookEntry = Database.upsert(pbeList,priceBookEntryId, false);
        for(Database.UpsertResult resu : savePriceBookEntry){
            if(!resu.isSuccess())
            {
                System.debug('Error al actualizar la entrada: '+ resu.getErrors());
            } else {
                System.debug('Success: '+resu.getId());
            }
        }
    }

    public void finish(Database.BatchableContext BC){
        productosSinDuplicados = new List<Product2>();
        if(!Test.isRunningTest()) BatchGetInventorySoftland.calloutWS(url,tokenType,token,actualPage,productosSinDuplicados,httpInventory,actualCurrency);
    }
}