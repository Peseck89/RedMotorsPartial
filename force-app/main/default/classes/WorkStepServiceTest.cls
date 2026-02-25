/**
 * @description       : Test Class for WorkStepService
 * @author            : Marco Hernandez
 * @group             : Redmotors
 * @last modified on  : 06-06-2023
 * @last modified by  : marcohernandezhp@gmail.com
**/
@isTest
public class WorkStepServiceTest {
    
    static String userEmail = 'marcotest@test.com';
    static String workStepName = 'cambio de aceite test';
    static String vehiclePlate = 'ABCTEST01';

    @TestSetup
    static void makeData(){
        TestDataFactory.prepareConsoleRecords();        
    }

    @IsTest
    public static void unitTestValidateCaseFilter(){
        Case caso = [SELECT Id,caseNumber FROM Case LIMIT 1];   
 
        Map<String,Object> responseMap = new Map<String,Object>(); 
        List<WorkStepWrapper> workStepList = new List<WorkStepWrapper>();        
        responseMap = WorkStepService.getWorkSteps(null, null, null, caso.CaseNumber, null, null, null, null, null, null, null);
        Boolean isSameCase = true;        
        workStepList = (List<WorkStepWrapper>) responseMap.get('workStepWrapperList');        
        for (WorkStepWrapper workStepWrapper : workStepList) {
            if (workStepWrapper.caseNumber != caso.CaseNumber) {
                isSameCase = false;
            }
        }

        System.assert(caso.CaseNumber != null,'El assert esperaba un numero de caso valido.'); 
        System.assert(workStepList.size() > 0,'El assert espera al menos un registro de work step.');        
        System.assert(isSameCase,'El assert espera registros relacionados al mismo caso.');   
        
        responseMap = WorkStepService.getWorkSteps(null, null, null, '00000001', null, null, null, null, null, null,null);
        workStepList = (List<WorkStepWrapper>) responseMap.get('workStepWrapperList');
        System.assert(workStepList.size() == 0,'El assert espera cero registros de work step.');
    }

    @IsTest
    public static void unitTestValidateWorkOrderNumberFilter(){
        Case caso = [SELECT (SELECT WorkOrderNumber FROM WorkOrders LIMIT 1) FROM Case LIMIT 1];
        String workOrderNumber = caso.WorkOrders[0].WorkOrderNumber;
 
        Map<String,Object> responseMap = new Map<String,Object>(); 
        List<WorkStepWrapper> workStepList = new List<WorkStepWrapper>();
        responseMap = WorkStepService.getWorkSteps(null, null, null, null, workOrderNumber, null, null, null, null, null, null);
        Boolean sameWorkOrder = true;        
        workStepList = (List<WorkStepWrapper>) responseMap.get('workStepWrapperList');        
        for (WorkStepWrapper workStepWrapper : workStepList) {
            if (workStepWrapper.workOrderNumber != workOrderNumber) {
                sameWorkOrder = false;
            }
        }

        System.assert(workOrderNumber != null,'El assert esperaba un numero de caso valido.'); 
        System.assert(workStepList.size() > 0,'El assert espera al menos un registro de work step.');        
        System.assert(sameWorkOrder,'El assert espera registros relacionados al mismo caso.');   
        
        responseMap = WorkStepService.getWorkSteps(null, null, null, null, '00000001', null, null, null, null, null, null);
        workStepList = (List<WorkStepWrapper>) responseMap.get('workStepWrapperList');
        System.assert(workStepList.size() == 0,'El assert espera cero registros de work step.');
        
    }
    
