import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { reduceErrors } from 'c/ldsUtils';
// import { refreshApex } from '@salesforce/apex';
import getTerritories from '@salesforce/apex/RM_CT_ConsolaTaller_Ctrl.getTerritories';
import getRecords from '@salesforce/apex/RM_CT_Rep_Tiempos_Improd_Ctrl.getRecords';
import searchUsersFilterByMecanico from '@salesforce/apex/SampleLookupController.searchUsersFilterByMecanico';

export default class Rm_ct_reporte_tiempos_improductivos extends LightningElement {

    @track records = [];

    @track isLoading;

    @track pageNumber = 1;
    @track totalPages = 0;
    @track totalRecords = 0;

    @track showFilters = true;

    ampm = false;

    //filters
    @track territoryId = 'all';
    @track mechanicId = null;
    @track startDate = null;
    @track endDate = null;
    @track caseNumber = null;
    @track workOrderNumber = null;    

    mechanicInicialSelection = [];
    errors = [];

    mechanicsItems = [];

    wiredRecordsResult;

    territories;
    allTerritories = [];
    @track selectedTerritories = [];
    @wire(getTerritories)
    wiredTerritories({ data, error }) {
        if (data) {
            this.territories = data.map(item => ({ 'label': item.Name, 'value': item.Id }));
            this.allTerritories = data.map(item => (item.Id));
            this.selectedTerritories = data.map(item => (item.Id));
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

    @wire(getRecords, { territories: '$selectedTerritories', mechanicId: "$mechanicId",caseNumber: "$caseNumber", workOrderNumber: "$workOrderNumber", startDate: "$startDate", endDate: "$endDate" })
    wiredRecords(result) {
        this.wiredRecordsResult = result;
        this.records = [];
        if (result.data) {
            let tmpRecords = result.data.records ? JSON.parse(JSON.stringify(result.data.records)) : [];
            tmpRecords.map((item) => {
                let tmpRecord = {
                    tecnico: item.Mecanico__r && item.Mecanico__r.Name ? item.Mecanico__r.Name : '-',
                    // taller: item.Work_Step__r && item.Work_Step__r.WorkOrder && item.Work_Step__r.WorkOrder.ServiceTerritory && item.Work_Step__r.WorkOrder.ServiceTerritory.Name ? item.Work_Step__r.WorkOrder.ServiceTerritory.Name : '-',
                    caso: item.Caso__r && item.Caso__r.CaseNumber ? item.Caso__r.CaseNumber : '-',
                    // orden: item.Work_Step__r && item.Work_Step__r.WorkOrder && item.Work_Step__r.WorkOrder.WorkOrderNumber ? item.Work_Step__r.WorkOrder.WorkOrderNumber : '-',
                    tarea: item.Work_Step__r && item.Work_Step__r && item.Work_Step__r.Name ? item.Work_Step__r.Name : '-',        
                    fecha: item.Fecha__c ? item.Fecha__c : '-',
                    observaciones: item.Observaciones__c ? item.Observaciones__c : '-',
                    fechaInicio: item.Fecha__c ? item.Fecha__c : item.Inicio__c,
                    horaInicio: item.Hora_inicio__c ? item.Hora_inicio__c : '',
                    horafin: item.Hora_fin__c ? item.Hora_fin__c : '',
                    fechaFin: item.Fin__c
                };
                this.records.push(tmpRecord);
            });
        } else if (result.error) {
            this.records = [];
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Atención',
                    message: reduceErrors(result.error).join(', '),
                    variant: 'error'
                })
            ); 
            this.showFilters = true;           
        }
    }

    handleStoreChange(event) {
        this.inputTerritoryId = event.target.value;
    }

    handleStarDateChange(event) {
        this.startDate = event.target.value;
    }

    handleEndDateChange(event) {
        this.endDate = event.target.value;
    }

    handleMechanicSearch(event) {
        const lookupElement = event.target;
        let params = event.detail;
        params["objName"] = 'Mecanico';
        params["icon"] = 'standard:user';

        searchUsersFilterByMecanico(params)
            .then((results) => {
                lookupElement.setSearchResults(results);
                this.mechanicsItems = results;
            })
            .catch((error) => {
            });
    }

    handleMechanicSelectionChange(event) {
        this.mechanicId = null;
        [this.mechanicId] = event.detail;
    }

    customTimeOut;
    refresh() {
        this.isLoading = true;
        this.customTimeOut = setTimeout(() => {
            // refreshApex(this.wiredWorkStepResult);
            this.isLoading = false;
        }, 1000);
    }

    handleTerritoryChange(event) {
        this.selectedTerritories = event.detail.value;
    }

    handleShowFiltersClick() {
        this.showFilters = !this.showFilters;
        // if(this.showFilters){
        //     this.mechanicsItems.forEach((item)=>{
        //         if(item.id == this.inputMechanicId){
        //             this.mechanicInicialSelection = item;
        //         }
        //     });
        // }
    }

    handleApplyFiltersClick() {
        // const diffInTime = new Date(this.inputEndDate).getTime() - new Date(this.inputStartDate).getTime();
        // const numDays = diffInTime > 0 ? diffInTime / (1000 * 3600 * 24) : 0;
        // console.log(numDays);
        // if (numDays <= 60) {
            this.showFilters = false;
            // this.refresh();
        // } else {
        //     this.dispatchEvent(
        //         new ShowToastEvent({
        //             title: 'Atención',
        //             message: 'El rango de dias maximo permitido es de 60 dias, favor de reducir el rango fecha inicio o fecha fin.',
        //             variant: 'error'
        //         })
        //     );
        // }
    }

    handleResetClick(event) {
        this.mechanicInicialSelection = [];
        this.records = [];

        this.territoryId = 'all';
        this.mechanicId = null;
        this.startDate = null;
        this.endDate = null;
    }

    get recordsFound() {
        return this.records.length > 0;
    }

    get isExportExcelAvailable() {
        return this.records.length > 0;
    }

    handleExportClick() {
        let doc = '<table>';

        doc += '<table style="border-collapse: collapse; width: 100%; height: 54px;" border="1">' +
            '<thead>' +
            '<tr style="height: 18px;">' +
            '<th style="width: 12%; height: 18px; text-align: center; background-color: #f0f0f0;"><strong>Tecnico</strong></th>' +
            '<th style="width: 12%; height: 18px; text-align: center; background-color: #f0f0f0;"><strong># Caso</strong></th>' +
            '<th style="width: 12%; height: 18px; text-align: center; background-color: #f0f0f0;"><strong>Tarea</strong></th>' +
            '<th style="width: 12%; height: 18px; text-align: center; background-color: #f0f0f0;"><strong>Fecha Inicio</strong></th>' +
            '<th style="width: 12%; height: 18px; text-align: center; background-color: #f0f0f0;"><strong>Fecha Fin</strong></th>' +
            '<th style="width: 12%; height: 18px; text-align: center; background-color: #f0f0f0;"><strong>Hora Inicio</strong></th>' +
            '<th style="width: 12%; height: 18px; text-align: center; background-color: #f0f0f0;"><strong>Hora Fin</strong></th>' +
            '<th style="width: 12%; height: 18px; text-align: center; background-color: #f0f0f0;"><strong>Observaciones</strong></th>' +
            '</tr>' +
            '</thead>' +
            '<tbody>';
        let rows = '';
        this.records.forEach(record => {
            rows += '<tr>';
            rows += '<td>' + (record.tecnico) + '</td>';
            rows += '<td>' + record.caso + '</td>';
            rows += '<td>' + record.tarea + '</td>';
            rows += '<td>' + record.fechaInicio + '</td>';
            rows += '<td>' + record.fechaFin + '</td>';
            rows += '<td>' + record.horaInicio + '</td>';
            rows += '<td>' + record.horaFin + '</td>';
            rows += '<td>' + record.observaciones + '</td>';
            rows += '</tr>';
        });
        doc += rows;
        doc += '</tbody>';
        doc += '</table>';
        // let element = 'data:application/vnd.ms-excel;base64,' + window.btoa(doc);
        let element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';

        downloadElement.download = 'Reporte tiempos improductivos.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }

    get isApplybuttonEnabled() {
        return this.startDate == null || this.endDate == null;
    }


    handleWorkOrderNumberChange(event) {
        this.workOrderNumber = event.target.value;       
    }    

    handleCaseNumberChange(event) {
        this.caseNumber = event.target.value;     
    }    
}