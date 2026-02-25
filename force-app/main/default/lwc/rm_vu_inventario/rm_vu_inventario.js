import { LightningElement,api,track,wire } from 'lwc';
import columns from './columns';
import { reduceErrors } from 'c/ldsUtils';
import { refreshApex } from '@salesforce/apex';
import PRICEBOOK_ID_FIELD from "@salesforce/schema/Opportunity.Pricebook2Id";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecords from '@salesforce/apex/RM_VU_Inventario_Ctrl.getRecords';
import getTipoGasolina from '@salesforce/apex/RM_VU_Inventario_Ctrl.getTipoGasolina';
import getUsadoRecordTypeOptions from '@salesforce/apex/RM_VU_Inventario_Ctrl.getUsadoRecordTypeOptions';

const DELAY = 300;

export default class Rm_vu_inventario extends LightningElement {

    columns = columns;

    //opp Id
    @api recordId;

    @api brand = '';
    @api year = '';
    @api model = '';
    @api vin = '';    
    @api internalColor = '';
    @api externalColor = '';
    @api tipoCombustible = '';
    @api bodegaId = '';
    @api placa = ''; 

    @api maxRowSelection = 1;

    pageNumber = 1;
    totalRecords = 0;
    totalPages = 0;

    bodegaErrors = [];
    bodegaInitialSelection = [];

    @track _selectedRecordIds = [];
    _selectedRecords = [];

    sfdcBaseURL;
    connectedCallback() {
        this.sfdcBaseURL = window.location.origin;         
    } 

    wiredRecordsResult;

    tipoCombustibleOptions = [];

    records = [];

    isLoadingTipoCombustible = true;
    @wire(getTipoGasolina)
    wiredTipoCombustible(result) {
        if (result.data) {
            this.tipoCombustibleOptions = result.data.map(item => ({'label':item.label,'value':item.value}));
        }

        if (result.data || result.error) {
            this.isLoadingTipoCombustible = false
        }
    } 

    priceBooks = [
        {
            label: 'Bavarian Dólar',
            value: 'Bavarian Dólar'
        },
        {
            label: 'Otobai Dólares',
            value: 'Otobai Dólares'
        }
    ];

    priceBookId = 'Bavarian Dólar'; 
   
    isLoadingRecordTypesUsados = true;
    recordTypesOptions;
    @wire(getUsadoRecordTypeOptions)
    wiredRecordTypeOptions(result) {
        if (result.data) {
            this.recordTypesOptions = result.data.map(item => ({'label':item.label,'value':item.value}));
        }

        if (result.data || result.error) {
            this.isLoadingRecordTypesUsados = false
        }
    }  

