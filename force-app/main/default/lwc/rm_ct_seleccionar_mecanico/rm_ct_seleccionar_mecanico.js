import { LightningElement } from 'lwc';
import LightningModal from 'lightning/modal';
import searchMechanics from '@salesforce/apex/SampleLookupController.searchMechanics';

export default class Rm_ct_seleccionar_mecanico extends LightningModal {

    mechanicInitialSelection = [];
    mechanicSelection = [];
    mechanicErrors = [];

    handleMechanicSearch(event) {
        const lookupElement = event.target;
        var params = event.detail;
        params["firedElement"] = 'Mecánico';
        params["icon"] = 'standard:user';

        searchMechanics(params)
            .then(results => {
                // this.mechanicSelection = result;
                lookupElement.setSearchResults(results);
            })
            .catch(error => {
                this.mechanicErrors = error;
            });
    }

    handleMechanicSelectionChange(event) {
        this.mechanicSelection = event.detail;
    }

    handleAccept() {
        this.close(
            {
                //propagar el mecanico seleccionado this.mechanicSelection, solo la posicion 0, usa destructuring
                mechanic: this.mechanicSelection[0]
            }
        );
    }
}