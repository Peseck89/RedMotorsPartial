import { LightningElement,track,wire,api } from 'lwc';
import columnsVehicle from './columns';
import { reduceErrors } from 'c/ldsUtils';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProducts from '@salesforce/apex/ProductSearcherController.getProducts';
import search from '@salesforce/apex/SampleLookupController.searchRecords';

const COLUMNS_EXTRA = [
    { 
        label: 'Nombre',
        fieldName: 'productUrl', 
        type: 'url',       
        typeAttributes: {label: { fieldName: 'productName' }, target: '_blank'},
    },    
    { label: 'Código', fieldName: 'productCode',initialWidth: 200},
    { label: 'Precio', fieldName: 'productUnitPrice', type: 'currency',typeAttributes: { currencyCode: 'USD' }, initialWidth:150},
    { label: 'Disponible', fieldName: 'Disponible__c', type: 'number', initialWidth:150},
    { label: 'Bodega', fieldName: 'bodegaName', type: 'text',initialWidth: 250}
];

const COLUMNS_MANOOBRA = [
    { 
        label: 'Nombre',
        fieldName: 'productUrl', 
        type: 'url',       
        typeAttributes: {label: { fieldName: 'productName' }, target: '_blank'},
    },
    { label: 'Código', fieldName: 'productCode'},
    { label: 'Precio', fieldName: 'productUnitPrice', type: 'currency', typeAttributes: { currencyCode: 'USD', alignment: 'center'},initialWidth:150}
];

export default class ProductSearcher extends LightningElement {

    columnsVehicle = columnsVehicle;
    columnsExtra = COLUMNS_EXTRA;
    columnsManoObra = COLUMNS_MANOOBRA;

    //Opp or Quote 
    _vehicleOptions;

    @api 
    oppProdIntId = null;

    @api
    recordId = null;
    
    @api title = null;

    @api 
    productType;

    pageNumber = 1;
    totalRecords = 0;
    totalPages = 0;
    showFilters = true;

    productName = null;

    vin = null;
    
    @api
    brand = null;

    @api
    year = null;    

    @api
    model = null;

    @api
    family = null;
        
    intColor = null;

    extColor = null;

    @api
    productCode = null;

    @api
    bodegaId = null;
    bodegaErrors = [];
    bodegaInitialSelection = [];

    isLoading = true;

    //Item selected from the user
    prodXBodItem;
  
    wiredProductsResult;
    @track products = [];
    selectedProductIds = [];

    
    productTypeOptions = [{ value: 'extra', label: 'Articulos'}, { value:  'mano obra', label: 'Otros gastos'  }];

    //Create a property to save the selected value from the vehiculoTransito combobox
    @track vehiculoTransito = 'All';

    //create a property  vehiculoTransitoOptions that will provide values for a combobox, Todos,Si,No
    @track vehiculoTransitoOptions = [
        { label: 'Todos', value: 'All' },
        { label: 'Si', value: 'Si' },
        { label: 'No', value: 'No' },
    ];


    //create a method to handel the change event of the vehiculoTransito combobox
    handleVehiculoTransitoChange(event) {
        //get the value of the selected option
        this.vehiculoTransito = event.detail.value;
    }
    
    handleProductTypeChange(event){
        this.productType = event.detail.value;
        // if (this.productType == 'mano obra') {
        //     this.columns = this.columnsManoObra;
        // }else{
        //     this.columns = thi.col;
        // }
        // this.refresh();
        
        this.dispatchEvent(new CustomEvent('producttypeselected', {
            detail:{
                productType: this.productType,
            }
        }));
    }

    
    get dynamicColumns(){
        if (this.productType == 'mano obra') {
            return this.columnsManoObra;
        }else if(this.productType == 'extra'){
            return this.columnsExtra;
        }else{
            return this.columnsVehicle;
        }
    }

