import { LightningElement, track, wire, api } from 'lwc';searchWOId
import { refreshApex } from '@salesforce/apex';

//import getProducts from '@salesforce/apex/ProductController.searchProductNameMethod';
import searchMO from '@salesforce/apex/ProductController.searchMO';
import searchWOId from '@salesforce/apex/SampleLookupController.searchWorkOrderId';
import { getPicklistValues,getObjectInfo } from 'lightning/uiObjectInfoApi';
import Trabajo__c from '@salesforce/schema/WorkOrderLineItem.Trabajo__c';
import WorkOrderLineItem_object from '@salesforce/schema/WorkOrderLineItem';
const DELAY = 100;

const COLS = [
    { label: 'Código', fieldName: 'ProductCode', type: 'text' },
    { label: 'Producto', fieldName: 'Name', type: 'text' },
    { label: 'Precio', fieldName: 'precio', type: 'currency',
    typeAttributes: {  maximumFractionDigits: 2,currencyCode: { fieldName: 'currencyCode' } } },
];

const secondTableCOLS = [
    { label: 'Código', fieldName: 'ProductCode', type: 'text' },
    { label: 'Producto', fieldName: 'Name', type: 'text' },
    { label: 'Precio unitario', fieldName: 'precio__c', type: 'text' },
    { label: 'Cantidad disponible', fieldName: 'cantidadDisponible__c', type: 'text' },

    { label: 'Alias artículo', fieldName: '', type: 'text',  editable: true },
    { label: 'Cantidad', fieldName: '', type: 'text', editable: true },
    { label: 'Descuento', fieldName: '', type: 'text', editable: true },
];

const toSegregateCols = [
    { label: 'Código', fieldName: 'ProductCode', type: 'text' },
    { label: 'Producto', fieldName: 'Name', type: 'text' },
    { label: 'Alias artículo', fieldName: '', type: 'text',  editable: true },
    { label: 'Precio unitario', fieldName: 'precio__c', type: 'text' },
    { label: 'Cliente', fieldName: '', type: 'text',  editable: true },
    { label: 'Garantia ', fieldName: '', type: 'text',  editable: true },
    { label: '', fieldName: '', type: 'text',  editable: true },
    { label: 'Alias', fieldName: '', type: 'text',  editable: true },
    { label: 'Cantidad disponible', fieldName: 'cantidadDisponible__c', type: 'text' },


    { label: 'Cantidad', fieldName: '', type: 'text', editable: true },
    { label: 'Descuento', fieldName: '', type: 'text', editable: true },
];

export default class searchManoDeObra extends LightningElement {
    cols = COLS;
    cols2=secondTableCOLS;
    @api recid;
    @api workOrderList = [];
    @api idList = [];
    @api visibleflagsearchmo=false;
    @api productName = '';
    @track productList = [];
    
    
    error;
    productIds = [];
    picklistValues = [];
    productList_test = [];
    selectedrows = [];
    productList_selected = [];
    quantityselected = 0;
    visibleFlag = false;
    productCode = '';
    thirdScreen = false;
    secondScreen = true;
    workOrderId;
    showDelete=false;

    // MAMBINI
    @api propertyValue="checkbox-unique-id-81";
    @api lines;
    @api workorderids;
    @api productids;
    modifiedIds;
    deletelines=[];
    showDelete=false;
    productCode = '';
    productName = '';
    @track productList = [];



