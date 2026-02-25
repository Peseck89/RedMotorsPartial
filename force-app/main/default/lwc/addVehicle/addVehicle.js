import { LightningElement,api, track, wire } from 'lwc';
import { reduceErrors } from 'c/ldsUtils';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createQuote from '@salesforce/apex/QuoterController.createQuote';
// import getProductByOppId from '@salesforce/apex/ProductSearcherController.getProductByOppId';

export default class BuscarVehiculo extends LightningElement {

    @track showProductSearcher = true;

    @api
    recordId = null;

    productId = null;

    isLoading = false;

    @api brand = null;
    @api family = null;
    @api model = null;
    @api year = null;
    @api color = null;

    // @wire(getProductByOppId, { oppId: '$recordId' })
    // wiredProduct({ error, data }) {
    //     if (data) {
    //         this.brand = data.brand ? data.brand : null;
    //         this.model = data.model ? data.model : null;
    //         // this.family = data.family ? data.family : null;
    //         this.error = undefined;
    //     } else if (error) {
    //         this.error = error;
    //         this.brand = null;            
    //         this.model = null;
    //         // this.family = null;
    //     }
    // }   

    getOpportunityId(){
        return this.recordId;
    }

    get isDisableAcceptButton(){
        return this.productId == null;
    }
    
    handleAcceptClick(event){
        this.isLoading = true;
        createQuote({
            opportunityId:this.getOpportunityId(),
            prodXBodId:this.productId,
        })
        .then((response)=>{
            this.dispatchEvent(new ShowToastEvent({
                title: 'Agregado a presupuesto',
                message: 'Vehiculo agregado a presupuesto',
                variant: 'success'
            }));
            this.dispatchEvent(new CloseActionScreenEvent());
        })
        .catch((error)=>{/*
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error al crear el presupuesto',
                message: reduceErrors(error).join(', '),
                variant: 'error'
            }));*/         
        })
        .finally(()=>{
            this.isLoading = false;
        });     
    }

    handleCreateSpecialOrderClick(){
        this.showProductSearcher = false;
    }

    get showPedidoEspecialForm(){
        return !this.showProductSearcher;
    }
  
    handleProductSelectionEvent(event){        
        [ this.productId ] = event.detail.products;
    }

    handleCloseWindowEvent(event){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}