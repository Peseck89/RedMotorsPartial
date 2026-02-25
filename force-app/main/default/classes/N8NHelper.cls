public with sharing class N8NHelper {
    public static void enqueue(List<Id> n8nIds){
        if(n8nIds == null || n8nIds.isEmpty()) return;
        System.enqueueJob(new N8NQueue(n8nIds));
    }
}