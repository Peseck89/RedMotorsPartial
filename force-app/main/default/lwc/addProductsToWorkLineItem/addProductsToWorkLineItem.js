import { LightningElement, track, wire, api } from 'lwc';

import getProducts_test from '@salesforce/apex/ProductController.searchProductxBodega';
import { getPicklistValues,getObjectInfo } from 'lightning/uiObjectInfoApi';
import Trabajo__c from '@salesforce/schema/WorkOrderLineItem.Trabajo__c';
import WorkOrderLineItem_object from '@salesforce/schema/WorkOrderLineItem';
const DELAY = 100;



const COLS = [
    { label: 'Código', fieldName: 'ProductCode', type: 'text' },
    { label: 'Producto', fieldName: 'Name', type: 'text' },
    { label: 'Precio', fieldName: 'precio', type: 'currency',typeAttributes: {  maximumFractionDigits: 2,currencyCode: { fieldName: 'currencyCode' } } },
    { label: 'Bodega', fieldName: 'Bodega', type: 'text' },
    { label: 'Cantidad disponible', fieldName: 'cantidadDisponible', type: 'text' },
    { label: 'Tipo', fieldName: 'productType', type: 'text' },
];

export default class addProductsToWorkLineItem extends LightningElement{
    cols = COLS;
    @api recId;
    @api workOrderList=[];
    @api idList=[];
    productIds=[];
    quantityselected=0;
    visibleFlag=false;
    @track selectedRows=[];
    picklistValues=[];
    productCode = '';
    @api productName = '';
    productList = [];
    productList_test = [];
    error;
    showSelectedProductsFlag=false;

    @wire(getObjectInfo, { objectApiName: WorkOrderLineItem_object })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: Trabajo__c
    })
    picklistValues;


    searchProductAction() {
        var pickListValue=this.template.querySelector("lightning-combobox").value;
        //console.log(this.template.querySelector("lightning-input").value);
        var searchinput=this.template.querySelector("lightning-input").value//event.target.value
        //console.log(pickListValue);
            getProducts_test({ productType: pickListValue,productName:searchinput,workOrder:this.recId})
                .then((result) => {
                    this.productList_test = result;
                    this.error = undefined;
                   // console.log(this.productList_test);
                })
                .catch((error) => {
                    this.error = error;
                    this.productList_test = undefined;
                    console.log(error);
                    
            }).finally(() => {
                if(this.workOrderList.length!=0){
                    setTimeout(
                        () => this.selectedRows = this.workOrderList.map(record=>record.ID)
                    );
                }
            });
       
    }
    
    selectProducts() {
       // console.log(event);
        var selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
        console.log(selectedRecords);
        if(selectedRecords){

                let ids = '';
                selectedRecords.forEach(currentItem => {
                    
                    if(this.idList.indexOf(currentItem.ID)==-1){
                        this.idList.push(currentItem.ID);
                        this.productIds.push(currentItem.productId);
                        this.workOrderList.push(currentItem);
                    }

                });
                this.selectedIds = ids.replace(/^,/, '');    
            }
        this.setQuantitySelected();
    }
    get options() {
        return [
            { label: 'Búsqueda solo en Bodega Correspondiente', value: 'ServiceTerritory' },
            { label: 'Búsqueda SOLAMENTE de Mano de Obra', value: 'Mano de Obra' },//Busqueda de Mano de Obra
        ];
    }

    handleNavigate() {
        if(this.visibleFlag){
            this.visibleFlag=false;
        }
        else{this.visibleFlag=true;}
        this.selectedRows=this.idList;
        //this.template.querySelector('lightning-datatable').selectedRows=this.selectedRows;
    }

    handleDeleteLine(event) {
       // console.log(event.detail);
        //this.dispatchEvent(new CustomEvent('deleteline'));
        //const lines = event.detail;//event.target.dataset.factor;
        this.workOrderList=event.detail.deletedRecords;
        this.idList=event.detail.deletedIds;
        this.quantityselected=this.idList.length;
       // console.log(event.detail.deletedRecords);
    }

    showSelectedProducts(){
        this.productList= this.workOrderList.map(record=>record);
        this.selectedRows = this.workOrderList.map(record=>record.ID);
        this.showSelectedProductsFlag=true;
    }

    closeSelectedProducts(){
        this.showSelectedProductsFlag = false;
    }

    deselectProducts(event){
        console.log(event.detail.selectedRows);
        this.workOrderList = event.detail.selectedRows.map(record=>record);
        this.selectedRows = this.workOrderList.map(record=>record.ID);
        this.idList = this.selectedRows;
        console.log(this.workOrderList.length);
        this.setQuantitySelected();
    }

    setQuantitySelected(){
        this.quantityselected=this.workOrderList.length;
    }

    handleClose(event){
        window.location = window.location.href;
        return false;
    }
    
}