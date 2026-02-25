import { LightningElement,api,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import syncQuote from '@salesforce/apex/RM_SyncQuoteController.syncQuote';

export default class RM_StartSyncing extends NavigationMixin(LightningElement) {
    @api recordId;
    @track error;
    @track showLoading = false;

    handleClick(event){
        this.showLoading = true;
        syncQuote({quoteId: this.recordId})
        .then((result) => {
            this.showLoading = false;
            this.showToast('Sincronización', 'El presupuesto fue sincronizado exitosamente.', 'success', 'dismissable');
            // eval("$A.get('e.force:refreshView').fire();");

            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: result.oppId,
                    objectApiName: 'Opportunity',
                    actionName: 'view'
                }
            });

        }).catch((error) => {
            this.showLoading = false;
            this.showToast('Error!!', error.body.message, 'error', 'dismissable');
        })
        .finally(()=>{
            this.showLoading = false;
        });
    }

    showToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }    
}