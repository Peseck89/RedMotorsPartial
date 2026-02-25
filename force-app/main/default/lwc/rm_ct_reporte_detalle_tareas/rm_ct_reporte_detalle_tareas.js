import { LightningElement, api,track, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getWorkSteps from '@salesforce/apex/RM_CT_ReporteDetalleTareas_Ctrl.getWorkSteps';

export default class Rm_ct_reporte_detalle_tareas extends LightningModal {
    @track workSteps = [];
    @track error;
    @track isLoading = false;
    
    @api mechanicId = null;
    @api territoryId = null;
    @api caseId = null;

    pageNumber = 1;
    pageSize = 15;  // Number of records per page
    @track disableNext = false;

    sfdcBaseURL;

    columns = [
        { 
            label: 'Trabajo a realizar', 
            fieldName: 'workToDo', 
            initialWidth: 150, 
            cellAttributes: {
                style: { 
                    fieldName: 'cellClass' 
                }
            }         
        },
        { 
            label: 'Tarea',
            fieldName: 'workStepUrl', 
            type: 'url',
            initialWidth: 250,
            typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'},
            cellAttributes: 
            { 
                style: { 
                    fieldName: 'cellClass' 
                } 
            } 
        },        
        {
            label: 'HA',
            fieldName: 'RM_TotalHorasFX__c',
            type: 'number',
            typeAttributes: { minimumFractionDigits: 2 },
            cellAttributes: {
                class: 'slds-text-align_right highlight-row',
                title: 'Horas asignadas',
                style: { 
                    fieldName: 'cellClass' 
                } 
            }
        }, 
        {
            label: 'Horas trabajadas',
            fieldName: 'hours',
            type: 'number',
            initialWidth: 150,
            typeAttributes: { minimumFractionDigits: 2 },
            cellAttributes: {
                class: 'slds-text-align_right',
                style: { 
                    fieldName: 'cellClass' 
                } 
            }
        },  
        {
            label: 'Horas facturadas',
            fieldName: 'RM_TotalHorasFX__c',
            type: 'number',
            initialWidth: 150,
            typeAttributes: { minimumFractionDigits: 2 },
            cellAttributes: {
                class: 'slds-text-align_right',
                style: { 
                    fieldName: 'cellClass' 
                }
            }
        },            
        { 
            label: 'Trabajada a nivel', 
            fieldName: 'modoTrabajo', 
            initialWidth: 150,
            cellAttributes: {
                style: { 
                    fieldName: 'cellClass' 
                }
            } 
        },
        // { 
        //     label: 'Tipo tarea', 
        //     fieldName: 'workStepType', 
        //     initialWidth: 150,
        //     cellAttributes: {
        //         style: { 
        //             fieldName: 'cellClass' 
        //         }
        //     } 
        // },
        { 
            label: 'Orden de trabajo',
            fieldName: 'workOrderNumber',
            initialWidth: 150,
            cellAttributes: {
                style: { 
                    fieldName: 'cellClass' 
                }
            } 
        },
        { 
            label: 'Caso', 
            fieldName: 'caseNumber',
            initialWidth: 150,
            cellAttributes: {
                style: { 
                    fieldName: 'cellClass' 
                }
            }
        },
        { 
            label: 'Territorio', 
            fieldName: 'territoryName', 
            initialWidth: 150,
            cellAttributes: {
                style: { 
                    fieldName: 'cellClass' 
                }
            }
        },    
        { 
            label: 'Mecánico', 
            fieldName: 'mechanicName', 
            initialWidth: 150, 
            cellAttributes: {
                style: { 
                    fieldName: 'cellClass' 
                }
            } 
        },
        // ... other columns as needed
    ];

    //create a function to convert minutes to hours
    convertMinutesToHours(minutes) {
        if (minutes) {
            let hours = Math.floor(minutes / 60);
            let minutesRemainder = minutes % 60;
            return hours + 'h ' + minutesRemainder + 'm';
        }
        return '';
    }

    connectedCallback() {
        this.sfdcBaseURL = window.location.origin;        
        this.loadWorkSteps();
    }

    showWorkStep(record){
        return ((record.Flag_Is_Task_FX__c === false && record.Tipo_de_trabajo_del_caso__c && record.Tipo_de_trabajo_del_caso__r.RM_ModoTrabajo__c && record.Tipo_de_trabajo_del_caso__r.RM_ModoTrabajo__c === 'Tarea padre') 
        || (record.Flag_Is_Task_FX__c === true && record.Tipo_de_trabajo_del_caso__c && record.Tipo_de_trabajo_del_caso__r.RM_ModoTrabajo__c && record.Tipo_de_trabajo_del_caso__r.RM_ModoTrabajo__c === 'Tarea hija'));
    }

    loadWorkSteps() {
        if (!this.mechanicId || !this.territoryId || !this.caseId) {
            return;
        }
        this.isLoading = true;
        getWorkSteps({ mechanicId: this.mechanicId, territoryId: this.territoryId, caseId: this.caseId, offset: (this.pageNumber-1) * this.pageSize, pageSize: this.pageSize })
        .then(data => {
            this.workSteps = data           
            .map(record => {
                let workStepUrl = this.sfdcBaseURL + '/'+record.Id;
                let workOrderNumber = record.WorkOrder && record.WorkOrder.WorkOrderNumber ? record.WorkOrder.WorkOrderNumber : '';                
                let modoTrabajo = record.Tipo_de_trabajo_del_caso__c && record.Tipo_de_trabajo_del_caso__r.RM_ModoTrabajo__c ? record.Tipo_de_trabajo_del_caso__r.RM_ModoTrabajo__c : '';        
                let workStepType = record.Flag_Is_Task_FX__c === true ? 'Tarea hija' : 'Tarea padre';
                let caseNumber = record.Caso__r && record.Caso__r.CaseNumber ? record.Caso__r.CaseNumber : '';
                let workToDo = record.Caso__r && record.Tipo_de_trabajo_del_caso__r &&  record.Tipo_de_trabajo_del_caso__r.Name ? record.Tipo_de_trabajo_del_caso__r.Name : '';
                
                if(record.Tipo_de_trabajo_del_caso__c && record.Tipo_de_trabajo_del_caso__c && record.Tipo_de_trabajo_del_caso__r && record.Tipo_de_trabajo_del_caso__r.Tipotrabajo__r && record.Tipo_de_trabajo_del_caso__r.Tipotrabajo__r.Name){
                    workToDo += ' - '+record.Tipo_de_trabajo_del_caso__r.Tipotrabajo__r.Name;
                }

                let mechanicName = record.Mec_nico_asignado__r && record.Mec_nico_asignado__r.Name ? record.Mec_nico_asignado__r.Name : '';
                let territoryName = record.Caso__r && record.Caso__r.Service_Territory1__r ? record.Caso__r.Service_Territory1__r.Name : '';
                let hours = record.Total_de_tiempo_trabajado_en_minutos__c != null ? (record.Total_de_tiempo_trabajado_en_minutos__c / 60).toFixed(2) : '';
                
                let cellClass = record.Flag_Is_Task_FX__c === false ? 'background-color: yellow;' : '';

                return { ...record, workStepUrl, workOrderNumber, caseNumber, mechanicName, territoryName,hours,modoTrabajo,workStepType,workToDo,cellClass};
            });

            this.isLoading = false;
            this.error = undefined;

            // Check if the number of records fetched is less than the page size
            if (data.length < this.pageSize) {
                this.disableNext = true;
            } else {
                this.disableNext = false;
            }
        })
        .catch(error => {
            this.error = error;
            this.isLoading = false;
        });
    }

    buildTree(data) {
        let tree = [];
    
        // Group data by Tipo_de_trabajo_del_caso__c
        let groups = data.reduce((groups, item) => {
            let group = item.Tipo_de_trabajo_del_caso__c;
            if (!groups[group]) {
                groups[group] = [];
            }
            groups[group].push(item);
            return groups;
        }, {});
    
        // For each group, find the parent item and add children to it
        for (let group in groups) {
            let items = groups[group];
            let parent = items.find(item => item.Flag_Is_Task_FX__c === false);
            if (parent) {
                parent.children = items.filter(item => item !== parent);
                tree.push(parent);
            }
        }
    
        return tree;
    }

    handleNext() {
        this.pageNumber++;
        this.loadWorkSteps();
    }

    handlePrevious() {
        if (this.pageNumber > 1) {
            this.pageNumber--;
            this.loadWorkSteps();
        }
    }

    get disablePrevious(){
        return this.pageNumber<=1;
    }
}