    @IsTest
    public static void unitTestValidateStartDateFilter(){        
        Account account = [SELECT Id FROM Account LIMIT 1];
        RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Contacto_de_Taller' LIMIT 1];

        Contact mechanic = TestDataFactory.createContact('testname','testlast',account,recordType.Id,true);        

        Case caso = [SELECT Id,CaseNumber FROM Case LIMIT 1];
        WorkStep workStep = [SELECT Id,StartTime,EndTime,Fecha_Inicio_FM__c,Caso__r.CaseNumber,Mec_nico_asignado__c FROM WorkStep WHERE Caso__c =:caso.Id LIMIT 1];
        
        DateTime currentTime = System.now();
        workStep.StartTime = currentTime;
        workStep.Mec_nico_asignado__c = mechanic.Id;
        update workStep;

        Date currentDate = currentTime.date();

        workStep = [SELECT Id,WorkOrder.CT_Fecha_Creacion_FM__c,EndTime,Fecha_Inicio_FM__c FROM WorkStep WHERE Caso__c =:caso.Id LIMIT 1];

        //Agregar regla, no permite setear star time si no se tiene mecanico
 
        Map<String,Object> responseMap = new Map<String,Object>(); 
        List<WorkStepWrapper> workStepList = new List<WorkStepWrapper>();

        responseMap = WorkStepService.getWorkSteps(null, null, null, null, null, null, null, currentDate, null, null, null);

        Set<Id> caseIds = new Set<Id>();
        caseIds.add(caso.Id);
        WorkStepService.getTiemposImproductivos(null);
        WorkStepService.getTiemposImproductivos(caseIds);

        responseMap = WorkStepService.getWorkStepsForReports(null,null,null,null,null,false);  
        responseMap = WorkStepService.getWorkStepsForReports(new List<String>(),null,null,null,null,false);
        // responseMap = WorkStepService.getWorkStepsForReports(null,mechanic.Id,caso.CaseNumber,null,null);
        
        
        tiposDeTrabajo__c tipoTrabajo = [SELECT Id FROM tiposDeTrabajo__c LIMIT 1];

        Horas_improductivas_por_mec_nico__c hipm = TestDataFactory.createTiempoImproductivoMecanico(caso,mechanic,tipoTrabajo, true);

        WorkStepService.TIWrrp  tiWrrp = new WorkStepService.TIWrrp(null,null);
        WorkStepService.TIWrrp.getMinutosPausa(null);
        WorkStepService.TIWrrp.getMinutosPausa(hipm);
    
        WorkStepService.dummy();
        // Boolean sameDate = true;        
        // workStepList = (List<WorkStepWrapper>) responseMap.get('workStepWrapperList'); 

        // for (WorkStepWrapper workStepWrapper : workStepList) {
        //     if (workStepWrapper.StartTime.date() != currentDate) {
        //         sameDate = false;
        //     }
        // }
 
        // System.assert(workStepList.size() > 0,'El assert espera al menos un registro de work step.');        
        // System.assert(sameDate,'El assert espera registros relacionados al mismo caso.'); 
        

        // responseMap = WorkStepService.getWorkSteps(null, null, null, null, null, null, null, currentDate, currentDate, null, null);
        // sameDate = true;        
        // workStepList = (List<WorkStepWrapper>) responseMap.get('workStepWrapperList'); 

        // for (WorkStepWrapper workStepWrapper : workStepList) {
        //     if (!(workStepWrapper.startTime.date() >= currentDate && workStepWrapper.startTime.date() <= currentDate)) {
        //         sameDate = false;
        //     }
        // }
        // System.assert(workStepList.size() > 0,'El assert espera al menos un registro de work step valida fecha inicio y fecha fin.');        
        // System.assert(sameDate,'El assert espera registros relacionados al mismo caso, se valida fecha inicio y fecha fin.');         

        
        // responseMap = WorkStepService.getWorkSteps(null, null, null, null, null, null, null, currentDate.addDays(1), null, null, null);
        // workStepList = (List<WorkStepWrapper>) responseMap.get('workStepWrapperList');
        // System.assert(workStepList.size() == 0,'El assert espera cero registros de work step.');
    }  
       

    @IsTest
    public static void unitTestValidateVehicleFilter(){
        Map<String,Object> responseMap = new Map<String,Object>(); 
        List<WorkStepWrapper> workStepList = new List<WorkStepWrapper>();
        responseMap = WorkStepService.getWorkSteps(null, null, null, null, null, null, vehiclePlate, null, null, null, null);
        Boolean isSameVehiclePlateNumber = true;        
        workStepList = (List<WorkStepWrapper>) responseMap.get('workStepWrapperList');        
        for (WorkStepWrapper workStepWrapper : workStepList) {
            if (workStepWrapper.vehiclePlateNumber != vehiclePlate) {
                isSameVehiclePlateNumber = false;
            }
        }

        // System.assert(workStepList.size() > 0,'El assert espera al menos un registro de work step.');        
        System.assert(isSameVehiclePlateNumber,'El assert espera registros relacionados al mismo caso.');   
        
        responseMap = WorkStepService.getWorkSteps(null, null, null, null, null,null, '001', null, null, null, null);
        workStepList = (List<WorkStepWrapper>) responseMap.get('workStepWrapperList');
        System.assert(workStepList.size() == 0,'El assert espera cero registros de work step.');
    }
    
    @IsTest
    public static void unitTestValidateCreationDateFilter(){
        Case caso = [SELECT Id FROM Case LIMIT 1];
        WorkStep workStep = [SELECT Id,CreatedDate,Fecha_Creacion_FM__c FROM WorkStep WHERE Caso__c =:caso.Id LIMIT 1];
        
        Map<String,Object> responseMap = new Map<String,Object>(); 
        List<WorkStepWrapper> workStepList = new List<WorkStepWrapper>();

        responseMap = WorkStepService.getWorkSteps(null, null, null, null, null, null, null, workStep.Fecha_Creacion_FM__c, workStep.Fecha_Creacion_FM__c, null,null);
        Boolean sameDate = true;        
        workStepList = (List<WorkStepWrapper>) responseMap.get('workStepWrapperList'); 

        for (WorkStepWrapper workStepWrapper : workStepList) {
            if (workStepWrapper.createdDate != workStep.Fecha_Creacion_FM__c) {
                sameDate = false;
            }
        }
 
        System.assert(workStepList.size() > 0,'El assert espera al menos un registro de work step.');        
        System.assert(sameDate,'El assert espera registros relacionados al mismo caso.'); 
    }

    @IsTest
    public static void unitTestGetTasksGroupedByCaseGeneral(){                 
        WorkStepService.getTasksGroupedByCase(null, null, null, null, null, null, null, null, null, null, null);
    }

}