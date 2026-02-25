/**
 * @description       : Service Class for getting data related to work steps
 * @author            : Marco Hernandez
 * @group             : Redmotors
 * @last modified on  : 09-03-2022
 * @last modified by  : marcohernandezhp@gmail.com
**/
public class WorkStepWrapper {
    
    // final static String GRAY = '#ffffff';
    // final static String BLUE = '#eafbfe';
    // final static String GREEN = '#f2f8e7';
    // final static String RED = '#fb617b';
    // final static String ORANGE = '#f8efe1';
    // final static String BLACK = '#23282c';
    // final static String WHITE = '#ffffff';
    public List<WorkStep> childWorkStepList = new List<WorkStep>();         

    @AuraEnabled
    public String id;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String workServiceType;    
    @AuraEnabled
    public String mechanicId;
    @AuraEnabled
    public String mechanicName;
    @AuraEnabled
    public String customerId;
    @AuraEnabled
    public String customerName;
    @AuraEnabled
    public String caseId;
    @AuraEnabled
    public String caseNumber;    
    @AuraEnabled
    public String stageName;
    @AuraEnabled
    public String workOrderStageName;    
    @AuraEnabled
    public String vehicleId;
    @AuraEnabled
    public String vehiclePlateNumber;
    @AuraEnabled
    public String workOrderId;
    @AuraEnabled
    public String workOrderNumber;
    @AuraEnabled
    public DateTime startTime;
    @AuraEnabled
    public String startTimeText;    
    @AuraEnabled
    public DateTime endTime;
    
    @AuraEnabled
    public DateTime startDateTimePause;

    @AuraEnabled
    public DateTime endDateTimePause;    

    @AuraEnabled
    public String endTimeText;

    @AuraEnabled
    public Date createdDate;
    
    @AuraEnabled
    public Decimal startingMinutes = 0;

    @AuraEnabled
    public Decimal minutesPausedAcum = 0;

    @AuraEnabled
    public Decimal workedHours;

    @AuraEnabled
    public Integer percentageWorkCompleted;

    @AuraEnabled
    public Decimal minutesWorked = 0;
    public String timeZone = 'America/Costa_Rica';

    @AuraEnabled
    public String lightColor = '';

    @AuraEnabled
    public Boolean isParent = false;

    public WorkStepWrapper(WorkStep workStep) {
        this.id = workStep?.Id;
        this.name = workStep?.Name;
        this.caseId = workStep?.Caso__c;
        this.minutesPausedAcum = workStep?.AcumuladoMinutosPausas__c;
        this.startDateTimePause = workStep?.Hora_de_inicio_de_pausa__c;
        this.caseNumber = (workStep != null && workStep.Caso__r != null) ? workStep.Caso__r.CaseNumber : null;
        this.workServiceType = workStep?.CT_TipoDeTrabajoDelCaso__c;
        this.stageName = workStep?.Status;
        this.workOrderStageName = (workStep != null && workStep.WorkOrder != null) ? workStep.WorkOrder.StatusDetail__c : null;
        this.vehiclePlateNumber = workStep?.CT_Placa__c;
        this.workOrderId = (workStep != null && workStep.WorkOrderId != null) ? workStep.WorkOrderId : null;
        this.workOrderNumber = workStep?.CT_NombreOrdenDeTrabajo__c;
        this.customerId = (workStep != null && workStep.WorkOrder != null) ? workStep.WorkOrder.AccountId : null;
        this.customerName = workStep?.CT_AccountName__c;
        this.mechanicName = (workStep != null && workStep.CT_AsignadoA__c != null) ? workStep.CT_AsignadoA__c : '';
        this.startTime = (workStep != null) ? workStep.StartTime : null;
        this.endTime = (workStep != null) ? workStep.EndTime : null;
        this.createdDate = (workStep != null) ? workStep.createdDate.date() : null;            

        //obtener las horas iniciales, si no tiene tareas hijas o si es padre, las horas iniciales se optionen del tipo de trabajo, en otro caso se obtienen del subtipo de trabajo
        if (workStep != null && workStep.Tipo_de_trabajo_del_caso__c != null && (workStep.Tipo_de_trabajo_del_caso__r.CT_Total_Subtareas_FM__c == 0|| workStep.CT_TieneSubtipo__c == false)){
            this.startingMinutes = workStep.Tipo_de_trabajo_del_caso__r.CT_Total_Subtareas_FM__c != null ? workStep.Tipo_de_trabajo_del_caso__r.CT_Total_Subtareas_FM__c : 0;
        }else if(workStep != null && workStep.Subtipos_de_trabajos_del_caso__r != null && workStep.Subtipos_de_trabajos_del_caso__r.size() > 0){
            this.startingMinutes = workStep.Subtipos_de_trabajos_del_caso__r[0].Cantidad_de_horas__c != null ? workStep.Subtipos_de_trabajos_del_caso__r[0].Cantidad_de_horas__c : 0;
        }

        //dado que son horas, se multiplica por 60 min
        this.startingMinutes *= 60;
        this.minutesWorked = workStep != null && workStep.Total_de_tiempo_trabajado_en_minutos__c != null ? workStep.Total_de_tiempo_trabajado_en_minutos__c : 0;                    

        // this.startTimeText = (workStep != null && workStep.StartTime != null) ? workStep.StartTime.format('yyyy-MM-dd h:mm a',timeZone): 'Sin fecha';
        // this.endTimeText = (workStep != null && workStep.EndTime != null) ? workStep.EndTime.format('yyyy-MM-dd h:mm a',timeZone): 'Sin fecha';
    }
}