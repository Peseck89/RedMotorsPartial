import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import MY_CUSTOM_OBJECT from '@salesforce/schema/Horas_improductivas_por_mec_nico__c';
import NAME_FIELD from '@salesforce/schema/Horas_improductivas_por_mec_nico__c.Inicio__c';
import FIN_FIELD from '@salesforce/schema/Horas_improductivas_por_mec_nico__c.Fin__c';
import HORA_INICIO from '@salesforce/schema/Horas_improductivas_por_mec_nico__c.Hora_inicio__c';
import HORA_FIN from '@salesforce/schema/Horas_improductivas_por_mec_nico__c.Hora_fin__c';
import OBSERVACIONES_FIELD from '@salesforce/schema/Horas_improductivas_por_mec_nico__c.Observaciones__c';
import TRABAJO_FIELD from '@salesforce/schema/Horas_improductivas_por_mec_nico__c.Tipo_de_Trabajo__c';
import MECANICO_FIELD from '@salesforce/schema/Horas_improductivas_por_mec_nico__c.Mecanico__c';
import ORDEN_FIELD from '@salesforce/schema/Horas_improductivas_por_mec_nico__c.Orden_de_trabajo__c';
import NUMERO_MESES from '@salesforce/schema/Horas_improductivas_por_mec_nico__c.Numero_de_meses__c';

import L from '@salesforce/schema/Horas_improductivas_por_mec_nico__c.L__c';
import K from '@salesforce/schema/Horas_improductivas_por_mec_nico__c.K__c';
import M from '@salesforce/schema/Horas_improductivas_por_mec_nico__c.M__c';
import J from '@salesforce/schema/Horas_improductivas_por_mec_nico__c.J__c';
import V from '@salesforce/schema/Horas_improductivas_por_mec_nico__c.V__c';
import SE_REPITE from '@salesforce/schema/Horas_improductivas_por_mec_nico__c.Se_repite__c';
 
export default class CT_improductivoRecurrente extends LightningElement {
    objectApiName = MY_CUSTOM_OBJECT;
    fields = [NAME_FIELD,FIN_FIELD,HORA_INICIO,HORA_FIN,TRABAJO_FIELD,MECANICO_FIELD,ORDEN_FIELD,OBSERVACIONES_FIELD,SE_REPITE
    ,L,K,M,J,V,NUMERO_MESES];

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
}