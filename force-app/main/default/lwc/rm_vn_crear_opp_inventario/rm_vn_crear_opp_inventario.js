import { LightningElement,api,track,wire } from 'lwc';
import columns from './columns';
import { reduceErrors } from 'c/ldsUtils';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProducts from '@salesforce/apex/RM_VN_CrearOportunidad_Ctrl.getProducts';
import getTipoGasolina from '@salesforce/apex/RM_VN_CrearOportunidad_Ctrl.getTipoGasolina';

const DELAY = 300;

export default class Rm_vn_crear_opp_inventario extends LightningElement {
    
    columns = columns;

    @api recordId = null;
    @track pageNumber = 1;
    @track totalRecords = 0;
    @track totalPages = 0;
    @api brand;
    @api year;
    @track model = '';
    @track productCode = '';
    @track vin = '';    
    @track internalColor = '';
    @track externalColor = '';
    @track bodegaId = '';

    bodegaErrors = [];
    bodegaInitialSelection = [];

    // isLoading = true;
    flagSelected = false;

    @track selectedProdXBodItemIds = [];
    @track selectedProdXBodItems = [];
    @track prodXBodItems = [];
    @track dynamicRecords = [];
    
    sfdcBaseURL;
    connectedCallback() {
        this.sfdcBaseURL = window.location.origin;         
    } 

    tipoCombustibleOptions = [];

    tipoCombustible = 'All'; 

    @wire(getTipoGasolina)
    wiredTipoCombustible({ data, error }) {
        if (data) {
            this.tipoCombustibleOptions = data.map(item => ({'label':item.label,'value':item.value}));
        }
    }      

    @wire(getProducts,{ productCode: '$productCode', bodegaId: '$bodegaId',  year: "$year" ,  vin: "$vin" ,  brand: "$brand" ,  internalColor: "$internalColor",  externalColor: "$externalColor" ,  model: "$model" , tipoCombustible:'$tipoCombustible', pageNumber : "$pageNumber" })    
    wiredProducts(result) { 
        this.prodXBodItems = [];       
        this.wiredProductsResult = result;
        if (result.data && result.data.records) {
            let tmpRecords = [];
            Object.values(result.data.records).forEach((item, index) => {
                if (typeof item === "object") {                    
                    let pbeFantasia = result.data.preciosFantasia.find((element) => {
                        return element.Name === item.Producto__r.modelo__c;                        
                    });

                    let pbeBavarian = result.data.preciosBavarian.find((element) => {
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
                        bodegaName : item.Bodega__r && item.Bodega__r.Name ? item.Bodega__r.Name : '-',
                        productUrl: this.sfdcBaseURL + '/'+item.Producto__r.Id,
                        pbeFantasiaId: pbeFantasia ? pbeFantasia.Id : null,
                        pbeBavarianId: pbeBavarian ? pbeBavarian.Id : null
                    };
                    tmpRecords[index] = record;

                    pbeFantasia = undefined;
                    pbeBavarian = undefined;
                }
            });
            
            this.prodXBodItems = tmpRecords;            
            this.totalRecords = result.data.totalRecords ? result.data.totalRecords : 0;
            if(this.totalRecords > 0){
                this.totalPages = Math.ceil(result.data.totalRecords / result.data.pageSize);
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
        // this.isLoading = false;
    }

    handleProdXBoditemsSelection(event){
        const selectedRows = event.detail.selectedRows;    
        this.selectedProdXBodItemIds = [];
        this.selectedProdXBodItems = [];
        // let selectedProducts;
        for (let i = 0; i < selectedRows.length; i++) {
            this.selectedProdXBodItemIds.push(selectedRows[i].Id);
            // this.prodXBodItemIds = selectedRows[i];
            // for (let j = 0; j < this.prodXBodItems.length; j++) {
            //     if (this.prodXBodItems[j].Id == selectedRows[i].Id) {
                    this.selectedProdXBodItems.push(selectedRows[i]);
            //     }
            // }
        
        }        
    }

    handleBrandChange(event){
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.brand = searchKey;
            this.selectedProdXBodItemIds = [];
            this.selectedProdXBodItems = [];
        }, DELAY);
    }

    handleYearChange(event){  
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.year = searchKey;
            this.selectedProdXBodItemIds = [];
            this.selectedProdXBodItems = [];            
        }, DELAY);
    }

    handleVinChange(event){
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.vin = searchKey;
        }, DELAY);
    }
    
    handleColorInternoChange(event){
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.internalColor = searchKey;
        }, DELAY);        
    } 

    handleColorExternoChange(event){
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.interexternalColornalColor = searchKey;
        }, DELAY);
    }     
    
    handleModelChange(event){
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.model = searchKey;
        }, DELAY);              
    }     
    
    handleCombustibleChange(event){    
        this.tipoCombustible = event.target.value;;     
    }    
    
    customTimeOut;
    refresh(){     
        if (this.customTimeOut) {
            clearTimeout(this.customTimeOut);
        }
        this.pageNumber = 1;
        // this.isLoading = true;
        this.customTimeOut = setTimeout(()=>{
            refreshApex(this.wiredProductsResult);
            // this.isLoading = false;
        },400);
    }    

    get itemsAdded(){      
        return this.selectedProdXBodItemIds.length > 0;
    }

    showSelected(event){
        this.flagSelected = !this.flagSelected;
    }

    get items(){
        return this.showSelected ? this.selectedProdXBodItems : this.prodXBodItems;
    }

    handleNextStepClick(event){
        this.dispatchEvent(new CustomEvent('nextstep', {
            detail:{
                prodXBodItems: [...this.selectedProdXBodItems],
                prodXBodItemIds: [...this.selectedProdXBodItemIds],
                brand: this.brand,
                year: this.year            
                }
            }));
    }

    get quantitySelectedItems(){
        return ' (' +this.selectedProdXBodItems.length+') seleccionados';
    }

    get records(){
        return this.prodXBodItems; 
    }

    handleClearClick(event){
        this.selectedProdXBodItems = [];
        this.selectedProdXBodItemIds = [];
    }

    get showClearButton(){
        return this.selectedProdXBodItems.length > 0;
    }

    get disableNextButton(){
        return this.selectedProdXBodItems.length == 0;
    }

    get selectedRecords(){
        return this.selectedProdXBodItems;
    }

    @api
    set selectedRecords(value){
        if(value && typeof value == 'string'){
            console.log('selected records');        
            this.prodXBodItems = JSON.parse(value);
            this.selectedProdXBodItems = JSON.parse(value);
            this.selectedProdXBodItemIds = [];
            for (let index = 0; index < this.selectedProdXBodItems.length; index++) {
                const element = this.selectedProdXBodItems[index];            
                this.selectedProdXBodItemIds.push(element.Id);
            }
        }
    }

    handleBackClick(){
        this.pageNumber--;
    }

    handleNextClick(){
        this.pageNumber++;
    }

    get isEnablePrevButton(){
        return !(this.totalPages > 0 && this.pageNumber > 1);
    }

    get isEnableNextButton(){
        return !(this.totalPages > 1 && this.pageNumber != this.totalPages);
    }     
    
    get isLoading() {
        return !this.wiredProductsResult.data && !this.wiredProductsResult.error;
    }    
}