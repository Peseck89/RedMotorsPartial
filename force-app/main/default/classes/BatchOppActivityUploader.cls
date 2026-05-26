public class BatchOppActivityUploader implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts{
    private DateTime dt;
    private Boolean excludeEmpty;
    public string idBMW;
    public string idMini;
    public string idMotorrad;
    public BatchOppActivityUploader (DateTime dt) {
        this.dt = dt;
        this.excludeEmpty = false;
        BatchActivityUploaderBase.RecordTypeIds recordTypeIds = BatchActivityUploaderBase.getRecordTypeIds(Schema.SObjectType.Opportunity);
        this.idBMW = recordTypeIds.idBMW;
        this.idMini = recordTypeIds.idMini;
        this.idMotorrad = recordTypeIds.idMotorrad;
        
    }
    public BatchOppActivityUploader (DateTime dt,Boolean excludeEmpty) {
        this.dt = dt;
        this.excludeEmpty = excludeEmpty;
        BatchActivityUploaderBase.RecordTypeIds recordTypeIds = BatchActivityUploaderBase.getRecordTypeIds(Schema.SObjectType.Opportunity);
        this.idBMW = recordTypeIds.idBMW;
        this.idMini = recordTypeIds.idMini;
        this.idMotorrad = recordTypeIds.idMotorrad;
        System.debug('Id 1: '+idBMW);
        System.debug('Id 2: '+idMini);
        System.debug('Id 3: '+idMotorrad);
    }
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id,Name FROM Opportunity WHERE CreatedDate >=:dt AND ( RecordTypeId =:idBMW OR RecordTypeId =:idMini OR RecordTypeId =:idMotorrad)';
        
        BatchActivityUploaderBase.sendDataflowSignal('start', 'opportunity', System.Label.OppActivityUploaderURL_SE, 'oppbody');
        
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<opportunity> oppList){
        DateTime dts = DateTime.now();
        dts = dts.addDays(-7);
        DateTime eve = Datetime.now();
        Set<String> oppIdSet = new Set<String>();
        System.debug('Devolvio: '+ oppList );
        for(Opportunity opp : oppList){
            oppIdSet.add(opp.Id);
        }
        
        List<Opportunity> opList = [SELECT Id,Name,Type,OwnerId,Owner.Name,RecordTypeId,RecordType.Name,LeadSource,ContactId,
                                    Fecha_Posible_Compra__c,StageName,CloseDate,facturado__c,fechafactura__c,entregado__c,
                                    fechaentrega__c,CreatedDate,Distribuidor__c,LastModifiedDate,Modelo_de_Veh_culo_Actual__c,RazonVentaPerdida__c,vitrinaSala__c,NombreProducto__c,
                                   (Select Id,Subject,whatId,what.Name,OwnerId,ActivityDate,Owner.Name,Status,CreatedDate,WhoId 
                                    from Tasks
                                    where Subject in : getSubjects('Task', 'Subject')),
                                   (Select Id,Subject,whatId,what.Name,OwnerId,ActivityDate,Owner.Name,EndDateTime,CreatedDate,WhoId 
                                    from Events
                                    where Subject in : getSubjects('Event', 'Subject'))
                                    FROM Opportunity 
                                    WHERE Id IN: oppIdSet ];
        System.debug('Retorno: '+opList.size());
        List<Contact> Conlist = [select Id,CreatedDate FROM Contact];
        
        List<OppWrapperClass> oppwrpList = new List<OppWrapperClass>();
        for(Opportunity opp : opList){
            if(opp.Tasks.size() > 0 || opp.Events.size()>0){
                List<Task> tkList = opp.Tasks;
                System.debug('Task: '+tkList);
                for(Task tk : tkList){
                    OppWrapperClass taskwrap = new OppWrapperClass();
                    taskwrap = new OppWrapperClass();
                    taskwrap.TipoActividad = tk.Subject;
                    taskwrap.idActividad = tk.Id;
                    taskwrap.IdOportunidad = opp.Id;
                    taskwrap.FechaCreacionOportunidad = convertDate(opp.CreatedDate.date());
                    //taskwrap.FechaCreacionOportunidad = taskwrap.FechaCreacionOportunidad.substringBefore(' ');
                    taskwrap.IdContactoOportunidad = tk.WhoId;
                    taskwrap.IdContacto = tk.WhoId;
                    taskwrap.NombreOportunidad = opp.Owner.Name;
                    taskwrap.idOportunidadUsuario = tk.OwnerId;
                    taskwrap.EstadoSeguimiento = tk.Status;
                    taskwrap.Marca = opp.RecordType.Name;
                    taskwrap.origendelprospecto = opp.LeadSource;
                    taskwrap.FechaEstimadadeCompra = opp.Fecha_Posible_Compra__c;
                    taskwrap.EstadoOportunidad = opp.StageName;
                    taskwrap.MedioDigital = opp.LeadSource;
                    taskwrap.FechaPedido = convertDate(opp.CloseDate);
                    taskwrap.Facturado = convertDate(opp.facturado__c);
                    taskwrap.fechafactura = convertDate(opp.fechafactura__c);
                    taskwrap.Entregado = convertDate(opp.entregado__c);
                    taskwrap.fechaentrega = convertDate(opp.fechaentrega__c);
                    taskwrap.Distribuidor = 'Bavarian Motors CR SA';//opp.Distribuidor__c;
                    taskwrap.Tiene_Actividad ='TRUE';
                    taskwrap.Tipo_Registro='Activity';
                    if(opp.CreatedDate >= dts){
                        taskwrap.Nuevo_Registro='TRUE';
                    }
                    else{
                        taskwrap.Nuevo_Registro='FALSE';
                    }
                    oppwrpList.add(taskwrap);
                    
                    taskwrap.NombreVitrina = 'Bavarian Motors CR SA';
                    //taskwrap.IdUsuario = tk.OwnerId;
                    //taskwrap.NombreUsuario = tk.Owner.Name;
                    datetime dt = tk.CreatedDate;
                    string fecha = dt.day()+'/'+dt.month()+'/'+dt.year();
                    taskwrap.FechaCreacion = fecha;
                    taskwrap.Modelo_Actual = opp.NombreProducto__c;
                }
                
                List<Event> eventList = opp.Events;
                for(Event et : eventList){
                    OppWrapperClass etewrap = new OppWrapperClass();
                    etewrap.TipoActividad = et.Subject;
                    etewrap.idActividad = et.Id;
                    etewrap.IdOportunidad = opp.Id;
                    etewrap.FechaCreacionOportunidad = convertDate(opp.CreatedDate.date());
                    //etewrap.FechaCreacionOportunidad = etewrap.FechaCreacionOportunidad.substringBefore(' ');
                    etewrap.IdContactoOportunidad = et.WhoId;
                    etewrap.IdContacto = et.WhoId;
                    etewrap.NombreOportunidad = opp.Owner.Name;
                    etewrap.idOportunidadUsuario = et.OwnerId;
                    etewrap.Marca = opp.RecordType.Name;
                    etewrap.origendelprospecto = opp.LeadSource;
                    etewrap.FechaEstimadadeCompra = opp.Fecha_Posible_Compra__c;
                    etewrap.EstadoOportunidad = opp.StageName;
                    etewrap.MedioDigital = opp.LeadSource;
                    etewrap.FechaPedido = convertDate(opp.CloseDate);
                    etewrap.Facturado = convertDate(opp.facturado__c);
                    etewrap.fechafactura = convertDate(opp.fechafactura__c);
                    etewrap.Entregado = convertDate(opp.entregado__c);
                    etewrap.fechaentrega = convertDate(opp.fechaentrega__c);
                    etewrap.motivoPerdida = opp.RazonVentaPerdida__c;
                    etewrap.Distribuidor = 'Bavarian Motors CR SA';
                    etewrap.NombreVitrina = opp.vitrinaSala__c;
                    etewrap.Tiene_Actividad='TRUE';
                    etewrap.Tipo_Registro='Activity';
                    etewrap.Modelo_Actual = opp.NombreProducto__c;
                    if(et.EndDateTime <= eve){
                        etewrap.EstadoSeguimiento = 'Close';
                    }else{
                        etewrap.EstadoSeguimiento = 'Open';
                    }
                    if(opp.CreatedDate >= dts){
                        etewrap.Nuevo_Registro='TRUE';
                    }
                    else{
                        etewrap.Nuevo_Registro='FALSE';
                    }
                    oppwrpList.add(etewrap);
                    
                    //etewrap.IdUsuario = et.OwnerId;
                    //etewrap.NombreUsuario = et.Owner.Name;
                    //ewrap.NombreVitrina = ;
                    etewrap.FechaCreacion = String.valueOf(et.CreatedDate);
                }
                
                if(eventList.isEmpty() && tkList.isEmpty() && excludeEmpty == false){
                    OppWrapperClass wrap = new OppWrapperClass();
                    wrap.TipoActividad = String.isNotBlank(opp.Type) ? opp.Type : '';
                    wrap.IdOportunidad = opp.Id;
                    wrap.FechaCreacionOportunidad = convertDate(opp.CreatedDate.date());
                    //wrap.FechaCreacionOportunidad = wrap.FechaCreacionOportunidad.substringBefore(' ');
                    wrap.NombreOportunidad = opp.Owner.Name;
                    wrap.IdContactoOportunidad = opp.ContactId;
                    wrap.idOportunidadUsuario = opp.OwnerId;
                    wrap.Marca = opp.RecordType.Name;
                    wrap.origendelprospecto = opp.LeadSource;
                    wrap.FechaEstimadadeCompra = opp.Fecha_Posible_Compra__c;
                    wrap.EstadoOportunidad = opp.StageName;
                    wrap.MedioDigital = opp.LeadSource;
                    wrap.FechaPedido = convertDate(opp.CloseDate);
                    wrap.Facturado = convertDate(opp.facturado__c);
                    wrap.fechafactura = convertDate(opp.fechafactura__c);
                    wrap.Entregado = convertDate(opp.entregado__c);
                    wrap.fechaentrega = convertDate(opp.fechaentrega__c);
                    wrap.motivoPerdida = opp.RazonVentaPerdida__c;
                    wrap.Distribuidor = opp.Distribuidor__c;
                    wrap.FechaCreacionContacto = Conlist[0].Id;
                    wrap.IdUsuario = opp.OwnerId;
                    wrap.NombreUsuario = opp.Owner.Name;
                    wrap.Tiene_Actividad='FALSE';
                    wrap.Tipo_Registro='Opportunity';
                    wrap.NombreVitrina = opp.vitrinaSala__c;
                    wrap.Modelo_Actual = opp.NombreProducto__c;
                    if(opp.CreatedDate >= dts){
                        wrap.Nuevo_Registro='TRUE';
                    }
                    else{
                        wrap.Nuevo_Registro='FALSE';
                    }
                    oppwrpList.add(wrap);
                    
                    //wrap.EstadoSeguimiento = '';
                    //wrap.NombreVitrina = '';
                }
            } 
        }
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        Map<String, Object> data = new Map<String, Object>();
        data.put('data', oppwrpList);
        String oppbody = Json.serializePretty(data);
        String oppbody2 = Json.serializePretty(oppwrpList);
        system.debug('Salida Json 123: '+oppbody2);
        /*oppbody = oppbody.replace('Tiene_Actividad', 'Tiene Actividad');
oppbody = oppbody.replace('Tipo_Registro','Tipo Registro');
oppbody = oppbody.replace('Nuevo_Registro','Nuevo Registro');*/
        System.debug('oppbody :: ' + oppbody);
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('content-type', 'application/json');
        req.setEndpoint(System.Label.OppActivityUploader_URL);
        req.setBody(oppbody);
        
        if(!Test.isRunningTest()){
            HttpResponse response = new Http().send(req);
            response.getBody();
            System.debug('Body ' + response.getBody()); 
        }
    }
    
    public String convertDate(date dt)
    {
        return BatchActivityUploaderBase.convertDate(dt);
    }
    
    public Set<String> getSubjects(String objectName, String fieldName)
    {
        return BatchActivityUploaderBase.getSubjects(objectName, fieldName);
    }
    
    public class OppWrapperClass{
        public String TipoActividad;
        public String FechaCreacion;
        public String idActividad;
        public String IdOportunidad;
        public String NombreOportunidad;
        public String idOportunidadUsuario;
        public String FechaCreacionContacto;
        public String IdUsuario;
        public String NombreUsuario;
        public String NombreVitrina;
        public String Marca;
        public String FechaEstimadadeCompra;
        public String EstadoSeguimiento;
        public String EstadoOportunidad;
        public String fechaentrega;
        public String motivoPerdida;
        public String FechaCreacionOportunidad;
        public String IdContactoOportunidad;
        public String origendelprospecto;
        public String MedioDigital;
        public String FechaPedido;
        public String Facturado;
        public String fechafactura;
        public String Entregado;
        public String Distribuidor;
        public string IdContacto;
        public string Tiene_Actividad;
        public string Tipo_Registro;
        public string Nuevo_Registro;
        public string Modelo_Actual;
        
        
        
        public OppWrapperClass(){
            TipoActividad = '';
            idActividad = '';
            IdOportunidad = '';
            NombreOportunidad = '';
            idOportunidadUsuario = '';
            FechaCreacionContacto = '';
            IdUsuario = '';
            NombreUsuario = '';
            NombreVitrina = '';
            Marca = '';
            FechaEstimadadeCompra = '';
            EstadoSeguimiento = '';
            EstadoOportunidad = '';
            fechaentrega = '';
            motivoPerdida ='';
            FechaCreacionOportunidad = '';
            IdContactoOportunidad = '';
            origendelprospecto = '';
            MedioDigital = '';
            FechaPedido = '';
            Facturado = '';
            fechafactura = '';
            Entregado = '';
            Distribuidor = '';
            IdContacto='';
            Tiene_Actividad='';
            Tipo_Registro='';
            Nuevo_Registro='';
            Modelo_Actual='';
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        BatchActivityUploaderBase.sendDataflowSignal('end', null, System.Label.OppActivityUploaderURL_SE, 'oppbody');
    }
}
