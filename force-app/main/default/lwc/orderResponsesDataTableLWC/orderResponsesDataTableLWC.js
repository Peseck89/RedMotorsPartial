import { LightningElement,api,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import {loadStyle} from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import lwcDatatableStyle from '@salesforce/resourceUrl/lightningLWCdataTable'
import syncOrderSoftalnd from '@salesforce/apex/ProductController.syncOrderWithSoftland';
import consultaAseguradora from '@salesforce/apex/ProductController.consultaAseguradora';
import consultaCentroDeCostos from '@salesforce/apex/ProductController.consultaCentroDeCostos';
import actualizaAseguradora from '@salesforce/apex/ProductController.actualizaAseguradora';
import actualizaCentrodeCostos from '@salesforce/apex/ProductController.actualizaCentroCostos';
import getServereOrderResponse from '@salesforce/apex/ProductController.getServereOrderResponse';
import getLastResponses from '@salesforce/apex/ProductController.getLastResponses';
import setSyncFlag from '@salesforce/apex/ProductController.setSyncFlag';
import lastSyncDate from '@salesforce/apex/ProductController.lastSyncDate';

import {FlowNavigationNextEvent  } from 'lightning/flowSupport'
const cols=[{ label: 'Respuesta', fieldName: 'orderResponseURL', type: 'url',typeAttributes: {label: { fieldName: 'ID_Pedido_Softland__c' }, target: '_blank'},initialWidth: 150,wrapText:true },
           // { label: 'Respuesta', fieldName: 'Id', type: 'text', cellAttributes:{class:'datatable-CellColor'}},
            { label: 'Cargo', fieldName: 'Tipo_cargo__c', type: 'text', cellAttributes:{class:'datatable-CellColor'}},
            { label: 'Estado', fieldName: 'Estado__c', type: 'text',  cellAttributes:{class:{fieldName:'statusColor'}}}
           /* { label: 'Fecha Facturación', fieldName: 'Fechay_hora_facturaci_n__c', type: 'date' },
              { label: 'Última modificación', fieldName: 'LastModifiedDate', type: 'date' }*/];
            
export default class OrderResponsesDataTableLWC extends NavigationMixin(LightningElement)  {
//@api responseList=[ { "CreatedById": "0054U000009i0CoQAI", "CreatedDate": "2022-10-13T04:35:29.000Z", "CurrencyIsoCode": "CRC", "Estado__c": "En Proceso", "Fechay_hora_facturaci_n__c": null, "ID_Pedido_Softland__c": "OSPA-000000155233333333333333333333333333333333333333333333333333333333333", "Id": "a357g000001WvuQAAS", "Impuesto__c": "99736", "IsDeleted": false, "LastActivityDate": null, "LastModifiedById": "0054U000009i0CoQAI", "LastModifiedDate": "2022-10-14T00:12:29.000Z", "Name": "A-0063", "Subtotal__c": "767200", "SystemModstamp": "2022-10-14T00:12:29.000Z", "Tipo_cargo__c": null, "Total_Pedido__c": "866936", "Work_Order__c": "0WO7g000000lqIwGAI", "statusColor": "datatable-CellColorStatus" }, { "CreatedById": "0054U000009i0CoQAI", "CreatedDate": "2022-10-14T00:18:11.000Z", "CurrencyIsoCode": "CRC", "Estado__c": null, "Fechay_hora_facturaci_n__c": null, "ID_Pedido_Softland__c": "asdasdadqawqewqe", "Id": "a357g000001WwN3AAK", "Impuesto__c": null, "IsDeleted": false, "LastActivityDate": null, "LastModifiedById": "0054U000009i0CoQAI", "LastModifiedDate": "2022-10-14T00:18:11.000Z", "Name": "A-0066", "Subtotal__c": null, "SystemModstamp": "2022-10-14T00:18:11.000Z", "Tipo_cargo__c": null, "Total_Pedido__c": null, "Work_Order__c": "0WO7g000000lqIwGAI", "statusColor": "datatable-CellColorStatus" } ];
@api responseList;
@api recordId;
@api hasSurvey;
isShowModal = false;
@api disableSoftlandSync = false;
@track data;
@track isShowModal = false;
CostosModal = false;
errorValidacion1 = false;
@api availableActions = [];
@api workOrderNumber;
@api compania;
softlandConfirmation = false;
waitingSoftlandResponse = false;
columns = cols;
lastSyncDateValue;

handleRowSelection(event){
    console.log(JSON.stringify(this.responseList));
    this.responseID=event.detail.selectedRows[0].Id;
}
showLoading(){
    this.waitingSoftlandResponse=true;
}
hideLoading(){
    this.waitingSoftlandResponse=false;
}
connectedCallback() {
    console.log('Disable Sync');
    console.log((this.hasSurvey) ? false:true);
    console.log(this.disableSoftlandSync);
    this.getLastSyncDate();
    this.hasSurvey = ((this.hasSurvey) ? false:true) || this.disableSoftlandSync;
    this.data=this.responseList;
    if(this.data){
        let dataCopy = JSON.parse(JSON.stringify(this.data));
    
                dataCopy.forEach(currentItem => {
                    if(currentItem.Estado__c==='Facturado'){
                        currentItem.statusColor ="slds-text-color_success";
                    }else if(currentItem.Estado__c==='Cancelado')
                    currentItem.statusColor = "slds-text-color_error";
                    else{
                        currentItem.statusColor = "datatable-CellColorStatus";
                    }
                    currentItem.orderResponseURL= '/'+currentItem.Id;
                });
  //              console.log(dataCopy);
        this.data = dataCopy;
    }
}
renderedCallback(){ 
    if(this.isCssLoaded){
        return
    } 

    this.isCssLoaded = true

    loadStyle(this, lwcDatatableStyle).then(()=>{
        console.log("Loaded Successfully")
    }).catch(error=>{ 
        console.log(error)
    });
}

setMessageShow(title,message,variant){
    var mode;
    if (this.variant==='error'||this.variant==='warning'){
        mode='sticky';
    }else{this.mode='dismissible'}
    const evt = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
        mode: mode
    });
    this.dispatchEvent(evt);
}
navigateToOrder() {
    // Navigate to the CaseComments related list page
    // for a specific Case record.
    console.log('redirecting '+this.recordId);
    this.serverResponse();
    
}
hideModalBox() {  
    this.isShowModal = false;
}
handleSaveAse(event) {
    console.log('entro save');
    this.isShowModal = false;
    this.errorValidacion1 = false;
    var nuevaAseguradora = this.template.querySelector('lightning-input-field').value;
    console.log('nuevaAseguradora1 ',nuevaAseguradora);
    actualizaAseguradora({ recordId: this.recordId, aseguradoraId : nuevaAseguradora}) 
    .then((result) => {
    console.log('resultado actualiza', result);
    })
    .catch((error) => {
        console.log(error);
    })

}
handleSaveCos(event) {
    this.CostosModal = false;
    this.errorValidacion1 = false;
    var nuevoCentroCostos = this.template.querySelector('lightning-input-field').value;
    console.log('nuevoCentroCostos ',nuevoCentroCostos);
    actualizaCentrodeCostos({ recordId: this.recordId, centroCostosId: nuevoCentroCostos}) 
    .then((result) => {
    console.log('resultado actualiza', result);
    })
    .catch((error) => {
        console.log(error);
    })

}
//Apex Calls//
handleSoftlandSync() { 
    var errorValidacion=false;
    consultaAseguradora({ recordId: this.recordId}) 
    .then((result) => {
    console.log('resultado aseguradora', result);
    if(result == true){
        errorValidacion = true;
        this.errorValidacion1 = true;
        this.isShowModal = true;
    }
    })
    .catch((error) => {
        console.log(error);
    })
    consultaCentroDeCostos({ recordId: this.recordId}) 
    .then((result) => {
    console.log('resultado costos', result);
    if(result == true){
        errorValidacion = true;
        this.errorValidacion1 = true;
        this.CostosModal = true;
    }

    })
    .catch((error) => {
        console.log(error);
    })
    console.log('isShowModal ',this.isShowModal);
    console.log('his.CostosModal ',this.CostosModal);
    setTimeout(() => {

        console.log('isShowModal 3000 ',this.isShowModal);
        console.log('his. 3000 ',this.CostosModal);
    if(this.isShowModal == false && this.CostosModal == false){
        this.showLoading();

        console.log(this.recordId)
    
        // console.log(JSON.parse(JSON.stringify(this.data)))
        syncOrderSoftalnd({ workorder: this.recordId}) 
                            .then((result) => {
                            //eval("$A.get('e.force:refreshView').fire();");
                            setTimeout(this.navigateToOrder.bind(this),10000);
                            })
                            .catch((error) => {
                                eval("$A.get('e.force:refreshView').fire();");
                                console.log(error);
                            })
        }
    }, 3000);
                           /* .finally(() => {
                                this.hideLoading();
                            });*/
}

