public class DeleteRecordsBatch implements Database.Batchable<Marca_Modelo__c>, Database.Stateful, Database.AllowsCallouts {
    
    List<Marca_Modelo__c> marcaList = new List<Marca_Modelo__c>();    
    DeleteRecordsBatch(List<Marca_Modelo__c> mList)
    {
        marcaList = mList;
    }
    
    public static void startExecution(List<Marca_Modelo__c> mList)
    {
        Database.executeBatch(new DeleteRecordsBatch(mList), 2000);    
    }
    
    public Iterable<Marca_Modelo__c> start(Database.BatchableContext BC)
    {
        return marcaList;
    }
    
    public void execute(Database.BatchableContext BC, List<Marca_Modelo__c> mListExecute) 
    {
        delete mListExecute;
    }   
    
    public void finish(Database.BatchableContext BC) 
    {
        
    }
}