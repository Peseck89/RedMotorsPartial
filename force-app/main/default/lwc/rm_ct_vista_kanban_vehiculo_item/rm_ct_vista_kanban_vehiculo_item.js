import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getData from '@salesforce/apex/RM_CT_VistaKanbanVehiculo_Ctrl.getData';

export default class Rm_ct_vista_kanban_vehiculo_item extends LightningElement {

    @api territoryId = '';
    @api stage = '';
    @api workOrderNumber = '';
    @api caseNumber = '';    
    @api vin = '';    
    @api placa = '';    
    @api startDate = '';    
    @api endDate = '';

    pageNumber = 1;

    totalRecords = 0;
    pageSize = 0;

    @track records = [];    
    wiredWorkOrderResult;

    @wire(getData,{ territoryId: "$territoryId", etapa: "$stage", caseNumber: "$caseNumber", workOrderNumber: "$workOrderNumber", vin: "$vin", placa: "$placa",startDate: "$startDate", endDate: "$endDate",pageNumber: '$pageNumber'})
    wiredWorkOrderResult(result) {
        this.wiredWorkOrderResult = result;      
        if (result.data && result.data.records) {     
            // console.log('test test:'+this.stage);
            this.totalRecords = result.data.totalRecords;
            this.pageSize = result.data.pageSize;
            this.pageNumber = result.data.pageNumber;

            if(this.pageNumber === 1){
                this.records = [];
            }

            this.records.push(...result.data.records);
        
            // console.log(this.records);
            this.error = undefined;
            this.isLoading = false;
        } else if (result.error) {
            this.error = result.error;
            this.records = undefined;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Atención!',
                    message: result.error.body.message,
                    variant: 'error'
                })
            );
            this.isLoading = false;
        }
    }

    get hasMoreRecords(){
        return this.totalRecords > this.pageSize * this.pageNumber;
    }

    handleMoreClick(){
        this.pageNumber = this.pageNumber + 1;
    }

    connectedCallback() {
    }

    get recordsFound(){
        return this.records && this.records.length > 0;
    }

    handleDragOver(event){
        event.preventDefault();
    }

    handleDrop(event){
        // event.target.style.border = '';
        // let workStepId = event.dataTransfer.getData("caseId");
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
}