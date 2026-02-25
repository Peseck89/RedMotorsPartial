import { LightningElement, api, wire, track } from 'lwc';
import { reduceErrors } from 'c/ldsUtils';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import WORK_ORDER_OBJECT from '@salesforce/schema/WorkOrder';
import WORK_STEP_OBJECT from '@salesforce/schema/WorkStep';
import WORK_STEP_ID_FIELD from '@salesforce/schema/WorkStep.Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import search from '@salesforce/apex/SampleLookupController.search';
import WORK_STEP_STATUS_FIELD from '@salesforce/schema/WorkStep.Status';
import getContact from '@salesforce/apex/cT_vistaTradicional.getContact'
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import getWorkSteps from '@salesforce/apex/cT_vistaTradicional.getWorkSteps'
import updateRecordMeca from '@salesforce/apex/cT_vistaTradicional.updateRecordMeca'
import WORK_ORDER_SERVICE_TYPE from '@salesforce/schema/WorkOrder.Tipo_de_servicio__c';
import MECHANIC_ASSIGNED_FIELD from '@salesforce/schema/WorkStep.Mec_nico_asignado__c';
import getTalleresForSelect from '@salesforce/apex/cT_vistaTradicional.getTalleresForSelect'
import Id from '@salesforce/user/Id';

export default class ViewCaseDetail extends LightningElement {
    
    @api caseId;

    ampm = true;

    @track showCurrentTimeColumn = false;

    @track pageNumber = 1;  
    @track totalPages = 0; 
    @track totalRecords = 0; 

    initialSelection = [];    
            
    inputPlate = null;
    inputVIN = null;
    inputCreationDateFrom = null;
    inputCreationDateTo = null;

    @track isLoading = true;

    @track showFilters = true;
    @track dataInicial = null;
    @track nombreMecanico;
    @track nombreNewMeca;
    @track accountWireResponse;
    @track accountWireResponseFilter;
    @track idBoton; 

    userId = Id;
    
    initialSelection = [];
    
    errors = [];
    
    iconShowFilter = 'utility:contract_alt';
    
    sfdcBaseURL;    
    
    wiredWorkStepsResult;
    
    @track workSteps;

    @wire(getTalleresForSelect)
    talleres

    @wire(getContact)
    contactos  
    
    @track flagLoadCompleted = false;

    customTimeOut;
    customTimer;

    workStepObjectForForm = WORK_STEP_OBJECT; 
    mechanicAssigned = MECHANIC_ASSIGNED_FIELD; 

    assignmentTitle;
    selectedWorkStepId = null;    
    mechanicId = null;
    
    @api
    mechanicFilter = null;

    @api
    statusesFilter = null;

    selectedWorkStepId = null;
    currentMechanicName;

    hasMechanicAssigned = false;

    @api
    territories;
    
    @api
    status = 'all';

    connectedCallback() {
        this.sfdcBaseURL = window.location.origin;
        this.customTimer = setInterval(() => {
            if(this.flagLoadCompleted){
                this.calcularTiempos();
                this.settingStatusColor();
            }
        }, 1000);
    }    

