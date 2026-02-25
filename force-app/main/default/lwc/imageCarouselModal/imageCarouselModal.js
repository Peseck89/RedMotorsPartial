import { LightningElement, api } from 'lwc';

export default class ImageCarouselModal extends LightningElement {
    @api isOpen = false;
    @api files = [];
    @api selectedId;

    get modalClass() {
        return this.isOpen ? 'slds-modal slds-fade-in-open' : 'slds-hide';
    }

    handleClose() {
        this.isOpen = false;
        this.dispatchEvent(new CustomEvent('close'));
    }
}