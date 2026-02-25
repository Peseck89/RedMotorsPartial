import { LightningElement, api, wire, track } from 'lwc';
import { reduceErrors } from 'c/ldsUtils';
import { refreshApex } from '@salesforce/apex';
import WORK_STEP_OBJECT from '@salesforce/schema/WorkStep';
import WORK_ORDER_OBJECT from '@salesforce/schema/WorkOrder';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import WORK_STEP_STATUS_FIELD from '@salesforce/schema/WorkStep.Status';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import getCases from '@salesforce/apex/WorkStepController.getTasksGroupedByCase';
import getTerritories from '@salesforce/apex/WorkStepController.getTerritories'
import WORK_ORDER_SERVICE_TYPE from '@salesforce/schema/WorkOrder.Tipo_de_servicio__c';
import searchUsersFilterByMecanico from '@salesforce/apex/SampleLookupController.searchUsersFilterByMecanico';
import getWorkStepStatus from '@salesforce/apex/RM_CT_ConsolaTaller_Ctrl.getWorkStepStatus';

export default class CT_ShowTasksGroupedByCase extends LightningElement {
    
    @track isLoading = true;

    @track pageNumber = 1;  
    @track totalPages = 0; 
    @track totalRecords = 0; 

    showParentTasks = false;
    
