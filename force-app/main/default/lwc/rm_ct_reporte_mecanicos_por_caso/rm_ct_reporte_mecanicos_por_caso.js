import { LightningElement,wire } from 'lwc';
import getData from '@salesforce/apex/RM_CT_MecanicosCasos_Ctrl.getData';

export default class Rm_ct_reporte_mecanicos_por_caso extends LightningElement {
 
    records = [];
    mecanicoId = '';

    salesforceURL;
    connectedCallback() {
        this.salesforceURL = window.location.origin;
    }

    wiredWorkOrderResult;
    @wire(getData, { mecanicoId: '$mecanicoId' })
    wiredData(result) {
        this.records = [];
        if (result.data && result.data.records) {
            this.records = result.data.records.map(record => ({
                ...record,
                caseURL: `${this.salesforceURL}/${record.Caso__c}`,
                mecanicoURL: `${this.salesforceURL}/${record.RM_Mecanico__c}`
            }));
        } else if (result.error) {
            // Manejo de errores
            console.error(result.error);
        }
    }
}