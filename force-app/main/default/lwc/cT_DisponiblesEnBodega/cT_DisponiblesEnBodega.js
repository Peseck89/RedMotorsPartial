import { api, LightningElement, track,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getDisponibles from '@salesforce/apex/CT_DisponiblesBodegaController.getProductosBodega';
const columns = [
    { label: 'Producto', fieldName: 'CT_ProductoNombre__c',type: 'text' },
    { label: 'Código', fieldName: 'CT_ProductoCode__c',type: 'text' },
    { label: 'Precio', fieldName: 'CT_ProductoPrecio__c' ,type: 'text'},
    { label: 'Bodega', fieldName: 'BodegaNombre__c', type: 'text' },
    { label: 'Disponible', fieldName: 'Disponible__c', type: 'text' },
];
export default class CT_DisponiblesEnBodega extends LightningElement {
    data;
    @track datos;
    @track nodata;
    @api recordId;
    columns = columns;
    @wire(getDisponibles , { PresupuestoId: '$recordId' })
    wiredAccount({ error, data }) {
        console.log('Hello '+data);
        if (data) {
            console.log('hay data');
            console.log('data tamanio ',data.length);
            if(data.length >0){
                this.datos = true;
                this.nodata = false;
            }
            else{
                this.nodata = true;
                this.datos = false;
            }
            this.data  = data;
            this.error = undefined;
        } else if (error) {
            console.log('no hay data');
            this.error = error;
            this.data  = undefined;
        }
    }
    get datos(){
        return this.datos;
    }
    get nodata(){
        return this.nodata;
    }

}