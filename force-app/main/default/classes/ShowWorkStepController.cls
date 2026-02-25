public without sharing class ShowWorkStepController {
    //Filter1
    @AuraEnabled
    public static List<String> getAllTerritoy()
    {
        List<String> filter1List = new List<String>();
        for(ServiceTerritory st : [SELECT Name FROM ServiceTerritory ORDER BY Name asc])
        {
            filter1List.add(st.Name);
        }
        system.debug(filter1List);
        return filter1List;
    }
    
    //Filter2
    @AuraEnabled
    public static List<String> getTipoDeServicio()
    {
        List<String> filter2List = new List<String>();
        String strObjectName = 'WorkOrder';
        String strPicklistField = 'Tipo_de_servicio__c';
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) 
        {
            if(objPickList.isActive())
            {
                 filter2List.add(objPickList.getLabel());
            	System.debug('Value = ' +objPickList.getValue() +' , Label = ' +objPickList.getLabel());
            }           
        }
        return filter2List;
    }
    
    //Filter3
    @AuraEnabled
    public static List<String> getuserList()
    {
        List<String> filter3List = new List<String>();
        for(User st : [SELECT Name FROM User ORDER BY Name asc])
        {
            filter3List.add(st.Name);
        }
        return filter3List;        
    }
    
    //Filter4
    @AuraEnabled
    public static List<String> getStatus()
    {
        List<String> filter4List = new List<String>();
        String strObjectName = 'WorkStep';
        String strPicklistField = 'Status';
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) 
        {
            if(objPickList.isActive())
            {
                filter4List.add(objPickList.getLabel());
            	System.debug('Value = ' +objPickList.getValue() +' , Label = ' +objPickList.getLabel());
            }            	
        }
        return filter4List;
    }
    
    @AuraEnabled
    public static ResponeWrapper getFilteredDate(String filter1, String filter2, String filter3, String filter4fromDate,
                                                 String filter5ToDate, string filter6status, String pageSize, String pageNumber)
    {
        Integer pSize = Integer.valueOf(pageSize);
        //Integer pNumber = Integer.valueOf(pageNumber)-1;
        Integer pNumber = Integer.valueOf(pageNumber);
        Integer offSetValue = (pSize*pNumber);
        Integer totalRecords = pSize*pNumber;
        System.Debug(' pNumber ' + pNumber);
        System.Debug(' pSize ' + pSize);
        System.Debug(' offSetValue ' + offSetValue);
        System.Debug(' totalRecords ' + totalRecords);
        //filter1 = null;filter2=null;filter3=null;
        //String query = '';
        System.Debug(' filter1 ' + filter1);
        System.Debug(' filter2 ' + filter2);
        System.Debug(' filter3 ' + filter3);
        System.Debug(' filter4fromDate ' + filter4fromDate);
        System.Debug(' filter5ToDate ' + filter5ToDate);
        System.Debug(' filter6status ' + filter6status);
        String query = 'select Id, Total_de_tiempo_trabajado_en_minutos__c,Status,WorkOrder.ServiceTerritory.Name,WorkOrderId,WorkOrder.Tipo_de_servicio__c,Owner__r.Name,WorkOrder.Owner.Name,WorkOrder.CreatedDate, WorkOrder.WorkOrderNumber,WorkOrder.Asset.Name,WorkOrder.AssetId, WorkOrder.Asset.NumeroDeChasis__c,WorkOrder.Asset.modelo__c,Tiempo_trabajado_en_mins_antes_de_pausa__c,(select Id, Cantidad_de_horas__c from Subtipos_de_trabajos_del_caso__r order by LastModifiedDate desc),StartTime,Name,  Caso__r.CaseNumber, WorkPlan.Name, WorkOrder.Account.Name,WorkOrder.Fecha_de_Entrada__c, (select Contact__r.Name from Mec_nicos_por_Worskteps__r), mecanico__r.name, team__r.name,mecanico__c,team__c,AcumuladoMinutosPausas__c  from WorkStep';
        
        if(filter1 != null && filter1 != '' && filter1 != '--None--')
        {
            query += ' where WorkOrder.ServiceTerritory.Name =:filter1 ';
        }
        
        if(filter2 != null && filter2 != '' && filter2 != '--None--')
        {
            if(query.contains(' where '))
                query += ' and WorkOrder.Tipo_de_servicio__c =:filter2 ';
            else
                query += ' where WorkOrder.Tipo_de_servicio__c =:filter2 ';
        }
        
        if(filter3 != null && filter3 != '')
        {
            if(query.contains(' where '))
                query += ' and  ( mecanico__c =:filter3 or team__c =:filter3 )';
            else
                query += ' where ( mecanico__c =:filter3  or team__c =:filter3 )';
        }
        if(filter4fromDate != null && filter4fromDate != '' && filter4fromDate != '--None--')
        {
            if(query.contains(' where '))
                query += ' and WorkOrder.Fecha_de_Entrada__c >=' + filter4fromDate  + '';
            else
                query += ' where WorkOrder.Fecha_de_Entrada__c >=' + filter4fromDate  + '';
           System.Debug( 'query ' + query);
           //System.debug('All records ' + [select id from WorkStep where WorkOrder.Fecha_de_Entrada__c >=:2022-12-05].size());
        }
        if(filter5ToDate != null && filter5ToDate != '' && filter5ToDate != '--None--')
        {
            if(query.contains(' where '))
                query += ' and WorkOrder.Fecha_de_Entrada__c <= ' + filter5ToDate + '';
            else
                query += ' where WorkOrder.Fecha_de_Entrada__c <=' + filter5ToDate + '';
        }
        if(filter6status != null && filter6status != '' && filter6status != '--None--' && filter6status != 'All')
        {
            if(query.contains(' where '))
                query += ' and Status =:filter6status ';
            else
                query += ' where Status =:filter6status ';
        }        
		//query +=' LIMIT :pSize OFFSET :offSetValue';
        query +=' order by WorkOrder.CreatedDate desc limit :totalRecords';
        System.debug('queryVal ' + query);
        Set<String> workOrderIds = new Set<String>();
        for(WorkStep ws : Database.query(query))
        {
            workOrderIds.add(ws.WorkOrderId);
        }
        //System.debug('workOrderIds ' + workOrderIds);
        System.debug('All records ' + Database.query(query).size());

        Map<String, String> mapIdName = new Map<String, String>();
        for(ServiceAppointment sa :[select ParentRecordId, Subject from ServiceAppointment where ParentRecordId =:workOrderIds order by CreatedDate desc])
        {
            if(!mapIdName.containsKey(sa.ParentRecordId))
            {
                mapIdName.put(sa.ParentRecordId,sa.Subject);
            }
        }
        //System.debug('mapIdName ' + mapIdName);    
        List<WorkStepRecords> responseList = new List <WorkStepRecords>();
        Integer recordCount = 0;
        for(WorkStep ws : Database.query(query))
        {//1-20, 21-40, 41-60 
            
            //if(recordCount > pSize &&  totalRecords)//0>20, 0>40
            //    continue;
            recordCount++;
            if(recordCount <= totalRecords - pSize)//0>20, 0>40
                continue;
            
            String color='gray_ball.png';//Image for consola taller table
            String bcolor='box-shadow: 1px 0 5px 2px rgb(0 0 0 / 15%);';//BackGround color for consola taller table
            String Cantidaddehoras = null;
            double horas_trabajadas=0;
            Double horasPausadas=pausedHours(ws);//To substract from timer
            if(ws.Subtipos_de_trabajos_del_caso__r.size() > 0)
            {
                if(ws.Total_de_tiempo_trabajado_en_minutos__c!=null){horas_trabajadas=((Double)ws.Total_de_tiempo_trabajado_en_minutos__c/60);}
                if(horas_trabajadas >= ws.Subtipos_de_trabajos_del_caso__r[0].Cantidad_de_horas__c){
                    //color = 'orangered';
                    color='red_ball.png';
                    bcolor= 'box-shadow: 1px 0 5px 2px #f24242bd;';
                }
                else if(ws.Status == 'Completada' && horas_trabajadas  <= ws.Subtipos_de_trabajos_del_caso__r[0].Cantidad_de_horas__c){
                     //color = 'lightgreen';
                     color='green_ball.png';
                     bcolor = 'box-shadow: 1px 0 5px 2px #00fd54a3;';//BackGround Color#1fbc0e
                }
                else if( (ws.Status != 'Completada' && horas_trabajadas <= 0 )
                        || (horas_trabajadas > 0  && ws.Status != 'Completada') ){
						//color = 'cornflowerblue';
						color='blue_ball.png';//imagen
						bcolor = 'box-shadow: 1px 0 5px 2px #27effbad;'; //BackGround Color
				}
					
					Cantidaddehoras = String.ValueOf(ws.Subtipos_de_trabajos_del_caso__r[0].Cantidad_de_horas__c);
            }
            List<String> assciatedContacts = new List<String>();
            for(Mec_nicos_por_Worsktep__c rec1 : ws.Mec_nicos_por_Worskteps__r)
            {
                assciatedContacts.add(rec1.Contact__r.Name);
            }
            string conName = null;
            if(ws.mecanico__c != null)
            {
                conName = ws.mecanico__r.name;
            }
            else
            {
                if(conName != null)
                {
                    conName = conName + '/' + ws.team__r.name;
                }
                else
                {
                    conName = ws.team__r.name;
                }
            }
            WorkStepRecords wr = new WorkStepRecords(ws.Id, ws.status,
                                                     color,bcolor,horasPausadas,ws.WorkOrder.Owner.Name, ws.WorkOrder.WorkOrderNumber,ws.WorkOrder.Asset.Name,
                                                     ws.WorkOrder.Asset.NumeroDeChasis__c, ws.WorkOrder.Asset.modelo__c,
                                                     String.valueOf((ws.Total_de_tiempo_trabajado_en_minutos__c)), Cantidaddehoras, String.valueOf(ws.StartTime),
                                                     mapIdName.get(ws.WorkOrderId),ws.Name,ws.Caso__r.CaseNumber,
                                                     ws.WorkPlan.Name,ws.WorkOrder.Account.Name,conName,ws.WorkOrder.AssetId,ws.WorkOrderId,String.valueOf(ws.WorkOrder.CreatedDate)
                                                    );
            responseList.add(wr);
        }
        System.Debug( ' responseList ' + responseList.size());
        ResponeWrapper rw = new ResponeWrapper(responseList);
        return rw;
    }
    
    //Status, StartTime, Mec_nico_asignado__c, Description
    @AuraEnabled
    public static String updateNewStatus(String recId)
    {
        String response = 'Success';
        try
        {
            WorkStep ws = [select Status from WorkStep where Id =:recId];
            ws.Status = 'Nueva';
            update ws;
        }
        catch(Exception ex)
        {
            response = ex.getMessage();
        }
        return response;
    }
    
    //Hora_de_inicio_de_pausa__c, Status
    @AuraEnabled
    public static String updatePauseStatus(String recId)
    {
        String response = 'Success';
        try
        {
            WorkStep ws = [select Status from WorkStep where Id =:recId];
            ws.Status = 'En pausa';
            ws.Hora_de_finalizaci_n_de_pausa__c=null;
            update ws;
        }
        catch(Exception ex)
        {
            response = ex.getMessage();
        }
        return response;       
    }
    
    //Hora_de_inicio_de_pausa__c, Status, Hora_de_finalizaci_n_de_pausa__c, Trabajo_Pausado__c
    @AuraEnabled
    public static String updateUnPauseStatus(String recId, String dateHoraDe)
    {
        String response = 'Success';
        try
        {
            DateTime acceptableDateTime = DateTime.Valueof(dateHoraDe.replace('T', ' '));
            String dateFormatted = acceptableDateTime.format('yyyy-MM-dd HH:mm:ss','GMT-6');
            WorkStep ws = [select Status, Hora_de_finalizaci_n_de_pausa__c from WorkStep where Id =:recId];
        	ws.Status = 'En curso';
            ws.Hora_de_finalizaci_n_de_pausa__c = DateTime.valueOfGmt(dateFormatted);
        	update ws;
        }
        catch(Exception ex)
        {
            response = ex.getMessage();
        }
        return response;
    }
    
    //StartTime , EndTime, Status, Total_de_tiempo_trabajado_en_minutos__c
    @AuraEnabled
    public static String updateCompleteStatus(String recId)
    {
         String response = 'Success';
        try
        {
           WorkStep ws = [select Status from WorkStep where Id =:recId];
        	ws.Status = 'Completada';
        	update ws;
        }
        catch(Exception ex)
        {
            response = ex.getMessage();
        }
        return response;
       
    }
    
    //Associate contact with WorkStep.
    @AuraEnabled
    public static String associateCreatedContactWithWorkStep(String workStepRecordId, String createdContactRecordId)
    {
         String response = 'Success';
        try
        {
           Mec_nicos_por_Worsktep__c mnpw = new Mec_nicos_por_Worsktep__c();
           mnpw.Work_Step__c = workStepRecordId;
           mnpw.Contact__c = createdContactRecordId;           
		   insert mnpw;
        }
        catch(Exception ex)
        {
            response = ex.getMessage();
        }
        return response;
    }
    
    @AuraEnabled
    public static String updateWorkStepOnComplete(String recId, String Status, String startDate, String endDate)
    {
        String response = 'Success';
        try
        {
            if(startDate == null || startDate == '')
                return 'Para completar una tarea debe iniciarla primero';
            System.debug('try block');
            WorkStep ws = [select Id, Status, EndTime,StartTime from WorkStep where Id=:recId limit 1];
            //if(Status != '--None--')
            //{
                ws.Status = Status;
            //}                        
            DateTime acceptableStartDateTime = DateTime.Valueof(startDate.replace('T', ' '));
            DateTime acceptableEndDateTime = DateTime.Valueof(endDate.replace('T', ' '));
            
            String startDateFormatted = acceptableStartDateTime.format('yyyy-MM-dd HH:mm:ss','GMT-6');
            String endDateFormatted = acceptableEndDateTime.format('yyyy-MM-dd HH:mm:ss','GMT-6');
            
            ws.StartTime = DateTime.valueOfGmt(startDateFormatted);
            ws.EndTime = Datetime.valueOfGmt(endDateFormatted);
            System.Debug(' ws.EndTime' + ws.EndTime);
            update ws;
        }
        catch(Exception ex)
        {
            System.debug('ex.getMessage() :: '+ex.getMessage());
            response = ex.getMessage();
        }
        return response;        
    }
    
    @AuraEnabled
    public static String updateWorkStepOnStart(String recId, String description, String Status, String contactId, 
                                                    String startDate)
    {
        //System.assert(false, ' recId ' + recId + ' description ' + description + ' Status ' + Status  + ' contactId ' + contactId +' startDate ' + startDate);
        String response = 'Success';
        try
        {
            System.debug('try block');
            WorkStep ws = [select Id, Description,Status, Mec_nico_asignado__c,StartTime from WorkStep where Id=:recId limit 1];
            ws.Description = description;
            //if(Status != '--None--')
            //{
                ws.Status = Status;
            //}
            //ws.Mec_nico_asignado__c = contactId;
            DateTime acceptableDateTime = DateTime.Valueof(startDate.replace('T', ' ')); 
            String startDateFormatted = acceptableDateTime.format('yyyy-MM-dd HH:mm:ss','GMT-6');
            ws.StartTime = DateTime.valueOfGmt(startDateFormatted);
            update ws;
        }
        catch(Exception ex)
        {
            System.debug('ex.getMessage() :: '+ex.getMessage());
            response = ex.getMessage();
        }
        return response;
    }
    
    public class ResponeWrapper {
        @AuraEnabled public List<WorkStepRecords> wmList;
        
        public ResponeWrapper(List<WorkStepRecords> wmList){
            this.wmList = wmList;
        }
    }
    
    public class WorkStepRecords {
        @AuraEnabled  public String recordId;
        @AuraEnabled  public String status;
        @AuraEnabled  public String color;
        @AuraEnabled  public String bcolor;// BackGround Color for table 
        @AuraEnabled  public double pausedHours;//Horas pausadas
        @AuraEnabled  public String workOrderOwnerName;//Work Order WorkOrder.Owner.Name
        @AuraEnabled  public String workOrderOwnerNumber;//WorkOrder.WorkOrderNumber
        @AuraEnabled  public String workOrderID;
        @AuraEnabled  public String workOrderDate;
        @AuraEnabled   public String assetName;
        @AuraEnabled public String assetID;
        @AuraEnabled public String VIN;
        @AuraEnabled public String Modelo;
        @AuraEnabled public String Tiempotrabajadoenmins;//Time worked in mins. before break
        @AuraEnabled public String Cantidaddehoras;//Cantidad de horas
        @AuraEnabled  public String StartTime;
        @AuraEnabled public String serviceAppointmentName;
        @AuraEnabled public String workStepName;
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String workPlanName;
        @AuraEnabled public String accountName;
       /* @AuraEnabled public List<string> associatedContacts = new List<string>();*/
        @AuraEnabled public String contactName;
        public WorkStepRecords(String recordId, String status, String color,String bcolor,double pausedHours,String workOrderOwnerName,String workOrderOwnerNumber, String assetName,
                               String VIN,String Modelo,String Tiempotrabajadoenmins, 
                               String Cantidaddehoras,String StartTime,String serviceAppointmentName,
                              	String workStepName,String caseNumber,
                               String workPlanName,String accountName,String contactName,String assetID, String workOrderID, String workOrderDate)
        {
            this.recordId = recordId;
            this.status = status;
            this.color = color;
            this.bcolor=bcolor; // BackGround Color for table 
            this.pausedHours=pausedHours;// to substract paused hours from timer
            this.workOrderOwnerName = workOrderOwnerName;
            this.workOrderOwnerNumber = workOrderOwnerNumber; 
            
            this.assetName = assetName;   
            this.VIN =  VIN;
            this.Modelo = Modelo;
            this.Tiempotrabajadoenmins = Tiempotrabajadoenmins;
            this.Cantidaddehoras = Cantidaddehoras;
            this.StartTime = StartTime;
            this.serviceAppointmentName = serviceAppointmentName;
            this.workStepName = workStepName;
            this.caseNumber = caseNumber;
            this.workPlanName = workPlanName;
            this.accountName = accountName;
            this.contactName = contactName;
            this.assetID=assetID;
            this.workOrderID=workOrderID;
            this.workOrderDate=workOrderDate;
        }
    }    
    public static double pausedHours(WorkStep ws){
        	//Datetime endPause= ws.Hora_de_finalizaci_n_de_pausa__c;
        	//Datetime StartPause= ws.Hora_de_inicio_de_pausa__c;
        	double pausedMinutes=ws.AcumuladoMinutosPausas__c;
        	double hours=0;
         	system.debug('MINUTOS PAUSADOS:'+pausedMinutes);
        	if(pausedMinutes!=null){
                Long milliseconds = (Long)pausedMinutes*60000;
                Long seconds = milliseconds / 1000;
                Long minutes = (Long)pausedMinutes;
                hours = ((Double) minutes) /60;
                
                double days = hours / 24;
                 System.debug(ws.Name+'horas;'+hours+'minutos:'+((Double) minutes) /60);
                }
           
        	return hours;
    }
}