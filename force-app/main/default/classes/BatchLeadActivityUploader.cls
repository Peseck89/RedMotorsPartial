public class BatchLeadActivityUploader implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    private DateTime dt;
    private Boolean excludeEmpty;
    public string idBMW;
    public string idMini;
    public string idMotorrad;
    
    public BatchLeadActivityUploader (DateTime dt) {
        this.dt = dt;
        this.excludeEmpty = false;
        this.idBMW = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BMW').getRecordTypeId();
        this.idMini = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('MINI').getRecordTypeId();
        this.idMotorrad = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Motorrad').getRecordTypeId();
        
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id,Name FROM Lead WHERE CreatedDate >=:dt AND ( RecordTypeId =:idBMW OR RecordTypeId =:idMini OR RecordTypeId =:idMotorrad)';
        
        Map<String, Object> data = new Map<String, Object>();
        data.put('sfdataflow', 'start');
        data.put('payloadTag', 'lead');
        String leadbody = Json.serializePretty(data);
        System.debug('leadbody :: ' + leadbody);
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('content-type', 'application/json');
        req.setEndpoint(System.Label.LeadActivityUploaderURL_SE);
        req.setBody(leadbody);
        
        if(!Test.isRunningTest()){
            HttpResponse response = new Http().send(req);
            response.getBody();
            System.debug('Body ' + response.getBody()); 
        }
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Lead> leadList)
    {
        DateTime dts = DateTime.now();
        dts = dts.addDays(-7);
        DateTime eve = Datetime.now();
        Set<String> leadIdSet = new Set<String>();
        System.debug('Devolvio: '+ leadList );
        for(Lead lead : leadList){
            leadIdSet.add(lead.Id);
        }
        
        List<Lead> ldList = [SELECT Id,Name,OwnerId,Owner.Name,RecordTypeId,RecordType.Name,LeadSource, Marca__c,
                             FechaPosibleCompra__c, Status,
                            (Select Id,Subject,whatId,what.Name,OwnerId,ActivityDate,Owner.Name,Status,CreatedDate,WhoId 
                             from Tasks
                             where Subject in : getSubjects('Task', 'Subject')),
                            (Select Id,Subject,whatId,what.Name,OwnerId,ActivityDate,Owner.Name,EndDateTime,CreatedDate,WhoId 
                             from Events
                             where Subject in : getSubjects('Event', 'Subject'))
                             FROM Lead 
                             WHERE Id IN: leadIdSet ];
        
        System.debug('Retorno: '+ldList.size());
        
        List<LeadWrapperClass> ldwrpList = new List<LeadWrapperClass>();
        for(Lead ld : ldList){
            if(ld.Tasks.size() > 0 || ld.Events.size()>0){
                List<Task> tkList = ld.Tasks;
            
                for(Task tk : tkList){
                    LeadWrapperClass taskwrap = new LeadWrapperClass();
                    taskwrap.NombreTraficos = ld.Name;
                    taskwrap.TipoActividad = tk.Subject;
                    taskwrap.origendelcandidato = ld.LeadSource;
                    taskwrap.propietariodelcandidato = tk.Owner.Name;
                    taskwrap.Estadodecandidato = ld.Status;
                    taskwrap.Marca = ld.Marca__c;
                    taskwrap.FechaEstimadadeCompra = ld.FechaPosibleCompra__c;
                    taskwrap.idActividad = tk.Id;
                    taskwrap.IdLead = ld.Id;
                    
                    ldwrpList.add(taskwrap);
                }
                
                List<Event> eventList = ld.Events;
                for(Event et : eventList){
                    LeadWrapperClass etewrap = new LeadWrapperClass();
                    etewrap.NombreTraficos = ld.Name;
                    etewrap.TipoActividad = et.Subject;
                    etewrap.origendelcandidato = ld.LeadSource;
                    etewrap.propietariodelcandidato = et.Owner.Name;
                    etewrap.Estadodecandidato = ld.Status;
                    etewrap.Marca = ld.Marca__c;
                    etewrap.FechaEstimadadeCompra = ld.FechaPosibleCompra__c;
                    etewrap.idActividad = et.Id;
                    etewrap.IdLead = ld.Id;
                    
                    ldwrpList.add(etewrap);
                }
            } 
        }
        
        Map<String, Object> data = new Map<String, Object>();
        data.put('data', ldwrpList);
        String leadbody = Json.serializePretty(data);
        
        System.debug('leadbody :: ' + leadbody);
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('content-type', 'application/json');
        req.setEndpoint(System.Label.LeadActivityUploader_URL);
        req.setBody(leadbody);
        
        if(!Test.isRunningTest()){
            HttpResponse response = new Http().send(req);
            response.getBody();
            System.debug('Body ' + response.getBody()); 
        }
    }
    
    public String convertDate(date dt)
    {
        if(dt != null)
        {
            return dt.day()+'/'+dt.month()+'/'+dt.year();
        }
        
        return '';
    }
    
    public Set<String> getSubjects(String objectName, String fieldName)
    {
        Set<String> values = new Set<String>();
          
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            values.add(pickListVal.getValue());
        }  
        
        return values;  
    }
    
    public class LeadWrapperClass{
        public String NombreTraficos;
        public String TipoActividad;
        public String origendelcandidato;
        public String propietariodelcandidato;
        public String Estadodecandidato;
        public String Marca;
        public String FechaEstimadadeCompra;
        public String idActividad;
        public String IdLead;
        
        public LeadWrapperClass()
        {
            NombreTraficos = '';
            TipoActividad = '';
            origendelcandidato = '';
            propietariodelcandidato = '';
            Estadodecandidato = '';
            Marca = '';
            FechaEstimadadeCompra = '';
            idActividad = '';
            IdLead = '';
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        Map<String, Object> data = new Map<String, Object>();
        data.put('sfdataflow', 'end');
        String leadbody = Json.serializePretty(data);
        System.debug('leadbody :: ' + leadbody);
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('content-type', 'application/json');
        req.setEndpoint(System.Label.LeadActivityUploaderURL_SE);
        req.setBody(leadbody);
        
        if(!Test.isRunningTest()){
            HttpResponse response = new Http().send(req);
            response.getBody();
            System.debug('Body ' + response.getBody()); 
        }
    }
}