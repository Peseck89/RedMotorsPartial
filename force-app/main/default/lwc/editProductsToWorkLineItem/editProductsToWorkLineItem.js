/*IMPORTS*/
import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import saveLines from '@salesforce/apex/ProductController.saveWorkLineItems';
import getAvailability from '@salesforce/apex/ProductController.getAvailability';
import getServereOrderResponse from '@salesforce/apex/ProductController.getServereOrderResponse';
import getWolis from '@salesforce/apex/ProductController.getWolis';
//import getPriceAccess from '@salesforce/apex/ProductController.getPriceAccess';
import getBetaAccess from '@salesforce/apex/ProductController.getBetaAccess';
import deleteWolis from '@salesforce/apex/ProductController.deleteWolis';
import getWorkOrderDataTableSetting from '@salesforce/apex/ProductController.getWorkOrderDataTableSetting';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues,getObjectInfo } from 'lightning/uiObjectInfoApi';
import Trabajo__c from '@salesforce/schema/WorkOrderLineItem.Trabajo__c';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
//import descuentoGeneral from '@salesforce/schema/WorkOrder.descuentoNivelGeneral__c';  se elimina a petición del cliente
import WorkOrderLineItem_object from '@salesforce/schema/WorkOrderLineItem';
import Id from '@salesforce/user/Id';
import CanDeleteWolis__c from '@salesforce/schema/User.CanDeleteWolis__c';
import CanDeleteWolisMo__c from '@salesforce/schema/User.CanDeleteWolisMo__c';
import CanEditSalePrice__c from '@salesforce/schema/User.Can_edit_sale_price__c';
import CanEditMOPrice__c from '@salesforce/schema/User.Can_edit_MO_price__c';
import WorkOrderNumber from '@salesforce/schema/WorkOrder.WorkOrderNumber';

/*Constants*/
//const fields = [descuentoGeneral]; se elimina a petición del cliente
const COLSSPECIALORDER = [
    { label: 'CÓDIGO', fieldName: 'ProductCode', type: 'text' },
    { label: 'PRODUCTO', fieldName: 'Name', type: 'text' },
    { label: 'LOCALIZACIÓN', fieldName: 'location', type: 'text' },
    { label: 'CANTIDAD SOFTLAND', fieldName: 'softlandQuantity', type: 'text' },
    { label: 'CANTIDAD SOLICITADA', fieldName: 'cantidad', type: 'text' },
];
export default class TargetLwcComponent extends NavigationMixin(LightningElement)  {

    /*Vars*/
    @api propertyValue="checkbox-unique-id-81";
    @api lines;
    @track modifiedList;
    @api workorderids;
    @api productids;
    @api recid;
    @api isLoaded = false;
    @track workOrderSetting;
    developerSettingName = 'WorkOrderDataTable';
    cols=COLSSPECIALORDER
    modifiedIds;
    deletelines=[];
    deleteWolis=[];
    specialOrderIds=[];
    @track specialOrders=[];
    specialOrderQuantity=0;
    showDelete=false;
    showRealAvailability=false;
    showReserveButton=false;
    showReserveWarning=false;
    showPreview=false;
    showModal=false;
    saveOnline=false;
    showModifiedUnitPrice=true;
    showBetaStuff=false;
    alreadyGetLines=false;
    montototal=0;
    currency='CRC';
    idOrder;
    result;
    error;
    _title = '';
    message = '';
    variant = 'error';
    mode = 'dismissible';
    variantOptions = [
        { label: 'error', value: 'error' },
        { label: 'warning', value: 'warning' },
        { label: 'success', value: 'success' },
        { label: 'info', value: 'info' },
    ];
    userId = Id;
    CanDeleteWolis__c;
    CanDeleteWolisMo__c;
    CanEditSalePrice__c;
    CanEditMOPrice__c;
    WorkOrderNumber;

    @wire(getWorkOrderDataTableSetting, { developerName: '$developerSettingName' })
    wiredWorkOrderSetting({ error, data }) {
        if (data) {
            this.workOrderSetting = data;
        } else if (error) {
            console.error(error);

        }
    }

    /*Wired functions*/
    @wire(getRecord, { recordId: Id, fields: [CanDeleteWolis__c,CanDeleteWolisMo__c,CanEditMOPrice__c,CanEditSalePrice__c]}) 
    userDetails({error, data}) {
        if (data) {
            //console.log(data);
            this.CanDeleteWolis__c = data.fields.CanDeleteWolis__c.value;
            this.CanDeleteWolisMo__c = data.fields.CanDeleteWolisMo__c.value;
            this.CanEditMOPrice__c = data.fields.Can_edit_MO_price__c.value;
            this.CanEditSalePrice__c = data.fields.Can_edit_sale_price__c.value;
        } else if (error) {
            this.error = error ;
        }
    }

