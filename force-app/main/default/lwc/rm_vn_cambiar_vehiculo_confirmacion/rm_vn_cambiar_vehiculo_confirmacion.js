import { LightningElement,api } from 'lwc';
import columns from './columns';
import replaceProduct from '@salesforce/apex/RM_VN_CambiarVehiculo_Ctrl.replaceProduct';
import { reduceErrors } from 'c/ldsUtils';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Rm_vn_cambiar_vehiculo_confirmacion extends LightningElement {
    @api appId;

    columns = columns;


    disableNextButton = false;

    isLoading = false;

    /**
     * Vehiculo seleccionado relacionado a la oportunidad
     */
    _selectedVehicle;

    /**
     * Vehiculo seleccionado de inventario de acuerdo a disponibilidad
     */    
    _selectedInventory;

    handleGoBackClick(){
        this.dispatchEvent(new CustomEvent('gobackstep'));
    }

    handleNextStepClick(){
        this.disableNextButton = true;
        this.isLoading = true;
        replaceProduct({
            oliId: this.selectedVehicle[0].Id,
            pxbId: this.selectedInventory[0].Id,
        })
        .then((response)=>{
            new ShowToastEvent({
                title: 'Producto cambiado',
                message: 'El producto a sido cambiado corretamente.',
                variant: 'success'
            })
            eval("$A.get('e.force:refreshView').fire();");
            this.dispatchEvent(new CustomEvent('nextstep'));
        })
        .catch((error)=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error !',
                    message: reduceErrors(error).join(', '),
                    variant: 'error'
                })
            );
        })
        .finally(()=>{
            this.disableNextButton = false;
            this.isLoading = false;
        });
        
    }

    get selectedVehicle(){
        return this._selectedVehicle;
    }

    @api
    set selectedVehicle(value){
        this._selectedVehicle = value;
    }

    get selectedInventory(){
        return this._selectedInventory;
    }

    @api
    set selectedInventory(value){
        this._selectedInventory = value;
    }

    
}