import { LightningElement, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';

import { NavigationMixin } from 'lightning/navigation'
export default class CT_vistaVehiculoHijo extends NavigationMixin(LightningElement) {
    @api tarea
    @api record
    @api strstatus 
    @api status
    get amarillo(){
        return this.record.Semaforo === 'Yellow';
    }
    get verde(){
        return this.record.Semaforo === 'Green';
    }
    get rojo(){
        return this.record.Semaforo === 'Red';
    }
    get azul(){
        return this.record.Semaforo === 'Blue';
    }
    get isSameStage(){
         
        return this.tarea === this.record.Tarea && this.record.Anidado == true;
    }
    navigateOppHandler(event){
        event.preventDefault()
        this.navigateHandler(event.target.dataset.id, 'WorkStep')
    }
    navigateAccHandler(event){
        event.preventDefault()
        this.navigateHandler(event.target.dataset.id, 'Account')
    }
    navigateHandler(Id, apiName) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: Id,
                objectApiName: apiName,
                actionName: 'view',
            },
        });
    }
    itemDragStart(){
        const event = new CustomEvent('itemdrag', {
            detail: this.record.Id
        })
        this.dispatchEvent(event)
    }
}