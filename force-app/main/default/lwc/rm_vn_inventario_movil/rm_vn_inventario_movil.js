import { LightningElement,api,track,wire } from 'lwc';
import columns from './columns';
import columns_transito from './columns_transito';
import { reduceErrors } from 'c/ldsUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecords from '@salesforce/apex/RM_VN_Inventario_Ctrl.getRecords';
import getTipoGasolina from '@salesforce/apex/RM_VN_Inventario_Ctrl.getTipoGasolina';
import getLocations from '@salesforce/apex/RM_VN_Inventario_Ctrl.getLocations';
import searchModels from '@salesforce/apex/RM_VN_Inventario_Ctrl.searchModels';
import searchFamilias from '@salesforce/apex/RM_VN_Inventario_Ctrl.searchFamilias';
import searchNumeroPedidos from '@salesforce/apex/RM_VN_Inventario_Ctrl.searchNumeroPedidos';
import searchColors from '@salesforce/apex/RM_VN_Inventario_Ctrl.searchColors'; 
import searchTapicerias from '@salesforce/apex/RM_VN_Inventario_Ctrl.searchTapicerias';
import {getBackgroudColor } from './rm_vn_helper.js';
import rm_vn_cambiar_ubicacion_modalbox from 'c/rm_vn_cambiar_ubicacion_modalbox';
import rm_vn_inventario_agregar_comentario from 'c/rm_vn_inventario_agregar_comentario';
import { refreshApex } from '@salesforce/apex';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';

const FIELDS = [
    'User.RM_PuedeModificarBodega__c'
];
const DELAY = 300;

export default class Rm_vn_inventario_movil extends LightningElement {

    @api hideExtraButtons = false;

    userId = USER_ID;
    puedeModificarBodega;

    columns = columns;

    @api brand = '';
    @api year = '';
    @api selectedYear = '';
    @api model = '';
    @api family = '';

    @api maxRowSelection = -1;

    pageNumber = 1;
    totalRecords = 0;
    totalPages = 0;
    productCode = '';
    vin = '';    
    locationId = '';

    bodegaErrors = [];
    bodegaInitialSelection = [];

    @track isLoading = false;

    @api selectedRecordIds = [];
    @api selectedRecords = [];

    @api records = [];

    @api brandInputDisabled = false;

    @api yearInputDisabled = false;

    @api modelInputDisabled = false;
    @api familyInputDisabled = false;

    @api isDisabledBrandInput = false;

    @api isDisabledYearInput = false;

    //Create a property to save the selected value from the vehiculoTransito combobox
    @track vehiculoTransito = 'All';
    @track showFilters = false;
    @track externalColor = ''; // Valor seleccionado en el picklist
    @track internalColor = ''; // Valor seleccionado en el picklist

    @track colorExternoOptions = []; // Opciones para el picklist 
    @track internalColorOptions = [];
    @track externalColorOptions = [];

    //create a property  vehiculoTransitoOptions that will provide values for a combobox, Todos,Si,No
    // @track vehiculoTransitoOptions = [
    //     { label: 'Todos', value: 'All' },
    //     { label: 'Si', value: 'Si' },
    //     { label: 'No', value: 'No' },
    // ];

    numeroPedido = '';
    reportado = 'No';
    reportadoOptions = [
        { label: 'Todos', value: '' },
        { label: 'Si', value: 'Si' },
        { label: 'No', value: 'No' },
    ];
    
    sfdcBaseURL;
    
    renderedCallback() {
        super.renderedCallback();
    
        const scrollableContainer = this.template.querySelector(".slds-scrollable_y");
        scrollableContainer.addEventListener("scroll", (e) => {
          console.log(e.target.scrollTop);
          console.log(e.target.scrollHeight);
        });
      }
    connectedCallback() {
        this.sfdcBaseURL = window.location.origin;
        
        // pobla yearOptions con los ultimos 5 años y ordenalos de forma descendente
        let currentYear = new Date().getFullYear();
        this.selectedYear = currentYear.toString();
        for(let i = 0; i < 6; i++){
            //set the values as strings
            let newYead = ''+(currentYear +1) - i;
            this.yearOptions.push({label: ''+newYead.toString(), value: ''+newYead.toString()});
        }
        console.log('===========years===========');
        console.log(this.yearOptions);

        if(this.model){
            this.modeloInitialSelection = [
                {
                    id: this.model,
                    sObjectType: 'Modelo',
                    icon: 'standard:selling_model',
                    title: this.model,
                    subtitle: 'Modelo'
                }
            ];
        }
        if(this.family){
            this.familiaInitialSelection = [
                {
                    id: this.family,
                    sObjectType: 'Familia',
                    icon: 'standard:selling_family',
                    title: this.family,
                    subtitle: 'Familia'
                }
            ];
        }
        this.fetchColorExternoOptions();
        this.updateInternalColors();
        //this.addScrollFix();
    } 
    
