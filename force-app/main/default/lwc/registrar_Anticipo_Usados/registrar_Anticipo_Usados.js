import { LightningElement,api,wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';  
import OPP_SYNCED_FIELD from '@salesforce/schema/Opportunity.Synced_Quote__c';
import findAnticipos from '@salesforce/apex/Registrar_Anticipo_Controller.findAnticipos';
import findQuotes from '@salesforce/apex/Registrar_Anticipo_Controller.findQuote';

const fields = [
    OPP_SYNCED_FIELD
];

export default class Registrar_Anticipo_Usados extends LightningElement {
    @api recordId;

    _loading = false;

    _firstRun = 0;

    _showTieneAnticipos = false;

    _showValidatePaymentScreen = true;

    _showConfirmPaymentScreen = false;    

    _showSelectOpportunityScreen = false;

    _isSync = false;

    identifier;
    
    amount;

    isPaymentIdentifierValid = false;    

    @wire(getRecord, { recordId: '$recordId', fields })
    opportunity;

    get synced() {
        return this._isSync;
    }

    get showTieneAnticipos(){
        return this._showTieneAnticipos;        
    }   

    get showSearchPaymentScreen(){
        return this._showValidatePaymentScreen;        
    }    

    get showConfirPaymentScreen(){
        return this._showConfirmPaymentScreen;
    }

    get showSelectOpportunityScreen(){
        return this._showSelectOpportunityScreen;
    }    

    get isLoading(){
        return this._loading;
    }

    connectedCallback() {
        
    }

    handlePaymentValidatedEvent(event){
        this.identifier = event.detail.identifier;
        this.amount = event.detail.amount;
        if(this.amount > 0){
            this._showValidatePaymentScreen = false;
            this._showConfirmPaymentScreen = true;    
            this._showSelectOpportunityScreen = false;
        }

        console.log('handlePaymentValidatedEvent');
        console.log(event.detail);
    }

    handlConfirmContinue(){      
        console.log('entro hanlde');  
        this._showTieneAnticipos = false;
        this._showValidatePaymentScreen = true;   
    }
    
    handleConfirmEvent(){        
        this._showValidatePaymentScreen = false;
        this._showConfirmPaymentScreen = false;    
        this._showSelectOpportunityScreen = true;
    }
    
    handlCloseEvent(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleShowLoadingEvent(event){
        console.log('show');
        this._loading = true;
    }   

    handleHideLoadingEvent(event){
        console.log('hide');
        this._loading = false;
    }      

    handlGoToStepOneEvent(event){
        this._showValidatePaymentScreen = true;
        this._showConfirmPaymentScreen = false;    
        this._showSelectOpportunityScreen = false;
    }

    handlGoToStepTwoEvent(event){
        this._showValidatePaymentScreen = false;
        this._showConfirmPaymentScreen = true;    
        this._showSelectOpportunityScreen = false;
    }

    @wire(findAnticipos, { oppId: '$recordId' })
    wiredFindAnticipos({ error, data }) {
        if (data) {
            if (this._firstRun === 0) {
                console.log(data);
                console.log('entro 1');
                if (data) {
                    this._showTieneAnticipos = true;
                    this._showValidatePaymentScreen = false;
                    this._firstRun = 1;
                }
            }
        } else if (error) {
            console.error(error);
        }
    }

    @wire(findQuotes, { oppId: '$recordId' })
    wiredFindQuotes({ error, data }) {
        if (data) {
            console.log(data);
            console.log('entro 2');
            if (data) {
                console.log('dentro del if');
                console.log(this._isSync);
                this._isSync = true;
                console.log('salio del if');
                console.log(this._isSync);
            }
            console.log('salio');
            console.log(this._isSync);
        } else if (error) {
            console.error(error);
        }
    }
}