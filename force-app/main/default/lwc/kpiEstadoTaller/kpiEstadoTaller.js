import { LightningElement, track } from 'lwc';
import getKPIs from '@salesforce/apex/KPIEstadoTallerController.getKPIs';

export default class KpiEstadoTaller extends LightningElement {

    @track kpis = {
        casosAbiertos: 0,
        sinUpdate2: 0,
        sinContacto5: 0,
        sucursalConMasRetrasos: '',
        cantidadAlertasSucursal: 0,
        asesoresConMasRetrasos: []
    };

    connectedCallback() {
        this.loadKPIs();
    }

    loadKPIs() {
        getKPIs()
            .then(result => {

                // Asignar KPIs base
                this.kpis = result;

                // Agregar numeración (orden) a asesores
                this.kpis.asesoresConMasRetrasos = result.asesoresConMasRetrasos.map((item, index) => {
                    return {
                        ...item,
                        orden: index + 1
                    };
                });

            })
            .catch(error => {
                console.error('Error loading KPIs:', error);
            });
    }
}