    wiredWorkStepsResult;    
    @wire(getWorkSteps, {caseNumber: "$caseId",territories: "$territories",mechanicId:"$mechanicFilter",statuses: "$statusesFilter", pageNumber:"$pageNumber" })
    wiredWorkSteps(result) {
        this.wiredWorkStepsResult = result;
        const { error, data } = result;
        if (data) {
            if(data.records){

                this.totalRecords = data.totalRecords ? data.totalRecords : 0;
                
                if(data.totalRecords > 0){
                    this.totalPages = Math.ceil(data.totalRecords / data.pageSize);
                }

                let records = JSON.parse(JSON.stringify(data.records))
                Object.values(data.records).forEach((workStep, index) => {
                    if (typeof workStep === "object") { 
                        //we dont change the original status's value, it may be used in future validations                       
                        records[index].statusName = workStep.Status && workStep.Status != '' ? workStep.Status : '-- None --';

                        //Show Lookup values for workorder,case
                        records[index].workStepURL = this.sfdcBaseURL +'/'+workStep.Id;
                        records[index].workOrderURL = this.sfdcBaseURL +'/'+ (workStep.WorkOrderId ? workStep.WorkOrderId : '');
                        records[index].caseURL = this.sfdcBaseURL +'/'+ (workStep.Caso__c ? workStep.Caso__c : '');
                        records[index].vehicleURL = this.sfdcBaseURL +'/'+ (workStep.WorkOrder && workStep.WorkOrder.AssetId ? workStep.WorkOrder.AssetId : '');
                        
                        //Prepare URL for Work Order and Case related to the work step
                        records[index].workOrderNumber = workStep.WorkOrder ? workStep.WorkOrder.WorkOrderNumber : '';
                        records[index].caseNumber = workStep.Caso__r ? workStep.Caso__r.CaseNumber : '';
                        records[index].vehiclePlaca = workStep.WorkOrder && workStep.WorkOrder.Asset && workStep.WorkOrder.Asset.Name ? workStep.WorkOrder.Asset.Name : ''
                        records[index].vehicleChasisNumber = workStep.WorkOrder && workStep.WorkOrder.Asset && workStep.WorkOrder.Asset.NumeroDeChasis__c ? workStep.WorkOrder.Asset.NumeroDeChasis__c : ''
                        
                        records[index].startingMinutes = this.getStartingMinutes(workStep);
                        
                        records[index].accountName = workStep.Account ? workStep.Account.Name : '';
                        records[index].mechanicName = workStep.Mec_nico_asignado__c ? workStep.Mec_nico_asignado__r.Name : 'Sin mecánico';
                        records[index].workOrderOwnerName = workStep.WorkOrder && workStep.WorkOrder.Owner ? workStep.WorkOrder.Owner.Name : '';
                        records[index].workTypeName = workStep.Tipo_de_trabajo_del_caso__r && workStep.Tipo_de_trabajo_del_caso__r.Nombre_TTC__c ? workStep.Tipo_de_trabajo_del_caso__r.Nombre_TTC__c : '';

                        records[index].assignmentLabel = workStep.Mec_nico_asignado__c && workStep.Mec_nico_asignado__c != '' ? 'Reasignar' : 'Asignar';
                        records[index].mechanicAlias = this.getAliasUser(workStep);                    
                        
                        //show menu options only at the beginning, because it depends of the status                    
                        records[index].showStartButton = workStep.Status == 'Nueva' && (workStep.Mec_nico_asignado__c && workStep.Mec_nico_asignado__c != null);
                        records[index].showAssignButton = (workStep.Status != 'Completada');
                        records[index].showPauseButton = workStep.Status == 'En curso';
                        records[index].showContinueButton = workStep.Status == 'En pausa';
                        records[index].showCompleteButton = workStep.Status == 'En curso';               
                        
                        //Flags to control how the running time is shown
                        records[index].isRunning = workStep.Status == 'En curso';
                        records[index].isCompleted = workStep.Status == 'Completada';
                        records[index].isPaused = workStep.Status == 'En pausa';
                        records[index].isDefault = !records[index].isRunning && !records[index].isCompleted && !records[index].isPaused;
                        
                        //Show the menu option only when work step's status is completed or empty
                        records[index].showMenu = workStep.Status != 'Completada' && workStep.Status != undefined && workStep.Status != '';
                        
                        //minutes worked commin from DB
                        records[index].totalMinutesWorkedWithoutPause = workStep.Total_de_tiempo_trabajado_en_minutos__c ? workStep.Total_de_tiempo_trabajado_en_minutos__c : 0;
                        
                        //Work Order CreatedDate
                        records[index].workOrderCreatedDate = workStep.WorkOrder ? workStep.WorkOrder.CreatedDate : null;
                        
                        //default status color
                        records[index].statusBackground = '';
                    }
                });            
                this.workSteps = records;
                this.flagLoadCompleted = true;        
                this.error = undefined;
            }           
        } else if (error) {
            this.workSteps = [];
            this.error = error;            
        }

        this.isLoading = false; 
    }    

    getAliasUser(workStep){
        let alias = undefined;
        if(workStep.Mec_nico_asignado__r && workStep.Mec_nico_asignado__r.Name != undefined && workStep.Mec_nico_asignado__r.Name != null && workStep.Mec_nico_asignado__r.Name.length > 0){  
          let words = workStep.Mec_nico_asignado__r.Name.split(' ');
          //the contact name contains at least two words
          if(words.length > 1){
            alias = words[0].charAt(0) + words[1].charAt(0);
          }else{
            alias = words[0].charAt(0) + words[0].charAt(1);
          }
        }else{
            alias = 'SN';
        }
        return alias.toUpperCase();         
    }

