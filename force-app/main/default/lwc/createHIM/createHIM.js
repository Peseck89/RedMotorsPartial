import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CreateHIM extends LightningElement {
    
    @api inputMechanicId = null;    

    isLoading = false;
    
    closeModal(event){
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    handleSuccessEvent(event){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Tiempo improductivo registrado',
                message: 'El tiempo improductivo ha sido registrado correctamente.',
                variant: 'success'
            })
        );
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    handleSubmitEvent(event){
        // this.isLoading = true;
    }
}