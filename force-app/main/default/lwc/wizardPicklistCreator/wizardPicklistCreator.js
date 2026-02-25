import { LightningElement, track, api } from 'lwc';

export default class WizardPicklistCreator extends LightningElement {
    @track showStep1 = true;
    @track showStep2 = false;
    @track showStep3 = false;
    @track showStep4 = false;
    @track showStep5 = false;

    //Parameters
    @api typeForm;
    @api recordTypeId;
    @api recordTypeDescripton;
    @api label;
    @api recordTypeApiName;

    //To other Steps
    @track brand = '';
    @track category = '';
    @track group = '';
    @track family = '';

    handleNext(event) {
        console.log('Step '+ event.detail.step);
        console.log('Marca '+ event.detail.brand );
        console.log('Category '+ event.detail.category );
        console.log('Griup '+ event.detail.category );
        console.log('Family '+ event.detail.family );
        const step = event.detail.step;
        if (step === '1') {
            this.brand = event.detail.brand;
            this.showStep1 = false;
            this.showStep2 = true;
        } else if (step === '2') {
            this.category = event.detail.category;
            this.showStep2 = false;
            this.showStep3 = true;
        } else if (step === '3') {
            this.group = event.detail.group;
            this.showStep3 = false;
            this.showStep4 = true;
        }   else if (step === '4') {
            this.family = event.detail.family;
            this.showStep4 = false;
            this.showStep5 = true;
        }
    }

    handlePrevious(event) {
        const step = event.detail.step;
        if (step === 2) {
            this.showStep2 = false;
            this.showStep1 = true;
        } else if (step === 3) {
            this.showStep3 = false;
            this.showStep2 = true;
        }
    }

    handleFinish() {
        // Handle finish logic here
        this.showStep3 = false;
        this.showStep1 = true; // Reset to step 1 or any other logic
    }

}