import { LightningElement,wire,track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getTerritories from '@salesforce/apex/WorkStepController.getTerritories';
import getWorkSteps from '@salesforce/apex/CT_Reporte_Cronologico_Controller.getWorkSteps';
import searchUsersFilterByMecanico from '@salesforce/apex/SampleLookupController.searchUsersFilterByMecanico';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CT_Reporte_Tiempos_Improductivos extends LightningElement {

    territories;
    allTerritories;
    selectedTerritories;

    ampm = false;

    //filters
    inputTerritoryId = 'all';
    inputMechanicId = null;
    inputStartDate = null;
    inputEndDate = null;
    caseNumber = null;

    mechanicInicialSelection = [];
    errors = [];    

    isLoading = false;
    showFilters = true;  

    workSteps = [];  
    records = []; 
    
    mechanicsItems = [];
    
    @wire(getTerritories)
    wiredTerritories({ data, error }) {
        this.territories = [];
        this.allTerritories = [];
        this.selectedTerritories = [];        
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

    @wire(getWorkSteps,{ territories: '$selectedTerritories',mechanicId: "$inputMechanicId",caseNumber: "$caseNumber",startDate: "$inputStartDate", endDate: "$inputEndDate" })  
    wiredWorkSteps(result) {
        this.wiredWorkStepResult = result;
        if (result.data) { 
            this.records = [];                                                                  
            let tmpRecords = result.data.records ? JSON.parse(JSON.stringify(result.data.records)) : [];
            tmpRecords.map((item)=>{                
                let tmpRecord = {
                    tecnico: item.Work_Step__r && item.Work_Step__r.Mec_nico_asignado__r && item.Work_Step__r.Mec_nico_asignado__r.Name ? item.Work_Step__r.Mec_nico_asignado__r.Name : '-',
                    taller: item.Work_Step__r && item.Work_Step__r.WorkOrder && item.Work_Step__r.WorkOrder.ServiceTerritory && item.Work_Step__r.WorkOrder.ServiceTerritory.Name ? item.Work_Step__r.WorkOrder.ServiceTerritory.Name : '-',
                    caso: item.Work_Step__r && item.Work_Step__r.Caso__r && item.Work_Step__r.Caso__r.CaseNumber ? item.Work_Step__r.Caso__r.CaseNumber : '-',
                    tarea: item.Work_Step__r && item.Work_Step__r.Tipo_de_trabajo_del_caso__r && item.Work_Step__r.Tipo_de_trabajo_del_caso__r.Nombre_TTC__c ? item.Work_Step__r.Tipo_de_trabajo_del_caso__r.Nombre_TTC__c : '-',
                    estadoAnterior: item.Old_Value__c ? item.Old_Value__c : '-',
                    estadoNuevo: item.New_Value__c ? item.New_Value__c : '-',
                    fechaInicio: item.Start_Date_Time__c,
                    fechaFin: item.End_Date_Time__c
                };
                this.records.push(tmpRecord);
            });                        
        }else if(result.error){
            this.records = [];
        }
    }   
    
    handleStoreChange(event) {
        this.inputTerritoryId = event.target.value;      
    }

    handleStarDateChange(event) {
        this.inputStartDate = event.target.value;
    }

    handleEndDateChange(event) {
        this.inputEndDate = event.target.value;      
    }   

    handleMechanicSearch(event){
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

    handleMechanicSelectionChange(event){     
        this.inputCaseId = null;
        [ this.inputMechanicId ] = event.detail;
    }    
    
    customTimeOut;
    refresh(){
        this.isLoading = true;        
        this.customTimeOut = setTimeout(()=>{
            // refreshApex(this.wiredWorkStepResult);
            this.isLoading = false;
        },1000);
    }    

    handleTerritoryChange(event){
        this.selectedTerritories = event.detail.value;
    }

    handleShowFiltersClick(){
        this.showFilters = !this.showFilters;
        if(this.showFilters){
            this.mechanicsItems.forEach((item)=>{
                if(item.id == this.inputMechanicId){
                    this.mechanicInicialSelection = item;
                }
            });
        }
    }

    handleApplyFiltersClick(){
        const diffInTime = new Date(this.inputEndDate).getTime() - new Date(this.inputStartDate).getTime();        
        const numDays = diffInTime > 0 ? diffInTime / (1000 * 3600 * 24) : 0;
        console.log(numDays);
        if (numDays <= 60) {
            this.showFilters = false;
            this.refresh();            
        }else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Atención',
                    message: 'El rango de dias maximo permitido es de 60 dias, favor de reducir el rango fecha inicio o fecha fin.',
                    variant: 'error'
                })
            ); 
        }
    }

    handleResetClick(event){
        this.inputTallerId = 'all';
        this.inputMechanicId = null;
        this.inputStartDate = null;
        this.inputEndDate = null;
        this.caseNumber = null;
        this.mechanicInicialSelection = [];
        this.records = [];
    }

    get recordsFound(){
        return this.records.length > 0;
    }

    get isExportExcelAvailable(){
        return this.records.length > 0;
    }

    handleExportClick(){
        let doc = '<table>';

        doc += '<table style="border-collapse: collapse; width: 100%; height: 54px;" border="1">'+
                    '<thead>'+
                        '<tr style="height: 18px;">'+
                            '<th style="width: 12%; height: 18px; text-align: center; background-color: #f0f0f0;"><strong>Tecnico</strong></th>'+
                            '<th style="width: 12%; height: 18px; text-align: center; background-color: #f0f0f0;"><strong>Taller</strong></th>'+
                            '<th style="width: 12%; height: 18px; text-align: center; background-color: #f0f0f0;"><strong># Caso</strong></th>'+
                            '<th style="width: 12%; height: 18px; text-align: center; background-color: #f0f0f0;"><strong>Tarea</strong></th>'+
                            '<th style="width: 12%; height: 18px; text-align: center; background-color: #f0f0f0;" width="83"><strong>Estado Anterior</strong></th>'+
                            '<th style="width: 12%; height: 18px; text-align: center; background-color: #f0f0f0;" width="83"><strong>Estado Nuevo</strong></th>'+
                            '<th style="width: 12%; height: 18px; text-align: center; background-color: #f0f0f0;" width="83"><strong>Fecha inicio</strong></th>'+
                            '<th style="width: 16%; height: 18px; text-align: center; background-color: #f0f0f0;"><strong>Fecha fin</strong></th>'+
                        '</tr>'+
                    '</thead>'+
                    '<tbody>';
        let rows = '';
        this.records.forEach(record => {
            rows += '<tr>';
                rows += '<td>'+(record.tecnico)+'</td>'; 
                rows += '<td>'+(record.taller)+'</td>'; 
                rows += '<td>'+record.caso+'</td>';
                rows += '<td>'+(record.tarea)+'</td>'; 
                rows += '<td>'+record.estadoAnterior+'</td>'; 
                rows += '<td>'+record.estadoNuevo+'</td>'; 
                rows += '<td>'+record.fechaInicio+'</td>'; 
                rows += '<td>'+record.fechaFin+'</td>'; 
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

        downloadElement.download = 'Reporte cronológico.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }


    get isApplybuttonEnabled(){
        return this.inputStartDate == null || this.inputEndDate == null;
    }

    handleCaseNumberChange(event) {
        this.caseNumber = event.target.value;     
    }    
}