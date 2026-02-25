import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { reduceErrors } from 'c/ldsUtils';
import { refreshApex } from '@salesforce/apex';
import getRecords from '@salesforce/apex/RM_CT_WorkStepsInProgress_Ctrl.getRecords';
import getTerritories from '@salesforce/apex/RM_CT_ConsolaTaller_Ctrl.getTerritories';
import getWorkStepStatus from '@salesforce/apex/RM_CT_ConsolaTaller_Ctrl.getWorkStepStatus';
import searchMechanics from '@salesforce/apex/SampleLookupController.searchMechanics';
import searchRecords from '@salesforce/apex/SampleLookupController.searchRecords';

/** The delay used when debouncing event handlers before invoking Apex. */
const DELAY = 300;

export default class Rm_ct_worksteps_in_progress extends LightningElement {

    @track
    records = [];

    pageNumber = 1;
    totalPages = 0;
    totalRecords = 0;

    showFilters = false;

    showParentTasks = false;

    caseNumber = '';
    workOrderNumber = '';
    placa = '';
    vin = '';
    mechanicId = '';
    agentId = '';
    startDate = null;
    endDate = null;

    agentInitialSelection = [];
    agentErrors = []; 
    
    mechanicInitialSelection = [];
    mechanicErrors = [];     
    
    flagLoadCompleted = false;

