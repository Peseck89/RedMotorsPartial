import { LightningElement,api,track,wire } from 'lwc';
import { reduceErrors } from 'c/ldsUtils';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createTiempoImproductivo from '@salesforce/apex/CT_AsignaMecanico.createTiempoImproductivo';

export default class CreateHIMFromTasks extends LightningElement {

    @api workStepIds = [];
    descripcion = null;
    isLoading = false;

    handleDescriptionChange(event){
        this.descripcion = event.target.value;
    }

    handleCloseClick(){
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    handleAcceptClick(){
        createTiempoImproductivo({
            wsIds: this.workStepIds,
            description: this.descripcion
        })
        .then((results) => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Tiempo improductivo registrado',
                message: 'La pausa y el tiempo improductivo se ha registrado correctamente.',
                variant: 'success'
            }))  
            this.isLoading = false;   
            this.dispatchEvent(new CustomEvent('accept'));  
        })
        .catch((error) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Atención',
                    message: reduceErrors(error).join(', '),
                    variant: 'error'
                })
            );  
            this.isLoading = false;     
        });        
    }    


    
}