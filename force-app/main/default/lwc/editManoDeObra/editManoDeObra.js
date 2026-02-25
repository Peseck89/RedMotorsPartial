import { LightningElement, api, track, wire } from 'lwc';


import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import saveLines from '@salesforce/apex/ProductController.saveWorkLineItems';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues,getObjectInfo } from 'lightning/uiObjectInfoApi';
import Trabajo__c from '@salesforce/schema/WorkOrderLineItem.Trabajo__c';
import WorkOrderLineItem_object from '@salesforce/schema/WorkOrderLineItem';

//import selectedProducts from '@salesforce/apex/ProductController.selectedProducts';
const DELAY = 100;
//


const COLS = [
    { label: 'Código', fieldName: 'ProductCode', type: 'text' },
    { label: 'Producto', fieldName: 'Name', type: 'text' },
    { label: 'Precio unitario', fieldName: 'precio__c', type: 'text' },
    { label: 'Cantidad disponible', fieldName: 'cantidadDisponible__c', type: 'text' },

    { label: 'Alias artículo', fieldName: '', type: 'text',  editable: true },
    { label: 'Cantidad', fieldName: '', type: 'text', editable: true },
    { label: 'Descuento', fieldName: '', type: 'text', editable: true },
];

export default class TargetLwcComponent extends NavigationMixin(LightningElement)  {
    @wire(getObjectInfo, { objectApiName: WorkOrderLineItem_object })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: Trabajo__c
    })
    picklistValues;
     
    cols = COLS;
   
    @api propertyValue="checkbox-unique-id-81";
    @api lines;
    modifiedList;
    @api workorderids;
    @api productids;
    @api recid;
    productList_test;
    selectProducts;
    selectedRows;
    modifiedIds;
    deletelines=[];
    showDelete=false;

}