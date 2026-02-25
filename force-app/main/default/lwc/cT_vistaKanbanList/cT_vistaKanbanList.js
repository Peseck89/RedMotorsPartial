import { LightningElement, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
export default class CT_vistaKanbanList extends LightningElement {
    @api records
    @api stage
    @api status;
    handleItemDrag(evt){
        const event = new CustomEvent('listitemdrag', {
            detail: evt.detail
        })
        this.dispatchEvent(event)
    }
    handleDragOver(evt){
        evt.preventDefault()
    }
    handleDrop(evt){
        const event = new CustomEvent('itemdrop', {
            detail: this.stage
        })
        this.dispatchEvent(event)
    }
}