    sfdcBaseURL;
    connectedCallback() {
        if(this.brand && this.brand.toLowerCase() == 'kawasaki'){
            this.brand = 'Kawa';
        }
        console.log('connectedCallback productSearcher');
        console.log(this.brand);

        this.sfdcBaseURL = window.location.origin; 
        // this.isLoading = true;        
    }

    @wire(getProducts,{ productType: '$productType', oppProdIntId:'$oppProdIntId', productName: '$productName',  productCode: '$productCode', bodegaId: '$bodegaId',  year: "$year" ,  vin: "$vin" ,  brand: "$brand" ,  family: "$family" ,  intColor: "$intColor",  extColor: "$extColor" ,  model: "$model" ,  recordId: "$recordId" ,  vehiculoTransito: "$vehiculoTransito" ,pageNumber : "$pageNumber" })    
    wiredProducts(result) { 
        this.products = [];       
        this.wiredProductsResult = result;
        if (result.data && result.data.products) {
            let records = JSON.parse(JSON.stringify(result.data.products));
            Object.values(result.data.products).forEach((item, index) => {
                if (typeof item === "object") {
                    
                    let pbeFantasia;
                    let pbeBavarian;

                    if(this.productType == 'vehiculo'){
                        if (result.data.preciosFantasia) {
                            pbeFantasia = result.data.preciosFantasia.find((element) => {
                                return element.Name === item.Producto__r.modelo__c;                        
                            });   
                        }
                       
                        if (result.data.preciosBavarian) {
                            pbeBavarian = result.data.preciosBavarian.find((element) => {
                                return element.Product2Id === item.Producto__c;                        
                            });
                        }   
                    }else if (result.data.prices ){
                        if(this.productType == 'extra'){
                            pbeBavarian = result.data.prices.find(({ Product2Id }) => item.Producto__r.Id === Product2Id);
                        }else if(this.productType == 'mano obra'){
                            pbeBavarian = result.data.prices.find(({ Product2Id }) => item.Id === Product2Id);
                        }
                    }


                    if(item.Producto__r){
                        records[index].productId =  item.Producto__r.Id ? item.Producto__r.Id : '';
                        records[index].productCode =  item.Producto__r.Codigo_de_Producto__c ? item.Producto__r.Codigo_de_Producto__c : '';
                        records[index].productName = item.Producto__r.Name ? item.Producto__r.Name : '';
                        records[index].productBrand = item.Producto__r.marcaVehiculo__c ? item.Producto__r.marcaVehiculo__c : '';
                        records[index].productModel = item.Producto__r.modelo__c ? item.Producto__r.modelo__c : '';
                        records[index].productFamily = item.Producto__r.VN_Familia__c ? item.Producto__r.VN_Familia__c : '';
                        records[index].productVin = item.Producto__r.vin__c ? item.Producto__r.vin__c : '';
                        records[index].productYear = item.Producto__r.Ano__c ? item.Producto__r.Ano__c : '';
                        records[index].productColor = item.Producto__r.Color__c ? item.Producto__r.Color__c : '';                        
                        records[index].productColorExterno = item.Producto__r.Color_Externo__c ? item.Producto__r.Color_Externo__c : '';  
                        records[index].productPriceFantasia = pbeFantasia && pbeFantasia.UnitPrice ? parseFloat(pbeFantasia.UnitPrice).toFixed(2) : 0;  
                        records[index].productUrl = this.sfdcBaseURL + '/'+item.Producto__r.Id;    
                        records[index].pbeFantasiaId = pbeFantasia ? pbeFantasia.Id : 0.0;
                        records[index].pbeBavarianId = pbeBavarian ? pbeBavarian.Id : 0.0;   
   
                    }else if(this.productType == 'mano obra'){
                        records[index].productId =  null;
                        records[index].productCode = item.Codigo_de_Producto__c ? item.Codigo_de_Producto__c : '';
                        records[index].productName = item.Name ? item.Name : '';
                        records[index].productQuantity = 1;                        
                        records[index].productUrl = this.sfdcBaseURL + '/'+item.Id;    
                    }else{
                        records[index].productId =  item.Id;
                        records[index].productCode = item.Codigo_de_Producto__c ? item.Codigo_de_Producto__c : '';
                        records[index].productName = item.Name ? item.Name : '';
                        records[index].productBrand = '';
                        records[index].productModel = '';
                        records[index].productVin = '';
                        records[index].productYear = '';
                        records[index].productColor = '';                          
                        records[index].productColorExterno = '';                           
                        records[index].productUrl = this.sfdcBaseURL + '/'+item.Id;                       
                    }

                    if(this.productType == 'vehiculo'){
                        records[index].productUnitPrice = pbeFantasia && pbeFantasia.UnitPrice ? parseFloat(pbeFantasia.UnitPrice).toFixed(2) : 0; 
                    }else{
                        records[index].productUnitPrice = pbeBavarian && pbeBavarian.UnitPrice ? parseFloat(pbeBavarian.UnitPrice).toFixed(2) : 0;
                    }
                    
                    if(item.Bodega__r){
                        records[index].bodegaName = item.Bodega__r.Name ? item.Bodega__r.Name : '-' 
                    }else{
                        records[index].bodegaName = '';
                    }
                }
            });
            // console.log('records');
            // console.log(records);
            this.products = records;           
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
        this.isLoading = false;
    }

    getPrice(productId,prices){
        let price = 0;
        if (prices && productId) {
            let productPrice = prices.find(({ Product2Id }) => productId === Product2Id);
            if(productPrice){console.log('productPrice:', productPrice);
                price = productPrice.UnitPrice;
            }            
        }
        return price;
    }

    // setLoading(currFieldValue,newValue,action){
    //     if (newValue.length > 0) {        
    //         if (currFieldValue != newValue) {
    //             this.isLoading = true;    
    //             this.pageNumber = 1;
    //         }
    //         action();
    //     }
    // }

    handleRecordNameChange(event){
        let value = event.target.value;
        // if (value.length > 0) {
            if (this.productName != value) {
                this.isLoading = true;    
                this.pageNumber = 1;
            }        
        // }
        this.productName = value;            
    }

    handleCodigoChange(event){
        let value = event.target.value;
        // if (value.length > 0) {
            if (this.productCode != value) {
                this.isLoading = true;    
                this.pageNumber = 1;
            }        
        // }
        this.productCode = value;
    }

    handleShowFiltersClick(event) {
        this.showFilters = !this.showFilters;
    }    

    handleYearChange(event){  
        let value = event.target.value;     
        // if (value.length > 0) { 
            if (this.year != value) {
                this.isLoading = true;    
                this.pageNumber = 1;
            }
        // }
        this.year = value;
    }

    handleVinChange(event){
        let value = event.target.value;
        // if (value.length > 0) {
            if (this.vin != value) {
                this.isLoading = true;    
                this.pageNumber = 1;
            }
        // }  
        this.vin = value; 
    }
    
    handleColorInternoChange(event){
        let value = event.target.value;
        // if (value.length > 0) {
            if (this.intColor != value) {
                this.isLoading = true;    
                this.pageNumber = 1;
            }        
        // }
        this.intColor = value;
    } 

    handleColorExternoChange(event){
        let value = event.target.value;
        // if (value.length > 0) {
            if (this.extColor != value) {
                this.isLoading = true;    
                this.pageNumber = 1;
            }          
        // }
        this.extColor = value;
    }     
    
    handleModelChange(event){    
        let value = event.target.value;    
        // if (value.length > 0) {
            if (this.model != value) {
                this.isLoading = true;    
                this.pageNumber = 1;
            }   
        // }  
        this.model = value;
    }   

    handleBackClick(){
        this.pageNumber--;
        this.refresh();
    }

    handleNextClick(){
        this.pageNumber++;
        this.refresh();
    }

    get isEnablePrevButton(){
        return !(this.totalPages > 0 && this.pageNumber > 1);
    }

    get isEnableNextButton(){
        return !(this.totalPages > 1 && this.pageNumber != this.totalPages);
    }    
    
    handleProductSelection(event){
        const selectedRows = event.detail.selectedRows;

        this.selectedProductIds = [];
        let selectedItem;
        for (let i = 0; i < selectedRows.length; i++) {
            this.selectedProductIds.push(selectedRows[i].Id);
            this.prodXBodItem = selectedRows[i];
            selectedItem = selectedRows[i];
        }
        // console.log(selectedItem);
        this.dispatchEvent(new CustomEvent('productselection', {
            detail:{
                products: [...this.selectedProductIds],
                prodXBodegaId: [...this.selectedProductIds],
                prodXBodItem: this.prodXBodItem,
                vehiculoCompatibleId: this.inputVehiculoCompatibleId,
                esManoDeObra: this.esManoDeObra,
                esExtra: this.esExtra,
                productType: this.productType,
                selectedRows: selectedRows
            }
        }));
                
    }


    get showVehicleFilters(){
        return this.productType == 'vehiculo';
    }

    get showFiltersVehiculoManoObra(){
        return this.productType == 'extra' || this.productType == 'mano obra';
    }

    get showFiltersExtra(){
        return this.productType == 'extra';
    }

    get isManoObra(){
        return this.productType == 'mano obra';
    }

    get maxRowSelection(){
        return this.isVehicle === true ? 1 : 5;
    }  

    customTimeOut;
    @api
    refresh(){     
        if (this.customTimeOut) {
            clearTimeout(this.customTimeOut);
        }

        this.isLoading = true;
        this.selectedProductIds = [];        

        this.customTimeOut = setTimeout(()=>{
            refreshApex(this.wiredProductsResult);
            this.isLoading = false;
        },400);
    }

    handleBodegaSearch(event){
        const lookupElement = event.target;
        var params = event.detail;
        console.log(params);        
        params["firedElement"] = 'Bodega';
        params["icon"] = 'standard:user';
        params["objName"] = 'Bodega__c';
        params["displayedObjName"] = 'Bodega';

        search(params)
            .then((results) => {
                lookupElement.setSearchResults(results);
            });
    }

    handleBodegaSelectionChange(event){        
        let bodId = null;
        [ bodId ] = event.detail;
        this.bodegaId = bodId != undefined ? bodId : null; 
    }    

    // Add extra articles

    get vehicleOptions(){
        return this._vehicleOptions;
    }
    
    @api 
    set vehicleOptions(value){
        if (value) {            
            this._vehicleOptions = value;
            if (this._vehicleOptions.length == 1) {
                this.brand = this._vehicleOptions[0].brand;
                this.model = this._vehicleOptions[0].model; 
                this.year = this._vehicleOptions[0].year; 
                this.inputVehiculoCompatibleId = this._vehicleOptions[0].value;

                console.log('==========this._vehicleOptions==========');
                console.log(this._vehicleOptions[0].brand);
                console.log(this._vehicleOptions[0].model);
                console.log(this._vehicleOptions[0].year);
            }
        }
    }

    handleVehicleCompatibleChange(event){
        if (event.detail.value != undefined) {            
            this.inputVehiculoCompatibleId = event.detail.value;
            console.log(this.inputVehiculoCompatibleId);
            this._vehicleOptions.forEach((item, index) => {
                if (event.detail.value == item.value) {
                    this.brand = item.brand;
                    this.model = item.model;
                    this.year = item.year;
                    // this.refresh();                
                }
            });
        }
    }

    get showManoObraFilters(){
        return this.productType == 'mano obra';
    }

    handleNameChange(event){
        this.productName = event.target.value;
    }

    handleBrandChange(event){
        console.log('handleBrandChange');
        //get recordTypeId from a custom event
        this.brand = event.detail.recordTypeId;
        console.log('Brand: ' + this.brand);
    }
}