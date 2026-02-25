import { LightningElement, wire, track } from 'lwc';
import { reduceErrors } from 'c/ldsUtils';
import columns from './columns';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import WORK_STEP_ID_FIELD from '@salesforce/schema/WorkStep.Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import WORK_STEP_STATUS_FIELD from '@salesforce/schema/WorkStep.Status';
import search from '@salesforce/apex/SampleLookupController.search';
import getWorkSteps from '@salesforce/apex/CT_AsignaMecanico.getWorkSteps';
import searchCases from '@salesforce/apex/SampleLookupController.searchCases';
import updateWorkSteps from '@salesforce/apex/CT_AsignaMecanico.updateWorkSteps';
import checkTaskRunning from '@salesforce/apex/CT_AsignaMecanico.checkTaskRunning';
import createTiempoImproductivo from '@salesforce/apex/CT_AsignaMecanico.createTiempoImproductivo';
import searchUsersFilterByMecanico from '@salesforce/apex/SampleLookupController.searchUsersFilterByMecanico';
import getTerritories from '@salesforce/apex/CT_AsignaMecanico.getTerritories';
import getTipoCargo from '@salesforce/apex/CT_AsignaMecanico.getTipoCargo';


export default class Asimec extends LightningElement {
    @track isLoading = true;
        
    @track pageNumber = 1;  
    @track totalPages = 0; 
    @track totalRecords = 0;    
    columns = columns;
    
    @track inputAction = 'detalle';
    @track caseId = null;
    @track mechanicId = null;
    @track inputTerritoryId = null;

    showParentTasks= false;

    step = 1;

    isModalOpen = false;
    isModalMechanicOpen = false;

    isHIMModalOpen = false;

    showConfirmStartNewTask = false;

    mechanicInitialSelection = [];
    errors = [];

    sfdcBaseURL;
    @track workSteps;
    wiredWorkStepResult; 

    caseInitialSelection = [];
    caseErrors = [];

    @track selectedWorkStepIds = [];

    //tiempos improductivos
    initialHIMMechanicSelection = [];
    himMechanicSelection = [];
    himMechanicErrors = [];
    inputTallerId = null;
    inputStartDate = null;
    inputEndDate = null;
    descripcion = null;
    inputRepetir = 'no-repetir';
    // inputDefaultDay = ;

    startNewTask = false;

    taskName = null;
    taskCaseNumber = null;
    taskOrderNumber = null;

    // @wire(getTalleresForSelect)
    // talleres    
    @track flagLoadCompleted = false;

    @track status = 'all';

    @track tipoCargoOptions = [];
    selectedTipoCargo = 'all';

    @wire(getTipoCargo)
    wiredTipoCargo({ error, data }) {
        console.log('wiredTipoCargo'+data);
        if (data) {
            this.tipoCargoOptions = [{ label: 'Todos', value: 'all' }].concat( data.map(item => {
                return { label: item.label, value: item.name };
            }));
        } else if (error) {
            // handle error
        }
    }

    get statusOptions() {
        return [
            { label: 'Todos', value: 'all' },
            { label: 'Nueva', value: 'Nueva' },
            { label: 'En curso', value: 'En curso' },
            { label: 'En pausa', value: 'En pausa' },            
            { label: 'Completada', value: 'Completada' },
        ];
    }

