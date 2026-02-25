import { LightningElement,api, track, wire } from 'lwc';
import { reduceErrors } from 'c/ldsUtils';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import addLineItem from '@salesforce/apex/QuoterController.addLineItem';
import getOpportunityByQuote from '@salesforce/apex/ProductSearcherController.getOpportunityByQuote';

export default class AgregarArticuloExtra extends LightningElement {
    isLoading = false;

    @api recordId;
    productId = null;

    @api brand = null;
    @api model = null;
    @api year = null;
    @api color = null;   
    

    @wire(getOpportunityByQuote, { quoteId: '$recordId' })
    wiredOpportunitty({ error, data }) {
        if (data) {
            this.opportunity = data;
            this.brand = data.Marca_de_Veh_culo_Actual__c;
            this.model = data.Modelo_de_Veh_culo_Actual__c;
            this.year = data.aniodelvehiculo__c;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.brand = null;
            this.model = null;
            this.year = null;
            this.color = null;
        }
    }      

    get isDisableAcceptButton(){
        return this.productId == null;
    }

    handleAcceptClick(event){
        this.isLoading = true;
        addLineItem({
            quoteId:this.recordId,
            productId:this.productId,
        })
        .then((response)=>{
            this.dispatchEvent(new ShowToastEvent({
                title: 'Agregado a presupuesto',
                message: 'Vehiculo agregado a presupuesto',
                variant: 'success'
            }));
            this.productId = null;
            this.template.querySelector('c-product-searcher').refresh();
        })
        .catch((error)=>{
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error al crear el presupuesto',
                message: reduceErrors(error).join(', '),
                variant: 'error'
            }));            
        })
        .finally(()=>{
            this.isLoading = false;
        });     
    }
  
    handleProductSelectionEvent(event){        
        [ this.productId ] = event.detail.products;
    }
}