    isLoadingInventario = true;
    tipoVehiculo = '';
    @wire(getRecords,{ tipoVehiculo: "$tipoVehiculo",brand: "$brand", model: "$model" ,year: "$year" , internalColor: "$internalColor",  externalColor: "$externalColor" , tipoCombustible:'$tipoCombustible', placa: "$placa", pageNumber : "$pageNumber" , priceBook: "$priceBookId"})    
    wiredRecords(result) { 
        this.records = [];       
        this.wiredRecordsResult = result;

        if (result.data && result.data.prodXBodItems) {
            let tmpRecords = [];
            Object.values(result.data.prodXBodItems).forEach((item, index) => {

                if (typeof item === "object") {                    

                   let pbe = result.data.priceBookEntries.find((element) => {
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
                        productPlaca : item.Producto__r.ProductCode ? item.Producto__r.ProductCode : '',
                        productTipoCombustible : item.Producto__r.combustible__c ? item.Producto__r.combustible__c : '',
                        productYear : item.Producto__r.Anno__c ? item.Producto__r.Anno__c : '',
                        productInternalColor : item.Producto__r.Color__c ? item.Producto__r.Color__c : '',
                        productExternalColor : item.Producto__r.Color_Externo__c ? item.Producto__r.Color_Externo__c : '',
                        unitPrice : pbe && pbe.UnitPrice ? parseFloat(pbe.UnitPrice).toFixed(2) : 0,
                        currencyCode : pbe && pbe.CurrencyCode ? parseFloat(pbe.CurrencyCode) : 0,
                        bodegaName : item.Bodega__r && item.Bodega__r.Name ? item.Bodega__r.Name : '-',
                        productUrl: this.sfdcBaseURL + '/'+item.Producto__r.Id,
                        pbeId: pbe ? pbe.Id : null
                    };
                    tmpRecords[index] = record;

                    //pbeFantasia = undefined;
                    pbe = undefined;
                }
            });
            
            this.records = tmpRecords;            
            this.totalRecords = result.data.totalRecords ? result.data.totalRecords : 0;
            if(this.totalRecords > 0){
                this.totalPages = Math.ceil(result.data.totalRecords / result.data.pageSize);
            }        
        }else if(result.error){
            this.records = [];
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error !',
                    message: reduceErrors(result.error).join(', '),
                    variant: 'error'
                })
            );
        }

        if (result.data || result.error) {
            this.isLoadingInventario = false;
        }
    }

    handleRecordsSelection(event){
        const selectedRows = event.detail.selectedRows;
        this._selectedRecords = selectedRows;
        this.dispatchEvent(new CustomEvent('inventoryselecion', {
            detail:{
                selectedRows: [... this._selectedRecords],    
                brand: this.brand,
                model: this.model,
                internalColor: this.internalColor,
                tipoCombustible: this.tipoCombustible,
                year: this.year,
                placa: this.placa,
                externalColor: this.externalColor                            
                }
            }));                
    }

    handleBrandChange(event){
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.brand = searchKey;
            this.isLoadingInventario = true;
        }, DELAY);
    }

    handleYearChange(event){  
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.year = searchKey;
            this.isLoadingInventario = true; 
        }, DELAY);
    }

    handleVinChange(event){
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.vin = searchKey;
            this.isLoadingInventario = true;
        }, DELAY);
    }
    
    handlePlacaChange(event){
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.placa = searchKey;
            this.isLoadingInventario = true;
        }, DELAY);
    }
    
    handleColorInternoChange(event){
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.internalColor = searchKey;
            this.isLoadingInventario = true;
        }, DELAY);        
    } 

    handleColorExternoChange(event){
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.externalColor = searchKey;
            this.isLoadingInventario = true;
        }, DELAY);
    }     
    
    handleModelChange(event){
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.model = searchKey;
            this.isLoadingInventario = true;
        }, DELAY);              
    }     
    
    handleTipoCombustibleChange(event){
        const searchKey = event.target.value;
        this.tipoCombustible = searchKey;
        this.isLoadingInventario = true;
    }   
    
    handlePriceBookChange(event){
        this.priceBookId = event.target.value;
        this.isLoadingInventario = true;
    }    

    handleTipoVehiculoChange(event){
        const searchKey = event.target.value;
        this.tipoVehiculo = searchKey;
        this.isLoadingInventario = true;
        console.log('tipoVehiculo: ' + this.tipoVehiculo);
    }   
    
    handleBackClick(){
        this.pageNumber--;
        this.isLoadingInventario = true;
    }

    handleNextClick(){
        this.pageNumber++;
        this.isLoadingInventario = true;
    }

    get isEnablePrevButton(){
        return !(this.totalPages > 0 && this.pageNumber > 1);
    }

    get isEnableNextButton(){
        return !(this.totalPages > 1 && this.pageNumber != this.totalPages);
    }
    
    @api
    get defaultSelectedItem(){
        return this._selectedRecords != undefined && this._selectedRecords.length > 0  ? this._selectedRecords[0] : undefined;
    }

    set defaultSelectedItem(value){
        // console.log('-----------defaultSelectedItem-----------');
        // if (value != undefined) {
        //     console.log(value); 
        //     this._selectedRecordIds.push(value);
        //     console.log(this._selectedRecordIds); 
        // }

        // if (value != undefined) {
        //     this.selectedRecordIds = [];
        //     refreshApex(this.wiredRecordsResult);
        //     const prodXBod = JSON.parse(JSON.stringify(value));
        //     // this._selectedRecords[0] = value;
        //     
        //     // this.records = prodXBod;
        // }   

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

        this.csvContent += "Nombre" + separator + "Modelo" + separator + "Año" + separator  + "Vin" + separator  + "Color Interno" + separator + "Color Externo" + separator + "Combustible" + separator + "Precio" + separator  + "Bodega\r\n";

        this.getData(separator);
    }

    isExportingCSV = false;
    async getData(separator){
        this.isExportingCSV = true;
        getRecords({ tipoVehiculo: this.tipoVehiculo,brand: this.brand, model: this.model ,year: this.year, internalColor: this.internalColor,externalColor: this.externalColor, tipoCombustible:this.tipoCombustible,placa: this.placa, skipPagination: true, priceBook: this.priceBookId})
        .then(data => {
            if(data.prodXBodItems){
                Object.values(data.prodXBodItems).forEach((item, index) => {
                    if (typeof item === "object") { 
    
                        let pbe = data.priceBookEntries.find((element) => {
                            return element.Product2Id === item.Producto__c;                        
                        });   
    
                        let record = this.getRow(item,pbe);
                        this.csvContent += '"' + record.productName + '"' + separator + '"' + record.productModel + '"' + separator + '"' + record.productYear + '"' + separator + '"' + record.productVin + '"' + separator + '"' + record.productInternalColor + '"' + separator + '"' + record.productExternalColor + '"' + separator + '"' + record.productTipoCombustible + '"' + separator + '"' + record.unitPrice + '"' + separator + '"' + record.bodegaName + '"' + "\r\n";
                    }
                });
    
                const encodedUri = encodeURI(this.csvContent);
                const link = document.createElement("a");
                link.setAttribute("href", encodedUri);
                link.setAttribute("download", "Inventario Usados.csv");
                document.body.appendChild(link);
    
                link.click();
            }
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error !',
                    message: reduceErrors(error).join(', '),
                    variant: 'error'
                })
            );
        }).finally(() => {
            this.isExportingCSV = false;
        });
    }

    getRow(item,pbe){
        let data = {
            Id :  item.Id,
            productId :  item.Producto__r.Id ? item.Producto__r.Id : '',
            productCode :  item.Producto__r.Codigo_de_Producto__c ? item.Producto__r.Codigo_de_Producto__c : '',
            productName : item.Producto__r.Name ? item.Producto__r.Name : '',
            productBrand : item.Producto__r.marcaVehiculo__c ? item.Producto__r.marcaVehiculo__c : '',
            productModel : item.Producto__r.modelo__c ? item.Producto__r.modelo__c : '',
            productVin : item.Producto__r.vin__c ? item.Producto__r.vin__c : '',
            productPlaca : item.Producto__r.ProductCode ? item.Producto__r.ProductCode : '',
            productTipoCombustible : item.Producto__r.combustible__c ? item.Producto__r.combustible__c : '',
            productYear : item.Producto__r.Anno__c ? item.Producto__r.Anno__c : '',
            productInternalColor : item.Producto__r.Color__c ? item.Producto__r.Color__c : '',
            productExternalColor : item.Producto__r.Color_Externo__c ? item.Producto__r.Color_Externo__c : '',
            unitPrice : pbe && pbe.UnitPrice ? parseFloat(pbe.UnitPrice).toFixed(2) : 0,
            currencyCode : pbe && pbe.CurrencyCode ? parseFloat(pbe.CurrencyCode) : 0,
            bodegaName : item.Bodega__r && item.Bodega__r.Name ? item.Bodega__r.Name : '-',
            productUrl: this.sfdcBaseURL + '/'+item.Producto__r.Id,
        };
        return data;
    }
    
    get isLoading(){
        return this.isLoadingInventario || this.isLoadingTipoCombustible || this.isLoadingRecordTypesUsados;
    }
    
}