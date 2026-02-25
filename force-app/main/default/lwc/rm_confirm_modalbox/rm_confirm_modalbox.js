import { LightningElement, api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class Rm_confirm_modalbox extends LightningModal {
    @api title;
    @api message;

    handleCancel() {
        this.close('cancel');
    }

    handleAccept() {
        this.close('ok');
    }
}