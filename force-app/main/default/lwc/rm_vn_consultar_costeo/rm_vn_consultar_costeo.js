import { LightningElement,api, wire } from 'lwc';
import columns from './columns';
import columnsError from './columnsError';
import { reduceErrors } from 'c/ldsUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getData from '@salesforce/apex/RM_VN_ConsultarCosteo_Ctrl.getData';
import rm_vn_consultar_detalle_costo_modalbox from 'c/rm_vn_consultar_detalle_costo_modalbox';

import getDataError from '@salesforce/apex/RM_VN_ConsultarCosteo_Ctrl.getDataError';

export default class Rm_vn_consultar_costeo extends LightningElement {
    columns = columns;
    columnsError = columnsError;
    selectedRows = [];
    //declare all filter variables
    isLoading = false;
    isLoadingRecordType = false;
    nodata= true;
    @api brand = '';
    @api model = '';
    @api year = '';
    @api productCode = '';
    @api bodegaId = '';
    @api vin = '';
    @api internalColor = '';
    @api externalColor = '';
    @api vehiculoTransito = '';

    //pagination
    pageNumber = 1;
    totalPages = 0;
    //pagination error
    pageNumberError = 1;
    totalPagesError = 0;
    
    
    
    selectedTipoCombustible = '';

    //create a variable with the following values that will be show in a combobox
    //Estatus: Todos, Disponible, Reservado,En tránsito
    statusOptions = [
        { label: 'Disponible', value: 'Disponible' },
        { label: 'Reservado', value: 'Reservado' },
        { label: 'En tránsito', value: 'En transito' }
    ];

    selectedStatus = 'Disponible';
    //records
    records = [];
    wiredRecordsResult;
    //records Error
    recordsError = [];
    wiredRecordsResultError;

    sfdcBaseURL;
    connectedCallback() {
        this.sfdcBaseURL = window.location.origin; 
        this.isLoading = true;   
        // this.year = new Date().getFullYear();
    } 

