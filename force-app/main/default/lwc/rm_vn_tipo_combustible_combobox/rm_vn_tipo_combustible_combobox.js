import { LightningElement, api, wire } from 'lwc';
import getData from '@salesforce/apex/RM_TipoCombustible_Ctrl.getData';

export default class Rm_vn_tipo_combustible_combobox extends LightningElement {

    tipoCombustibleOptions = [];

    selectedTipoCombustible = ''; 

    @wire(getData)
    wiredTipoCombustible({ data, error }) {
        if (data) {
            this.tipoCombustibleOptions = data.map(item => ({'label':item.label,'value':item.value}));
        }
    }

    handleTipoCombustibleChange(event){
        this.selectedTipoCombustible = event.detail.value;
        const selectedEvent = new CustomEvent('selectedtipocombustibleevent', { detail: this.selectedTipoCombustible });
        this.dispatchEvent(selectedEvent);
    }

    get defaultTipoCombustible(){
        return this.selectedTipoCombustible;
    }

    @api
    set defaultTipoCombustible(value){
        if(value){
            this.selectedTipoCombustible = value;
        }
    }
}