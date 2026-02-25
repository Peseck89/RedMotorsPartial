import { LightningElement,api,wire } from 'lwc';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';

export default class CT_Add_Inventario_Preview extends LightningElement {

    _prodXBodItem;

    @api
    oppId;

    flagAddToExistingQuote = false;
    inputQuoteId = null;

    @api brand = null;
    @api model = null;
    @api family = null;
    @api year = null;    

    error;
    quoteOptions = [];
    @wire(getRelatedListRecords, {
        parentRecordId: '$oppId',
        relatedListId: 'Quotes',
        fields: ['Quote.Id','Quote.Name']
    })listInfo({ error, data }) {
        if (data) {            
            this.quoteOptions = data.records.map(item => ({'label':item.fields.Name.value,'value':item.fields.Id.value})); 
            this.error = undefined;
            console.log(this.quoteOptions.length);
        } else if (error) {
            this.error = error;
            this.quoteOptions = [];
        }
    }    

    connectedCallback(){
        
        console.log(this.oppId);
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


    get prodXBodItem(){
        return this._prodXBodItem;
    }

    @api
    set prodXBodItem(value){

        this._prodXBodItem = value;

        this.productCode = value.productCode;
        this.productName = value.productName;
        this.productBrand = value.productBrand;
        this.productModel = value.productModel;
        this.productFamily = value.productFamily;
        this.productVin = value.productVin;
        this.productTipoCombustible = value.productTipoCombustible;
        this.productYear = value.productYear;
        this.productInternalColor = value.productInternalColor;
        this.productExternalColor = value.productExternalColor;
        this.productPriceFantasia = value.productPriceFantasia;
        this.bodegaName = value.bodegaName;

    }

}