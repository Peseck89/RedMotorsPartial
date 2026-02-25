import { LightningElement,api } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor'; 
export default class Rm_vn_crear_opp_general extends LightningElement {
    @api brand = 'BMW';
    @api year;
    get isMobile() {
        console.log('FORM_FACTOR ',FORM_FACTOR);
        // 'Small' es para teléfonos y 'Medium' para tabletas (ambos deben cargar el componente móvil)
        return FORM_FACTOR === 'Small' || FORM_FACTOR === 'Medium';
    }
}