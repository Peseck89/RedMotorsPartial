import { LightningElement,api,track, wire } from 'lwc';
import { reduceErrors } from 'c/ldsUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningModal from 'lightning/modal';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import PHONE_FIELD from '@salesforce/schema/Account.Phone';
import PERSON_EMAIL_FIELD from '@salesforce/schema/Account.PersonEmail';
import CEDULA_FIELD from '@salesforce/schema/Account.Cedula__c';
import INVOICE_EMAIL_FIELD from '@salesforce/schema/Account.Invoice_Email__c';
import INVOICE_PHONE_FIELD from '@salesforce/schema/Account.Invoice_Phone__c';
import getRecordTypes from '@salesforce/apex/RM_VU_CrearOportunidad_Ctrl.getRecordTypes';

export default class Rm_vu_crear_opp_acc_form extends LightningModal { 
    @track isLoading = true;

    @track recordTypeSelected = false;

    @api accountId;

    @api selectedRrecordTypeId;

    recordTypeOptions;

    @wire(getRecordTypes)
    wiredRecordTypes({ data, error }) {
        if (data) {
            this.recordTypeOptions = data.map(item => ({'label':item.label,'value':item.value}));

            //Setea el record type por default
            for(let i = 0; i< this.recordTypeOptions.length;i++){
                if ((this.recordTypeOptions[i].label == 'Cuenta personal' || this.recordTypeOptions[i].label == 'Person Account')) {
                    this.selectedRrecordTypeId = this.recordTypeOptions[i].value;  
                }
            }

        }
    }      

    fields = [NAME_FIELD,PHONE_FIELD,PERSON_EMAIL_FIELD,CEDULA_FIELD,INVOICE_EMAIL_FIELD,INVOICE_PHONE_FIELD];


    handleCancelEvent(event) {
        this.close('cancelled');
    }

    handleSuccessEvent(event){
        this.accountId = event.detail.id;

        // this.disableClose = false;
        this.isLoading = false;
        this.close({accountId: this.accountId});
    }
    
    handleLoadEvent(event){
        this.isLoading = false;
    }

    handleSubmitEvent(event){
        this.isLoading = true;
        // this.disableClose = true;
    }

    handleErrorEvent(event){
        console.log('Error');
        console.log(event.detail);
        // this.dispatchEvent(new ShowToastEvent({
        //     title: 'Error al agregar el nuevo item',
        //     message: reduceErrors(error).join(', '),
        //     variant: 'error'
        // }));   

        this.isLoading = false;
        // this.disableClose = false;
    }
    
    get isRecordTypeSelected(){
        return this.selectedRrecordTypeId && this.recordTypeSelected != null;
    }

    handleRecordTypeSelection(event){
        this.selectedRrecordTypeId = event.detail.value;
    }
    get isBURTSelected() {
        if (this.selectedRrecordTypeId) {
            for (let i = 0; i < this.recordTypeOptions.length; i++) {
                const optionValue = String(this.recordTypeOptions[i].value).trim();
                const optionLabel = String(this.recordTypeOptions[i].label).trim().toLowerCase();    
                if (
                    this.selectedRrecordTypeId === optionValue &&
                    (optionLabel === 'cuenta empresarial' || optionLabel === 'business account')
                ) {
                    console.log('Match found, returning true');
                    return true;
                }
            }
        }
        console.log('No match found, returning false');
        return false;
    }
}