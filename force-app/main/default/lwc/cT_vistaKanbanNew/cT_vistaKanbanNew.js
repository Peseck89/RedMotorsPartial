import { LightningElement, wire, track } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import WORKSTEP_STATUS_FIELD from '@salesforce/schema/WorkStep.Status';
import WORKSTEP_ID_FIELD from '@salesforce/schema/WorkStep.Id';
import getTerritories from '@salesforce/apex/RM_CT_ConsolaTaller_Ctrl.getTerritories'
import getWorkStepStatus from '@salesforce/apex/RM_CT_ConsolaTaller_Ctrl.getWorkStepStatus'
import getServiceTypes from '@salesforce/apex/RM_CT_ConsolaTaller_Ctrl.getServiceTypes'

export default class CT_vistaVehiculoKanban extends LightningElement {
    error;

    isLoading = true;
    
    @track tallerId = null;    
    @track startCreationDate = null;    
    @track endCreationDate = null;
    @track caseNumber = null;
    @track workServiceType = null;
    @track stageName = null;    
    @track vin = null;    
    @track nested = true;

    startTime = null;
    endTime = null;
    
    workStepStages;
    originalWorkOrderStageNames;

    showFilters = false;
    showModal = false;

    openPanel = 'slds-panel slds-size_medium slds-panel_docked slds-panel_docked-right slds-panel_drawer';

    stagesToShow = 5;

    serviceTypes = [];         

    selectedTempStages = [];

    requiredStagesOptions = [];

    workStepStagesForSelect;  

    @wire(getWorkStepStatus)
    wiredWorkStepStatuses({ data, error }) {
        if (data) {
            this.workStepStagesForSelect = data;                                          
            this.workStepStages = data.map(item => (item.value));
            this.originalWorkOrderStageNames = this.workStepStages;       
        } else if (error){
            this.workStepStagesForSelect = [];                              
            this.workStepStages = []
            this.originalWorkOrderStageNames = [];
            this.dispatchEvent(
            new ShowToastEvent({
                title: 'Atención!',
                message: result.error.body.message,
                variant: 'error'
            })
            );
        }
    } 

    @wire(getServiceTypes)
    wiredServiceTypes({ data, error }) {
        if (data) {
            this.serviceTypes = data;                                            
        } else if (error){
            this.serviceTypes = [];  
            this.dispatchEvent(
            new ShowToastEvent({
                title: 'Atención!',
                message: result.error.body.message,
                variant: 'error'
            })
            );
        }
    }

    @wire(getTerritories)
    talleres

    handleButtonFilterClick() {
        this.showFilters = !this.showFilters;
        this.openPanel = 'slds-panel slds-size_medium slds-panel_docked slds-panel_docked-right slds-panel_drawer';
        if(this.showFilters){
            this.openPanel+=' slds-is-open';
        }
    }    

    handleButtonOpenModalDialogClick() {
        this.showModal = true;
        this.showFilters = false;
        this.openPanel = 'slds-panel slds-size_medium slds-panel_docked slds-panel_docked-right slds-panel_drawer';
    }

    handleButtonCloseModalDialogClick() {
        this.showModal = false;
    }

    handleButtonSaveModalDialogClick() {
        this.showModal = false;                
        this.workStepStages = this.selectedTempStages;
        // this.stageName = this.selectedTempStages;
    }

    handleTallerChange(event) {
        this.tallerId = event.detail.value;
        this.isLoading = true;
    }

    handleServiceTypeChange(event) {   
        this.workServiceType = event.detail.value;   
        this.isLoading = true;     
    }

    // handleStateChange(event) {  
    //     this.stageName = event.detail.value;
    // }    
        
    handleStartCreationDateChange(event) {        
        this.startCreationDate = event.detail.value;
        this.isLoading = true;
    }
    
    handleEndCreationDateChange(event) {        
        this.endCreationDate = event.detail.value;
        this.isLoading = true;
    }
    
    handleCaseNumberChange(event){        
        this.caseNumber = event.target.value;
        this.isLoading = true;       
    }
    
    handleVinChange(event){        
        this.vin = event.target.value;
        this.isLoading = true;
    }

    // refresh(){
    //     this.isLoading = true;
    //     setTimeout(() => {
    //        refreshApex(this.wiredStepWorksResult);
    //        this.isLoading = false;
    //      }, 300);  
    // }

    handleWorkStepChange(event){
        this.selectedTempStages = event.detail.value;
    }

    handleDragOver(event){
        // event.preventDefault();
    }

    handleDrop(event){
        // event.target.style.border = '';
        // let workStepId = event.dataTransfer.getData("workstepid");
        // let stageName = event.target.dataset.stage;

        // console.log('===========================');        
        // console.log('workStepId:'+workStepId);
        // console.log('stageName:'+stageName);
        // console.log('===========================');

        // if(workStepId != null && stageName != null){
        //     this.isLoading = true;
        //     const fields = {};
        //     fields[WORKSTEP_ID_FIELD.fieldApiName] = workStepId;
        //     fields[WORKSTEP_STATUS_FIELD.fieldApiName] = stageName;
        //     const recordInput ={fields}
        //     updateRecord(recordInput)
        //     .then(()=>{
        //         this.dispatchEvent(new ShowToastEvent({
        //             title : 'Error',
        //             message : 'La tarea fue movida de etapa correctamente.',
        //             variant : 'success'
        //         }));
        //         this.refresh();
        //     }).catch(error => {
        //         this.dispatchEvent(new ShowToastEvent({
        //             title : 'Error',
        //             message : error.body.message,
        //             variant : 'error'
        //         }));
        //         this.isLoading = false;
        //     })
        // }

    }

    handleNestedChange(event){
        this.nested = event.target.checked;
        this.isLoading = true;  
        // this.refresh();        
    }

    handleButtonRefreshClick(event){
        // this.refresh();        
    }


    get isLoading() {
        return !this.wiredProperty.data && !this.wiredProperty.error;
    }
    
}