    @wire(getRecord, { recordId: '$recid', fields: [WorkOrderNumber]}) 
    orderNumber({error, data}) {
        //console.log(this.recid);
        if (data) {
            this.WorkOrderNumber = data.fields.WorkOrderNumber.value;
            
        } else if (error) {
            console.log(error);
            this.error = error ;
        }
    }

    @wire(getObjectInfo, { objectApiName: WorkOrderLineItem_object })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: Trabajo__c
    })
    picklistValues;
    
    /*@wire(getRecord, { recordId: '$recid', fields })
    workOrderFields;*/

    get desc_general() {
        return getFieldValue(this.workOrderFields.data, descuentoGeneral);
    }


    /* Init Callback function */
    connectedCallback() {
        let tempPickList  =JSON.parse(JSON.stringify(this.lines)); 
            tempPickList.map(e =>{
                if(e.productType=='Material'){
                    e.productType='Materiales';
                }
                if( e.productType=='Mano de Obra'){
                    e.cantidadDisponible=1000;
                }
                this.currency=e.currencyCode;
            })
            
            this.modifiedList=tempPickList;

        let tempIdList  =JSON.parse(JSON.stringify(this.workorderids)); 
            this.modifiedIds=tempIdList;
            this.setMontoTotal();
            this.showReserveButton=true;
            this.handleAccess();
            this.validateDeleteUserAccess()
    }


    /* FE Functions */
    handleAccess() {
        getBetaAccess()
        .then((result) => {
            this.showBetaStuff=result;
            //console.log(result);
        })
        .catch((error) => {
            console.log(error);  
        });
    }
    

    handleTrabajo(event) {
        // this.modifiedList=this.lines;
         var modifiedIndex=this.workorderids.indexOf(event.currentTarget.dataset.id); 
         this.modifiedList[modifiedIndex].trabajo=event.currentTarget.value;
         //console.log('You selected an account: ' + event.detail.value);
         
        
     }
    
    handleTipodeTrabajo(event) {
        // this.modifiedList=this.lines;
         var modifiedIndex=this.workorderids.indexOf(event.currentTarget.dataset.id); 
         this.modifiedList[modifiedIndex].tipotrabajo=event.currentTarget.value;
        // console.log('You selected an account: ' + event.detail.value);
         
        
     }
     handleAlias(event) {
       // this.modifiedList=this.lines;
       //console.log(event.currentTarget.dataset.id);
        var modifiedIndex=this.workorderids.indexOf(event.currentTarget.dataset.id); 
        this.modifiedList[modifiedIndex].alias=event.currentTarget.value;
    }

    handleQuantity(event) {
        // this.modifiedList=this.test;
        //console.log(event.detail.value);
         var modifiedIndex=this.workorderids.indexOf(event.currentTarget.dataset.id); 
         this.modifiedList[modifiedIndex].cantidad=event.detail.value;
         this.setMontoTotal();
        
     }
    
    handleQuantityValidation(event) {
        //console.log(event.currentTarget.dataset.id);
        //console.log( JSON.parse(JSON.stringify(this.specialOrders)));
        var specialOrderList= JSON.parse(JSON.stringify(this.specialOrders));
        var modifiedIndex=this.workorderids.indexOf(event.currentTarget.dataset.id); 
        var woliUpdated=this.modifiedList[modifiedIndex];
        var deleteSpecialIndex= this.specialOrderIds.indexOf(event.currentTarget.dataset.id); 
        if(!this.showReserveButton && !woliUpdated.productType.toLowerCase().includes('mano de obra')){
            //var test =JSON.parse(JSON.stringify(this.modifiedList[modifiedIndex]))
           // console.log(test)
            //console.log(JSON.parse(JSON.stringify(this.modifiedList[modifiedIndex])))
            if(woliUpdated.cantidad>woliUpdated.softlandQuantity && woliUpdated.cantidad!=0){
                this.template.querySelector('[data-id="'+event.currentTarget.dataset.id+'"]').className='redClass';
                this.setMessageShow('ADVERTENCIA:','Este artículo no tiene existencias en la localización seleccionada.','warning');
                if(deleteSpecialIndex===-1){
                    this.specialOrderIds.push(event.currentTarget.dataset.id);
                    specialOrderList.push(woliUpdated);
                }    
            }else{
                if(deleteSpecialIndex>-1){
                    specialOrderList.splice(deleteSpecialIndex, 1);
                    this.specialOrderIds.splice(deleteSpecialIndex, 1);
                }
                this.template.querySelector('[data-id="'+event.currentTarget.dataset.id+'"]').className='greenClass';
                //console.log( JSON.parse(JSON.stringify(this.specialOrderIds)));
            }
            this.specialOrders=specialOrderList;
            this.handleSpecialOrderLength();
        }
     }

     handleSpecialOrderLength(){
        this.specialOrderQuantity=this.specialOrderIds.length;
        if(this.specialOrderQuantity>0){
            this.template.querySelector('[data-label="orderQuantity"]').classList.remove('d-none');
        }else{this.template.querySelector('[data-label="orderQuantity"]').className='d-none';
        }
     }

     handleSalePrice(event) {
        // this.modifiedList=this.test;
         var modifiedIndex=this.workorderids.indexOf(event.currentTarget.dataset.id); 
         this.modifiedList[modifiedIndex].unitPrice=event.detail.value;
         this.setMontoTotal();
        
     }
     
     handleDiscount(event) {
        // this.modifiedList=this.lines;
        //console.log(event.detail.value);
         var modifiedIndex=this.workorderids.indexOf(event.currentTarget.dataset.id); 
         this.modifiedList[modifiedIndex].discount=event.detail.value;
         this.setMontoTotal();
        
     }
     handleApproval(event){
     //console.log(event.detail.checked);
     var modifiedIndex=this.workorderids.indexOf(event.currentTarget.dataset.id); 
     this.modifiedList[modifiedIndex].aprobado=event.detail.checked;
     }

    handleSaveOnline(){
        this.saveOnline=true;
        //this.showReserveWarning=!this.showReserveWarning;
        this.handleSave();
    }
    handleshowReserveWarning(){
        this.showReserveWarning=this.specialOrderQuantity>0;
        this.showModal=this.showReserveWarning;
        if(!this.showReserveWarning){
            this.handleSaveOnline();
        }
    }
    handleshowSpecialPreview(){
        if(this.specialOrderQuantity>0){
            this.showPreview=true;
            this.showModal=this.showPreview;
        }
    }
    handleDeleteLine(event) {
        //this.dispatchEvent(new CustomEvent('deleteline'));
        var listaIds;
        var records;
        const lines = 5;//event.target.dataset.factor;
        //console.log("Lista antes"+this.modifiedIds);
        this.deletelines.forEach(currentItem => {
            //console.log("Eliminanod"+currentItem);
            this.modifiedList.splice(this.modifiedIds.indexOf(currentItem), 1);
            this.modifiedIds.splice(this.modifiedIds.indexOf(currentItem), 1);
            this.specialOrders.splice(this.specialOrders.indexOf(currentItem), 1)
            this.specialOrderIds.splice(this.specialOrderIds.indexOf(currentItem), 1);
   
        });
        //console.log("Lista después"+this.modifiedIds);
        this.deletelines=[];
        this.showDelete=(this.deletelines.length>0);
        this.dispatchEvent(new CustomEvent('deleteline', {
        detail: {deletedRecords:this.modifiedList, deletedIds:this.modifiedIds}
        }));

        if(this.deleteWolis.length>0){
            console.log('Eliminando '+this.deleteWolis.length+ 'wolis');
            this.deleteWolisUI();
        }
        this.handleSpecialOrderLength();
    }

    handlecheck(event) {
        var indexes;
        var modifiedIndex=this.workorderids.indexOf(event.currentTarget.dataset.id); 
        //console.log(modifiedIndex);
        if(event.target.checked){
            this.deletelines.push(event.currentTarget.dataset.id);
            console.log("Ies Woli"+(this.modifiedList[modifiedIndex].wolId) );
            if(this.modifiedList[modifiedIndex].wolId){
                this.deleteWolis.push(this.modifiedList[modifiedIndex].wolId);
            }
            //console.log("Ingresamos a elimianr"+(modifiedIndex) );

        }else{
            modifiedIndex=this.deletelines.indexOf(event.currentTarget.dataset.id);
            //console.log("Quitamos de eliminar deletelines"+(modifiedIndex) );
            this.deletelines.splice(modifiedIndex, 1);
            modifiedIndex=this.deleteWolis.indexOf(event.currentTarget.dataset.id);
            this.deleteWolis.splice(modifiedIndex, 1);
        }
        this.showDelete=(this.deletelines.length>0);
       indexes=this.deletelines;
    }

    autoCheckToDelete(IdToDelete, wolId) {
        var modifiedIndex = this.workorderids.indexOf(IdToDelete);
        var isNotSaved = wolId !== undefined ? false: true;
        var isSaved = !isNotSaved;
        if(this.CanDeleteWolis__c && isSaved){
            this.deletelines.push(IdToDelete);
            if(this.modifiedList[modifiedIndex].wolId){
                this.deleteWolis.push(this.modifiedList[modifiedIndex].wolId);
            }
        } else if(isNotSaved){
            this.deletelines.push(IdToDelete);
            if(this.modifiedList[modifiedIndex].wolId){
                this.deleteWolis.push(this.modifiedList[modifiedIndex].wolId);
            }
        }
        this.showDelete=(this.deletelines.length>0);
    }
    navigateToRelatedList() {
        // Navigate to the CaseComments related list page
        // for a specific Case record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recid,
                objectApiName: 'WorkOrder',
                relationshipApiName: 'WorkOrderLineItems',
                actionName: 'view'
            }
        });
    }
    navigateToOrder() {
        // Navigate to the CaseComments related list page
        // for a specific Case record.
        console.log('redirecting '+this.idOrder);
        this.serverResponse();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recid,
                objectApiName: 'WorkOrder',
               // relationshipApiName: 'WorkOrderLineItems',
                actionName: 'view'
            }
        });
        
    }
    setRealVailability(){
        var error=false;
        var productNotAvailable = false;
        var errorMsg=' ';
        this.showRealAvailability=true;
        this.modifiedList.forEach(currentItem => {
            if(currentItem.productType!=undefined){
                if((!currentItem.productType.toLowerCase().includes('mano de obra') && !currentItem.productType.toLowerCase().includes('subcontrato') ) && !currentItem.isClosed){
                    if(!currentItem.validated){             
                        this.template.querySelector('[data-id="'+currentItem.ID+'"]').className='warningClass';
                    }else if(currentItem.available){
                        this.template.querySelector('[data-id="'+currentItem.ID+'"]').className='greenClass';
                    }else{
                        productNotAvailable = true;
                        this.template.querySelector('[data-id="'+currentItem.ID+'"]').className='redClass';
                        this.autoCheckToDelete(currentItem.ID, currentItem.wolId);
                        currentItem.isChecked = this.workOrderSetting.only_available_spare_parts__c;
                        //this.template.querySelector('[data-id="'+currentItem.ID+'"]').className='redClass';
                        if(this.specialOrderIds.indexOf(currentItem.ID)===-1){
                            this.specialOrderIds.push(currentItem.ID);
                            this.specialOrders.push(currentItem);
                            this.handleSpecialOrderLength();
                        }
                    }
                }
            }else{
                error=true;
                errorMsg=errorMsg+' '+currentItem.ProductCode+',';
            } 
        });
        if(productNotAvailable){
            this.showReserveButton = this.workOrderSetting.only_available_spare_parts__c;
        } else{
            this.showReserveButton = false;
        }
        if(!error){
            if(this.specialOrderQuantity>0){
                this.setMessageShow('ADVERTENCIA','Los artículos no tienen existencias en la localización seleccionada.','warning');
            }
        }else{
            this.setMessageShow('ERROR DE CONFIGURACIÓN','Los siguientes articulos'+errorMsg+' no tienen definido el Tipo de Producto','error');
        }
    }

    handleResetAll(){
        
        this.template.querySelectorAll('lightning-input').forEach(element => {
            //console.log(element.name);
        if (element.name==='')
          if(element.type === 'checkbox' || element.type === 'checkbox-button'){
            element.checked = false;
          }else{
            element.value = null;
          }      
        });
      }
    
    setMontoTotal(){
       var monto=0;
       var montoLinea
        this.modifiedList.forEach(currentItem => {
            montoLinea=(currentItem.cantidad*currentItem.unitPrice);
            montoLinea=montoLinea-(montoLinea*(currentItem.discount)/100);
            monto=monto+montoLinea;
        });
        var formatter = new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: this.currency,
          
            // These options are needed to round to whole numbers if that's what you want.
            //minimumFractionDigits: 0, // (this suffices for whole numbers, but will print 2500.10 as $2,500.1)
            //maximumFractionDigits: 0, // (causes 2500.99 to be printed as $2,501)
          });
          this.montototal=formatter.format(monto);
    }

    closeReservar(){
        this.showReserveWarning=false;
        this.showPreview=false;
        this.showModal=false;
     }

    handleLocation(event){
        //console.log(event.detail.value);
        var newLocation=event.detail.value
        var modifiedIndex=this.workorderids.indexOf(event.currentTarget.dataset.id); 
        console.log(modifiedIndex);
        this.modifiedList[modifiedIndex].softlandQuantity=this.modifiedList[modifiedIndex].softlandQuantities[this.modifiedList[modifiedIndex].locations.indexOf(newLocation)];
        this.modifiedList[modifiedIndex].location=newLocation;
        this.handleQuantityValidation(event);
       // console.log( this.modifiedList[modifiedIndex]);
        //console.log(this.modifiedList[modifiedIndex].location);
    }
     // change isLoaded to the opposite of its current value
     toggle() {
        this.isLoaded = !this.isLoaded;
    }
   
    setWoLisIds(){
        var tempIds=[];
        this.lines.forEach(currentItem => {
            tempIds.push(currentItem.ID);
        });
        this.workorderids=JSON.parse(JSON.stringify(tempIds));
        this.validateDeleteUserAccess();
    }

    validateDeleteUserAccess(){
        this.modifiedList.forEach(currentItem => {
            if(currentItem.wolId){
                currentItem.CanDeleteWolis__c = this.CanDeleteWolis__c;
                if(currentItem.productType.toLowerCase()==='mano de obra'){
                    currentItem.CanDeleteWolis__c = this.CanDeleteWolisMo__c;
                }
            }else {
                currentItem.CanDeleteWolis__c = true;
            }
            this.validateEditSalesPriceUserAccess(currentItem);
        });
    }

    validateEditSalesPriceUserAccess(currentItem){
        if(currentItem.productType.toLowerCase()==='mano de obra'){
            currentItem.canEditSalesPrice = currentItem.isClosed ? currentItem.isClosed : !this.CanEditMOPrice__c;
        }else{
            currentItem.canEditSalesPrice = currentItem.isClosed ? currentItem.isClosed : !this.CanEditSalePrice__c;
        }

    }
     
    setMessageShow(title,message,variant){
        this._title = title;
        this.message = message;
        this.variant = variant;
        if (this.variant==='error'||this.variant==='warning'){
            this.mode='sticky';
        }else{this.mode='dismissible'}
        this.showNotification();
    }

    showNotification() {
        const evt = new ShowToastEvent({
            title: this._title,
            message: this.message,
            variant: this.variant,
            mode: this.mode
        });
        this.dispatchEvent(evt);
    }
 
    /* Apex Calls */
    @api async handleSave() {
        this.closeReservar();
        this.toggle();
        console.log('Save');
        console.log(this.modifiedList);
        const allValid = [
                    ...this.template.querySelectorAll('lightning-input'),
                ].reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
                }, true);
                if (allValid) {
                    
                    saveLines({ listTosave: JSON.stringify(this.modifiedList),workorder:this.recid,saveOnline:this.saveOnline}) 
                            .then((result) => {
                                console.log(result);
                                this.idOrder=result;
                                if(!this.handleSave){
                                    this._title = 'Success!';
                                    this.message = 'Las líneas de la orden fueron guardadas';
                                    this.variant = 'success';
                                    this.showNotification();
                                    this.navigateToRelatedList();
                                    //eval("$A.get('e.force:refreshView').fire();");
                                }else{
                                    //Reservar Online con 10s de espera en respuesta
                                    setTimeout(this.navigateToOrder.bind(this), 5000)}
                                })
                            .catch((error) => {
                                console.log(error);
                                console.log(error.body.pageErrors[0].message);
                                this.toggle();
                                this.saveOnline=false;
                                var message = error.body.pageErrors[0].message;
                                this.error = error;
                                this._title = 'Ups!';
                                this.message = 'Algo no salió bien, consulte su administrador';
                                if(message){
                                    this._title  = message;
                                    this.message='';
                                }
                                this.setMessageShow(this._title ,this.message,'error')                           
                                this.showNotification();
                                
                            });
                        
                } else {
                    this.toggle();
                    this._title = 'Error!';
                    this.variant = 'error';
                    this.message = 'Revise los campos señalados en ROJO';
                    this.showNotification();
                    //this.showErrorMessage=true;
                    //alert('Please update the invalid form entries and try again.');
                }

    }

    @api async deleteWolisUI() {
        this.toggle();
        deleteWolis({ listToDelete: JSON.stringify(this.deleteWolis)}) 
                                .then((result) => {
                                this.setMessageShow('Success!','Se eliminaron correctamente las líneas','success');
                                
                                })
                                .catch((error) => {
                                    this.error = error;
                                    this._title = 'Intentelo nuevamente!';
                                    this.message = 'Algo no salió bien, no se pudo eliminar la(s) líneas';
                                    this.variant = 'warning';                            
                                    this.showNotification();
                                    console.log(error);
                            })
                            .finally(() => {
                                this.setRealVailability();
                                this.toggle();
                            });
    }
    
    serverResponse() {
        getServereOrderResponse({ order: this.idOrder}) 
                                .then((result) => {
                                console.log(result);
                                if(result === null){
                                    this.setMessageShow('No se tiene respuesta de Softland','Espere unos minutos y  refresque utilizando el botón del pedido "REFRESCAR"','warning');
                                }
                                else if(result.includes('OSLU')){
                                    this.setMessageShow('Respuesta de Softland CORRECTA',result,'success');
                                }else if(result.toLowerCase().includes('error')){
                                    this.setMessageShow('ERROR en el pedido',result,'error');
                                }
                                
                                })
                                .catch((error) => {
                                    this.error = error;
                                    this._title = 'Ups!';
                                    this.message = 'Algo no salió bien, no se pudo conectar con Softland';
                                    this.variant = 'warning';                            
                                    this.showNotification();
                                    console.log(error);
                            })
                            .finally(() => {
                                try{
                                    setTimeout(location.reload().bind(this),20000);
                                }catch{
                                    console.log('error');
                                }
                            });
    }
    handleGetWolis(){
        this.toggle();
        getWolis({ listTosave: JSON.stringify(this.modifiedList),workorder:this.recid})
                            .then((result) => {
                            this._title = 'Success!';
                            this.message = 'Las líneas se obtuvieron correctamente!';
                            this.variant = 'success';
                            this.alreadyGetLines=true;
                            this.showNotification();
                            this.lines=JSON.parse(JSON.stringify(result));
                            this.setWoLisIds();
                            this.connectedCallback();
                            //console.log(this.lines);
                            this.modifiedList.forEach(currentItem => {
                                currentItem.picklistLocation=([{label:currentItem.location,value:currentItem.location }]);
                            });
                           
                            
                            })
                            .catch((error) => {
                                this.error = error;
                                this._title = 'Ups!';
                                this.message = 'Algo no salió bien, no se pudieron obtener las líneas de la Work Order';
                                this.variant = 'warning';                            
                                this.showNotification();
                                console.log(error);
                        })
                        .finally(() => {
                            this.setRealVailability();
                            this.toggle();
                            this.showReserveButton = true;
                         });
    }

    redStyle='';
    greenStyle='';
    mapData= [];
    validateProducts(){
        this.showRealAvailability=false;
        this.specialOrders = [];
        this.specialOrderIds = [];
        this.specialOrderQuantity = 0;
        this.toggle();
        getAvailability({ listTosave: JSON.stringify(this.modifiedList), workorder:this.recid, workOrderNumber:this.WorkOrderNumber}) 
                            .then((result) => {
                            this._title = 'Verificación con Softland correcta';
                            this.message = 'Los productos marcados en ROJO no están disponibles';
                            this.variant = 'success';
                            this.showNotification();
                            //this.handleResetAll();
                            this.modifiedList=JSON.parse(JSON.stringify(result));
                            console.log(result);
                            var locations;
                            this.modifiedList.forEach(currentItem => {
                                locations=[];
                                for(var key in currentItem.quantityByLocation){
                                    locations.push({label:key,value:key });
                                    this.mapData.push({label:key,value:key });
                                }
                                currentItem.picklistLocation=locations;
                                currentItem.softlandQuantity=currentItem.softlandQuantities[currentItem.locations.indexOf(currentItem.location)];
                                currentItem.available=currentItem.softlandQuantity>=currentItem.cantidad;
                            });
                           //console.log(JSON.parse(JSON.stringify(this.modifiedList)));
                            })
                            .catch((error) => {
                                this.error = error;
                                this._title = 'Ups!';
                                this.message = 'Algo no salió bien, no se pudo conectar con Softland';
                                this.variant = 'warning';                            
                                this.showNotification();
                                console.log(error);
                        })
                        .finally(() => {
                           // console.log('Finally'); // Finally
                            this.setRealVailability();
                            this.toggle();
                            this.validateDeleteUserAccess();
                        });
    }
}