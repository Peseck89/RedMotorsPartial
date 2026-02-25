import { LightningElement,api,wire,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sync from '@salesforce/apex/RM_VN_SyncQuote_Ctrl.sync';
import hasRelatedPlanMttos from '@salesforce/apex/RM_VN_SyncQuote_Ctrl.hasRelatedPlanMttos';

export default class Rm_vn_sync_quote extends NavigationMixin(LightningElement) {
    @api recordId;
    error;
    @track showLoading = false;

    // @wire(hasRelatedPlanMttos, { quoteId: '$recordId' })
    @track flagRelatedAnticipos;
    @wire(hasRelatedPlanMttos, {quoteId:'$recordId' })
    wiredGetHasRelatedPlanMttos({ error, data }) {
        if (data) {
            console.log('@data@');
            console.log(data);
            this.flagRelatedAnticipos = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.flagRelatedAnticipos = false;
        }
    }

    handleClick(event){
        this.showLoading = true;
        sync({quoteId: this.recordId})
        .then((result) => {
            this.showLoading = false;
            const evt = new ShowToastEvent({
                title: 'Sincronización',
                message: 'El presupuesto fue sincronizado exitosamente.',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);

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
            const evt = new ShowToastEvent({
                title: 'Error!!',
                message: error.body.message,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        })
        .finally(()=>{
            this.showLoading = false;
        });
    }
}