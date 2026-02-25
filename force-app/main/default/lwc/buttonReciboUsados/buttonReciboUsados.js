import { LightningElement, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import My_Resource from '@salesforce/resourceUrl/ImageRU';

export default class ModalPopupLWC extends LightningElement {
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen = true;
    ImageRU = My_Resource;

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        this.dispatchEvent(new CloseActionScreenEvent());
    }

}