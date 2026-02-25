public without sharing class HorasImproductivasMecanicoTriggerHandler extends TriggerHandler{

    private List<Horas_improductivas_por_mec_nico__c> newRecordList{get;set;}
    private List<Horas_improductivas_por_mec_nico__c> oldRecordList{get;set;}
    private Map<Id, Horas_improductivas_por_mec_nico__c> newRecordMap{get;set;}
    private Map<Id, Horas_improductivas_por_mec_nico__c> oldRecordMap{get;set;}
    public static Boolean flagFirstTime = true;

    public HorasImproductivasMecanicoTriggerHandler () {
        this.newRecordList = (List<Horas_improductivas_por_mec_nico__c>) Trigger.New;
        this.oldRecordList = (List<Horas_improductivas_por_mec_nico__c>) Trigger.Old;
        this.newRecordMap = (Map<Id, Horas_improductivas_por_mec_nico__c>) Trigger.newMap;
        this.oldRecordMap = (Map<Id, Horas_improductivas_por_mec_nico__c>)  Trigger.oldMap;                      
    }    

	public override void afterInsert(){                  
        // List<Horas_improductivas_por_mec_nico__c> recordsToInsertList = new List<Horas_improductivas_por_mec_nico__c>();
        // for (Horas_improductivas_por_mec_nico__c newRecord : newRecordList) {            

        //     if (newRecord.Se_repite__c != 'No repetir') {
        //         recordsToInsertList.addAll(HorasImproductivasMecanicoTriggerHelper.createRecords(newRecord));
        //     }
        // }
        // if (recordsToInsertList.size() > 0) {
        //     TriggerHandler.bypass('HorasImproductivasMecanicoTriggerHandler');
        //     insert recordsToInsertList;
        //     createWorkStepLogStatus(recordsToInsertList);
        //     TriggerHandler.clearBypass('HorasImproductivasMecanicoTriggerHandler');
        // }
    }

    public override void beforeDelete(){
        // List<Horas_improductivas_por_mec_nico__c> recordsToDeleteList = new List<Horas_improductivas_por_mec_nico__c>();        
        // recordsToDeleteList = [SELECT Id,HIM__c FROM Horas_improductivas_por_mec_nico__c WHERE HIM__c IN :oldRecordMap.keySet() ];        
        // if (recordsToDeleteList.size() > 0) {
        //     delete recordsToDeleteList;
        // } 
    } 

    /**
    * @description registra los tiempos improductivos en la tabla de log de estatus ligado al mecanico
    * @param newHIMList Lista con los registros de horas improductivas por mecanico.
    **/
    // public static void createWorkStepLogStatus(List<Horas_improductivas_por_mec_nico__c> newHIMList) {
    //     List<Log_Status__c> newLogStatusList = new List<Log_Status__c>();
    //     for (Horas_improductivas_por_mec_nico__c newHIM : newHIMList) {            
    //         if(newHIM.Id != null) {                    
    //             newLogStatusList.add(new Log_Status__c(
    //                 Hora_Improductiva_Mecanico__c = newHIM.Id,
    //                 New_Value__c = 'Tiempo improductivo',
    //                 Old_Value__c = null,
    //                 Mecanico__c = newHIM.Mecanico__c,
    //                 Start_Date_Time__c = Datetime.newInstance(newHIM.Inicio__c, newHIM.Hora_inicio__c),
    //                 End_Date_Time__c = Datetime.newInstance(newHIM.Fin__c, newHIM.Hora_fin__c)
    //             ));
    //         }
    //     }
    //     if (newLogStatusList.size() > 0) {
    //         insert newLogStatusList;
    //     }
    // }
}