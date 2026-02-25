import { LightningElement,wire,api,track } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { reduceErrors } from 'c/ldsUtils';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi'; 
import getAnticipos from '@salesforce/apex/Registrar_Anticipo_Controller.getAnticipos'; // Replace with your Apex method


export default class Registrar_Anticipo_Presentar extends LightningElement {

    @api
    oppId;

    inputIdentifier;

    records = [];

    @wire(getRecord, { recordId: '$recordId' })
    opportunity;
    
    isPaymentIdentifierValid;

    paymentNotFound;
    
    @wire(getAnticipos, {
        oppId: '$oppId'
    })wiredRecords({ error, data }) {
        console.log('entro');
        
        if (data) {
            console.log(data);
            this.records = data;
        } else if (error) {
            console.error(error);
        }
    }

    handleIdentifierChange(event){
        this.inputIdentifier = event.detail.value;
    }

    get isDisableButton(){
        return this.inputIdentifier == null || this.inputIdentifier.length == 0;
    }

    handleClick(){
        this.dispatchEvent(new CustomEvent('confirmcontinue'));
        
    }
}