    @wire(getObjectInfo, {
        objectApiName: WorkOrderLineItem_object
    })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: Trabajo__c
    })
    picklistValues;

    searchProductAction() {
        this.recid = '5007g00000AjSFHAA3';

        var searchinput = this.template.querySelector("lightning-input").value;
        const parametersMO = {}; // Mano de obra
        const parametersWO = {}; // Work Order
        parametersMO["productType"] = 'Mano de Obra';
        parametersMO["productName"] = searchinput;
        parametersMO["workOrder"] = this.workOrderId;

        console.log(this.recid);

        parametersWO["caseIdentificator"] = this.recid;
        searchWOId(parametersWO)
            .then((result) => {
                this.workOrderId = result;
                console.log(this.workOrderId);
                this.selectedrows = this.idList;
            })
            .catch((error) => {
                this.error = error;
            });


        searchMO(parametersMO)
            .then((results) => {
                console.log(results);
                this.productList_test = results;
            })
            .catch((error) => {
                this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    selectProducts() {
        var selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
        var localIdList = []
        var localworkOrderList = []
        if (selectedRecords) {
            //console.log('selectedRecords are ', selectedRecords);
            let ids = '';
            selectedRecords.forEach(currentItem => {

                if (this.idList.indexOf(currentItem.ID) == -1) {
                    this.idList.push(currentItem.ID);
                    this.productIds.push(currentItem.productId);
                    this.workOrderList.push(currentItem);
                    this.productList_selected.push(currentItem);
                }
            });
            this.selectedIds = ids.replace(/^,/, '');
            this.lstSelectedRecords = selectedRecords;
        }
        this.quantityselected = this.idList.length;
    }

    watchSelectedItems() {
        this.productList_test = this.productList_selected;
    }


    handleNavigate(data) {
        if (this.visibleFlag) {
            this.visibleFlag = false;
        } else {
            this.visibleFlag = true;
        }
        //this.watchSelectedItems();
        //this.selectedRows = this.productList_selected;
        this.productList_test = this.productList_selected;
        this.secondScreen=false;
        this.thirdScreen=true;
    }

    
    handleDeleteLine(event) {
        this.workOrderList = event.detail.deletedRecords;
        this.idList = event.detail.deletedIds;
        this.quantityselected = this.idList.length;
    }

    handlecheck(event) {
        console.log("Handle check");
        var indexes;
        var modifiedIndex=this.workorderids.indexOf(event.currentTarget.dataset.id); 
        console.log(modifiedIndex);
        if(event.target.checked){
            this.deletelines.push(event.currentTarget.dataset.id);
        }
        else{
            modifiedIndex=this.deletelines.indexOf(event.currentTarget.dataset.id);
            console.log(modifiedIndex);
            this.deletelines.splice(modifiedIndex, 1);
            console.log(this.deletelines);
        }
        this.showDelete=(this.deletelines.length>0);
       indexes=this.deletelines;
    }

    handleDeleteLineEditMO(event) {

        console.log("TEST");
        console.log(this.productList_test);
        console.log("----------------------");
        var listaIds;
        var records;
        const lines = 5;
        console.log("Lines to be deleted:");
        console.log(this.deletelines);
        console.log("Selected IDs:");
        console.log(this.idList);

        this.deletelines.forEach(currentItem => {
            this.idList.splice(this.idList.indexOf(currentItem), 1);
        });

        console.log("Missing LIST");
        console.log(this.idList);

        this.deletelines=[];
        this.showDelete=(this.idList.length>0);
        this.productList_test=this.idList;
        this.quantityselected=this.idList.length;
    }

    handlecheckEditMO(event) {
        console.log("HANDLE CHECK");
        var indexes;
        console.log("modifiedIndex");
        console.log(event.currentTarget.dataset);
        var modifiedIndex=this.productList_test.indexOf(event.currentTarget.dataset.id); 
        
        if(event.target.checked){
            console.log(event.currentTarget.dataset.id);
            console.log(event.currentTarget.dataset.id)
            this.deletelines.push(event.currentTarget.dataset.id);
        }else{
            modifiedIndex=this.deletelines.indexOf(event.currentTarget.dataset.id);
            this.deletelines.splice(modifiedIndex, 1);
        }
        this.showDelete=(this.deletelines.length>0);
       indexes=this.deletelines;
       console.log(indexes);
    }

    handleApproval(event){
        var modifiedIndex=this.workorderids.indexOf(event.currentTarget.dataset.id); 
        this.modifiedList[modifiedIndex].aprobado=event.detail.checked;
        }

    backToSelectMO(){
        this.thirdScreen=false;
        this.secondScreen=true;
        this.deletelines=[];
        this.showDelete=false;
    }

    handleDiscount(event) {
        // this.modifiedList=this.lines;
        //console.log(event.detail.value);
        ;
         var modifiedIndex=this.workorderids.indexOf(event.currentTarget.dataset.id); 
         this.modifiedList[modifiedIndex].discount=event.detail.value;
         this.modifiedList.forEach(currentItem => {
     
            //console.log(currentItem.discount);
 
         });
        
     }

     handleQuantity(event) {
        // this.modifiedList=this.test;
        //console.log(event.detail.value);
         var modifiedIndex=this.workorderids.indexOf(event.currentTarget.dataset.id); 
         this.modifiedList[modifiedIndex].cantidad=event.detail.value;
         this.modifiedList.forEach(currentItem => {
     
            //console.log(currentItem.cantidad);
 
         });
        
     }

     handleAlias(event) {
        // this.modifiedList=this.lines;
        //console.log(event.currentTarget.dataset.id);
         var modifiedIndex=this.workorderids.indexOf(event.currentTarget.dataset.id); 
         this.modifiedList[modifiedIndex].alias=event.currentTarget.value;
     }
}