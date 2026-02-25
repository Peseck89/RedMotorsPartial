import { LightningElement,api } from 'lwc';

export default class Registrar_Anticipo_Confirmar extends LightningElement {

    @api
    identifier;

    @api
    amount = 0;

    handleBackClick(){
        this.dispatchEvent(new CustomEvent('gotostepone'));
    }

    handleContinueClick(){
        this.dispatchEvent(new CustomEvent('confirm'));
    }    
}