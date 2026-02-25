import { api, wire } from 'lwc';
import { reduceErrors } from 'c/ldsUtils';
import LightningModal from 'lightning/modal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
import agregaComentario from '@salesforce/apex/RM_VN_Inventario_Ctrl.agregaComentario';
import PRODUCT2_COMENTARIO_FIELD from '@salesforce/schema/Product2.RM_Comentario__c';
import PRODUCT2_REPORTADO_FIELD from '@salesforce/schema/Product2.RM_Reportado__c';
import PROD_X_BODEGA_VEHICULO_FIELD from '@salesforce/schema/ProductoXBodega__c.Producto__c';


const PRODXBOD_FIELDS = [
    PROD_X_BODEGA_VEHICULO_FIELD
];

const PRODUCT_FIELDS = [
    PRODUCT2_COMENTARIO_FIELD,
    PRODUCT2_REPORTADO_FIELD
];

export default class Rm_vn_inventario_agregar_comentario extends LightningModal {
    @api recordId;
    isLoading = false;

    vehiculoId;
    comentario = '';
    reportado = false;

    connectedCallback() {
        console.log('recordId', this.recordId);
    }

    @wire(getRecord, { recordId: '$recordId', fields: PRODXBOD_FIELDS })
    prodXBodRecord({ error, data }) {
        console.log('vehiculoRecord', data);
        console.log(data);
        if (data) {
            this.vehiculoId = getFieldValue(data, PROD_X_BODEGA_VEHICULO_FIELD);

        } else if (error) {
            console.error('Error loading user data:', error);
        }
    }

    @wire(getRecord, { recordId: '$vehiculoId', fields: PRODUCT_FIELDS})
    vehiculoRecord({ error, data }) {
        if (data) {
            this.comentario = getFieldValue(data, PRODUCT2_COMENTARIO_FIELD);
            this.reportado = getFieldValue(data, PRODUCT2_REPORTADO_FIELD);
        } else if (error) {
            console.error('Error loading user data:', error);
        }
    }

    handleComentarioChange(event) {
        this.comentario = event.target.value;
    }

    handleReportadoChange(event) {
        this.reportado = event.target.checked;
    }

    handleGuardarComentario() {
        this.isLoading = true;

        console.log('recordId', this.recordId);
        console.log('comentario', this.comentario);
        console.log('reportado', this.reportado);

        agregaComentario({ vehiculoId: this.recordId, comentario: this.comentario, reportado: this.reportado })
            .then(result => {
                this.close();
            })
            .catch(error => {
                this.close();
            })
            .finally(() => {
                this.isLoading = false;
            });
    }   

    get isSaveButtonDisabled() {
        return !this.comentario;
    }

}