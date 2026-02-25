import { LightningElement, api, wire } from 'lwc';
import getDibujosByCase from '@salesforce/apex/DibujoController.getDibujosByCase';

export default class AnomaliaViewer extends LightningElement {
    @api recId;
    dibujos = [];

    @wire(getDibujosByCase, { caseId: '$recId' })
    wiredDibujos({ error, data }) {
        if (data) {
            this.dibujos = data.map(d => ({
                id: d.dibujoId,
                createdDate: this.formatDate(d.createdDate),
                creadoPor : d.creadoPor,
                imageUrl: d.versionId ? `/sfc/servlet.shepherd/version/download/${d.versionId}` : null
            }));
        } else if (error) {
            console.error('Error al obtener dibujos:', error);
        }
    }

    formatDate(isoString) {
        if (!isoString) return '';
        return isoString.split('T')[0]; 
    }
}