import { LightningElement, track } from 'lwc';
import getKPIs from '@salesforce/apex/KPIEstadoTallerController.getKPIs';

export default class KpiSucursales extends LightningElement {

    @track sucursales = [];

     @track kpis = {
        casosAbiertos: 0,
        casosAbiertosMotos: 0,
        sinUpdate1: 0,
        sinContacto5: 0,
        sinContacto15: 0,
        sucursalConMasRetrasos: '',
        cantidadAlertasSucursal: 0,
        asesoresConMasRetrasos: []
    };

    // Lista fija
    sucursalesFijas = ['Uruca', 'Pinares', 'Escazú', 'Motorrad', 'Otobai'];

    connectedCallback() {
        this.loadKPIs();
    }

    loadKPIs() {
        getKPIs()
            .then(result => {

                const mapa = result.alertasPorSucursal || {};
                this.kpis = result;
                // Construir lista final en el mismo orden
                this.sucursales = this.sucursalesFijas.map((nombre, index) => {
                    return {
                        nombre: nombre,
                        cantidad: mapa[nombre] || 0,
                        clase: `kpi-card card-${index + 1}`
                    };
                });

            })
            .catch(error => {
                console.error('Error al cargar sucursales', error);
                console.log(error);
            });
    }
}