serverResponse() {
    getServereOrderResponse({ order: this.recordId}) 
                            .then((result) => {
                            console.log(result);
                            if(result === null){
                                this.setMessageShow('Softland está PROCESANDO el pedido','Espere unos minutos y haga click en CONSULTAR SOFTLAND"','warning');
                            }
                            else if(result.includes('OS')||result.includes('PI')){
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
                                this.setMessageShow('ERROR',error,'error');
                                console.log(error);
                        })
                        .finally(() => {
                            console.log('Finally'); // Finally
                            this.updateSyncFlag();
                            this.hideLoading();
                            if (this.availableActions.find((action) => action === 'NEXT')) {
                                // navigate to the next screen
                                const navigateNextEvent2 = new FlowNavigationNextEvent ();
                                this.dispatchEvent(navigateNextEvent2);
                                ///console.log(JSON.parse(JSON.stringify(this.data)))
                            }
                            eval("$A.get('e.force:refreshView').fire();");
                        });
}

updateSyncFlag() {
   // console.log(JSON.parse(JSON.stringify(this.data)))
   setSyncFlag({ workorder: this.recordId, validate: true}) 
                            .then((result) => {
                            console.log('Actualiza FLAG');
                            })
                            .catch((error) => {
                                console.log('NO Actualizó FLAG');
                                console.log(error);
                            })
}

getLastSyncDate() {
    lastSyncDate({ WorkorderId: this.recordId })
        .then(result => {
            console.log(result);
            var verifyOrder = JSON.parse(result);
            this.lastSyncDateValue = verifyOrder.LastSoftlandResponse;
            this.softlandConfirmation = verifyOrder.SoftlandConfirmation;
        })
        .catch(error => {
            console.log(error);
        });
}

handleGetLastResponses() {
    this.showLoading();
    getLastResponses({orderNumber:this.workOrderNumber, compania:this.compania, workOrder: this.recordId })
        .then(result => {
            console.log('Sincronizado con Softland');
            console.log(result);
            this.softlandConfirmation = result===true;
            
        })
        .catch(error => {
            console.log(error);
            this.setMessageShow('ERROR','Error al Consultar Softland','error');
        })
        .finally(() => {
            console.log('Finally'); // Finally
            this.hideLoading();
            if (this.availableActions.find((action) => action === 'NEXT')) {
                // navigate to the next screen
                const navigateNextEvent2 = new FlowNavigationNextEvent ();
                this.dispatchEvent(navigateNextEvent2);
                ///console.log(JSON.parse(JSON.stringify(this.data)))
            }
            //eval("$A.get('e.force:refreshView').fire();");
        });
}

}