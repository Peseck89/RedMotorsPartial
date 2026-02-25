import { LightningElement, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
export default class CT_vistaVehiculoList extends LightningElement {
    @api records
    @api registros
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