    @wire(getDataError,{ pageNumber : "$pageNumberError"})    
    wiredRecordsError(result) {
       
        this.recordsError = [];   
        this.totalRecordsError = 0;
        this.totalPagesError = 0;  
        this.wiredRecordsResultError = result;
        if (result.data && result.data.records) {
            Object.values(result.data.records).forEach((item, index) => {
                if (typeof item === "object") {

                    console.log(item);
                    console.log(item.IsActive);
                    console.log(item.IsActive ? item.IsActive : false);
                    let bodegaName;
                    if(item.Productos_por_Bodega__r && item.Productos_por_Bodega__r[0].Bodega__c){
                        bodegaName = item.Productos_por_Bodega__r[0].Bodega__r.Name;
                    }

                    let actions = [];
                    actions: actions.push({ label: 'Consultar detalle costo', name: 'consultar-detalle-consteo' });
                    let record = {
                        Id :  item.Id,
                        productId :  item.Id,
                        productCode :  item.Codigo_de_Producto__c ? item.Codigo_de_Producto__c : '',
                        productName : item.Name ? item.Name : '',
                        productBrand : item.marcaVehiculo__c ? item.marcaVehiculo__c : '',
                        productModel : item.modelo__c ? item.modelo__c : '',
                        productVin : item.vin__c ? item.vin__c : '',
                        isActive : item.IsActive ? item.IsActive : false,
                        productYear : item.Anno__c ? item.Anno__c : '',
                        esVehiculo : item.esVehiculo__c ? item.esVehiculo__c : false,
                        productExternalColor : item.Color_Externo__c ? item.Color_Externo__c : '',
                        bodegaName : bodegaName,//item.Bodega__r && item.Bodega__r.Name ? item.Bodega__r.Name : '-',
                        productUrl: this.sfdcBaseURL + '/'+item.Id,
                        daysInInventory : item.RM_NoDiasInventario__c ? parseFloat(item.RM_NoDiasInventario__c).toFixed(2) : 0.0,
                        actions: actions
                        
                    };

                    let sumDolar = 0;
                    let sumLocal = 0;

                    if(item.Detalles_Costo_Productos__r){
  
                        Object.values(item.Detalles_Costo_Productos__r).forEach((itemCosto, index) => {

                            if(itemCosto.Monto_Dolar__c){
                                sumDolar += itemCosto.Monto_Dolar__c;
                            }

                            if(itemCosto.Monto_local__c){
                                sumLocal += itemCosto.Monto_local__c;
                            }
                        });

                    }

                    if(item.es_Vehiculo_en_transito__c == true){
                        record.productVin = item.Codigo_de_Producto__c;
                    }

                    var mensajeError = ' ';
                    if(record.productYear == ''){
                        mensajeError += ' El producto no cuenta con año asignado. '
                    }
                    if(record.isActive == false){
                        mensajeError += ' El producto no esta activo. '
                    }
                    if(record.esVehiculo == false){
                        mensajeError += ' El producto no tiene check de es vehiculo. '                        
                    }
                    if(record.productModel == '' || record.productModel == '-'){
                        mensajeError += ' El producto no tiene modelo. '                        
                    }
                    if(item.Producto_Reservado__c == true){
                        mensajeError += ' El producto esta reservado. '                        
                    }
                    if(record.productBrand == ''){
                        mensajeError += ' El producto no tiene marca. '
                    }
                    record.sumDolar = sumDolar;
                    record.sumLocal = sumLocal;
                    record.causaError = mensajeError;

                    this.recordsError[index] = record;
                    this.isLoading = false;
                }
            });           
            this.totalRecordsError = result.data.totalRecords ? result.data.totalRecords : 0;
            if(this.totalRecordsError > 0){
                this.totalPagesError = Math.ceil(this.totalRecordsError / result.data.pageSize);
                // console.log('this.totalPages',this.totalPages);
            }   
        }else if(result.error){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error !',
                    message: reduceErrors(result.error).join(', '),
                    variant: 'error'
                })
            );
        }
    }        

    @wire(getData,{ brand: "$brand" ,model: "$model" ,year: "$year" ,productCode: '$productCode', bodegaId: '$bodegaId', vin: "$vin" , internalColor: "$internalColor",  externalColor: "$externalColor" ,tipoCombustible:'$selectedTipoCombustible',status:'$selectedStatus', pageNumber : "$pageNumber" })    
    wiredRecords(result) {
        this.isLoading = true;
        this.isLoading = false;
        this.records = [];     
        this.totalRecords = 0;
        this.totalPages = 0;
        this.wiredRecordsResult = result;
        if (result.data && result.data.records) {
            Object.values(result.data.records).forEach((item, index) => {
                if (typeof item === "object") {
                    let bodegaName;
                    if(item.Productos_por_Bodega__r && item.Productos_por_Bodega__r[0].Bodega__c){
                        bodegaName = item.Productos_por_Bodega__r[0].Bodega__r.Name;
                    }

                    let actions = [];
                    actions: actions.push({ label: 'Consultar detalle costo', name: 'consultar-detalle-consteo' });
                    let record = {
                        Id :  item.Id,
                        productId :  item.Id,
                        productCode :  item.Codigo_de_Producto__c ? item.Codigo_de_Producto__c : '',
                        productName : item.Name ? item.Name : '',
                        productBrand : item.marcaVehiculo__c ? item.marcaVehiculo__c : '',
                        productModel : item.modelo__c ? item.modelo__c : '',
                        productVin : item.vin__c ? item.vin__c : '',
                        productTipoCombustible : item.combustible__c ? item.combustible__c : '',
                        productYear : item.Anno__c ? item.Anno__c : '',
                        productInternalColor : item.Color__c ? item.Color__c : '',
                        productExternalColor : item.Color_Externo__c ? item.Color_Externo__c : '',
                        bodegaName : bodegaName,//item.Bodega__r && item.Bodega__r.Name ? item.Bodega__r.Name : '-',
                        productUrl: this.sfdcBaseURL + '/'+item.Id,
                        daysInInventory : item.RM_NoDiasInventario__c ? parseFloat(item.RM_NoDiasInventario__c).toFixed(2) : 0.0,
                        actions: actions
                        
                    };

                    let sumDolar = 0;
                    let sumLocal = 0;

                    if(item.Detalles_Costo_Productos__r){
  
                        Object.values(item.Detalles_Costo_Productos__r).forEach((itemCosto, index) => {

                            if(itemCosto.Monto_Dolar__c){
                                sumDolar += itemCosto.Monto_Dolar__c;
                            }

                            if(itemCosto.Monto_local__c){
                                sumLocal += itemCosto.Monto_local__c;
                            }
                        });

                    }

                    if(item.es_Vehiculo_en_transito__c == true){
                        record.productVin = item.Codigo_de_Producto__c;
                    }
                    

                    record.sumDolar = sumDolar;
                    record.sumLocal = sumLocal;

                    this.records[index] = record;
                    this.isLoading = false;
                }
            });           
            this.totalRecords = result.data.totalRecords ? result.data.totalRecords : 0;
            if(this.totalRecords > 0){
                this.totalPages = Math.ceil(this.totalRecords / result.data.pageSize);
                // console.log('this.totalPages',this.totalPages);
            }       
        }else if(result.error){
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error !',
                    message: reduceErrors(result.error).join(', '),
                    variant: 'error'
                })
            );
        }

        if (result.data || result.error) {
            this.isLoading = false;
        }
        this.isLoading = false;
        console.log('this.isLoadingRecordType ',this.isLoadingRecordType );
        console.log('this.isLoading ' , this.isLoading);
        console.log('this.records',this.records);
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'consultar-detalle-consteo':
                this.handleConsultarDetalleCosto(row);
                break;
        }
    }

    handleConsultarDetalleCosto(row){
        rm_vn_consultar_detalle_costo_modalbox.open({
            size: 'medium',
            vehiculoId: row.productId
        });
    }

    handleSelectedTipoCombustibleEvent(event){
        console.log('1');
        this.isLoading = true;
        this.selectedTipoCombustible = event.detail;
        this.selectedRows = [];
        this.records = [];
        this.pageNumber = 1;
        console.log('1');
    }

    handleStatusChange(event){
        console.log('2');
        this.isLoading = true;
        this.selectedStatus = event.target.value;
        this.selectedRows = [];
        this.records = [];
        this.pageNumber = 1;
        console.log('2');
    }
    
    handleBrandChange(event){
        console.log('3');
        
        this.brand = event.detail.recordTypeId;
        this.selectedRows = [];
        this.records = [];
        this.pageNumber = 1;
        this.isLoadingRecordType = false;
        console.log('3');
    }

    handleModelChange(event){
        console.log('4');
        this.isLoading = true;
        this.model = event.target.value;
        this.selectedRows = [];
        this.records = [];
        this.pageNumber = 1;
        console.log('4');
    }

    handleColorInternoChange(event){
        console.log('5');
        this.isLoading = true;
        this.internalColor = event.target.value;
        this.selectedRows = [];
        this.records = [];
        this.pageNumber = 1;
        console.log('5');
    } 

    handleColorExternoChange(event){
        console.log('6');
        this.isLoading = true;
        this.externalColor = event.target.value;
        this.selectedRows = [];
        this.records = [];
        this.pageNumber = 1;
        console.log('6');
    }

    handleVinChange(event){
        console.log('7');
        this.isLoading = true;
        this.vin = event.target.value;
        this.selectedRows = [];
        this.records = [];
        this.pageNumber = 1;
        console.log('7');
    }

    handleYearChange(event){  
        console.log('8');
        this.isLoading = true;
        this.year = event.target.value;
        this.selectedRows = [];
        this.records = [];
        this.pageNumber = 1;
        console.log('8');
    }

    handleBackClick(){
        this.isLoading = true;
        this.selectedRows = [];
        this.records = [];
        this.pageNumber--;
    }

    handleNextClick(){
        this.isLoading = true;
        this.selectedRows = [];
        this.records = [];
        this.pageNumber++;
    }

    handleBackClickError(){
        this.isLoading = true;
        this.selectedRows = [];
        this.recordsError = [];
        this.pageNumberError--;
    }

    handleNextClickError(){
        this.isLoading = true;
        this.selectedRows = [];
        this.recordsError = [];
        this.pageNumberError++;
    }

    get isEnablePrevButtonError(){
        return this.pageNumberError <= 1;
    }

    get isEnableNextButtonError(){
        return this.pageNumberError >= this.totalPagesError;
    }

    get isEnablePrevButton(){
        return this.pageNumber <= 1;
    }

    get isEnableNextButton(){
        return this.pageNumber >= this.totalPages;
    }

    handleIsLoadingRecordType(event){
        //this.isLoadingRecordType = event.detail.isloading;
    }

    get showSpinner(){ 
        return this.isLoading || this.isLoadingRecordType;
    }

    handleExportSelect(event){
        const selectedItemValue = event.detail.value;
        if(selectedItemValue === 'comma'){
            this.handleExportToCSV(',');
        }else if(selectedItemValue === 'semicolon'){
            this.handleExportToCSV(';');
        }
    }

    csvContent = '';

    handleExportToCSV(separator) {
        this.csvContent = "data:text/csv;charset=utf-8,";
        this.csvContent += "Nombre" + separator + "Marca" + separator + "Modelo" + separator + "Año" + separator  + "Vin" + separator  + "Color" + separator + "Color Externo" + separator + "Combustible" + separator + "Bodega" + separator + "Días en inventario" + separator + "Monto(CRC)" + separator + "Monto(USD)\r\n";
        this.exportar(separator);
    }

    async exportar(separator){
        this.isLoading = true;
        
        getData({ brand: this.brand ,model: this.model ,year: this.year ,productCode: this.productCode, bodegaId: this.bodegaId, vin: this.vin , internalColor: this.internalColor,  externalColor: this.externalColor ,tipoCombustible:this.selectedTipoCombustible,status:this.selectedStatus, pageNumber : this.pageNumber,skipPagination: true})
        .then(data => {
            if(data.records){
                Object.values(data.records).forEach((item, index) => {
                    if (typeof item === "object") { 

                        let record = this.getRow(item);
                        this.csvContent += '"' + record.productName + '"' + separator + '"' + record.productBrand + '"' + separator + '"' + record.productModel + '"' + separator + '"' + record.productYear + '"' + separator + '"' + record.productVin + '"' + separator + '"' + record.productInternalColor + '"' + separator + '"' + record.productExternalColor + '"' + separator + '"' + record.productTipoCombustible + '"' + separator + '"' + record.bodegaName + '"' + separator + '"' + record.daysInInventory + '"' + separator + '"' + record.sumLocal.toFixed(2) + '"' + separator + '"' + record.sumDolar.toFixed(2) + '"' + "\r\n";                    }
                });
    
                const encodedUri = encodeURI(this.csvContent);
                const link = document.createElement("a");
                link.setAttribute("href", encodedUri);
                link.setAttribute("download", "Consultar Costeo.csv");
                document.body.appendChild(link);
    
                link.click();
            }
            this.isLoading = false;
        })
        .catch(error => {
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error !',
                    message: reduceErrors(error).join(', '),
                    variant: 'error'
                })
            );
        });
    }

    getRow(item){
        let bodegaName = '';
        if(item.Productos_por_Bodega__r && item.Productos_por_Bodega__r[0].Bodega__c){
            bodegaName = item.Productos_por_Bodega__r[0].Bodega__r.Name;
        }

        let sumDolar = 0;
        let sumLocal = 0;

        if(item.Detalles_Costo_Productos__r){

            Object.values(item.Detalles_Costo_Productos__r).forEach((itemCosto, index) => {

                if(itemCosto.Monto_Dolar__c){
                    sumDolar += itemCosto.Monto_Dolar__c;
                }

                if(itemCosto.Monto_local__c){
                    sumLocal += itemCosto.Monto_local__c;
                }
            });

        }

        
        let data = {
            Id :  item.Id,
            productId :  item.Id,
            productCode :  item.Codigo_de_Producto__c ? item.Codigo_de_Producto__c : '',
            productName : item.Name ? item.Name : '',
            productBrand : item.marcaVehiculo__c ? item.marcaVehiculo__c : '',
            productModel : item.modelo__c ? item.modelo__c : '',
            productVin : item.vin__c ? item.vin__c : '',
            productTipoCombustible : item.combustible__c ? item.combustible__c : '',
            productYear : item.Anno__c ? item.Anno__c : '',
            productInternalColor : item.Color__c ? item.Color__c : '',
            productExternalColor : item.Color_Externo__c ? item.Color_Externo__c : '',
            bodegaName : bodegaName,
            productUrl: this.sfdcBaseURL + '/'+item.Id,
            daysInInventory : item.RM_NoDiasInventario__c ? parseFloat(item.RM_NoDiasInventario__c).toFixed(2) : 0.0,
            sumDolar : sumDolar,
            sumLocal : sumLocal
        };
        return data;
    }

    mostrarErrores(event) {
        this.nodata = false;
    }

    mostrarNormal(event) {
        this.nodata = true;
    }

}