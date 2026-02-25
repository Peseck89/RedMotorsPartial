// saPlayerHub.js
import { LightningElement, track } from 'lwc';

// TODO: Descomentar cuando el Apex Controller esté listo
// import getMyServiceAppointments from '@salesforce/apex/SaPlayerHubCtrl.getMyServiceAppointments';

export default class SaPlayerHub extends LightningElement {
    @track selectedSaId = '';

    // Opciones hardcodeadas para pruebas
    // TODO: Reemplazar con datos de Apex
    saOptions = [
        { label: 'SA-10763 - Oil Change', value: 'a0B000000000001' },
        { label: 'SA-10764 - Brake Inspection', value: 'a0B000000000002' },
        { label: 'SA-10765 - Tire Rotation', value: 'a0B000000000003' }
    ];

    handleChange(event) {
        this.selectedSaId = event.detail.value;
    }

    // TODO: Descomentar cuando el Apex Controller esté listo
    // connectedCallback() {
    //     this.loadServiceAppointments();
    // }

    // async loadServiceAppointments() {
    //     try {
    //         const data = await getMyServiceAppointments();
    //         // Asegurarse de que data tenga el formato: [{ label: '...', value: '...' }, ...]
    //         this.saOptions = data;
    //     } catch (error) {
    //         console.error('Error loading appointments', error);
    //         // Opcionalmente, mostrar un toast de error al usuario
    //     }
    // }
}