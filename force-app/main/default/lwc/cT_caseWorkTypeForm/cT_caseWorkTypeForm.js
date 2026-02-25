import {LightningElement,track,wire,api} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import Trabajo__c from '@salesforce/schema/WorkOrderLineItem.Trabajo__c';

//crear tipotrabajo desde lwc
import TIPO_TRABAJO from '@salesforce/schema/tiposDeTrabajo__c';
import NAME_FIELD from '@salesforce/schema/tiposDeTrabajo__c.Name';

// Apex Clasess
import search from '@salesforce/apex/SampleLookupController.search';
import getWorkOrders from '@salesforce/apex/TipoTrabajoCasoController.getWorkOrders';
import insertTipoTrabajo from '@salesforce/apex/TipoTrabajoCasoController.insertTipoDelCasoDeTrabajo';
import accountValidation from '@salesforce/apex/AccountValidationController.accountValidation';
import assetValidation from '@salesforce/apex/AssetValidationController.assetValidation';
import assetUpdate from '@salesforce/apex/AssetValidationController.assetUpdate';
import {refreshApex} from '@salesforce/apex';

const DELAY = 100;
const fields = [Trabajo__c];
export default class CT_caseWorkTypeForm extends LightningElement {
    
    myFields = [NAME_FIELD];
    handleSuccessTrabajo(event) {
        const evt = new ShowToastEvent({
            title: 'Registro correcto',
            message: 'Record ID: ' + event.detail.id,
            variant: 'success',
        });
        this.dispatchEvent(evt);
        this.firstScreen = true;
        this.secondScreen = false;
        this.thirdScreen = false;
    }
    handleCancelTrabajo(){
        this.firstScreen = true;
        this.secondScreen = false;
        this.thirdScreen = false;
    }
    handleCrear(){
        this.firstScreen = false;
        this.secondScreen = false;
        this.thirdScreen = true;
    }
    // Use alerts instead of toasts (LEX only) to notify user
    @api notifyViaAlerts = false;
    isMultiEntry = false;
    maxSelectionSize = 2;
    initialSelection = [];
    errors = [];
    
    @api recId;
    productIds = [];
    quantityselected = 0;
    
    selectedRows = [];

    //Added account validation for Email and Phone
    @api accountValidationFlag=false;
    @api accountValidationRequired=false;
    
    accountId;
    contactId;
    isPhysical=false;
    validationObject;
    //JD Chanegs
    showAseguradora = false;
    showCentroCosto = false;

    firstScreen = true;
    secondScreen = false;
    thirdScreen = false;

    tipoDeTrabajo = '';
    @api tipoDeTrabajoId;
    @api tipoDeTrabajoCaso;
    @api centroDeCosto;
    aseguradora ='';
    @api tipoDeCargo;
    sugerenciaTaller='';
    comments='';
    aprobador = '';
    categoriaDePresupuesto = '';
    error;
    myVal;

    //Asset validation variables.
    asset;
    assetId;
    assetValidationFlag = false;
    
    tipoCargoSeleccionado = '';
    formats = [
        'clean'
    ];

    //JD Changes

    // Changes JD

    //Missing logic, needs work...
    /*
        Logic 
     */

    get options() {
        return [{
                label: 'Cliente',
                value: 'Cliente'
            },
            {
                label: 'Garantía',
                value: 'Garantía'
            },
            {
                label: 'BSI',
                value: 'BSI'
            },
            {
                label: 'Aseguradora',
                value: 'Aseguradora'
            },
            {
                label: 'BSI Interno',
                value: 'BSI Interno'
            },
            {
                label: 'Interno',
                value: 'Interno'
            }
        ];
    }
    get optionsAprobador() {
        return [{
                label: 'Cliente',
                value: 'Cliente'
            },
            {
                label: 'Asesor',
                value: 'Asesor'
            }
        ];
    }
    get optionsCategoriaDePresupuesto() {
        return [
            {
                label: 'Urgente',
                value: 'Urgente'
            },
            {
                label: 'Proximo',
                value: 'Proximo'
            },
            {
                label: 'Sugerido',
                value: 'Sugerido'
            }
        ];
    }
    get sugerenciaTallerOptions() {
        return [
            {
                label: 'Urgente',
                value: 'Urgente'
            },
            {
                label: 'Proximo',
                value: 'Proximo'
            },
            {
                label: 'Sugerido',
                value: 'Sugerido'
            }
        ];
    }

