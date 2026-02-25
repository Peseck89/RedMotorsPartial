import { LightningElement,wire,track } from 'lwc';
import getTerritories from '@salesforce/apex/WorkStepController.getTerritories';
import getConfig from '@salesforce/apex/CT_Reporte_Horas_Fact_Controller.getConfig';
import getData from '@salesforce/apex/RM_CT_ReporteHorasFacturadas_Ctrl.getData';
import searchUsersFilterByMecanico from '@salesforce/apex/SampleLookupController.searchUsersFilterByMecanico';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import rm_ct_reporte_detalle_tareas from 'c/rm_ct_reporte_detalle_tareas';

export default class CT_reporteHorasFac extends LightningElement {

    // @wire(getTerriories)
    // stores;
    
    territories;
    selectedTerritories;

    //filters
    inputTerritoryId = 'all';
    inputMechanicId = '';
    inputStartDate = '';
    inputEndDate = '';
    caseNumber = '';

    wiredWorkStepResult;

    @track mechanics = [];
    // workSteps = [];  
    @track records = [];  
      
    showParentTasks= false;    

    mechanicInicialSelection = [];
    errors = [];

    isLoading = false;

    showFilters = true;

    mechanicsItems = [];

    showResume;

    horas_x_dia = 0;
    dias_x_mes = 0;
    existeConfig = false;

    connectedCallback(){
        this.showResume = false;
    }

    //call this apex action
    data = [];
    wiredDataResult;
    @wire(getData,{mechanicId: "$inputMechanicId", startDate: "$inputStartDate", endDate: "$inputEndDate",showResume: "$showResume",caseNumber: "$caseNumber"})
    wiredGetData(result){
        this.wiredDataResult = result;
        if(result.data){
            this.wiredDataResult = result.data;
            this.records = result.data.records;
        }
    }

    handleShowResumeClick(event)
    {
        this.showResume = !this.showResume;
    }

    @wire(getConfig)
    wiredConfig({ data, error }) {
        if (data) {
            this.config = data ? JSON.parse(JSON.stringify(data)) : [];
        }else if (error){
            this.config = [];
        }
    }

    @wire(getTerritories)
    wiredTerritories({ data, error }) {
        if (data) {  
            this.territories = [];       
            this.allTerritories = [];       
            this.selectedTerritories = [];  

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

            this.territories = [];       
            this.allTerritories = [];       
            this.selectedTerritories = [];       

        }
    }    

    tiemposImproductivos = [];
    // @wire(getWorkSteps,{ territories: '$selectedTerritories',mechanicId: "$inputMechanicId",caseNumber: "$caseNumber",startDate: "$inputStartDate", endDate: "$inputEndDate", showParentTasks: "$showParentTasks" })  
    // wiredWorkSteps(result) {
    //     this.wiredWorkStepResult = result;
    //     this.records = [];   
    //     if (result.data) {                                                               
    //         this.records = result.data.records ? JSON.parse(JSON.stringify(result.data.records)) : []; 
    //         this.tiemposImproductivos = result.data.tiemposimproductivos ? JSON.parse(JSON.stringify(result.data.tiemposimproductivos)) : []; 
    //         this.records.forEach((record,recordIndex)=>{      
    //             let casesArray = [];
    //             let first = true;
    //             record.cases.forEach((_case,caseIndex)=>{
    //                 casesArray.push({
    //                     caseId:_case,
    //                     first:first,
    //                     minutosPausa:this.getMinutosPausa(_case,record.mechanicId)
    //                 });
    //                 first = false;
    //             });
    //             this.records[recordIndex].cases = casesArray;
    //         });
    //     }else if(result.error){
    //     }
    // }

    getMinutosPausa(casoId,mecanicoId) {
        let tti = 0;
        // if(this.tiemposImproductivos && this.tiemposImproductivos.length > 0){
        //     this.tiemposImproductivos.forEach((record,recordIndex)=>{
        //         if (record.caseId == casoId && record.mecanicoId == mecanicoId) {
        //             tti = record.total;
        //         }
        //     });       
        // }
        return tti;
    }