    territories;    
    allTerritories = [];
    selectedTerritories = [];
    @wire(getTerritories)
    wiredTerritories({ data, error }) {
        if (data) {            
            this.territories = data.map(item => ({'label':item.Name,'value':item.Id}));            
            this.allTerritories = data.map(item => (item.Id));
            this.selectedTerritories = data.map(item => (item.Id));
        }else if (error){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Atención!',
                    message:  reduceErrors(error).join(', '),
                    variant: 'error'
                })
            );
        }
    }

    @wire(getObjectInfo, { objectApiName: WORK_STEP_OBJECT })
    workStepObject    

    workStepStatuses = [];
    allWorkStepStatuses = [];
    @track selectedWorkStepStatus = [
        'Nueva',
        'En curso',
        'En pausa'
    ];

    // @wire(getPicklistValues, {recordTypeId: '$workStepObject.data.defaultRecordTypeId',fieldApiName: WORK_STEP_STATUS_FIELD})
    // wiredWorkStepStatuses({ data, error }) {
    //     if (data) {
    //         this.workStepStatuses = data.values.map(item => ({'label':item.label,'value':item.value}));                                          
    //         this.allWorkStepStatuses = data.values.map(item => (item.value));
    //         // this.selectedWorkStepStatus = data.values.map(item => (item.value));   
    //     }else if (error){
    //         this.dispatchEvent(
    //         new ShowToastEvent({
    //             title: 'Atención!',
    //             message: result.error.body.message,
    //             variant: 'error'
    //         })
    //         );
    //     }
    // }    

    @wire(getWorkStepStatus)
    wiredWorkStepStatuses({ data, error }) {
        if (data) {
            this.workStepStatuses = data.map(item => ({'label':item.label,'value':item.value}));                                          
            this.allWorkStepStatuses = data.map(item => (item.value));
        } else if (error){
            this.dispatchEvent(
            new ShowToastEvent({
                title: 'Atención!',
                message: result.error.body.message,
                variant: 'error'
            })
            );
        }
    } 
        
    @track showFilters = false;

    //filters
    inputTallerId = 'all';
    inputOrderNumber = null;
    inputCaseNumber = null;
    inputPlate = null;
    inputVIN = null;
    inputCreationDateFrom = null;
    inputCreationDateTo = null; 
    inputMechanicId = null;
    inputEstado = 'all';

    showCaseStatus = false;
    

    @track cases; 
    @track sttcRecords; 

    customTimeOut;   

    initialSelection = [];
    errors = [];       

    @track numCaseNotStarted = 0;
    @track numCaseInProgress = 0;

    sfdcBaseURL;
    connectedCallback() {
        this.sfdcBaseURL = window.location.origin;
        this.isLoading = true;
    }    
    
    flagFirstTime = true;

    wiredCasesResult;    
    @wire(getCases, {territoryIds: "$selectedTerritories",mechanicId:'$inputMechanicId',statuses:'$selectedWorkStepStatus',caseNumber: "$inputCaseNumber", orderNumber: "$inputOrderNumber", plate: "$inputPlate", vin: "$inputVIN",creationDateFrom: "$inputCreationDateFrom", creationDateTo: "$inputCreationDateTo", pageNumber:"$pageNumber" })
    wiredCases(result) {
        this.wiredCasesResult = result;
        const { error, data } = result;
        if (data) {
            
            this.numCaseNotStarted = data.numCaseNotStarted;
            this.numCaseInProgress = data.numCaseInProgress;

            this.sttcRecords = data.sttcRecords;

            if(data.records){
                this.totalRecords = data.totalRecords ? data.totalRecords : 0;
                
                if(data.totalRecords > 0){
                    this.totalPages = Math.ceil(data.totalRecords / data.pageSize);
                }

                let records = JSON.parse(JSON.stringify(data.records))
                Object.values(data.records).forEach((record, index) => {
                    if (typeof record === "object") {                                                
                        records[index].WorkOrderId = this.getOrderId(record);                  
                        records[index].WorkOrderNumber = this.getOrderNumber(record);                  
                        records[index].approvedStatus = this.getStatusApproved(record);                  
                        records[index].placa = record.Asset && record.Asset.Name != null ? record.Asset.Name : '';
                        records[index].vin = record.Asset && record.Asset.NumeroDeChasis__c != '' ? record.Asset.NumeroDeChasis__c : '';                        

                        records[index].workOrderURL = this.sfdcBaseURL +'/'+ (records[index].WorkOrderId ? records[index].WorkOrderId : '');
                        records[index].caseURL = this.sfdcBaseURL +'/'+ (record.Id ? record.Id : '');

                        let caseVales = this.calculateValues(record);
                        console.log(caseVales);
                        
                        records[index].startingMinutes = caseVales.startingMinutes;
                        records[index].minutesWorked = caseVales.minutesWorked;
                        records[index].minutesPaused = caseVales.minutesPaused;

                        //Sin work steps relacionados
                        records[index].hasWorkStepsRelated = caseVales.hasWorkStepsRelated;
                        records[index].caseCompleted = caseVales.caseCompleted;
                        records[index].caseStarted = caseVales.caseStarted;
                        records[index].caseStarted = caseVales.caseStarted;
                        records[index].caseAssigned = caseVales.caseAssigned;
                        
                        records[index].isRed = parseFloat(records[index].minutesWorked) > parseFloat(records[index].startingMinutes);
                        records[index].isGreen = parseFloat(records[index].minutesWorked) <= parseFloat(records[index].startingMinutes);
                        records[index].showDetail = false
                    }   
                });      
                this.flagFirstTime = false;      
                this.cases = records;            
            }           
        } else if (error) {
            this.cases = [];
            this.error = error;   
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Atención',
                    message: reduceErrors(error).join(', '),
                    variant: 'error'
                })
            );      
        }

        this.isLoading = false;         
    } 

    calculateValues(record){
        let values = {
            hasWorkStepsRelated: false,
            minutesWorked: 0,
            minutesPaused: 0,
            startingMinutes: 0,
            caseCompleted: true,
            caseStarted: false,
            caseAssigned:true
        };

        if (record.Subtipos_de_trabajos1__r && record.Subtipos_de_trabajos1__r.length > 0) {
            record.Subtipos_de_trabajos1__r.forEach((workStep,key) => {
                let flagShowWS = false;
                if (workStep.Tipo_de_trabajo_del_caso__c != null && workStep.Tipo_de_trabajo_del_caso__r.CT_Total_Subtareas_FM__c == 0) {
                    values.startingMinutes += workStep.Tipo_de_trabajo_del_caso__r.Horaa__c != null ? parseFloat(workStep.Tipo_de_trabajo_del_caso__r.Horaa__c) : 0;
                    flagShowWS = true;                    
                }else{                  
                    this.sttcRecords.forEach((sttc,sttcKey)=>{
                        if (sttc.Caso__c === workStep.Caso__c && workStep.Id === sttc.Paso_de_trabajo__c) {
                            values.startingMinutes += sttc.Cantidad_de_horas__c != null ? parseFloat(sttc.Cantidad_de_horas__c) : 0; 
                            flagShowWS = true;                            
                        }
                    });
                }                
                values.minutesWorked += workStep.Total_de_tiempo_trabajado_en_minutos__c != null ? parseFloat(workStep.Total_de_tiempo_trabajado_en_minutos__c) : 0; 
                values.minutesPaused += workStep.AcumuladoMinutosPausas__c != null ? parseFloat(workStep.AcumuladoMinutosPausas__c) : 0;

                if (flagShowWS) {
                    values.hasWorkStepsRelated = true;

                    if (workStep.Status != 'Nueva' || workStep.Mec_nico_asignado__c == null) {
                        values.caseAssigned = false;
                    }
                }

                if(flagShowWS && workStep.Status != 'Completada'){  
                    values.caseCompleted = false;              
                }

                if(flagShowWS && workStep.Status != 'Nueva'){  
                    values.caseStarted = true;              
                }                
            });
           
        }
        values.minutesPaused = values.minutesPaused.toFixed(0);
        values.minutesWorked = values.minutesWorked.toFixed(0);
        values.startingMinutes = (values.startingMinutes * 60).toFixed(0);
        return values;
    }

    getOrderId(record){
        if (record.WorkOrders && record.WorkOrders.length > 0 && record.WorkOrders[0].Id) {
            return record.WorkOrders[0].Id;
        }
        return '';
    }

    getOrderNumber(record){
        if (record.WorkOrders && record.WorkOrders.length > 0 &&  record.WorkOrders[0].WorkOrderNumber) {
            return record.WorkOrders[0].WorkOrderNumber;
        }
        return '';
    }

    getStatusApproved(record){
        if (record.WorkOrders && record.WorkOrders.length > 0) {
            return record.WorkOrders[0].Aprobado__c;
        }
        return false;
    }    

    handleStoreChange(event) {        
        this.inputTallerId = event.target.value;       
    }

    handleServiceTypeChange(event) {
        this.inputServiceType = event.target.value;      
    }

    handleStatusChange(event) {
        this.inputStatus = event.target.value;     
    }   
    
    handleOrderNumberChange(event) {
        this.inputOrderNumber = event.target.value;       
    }    

    handleCaseNumberChange(event) {
        this.inputCaseNumber = event.target.value;     
    }

    handlePlateChange(event) {
        this.inputPlate = event.target.value;       
    }

    handleVINChange(event) {
        this.inputVIN = event.target.value;        
    }    

    handleCreationDateFromChange(event) {
        this.inputCreationDateFrom = event.target.value;     
    }

    handleCreationDateToChange(event) {
        this.inputCreationDateTo = event.target.value;     
    }

    handleTerritoryChange(event){
        this.selectedTerritories = event.detail.value;
    }
    
    handleWorkStepStatusChange(event){
        this.selectedWorkStepStatus = event.detail.value;
    }     

    handleApplyFiltersClick(event){
        this.pageNumber = 1;
        this.refresh();
        this.showFilters = false;
    }

    handleResetClick(event){
        this.inputTallerId = 'all';
        this.inputEstado = 'all';
        
        this.selectedTerritories = this.allTerritories;
        this.selectedWorkStepStatus = this.allWorkStepStatuses;
        this.mechanicId = null;
        this.showCaseStatus = true;
        this.inputMechanicId = null;
        this.inputOrderNumber = null;
        this.inputCaseNumber = null;
        this.inputPlate = null;
        this.inputVIN = null;
        this.inputCreationDateFrom = null;
        this.inputCreationDateTo = null; 
        this.showFilters = false;
        this.pageNumber = 1;
        this.refresh();
    }    

    handleBackClick(){
        this.pageNumber--;
        this.refresh();
    }

    handleNextClick(){
        this.pageNumber++;
        this.refresh();
    }

    get isEnablePrevButton(){
        return !(this.totalPages > 0 && this.pageNumber > 1);
    }

    get isEnableNextButton(){
        return !(this.totalPages > 1 && this.pageNumber != this.totalPages);
    }
    
    handleShowFiltersClick(event) {
        this.showFilters = !this.showFilters;
    }    

    handleShowDetailClick(event){
        let recordId = event.target.dataset.id;
        Object.values(this.cases).forEach((record, index) => {            
            if(record.Id === recordId){            
                this.cases[index].showDetail = !record.showDetail;
            }else{
                this.cases[index].showDetail = false;
            }
        });
    }

    refresh() {
        this.isLoading  = true;
        this.customTimeOut = setTimeout(()=>{
            refreshApex(this.wiredCasesResult);
            this.isLoading = false;
        },1000);     
    }

    handleRefreshCasesEvent(event){
        this.refresh();
    }
    
    handleMechanicSearch(event){
        const lookupElement = event.target;
        var params = event.detail;
        params["firedElement"] = 'Mecanico';
        params["icon"] = 'standard:user';

        searchUsersFilterByMecanico(params)
            .then((results) => {
                lookupElement.setSearchResults(results);
            })
            .catch((error) => {
                this.showAlert('Atención',error,'error');
            });
    }

    handleMechanicSelectionChange(event){
        let userId = null;
        [ userId ] = event.detail;
        this.inputMechanicId = userId != undefined ? userId : null; 
        
        if (this.inputMechanicId == null) {
            this.showCaseStatus = false;
        }else{
            this.showCaseStatus = true;
        }
    }

    get showCaseStatusColumn(){
        return this.allWorkStepStatuses.length === this.selectedWorkStepStatus.length; 
    }

    get fewRecords(){
        return this.cases == null || this.cases.length < 5;
    }
   
    handleShowParentTasksChange(event){
        this.showParentTasks = event.target.checked;
        console.log('showParentTasks:'+this.showParentTasks);
    }

    get showMessageInfo(){
        return this.showParentTasks ? 'Se estan mostrando trabajos': 'Se estan mostrando subtrabajos'
    }
}