    connectedCallback() {
        this.handleAccountValidation();
        this.handleAssetValidation();
    }

    //read workOrder using wire service getWorkOrders
    wiredWorkOrders;
    selectedWorkOrderId;
    workOrdersOptions = [];
    @wire(getWorkOrders, { caseId: '$recId' })
    workOrders(result) {
        this.wiredWorkOrders = result;
        if (result.data) {
            this.workOrdersOptions = result.data.map(workOrder => ({
                label: workOrder.WorkOrderNumber,
                value: workOrder.Id
            }));

            if (this.workOrdersOptions && this.workOrdersOptions.length === 1) {
                this.selectedWorkOrderId = this.workOrdersOptions[0].value;
            }
        }
    }

    get showWorkOrderCombo(){
        return this.workOrdersOptions.length > 1;
    }

    handleOrdenSelection(event){
        this.selectedWorkOrderId = event.detail.value;
        console.log('selectedWorkOrderId: ' + this.selectedWorkOrderId);
    }
    
    handleTipoCargoSelection(event) {
        if(this.accountValidationRequired){
            this.handleAccountValidation();
        } 
        console.log("==================");
        console.log("tipo cargo seleccionado: "+event.detail.value);
        console.log("==================");
        if(event.detail.value != null){
            this.tipoCargoSeleccionado = true;
        }
        else{
            this.tipoCargoSeleccionado = false;
        }

        console.log("==================");
        console.log("tipoCargoSeleccionado: "+this.tipoCargoSeleccionado);
        console.log("==================");

        this.showCentroCosto = false;
        this.showAseguradora = false;
        let selection = this.template.querySelector('lightning-combobox[data-id=TipoCargo]').value;
        this.tipoDeCargo = selection;
        if (selection == 'Aseguradora') {
            this.showAseguradora = true;
            this.showCentroCosto = false;
            return;
        }
        if (selection == 'Interno') {
            this.showCentroCosto = true;
            this.showAseguradora = false;
        } 
    }


    /**
     * Handles the lookup search event.
     * Calls the server to perform the search and returns the resuls to the lookup.
     * @param {event} event `search` event emmitted by the lookup
     */
    handleLookupsearch(event) {
        if(this.accountValidationRequired){
            this.handleAccountValidation();
        }
         // this.handleCheckWO();
         const lookupElement = event.target;
         const firedElement = event.target.id;
         // Call Apex endpoint to search for records and pass results to the lookup
        var paramenters = event.detail;
        paramenters["firedElement"] = firedElement;
        paramenters["caseId"] = this.recId;

        search(paramenters)

            .then((results) => {
                lookupElement.setSearchResults(results);
            })
            .catch((error) => {
                this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
        });
    }
    handleAprobadorChange(event){
        this.aprobador = event.target.value;
    }
    handleCategoriaDePresupuestoChange(event){
        this.categoriaDePresupuesto = event.target.value;
    }
    handleNumberChange(event){
        this.comments = event.target.value;
        if(this.accountValidationRequired){
            this.handleAccountValidation();
        }
     }

    handleInsert(event) {
        const parameters = {};
        parameters["caseId"] = this.recId;
        parameters["tipoDeCargo"] = this.tipoDeCargo;
        parameters["sugerenciaTaller"] = "Sugerido";
        parameters["comments"] = this.comments;
        parameters["tipoDeTrabajo"] = this.tipoDeTrabajo["id"];
        parameters["workOrderId"] = this.selectedWorkOrderId;
        parameters["aseguradoraId"] = this.aseguradora;
        parameters["centroCostoId"] = this.centroDeCosto;
        parameters["aprobador"] = this.aprobador;
        parameters["categoriaDePresupuesto"] = this.categoriaDePresupuesto;
        this.tipoDeTrabajoId = this.tipoDeTrabajo["id"];

        insertTipoTrabajo(parameters)
            .then((results) => {
                this.tipoDeTrabajoCaso = results.Id;
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Atención',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
                this.errors = [error];
            });
    }

