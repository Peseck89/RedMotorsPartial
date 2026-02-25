import { LightningElement, track, wire, api } from 'lwc';searchWOId
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';

//import getProducts from '@salesforce/apex/ProductController.searchProductNameMethod';
import searchMO from '@salesforce/apex/ProductController.searchMO';
import searchWOId from '@salesforce/apex/SampleLookupController.searchWorkOrderId';
import { getPicklistValues,getObjectInfo } from 'lightning/uiObjectInfoApi';
import Trabajo__c from '@salesforce/schema/WorkOrderLineItem.Trabajo__c';
import WorkOrderLineItem_object from '@salesforce/schema/WorkOrderLineItem';
import saveLines from '@salesforce/apex/TipoTrabajoCasoController.saveWorkLineItems';
import getWorkOrderListMethod from '@salesforce/apex/WorkOrderListController.getWorkOrderList';

const DELAY = 100;

const COLS = [
    { label: 'Código', fieldName: 'ProductCode', type: 'text' },
    { label: 'Producto', fieldName: 'Name', type: 'text' },
    { label: 'Precio', fieldName: 'precio', type: 'currency',
    typeAttributes: {  maximumFractionDigits: 2,currencyCode: { fieldName: 'currencyCode' } } },
];

const woTableCols = [
    //{ label: 'Id', fieldName: 'Id', type: 'Id' },
    { label: 'Orden de trabajo', fieldName: 'WorkOrderNumber', type: 'Auto Number' },
    { label: 'Cuenta', fieldName: 'CT_AccountName__c', type: 'text' }
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

export default class searchManoDeObra extends NavigationMixin(LightningElement){
    cols = COLS;
    cols2 = secondTableCOLS;
    woCols = woTableCols;
    @api recid;
    @api aseguradora;
    @api centrodecosto;
    @api tipodecargo;
    @api tipodetrabajoid;
    @api workOrderList = [];
    @api tipodetrabajocaso;
    @api idList = [];
    @api visibleflagsearchmo=false;
    @api productName = '';
    @track productList = [];
    @api nombretrabajo;
    
    
    error;
    productIds = [];
    picklistValues = [];
    productList_test = [];
    selectedrows = [];
    selectedWOrows = [];
    productList_selected = [];
    relatedWorkOrderList = [];
    quantityselected = 0;
    quantityWOselected = 0;
    visibleFlag = false;
    productCode = '';
    fourthScreen = false;
    thirdScreen = false;
    secondScreen = true;
    workOrderId;

    // MAMBINI
    @api propertyValue="checkbox-unique-id-81";
    @api lines;
    @api workorderids;
    @api productids;
    modifiedIds;
    deletelines=[];
    showDelete=true;
    productCode = '';
    productName = '';
    @track productList = [];

    isSaving = false;

    @wire(getObjectInfo, {
        objectApiName: WorkOrderLineItem_object
    })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: Trabajo__c
    })
    picklistValues;

    @wire(getWorkOrderListMethod,{ caseId: '$recid' })getWOLM({ error, data}){
        if(data){
            this.relatedWorkOrderList = data;
            console.log('Wired correctly!! id ' + this.recid);
        }
        else if(error){
            this.notifyUser('Error', 'Algo no salió bien en el methodo "getWOLM", consulte su administrador', 'error');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        }
    }

    @api async handleSave2() {
        const allValid = [
                    ...this.template.querySelectorAll('lightning-input'),
                ].reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
                }, true);
                if (allValid) {
                    this.isSaving = true;
                    console.log('Before save searchWOId ================> ' + this.workOrderId);
                    saveLines({ listTosave: JSON.stringify(this.productList_test),workorder:this.workOrderId, caseid:this.recid, tipodetrabajoid:this.tipodetrabajoid, tipodetrabajocaso:this.tipodetrabajocaso, origin:"caseWorkTypes", tipodecargo:this.tipodecargo, aseguradora:this.aseguradora, centrodecosto:this.centrodecosto, aliasGenerico:this.nombretrabajo})
                            .then((result) => {
                            this._title = 'Success!';
                            this.message = 'Las líneas de la orden fueron guardadas';
                            this.variant = 'success';
                            this.showNotification();
                            //this.navigateToRelatedList();
                            this.navigateToCase();
                            this.isSaving = false;
                            })
                            .catch((error) => {
                                console.log(error.body.message);
                                this.dispatchEvent(new ShowToastEvent({
                                    title: 'Atención',
                                    message: this.cleanErrorMessage(error.body.message),                                    
                                    variant: 'error',
                                }));                            
                                // this.error = error;
                                // this._title = 'Ups!';
                                // this.message = 'Cantidad de Horas, UT y Alias son campos requeridos.';
                                // this.variant = 'error';                            
                                // this.showNotification();
                                this.isSaving = false;
                        });
                        
                } else {
                    this._title = 'Error!';
                    this.message = 'Revise los campos señalados en ROJO';
                    this.showNotification();
                }
    }

    handlecheckEditMO(event) {
        
        console.log(this.idList.indexOf(currentItem.ID));
        

        /*var indexes;
        var modifiedIndex=this.workorderids.indexOf(event.currentTarget.dataset.id); 
        //console.log(modifiedIndex);
        if(event.target.checked){
            this.deletelines.push(event.currentTarget.dataset.id);
            //console.log("Ingresamos a elimianr"+(modifiedIndex) );

        }else{
            modifiedIndex=this.deletelines.indexOf(event.currentTarget.dataset.id);
            //console.log("Quitamos de eliminar deletelines"+(modifiedIndex) );
            this.deletelines.splice(modifiedIndex, 1);
        }
        this.showDelete=(this.deletelines.length>0);
       indexes=this.deletelines;
       //console.log(indexes);*/
    }

    //  Apex Calls------------------------------------------------------------------------------------------------------------------------------------

    searchProductAction() {

        var searchinput = this.template.querySelector("lightning-input").value;
        const parametersMO = {}; // Mano de obra
        const parametersWO = {}; // Work Order
        parametersMO["productType"] = 'Mano de Obra';
        parametersMO["productName"] = searchinput;
        parametersMO["workOrder"] = this.workOrderId;

        parametersWO["caseIdentificator"] = this.recid;
        searchWOId(parametersWO)
            .then((result) => {
                this.workOrderId = result;
                this.selectedrows = this.idList;
            })
            .catch((error) => {
                this.error = error;
            });

        searchMO(parametersMO)
            .then((results) => {
                this.productList_test = results;
            })
            .catch((error) => {
                this.notifyUser('Error', 'Algo no salió bien, consulte su administrador', 'error');
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    selectWorkOrder(){
        // var selectedWo = this.template.querySelector("lightning-datatable").getSelectedRows();
        // console.log('selectedRecords are ', selectedWo);
        var selectedWo = this.template.querySelector("lightning-datatable").getSelectedRows();
        if(selectedWo.length > 0){
            console.log('selectedRecords are ', selectedWo);
   
            let ids = '';
            selectedWo.forEach(currentItem => {
                ids = ids + ',' + currentItem.Id;
            });
            this.slctdIds = ids.replace(/^,/, '');
        }
        
        this.quantityWOselected = selectedWo.length;
        this.workOrderId = this.slctdIds;
        console.log('workOrderId: ' + this.workOrderId);
    }

    selectProducts() {
        var selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
        var localIdList = []
        var localworkOrderList = []
        if (selectedRecords) {
            //console.log('selectedRecords are ', selectedRecords);
            let ids = '';
            selectedRecords.forEach(currentItem => {
                currentItem = JSON.parse(JSON.stringify(currentItem));

                if (this.idList.indexOf(currentItem.ID) == -1) {
                    currentItem.originalId = currentItem.ID;
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

    // Navigation Controllers ------------------------------------------------------------------------------------------------------------------------------------

    backToSelectMO(){
        this.thirdScreen=false;
        this.secondScreen=true;
        this.quantityWOselected = 0;
        this.deletelines=[];
        this.showDelete=true;
        this.productList_selected = this.productList_test;
    }

    backToSelectWO(){
        if(this.relatedWorkOrderList.length > 1){
            this.thirdScreen = true;
        }else{
            this.secondScreen = true;
        }
        this.fourthScreen=false;
        this.deletelines=[];
        this.showDelete=true;
        this.productList_selected = this.productList_test;
    }

    handleNavigate(data) {
        if(this.quantityselected && this.quantityselected > 0){
            if (this.visibleFlag) {
                this.visibleFlag = false;
            } else {
                this.visibleFlag = true;
            }
            this.watchSelectedItems();
            
            console.log('WOL : ' + this.relatedWorkOrderList);
            console.log('WOL lenght: ' + this.relatedWorkOrderList.length);
            if(this.relatedWorkOrderList.length > 1){
                this.thirdScreen=true;
            }else{
                console.log('Only one work order: ' + this.relatedWorkOrderList[0].Id);
                this.workOrderId = this.relatedWorkOrderList[0].Id;
                this.fourthScreen = true;
            }
            this.secondScreen=false;
            this.selectedRows = this.productList_selected;
            this.productList_test = this.productList_selected;
        }else{
            const toastEvent = new ShowToastEvent({ title: 'Atención', message: 'Favor de seleccionar al menos 1 producto.', variant: 'error' });
            this.dispatchEvent(toastEvent);
        }
    }

    handleAddWorkOrder(){
        //logica agregar la work order
        this.thirdScreen = false;
        this.fourthScreen = true;
    }

    watchSelectedItems() {
        this.productList_test = this.productList_selected;
    }

    showNotification() {
        const evt = new ShowToastEvent({
            title: this._title,
            message: this.message,
            variant: this.variant,
        });
        this.dispatchEvent(evt);
    }

    navigateToRelatedList() {
        // Navigate to the CaseComments related list page
        // for a specific Case record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.workOrderId,
                objectApiName: 'WorkOrder',
                relationshipApiName: 'WorkOrderLineItems',
                actionName: 'view'
            }
        });
    }


    // Handle Methods----------------------------------------------------------------------------------------------------------------------------------------------

    handleApproval(event){
        var modifiedIndex=this.workorderids.indexOf(event.currentTarget.dataset.id); 
        this.modifiedList[modifiedIndex].aprobado=event.detail.checked;
        }

    handleDiscount(event) {
        var modifiedIndex = this.idList.indexOf(event.currentTarget.dataset.id); 
        let tempPickList  = JSON.parse(JSON.stringify(this.productList_test));
        tempPickList[modifiedIndex].discount = event.currentTarget.value;
        this.productList_test = tempPickList;
        tempPickList = [];
     }

     handleQuantity(event) {
        var modifiedIndex = this.idList.indexOf(event.currentTarget.dataset.id); 
        let tempPickList  = JSON.parse(JSON.stringify(this.productList_test));
        let UTData = (60/5) * (event.currentTarget.value);

        tempPickList[modifiedIndex].cantidad = event.currentTarget.value;
        tempPickList[modifiedIndex].UT = UTData.toFixed(3); // Convierte el resultado en UTs
        this.productList_test = tempPickList;
        tempPickList = [];
     }

     handleAlias(event) {
        var modifiedIndex = this.idList.indexOf(event.currentTarget.dataset.id); 
        let tempPickList  = JSON.parse(JSON.stringify(this.productList_test));
        tempPickList[modifiedIndex].alias = event.currentTarget.value;
        this.productList_test = tempPickList;
        tempPickList = [];
     }

     handleUT(event){
        var modifiedIndex = this.idList.indexOf(event.currentTarget.dataset.id); 
        let tempPickList = JSON.parse(JSON.stringify(this.productList_test));
        let cantidadData = ((event.currentTarget.value) * 5) / 60;
        tempPickList[modifiedIndex].cantidad = cantidadData.toFixed(3); // Convierte el resultado en Horas.
        tempPickList[modifiedIndex].UT = event.currentTarget.value;
        this.productList_test = tempPickList;
        tempPickList = [];
     }

     handleDeleteLineEditMO(event) {
        
        var listaIds = this.productList_test;
        var records;
        const lines = 5;
        this.deletelines.forEach(currentItem => {
            this.productList_test.splice(this.idList.indexOf(currentItem), 1);
            //this.productList_selected.splice(this.idList.indexOf(currentItem), 1);
            this.idList.splice(this.idList.indexOf(currentItem), 1); 
        });

        let tempPickList  =JSON.parse(JSON.stringify(this.productList_test)); 
        this.selectedRows = tempPickList;
        this.productList_test=tempPickList;
        this.deletelines=[];
        this.showDelete=!(this.deletelines.length>0);
        this.quantityselected=this.idList.length;
    }

    handleDeleteLine(event) {
        this.workOrderList = event.detail.deletedRecords;
        this.idList = event.detail.deletedIds;
        this.quantityselected = this.idList.length;
    }

    handlecheck(event) {
        var indexes;
        var modifiedIndex=this.idList.indexOf(event.currentTarget.dataset.id); 
        if(event.target.checked){
            this.deletelines.push(event.currentTarget.dataset.id);
        }
        else{
            modifiedIndex=this.deletelines.indexOf(event.currentTarget.dataset.id);
            this.deletelines.splice(modifiedIndex, 1);
        }
        this.showDelete=!(this.deletelines.length>0);
       indexes=this.deletelines;
    }

    handleCloneLineEditMO(event) {
        var listaIds = [... this.productList_test];
        listaIds = JSON.parse(JSON.stringify(listaIds));
        var records;
        const lines = 5;

        //deleted items contiene los items seleccionados
        let cloneItemsConta = listaIds.length;
        this.deletelines.forEach(currentItem => {
            cloneItemsConta++;
            var newRow = listaIds[this.idList.indexOf(currentItem)];
            newRow.ID = newRow.originalId+'-DUP-'+ cloneItemsConta;
            newRow.dupstatus = 'Duplicated';
            this.productList_test.push(newRow);
            this.idList.push(newRow.ID);
            //this.productList_test.push(this.idList.indexOf(currentItem), 1);
            //this.productList_selected.splice(this.idList.indexOf(currentItem), 1);
            //this.idList.push(this.idList.indexOf(newRow.Id)); 
        });

        let tempPickList = JSON.parse(JSON.stringify(this.productList_test)); 
        //this.selectedRows = tempPickList;
        this.productList_test = tempPickList;
        //this.deletelines=[];
        //this.quantityselected=this.idList.length;
    }

    handleSave() {
        this.handleSave2();
    }
    
    notifyUser(title, message, variant) {
        if (this.notifyViaAlerts) {
            alert(`${title}\n${message}`);
        } else {
            const toastEvent = new ShowToastEvent({ title, message, variant });
            this.dispatchEvent(toastEvent);
        }
    }

    cleanErrorMessage(message){
        return message.replace('Upsert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Insert failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING,', '');
    }
    navigateToCase() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recid,
                actionName: 'view'
            }
        });
    }
}