    calcularTiempos(){
        let currentTime = new Date();
        this.workSteps.forEach((workStep, index) => {
            let hoursWorked = 0;
            let minutesWorked = 0;
            let secondsWorked = 0;

            let hoursPaused = 0;
            let minutesPaused = 0;
            let secondsPaused = 0;

            let totalMinutesWorked = 0
            let totalMinutesPaused = 0

            if(workStep.StartTime){             
                let milliseconds = Math.floor(currentTime - new Date(workStep.StartTime));

                hoursWorked = Math.floor(milliseconds  / 3600000); // hours      
                minutesWorked = Math.floor(((milliseconds % 86400000) % 3600000) / 60000);///minutes la diferencia es en minutos del 0 - 59
                secondsWorked = Math.floor((((milliseconds % 86400000)% 3600000) % 60000) /1000);//La diferencia en segundos es del 0 al 60
                                
                totalMinutesWorked += (hoursWorked * 60) + minutesWorked;
                totalMinutesWorked -= workStep.AcumuladoMinutosPausas__c ? parseFloat(workStep.AcumuladoMinutosPausas__c) : 0;
            }

            if(workStep.isPaused && workStep.Hora_de_inicio_de_pausa__c){
                let milliseconds = Math.floor(currentTime - new Date(workStep.Hora_de_inicio_de_pausa__c));

                hoursPaused = Math.floor(milliseconds  / 3600000); // hours      
                minutesPaused = Math.floor(((milliseconds % 86400000) % 3600000) / 60000);//minutes la diferencia es en minutos del 0 - 59
                secondsPaused = Math.floor((((milliseconds % 86400000)% 3600000) % 60000) /1000);//La diferencia en segundos es del 0 al 60              
                
                totalMinutesPaused += (hoursPaused * 60) + minutesPaused;
                totalMinutesPaused += workStep.AcumuladoMinutosPausas__c ? parseFloat(workStep.AcumuladoMinutosPausas__c) : 0;
            }

            this.workSteps[index].hoursWorked = hoursWorked.toFixed(0);
            this.workSteps[index].minutesWorked = minutesWorked.toFixed(0);
            this.workSteps[index].secondsWorked = secondsWorked.toFixed(0);
            this.workSteps[index].totalMinutesWorked = totalMinutesWorked.toFixed(0);
            
            this.workSteps[index].hoursPaused = hoursPaused;
            this.workSteps[index].minutesPaused = minutesPaused.toFixed(0);
            this.workSteps[index].secondsPaused = secondsPaused.toFixed(0);
            this.workSteps[index].totalMinutesPaused = totalMinutesPaused.toFixed(0);

            //total de minutos trabajados con segundos para determinar el color
            //El tiempo inicial tiene milisegundos
            this.workSteps[index].totalMinutesWithSecondsWorked = parseFloat(this.workSteps[index].totalMinutesWorked +'.'+ this.workSteps[index].secondsWorked).toFixed(2);
        });
    }

    getStatusBackgroundColor(workStep){        
        if (workStep.Status == 'Nueva' && workStep.Mec_nico_asignado__c == undefined) {
            return 'background-color:#f1f1f1;';
        } else if (workStep.Status == 'Nueva' && workStep.Mec_nico_asignado__c) {
            return 'background-color:#eafbfe;';
        } else if (workStep.Status == 'En curso' && parseFloat(workStep.totalMinutesWithSecondsWorked) > parseFloat(workStep.startingMinutes)) {
            return 'background-color:#fb617b;color:white;';
        } else if (workStep.Status == 'En curso' && parseFloat(workStep.totalMinutesWithSecondsWorked) <= parseFloat(workStep.startingMinutes)) {
            return 'background-color:#f2f8e7;';
        } else if (workStep.Status == 'En pausa') {
            return 'background-color:#f8efe1;';
        } else if (workStep.Status == 'Completada') {
            return 'background-color:#23282c;color:white;';
        }
        //return 'background-color:#f6f6f6;';
    }    

    /**
     * Obtiene los minutos iniciales de una tarea
     * Si la tarea no tiene hijos, o si es padre, los minutos se obtienen del tipo de tarea
     * En otro caso y se obtiene del registro relacionado de subtarea
     */
    getStartingMinutes(workStep){
        let hours = 0;
        if(workStep.Tipo_de_trabajo_del_caso__c != null && workStep.Tipo_de_trabajo_del_caso__r.CT_Total_Subtareas_FM__c == 0){ 
                       
            hours = workStep.Tipo_de_trabajo_del_caso__r.Horaa__c != null ? parseFloat(workStep.Tipo_de_trabajo_del_caso__r.Horaa__c) : 0;            
        }else if(workStep.Subtipos_de_trabajos_del_caso__r){
            //Un caso esta relacionado a 1 y solo 1 subtipo
            hours = workStep.Subtipos_de_trabajos_del_caso__r[0].Cantidad_de_horas__c != null ? parseFloat(workStep.Subtipos_de_trabajos_del_caso__r[0].Cantidad_de_horas__c) : 0;
        }
        return (hours * 60).toFixed(0);
    }

   /**
    * Setea el color
    */
    settingStatusColor() {
        this.workSteps.forEach((workStep, index) => {        
            this.workSteps[index].statusBackground = this.getStatusBackgroundColor(workStep);
        });
    }    
      

    handleBackClick(event){
        this.pageNumber--;
        this.refresh();
    }

