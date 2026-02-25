import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class MisOrdenesReprogramadas extends NavigationMixin(LightningElement) {
    connectedCallback() {
        // Redirige inmediatamente al cargar el componente
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'WorkOrder',
                actionName: 'list'
            },
            state: {
                filterName: 'MisOrdenesReprogramadas'
            }
        });
    }
}