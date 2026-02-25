import { LightningElement, wire, track } from 'lwc';
import { reduceErrors } from 'c/ldsUtils';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import WORKORDER_OBJECT from '@salesforce/schema/Case'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTerritories from '@salesforce/apex/RM_CT_ConsolaTaller_Ctrl.getTerritories';
import DETALLE_ESTATUS_CASO from '@salesforce/schema/Case.StatusDetail__c';

const DELAY = 300;

export default class CT_vistaVehiculoKanban extends LightningElement {
    error;

    isLoading = false;
    
    territoryId = '';    
    startDate = null;    
    endDate = null;
    workOrderNumber = '';
    caseNumber = '';
    stageName = '';    
    vin = '';    
    placa = '';
    
    workOrderStageNames;
    
    originalWorkOrderStageNames;

    showFilters = false;

    showModal = false;

    openPanel = 'slds-panel slds-size_medium slds-panel_docked slds-panel_docked-right slds-panel_drawer';
    
    selectedTempStages = [];

    requiredStagesOptions = [];

    workOrderStageNamesForSelect;  
    
    recordsFound = false;

    delayTimeout;

    @wire(getTerritories,{flagMultiSelect:false})
    territories;
    wiredTerritory({ data, error }) {
        if (data) {
            this.territories = data.values;           
        }else if (error){
            this.dispatchEvent(
                new ShowToastEvent({
                title: 'Atención!',
                message: reduceErrors(error).join(', '),
                variant: 'error'
                })
            )
        }
    }        

    /** Fetch metadata abaout the opportunity object**/
    @wire(getObjectInfo, { objectApiName: WORKORDER_OBJECT })
    workStepObject

    @wire(getPicklistValues, {recordTypeId: '$workStepObject.data.defaultRecordTypeId',fieldApiName: DETALLE_ESTATUS_CASO})
    wiredWorkOrderStatusDetailNames({ data, error }) {
        if (data) {
            let filteredData = data.values.filter(item => item.label != 'Orden Facturada' && item.value != 'Orden Rechazada');
            this.workOrderStageNamesForSelect = filteredData.map(item => ({'label':item.label,'value':item.value}))
            this.workOrderStageNames = filteredData.map(item => item.value)          
            this.originalWorkOrderStageNames = this.workOrderStageNames;                        
        }else if (error){
            this.dispatchEvent(
                new ShowToastEvent({
                title: 'Atención!',
                message: result.error.body.message,
                variant: 'error'
                })
            )
        }
    }    

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
        this.workOrderStageNames = this.selectedTempStages;
    }

    handleTerritoryIdChange(event) { 
        const searchKey = event.target.value;
        this.territoryId = searchKey;
    }

    handleStageChange(event) {
        const searchKey = event.target.value;
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            this.stageName = searchKey;
        }, DELAY);          
        this.propagaEventoFiltroCambiado();
    }    
        
    handleStartDateChange(event) {        
        const searchKey = event.detail.value;
        this.startDate = searchKey;   
    }
    
    handleEndDateChange(event) {        
        const searchKey = event.detail.value;
        this.endDate = searchKey;
    }
    
    handleWorkOrderChange(event){
        const searchKey = event.detail.value;
        this.workOrderNumber = searchKey;   
    }
    
    handleCaseNumberChange(event){
        const searchKey = event.detail.value;
        this.caseNumber = searchKey;    
    }    
    
    handlePlacaChange(event){
        const searchKey = event.detail.value;
        this.placa = searchKey;
    }

    handleVinChange(event){
        const searchKey = event.detail.value;
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            this.vin = searchKey;
        }, DELAY);
        this.propagaEventoFiltroCambiado();
    }

    handleStageSelectedChange(event){
        const searchKey = event.detail.value;
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() => {
            this.selectedTempStages = searchKey;
        }, DELAY);          
    }
    
    propagaEventoFiltroCambiado(){
        // const selectedEvent = new CustomEvent('filtromodificado');
        // this.dispatchEvent(selectedEvent);
    }
}