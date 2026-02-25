import { LightningElement, api, wire, track } from 'lwc';
import getInternalTiposCargo from '@salesforce/apex/TipoCargoApprovalController.getInternalTiposCargo';
import submitForApproval from '@salesforce/apex/TipoCargoApprovalController.submitForApproval';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import hasPendingCentroCostoApproval from '@salesforce/apex/TipoCargoApprovalController.hasPendingCentroCostoApproval';
import { CloseActionScreenEvent } from 'lightning/actions';
import { refreshApex } from '@salesforce/apex';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

export default class EnvioAprobacionCentroCostoWO extends LightningElement {
    @api recordId; // WorkOrder Id

    @track rows = [];
    comment = '';
    @track currencyCode;
    @track hasPendingApproval = false;

    @track isLoading = false;
    @track isVisible = true;

    // para poder refrescar SOLO este wire
    wiredPendingResult;

    @wire(hasPendingCentroCostoApproval, { workOrderId: '$recordId' })
    wiredPending(value) {
        this.wiredPendingResult = value;
        const { data, error } = value;
        if (data !== undefined) {
            this.hasPendingApproval = data;
        } else if (error) {
            this.toast('Error', this.normalizeError(error), 'error');
        }
    }

    // Carga de filas
    @wire(getInternalTiposCargo, { workOrderId: '$recordId' })
    wiredRows({ data, error }) {
        if (data) {
            this.rows = data.map(r => ({ ...r, checked: false }));
            if (this.rows.length > 0 && this.rows[0].currencyIsoCode) {
                this.currencyCode = this.rows[0].currencyIsoCode;
            }
        } else if (error) {
            this.toast('Error', this.normalizeError(error), 'error');
        }
    }

    get hasData() {
        return this.rows && this.rows.length > 0;
    }

    get noData() {
        return this.rows && this.rows.length === 0;
    }

    get disableSubmit() {
        return this.selectedIds.length === 0 ||
            !this.comment ||
            this.comment.trim().length === 0;
    }

    handleCheck(event) {
        const id = event.target.dataset.id;
        const checked = event.target.checked;
        this.rows = this.rows.map(r => (r.id === id ? { ...r, checked } : r));
    }

    handleComment(event) {
        if (event.detail.value != null && event.detail.value !== '') {
            this.comment = event.detail.value;
        } else {
            this.comment = '';
        }
    }

    get selectedIds() {
        const ids = [];
        this.rows.forEach(r => {
            if (r.checked && !r.disableCheck && r.tipoCargoIds) {
                ids.push(...r.tipoCargoIds);
            }
        });
        return ids;
    }

    get total() {
        return this.rows
            .filter(r => r.checked && !r.disableCheck)
            .reduce((sum, r) => sum + (r.precio || 0), 0);
    }

    async handleSubmit() {
        if (this.disableSubmit) {
            this.toast(
                'Faltan datos',
                'Selecciona al menos un tipo de cargo y escribe un comentario.',
                'warning'
            );
            return;
        }

        // 🔎 VALIDACIÓN: centros de costo
        const selectedRows = this.rows.filter(r => r.checked && !r.disableCheck);
        const centros = new Set(selectedRows.map(r => r.centroCostoId));

        if (centros.size > 1) {
            this.toast(
                'Error de validación',
                'No se puede enviar a aprobación líneas de distintos centros de costo. Verifica tu selección.',
                'error'
            );
            return;
        }

        this.isLoading = true;

        try {
            await submitForApproval({
                workOrderId: this.recordId,
                selectedTipoCargoIds: this.selectedIds,
                comment: this.comment
            });

            this.toast('Enviado', 'La orden se envió a aprobación correctamente.', 'success');

            // Limpieza visual local
            this.rows = this.rows.map(r => ({ ...r, checked: false }));
            this.comment = '';

            // ⚠️ Estado local: ya sabemos que quedó con aprobación pendiente
            this.hasPendingApproval = true;

            // ⚡ Refrescar el wire del "hasPending" sin esperar el resultado
            if (this.wiredPendingResult) {
                refreshApex(this.wiredPendingResult);
            }

            // Avisar al framework que el registro cambió (para layout estándar y otros comp.)
            getRecordNotifyChange([{ recordId: this.recordId }]);

            // 🔒 Ocultar el componente y cerrar quick action
            this.isVisible = false;
            this.dispatchEvent(new CloseActionScreenEvent());
        } catch (e) {
            this.toast('Error al enviar', this.normalizeError(e), 'error');
        } finally {
            this.isLoading = false;
        }
    }

    toast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    normalizeError(e) {
        let msg = 'Ocurrió un error inesperado';
        if (e && e.body) {
            msg = e.body.message || msg;
        } else if (e && e.message) {
            msg = e.message;
        }
        return msg;
    }
}