    handleCheckWO() {
        const parameters = {};
        parameters["caseId"] = this.recId;

        checkIfHasWorkOrder(parameters)
            .then((results) => {
                console.log("results");
                console.log(results);
            })
            .catch((error) => {
                this.existsWorkOrder = false;
                this.notifyUser('Lookup Error', 'No existe una Orden de Trabajo asociada a este caso.', 'error');
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    /**
     * Handles the lookup selection change
     * @param {event} event `selectionchange` event emmitted by the lookup.
     * The event contains the list of selected ids.
     */
    // eslint-disable-next-line no-unused-vars
    handleTipoTrabajoLookupSelectionChange(event) {
        this.checkForErrors();
    }

    handleSubmit() {
        if(!this.accountValidationRequired){
            this.checkForErrors();
            console.log("###########################################");
            console.log("##############              ###############");
            console.log(this.tipoDeTrabajo);
            console.log("###########################################");
            var tipoCargoSeleccionadoValidation = this.template.querySelector('lightning-combobox[data-id=TipoCargo]');
            console.log("tipoCargoSeleccionadoValidation.validity.valid : " + tipoCargoSeleccionadoValidation.validity.valid );
            console.log("value: " + tipoCargoSeleccionadoValidation.value);
            if(!tipoCargoSeleccionadoValidation.validity.valid && this.tipoDeTrabajo != undefined){
                this.notifyUser('Error', 'Favor de seleccionar un tipo de cargo.', 'error');
            }else if (this.errors.length === 0) {
                this.handleInsert();
                this.notifyUser('Success', 'El tipo de trabajo del caso ha sido creado.', 'success');
                this.firstScreen = false;
                this.secondScreen=true;
            }
        }else{this.handleAccountValidation();} 
    }

    validateInput(selection, message){
        try{

            if ((this.isMultiEntry && selection.length > this.maxSelectionSize) || (selection.length === 0) ) {
                this.notifyUser("Error", "Debe ingresar "+message, "error");
                this.errors =["Error ingresando"+message];
                return;
            }
            else{
                return selection;
            }
        }
        
        catch{
            this.notifyUser("Error", "Debe ingresar "+message, "error");
            this.errors =["Error ingresando"+message];
            return;
        }

    }

    checkForErrors() {
        this.errors = [];
        let nodes = this.template.querySelectorAll('c-lookup');
        // var tipoDeTrabajo_ = 
        this.tipoDeTrabajo = this.validateInput(nodes[0].getSelection()[0], "el Tipo de Trabajo");
        
        console.log('tipoDeTrabajo');
        console.log(this.tipoDeTrabajo.title);

        this.tipoCargoSeleccionado = this.tipoDeTrabajo.title;
        this.aseguradora='';
        this.centroDeCosto='';
        if(this.template.querySelector('lightning-combobox[data-id=TipoCargo]').value==='Aseguradora'){
            var aseguradora_ = this.validateInput(nodes[1].getSelection()[0], "la Aseguradora");
            this.aseguradora = aseguradora_.id;
            this.centroDeCosto='';
        }
        if(this.template.querySelector('lightning-combobox[data-id=TipoCargo]').value==='Interno'){
            var centroDeCosto_ = this.validateInput(nodes[1].getSelection()[0], "el Centro de Costo");
            this.centroDeCosto = centroDeCosto_.id;
            this.aseguradora = '';
        }
    }

    notifyUser(title, message, variant) {
        // if (this.notifyViaAlerts) {
        //     alert(`${title}\n${message}`);
        // } else {
            const toastEvent = new ShowToastEvent({
                title,
                message,
                variant
            });
            this.dispatchEvent(toastEvent);
        // }
    }

    handleAccountValidation(){
        if(!this.accountValidationRequired){
            accountValidation({caseId:this.recId})
            .then((result) => {
               
                console.log(JSON.parse(result));
                if(result){
                    var account=JSON.parse(result);
                    this.accountValidationFlag=account.validate;
                    this.accountValidationRequired=account.validate;
                    this.accountId=account.Id;
                    this.contactId=account.ContactId;
                    this.isPhysical=account.isPhysical
                    this.validationObject=account;
                    //console.log(result);
                }
            })
            .catch((error) => {
                console.log(error);
                
            });
        }else{this.accountValidationFlag=true;}
    }

    handleUpdateAccount(event) {
        this.accountValidationFlag=!event.detail.success;
        if(event.detail.action==='Save'){
           this.showNotification('Success','Información actualizada correctamente','success');
           this.accountValidationRequired=false;
        } 
   }
    handleUpdateCase(event) {
        console.log('caso se actualza');
        this.accountValidationFlag=false;
        this.firstScreen = true;
    }
    handleUpdateAsset(event) {
        console.log('asset se actualza');
        this.accountValidationFlag=false;
        this.firstScreen = true;
    }
    handleUpdateContact(event) {
        setTimeout(() => {
        this.accountValidationRequired=false;
        this.handleAccountValidation();
        this.accountValidationFlag=false;
        this.firstScreen = true;
    }, 2000);

    }
    handleUpdatePersonAccount(event) {
        this.accountValidationFlag=false;
        this.firstScreen = true;
    }
    handleUpdateEmpresarialAccount(event) {
        this.accountValidationFlag=false;
        this.firstScreen = true;
    }
   showNotification(title,message,variant) { 
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    handleAssetValidation(){

        assetValidation({caseId : this.recId})
        .then((result) => {
            console.log('Asset Result: ');
            console.log(JSON.parse(result));
            if(result){
                var tempAsset = JSON.parse(result);
                this.assetValidationFlag = tempAsset.assetValidateFlag;
                this.assetId = tempAsset.Id;
                this.asset = tempAsset;
                if(tempAsset.assetValidateFlag)this.firstScreen = false;
            }
        })
        .catch((error) => {
            console.log(error);
        });
    }

    handleErrorAsset(event){

        console.log("handleError event");
        console.log(JSON.stringify(event.detail));
        this.showNotification(event.detail.message,event.detail.detail,'error');
    }

    handleSubmitAsset(event){

        console.log('Entra a handleSubmitAsset');
        var assetTemp = JSON.parse(JSON.stringify(this.asset));
        const inputFields = this.template.querySelectorAll(
			'[data-type="assetField"]'
		);
        if(this.assetValidationFlag && inputFields && event.target.dataset.id === 'Save'){
            inputFields.forEach(field => {
                console.log(field.dataset.name);
                switch(field.dataset.name){
                    case 'Asset_Name':
                        assetTemp.Asset_Name=field.value;
                        break;
                    case 'Asset_Tipo_de_veh_culo__c':
                        assetTemp.Asset_Tipo_de_veh_culo=field.value;
                        break;
                    case 'Asset_Marca_Nvo__c':
                        assetTemp.Asset_Marca_Nvo=field.value;
                        break;
                    case 'Asset_Modelo_Nvo__c':
                        assetTemp.Asset_Modelo_Nvo=field.value;
                        break;
                    case 'Asset_Marca_Otros__c':
                        assetTemp.Marca_Otros=field.value;
                        break;
                    case 'Asset_Modelo_Otros__c':
                        assetTemp.Asset_Modelo_Otros=field.value;
                        break;
                    case 'Asset_Anio__c':
                        assetTemp.Asset_Anio=field.value;
                        break;
                    case 'Asset_NumeroDeChasis__c':
                        assetTemp.Asset_NumeroDeChasis=field.value;
                        break;
                }
                console.log(field.value);
            });
            console.log();
            this.asset = assetTemp;
            console.log('Send to updateAsset()');
            this.updateAsset();
            this.assetValidationFlag = false;
            this.firstScreen = true;
        }
        else{
            this.assetValidationFlag = false;
            this.firstScreen = true;
            this.dispatchEvent(new CustomEvent('updateasset', {
                detail: {
                    success : true,
                    action : event.target.dataset.id
                }
            }));
        }
    }

    updateAsset(){

        assetUpdate({assetWrapper : JSON.stringify(this.asset)})
        .then((result) => {
            console.log('Result in updateAsset');
            console.log(JSON.parse(result));
            this.assetValidationFlag = result;
        })
        .catch((error) => {
            console.log(error);
            this.showNotification('Error',error.body.message[0].message,'error');
        })
        .finally(() => {
            if(this.assetValidationFlag == true){
                this.dispatchEvent(new CustomEvent('updateasset', {
                    detail: {
                        success: true,
                        action: 'Save'
                    }
                }));
                this.assetValidationFlag = false;
            }
            else this.showNotification('Error al actualizar el Asset ');
        });
    }


    get isNextButtonStepOneDisabled(){
        return this.firstScreen && (!this.selectedWorkOrderId && !this.tipoDeTrabajo);
    }

}