    addScrollFix() {
        const scroller = this.template.querySelector('.scroller-content');
        
        if (scroller) {
            scroller.scrollTop = 0; // Ajusta el scroll al principio
            console.log("Se ajustó el scroll al principio.");
        } else {
            console.log("No se encontró el contenedor de scroll");
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    toggleFilters() {
        this.showFilters = !this.showFilters;
    }
    renderedCallback() {
        console.log('===========================');
        console.log('this.model', this.model);
        console.log('this.family', this.family);
        
    }

    wiredRecordsResult;

    tipoCombustibleOptions = [];

    tipoCombustible = 'all'; 

    isLoadingTipoGasolina = false;  
    @wire(getTipoGasolina)
    wiredTipoCombustible({ data, error }) {
        this.isLoadingTipoGasolina = true;
        if (data) {
            this.tipoCombustibleOptions = data.map(item => ({'label':item.label,'value':item.value}));
        }
        this.isLoadingTipoGasolina = false;
    }    
    
    yearOptions = []; 

    isLoadingLocations = false;
    locations = [];
    @wire(getLocations,{marca: '$brand'})
    wiredLocations({ data, error }) {
        this.isLoadingLocations = true;
        if (data) {
            this.locations = data.map(item => ({'label':item.label,'value':item.value}));
            //preseleccionar la primera ubicacion
            if(this.locations.length > 0){
                this.locationId = this.locations[0].value;
            }
        }
        this.isLoadingLocations = false;
    } 

    modeloInitialSelection = [];
    modelErrors = [];
    handleModelSearch(event) {
        const lookupElement = event.target;
        let params = event.detail;
        console.log('this.brand ',this.brand);
        params["firedElement"] = 'Product2';
        params["icon"] = 'standard:selling_model';
        params["objName"] = 'Product2';
        params["displayedObjName"] = 'Modelo';
        params["brand"] = this.brand;
        params["selectedFamily"] = this.family;
        params["selectedBrand"] = this.brand;

        searchModels(params)
        .then(results => {
            lookupElement.setSearchResults(results);
        })
        .catch(error => {
            this.modelErrors = error;
        });
        
    }
    handleModelSelectionChange(event) {
        this.model = '';
        if(event.detail && event.detail.length > 0) {
            this.model = event.detail[0];
        }
        this.fetchColorExternoOptions();
        this.updateInternalColors();
    }
    familiaInitialSelection = [];
    familyErrors = [];
    handleFamilySearch(event) {
        const lookupElement = event.target;
        let params = event.detail;
        console.log('this.brand ',this.brand);
        params["firedElement"] = 'Product2';
        params["icon"] = 'standard:selling_family';
        params["objName"] = 'Product2';
        params["displayedObjName"] = 'Familia';
        params["brand"] = this.brand;
        params["selectedBrand"] = this.brand;
        searchFamilias(params)
        .then(results => {
            lookupElement.setSearchResults(results);
        })
        .catch(error => {
            this.familyErrors = error;
        });
    }
    handleFamilySelectionChange(event) {
        this.family = '';
        if(event.detail && event.detail.length > 0) {
            this.family = event.detail[0];
        }
    }
    numeroPedidoInitialSelection = [];
    numeroPedidoErrors = [];
    handleNumeroPedidosSearch(event) {
        const lookupElement = event.target;
        let params = event.detail;
        params["firedElement"] = 'Product2';
        params["icon"] = 'utility:number_input';
        params["objName"] = 'Product2';
        params["displayedObjName"] = 'Product2';

        searchNumeroPedidos(params)
        .then(results => {
            lookupElement.setSearchResults(results);
        })
        .catch(error => {
            this.numeroPedidoErrors = error;
        });
    }

    handleNumeroPedidoSelectionChange(event) {
        this.numeroPedido = '';
        if(event.detail && event.detail.length > 0) {
            this.numeroPedido = event.detail[0];
        }
    }
    handleColorExternoChange(event) {
        this.externalColor = event.detail.value;
        this.updateInternalColors();
    }
    updateInternalColors() {
        searchTapicerias({
            selectedBrand: this.brand,
            selectedModel: this.model,
            selectedYear: this.selectedYear
        })
            .then(result => {
                // Agregar la opción "Todos" al inicio de la lista
                this.internalColorOptions = [
                    { label: 'Todos', value: '' },
                    ...result.map(color => ({ label: color, value: color }))
                ];
                this.internalColor = '';
            })
            .catch(error => {
                console.error('Error fetching internal colors:', error);
            });
    }
    
    fetchColorExternoOptions() {
        searchColors({ selectedBrand: this.brand,selectedYear: this.selectedYear, selectedModel: this.model })
            .then(result => {
                // Agregar la opción "Todos" al inicio de la lista
                this.colorExternoOptions = [
                    { label: 'Todos', value: '' },
                    ...result.map(color => ({ label: color, value: color }))
                ];
                console.log('this.year color ',this.selectedYear);
                console.log('this.colorExternoOptions ',this.colorExternoOptions);
            })
            .catch(error => {
                console.error('Error fetching colors: ', error);
            });
    }    
    isLoadingInventario = false;
    @wire(getRecords,{ brand: "$brand" ,model: "$model" ,family: "$family" ,year: "$selectedYear" ,productCode: '$productCode', locationId: '$locationId', vin: "$vin" ,  internalColor: "$internalColor",  externalColor: "$externalColor" ,tipoCombustible:'$tipoCombustible',reportado:'$reportado',numeroPedido:'$numeroPedido',vehiculoTransito:'$vehiculoTransito', pageNumber : "$pageNumber",skipPagination: false})    
    wiredRecords(result) {
        this.wiredRecordsResult = result;
        this.isLoadingInventario = true;
        if (result.data) {
            let tmpRecords = [];
            Object.values(result.data.records).forEach((item, index) => {
                if (typeof item === "object") {                    
                    let pbeFantasia = result.data.preciosFantasia.find((element) => {
                        return element.Name === item.Producto__r.modelo__c || (element.Product2 && element.Product2.Modelo_De_Inter_s__c === item.Producto__r.modelo__c);                        
                    });

                    let pbeSoftland = result.data.preciosSoftland.find((element) => {
                        return element.Product2Id === item.Producto__c;                        
                    });                    

                    let record = {
                        Id :  item.Id,
                        productId :  item.Producto__r.Id ? item.Producto__r.Id : '',
                        productCode :  item.Producto__r.Codigo_de_Producto__c ? item.Producto__r.Codigo_de_Producto__c : '',
                        productName : item.Producto__r.Name ? item.Producto__r.Name : '',
                        productBrand : item.Producto__r.marcaVehiculo__c ? item.Producto__r.marcaVehiculo__c : '',
                        productModel : item.Producto__r.modelo__c ? item.Producto__r.modelo__c : '',
                        productVin : item.Producto__r.vin__c ? item.Producto__r.vin__c : '',
                        productTipoCombustible : item.Producto__r.combustible__c ? item.Producto__r.combustible__c : '',
                        productYear : item.Producto__r.Anno__c ? item.Producto__r.Anno__c : '',
                        productInternalColor : item.Producto__r.Color__c ? item.Producto__r.Color__c : '',
                        productExternalColor : item.Producto__r.Color_Externo__c ? item.Producto__r.Color_Externo__c : '',
                        productPriceFantasia : pbeFantasia && pbeFantasia.UnitPrice ? parseFloat(pbeFantasia.UnitPrice).toFixed(2) : 0,
                        fechaIngresoTransito : item.Producto__r.fecha_ingreso_inventario__c ? item.Producto__r.fecha_ingreso_inventario__c : '',
                        noDiasInventario : item.Producto__r.RM_NoDiasInventario__c ? item.Producto__r.RM_NoDiasInventario__c : '',
                        tapiceria : item.Producto__r.tapiceria__c ? item.Producto__r.tapiceria__c : '',
                        codigoEquipamiento : item.Producto__r.RM_CodigoEquipamiento__c ? item.Producto__r.RM_CodigoEquipamiento__c : '',
                        numeroPedido : item.Producto__r.Pedido_Original__c ? item.Producto__r.Pedido_Original__c : '',
                        reportado : item.Producto__r.RM_Reportado__c ? item.Producto__r.RM_Reportado__c : false,
                        comentario : item.Producto__r.RM_Comentario__c ? item.Producto__r.RM_Comentario__c : '',
                        bodegaName : item.Bodega__r && item.Bodega__r.Name ? item.Bodega__r.Name : '-',
                        productUrl: this.sfdcBaseURL + '/'+item.Producto__r.Id,
                        backgroudColor:  item.Producto__r && item.Producto__r.RM_Reportado__c ? getBackgroudColor(item.Producto__r.RM_Reportado__c) : '',
                        pbeFantasiaId: pbeFantasia ? pbeFantasia.Id : null,
                        pbeSoftlandId: pbeSoftland ? pbeSoftland.Id : null
                    };
                    if(item.Producto__r.es_Vehiculo_en_transito__c == true){
                        record.productVin = item.Producto__r.Codigo_de_Producto__c;
                    }
                    tmpRecords[index] = record;

                    pbeFantasia = undefined;
                    pbeSoftland = undefined;
                }
            });
            
            this.records = tmpRecords;            
            this.totalRecords = result.data.totalRecords ? result.data.totalRecords : 0;
            if(this.totalRecords > 0){
                this.totalPages = Math.ceil(result.data.totalRecords / result.data.pageSize);
            }       
            this.error = undefined;
        }else if(result.error){
            // this.data = undefined;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error !',
                    message: reduceErrors(result.error).join(', '),
                    variant: 'error'
                })
            );
        }
        this.isLoadingInventario = false;
        setTimeout(() => {
           // this.addScrollFix();
        }, 300); 
        console.log('searching method');
    }

    @wire(getRecord, { recordId: '$userId', fields: FIELDS })
    userRecord({ error, data }) {
        if (data) {
            this.puedeModificarBodega = data.fields.RM_PuedeModificarBodega__c.value;
            console.log('puedeModificarBodega', this.puedeModificarBodega);
        } else if (error) {
            console.error('Error loading user data:', error);
        }
    }

    handleRecordsSelection(event){
        // Get selected rows
        const selectedRows = event.detail.selectedRows;
        console.log('selectedRows', selectedRows);
        // Filter out rows that should be disabled
        const disabledRows = !this.puedeModificarBodega ? this.records.filter(row => row.reportado).map(row => row.Id) : [];
        // const disabledRows = this.records.filter(row => row.reportado).map(row => row.Id);

        // Remove disabled rows from selection
        this.selectedRecords  = selectedRows.filter(row => !disabledRows.includes(row.Id));
        console.log('selectedRecords', this.selectedRecords);
        
        // this.selectedRecords = event.detail.selectedRows;
        this.dispatchEvent(new CustomEvent('inventoryselecion', {
            detail:{
                selectedVehicles: [...this.selectedRecords],         
                brand: this.brand,         
                year: this.year         
                }
            }));        
    }

    handleLocationChange(event) {
        this.locationId = event.detail.value;
        this.resetValues();
    }

    handleBrandChange(event){
        this.brand = event.detail.recordTypeId;
        this.fetchColorExternoOptions();
        this.updateInternalColors();
        this.resetValues();
    }

    handleYearChange(event){  
        this.selectedYear = event.target.value;
        this.fetchColorExternoOptions();
        this.updateInternalColors();
        this.resetValues();
    }

    handleVinChange(event){
        this.vin = event.target.value;
        this.resetValues();
    }
    
    handleColorInternoChange(event){
        this.internalColor = event.target.value;
        this.resetValues();      
    } 

    handleColorExternoChange(event){
        this.externalColor = event.target.value;
        this.resetValues();
    }     
    
    handleModelChange(event){
        this.model = event.target.value;
        this.resetValues(); 
    }     
    handleFamilyChange(event){
        this.family = event.target.value;
        this.resetValues(); 
    }  
    handleCombustibleChange(event){    
        this.tipoCombustible = event.target.value;
        this.resetValues();  
    }

    handleReportadoChange(event){    
        this.reportado = event.target.value;
        this.resetValues();  
        console.log('reportado', this.reportado);
    }

    handleNumeroPedidoChange(event){    
        this.numeroPedido = event.target.value;
        this.resetValues();  
        console.log('numeroPedido', this.numeroPedido);
    }

    handleBackClick(){
        this.pageNumber--;
        // this.isLoading = true;
        this.selectedRecordIds = [];
        this.selectedRecords = [];
    }

    handleNextClick(){
        this.pageNumber++;
        // this.isLoading = true;
        this.selectedRecordIds = [];
        this.selectedRecords = [];
    }

    get isEnablePrevButton(){
        return !(this.totalPages > 0 && this.pageNumber > 1);
    }

    get isEnableNextButton(){
        return !(this.totalPages > 1 && this.pageNumber != this.totalPages);
    }

    resetValues(){
        // this.isLoading = true;
        this.selectedRecordIds = [];
        this.selectedRecords = [];
        this.pageNumber = 1;
        this.records = [];     
        this.totalRecords = 0;
        this.totalPages = 0;
    }

    set dynamicColumns(value){

    }

    get dynamicColumns() {
        // return this.vehiculoTransito == 'Si' ? columns_transito : columns;
        return columns;
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
        this.csvContent += "Reportado" + separator 
                        + "Comentario" + separator 
                        + "Pedido" + separator  
                        + "Fecha de Ingreso" + separator 
                        + "Días en inventario" + separator 
                        + "Nombre" + separator 
                        + "Modelo" + separator 
                        // + "Color"  + separator 
                        + "Color Externo" + separator 
                        + "Combustible" + separator 
                        + "Precio con Gastos Legales" + separator  
                        + "Tapiceria" + separator 
                        + "Equipamiento" + separator 
                        + "Vin" + separator 
                        + "Ubicación" + separator 
                        + "\r\n";
                        
        //consultar todas las paginas
        console.log(this.totalPages);
        let promises = [];

        promises.push(this.getData(separator));

        Promise.all(promises).then((pages) => {

        });
    }

    async getData(separator){
        this.isLoading = true;
        getRecords({ brand: this.brand, model: this.model, family: this.family ,year: this.selectedYear, productCode: this.productCode, locationId: this.locationId, vin: this.vin, internalColor: this.internalColor, externalColor: this.externalColor, tipoCombustible: this.tipoCombustible, reportado: this.reportado, numeroPedido: this.numeroPedido, vehiculoTransito: this.vehiculoTransito,pageNumber:1,skipPagination: true})
        .then(data => {
            Object.values(data.records).forEach((item, index) => {
                if (typeof item === "object") { 
                    let pbeFantasia = data.preciosFantasia.find((element) => {
                        return element.Name === item.Producto__r.modelo__c || (element.Product2 && element.Product2.Modelo_De_Inter_s__c === item.Producto__r.modelo__c);                        
                    });

                    let record = this.getRow(item,pbeFantasia);
                    this.csvContent += '"' + record.reportado + '"' + separator 
                    + '"' + record.comentario + '"' + separator 
                    + '"' + record.numeroPedido + '"' + separator 
                    + '"' + record.fechaIngresoTransito + '"' + separator 
                    + '"' + record.noDiasInventario + '"' + separator 
                    + '"' + record.productName + '"' + separator 
                    + '"' + record.productModel + '"' + separator 
                    // + '"' + record.productInternalColor + '"' + separator 
                    + '"' + record.productExternalColor + '"' + separator 
                    + '"' + record.productTipoCombustible + '"' + separator 
                    + '"' + (pbeFantasia?.UnitPrice || '') + '"' + separator 
                    + '"' + record.tapiceria + '"' + separator 
                    + '"' + record.codigoEquipamiento + '"' + separator 
                    + '"' + record.productVin + '"' + separator 
                    + '"' + record.bodegaName + '"' + separator 
                    + "\r\n";

                }
            });
            this.isLoading = false;

            const encodedUri = encodeURI(this.csvContent);
            const link = document.createElement("a");
            link.setAttribute("href", encodedUri);
            link.setAttribute("download", "Inventario Nuevos.csv");
            document.body.appendChild(link);

            link.click();
            
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

    getRow(item,pbeFantasia){
        let data = {
            Id :  item.Id,
            productId :  item.Producto__r.Id ? item.Producto__r.Id : '',
            productCode :  item.Producto__r.Codigo_de_Producto__c ? item.Producto__r.Codigo_de_Producto__c : '',
            productName : item.Producto__r.Name ? item.Producto__r.Name : '',
            productBrand : item.Producto__r.marcaVehiculo__c ? item.Producto__r.marcaVehiculo__c : '',
            productModel : item.Producto__r.modelo__c ? item.Producto__r.modelo__c : '',
            productVin : item.Producto__r.vin__c ? item.Producto__r.vin__c : '',
            productTipoCombustible : item.Producto__r.combustible__c ? item.Producto__r.combustible__c : '',
            productYear : item.Producto__r.Anno__c ? item.Producto__r.Anno__c : '',
            productInternalColor : item.Producto__r.Color__c ? item.Producto__r.Color__c : '',
            productExternalColor : item.Producto__r.Color_Externo__c ? item.Producto__r.Color_Externo__c : '',
            productPriceFantasia : pbeFantasia && pbeFantasia.UnitPrice ? parseFloat(pbeFantasia.UnitPrice).toFixed(2) : 0,
            fechaIngresoTransito : item.Producto__r.fecha_ingreso_inventario__c ? item.Producto__r.fecha_ingreso_inventario__c : '',
            noDiasInventario : item.Producto__r.RM_NoDiasInventario__c ? item.Producto__r.RM_NoDiasInventario__c : '',
            tapiceria : item.Producto__r.tapiceria__c ? item.Producto__r.tapiceria__c : '',
            codigoEquipamiento : item.Producto__r.RM_CodigoEquipamiento__c ? item.Producto__r.RM_CodigoEquipamiento__c : '',
            numeroPedido : item.Producto__r.Pedido_Original__c ? item.Producto__r.Pedido_Original__c : '',
            bodegaName : item.Bodega__r && item.Bodega__r.Name ? item.Bodega__r.Name : '-',
            reportado : item.Producto__r.RM_Reportado__c ? item.Producto__r.RM_Reportado__c : false,
            comentario : item.Producto__r.RM_Comentario__c ? item.Producto__r.RM_Comentario__c : '',
            productUrl: this.sfdcBaseURL + '/'+item.Producto__r.Id,
            pbeFantasiaId: pbeFantasia ? pbeFantasia.Id : null
        };
        if(item.Producto__r.es_Vehiculo_en_transito__c == true){
            data.productVin = item.Producto__r.Codigo_de_Producto__c;
        }
        return data;
    }

    handleAgregarComentarioClick(event) {
        if(!this.selectedRecords && this.selectedRecords.length == 0){
            return;
        }

        const row = this.selectedRecords.find(record => record.Id === event.target.dataset.id);
        rm_vn_inventario_agregar_comentario.open({
            size: 'small',
            recordId: this.selectedRecords[0].Id,
        })
        .then(response => {
            //reload de page
            window.location.reload();
            // refreshApex(this.wiredRecordsResult);
        })
    }

    handleChangeUbicacionClick(event) {
        if(!this.selectedRecords && this.selectedRecords.length == 0){
            return;
        }

        const row = this.selectedRecords.find(record => record.Id === event.target.dataset.id);
        rm_vn_cambiar_ubicacion_modalbox.open({
            size: 'small',
            recordId: this.selectedRecords[0].Id,
        })
        .then(response => {
            if(response && response.success){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Cambiar Ubicación',
                        message: 'Se cambió la ubicación correctamente.',
                        variant: 'success'
                    })
                );
            }
            //else{
            //     this.dispatchEvent(
            //         new ShowToastEvent({
            //             title: 'Cambiar Ubicación Error',
            //             message: response.message,
            //             variant: 'error'
            //         })
            //     );
            // }
            refreshApex(this.wiredRecordsResult);
            this.selectedRecordIds = [];
            this.selectedRecords = [];
        })
    }
    
    get isCambiarUbicacionDisabled(){
        return this.selectedRecords && this.selectedRecords.length == 0;
    }
}