    territories;
    allTerritories = [];
    selectedTerritories = [];
    @wire(getTerritories,{flagMultiSelect:true})
    wiredTerritories({ data, error }) {
        if (data) {
            this.territories = data.map(item => ({ 'label': item.label, 'value': item.value }));
            this.allTerritories = data.map(item => (item.value));
            this.selectedTerritories = data.map(item => (item.value));
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Atención!',
                    message: reduceErrors(error).join(', '),
                    variant: 'error'
                })
            );
        }
    }

    allWorkStepStatus = [];
    selectedWorkStepStatus = ['En curso','En pausa','Completada'];
    workStepStatus = [];

    @wire(getWorkStepStatus)
    wiredWorkStepStatuses({ data, error }) {
        if (data) {
            this.workStepStatus = data.map(item => ({'label':item.label,'value':item.value}));                                          
            this.allWorkStepStatus = data.map(item => (item.value));
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

    sfdcBaseURL;
    connectedCallback() {
        this.sfdcBaseURL = window.location.origin;
        this.customTimer = setInterval(() => {
            console.log('this.flagLoadCompleted'+this.flagLoadCompleted); 
            if(this.flagLoadCompleted){
                this.calcularTiempos();
                this.settingStatusColor();
            }
        }, 1000);
      
    }

    wiredRecordsResult;
    @wire(getRecords, { territoryIds: "$selectedTerritories", caseNumber: "$caseNumber", workOrderNumber: "$workOrderNumber",statuses: "$selectedWorkStepStatus",placa: "$placa",vin: "$vin",mechanicId: "$mechanicId",agentId: '$agentId',startDate: "$startDate", endDate: "$endDate", showParentTasks: "$showParentTasks",pageNumber: "$pageNumber" })
    wiredRecords(result) {
        this.wiredRecordsResult = result;
        const { error, data } = result;
        this.records = [];
        if (data) {

            if(data.totalRecords > 0){
                this.totalPages = Math.ceil(data.totalRecords / data.pageSize);
            }
            this.totalRecords = data.totalRecords ? data.totalRecords : 0;
            if (data.records) {
              
                let tmpRecords = JSON.parse(JSON.stringify(data.records));
                let currentTime = new Date();
                Object.values(data.records).forEach((record, index) => {
                    if (typeof record === "object") {
                        tmpRecords[index].id = record.Id;
                        tmpRecords[index].mechanicFullName = record.Mec_nico_asignado__r && record.Mec_nico_asignado__r.Name && record.Mec_nico_asignado__r.Name != null ? record.Mec_nico_asignado__r.Name: '';
                        tmpRecords[index].caseNumber = record.Caso__r && record.Caso__r.CaseNumber && record.Caso__r.CaseNumber != null ? record.Caso__r.CaseNumber : '';
                        tmpRecords[index].workOrderNumber = record.WorkOrder && record.WorkOrder.WorkOrderNumber && record.WorkOrder.WorkOrderNumber != null ? record.WorkOrder.WorkOrderNumber : '';
                        tmpRecords[index].status = record.Status;
                        tmpRecords[index].createdDate = record.Caso__r.CreatedDate ? record.Caso__r.CreatedDate : null;
                        tmpRecords[index].name = record.Name ? record.Name : null;
                        tmpRecords[index].placa = record.Caso__c && record.Caso__r.Asset && record.Caso__r.Asset.Name != null ? record.Caso__r.Asset.Name : '';
                        tmpRecords[index].vin = record.Caso__r && record.Caso__r.Asset && record.Caso__r.Asset.NumeroDeChasis__c != '' ? record.Caso__r.Asset.NumeroDeChasis__c : ''; 
                        tmpRecords[index].marca = record.Caso__r && record.Caso__r.Marca__c && record.Caso__r.Marca__c != null ? record.Caso__r.Marca__c : '';
                        tmpRecords[index].modelo = record.Caso__r && record.Caso__r.Modelo__c && record.Caso__r.Modelo__c != null ? record.Caso__r.Modelo__c : '';
                        tmpRecords[index].mecanicoURL = this.sfdcBaseURL +'/'+ (record.Mec_nico_asignado__c ? record.Mec_nico_asignado__c : '');
                        tmpRecords[index].workOrderURL = this.sfdcBaseURL +'/'+ (record.WorkOrderId ? record.WorkOrderId : '');
                        tmpRecords[index].workStepURL = this.sfdcBaseURL +'/'+ (record.Id ? record.Id : '');
                        tmpRecords[index].caseURL = this.sfdcBaseURL +'/'+ (record.Caso__c ? record.Caso__c : '');
                        tmpRecords[index].agentFullName = (record.Caso__c && record.Caso__r && record.Caso__r != null ? record.Caso__r.Owner.Name : '');
                        tmpRecords[index].agentURL = this.sfdcBaseURL +'/'+ (record.Caso__c && record.Caso__r && record.Caso__r != null ? record.Caso__r.OwnerId : '');

                        tmpRecords[index].startingMinutes = record.RM_TotalHorasFX__c ? record.RM_TotalHorasFX__c : 0;
                        tmpRecords[index].startingMinutes = parseFloat(tmpRecords[index].startingMinutes) * 60;
                        tmpRecords[index].startingMinutes = parseFloat(tmpRecords[index].startingMinutes).toFixed(0);

                        //calculate initial hours, minutes and seconds basen on the startingMinutes
                        let hours = Math.floor(tmpRecords[index].startingMinutes / 60);
                        let minutes = tmpRecords[index].startingMinutes % 60;
                        let seconds = 0;
                        tmpRecords[index].totalInitialTimeText = 'Tiempo inicial: '+hours.toFixed(0) +' horas '+ minutes.toFixed(0) +' minutos '+ seconds.toFixed(0) + ' segundos';

                        
                        tmpRecords[index].hoursWorked = 0;

                        let totalMinutesWorked = record.Total_de_tiempo_trabajado_en_minutos__c ? parseFloat(record.Total_de_tiempo_trabajado_en_minutos__c).toFixed(0) : 0;
                        tmpRecords[index].totalMinutesWorked = totalMinutesWorked;
                        tmpRecords[index].isRed = parseFloat(totalMinutesWorked) > parseFloat(tmpRecords[index].startingMinutes);
                        tmpRecords[index].isGreen = parseFloat(totalMinutesWorked) <= parseFloat(tmpRecords[index].startingMinutes);

                        tmpRecords[index].classTR = tmpRecords[index].isRed ? 'slds-hint-parent tr-red' : 'slds-hint-parent';
                        tmpRecords[index].classLink = tmpRecords[index].isRed ? 'link-white' : '';

                        //Flags to control how the running time is shown
                        tmpRecords[index].isRunning = record.Status == 'En curso';
                        tmpRecords[index].isCompleted = record.Status == 'Completada';
                        tmpRecords[index].isPaused = record.Status == 'En pausa'; 
                        
                        // tmpRecords[index].totalMinutesWorkedWithoutPause = record.Total_de_tiempo_trabajado_en_minutos__c ? record.Total_de_tiempo_trabajado_en_minutos__c : 0;                        
                    }
                });
                this.flagLoadCompleted = true; 
                this.records = tmpRecords;
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
    }

    handleWorkOrderNumberChange(event) {
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.workOrderNumber = searchKey; 
        }, DELAY);             
    }    

    handleCaseNumberChange(event) {
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.caseNumber = searchKey; 
        }, DELAY);
    }

    handlePlacaChange(event) {
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.placa = searchKey; 
        }, DELAY);        
    }

    handleVINChange(event) {
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.vin = searchKey; 
        }, DELAY);        
    }    

    handleStartDateChange(event) {
        this.startDate = event.target.value;     
    }    

    handleEndDateChange(event) {
        this.endDate = event.target.value;     
    }        

    handleApplyFiltersClick(event) {
        this.pageNumber = 1;
        this.showFilters = false;
    }

    handleShowFiltersClick(event) {
        this.showFilters = !this.showFilters;
    }

    handleBackClick() {
        this.pageNumber--;
        this.refresh();
    }

    handleNextClick() {
        this.pageNumber++;
        this.refresh();
    }

    get isEnablePrevButton() {
        return !(this.totalPages > 0 && this.pageNumber > 1);
    }

    get isEnableNextButton() {
        return !(this.totalPages > 1 && this.pageNumber != this.totalPages);
    }

    refresh() {

    }

    handleMechanicSearch(event){
        const lookupElement = event.target;
        var params = event.detail;
        params["firedElement"] = 'Mecánico';
        params["icon"] = 'standard:user';

        searchMechanics(params)
            .then((results) => {
                lookupElement.setSearchResults(results);
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Consultar información de mecánico',
                        message: reduceErrors(error).join(', '),
                        variant: 'error'
                    })
                );
            });
    }
    
    handleMechanicSelectionChange(event){
        if (event.detail.length > 0) {
            [ this.mechanicId ] = event.detail;
            this.mechanicInitialSelection = event.target.getSelection();
        }else{
            this.mechanicId = null;
            this.mechanicInitialSelection = [];
        }
        // console.log( this.mechanicId);
        // console.log(this.mechanicInitialSelection);
        
    }
    
    handleAgentSearch(event){
        const lookupElement = event.target;
        var params = event.detail;
        params["objName"] = 'User';
        params["displayedObjName"] = 'Usuario';
        params["firedElement"] = 'User';
        params["icon"] = 'standard:user';

        searchRecords(params)
            .then((results) => {
                lookupElement.setSearchResults(results);
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Consultar información de asesores',
                        message: reduceErrors(error).join(', '),
                        variant: 'error'
                    })
                );
            });
    } 

    handleAgentSelectionChange(event){
        if (event.detail.length > 0) {
            [ this.agentId ] = event.detail;
            this.agentInitialSelection = event.target.getSelection();
        }else{
            this.agentId = null;
            this.agentInitialSelection = [];
        }        
    }    
    
    handleResetClick(event){
        this.selectedTerritories = this.allTerritories;
        this.selectedWorkStepStatus = ['En curso','En pausa','Completada'];
        this.mechanicId = '';
        this.mechanicInitialSelection = [];  
        this.agentId = ''; 
        this.agentInitialSelection = [];  
        this.caseNumber = '';
        this.workOrderNumber = '';
        this.placa = '';
        this.vin = '';
        this.startDate = null;
        this.endDate = null; 
        this.status = 'all'; 
    }      

    handlStatusChange(event){
        this.status = event.target.value;
    }     

    handleWorkStepStatusChange(event){
        this.selectedWorkStepStatus = event.detail.value;
    }     

    handleTerritoryChange(event){
        this.selectedTerritories = event.detail.value;
    }

    calcularTiempos(){
        let currentTime = new Date();
        this.records.forEach((record, index) => {
            let hoursWorked = 0;
            let minutesWorked = 0;
            let secondsWorked = 0;
            
            let hoursPaused = 0;
            let minutesPaused = 0;
            let secondsPaused = 0;
            let totalMinutesPaused = 0;

            let totalHoursWorked = 0;
            let totalMinutesWorked = 0;
            let totalSecondsWorked = 0;

            let totalMillisecondsPaused = 0;

            //check if record.AcumuladoMinutosPausas__c is not null and calculate hours, minutes and seconds
            if(record.AcumuladoMinutosPausas__c){
                totalMinutesPaused = parseFloat(record.AcumuladoMinutosPausas__c);
                //convert minutes to milliseconds
                totalMillisecondsPaused = totalMinutesPaused * 60000;
            }
            
            //Calculate the paused time
            if(record.isPaused && record.Hora_de_inicio_de_pausa__c){
                // Calculate the difference in milliseconds
                let diff = currentTime - record.Hora_de_inicio_de_pausa__c;
                totalMillisecondsPaused += diff;

                totalMinutesPaused = Math.floor(totalMillisecondsPaused / (1000 * 60));

                    diff = totalMillisecondsPaused;
                // Calculate hours, minutes and seconds paused 
                hoursPaused = Math.floor(diff / (1000 * 60 * 60));
                minutesPaused = Math.floor(diff / (1000 * 60));
                secondsPaused = Math.floor(diff / 1000);
            }

            // calculate the worked time
            if(record.StartTime){
                // Assuming startTime is a Date object
                let startTime = new Date(record.StartTime); // replace this.records.startTime with your actual start time

                // Calculate the difference in milliseconds
                let diff = currentTime - startTime;
                diff -= totalMillisecondsPaused;

                totalMinutesWorked = Math.floor(diff / (1000 * 60));

                // Calculate hours, minutes and seconds
                hoursWorked = Math.floor(diff / (1000 * 60 * 60));
                diff -= hoursWorked * (1000 * 60 * 60);

                minutesWorked = Math.floor(diff / (1000 * 60));
                diff -= minutesWorked * (1000 * 60);

                secondsWorked = Math.floor(diff / 1000);
            }


            record.hoursWorked = hoursWorked.toFixed(0);
            record.minutesWorked = minutesWorked.toFixed(0);
            record.secondsWorked = secondsWorked.toFixed(0);
            record.totalMinutesWorked = totalMinutesWorked.toFixed(0);

            record.totalWorkedTime = 'Tiempo trabajado: '+hoursWorked.toFixed(0) +' horas '+ minutesWorked.toFixed(0) +' minutos'+ secondsWorked.toFixed(0) + ' segundos';
            
            record.hoursPaused = hoursPaused.toFixed(0);
            record.minutesPaused = minutesPaused.toFixed(0);
            record.secondsPaused = secondsPaused.toFixed(0);
            record.totalMinutesPaused = totalMinutesPaused.toFixed(0);

            //total de minutos trabajados con segundos para determinar el color
            //El tiempo inicial tiene milisegundos
            record.totalMinutesWithSecondsWorked = parseFloat(record.totalMinutesWorked +'.'+ record.secondsWorked).toFixed(2);
            
            // console.log('hoursWorked',this.records[index].hoursWorked);
            // console.log('minutesWorked',this.records[index].minutesWorked);
            // console.log('secondsWorked',this.records[index].secondsWorked);

        });
        console.log('this.records',this.records);
    }    

   /**
    * Setea el color
    */
   settingStatusColor() {
        this.records.forEach((record, index) => {
            if (record.Status == 'En curso' && parseFloat(record.totalMinutesWithSecondsWorked) > parseFloat(record.startingMinutes)) {
                this.records[index].statusBackground = 'slds-hint-parent tr-red';
                this.records[index].classLink = 'link-white';
            } else if (record.Status == 'En curso' && parseFloat(record.totalMinutesWithSecondsWorked) <= parseFloat(record.startingMinutes)) {
                this.records[index].statusBackground = 'slds-hint-parent tr-green';
                this.records[index].classLink = 'link-black';
            } else {
                this.records[index].statusBackground = 'slds-hint-parent tr-black';
                this.records[index].classLink = '';
            }
        });
    }      

    get isLoading() {
        return !this.wiredRecordsResult.data && !this.wiredRecordsResult.error;
    }   
    
    handleShowParentTasksChange(event){
        this.showParentTasks = event.target.checked;
    }

    get showMessageInfo(){
        return this.showParentTasks ? 'Se estan mostrando trabajos': 'Se estan mostrando subtrabajos'
    }
}