import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class MisOrdenesConPedidoEspecial extends NavigationMixin(LightningElement) {
    connectedCallback() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'WorkOrder',
                actionName: 'list'
            },
            state: {
                filterName: 'MisOrdenesConPedidoEspecialEnCurso'
            }
        });
    }
}