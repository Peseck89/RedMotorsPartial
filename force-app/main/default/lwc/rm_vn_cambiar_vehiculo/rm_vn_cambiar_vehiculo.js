import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';


export default class Rm_vn_cambiar_vehiculo extends LightningElement {

    @api recordId;

    /**
     * Vehiculo seleccionado relacionado a la oportunidad
     */
    selectedVehicle;

    /**
     * Vehiculo seleccionado de inventario de acuerdo a disponibilidad
     */    
    selectedInventory;
    
    /**
     * Paso en el que se encuentra actualmente la pantalla
     */
    step = 1;

    get showSelectVehicleScreen(){
        return this.step == 1;
    }

    get showInventarioScreen(){
        return this.step == 2;
    }

    get showConfirmationScreen(){
        return this.step == 3;
    }    

    next(){
        if (this.step < 3) {
            this.step++;
        }
    }

    back(event){
        if (this.step > 1) {
            this.step--;
        }
    }

    hendleInventorySelectionEvent(event){
        this.selectedInventory  = event.detail.selectedVehicles;
    }

    hendleSaveEvent(event){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    get brand(){
        return this.selectedVehicle && this.selectedVehicle.length > 0 && this.selectedVehicle[0].productBrand ? this.selectedVehicle[0].productBrand : null;
    }

    get year(){
        return this.selectedVehicle && this.selectedVehicle.length > 0 && this.selectedVehicle[0].productYear ? this.selectedVehicle[0].productYear : null;
    }
    
    get model(){
        return this.selectedVehicle && this.selectedVehicle.length > 0 && this.selectedVehicle[0].productModel ? this.selectedVehicle[0].productModel : null;
    }
    
    get isDisableAcceptInventarioButton(){
        return !(this.selectedInventory && this.selectedInventory.length > 0);
    }


    handleBackOppLineItemsScreen(event){
        this.back();
        this.selectedVehicle = undefined;
        this.selectedInventory = undefined;
    }

    handleBackInventarioScreen(event){        
        this.back();        
        this.selectedInventory = undefined;
    }

    handleNextInventarioScreen(event){
        this.next();
        this.selectedVehicle = event.detail.oppLineItems;
        this.selectedInventory = undefined;
    }

    handleNextConfirmationScreen(event){
        this.next();
    }    
}