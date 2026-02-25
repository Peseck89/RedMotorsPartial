global class OppActivityUploader implements Schedulable{
    /*
    * String jobID = System.schedule('Opportunity Activity Uploader', '0 0 18 ? * 6', new OppActivityUploader());
    */
    
    global void execute(SchedulableContext sctx) {
        DateTime dt = DateTime.now();
        dt = dt.addMonths(-6);
        if(sctx !=null){
            CronTrigger ct = [SELECT PreviousFireTime FROM CronTrigger WHERE Id = :sctx.getTriggerId()]; 
            if(ct.PreviousFireTime !=null){
                dt = ct.PreviousFireTime;
            }
        }
        
        init();
        //init2();
    }
    
    @AuraEnabled
    public Static void init(){
        DateTime dt = DateTime.newInstance((Date.today().Year() - 1),1,1);
        
        BatchOppActivityUploader batch = new BatchOppActivityUploader(dt);
        database.executebatch(batch);
    }
    
    @AuraEnabled
    public Static void initLeads(){
        DateTime dt = DateTime.newInstance((Date.today().Year() - 1),1,1);
        System.debug('dt :::::' + dt);
        BatchLeadActivityUploader batch = new BatchLeadActivityUploader(dt);
        database.executebatch(batch);
    }
    
    @AuraEnabled
    public Static void init2()
    {
        DateTime dt = DateTime.newInstance(2019, 09, 01); 
        BatchOppActivityUploader batch = new BatchOppActivityUploader(dt,true);
        database.executebatch(batch);
        
    }
}