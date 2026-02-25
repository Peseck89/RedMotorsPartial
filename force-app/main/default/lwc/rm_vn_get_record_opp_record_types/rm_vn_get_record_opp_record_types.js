import { LightningElement, api, wire } from 'lwc';
import getRecordTypes from '@salesforce/apex/RM_VN_GetOppRecordTypes_Ctrl.getRecordTypes';


export default class Rm_vn_get_record_opp_record_types extends LightningElement {

    recordTypeOptions = [];

    @api selectedRecordTypeId;
    
    @api customVariant = 'label-inline';

    @api isRequired;

    @api emptyOption;

    isLoading = false;

    @api isDisabled = false;

    connectedCallback() {
        this.isLoading = true;
        this.selectedRecordTypeId = this.selectedRecordTypeId && this.selectedRecordTypeId == 'Kawasaki' ? 'kawa' : this.selectedRecordTypeId;
        const selectedRecordTypeEvent = new CustomEvent('isloading', {
            detail: {
                isloading: true
            }
        });
        this.dispatchEvent(selectedRecordTypeEvent);
    }

    @wire(getRecordTypes)
    wiredRecordTypes({error, data}) {
        this.isloading = true
        if (data) {
            // Convert the fetched record types into the format that lightning-combobox expects
            this.recordTypeOptions = data.map(recordType => {
                return {
                    label: recordType.Name.toUpperCase(),
                    value: recordType.DeveloperName
                };
            });

            if(this.emptyOption){
                this.recordTypeOptions.unshift({ label: ' -- Todas -- ', value: '' });
            }

            // Set the first value to selectedRecordTypeId
            if(!this.selectedRecordTypeId && this.recordTypeOptions.length > 0) {
                this.selectedRecordTypeId = this.recordTypeOptions[0].value;
                this.dispatchEventRecordTypeSelected();
            }
        } else if (error) {
            console.error('Error fetching Opportunity record types', error);
        }
        if(data || error){
            this.isLoading = false;
        }
    }

    handleRecordTypeChange(event) {
        this.selectedRecordTypeId = event.detail.value;
        this.dispatchEventRecordTypeSelected();
        console.log('Selected Record Type Id: ' + this.selectedRecordTypeId);
    }
    
    // New method to dispatch the custom event
    dispatchEventRecordTypeSelected(event) {
        const selectedRecordTypeEvent = new CustomEvent('recordtypeselected', {
            detail: {
                recordTypeId: this.selectedRecordTypeId,
                isLoading: false
            }
        });
        this.dispatchEvent(selectedRecordTypeEvent);
    }


    get brandLabel(){
        return this.isloading ? 'Cargando...' : '--- Seleccionar ---';
    }
}