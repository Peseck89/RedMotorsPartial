import { LightningElement,wire,track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getTerritories from '@salesforce/apex/WorkStepController.getTerritories';
import getWorkSteps from '@salesforce/apex/ReporteResumenController.getWorkSteps';
import searchUsersFilterByMecanico from '@salesforce/apex/SampleLookupController.searchUsersFilterByMecanico';

export default class CT_Reporte_Resumen extends LightningElement {

    territories;
    allTerritories;
    selectedTerritories;

    ampm = false;

    //filters
    inputTerritoryId = 'all';
    inputMechanicId = null;
    inputStartDate = null;
    inputEndDate = null;

    mechanicInicialSelection = [];
    errors = [];    

    isLoading = false;
    showFilters = true;  

    workSteps = [];  
    records = [];    
    
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

    @wire(getWorkSteps,{ territories: '$selectedTerritories',mechanicId: "$inputMechanicId",startDate: "$inputStartDate", endDate: "$inputEndDate" })  
    wiredWorkSteps(result) {
        this.wiredWorkStepResult = result;
        if (result.data) {
            this.records = [];
            let tmpRecords = result.data.records ? JSON.parse(JSON.stringify(result.data.records)) : [];                                          
            tmpRecords.map((item)=>{        
                let tmpRecord = {
                    tecnico: item.mechanicName,
                    assignedHours: parseFloat(item.assignedHours).toFixed(2),
                    workedHours: parseFloat(item.workedHours).toFixed(2),
                    tiemposImproductivos: parseFloat(item.tiemposImproductivos).toFixed(2),
                    productividad: parseFloat(item.productividad).toFixed(2),
                    eficiencia: parseFloat(item.eficiencia).toFixed(2),
                };
                this.records.push(tmpRecord);
            });            
        }else if(result.error){
            this.records = [];
        }
    }   
    
    handleStoreChange(event) {        
        this.inputTerritoryId = event.target.value;        
        this.refresh();        
    }

    handleStarDateChange(event) {
        this.inputStartDate = event.target.value;
        this.refresh();        
    }

    handleEndDateChange(event) {
        this.inputEndDate = event.target.value;
        this.refresh();        
    }   

    handleMechanicSearch(event){
        const lookupElement = event.target;
        var params = event.detail;
        params["objName"] = 'Mecanico';
        params["icon"] = 'standard:user';

        searchUsersFilterByMecanico(params)
            .then((results) => {
                lookupElement.setSearchResults(results);
            })
            .catch((error) => {                
            });
    }       
    
    customTimeOut;
    refresh(){
        this.isLoading = true;        
        this.customTimeOut = setTimeout(()=>{
            refreshApex(this.wiredWorkStepResult);
            this.isLoading = false;
        },1000);
    }    

    handleTerritoryChange(event){
        this.selectedTerritories = event.detail.value;
    }

    handleShowFiltersClick(){
        this.showFilters = !this.showFilters;
    }

    handleApplyFiltersClick(){
        this.showFilters = false;
        this.refresh();
    }

    handleResetClick(event){
        this.inputTallerId = 'all';
        this.inputEstado = 'all';
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
                            '<th style="width: 50%; height: 18px; text-align: center; background-color: #f0f0f0;"><strong>Tecnico</strong></th>'+
                            '<th style="width: 10%; height: 18px; text-align: center; background-color: #f0f0f0;"><strong>Horas Asignadas</strong></th>'+
                            '<th style="width: 10%; height: 18px; text-align: center; background-color: #f0f0f0;"><strong>Horas Trabajadas</strong></th>'+
                            '<th style="width: 10%; height: 18px; text-align: center; background-color: #f0f0f0;"><strong>Tiempos Improductivos</strong></th>'+
                            '<th style="width: 10%; height: 18px; text-align: center; background-color: #f0f0f0;" width="83"><strong>Eficiencia</strong></th>'+
                            '<th style="width: 10%; height: 18px; text-align: center; background-color: #f0f0f0;" width="83"><strong>Productividad</strong></th>'+
                        '</tr>'+
                    '</thead>'+
                    '<tbody>';
        let rows = '';

        this.records.forEach(record => {
            rows += '<tr>';
                rows += '<td>'+(record.tecnico)+'</td>'; 
                rows += '<td>'+(record.assignedHours)+'</td>'; 
                rows += '<td>'+(record.workedHours)+'</td>'; 
                rows += '<td>'+(record.tiemposImproductivos)+'</td>'; 
                rows += '<td>'+(record.eficiencia)+'</td>'; 
                rows += '<td>'+(record.productividad)+'</td>'; 
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

        downloadElement.download = 'Reporte Tiempos Improductivos.xls';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }

}