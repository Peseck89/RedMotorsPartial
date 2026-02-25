public with sharing class cT_reporteHorasFac {


    @AuraEnabled(cacheable=true)
    public static List<WorkStepCantWrapper> getCantidad(String fechaIni, String fechaFin){
        Id recordTypeId =
        Schema.SObjectType.Contact.getRecordTypeInfosByName()
        .get('Contacto de Taller').getRecordTypeId();
        List<Contact> lstContactos = [SELECT Id,Name FROM Contact WHERE RecordTypeId = :recordTypeId];

        String query = 'Select Id,CT_CantidadDeHoras__c,Mec_nico_asignado__c,Total_de_tiempo_trabajado_en_minutos__c FROM WorkStep';
        String stringConditions = '';
        if(String.isNotBlank(fechaIni)){
            stringConditions += String.isNotBlank(stringConditions) ? ' AND' : '';

            stringConditions += ' StartTime >= '+DateTime.valueOfGMT(fechaIni + ' 00:00:00').format('yyyy-MM-dd\'T\'hh:mm:ss\'z\'','America/Costa_Rica');
        }
        
        if(String.isNotBlank(fechaFin)){
            stringConditions += String.isNotBlank(stringConditions) ? ' AND' : '';
            stringConditions += ' StartTime <= '+DateTime.valueOfGMT(fechaFin + ' 00:00:00').format('yyyy-MM-dd\'T\'hh:mm:ss\'z\'','America/Costa_Rica');            
        } 
        if(String.isNotBlank(stringConditions)){
            query += ' WHERE '+stringConditions ;
        }


        String queryIm = 'Select Id,Mecanico__c,Inicio_de_tiempo_Improductivo__c,Fin_de_tiempo_Improductivo__c FROM Horas_improductivas_por_mec_nico__c';
        String stringConditions1 = '';
        if(String.isNotBlank(fechaIni)){
            stringConditions1 += String.isNotBlank(stringConditions1) ? ' AND' : '';

            stringConditions1 += ' Inicio_de_tiempo_Improductivo__c >= '+DateTime.valueOfGMT(fechaIni + ' 00:00:00').format('yyyy-MM-dd\'T\'hh:mm:ss\'z\'','America/Costa_Rica');
        }
        
        if(String.isNotBlank(fechaFin)){
            stringConditions1 += String.isNotBlank(stringConditions1) ? ' AND' : '';
            stringConditions1 += ' Inicio_de_tiempo_Improductivo__c <= '+DateTime.valueOfGMT(fechaFin + ' 00:00:00').format('yyyy-MM-dd\'T\'hh:mm:ss\'z\'','America/Costa_Rica');            
        } 
        if(String.isNotBlank(stringConditions1)){
            queryIm += ' WHERE '+stringConditions1 ;
        }
        Integer dias = 0;
        Integer dt1 = (Date.valueOf(fechaIni)).daysBetween(Date.valueOf(fechaFin));
        Date fechaI = Date.valueOf(fechaIni);
        Date fechaF = Date.valueOf(fechaFin);
        for(Integer i = 0; i<dt1; i++){
            fechaI = fechaI.addDays(i);
            Datetime dt = (DateTime)fechaI;
            String dayOfWeek = dt.format('EEEE');
            if (dayOfWeek != 'Saturday' && dayOfWeek != 'Sunday') {
                dias= dias+1;
            }
        }



        List<WorkStepCantWrapper> workStepWrapperList = new List<WorkStepCantWrapper>(); 
        try {           
            List<WorkStep> workStepList = (List<WorkStep>) Database.query(query);
            List<Horas_improductivas_por_mec_nico__c> horasList = (List<Horas_improductivas_por_mec_nico__c>) Database.query(queryIm);
            for(Contact contactCurso:lstContactos){
                String Id = '';
                String Contacto = '';
                Decimal cantidad = 0; 
                Decimal trabajado = 0;

                //Tiempo Improductivo
                Long dt1Long = 0;
                Long dt2Long = 0;
                long totalSuma = 0;
                for(WorkStep ordenCurso:workStepList){
                    if(contactCurso.Id == ordenCurso.Mec_nico_asignado__c && ordenCurso.CT_CantidadDeHoras__c != null){
                            Id = ordenCurso.Id;
                            cantidad = cantidad + ordenCurso.CT_CantidadDeHoras__c;
                            Contacto = ordenCurso.Mec_nico_asignado__c;        
                            trabajado = trabajado + ordenCurso.Total_de_tiempo_trabajado_en_minutos__c;  
                                           
                    }                  
                }     
                for (Horas_improductivas_por_mec_nico__c hImp : horasList) {
                    if(contactCurso.Id == hImp.Mecanico__c){
                        dt1Long = (hImp.Inicio_de_tiempo_Improductivo__c).getTime();
                        dt2Long = (hImp.Fin_de_tiempo_Improductivo__c).getTime();
                        Long milliseconds = dt2Long - dt1Long;
                        Long seconds = milliseconds / 1000;
                        Long minutes = seconds / 60;
                        Long hours = minutes / 60;
                        totalSuma = totalSuma + hours;
                    }  
                }   
                if (!String.isBlank(Id) && !String.isBlank(Contacto)) {
                    workStepWrapperList.add(new WorkStepCantWrapper(Id,cantidad,Contacto,trabajado,dias,totalSuma));    
                }
                
            } 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('Cadena ' + workStepWrapperList);
        return workStepWrapperList;
    }


    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacto(){
        Id recordTypeId =
        Schema.SObjectType.Contact.getRecordTypeInfosByName()
        .get('Contacto de Taller').getRecordTypeId();
        List<Contact> lstContactos = [SELECT Id,Name FROM Contact WHERE RecordTypeId = :recordTypeId];
        return lstContactos;
    }


    @AuraEnabled(cacheable=true)
    public static List<WorkOrder> getOrdenes(String fechaIni, String fechaFin){
        Id recordTypeId =
        Schema.SObjectType.Contact.getRecordTypeInfosByName()
        .get('Contacto de Taller').getRecordTypeId();

        String query = 'SELECT Id,ContactId,WorkOrderNumber FROM WorkOrder';
        String stringConditions = '';
        if(String.isNotBlank(fechaIni)){
            stringConditions += String.isNotBlank(stringConditions) ? ' AND' : '';

            stringConditions += ' CreatedDate >= '+DateTime.valueOfGMT(fechaIni + ' 00:00:00').format('yyyy-MM-dd\'T\'hh:mm:ss\'z\'','America/Costa_Rica');
        }
        
        if(String.isNotBlank(fechaFin)){
            stringConditions += String.isNotBlank(stringConditions) ? ' AND' : '';
            stringConditions += ' CreatedDate <= '+DateTime.valueOfGMT(fechaFin + ' 00:00:00').format('yyyy-MM-dd\'T\'hh:mm:ss\'z\'','America/Costa_Rica');            
        } 
        if(String.isNotBlank(stringConditions)){
            query += ' WHERE '+stringConditions;
        }
        List<Contact> lstContactos = [SELECT Id,Name FROM Contact WHERE RecordTypeId = :recordTypeId];
        List<WorkOrder> ordenes = (List<WorkOrder>) Database.query(query);

        List<WorkOrder> ordenesFilt = new List<WorkOrder>();
        for(Contact contactCurso:lstContactos){
            for(WorkOrder ordenCurso:ordenes){
                if(contactCurso.Id == ordenCurso.contactId ){
                    ordenesFilt.add(ordenCurso);
                }
            }        
        }   
        return ordenesFilt;
    }

    @AuraEnabled(cacheable=true)
    public static List<WorkStepWrapper> getWorkStep(String fechaIni, String fechaFin){
        //List<Contact> lstContactos = [SELECT Id FROM Contact  WHERE RecordTypeId = :recordTypeId];
        String query = 'SELECT Id,Mec_nico_asignado__c,WorkOrderId,CT_CantidadDeHoras__c,Total_de_tiempo_trabajado_en_minutos__c FROM workstep  ';
        System.debug('@@@@@@@@@@@@@@query@@@@@@@@@@@@@@@'+query);
        String stringConditions = '';
        if(String.isNotBlank(fechaIni)){
            stringConditions += String.isNotBlank(stringConditions) ? ' AND' : '';

            stringConditions += ' StartTime >= '+DateTime.valueOfGMT(fechaIni + ' 00:00:00').format('yyyy-MM-dd\'T\'hh:mm:ss\'z\'','America/Costa_Rica');
        }
        
        if(String.isNotBlank(fechaFin)){
            stringConditions += String.isNotBlank(stringConditions) ? ' AND' : '';
            stringConditions += ' StartTime <= '+DateTime.valueOfGMT(fechaFin + ' 00:00:00').format('yyyy-MM-dd\'T\'hh:mm:ss\'z\'','America/Costa_Rica');            
        } 
        
        if(String.isNotBlank(stringConditions)){
            query += ' WHERE '+stringConditions;
        }
        List<WorkStepWrapper> workStepWrapperList = new List<WorkStepWrapper>(); 
        try {           
            List<WorkStep> workStepList = (List<WorkStep>) Database.query(query);
            for (WorkStep workStep : workStepList) {
                workStepWrapperList.add(new WorkStepWrapper(workStep));
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return workStepWrapperList;
    }


    public class WorkStepWrapper {
        @AuraEnabled
        public String Id {get;set;}        
        @AuraEnabled
        public String ContactId {get;set;}
        @AuraEnabled
        public Decimal horasReales {get;set;}
        @AuraEnabled
        public Decimal horasTardadas {get;set;}
        @AuraEnabled
        public Decimal horasFacturadas {get;set;}
        @AuraEnabled
        public String WorkOrderId {get;set;}
        public WorkStepWrapper(WorkStep workStep){
            this.Id = workStep.Id;
            this.ContactId = (workStep.Mec_nico_asignado__c != null ) ? workStep.Mec_nico_asignado__c : null;
            this.horasReales = (workStep.CT_CantidadDeHoras__c!= null ) ? workStep.CT_CantidadDeHoras__c : null;
            this.horasTardadas = (workStep.Total_de_tiempo_trabajado_en_minutos__c!= null ) ? (workStep.Total_de_tiempo_trabajado_en_minutos__c/60).setScale(4) : null;
            this.WorkOrderId = (workStep.WorkOrderId!= null ) ? workStep.WorkOrderId : null;

        }
    }

    public class WorkStepCantWrapper {
        @AuraEnabled
        public String Id {get;set;}        
        @AuraEnabled
        public String ContactId {get;set;}
        @AuraEnabled
        public Decimal horasReales {get;set;}
        @AuraEnabled
        public Decimal horasTotales {get;set;}
        @AuraEnabled
        public Decimal horasProd {get;set;}
        @AuraEnabled
        public Decimal horasEfici {get;set;}

        public WorkStepCantWrapper(String Id, Decimal cantidad,String Contacto, Decimal horasT,Integer dias,Long improd){
            System.debug('valores ' + id + cantidad + Contacto);
            if (!String.isBlank(Id) && !String.isBlank(Contacto)) {
                this.Id = (Id!= null ) ? Id : null;
                this.ContactId =  (Contacto!= null ) ? Contacto : null;
                this.horasReales = (cantidad!= null ) ? cantidad : null;
                this.horasTotales = (horasT!= null ) ? (horasT/60).setScale(4) : null;
                this.horasProd = (horasReales!= null ) ? (((horasReales/8)*dias)-improd).setScale(4) : null;
                this.horasEfici =  (horasT!= null ) ? (((horasT/60).setScale(4))/cantidad).setScale(4) : null;
            }

        }
    }

}