import { LightningElement,track,wire,api } from 'lwc';
// import { reduceErrors } from 'c/ldsUtils';
// import { refreshApex } from '@salesforce/apex';
// import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import getOppLineItems from '@salesforce/apex/CT_OppLineItems_Controller.getOppLineItems';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';

const columns = [
    { label: 'Código', fieldName: 'productCode'},
    { label: 'Nombre', fieldName: 'productName'},
    { label: 'Marca', fieldName: 'productBrand'},
    { label: 'Modelo', fieldName: 'productModel'},
    { label: 'Precio', fieldName: 'price', type: 'currency'},
];

export default class CT_Opportunity_Line_Items extends LightningElement {
    @api oppId;

    columns = columns;
    isLoading = true;
  
    selectedOppProdInteresIds = [];
    numItems = 0;    
    firstOLIId = null;
    
    error;    
    records = [];
    @wire(getRelatedListRecords, {
        parentRecordId: '$oppId',
        relatedListId: 'Oportunidad_Producto_Interes__r',
        fields: ['Oportunidad_Producto_Interes__c.Id','Oportunidad_Producto_Interes__c.Marca__c','Oportunidad_Producto_Interes__c.Familia__c','Oportunidad_Producto_Interes__c.Anio__c','Oportunidad_Producto_Interes__c.Modelo_Interes__c','Oportunidad_Producto_Interes__c.Precio_Unitario__c','Oportunidad_Producto_Interes__c.Producto__r.Name','Oportunidad_Producto_Interes__c.Producto__r.ProductCode']
    })listInfo({ error, data }) {
        console.log('entro');
        if (data) {
            let preparedRecords = [];
            this.numItems = data.records.length;
            data.records.forEach((item, index) => {
                if (item.fields) {
                    
                }                    
                this.firstOLIId = item.fields.Id.value;            
                let _productCode = '';
                let _productName = '';
                if (item.fields && item.fields.Producto__r && item.fields.Producto__r.value && item.fields.Producto__r.value.fields) {

                    if (item.fields.Producto__r.value.fields.ProductCode && item.fields.Producto__r.value.fields.ProductCode.value) {
                        _productCode = item.fields.Producto__r.value.fields.ProductCode.value;
                    }
                    
                    if (item.fields.Producto__r.value.fields.Name && item.fields.Producto__r.value.fields.Name.value) {
                        _productName = item.fields.Producto__r.value.fields.Name.value;
                    }
                }
                let record = {
                    Id: item.id,
                    productCode: _productCode,
                    productName: _productName,
                    productBrand: item.fields.Marca__c.value,
                    productFamily: item.fields.Familia__c.value,
                    productModel: item.fields.Modelo_Interes__c.value,                
                    productYear: item.fields.Anio__c.value,
                    price: item.fields.Precio_Unitario__c.value
            };
                preparedRecords[index] = record;             
            });

            if (this.numItems == 1) {
                this.selectedOppProdInteresIds.push(this.firstOLIId);
                this.selectItemEvent();
            }

            this.records = preparedRecords;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.records = [];
        }
        this.isLoading = false;
    }
    
    handleOppLineItemSelection(event){
        const selectedRows = event.detail.selectedRows;        
        this.selectedOppProdInteresIds = [];
        for (let i = 0; i < selectedRows.length; i++) {
            this.selectedOppProdInteresIds.push(selectedRows[i].Id);
        }
    }

    get isDisableAcceptButton(){
        return this.selectedOppProdInteresIds.length == 0;
    }

    handleNextClick(event){
        this.selectItemEvent();
    }

    selectItemEvent(){
        this.dispatchEvent(new CustomEvent('prodinteresselection', {
            detail:{
                oppProdInteresId: [...this.selectedOppProdInteresIds]
            }
        }));        
    }    

}