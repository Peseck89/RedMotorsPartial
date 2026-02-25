import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getTrabajos from '@salesforce/apex/cT_tiempoIproductivo.getTrabajos'
import getContact from '@salesforce/apex/cT_tiempoIproductivo.getContact'
import MY_CUSTOM_OBJECT from '@salesforce/schema/Horas_improductivas_por_mec_nico__c';
import NAME_FIELD from '@salesforce/schema/Horas_improductivas_por_mec_nico__c.Inicio_de_tiempo_Improductivo__c';
import FIN_FIELD from '@salesforce/schema/Horas_improductivas_por_mec_nico__c.Fin_de_tiempo_Improductivo__c';
import OBSERVACIONES_FIELD from '@salesforce/schema/Horas_improductivas_por_mec_nico__c.Observaciones__c';
import TRABAJO_FIELD from '@salesforce/schema/Horas_improductivas_por_mec_nico__c.Tipo_de_Trabajo__c';
import MECANICO_FIELD from '@salesforce/schema/Horas_improductivas_por_mec_nico__c.Mecanico__c';
import ORDEN_FIELD from '@salesforce/schema/Horas_improductivas_por_mec_nico__c.Orden_de_trabajo__c';

export default class CT_tiempoImproductivo extends LightningElement {
    objectApiName = MY_CUSTOM_OBJECT;

    fields = [NAME_FIELD,FIN_FIELD,TRABAJO_FIELD,MECANICO_FIELD,ORDEN_FIELD,OBSERVACIONES_FIELD];

    handleSuccess(event) {
        this.areDetailsVisible = true;
        const evt = new ShowToastEvent({
            title: 'Registro completo',
            message: 'Record ID: ' + event.detail.id,
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }

    areDetailsVisible = false;

    handleClick(event) {
        this.areDetailsVisible = false;
        eval("$A.get('e.force:refreshView').fire();");
        //this.dispatchEvent(evt);
    }
    //  fechaInicio;
    //  fechaFinal;
    //  tipoTrabajo;
    //  mecanico;
    //  observaciones;

    // @wire(getTrabajos)
    // trabajos

    // @wire(getContact)
    // contactos

    // handleFechaInicio(event){
    //     const searchKey = event.target.value;
    //     this.fechaInicio = searchKey;
    // }
    // handleFechaFinal(event){
    //     const searchKey = event.target.value;
    //     this.fechaFinal = searchKey;
    // }
    // handleTipoTrabajo(event){
    //     const searchKey = event.target.value;
    //     this.tipoTrabajo = searchKey;
    // }
    // handleMecanico(event){
    //     const searchKey = event.target.value;
    //     this.mecanico = searchKey;
    // }
    // handleObservaciones(event){
    //     const searchKey = event.target.value;
    //     this.observaciones = searchKey;
    // }

    // handleGuardar(){
    //     updateRecordMeca({ idRegistro: "$inputEstado" , idMecanicoNuevo: "$inputEstado"  }).then(result => {
    //         const eventp = new ShowToastEvent({
    //             title: 'Mecánico Asignado',
    //             message: 'Mécanico asignado correctamente.',
    //             variant: 'success'
    //         });
    //         this.availableAccounts = this.initialRecords;
    //         this.dispatchEvent(eventp);
    //         refreshApex(this.accountWireResponse);
    //     })
    //     .catch(error => {
    //         const eventp = new ShowToastEvent({
    //             title : 'Error',
    //             message : 'Error asignación no exitosa',
    //             variant : 'error'
    //         });
    //         this.dispatchEvent(eventp);
    //     });
    // }

    

}