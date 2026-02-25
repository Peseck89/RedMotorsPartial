import { LightningElement,api,track,wire } from 'lwc';
import getHistorico from '@salesforce/apex/cT_eventoHistorico_ctrl.getHistorico'; 

const COLS = [
    { label: 'Autor', fieldName: 'Movimiento__c', type: 'text' },
    { label: 'Hora Original', fieldName: 'Hora_Original__c', type: 'text'},
    { label: 'Hora Editada', fieldName: 'Horario_Modificado__c', type: 'text' },
];

export default class HistoricoHorarioEvento_LWC extends LightningElement {
    @api recordId;
    cols = COLS;
    @track data = [];

    @wire(getHistorico, { recordId: '$recordId'})
    wiredAccount({ error, data }) {
        if (data) {
            this.data = data.map(item => ({
                ...item,
                Hora_Original__c: this.formatDateTime(item.Hora_Original__c),
                Horario_Modificado__c: this.formatDateTime(item.Horario_Modificado__c)
            }));
        } else if (error) {
            console.error('Error:', error);
        }
    }

    formatDateTime(dateTimeString) {
        if (!dateTimeString) return '';
        const dateTime = new Date(dateTimeString);
        if (isNaN(dateTime)) return ''; // Handle invalid date

        // Subtract 6 hours
        dateTime.setHours(dateTime.getHours() - 6);
        
        const day = String(dateTime.getDate()).padStart(2, '0');
        const month = String(dateTime.getMonth() + 1).padStart(2, '0');
        const year = dateTime.getFullYear();
        let hours = dateTime.getUTCHours(); // Use getUTCHours to handle timezone
        const minutes = String(dateTime.getUTCMinutes()).padStart(2, '0');
        const ampm = hours >= 12 ? 'PM' : 'AM';
        hours = hours % 12;
        hours = hours ? hours : 12; // the hour '0' should be '12'
        const strTime = hours + ':' + minutes + ' ' + ampm;
        return `${day}/${month}/${year} ${strTime}`;
    }

}