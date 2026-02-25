import { LightningElement,api,wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';  
import OPP_SYNCED_FIELD from '@salesforce/schema/Opportunity.Synced_Quote__c';
import findAnticipos from '@salesforce/apex/Registrar_Anticipo_Controller.findAnticipos';
import findQuotes from '@salesforce/apex/Registrar_Anticipo_Controller.findQuote';
import makeReserva from '@salesforce/apex/ReservaOportunidadController.makeReserva';

const fields = [ 
    OPP_SYNCED_FIELD
];


export default class Registrar_Anticipo extends LightningElement {

    @api recordId;
    
    _loading = false;

    _firstRun = 0;

    _showTieneAnticipos = false;

    _showValidatePaymentScreen = true;

    _showConfirmPaymentScreen = false;    

    _showSelectOpportunityScreen = false;

    identifier;
    
    amount;

    ProduName;

    isPaymentIdentifierValid = false; 
    
    
    @wire(getRecord, { recordId: '$recordId', fields })
    opportunity;
    

    get synced() {

        var tieneSync = false;
        console.log('record');
        console.log(this.recordId);
        console.log(this.opportunity.data);
        //cast string to number, checks amount anticipo greater than 1000            
        findAnticipos({  
            oppId: this.recordId

        }).then((result)=>{
            if(this._firstRun == 0 ){
                console.log(result);
                console.log('entro 1');
                if(result){
                    this._showTieneAnticipos = true;
                    this._showValidatePaymentScreen = false;
                    this._firstRun = 1;
                }
            }            
        })
        .catch((error)=>{

        })
        .finally(() => {
        
        });


    
        return getFieldValue(this.opportunity.data, OPP_SYNCED_FIELD);
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
    
    //Apex Calls//

    handlecheckboxes1() {
        this.showLoading();
        console.log(this.recordId)
        console.log(this.ProduName)
                        
    // console.log(JSON.parse(JSON.stringify(this.data)))
        makeReserva({ opportunity: this.recordId, product2:this.ProduName
                      }) 
                             .then((result) => {
                                console.log(result.selectedProduct);
                                
                                                })
                             .catch((error) => {
                                 eval("$A.get('e.force:refreshView').fire();");
                                 console.log(error);
                            })
                                        
                         }


}