    handleTerritoryChange(event) {        
        this.inputTerritoryId = event.target.value;              
    }
    
    handleCaseNumberChange(event) {        
        this.caseNumber = event.target.value;              
    }

    handleStarDateChange(event) {
        this.inputStartDate = undefined;
        if(this.inputEndDate != null){
            const diffInTime = new Date(this.inputEndDate).getTime() - new Date(event.target.value).getTime();        
            const numDays = diffInTime > 0 ? diffInTime / (1000 * 3600 * 24) : 0;
            if(numDays > 94){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Atención',
                        message: 'El rango de consulta no debe ser mayor a 90 dias.',
                        variant: 'error'
                    })
                    ); 
                    event.target.value = '';
            }else{
                this.inputStartDate = event.target.value;
            }
        }else{
            this.inputStartDate = event.target.value;
        }              
    }

    handleEndDateChange(event) {
        this.inputEndDate = undefined;
        if(this.inputStartDate != null){
            const diffInTime = new Date(this.inputEndDate).getTime() - new Date(event.target.value).getTime();        
            const numDays = diffInTime > 0 ? diffInTime / (1000 * 3600 * 24) : 0;
            if(numDays > 94){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Atención',
                        message: 'El rango de consulta no debe ser mayor a 90 dias.',
                        variant: 'error'
                    })
                    ); 
                    event.target.value = '';
            }else{
                this.inputEndDate = event.target.value;
            }
        }else{
            this.inputEndDate = event.target.value;
        }  
    }   

    handleMechanicSearch(event){
        const lookupElement = event.target;
        var params = event.detail;
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
        let userId = null;
        [ userId ] = event.detail;
        this.inputMechanicId = userId != null ? userId : null; 
        // this.refresh();       
    }

    customTimeOut;
    refresh(){
        this.isLoading = true;        
        this.customTimeOut = setTimeout(()=>{
            // refreshApex(this.wiredWorkStepResult);
            this.isLoading = false;
        },1000);
        this.showFilters = false;
    }

    handleExportClick(){
        let doc = '';

        // doc += '<table style="border-collapse: collapse; width: 100%; height: 54px;" border="1">'+
        //             '<thead>'+
        //                 '<tr style="height: 18px;">'+
        //                     '<th style="width: 14.28%; height: 18px; text-align: center; background-color: #f0f0f0;"><strong>Tecnico</strong></th>'+
        //                     '<th style="width: 14.28%; height: 18px; text-align: center; background-color: #f0f0f0;"><strong>Taller</strong></th>'+
        //                     '<th style="width: 14.28%; height: 18px; text-align: center; background-color: #f0f0f0;"><strong># Caso</strong></th>'+
        //                     '<th style="width: 14.28%; height: 18px; text-align: center; background-color: #f0f0f0;"><strong>H. Asignadas</strong></th>'+
        //                     '<th style="width: 14.28%; height: 18px; text-align: center; background-color: #f0f0f0;" width="83"><strong>H. Tardadas</strong></th>'+
        //                     '<th style="width: 14.28%; height: 18px; text-align: center; background-color: #f0f0f0;"><strong>H. Facturadas</strong></th>'+
        //                     '<th style="width: 14.28%; height: 18px; text-align: center; background-color: #f0f0f0;"><strong>Tiempos Improductivos</strong></th>'+
        //                 '</tr>'+
        //             '</thead>'+
        //             '<tbody>';

        // this.records.forEach((item,key) => {
        //     let totalHorasAsignadas = 0;
        //     let totalHorasTrabajadas = 0;
        //     let totalHorasFacturadas = 0;
        //     let totalTiemposImproductivos = 0;
        //     let productividad = 0;
        //     let eficiencia = 0;            
                        
        //     for(let i = 0; i < item.cases.length;i++){
        //         let tmpCase = item.cases[i];   

        //         let caseNumber;
        //         let horasAsignadas = 0;
        //         let horasTrabajadas = 0;
        //         let horasFacturadas = 0;

        //         for(let j = 0; j < item.workSteps.length;j++){
        //             let tmpWorkStep = item.workSteps[j];
        
        //             if (tmpWorkStep.Mec_nico_asignado__c == item.mechanicId && tmpWorkStep.Caso__r.Service_Territory1__c == item.territoryId && tmpWorkStep.Caso__c == tmpCase.caseId) {
        //                 caseNumber = tmpWorkStep.Caso__r.CaseNumber;

        //                 let _hoursAssigned = tmpWorkStep.RM_TotalHorasFX__c ? parseFloat(tmpWorkStep.RM_TotalHorasFX__c) : 0;
        //                 let _hoursWorked = tmpWorkStep.Total_de_tiempo_trabajado_en_minutos__c && parseFloat(tmpWorkStep.Total_de_tiempo_trabajado_en_minutos__c) > 0 ? parseFloat(tmpWorkStep.Total_de_tiempo_trabajado_en_minutos__c) : 0;
        
        //                 _hoursWorked = _hoursWorked > 0 ? (_hoursWorked / 60) : 0;
        
        //                 horasAsignadas += parseFloat(_hoursAssigned);
        //                 horasTrabajadas += parseFloat(_hoursWorked);
        //                 horasFacturadas += parseFloat(_hoursAssigned);

        //             }
        //         }

        //         if (this.showResume) {
        //             doc += '<tr>';
        //             if (tmpCase.first) {
        //                 doc += '<td rowspan='+item.numWS+'>'+item.mechanicName+'</td>';                         
        //             } 
        //             doc += '<td>'+item.territoryName+'</td>'; 
        //             doc += '<td>'+caseNumber+'</td>'; 
        //             doc += '<td>'+horasAsignadas.toFixed(2)+'</td>'; 
        //             doc += '<td>'+horasTrabajadas.toFixed(2)+'</td>';
        //             doc += '<td>'+horasFacturadas.toFixed(2)+'</td>'; 
        //             doc += '<td>'+tmpCase.minutosPausa.toFixed(2)+'</td>'; 
        //             doc += '</tr>';  
       
        //         }

        //         totalHorasAsignadas += horasAsignadas;
        //         totalHorasTrabajadas += horasTrabajadas;
        //         totalHorasFacturadas += horasFacturadas;
        //         totalTiemposImproductivos += parseFloat(tmpCase.minutosPausa);
        //     }

        //     doc += '<tr>';
        //     if (!this.showResume) {
        //         doc += '<td>'+item.mechanicName+'</td>'; 
        //     }else{
        //         doc += '<td>Total</td>'; 
        //     }

        //     doc += '<td>'+item.territoryName+'</td>'; 
        //     doc += '<td>&#32;</td>'; 
        //     doc += '<td>'+totalHorasAsignadas.toFixed(2)+'</td>'; 
        //     doc += '<td>'+totalHorasTrabajadas.toFixed(2)+'</td>';
        //     doc += '<td>'+totalHorasFacturadas.toFixed(2)+'</td>'; 
        //     doc += '<td>'+totalTiemposImproductivos.toFixed(2)+'</td>'; 
        //     doc += '</tr>'; 
            
        //     this.validarDisponibilidad(item);
        //     productividad = totalHorasAsignadas && this.horas_x_dia && this.dias_x_mes ? (totalHorasAsignadas / this.horas_x_dia) * this.dias_x_mes : 0;
        //     eficiencia = totalHorasTrabajadas > 0 ? (totalHorasTrabajadas / totalHorasFacturadas) : 0;            

        //     doc += '<tr>';
        //     doc += '<td>Productividad</td>'; 
        //     if(this.existeConfig){
        //         doc += '<td>'+productividad.toFixed(2)+'</td>'; 
        //     }else{
        //         doc += '<td>Sin registro de config disponibilidad</td>';
        //     }
        //     doc += '<td>&#32;</td>'; 
        //     doc += '<td>&#32;</td>'; 
        //     doc += '<td>&#32;</td>'; 
        //     doc += '<td>&#32;</td>'; 
        //     doc += '</tr>';  

        //     doc += '<tr>';
        //     doc += '<td>Eficiencia</td>'; 
        //     if(this.existeConfig){
        //         doc += '<td>'+eficiencia.toFixed(2)+'</td>'; 
        //     }else{
        //         doc += '<td>Sin registro de config disponibilidad</td>';
        //     }            
        //     doc += '<td>&#32;</td>'; 
        //     doc += '<td>&#32;</td>'; 
        //     doc += '<td>&#32;</td>'; 
        //     doc += '<td>&#32;</td>'; 
        //     doc += '</tr>';                               

        // });
        // doc += '</tbody>';
        // doc += '</table>';
        // let element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
        // let downloadElement = document.createElement('a');
        // downloadElement.href = element;
        // downloadElement.target = '_self';

        // downloadElement.download = 'Reporte Horas Facturadas.xls';
        // document.body.appendChild(downloadElement);
        // downloadElement.click();

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
        // const diffInTime = new Date(this.inputEndDate).getTime() - new Date(this.inputStartDate).getTime();        
        // const numDays = diffInTime > 0 ? diffInTime / (1000 * 3600 * 24) : 0;

        // if (numDays <= 60) {
            this.showFilters = false;
            this.refresh();            
        // }else{
        //     this.dispatchEvent(
        //         new ShowToastEvent({
        //             title: 'Atención',
        //             message: 'El rango de dias maximo permitido es de 60 dias, favor de reducir el rango fecha inicio o fecha fin.',
        //             variant: 'error'
        //         })
        //     ); 
        // }
    }

    handleResetClick(event){
        this.inputTallerId = 'all';
        this.inputMechanicId = '';
        this.inputStartDate = '';
        this.inputEndDate = '';
        this.mechanicInicialSelection = [];
        this.records = [];
    }

    get recordsFound(){
        return this.records && this.records.length > 0;
    }

    get isApplybuttonEnabled(){
        return this.inputStartDate == '' || this.inputStartDate == null || this.inputEndDate == null || this.inputEndDate == '';
    }

    validarDisponibilidad(record) {
        this.existeConfig = false;
        this.horas_x_dia = undefined;
        this.dias_x_mes = undefined;
        this.config.forEach((config, index) => {
            if (config.Mecanico__c == record.mechanicId && config.Taller__c == record.territoryId && config.Horas_x_dia__c && parseFloat(config.Horas_x_dia__c) > 0 && config.Dias_x_mes__c && parseFloat(config.Dias_x_mes__c) > 0) {
                this.horas_x_dia = parseFloat(config.Horas_x_dia__c).toFixed(2);
                this.dias_x_mes = parseFloat(config.Dias_x_mes__c).toFixed(2);
                this.existeConfig = true;
            }
        });
    }

    get showMessageInfo(){
        return this.showParentTasks ? 'Se estan mostrando tareas padres': 'Se estan mostrando tareas hijas'
    }
        

    handleShowParentTasksChange(event){
        this.showParentTasks = event.target.checked;
    } 
    
    handleViewDetailClick(event){
        let mechanicId = event.target.dataset.machanic;
        let territoryId = event.target.dataset.territoryId;
        let caseId = event.target.dataset.caseId;

        console.log('mechanicId: ' + mechanicId);
        console.log('mechanicId: ' + mechanicId);
        console.log('territoryId: ' + territoryId);
        console.log('caseId: ' + caseId);

        rm_ct_reporte_detalle_tareas.open({
            size: 'small',
            description: 'Detalle de tareas',
            mechanicId: mechanicId,
            territoryId: territoryId,
            caseId: caseId
        })
        .then((result) => {

        });        
    }
}