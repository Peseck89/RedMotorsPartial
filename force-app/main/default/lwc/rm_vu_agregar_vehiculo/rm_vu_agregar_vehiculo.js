import { LightningElement,api } from 'lwc';
import { reduceErrors } from 'c/ldsUtils';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import addVehicle from '@salesforce/apex/RM_VU_Quote_Ctrl.addVehicle';

export default class Rm_vu_agregar_vehiculo extends NavigationMixin(LightningElement) {
    @api recordId;
    
    isLoading = false;

    prodXBodegaId;
    prodXBodItem;
    
    step = 1;

    brand = '';
    year = '';
    model = '';
    vin = '';    
    internalColor = '';
    externalColor = '';
    tipoCombustible = '';
    bodegaId = '';
    placa = ''; 

    get isStepOne(){
        return this.step == 1;
    }

    get isStepTwo(){
        return this.step == 2;
    }

    handleGoBackClick(event){
        if (this.step > 1) {            
            this.step--;
        }           
    }

    handleContinueClick(event){
        console.log('test test');
        if (this.step < 2) {
            this.step++;
        }
    }

    handleCloseWindowEvent(event){        
        this.dispatchEvent(new CloseActionScreenEvent());        
    }

    handleVehicleSelectionEvent(event){ 
        const selectedRows = event.detail.selectedRows;

        this.brand = event.detail.brand && event.detail.brand != '' ? event.detail.brand : '';
        this.year = event.detail.year && event.detail.year != '' ? event.detail.year : '';
        this.model = event.detail.model && event.detail.model != '' ? event.detail.model : '';
        this.vin = event.detail.vin && event.detail.vin != '' ? event.detail.vin : '';
        this.internalColor = event.detail.internalColor && event.detail.internalColor != '' ? event.detail.internalColor : '';
        this.externalColor = event.detail.externalColor && event.detail.externalColor != '' ? event.detail.externalColor : '';
        this.tipoCombustible = event.detail.tipoCombustible && event.detail.tipoCombustible != '' ? event.detail.tipoCombustible : '';
        this.placa = event.detail.placa && event.detail.placa != '' ? event.detail.placa : '';

        console.log('###########################');
        console.log('====== brand:'+this.brand);
        console.log('====== year:'+this.year);
        console.log('====== model:'+this.model);
        console.log('====== brvinand:'+this.vin);
        console.log('====== internalColor:'+this.internalColor);
        console.log('====== externalColor:'+this.externalColor);
        console.log('====== tipoCombustible:'+this.tipoCombustible);
        console.log('====== placa:'+this.placa);

        for (let index = 0; index < selectedRows.length; index++) {
            this.prodXBodItem = selectedRows[index];       
            this.prodXBodegaId = selectedRows[index].Id;       
        }
    }

    get isVehicleSelected(){
        return this.prodXBodegaId == undefined;
    }

    handleGoToInventoryScreenEvent(){
        this.handleGoBackClick();
        this.prodXBodItem = undefined;
        this.prodXBodegaId = undefined;
        console.log(this.prodXBodItem);
        console.log(this.prodXBodegaId);
    }

    handleAddNewItemEvent(event){
        this.isLoading = true;
        addVehicle({
            oppId: this.recordId,
            prodXBodegaId:this.prodXBodegaId,
            existingQuoteId: event.detail.quoteId,
        })
        .then((response)=>{
            this.dispatchEvent(new ShowToastEvent({
                title: 'Agregado a presupuesto',
                message: 'Vehiculo agregado a presupuesto',
                variant: 'success'
            }));
            this.dispatchEvent(new CloseActionScreenEvent());

            eval("$A.get('e.force:refreshView').fire();");
            console.log(response.quoteId);
            // if (response.quoteId) {
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: response.quoteId,
                        actionName: 'view'
                    }
                });   
            // }
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

}