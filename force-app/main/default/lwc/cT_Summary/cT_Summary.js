import { LightningElement,track,wire } from 'lwc';
import { reduceErrors } from 'c/ldsUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getData from '@salesforce/apex/CT_Summary_Controller.getData';

export default class CT_Summary extends LightningElement {
    @track vehiclesNotStarted = 0;
    @track vehiclesInProgress = 0;
    isLoading = false;

    wiredDataResult;    
    @wire(getData)
    wiredData(result) {
        this.wiredDataResult = result;
        const { error, data } = result;
        if (data) {
            this.vehiclesNotStarted = data.vehiclesNotStarted ? data.vehiclesNotStarted : 0;
            this.vehiclesInProgress = data.vehiclesInProgress ? data.vehiclesInProgress : 0;
        } else if (error) {            
            this.error = error;   
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Atención',
                    message: reduceErrors(error).join(', '),
                    variant: 'error'
                })
            );      
        }
    }
}