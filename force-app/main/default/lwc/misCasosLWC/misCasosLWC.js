import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class MisCasosLWC extends NavigationMixin(LightningElement) {
    connectedCallback() {
        // Redirige inmediatamente al cargar el componente
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Case',
                actionName: 'list'
            },
            state: {
                filterName: 'MisCasosDeTallerEnProceso'
            }
        });
    }
}