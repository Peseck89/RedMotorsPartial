import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class SelectTipoDeCargo extends LightningElement {
    lstSelected = [];
    _selected = [];
    @api recId;
    @track selectitems = [];
    get options() {
        return [
            { label: 'Cliente', value: 'Cliente' },
            { label: 'Garantía', value: 'Garantia' },
            { label: 'BSI', value: 'BSI' },
            { label: 'Aseguradora', value: 'Aseguradora' },
            { label: 'Interno', value: 'Interno' },
            { label: 'BSI Interno', value: 'BSI Interno' },
        ];}

    get selected() {
        return this._selected.length ? this._selected : 'none';
    }

    handleChange(event) {
      var slect=[];
      this._selected = event.detail.value;
      var options=event.target.options;
      var details=event.detail;
      var i,j;
      for(i=0;i<options.length;i++){
            for(j=0;j<details.value.length;j++){
                if(options[i].value==details.value[j]){
                        slect.push(options[i]);
                }
            }
        }
       this.selectitems=slect; 
    }

    handleCrearReporte(data) {
        if (this._selected.length > 0){
            window.open(
                "/apex/WorkorderCargoSeleccionadoPage?id="+this.recId+"&cargosSelected="+this._selected,
                '_blank' // <- This is what makes it open in a new window.
            );
        } else {		         
            this.showToastEvent('Error', 'Seleccione al menos un tipo de cargo!', 'Error');
        }
    } 

    showToastEvent(inputTitle, inputMsg, inputVariant) {
        this.dispatchEvent(new ShowToastEvent({
            title: inputTitle,
            message: inputMsg,
            variant: inputVariant
        }));
    }
}