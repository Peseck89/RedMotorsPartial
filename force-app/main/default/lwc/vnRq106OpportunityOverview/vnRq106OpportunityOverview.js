import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getOverview from '@salesforce/apex/VN_RQ106_OpportunityOverviewController.getOverview';

const MAX_TABLE_ROWS = 3;
const MAX_HISTORY_ROWS = 2;

export default class VnRq106OpportunityOverview extends NavigationMixin(LightningElement) {
    @api recordId;
    overview;
    errorMessage;
    isLoading = true;

    @wire(getOverview, { opportunityId: '$recordId' })
    wiredOverview({ data, error }) {
        this.isLoading = false;
        if (data) {
            this.errorMessage = undefined;
            this.overview = this.normalizeOverview(data);
            return;
        }
        if (error) {
            this.overview = undefined;
            this.errorMessage = this.reduceError(error);
        }
    }

    get solicitudes() {
        return this.overview?.solicitudes || [];
    }

    get visibleSolicitudes() {
        return this.solicitudes.slice(0, MAX_TABLE_ROWS);
    }

    get anticiposAprobados() {
        return this.overview?.anticiposAprobados || [];
    }

    get visibleAnticiposAprobados() {
        return this.anticiposAprobados.slice(0, MAX_TABLE_ROWS);
    }

    get historial() {
        return this.overview?.historial || [];
    }

    get visibleHistorial() {
        return this.historial.slice(0, MAX_HISTORY_ROWS);
    }

    get hasSolicitudes() {
        return this.solicitudes.length > 0;
    }

    get hasApprovedAnticipos() {
        return this.anticiposAprobados.length > 0;
    }

    get hasHistory() {
        return this.historial.length > 0;
    }

    get requestCountLabel() {
        return `${this.solicitudes.length} registro(s)`;
    }

    get hasMoreSolicitudes() {
        return this.solicitudes.length > MAX_TABLE_ROWS;
    }

    get solicitudesMoreLabel() {
        return `Ver mas en lista relacionada (${this.solicitudes.length - MAX_TABLE_ROWS} adicionales).`;
    }

    get approvedCountLabel() {
        return `${this.anticiposAprobados.length} registro(s)`;
    }

    get hasMoreApprovedAnticipos() {
        return this.anticiposAprobados.length > MAX_TABLE_ROWS;
    }

    get approvedMoreLabel() {
        return `Ver mas en lista relacionada (${this.anticiposAprobados.length - MAX_TABLE_ROWS} adicionales).`;
    }

    get hasMoreHistory() {
        return this.historial.length > MAX_HISTORY_ROWS;
    }

    get historyMoreLabel() {
        return `Ver mas en lista relacionada (${this.historial.length - MAX_HISTORY_ROWS} adicionales).`;
    }

    get vehicleSummary() {
        const vehicles = this.overview?.vehicles || [];
        if (!vehicles.length) {
            return 'No disponible todavía';
        }
        const firstVehicle = vehicles[0];
        const vin = firstVehicle.vin ? ` / ${firstVehicle.vin}` : '';
        const extra = vehicles.length > 1 ? ` +${vehicles.length - 1}` : '';
        return `${firstVehicle.name || 'Vehiculo'}${vin}${extra}`;
    }

    get opportunityReservationStatus() {
        const stage = this.overview?.stageName || 'Sin estado';
        const reservation = this.overview?.reservaStatus || 'Reserva VN pendiente/producto disponible';
        return `${stage} / ${reservation}`;
    }

    get correctionLabel() {
        return this.overview?.correccionSolicitada ? 'Si' : 'No';
    }

    get integrationLabel() {
        return this.overview?.errorIntegracion ? 'Si' : 'No';
    }

    get retryLabel() {
        return this.overview?.reintentoAutorizado ? 'Si' : this.overview?.retryStatus || 'No disponible todavía';
    }

    get correctionClass() {
        return this.overview?.correccionSolicitada ? 'active' : 'pending';
    }

    get integrationClass() {
        return this.overview?.errorIntegracion ? 'active' : 'pending';
    }

    handleRegisterClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__quickAction',
            attributes: {
                apiName: 'Opportunity.VN_RQ106_Registrar_Ingreso_Anticipo'
            },
            state: {
                recordId: this.recordId
            }
        });
    }

    normalizeOverview(data) {
        const normalizeAnticipo = (item) => ({
            ...item,
            url: `/${item.id}`,
            approverDisplay: item.approverName || 'No disponible todavía'
        });

        return {
            ...data,
            accountName: data.accountName || 'Sin cliente relacionado',
            ownerName: data.ownerName || 'No disponible todavía',
            stageName: data.stageName || 'Sin estado',
            valorTotalOportunidad: data.valorTotalOportunidad || 0,
            totalAnticiposAprobados: data.totalAnticiposAprobados || 0,
            saldoPendiente: data.saldoPendiente || 0,
            currencyIsoCode: data.currencyIsoCode || 'USD',
            vehicles: data.vehicles || [],
            solicitudes: (data.solicitudes || []).map(normalizeAnticipo),
            anticiposAprobados: (data.anticiposAprobados || []).map(normalizeAnticipo),
            historial: (data.historial || []).map((event, index) => ({
                ...event,
                key: `${event.anticipoId}-${index}`,
                comentarioDisplay: event.comentario || 'Sin comentarios registrados',
                usuario: event.usuario || 'No disponible'
            }))
        };
    }

    reduceError(error) {
        if (Array.isArray(error?.body)) {
            return error.body.map((item) => item.message).join(', ');
        }
        return error?.body?.message || error?.message || 'No fue posible cargar VN-RQ106.';
    }
}
