import { LightningElement,api,wire } from 'lwc';
import getQuotes from '@salesforce/apex/RM_VU_Quote_Ctrl.getQuotes';
import { refreshApex } from '@salesforce/apex';

export default class Rm_vu_agregar_vehiculo_preview extends LightningElement {

    @api
    prodXBodItemId;

    @api
    prodXBodItem;

    @api
    oppId;

    flagAddToExistingQuote = false;
    inputQuoteId = null;

    error;
    quoteOptions = [];
    quoteResult;
    // @wire(getRelatedListRecords, {
    //     parentRecordId: '$oppId',
    //     relatedListId: 'Quotes',
    //     fields: ['Quote.Id','Quote.Name']
    // })listInfo(result) {
    //     this.quoteResult = result;
    //     if (result.data) {
    //         this.quoteOptions = result.data.records.map(item => ({'label':item.fields.Name.value,'value':item.fields.Id.value})); 
    //         this.error = undefined;
    //         console.log(this.quoteOptions.length);
    //     } else if (result.error) {
    //         this.error = error;
    //         this.quoteOptions = [];
    //     }
    // }    

    @api
    refresh(){
        refreshApex(this.quoteResult); 
    }

    connectedCallback(){      
        // console.log('entro');
        this.getQuotesAction();
    }

    getQuotesAction(){
        getQuotes({
            oppId: this.oppId
        })
        .then((data)=>{
            this.quoteOptions = data.map(item => ({'label':item.Name,'value':item.Id})); 
            this.error = undefined;
        })
        .catch((error) => {
            this.error = error;
            this.quoteOptions = [];
        });        
    }

    handleGoBackClick(event){
        this.dispatchEvent(new CustomEvent('gobacktosteptwo')); 
    }

    handleAddItemClick(event){
        this.dispatchEvent(new CustomEvent('addnewitem',{detail:{
                flagNewQuote: this.flagAddToExistingQuote,
                quoteId: this.inputQuoteId
            }
        })); 
    }

    handleQuoteInputChange(event){
        this.inputQuoteId = event.target.value;        
    }    

    get showQuoteInput(){
        return this.flagAddToExistingQuote;
    }

    handleFlagAddToExistingQuoteChange(event){
        this.flagAddToExistingQuote = event.target.checked;
    }

    get hasQuotes(){
        return this.quoteOptions.length > 0;
    }

}