import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

import validateQuoteData from '@salesforce/apex/QuoteApprovalController.validateQuoteData';
import submitForApproval from '@salesforce/apex/QuoteApprovalController.submitForApproval';

export default class EnvioAprobacionCentroCostosQuote extends LightningElement {
    @api recordId; // Id del Quote

    @track isLoading = true;
    @track isValid = false;
    @track errorMessage;

    @track centroDeCostosName;
    @track totalQuote;
    @track estatusAprobacion;

    @track comentarios = '';

    // Al iniciar, aseguramos recordId y luego validamos datos
    connectedCallback() {
        this.ensureRecordId();
        this.loadData();
    }

    // Si Salesforce no manda recordId, lo obtenemos desde la URL
    ensureRecordId() {
        if (this.recordId) {
            return;
        }

        try {
            const path = window.location.pathname;
            // Ejemplo: /lightning/r/Quote/0Q0XXXXXXXXXXXX/view
            const parts = path.split('/');
            const quoteIndex = parts.indexOf('Quote');
            if (quoteIndex !== -1 && parts.length > quoteIndex + 1) {
                this.recordId = parts[quoteIndex + 1];
            }
        } catch (e) {
            // Si algo falla, dejamos recordId como está (null)
        }
    }

    // Cargar datos y aplicar validaciones iniciales
    loadData() {
        this.isLoading = true;
        this.errorMessage = null;

        if (!this.recordId) {
            this.isLoading = false;
            this.errorMessage = 'No se pudo determinar el Id del presupuesto (recordId vacío).';
            return;
        }

        validateQuoteData({ quoteId: this.recordId })
            .then(result => {
                if (result.isValid === true) {
                    // Todo OK → mostramos formulario
                    this.isValid = true;
                    this.centroDeCostosName = result.centroDeCostosName;
                    this.totalQuote = result.totalQuote;
                    this.estatusAprobacion = result.estatusAprobacion;
                } else {
                    // Error de validación → solo mensaje de bloqueo
                    this.isValid = false;
                    this.errorMessage = result.message;
                }
            })
            .catch(error => {
                this.isValid = false;
                this.errorMessage = this.reduceError(error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    // Actualizar comentarios
    handleCommentChange(event) {
        this.comentarios = event.target.value;
    }

    // Enviar a aprobación (solo si pasó validación)
    handleEnviar() {
        this.isLoading = true;

        submitForApproval({ quoteId: this.recordId, comentarios: this.comentarios })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Éxito',
                        message: 'El presupuesto se envió a aprobación correctamente',
                        variant: 'success'
                    })
                );
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error al enviar a aprobación',
                        message: this.reduceError(error),
                        variant: 'error'
                    })
                );
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    reduceError(error) {
        let message = 'Error desconocido';
        if (Array.isArray(error.body)) {
            message = error.body.map(e => e.message).join(', ');
        } else if (error.body && typeof error.body.message === 'string') {
            message = error.body.message;
        }
        return message;
    }

    // Mostrar mensaje de error cuando no es válido
    get showError() {
        return !this.isLoading && !this.isValid && this.errorMessage;
    }

    // Mostrar formulario solo cuando todo está validado
    get showForm() {
        return !this.isLoading && this.isValid;
    }

    // Deshabilitar botón si no hay comentarios
    get isCommentEmpty() {
        return !this.comentarios || this.comentarios.trim().length === 0;
    }
}