    @wire(getTerritories)
    wiredTerritories({ data, error }) {
        if (data) {            
            this.territories = data.map(item => ({'label':item.Name,'value':item.Id}));
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
    customTimer;
    connectedCallback() {
        this.sfdcBaseURL = window.location.origin;         
    }    
     
    @wire(getWorkSteps,{ caseId: '$caseId', mechanicId: "$mechanicId",status: "$status", tallerId: "$inputTallerId",action: "$inputAction",showParentTasks: "$showParentTasks", tipoCargo:"$selectedTipoCargo", pageNumber: "$pageNumber" })  
    wiredWorkSteps(result) {
        this.wiredWorkStepResult = result;
        this.workSteps = [];
        if (result.data) {
            this.totalRecords = result.data.totalRecords;
            if(result.data.totalRecords > 0){
                this.totalPages = Math.ceil(result.data.totalRecords / result.data.pageSize);
            }

            if(result.data.workSteps){
                let records = JSON.parse(JSON.stringify(result.data.workSteps));                              
                Object.values(result.data.workSteps).forEach((item,index) => {
                    if (typeof item === "object") {                                
                        records[index].WorkOrderNumber = item.WorkOrder != null ? item.WorkOrder.WorkOrderNumber : '';
                        records[index].WorkOrderURL = this.sfdcBaseURL + '/'+item.WorkOrderId;
                        records[index].CaseURL = this.sfdcBaseURL + '/'+ (item.Caso__c ? item.Caso__c : '');
                        records[index].CaseNumber = item.Caso__r != null ? item.Caso__r.CaseNumber : '';
                        records[index].WorkTime = item.Total_de_tiempo_trabajado_en_minutos__c ? parseFloat(item.Total_de_tiempo_trabajado_en_minutos__c).toFixed(0) : 0;
                        records[index].StartTime = item.StartTime != null ? item.StartTime : null;
                        records[index].WorkStepURL = this.sfdcBaseURL + '/'+item.Id;
                        records[index].WorkStepName = item.Name;  
                        records[index].WorkOrderCreationDate = item.WorkOrder != null ? item.WorkOrder.CT_Fecha_Creacion_FM__c : null;  
                        records[index].tipoCargo = item.Tipo_de_trabajo_del_caso__r != null && item.Tipo_de_trabajo_del_caso__r.Tipo_de_cargo__c != null ? item.Tipo_de_trabajo_del_caso__r.Tipo_de_cargo__c : null;  

                        records[index].Status = item.Status ? item.Status : '';
                        records[index].startingMinutes = item.RM_TotalHorasFX__c ? item.RM_TotalHorasFX__c : 0;
                        records[index].startingMinutes *=60;
                        //round to 2 decimals
                        records[index].startingMinutes = parseFloat(records[index].startingMinutes).toFixed(0);

                        records[index].hoursWorked = 0;

                        let totalMinutesWorked = item.Total_de_tiempo_trabajado_en_minutos__c ? parseFloat(item.Total_de_tiempo_trabajado_en_minutos__c).toFixed(0) : 0;
                        records[index].totalMinutesWorked = totalMinutesWorked;
                        records[index].isRed = parseFloat(totalMinutesWorked) > parseFloat(records[index].startingMinutes);
                        records[index].isGreen = parseFloat(totalMinutesWorked) <= parseFloat(records[index].startingMinutes);

                        // records[index].startingMinutes = item.RM_TotalHorasFX__c ? item.RM_TotalHorasFX__c : 0;
                        records[index].isRunning = item.Status == 'En curso';
                        records[index].isCompleted = item.Status == 'Completada';
                        records[index].isPaused = item.Status == 'En pausa';                                                 
                    }                                      
                });
                this.flagLoadCompleted = true; 
                this.workSteps = records;
            }
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;            
        }
        this.isLoading = false;
    }        

    handleShowParentTasksChange(event){
        this.showParentTasks = event.target.checked;
    }

    handleActionChange(event){
        this.inputAction = event.target.value;
        if (this.inputAction == 'consultar-tareas') {
            this.caseId = null;
            this.mechanicId = null;
            this.inputTerritoryId = null;
            this.mechanicInitialSelection = [];
            this.caseInitialSelection = [];

            this.customTimer = setInterval(() => {
                if(this.flagLoadCompleted){
                    this.calcularTiempos();
                    this.settingStatusColor();
                }
            }, 1000);
            
        }else{
            if (this.customTimer) {                
                clearInterval(this.customTimer);
            }
        }

        this.mechanicId = null;
        this.tallerId = null;
        
        this.execCommand();
    }

    handleAcceptClick(event){
        if ((this.inputAction != "detalle" || this.inputAction != "tiempo-improductivo") && this.selectedWorkStepIds.length == 0) {            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Tarea requerida',
                    message: 'Favor de seleccionar al menos una tarea.',
                    variant: 'error'
                })
            );
            return;
        }
        if (this.inputAction == "asignar" || this.inputAction == "reasignar") {
            if(this.mechanicId == null){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Mecánico requerido',
                        message: 'Favor de ingresar el mecánico.',
                        variant: 'error'
                    })
                );                
            }else{
                this.updateAction(null);
            }
        }else if(this.inputAction == 'iniciar'){
            checkTaskRunning({taskId: this.selectedWorkStepIds[0]})
            .then((response) => {
                if(response.hasRunningTask){
                    const modal = this.template.querySelector('c-modal');
                    modal.show();
                    this.taskName = response.task.Name;
                    this.taskCaseNumber = response.task.Caso__r.CaseNumber;
                }else{
                    this.updateAction('En curso');
                }
            });

        }else if(this.inputAction == 'pausar' || this.inputAction == 'cierre-taller'){
            this.isHIMModalOpen = true;
        }else if(this.inputAction == 'completar'){
            this.updateAction('Completada');
        }else if(this.inputAction == 'reanudar'){
            this.updateAction('En curso');
        }
        
    }

    handleCaseSelectionChange(event){   
        this.caseId = null;
        [ this.caseId ] = event.detail;
        if (this.caseId == undefined) {
            this.caseId = null;
        }
 
        console.log('caseId');  
        console.log(this.caseId);         
    }

    execCommand(){
        if (this.inputAction == "tiempo-improductivo") {
            this.isModalOpen = true;            
        }else{
            this.step = 2;
            this.refresh();
        }
    }

    handleMechanicSelectionChange(event){
        let userId = null;
        [ userId ] = event.detail;
        this.mechanicId = userId != undefined ? userId : null;        
    }    

    get showRecords(){
        return  ((this.inputAction == 'detalle' && this.caseId != null)
         || (this.inputAction == 'asignar' && this.caseId != null)
         || (this.inputAction == 'reasignar' && this.caseId != null)
         || (this.inputAction == 'iniciar' && this.caseId != null)
         || (this.inputAction == 'pausar' && this.caseId != null)
         || (this.inputAction == 'reanudar' && this.caseId != null)
         || (this.inputAction == 'completar' && this.caseId != null)
         || (this.inputAction == 'consultar-tareas')
         || (this.inputAction == 'cierre-taller')
         );
    }

    get isNextButtonEnabled(){
        return !(this.caseId != null && this.inputAction != null && this.step == 1);
    }
    
    handleCancelClick(event){
        this.clear();
    }

    handleCloseModal(event) {
        this.isModalOpen = false;
        this.isModalMechanicOpen = false;
        this.inputAction = 'detalle';
    }

    submitDetails(event) {
        if(this.inputAction == "pausar"){
            this.isLoading = true;
            createTiempoImproductivo({
                wsIds: this.selectedWorkStepIds,
                description: this.descripcion
            })
            .then((results) => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Tiempo improductivo registrado',
                    message: 'La pausa y el tiempo improductivo se ha registrado correctamente.',
                    variant: 'success'
                }))
                this.selectedWorkStepIds = [];
                this.inputAction = 'detalle';
                this.clear();  
                this.isModalOpen = false;  
                this.isModalMechanicOpen = false;      
                this.isLoading = false;     
            })
            .catch((error) => {
                this.showAlert('Atención',error,'error');
                this.isLoading = false;     
            });
        }else if(this.inputAction == "tiempo-improductivo"){
            
        }
    }

    clear(){
        // this.inputAction = 'detalle';
        // this.caseId = null;
        // this.mechanicId=null;
        // this.inputTerritoryId = null;
        // this.descripcion=null;
        // this.mechanicInitialSelection = [];
        // this.caseInitialSelection = [];
        // this.showRecords = false;
    }

    get isEmptyAction(){
        return this.inputAction == 'detalle';
    }

    handleMechanicSearch(event){
        const lookupElement = event.target;
        var params = event.detail;
        params["firedElement"] = 'Mecanico';
        params["icon"] = 'standard:user';

        search(params)
            .then((results) => {
                lookupElement.setSearchResults(results);
            })
            .catch((error) => {
                this.showAlert('Atención',error,'error');
            });
    }

    handleCaseSearch(event){
        const lookupElement = event.target;
        var params = event.detail;
        params["objName"] = 'Case';
        params["displayedObjName"] = 'Caso';
        params["icon"] = 'standard:case';

        searchCases(params)
            .then((results) => {
                lookupElement.setSearchResults(results);
            })
            .catch((error) => {
                this.showAlert('Atención',error,'error');
            });
    }   
    
    handleHIMMechanicSearch(event){
        const lookupElement = event.target;
        var params = event.detail;
        params["objName"] = 'Mecanico';
        params["icon"] = 'standard:user';

        searchUsersFilterByMecanico(params)
            .then((results) => {
                lookupElement.setSearchResults(results);
            })
            .catch((error) => {
                this.showAlert('Atención',error,'error');
            });
    }
    
    showAlert(title,message,type){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message == 'success' ? message : reduceErrors(message).join(', '),
                variant: type
            })
        );        
    }    
    
    handleWorkStepSelection(event){        
        const selectedRows = event.detail.selectedRows;
        this.selectedWorkStepIds = [];
        for (let i = 0; i < selectedRows.length; i++) {
            this.selectedWorkStepIds.push(selectedRows[i].Id);
        }       
    }

    customTimeOut;
    refresh(){
        this.isLoading = true;
        this.selectedWorkStepIds = [];        
        this.mechanicId = null;
        this.mechanicInitialSelection = [];  
        
        if (this.inputAction == 'consultar-tareas') {
            this.caseId = null;
            this.caseInitialSelection = [];
        }

        this.customTimeOut = setTimeout(()=>{
            refreshApex(this.wiredWorkStepResult);
            this.isLoading = false;
        },1000);
    }
    
    get isCaseDisabled(){
        return this.step > 1 && this.inputAction != 'detalle';
    }

    get isHideCheckboxColumn(){
        return this.inputAction == 'detalle' || this.inputAction == 'tiempo-improductivo' || this.inputAction == 'consultar-tareas';
    }

    get showMechanicElement(){
        return this.inputAction == 'asignar' || this.inputAction == 'reasignar'  || this.inputAction == 'consultar-tareas';
    }

    get showWorkStepStatus(){
        return this.inputAction == 'consultar-tareas';
    }

    get maxRowSelection(){
        return this.inputAction == 'iniciar' ? 1 : 100;
    }

    updateAction(newStatus){
        this.isLoading = true;
        updateWorkSteps({ 
            wsIds : this.selectedWorkStepIds, 
            action: this.inputAction,
            status : newStatus,
            mechanicId : this.mechanicId
        })
        .then(result => {
            this.showAlert('Solicitud procesada','La solicitud fue procesada correctamente.','success');
            this.isLoading = false;
            this.mechanicInitialSelection = [];
            this.mechanicId = null;
            this.tallerId = null;
            this.selectedWorkStepIds = [];
            this.inputAction = 'detalle';
            this.refresh();
        })
        .catch(error => {            
            this.showAlert('Atención',error,'error');
            this.isLoading = false;
        });  
    }  

    handleDescriptionChange(event){
        this.descripcion = event.target.value;
    }

    handlStatusChange(event){
        this.status = event.target.value;
    }    

    get showRecurrenceFields(){
        return this.inputAction == 'tiempo-improductivo';
    }

    handleCloseHIMEvent(event){
        this.isHIMModalOpen = false;
        this.inputAction = 'detalle';
    }

    handleAcceptEvent(event){        
        this.isHIMModalOpen = false;        
        this.inputAction = 'detalle';
        this.pageNumber = 1;
        this.refresh();
    }

    get isCaseRequired(){
        return this.inputAction != 'consultar-tareas' && this.inputAction != 'cierre-taller';
    }


    async checkTaskRunningAction(){
        await checkTaskRunning({mechanicId: this.mechanicId})
        .then((response) => {
            return response.hasRunningTask;
        });
        return false;
    }

    handleCancelPauseAndStartClick(event){
        const modal = this.template.querySelector('c-modal');
        modal.hide();
    }

    handlePauseAndStartClick(event){
        this.updateAction('En curso');
        const modal = this.template.querySelector('c-modal');
        modal.hide();
    }

    get showTaller(){
        return this.inputAction == 'cierre-taller';
    }

    handleTallerChange(event) {        
        this.inputTallerId = event.detail.value;
        this.pageNumber = 1;      
        this.refresh();
    }    

    get IsCaseNotEmpty(){
        return this.caseId != null && this.caseId;
    }

    handleRefreshWorkStepsEvent() {
        this.refresh();
    }



    //Contador
    calcularTiempos(){
        console.log('timer');
        let currentTime = new Date();
        this.workSteps.forEach((record, index) => {
            let hoursWorked = 0;
            let minutesWorked = 0;
            let secondsWorked = 0;

            let hoursPaused = 0;
            let minutesPaused = 0;
            let secondsPaused = 0;

            let totalMinutesWorked = 0
            let totalMinutesPaused = 0

            if(record.StartTime){             
                let milliseconds = Math.floor(currentTime - new Date(record.StartTime));

                hoursWorked = Math.floor(milliseconds  / 3600000); // hours      
                minutesWorked = Math.floor(((milliseconds % 86400000) % 3600000) / 60000);///minutes la diferencia es en minutos del 0 - 59
                secondsWorked = Math.floor((((milliseconds % 86400000)% 3600000) % 60000) /1000);//La diferencia en segundos es del 0 al 60
                                
                totalMinutesWorked += (hoursWorked * 60) + minutesWorked;
                totalMinutesWorked -= record.AcumuladoMinutosPausas__c ? parseFloat(record.AcumuladoMinutosPausas__c) : 0;
            }

            // if(record.isPaused && record.Hora_de_inicio_de_pausa__c){
            //     let milliseconds = Math.floor(currentTime - new Date(record.Hora_de_inicio_de_pausa__c));

            //     hoursPaused = Math.floor(milliseconds  / 3600000); // hours      
            //     minutesPaused = Math.floor(((milliseconds % 86400000) % 3600000) / 60000);//minutes la diferencia es en minutos del 0 - 59
            //     secondsPaused = Math.floor((((milliseconds % 86400000)% 3600000) % 60000) /1000);//La diferencia en segundos es del 0 al 60              
                
            //     totalMinutesPaused += (hoursPaused * 60) + minutesPaused;
            //     totalMinutesPaused += record.AcumuladoMinutosPausas__c ? parseFloat(record.AcumuladoMinutosPausas__c) : 0;
            // }

            this.workSteps[index].hoursWorked = hoursWorked.toFixed(0);
            this.workSteps[index].minutesWorked = minutesWorked.toFixed(0);
            this.workSteps[index].secondsWorked = secondsWorked.toFixed(0);
            this.workSteps[index].totalMinutesWorked = totalMinutesWorked.toFixed(0);
            
            // this.workSteps[index].hoursPaused = hoursPaused;
            // this.workSteps[index].minutesPaused = minutesPaused.toFixed(0);
            // this.workSteps[index].secondsPaused = secondsPaused.toFixed(0);
            // this.workSteps[index].totalMinutesPaused = totalMinutesPaused.toFixed(0);

            if (record.isRunning) {
                this.workSteps[index].WorkTime = this.workSteps[index].hoursWorked + ':'+ this.workSteps[index].minutesWorked + ':' + this.workSteps[index].secondsWorked;
                // console.log('tiempo trabajado');
                // console.log(this.workSteps[index].workTime);
            }

            // //total de minutos trabajados con segundos para determinar el color
            // //El tiempo inicial tiene milisegundos
            this.workSteps[index].totalMinutesWithSecondsWorked = parseFloat(this.workSteps[index].totalMinutesWorked +'.'+ this.workSteps[index].secondsWorked).toFixed(2);            
            
        });
    }    

    settingStatusColor() {
        this.workSteps.forEach((record, index) => {
            if (record.Status == 'En curso' && parseFloat(record.totalMinutesWithSecondsWorked) > parseFloat(record.startingMinutes)) {
                this.workSteps[index].statusBackground = 'slds-hint-parent tr-red';
                this.workSteps[index].classLink = 'link-white';
            } else if (record.Status == 'En curso' && parseFloat(record.totalMinutesWithSecondsWorked) <= parseFloat(record.startingMinutes)) {
                this.workSteps[index].statusBackground = 'slds-hint-parent ';
                // this.workSteps[index].classLink = 'link-white';
            } else {
                this.workSteps[index].statusBackground = 'slds-hint-parent';
                this.workSteps[index].classLink = '';
            }
        });
    }

    handleTipoCargoChange(event){
        this.selectedTipoCargo = event.detail.value;
        console.log('selectedTipoCargo'+this.selectedTipoCargo);
    }
    
    get isConsultarTareas(){
        return this.inputAction == 'consultar-tareas';
    }

    get showMessageInfo(){
        return this.showParentTasks ? 'Se estan mostrando trabajos': 'Se estan mostrando subtrabajos'
    }
}