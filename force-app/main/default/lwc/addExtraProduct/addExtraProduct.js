import { LightningElement,api, track, wire } from 'lwc';
import { reduceErrors } from 'c/ldsUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import addLineItem from '@salesforce/apex/RM_VN_QuoteController.addLineItem';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
// import getProductByQuoteId from '@salesforce/apex/ProductSearcherController.getProductByQuoteId';

export default class AddExtraProduct extends LightningElement {

    isLoading = false;

    @api recordId;

    productId = null;

    qliId = null;

    // @api family = null;
    @api brand;
    @api model;
    @api year;
    productType = 'extra';
    productCode;
    productName;
    productAlias;
    productosAgregados;
    clickType;
    
    productQuantity = 1;
    productUnitPrice = 0.0;

    showManoObraForm = false;  

    connectedCallback(){
        this.manoObraFormOpen = false;
        // console.log('product type:'+ this.productType);        
        // console.log('showManoObraForm:'+ this.showManoObraForm);        
        // console.log('entro');
    }

    //Add extras
    inputVehiculoCompatibleId;
    error;    
    @track vehicleOptions = [];
    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'QuoteLineItems',
        fields: ['QuoteLineItem.Id','QuoteLineItem.Product2.Name','QuoteLineItem.Product2.modelo__c','QuoteLineItem.Product2.marcaVehiculo__c','QuoteLineItem.Product2.Anno__c','QuoteLineItem.Product2.ProductCode','QuoteLineItem.Product2.vin__c'],
        where: "{ and: [{ esVehiculo_FM__c: { eq: true }}] }"   
    })listInfo({ error, data }) {
        if (data) {
            let preparedOptions = [];            
            data.records.forEach((item, index) => {
                let _brand = '';
                let _model = '';
                let _name = '';
                let _year = '';
                let _vin = '';
                if (item.fields && item.fields.Product2 && item.fields.Product2.value && item.fields.Product2.value.fields) {
                    if (item.fields.Product2.value.fields.marcaVehiculo__c && item.fields.Product2.value.fields.marcaVehiculo__c.value) {
                        _brand = item.fields.Product2.value.fields.marcaVehiculo__c.value;
                    }
                    if (item.fields.Product2.value.fields.modelo__c && item.fields.Product2.value.fields.modelo__c.value) {
                        _model = item.fields.Product2.value.fields.modelo__c.value;
                    }                    
                    if (item.fields.Product2.value.fields.Name && item.fields.Product2.value.fields.Name.value) {
                        _name = item.fields.Product2.value.fields.Name.value;
                    }
                    if (item.fields.Product2.value.fields.vin__c && item.fields.Product2.value.fields.vin__c.value) {
                        _vin = item.fields.Product2.value.fields.vin__c.value;
                    }
                    if (item.fields.Product2.value.fields.Anno__c && item.fields.Product2.value.fields.Anno__c.value) {
                        _year = item.fields.Product2.value.fields.Anno__c.value;
                    }                                        
                }
                let option = {                    
                    value: item.id,
                    label: _name + ' - '+_vin,
                    brand: _brand,
                    model: _model,
                    year: _year
                };
                preparedOptions[index] = option;             
            });
            this.vehicleOptions = preparedOptions;
            // console.log('this.vehicleOptions');
            // console.log(this.vehicleOptions);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.vehicleOptions = [];
        }
    }    

    get isDisableAcceptButton(){
        return this.productId == null;
    }

    get isProductTypeExtraSelected(){
        return this.productType == 'extra';
    }
    
    handleProductTypeEvent(event){
        this.productType = event.detail.productType;
    }
        
    manoObraFormOpen = false;

    handleCloseEvent(){
        this.manoObraFormOpen = false;
        const modal = this.template.querySelector('c-r-m_-modal');
        modal.hide();
    }

    get showNextButton(){
        return !this.manoObraFormOpen && this.productType == 'mano obra';
    }

    handleNextClick(event){
        const modal = this.template.querySelector('c-r-m_-modal');
        modal.show();
        this.manoObraFormOpen = true;
        this.productAlias = '';
        this.productQuantity = 1;
    }

    handleExtraClick(){    
        for(let i=0;i<this.productosAgregados.length;i++){
            let prod1 = this.productosAgregados[i];   
            console.log('prod1 ',prod1);
            this.productName = prod1.productName ? prod1.productName : '';
            this.productCode = prod1.productCode ? prod1.productCode : '';
            this.productUnitPrice = prod1.productUnitPrice ? parseFloat(prod1.productUnitPrice).toFixed(2) : 0.0;
            this.productId = prod1.Id;
            console.log('recordId ',this.recordId);
            console.log('productId ',this.productId);
            console.log('qliId ',this.qliId);
            console.log('productType ',this.productType);
            console.log('productAlias ',this.productAlias);
            console.log('productQuantity ',this.productQuantity);
            console.log('productUnitPrice ',this.productUnitPrice);

            this.addItemAction({
                quoteId:this.recordId,
                prodXBodId:this.productId,
                qliId: this.qliId,
                esRegalia: false,
                esExtra: true,
                productType:this.productType,
                productAlias:this.productAlias,
                productQuantity:this.productQuantity,
                productUnitPrice:this.productUnitPrice
    
            });
        }   
    }

    handleRegaliaClick(){
        for(let i=0;i<this.productosAgregados.length;i++){
            let prod1 = this.productosAgregados[i];   
            this.productName = prod1.productName ? prod1.productName : '';
            this.productCode = prod1.productCode ? prod1.productCode : '';
            this.productUnitPrice = prod1.productUnitPrice ? parseFloat(prod1.productUnitPrice).toFixed(2) : 0.0;
            this.productId = prod1.Id;

            this.addItemAction({
                quoteId:this.recordId,
                prodXBodId:this.productId,
                qliId: this.qliId,
                esRegalia: true,
                esExtra: false,            
                productType:this.productType,
                productAlias:this.productAlias,
                productQuantity:this.productQuantity,
                productUnitPrice:this.productUnitPrice
            });
        }
    }

    addItemAction(params){
        setTimeout(() => {
        console.log('en timeout');
        this.isLoading = true;
        params.productAlias = this.productAlias != null && this.productAlias != '' ? this.productAlias : this.productName;
        addLineItem(params)
        .then((response)=>{
            this.dispatchEvent(new ShowToastEvent({
                title: 'Item(s) agregado(s) al presupuesto.',
                message: 'Item(s) agregado(s) correctamente.',
                variant: 'success'
            }));
            this.productId = null;
            this.template.querySelector('c-product-searcher').refresh();
            eval("$A.get('e.force:refreshView').fire();");


            if (this.productType == 'mano obra') {
                const modal = this.template.querySelector('c-r-m_-modal');
                modal.hide();
                this.manoObraFormOpen = false;
            } 

        })
        .catch((error)=>{
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error al agregar el nuevo item',
                message: reduceErrors(error).join(', '),
                variant: 'error'
            }));            
        })
        .finally(()=>{
            this.isLoading = false;
        });    
        },3000);    
    }
  
    handleProductSelectionEvent(event){        
        [ this.productId] = event.detail.products;
        this.qliId = event.detail.vehiculoCompatibleId;
        this.esManoObra = event.detail.esManoDeObra;
        this.esExtra = event.detail.esExtra;
        this.productType = event.detail.productType;        

        // let selectedItem = event.detail.selectedRows;
        let selectedItem = event.detail.selectedRows;
        this.productosAgregados = selectedItem;
        // console.log('selected product');
        // console.log(selectedItem);
        // console.log(selectedItem.length);
        if (selectedItem && selectedItem.length > 0 &&  selectedItem[0] != undefined) {            
            // console.log(selectedItem[0]);
            let prod = selectedItem[0];            
            this.productName = prod.productName ? prod.productName : '';
            this.productCode = prod.productCode ? prod.productCode : '';
            this.productUnitPrice = prod.productUnitPrice ? parseFloat(prod.productUnitPrice).toFixed(2) : 0.0;

        }
       
    }

    handleAliasChange(event){
        this.productAlias = event.detail.value;
    }

    handleQuantityChange(event){
        this.productQuantity = event.detail.value;
    }

    handleUnitPriceChange(event){
        this.productUnitPrice = event.detail.value;
    }    

    get totalManoObra(){
        return (parseFloat(this.productQuantity) * parseFloat(this.productUnitPrice)).toFixed(2);
    }

}