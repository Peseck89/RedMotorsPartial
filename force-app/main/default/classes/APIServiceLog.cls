public without sharing class APIServiceLog {
    private APIServiceLog__c serviceLog;
    
    public APIServiceLog(String requestId, String serviceType, String relatedObject, String relatedObjectId, String objctReference){
        serviceLog = new APIServiceLog__c(RequestId__c = requestId, Service_Type__c = serviceType,
                                          Related_Object__c = relatedObject, Related_Object_Id__c = relatedObjectId, Status__c = 'NO RESPONSE', Object_Field_Reference__c = objctReference);
        setReferenceObjectbyField();
        insertLog();
    }
    
    public APIServiceLog(String requestId){
        getLog(requestId);
    }
    
    public void setRequest(String JSON){
        serviceLog.JSON__c = JSON;
        serviceLog.RequestDate__c = Datetime.now();
        updateLog();
    }
    
    public void setResponse(String response){
        if(String.isEmpty(serviceLog.Response__c)){
            serviceLog.Response__c = response;
            serviceLog.Response_Date__c = Datetime.now();
            updateLog();
        }
    }
    
    public boolean logExists(){
        return serviceLog!=null;
    }
    
    private void insertLog(){
        insert serviceLog;
    }
    
    private void updateLog(){
        update serviceLog;
    }
    
    private void getLog(String requestId){
        if(serviceLog == null){
            List <APIServiceLog__c> logs = [select Id, Response__c  from APIServiceLog__c where RequestId__c =: requestId limit 1];
            if(logs.size() > 0){
                serviceLog = logs[0];         
            }
        }
    }
    
    private void setReferenceObjectbyField(){
        String field = serviceLog.Object_Field_Reference__c;
        String objName = serviceLog.Related_Object__c;
        String objId = serviceLog.Related_Object_Id__c;
        String query = 'SELECT Id, ' + field + ' FROM ' + objName + ' WHERE Id = :objId LIMIT 1'; 
        List<sObject> objList = Database.query(query);
        if(objList.size() > 0){
            serviceLog.Object_Reference__c = String.valueOf(objList[0].get(field));
        }
    }
    
    
    
    
}