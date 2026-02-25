import { LightningElement,api } from 'lwc';
const currentDate = new Date();
export default class Rm_vn_crear_opp_home_movil extends LightningElement {
    @api brand = 'BMW';
    @api year;

    connectedCallback(){
        this.year = currentDate.getFullYear();
    }
}