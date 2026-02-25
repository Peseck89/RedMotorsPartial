import { api, wire } from 'lwc';
import { reduceErrors } from 'c/ldsUtils';
import LightningModal from 'lightning/modal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import guardar from '@salesforce/apex/RM_VN_CambiarUbicacion_Ctrl.guardar';
import searchBodegas from '@salesforce/apex/RM_VN_CambiarUbicacion_Ctrl.searchBodegas';
import LightningAlert from 'lightning/alert';

const FIELDS = [
    'ProductoXBodega__c.Producto__c',
    'ProductoXBodega__c.Producto__r.Id',
    'ProductoXBodega__c.Producto__r.Name',
    'ProductoXBodega__c.Producto__r.vin__c',
    'ProductoXBodega__c.Bodega__c',
    'ProductoXBodega__c.Bodega__r.Name',
    'ProductoXBodega__c.Disponible__c'
];

export default class Rm_vn_cambiar_ubicacion_modalbox extends LightningModal {
    //Case Id
    @api recordId;
    @api productoXBodega;
    isLoading = false;
    step = 1;

    messageError;

    nuevaUbicacionId = '';

    initialSelection = [];
    errors = [];

    connectedCallback() {
        console.log('recordId: ');
        console.log(this.recordId);
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    productoXBodega;

    get productName() {
        return this.productoXBodega.data ? this.productoXBodega.data.fields.Producto__r.value.fields.Name.value : '';
    }

    get productVin() {
        return this.productoXBodega.data ? this.productoXBodega.data.fields.Producto__r.value.fields.vin__c.value : '';
    }

    get productId() {
        return this.productoXBodega.data ? this.productoXBodega.data.fields.Producto__r.value.fields.Id.value : '';
    }

    get bodegaName() {
        return this.productoXBodega.data ? this.productoXBodega.data.fields.Bodega__r.value.fields.Name.value : '';
    }

    get isStepOne() {
        return this.step === 1;
    }

    get isStepTwo() {
        return this.step === 2;
    }

    handleNextClick(event) {
        this.step++;
    }

    get isSaveButtonDisabled() {
        return this.nuevaUbicacionId == undefined || this.nuevaUbicacionId == '';
    }

    get title() {
        return 'Cambiar ubicación';    
    }

    handleLookupSearch(event) {
        const lookupElement = event.target;
        let params = event.detail;
        params["objName"] = 'Bodega';
        params["icon"] = 'standard:store';
        params["additionalConditions"] = ' AND Id != \'' + this.productoXBodega.data.fields.Bodega__c.value + '\' AND Bodega_vehiculos_nuevos__c = TRUE ';

        searchBodegas(params)
        .then((results) => {
            lookupElement.setSearchResults(results);
            this.bodegas = results;
        })
        .catch((error) => {
        });
    }

    handleSelectionChange(event) {
        if (event.detail && event.detail.length > 0) {
            this.nuevaUbicacionId = event.detail[0];
        } else {
            // Handle the case where the position does not exist
            console.warn('No position found in event.detail');
            this.nuevaUbicacionId = null; // or handle it as needed
        }
        console.log('nuevaUbicacionId: ');
        console.log(this.nuevaUbicacionId);    
    }


    get displayError() {
        return this.messageError && this.messageError.length > 0;
    }

    async handleSaveClick() {
        try {
            this.isLoading = true;
            let response = await guardar({ productoXBodegaOrigenId: this.recordId, bodegaDestinoId: this.nuevaUbicacionId });
            this.close({ success: true, message: response.message });
            console.log('response: ');
            console.log(response);
            this.messageError = undefined;
            this.isLoading = false;
        } catch (error) {
            this.messageError = reduceErrors(error);
            this.isLoading = false;
        }
    }
}