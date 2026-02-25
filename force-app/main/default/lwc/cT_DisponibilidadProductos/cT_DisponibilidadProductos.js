import { api, LightningElement, track,wire } from 'lwc';
import RedMotors from '@salesforce/resourceUrl/RedMotors';
import getDisponibilidad from '@salesforce/apex/CT_DisponibilidadBodegaController.getProductosDisponibles';
import getQuote from '@salesforce/apex/CT_DisponibilidadBodegaController.getQuote';

const columns = [
    { label: 'Producto', fieldName: 'Producto',type: 'text' },
    { label: 'Bodega', fieldName: 'Bodega', type: 'text' },
    { label: 'Disponible', fieldName: 'Disponible', type: 'decimal' },
    { label: 'Seleccionados', fieldName: 'Seleccionados', type: 'decimal' }

];
const fields  = [
    'Qoute.BMW_Advertencias__c'
];
export default class CT_DisponibilidadProductos extends LightningElement {
    RedMotorsLogo = RedMotors;
    @api recordId;
    columns = columns;
    @track data; 
    @track data2; 
    @track error2; 
    @track advertencias; 

    @wire(getDisponibilidad , { PresupuestoId: '$recordId' })
    wiredAccount({ error, data }) {
        console.log('Hello '+data)
        if (data) {
            this.data  = data
            this.error = undefined
        } else if (error) {
            this.error = error;
            this.data  = undefined;
        }
    }
    @wire(getQuote, { PresupuestoId: '$recordId' })
    wiredQuote({ error, data }) {
        console.log('data2 '+data)
        if (data) {
            this.data2  = data
            this.advertencias = data.BMW_Advertencias__c

            this.error2 = undefined
        } else if (error) {
            this.error2 = error;
            this.data2  = undefined;
        }
    }
}