    handleNextClick(event){
        this.pageNumber++;
        this.refresh();
    }  
    
    handleRefreshClick(event){
        this.isLoading = true;
        this.refresh();
    }

    get isEnablePrevButton(){
        return !(this.totalPages > 0 && this.pageNumber > 1);
    }

    get isEnableNextButton(){
        return !(this.totalPages > 1 && this.pageNumber != this.totalPages);
    }

    @api refresh() {
        this.isLoading = true;        
        this.customTimeOut = setTimeout(() => {
            refreshApex(this.wiredWorkStepsResult);                        
            this.isLoading = false;
        }, 1000);                
    }
    
    get isMoreThanOnePage(){
        return this.totalPages > 1;
    }

    @track isModalOpen = false;
    handleOpenMondalWindow(event) {
        this.selectedWorkStepId = event.target.value;
        let tempWorkStep;
        this.workSteps.forEach((record,index)=>{
            if(record.Id === this.selectedWorkStepId){
                tempWorkStep = record;
            }            
        });    

        //set form title for mechanic's assigment
        if(tempWorkStep && tempWorkStep.Mec_nico_asignado__c != null){
            this.assignmentTitle = 'Reasignar mecánico';
            this.hasMechanicAssigned = true;
            this.mechanicId = tempWorkStep.Mec_nico_asignado__c;
            this.initialSelection = {
                icon: "standard:user",
                icon: "standard:user",
                id: tempWorkStep.Mec_nico_asignado__c,
                sObjectType: "User",
                subtitle: "Mecanico",
                title: tempWorkStep.mechanicName,
            };
            this.currentMechanicName = tempWorkStep.mechanicName;
        }else{
            this.assignmentTitle = 'Asignación de mecánico';
            this.hasMechanicAssigned = false;
            this.mechanicId = null;
            this.currentMechanicName = null;
            this.initialSelection = [];
        }

        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    submitDetails() {
        console.log('this.selectedWorkStepId:'+this.selectedWorkStepId);
        console.log('this.mechanicId:'+this.mechanicId);        
        if(this.selectedWorkStepId == null || this.mechanicId == null){
            this.dispatchEvent(ShowToastEvent({
                title: 'Atención',
                message: 'Por favor seleccione un mecánico',
                variant: 'error'
            }));
            return;
        }

        this.isLoading = true;

        updateRecordMeca({ idRegistro: this.selectedWorkStepId, idMecanicoNuevo: this.mechanicId })
            .then(result => {
                const eventp = new ShowToastEvent({
                    title: 'Mecánico Asignado',
                    message: 'Mecánico asignado correctamente.',
                    variant: 'success'
                });
                this.dispatchEvent(eventp);
                this.refresh();
                this.mechanicId = null;
                this.selectedWorkStepId = null;
            })
            .catch(error => {
                const eventp = new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                });
                this.dispatchEvent(eventp);
                this.refresh();
            });
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        this.isModalOpen = false;
    } 
    
    handleLookupSearch(event) {
        const lookupElement = event.target;
        var params = event.detail;
        params["firedElement"] = 'Mecanico';
        search(params)
            .then((results) => {
                lookupElement.setSearchResults(results);
            })
            .catch((error) => {
                this.errors = [error];
            });
    }
    
    handleLookupSelectionChange(event) {
        let userId = null;
        [userId] = event.detail;
        this.mechanicId = userId;        
        console.log('mechanicId:'+this.mechanicId);
    }    

    handleClickIniciar(event) {
        this.updateRecordAction(event.target.value, 'En curso');
    }

    handleClickPausa(event) {
        this.updateRecordAction(event.target.value, 'En pausa');
    }

    handleClickReanudar(event) {
        this.updateRecordAction(event.target.value, 'En curso');
    }

    handleClickCompletar(event) {
        this.updateRecordAction(event.target.value, 'Completada');
    }

    /**
     * Cambia de estatus al work step
     * @param Id workStepId 
     * @param String status 
     */
    updateRecordAction(workStepId, status) {
        const fields = {};
        fields[WORK_STEP_ID_FIELD.fieldApiName] = workStepId;
        fields[WORK_STEP_STATUS_FIELD.fieldApiName] = status;

        const recordInput = { fields };

        this.isLoading = true;

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Estado actualizado',
                        message: 'El estado ha sido actualizado correctamente.',
                        variant: 'success'
                    })
                );
                this.refresh();
                this.dispatchEvent(new CustomEvent('refreshcases'));
            })
            .catch(error => {
                console.log(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Atención',
                        message: reduceErrors(error).join(', '),
                        variant: 'error'
                    })
                );
                this.refresh();
            });
    }    

    get workStepsFound(){
        return this.workSteps != null && this.workSteps.length > 0;
    }
}