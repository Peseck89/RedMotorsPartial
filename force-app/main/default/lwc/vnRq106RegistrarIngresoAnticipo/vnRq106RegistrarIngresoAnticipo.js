import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOpportunityContext from '@salesforce/apex/VN_RQ106_AnticipoController.getOpportunityContext';
import createDraftSolicitud from '@salesforce/apex/VN_RQ106_AnticipoController.createDraftSolicitud';
import updateDraftSolicitud from '@salesforce/apex/VN_RQ106_AnticipoController.updateDraftSolicitud';
import sendToTreasury from '@salesforce/apex/VN_RQ106_AnticipoController.sendToTreasury';

const TIPO_RESERVA = 'Reserva de vehículo';
const STATUS_EN_VALIDACION_TESORERIA = 'En validación de Tesorería';
const NO_VEHICLES_MESSAGE = 'No hay vehículos disponibles para reserva en esta oportunidad.';

export default class VnRq106RegistrarIngresoAnticipo extends LightningElement {
    _recordId;
    context;
    loadError;
    isLoading = false;
    createdAnticipoId;
    createdAnticipoStatus;
    hasExistingDraft = false;
    uploadedFileNames;

    @track form = {
        tipoIngreso: '',
        monto: null,
        medioPago: '',
        fechaIngreso: '',
        referenciaComprobante: '',
        depositante: '',
        comentariosAsesor: '',
        productoId: ''
    };

    tipoIngresoOptions = [
        { label: 'Reserva de vehículo', value: 'Reserva de vehículo' },
        { label: 'Abono', value: 'Abono' },
        { label: 'Complemento de prima', value: 'Complemento de prima' },
        { label: 'Separación pedido especial', value: 'Separación pedido especial' },
        { label: 'Otro', value: 'Otro' }
    ];

    medioPagoOptions = [
        { label: 'Transferencia', value: 'Transferencia' },
        { label: 'Depósito', value: 'Depósito' },
        { label: 'Tarjeta', value: 'Tarjeta' },
        { label: 'Caja', value: 'Caja' },
        { label: 'SINPE', value: 'SINPE' },
        { label: 'Otro', value: 'Otro' }
    ];

    @api
    get recordId() {
        return this._recordId;
    }

    set recordId(value) {
        this._recordId = value;
        if (value) {
            this.loadContext();
        }
    }

    get displayAccountName() {
        return this.context?.accountName || 'Sin cuenta';
    }

    get displayOwnerName() {
        return this.context?.ownerName || 'Sin asesor';
    }

    get displayRecordType() {
        return this.context?.recordTypeDeveloperName || 'Sin record type';
    }

    get displayCurrencyIsoCode() {
        return this.context?.currencyIsoCode || '';
    }

    get isReservaVehiculo() {
        return this.form.tipoIngreso === TIPO_RESERVA;
    }

    get productOptions() {
        const products = this.context?.products || [];
        return products.map((product) => {
            const vin = product.vin ? ` - ${product.vin}` : '';
            return {
                label: `${product.productName || 'Vehículo'}${vin}`,
                value: product.productId
            };
        });
    }

    get hasNoVehiclesForReserva() {
        return this.isReservaVehiculo && !this.isLoading && !!this.context && !this.hasVehicleOptions;
    }

    get hasVehicleOptions() {
        return this.productOptions.length > 0;
    }

    get hasOpportunityContext() {
        return !!this.context;
    }

    get hasRelatedClient() {
        return !!this.context?.accountId;
    }

    get hasPositiveAmount() {
        return Number(this.form.monto) > 0;
    }

    get hasRequiredFieldsComplete() {
        const baseFieldsComplete =
            !!this.form.tipoIngreso &&
            this.hasPositiveAmount &&
            !!this.form.medioPago &&
            !!this.form.fechaIngreso &&
            !!this.form.referenciaComprobante;

        return baseFieldsComplete && (!this.isReservaVehiculo || !!this.form.productoId);
    }

    get isPreparedForTreasury() {
        return !!this.createdAnticipoId && this.hasUploadedEvidence && !this.isSentToTreasury;
    }

    get isPreparedForTreasuryPositive() {
        return this.isSentToTreasury || this.isPreparedForTreasury;
    }

    get preparedForTreasuryStatusLabel() {
        return this.isPreparedForTreasuryPositive ? 'Listo' : 'Pendiente';
    }

    get noVehiclesMessage() {
        return NO_VEHICLES_MESSAGE;
    }

    get isSaveDisabled() {
        return this.isLoading || this.hasNoVehiclesForReserva || !this.hasRelatedClient || this.isSentToTreasury;
    }

    get saveDraftLabel() {
        return this.createdAnticipoId ? 'Actualizar borrador' : 'Guardar borrador';
    }

    get draftStatusTitle() {
        return this.hasExistingDraft ? 'Borrador existente' : 'Borrador creado';
    }

    get draftStatusValue() {
        return this.createdAnticipoId || 'Pendiente';
    }

    get hasUploadedEvidence() {
        return !!this.uploadedFileNames;
    }

    get isSentToTreasury() {
        return this.createdAnticipoStatus === STATUS_EN_VALIDACION_TESORERIA;
    }

    get isSolicitudEnviada() {
        return this.isSentToTreasury;
    }

    get solicitudEnviadaStatusLabel() {
        return this.isSentToTreasury ? 'Enviado' : 'Pendiente';
    }

    get isUploadDisabled() {
        return this.isLoading || this.isSentToTreasury;
    }

    get isSendToTreasuryDisabled() {
        return this.isLoading || !this.hasUploadedEvidence || this.isSentToTreasury;
    }

    loadContext() {
        this.isLoading = true;
        this.loadError = undefined;

        getOpportunityContext({ opportunityId: this.recordId })
            .then((result) => {
                this.context = result;
                this.applyExistingDraft(result?.existingDraft);
            })
            .catch((error) => {
                this.loadError = this.reduceError(error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    applyExistingDraft(draft) {
        if (!draft?.anticipoId) {
            return;
        }

        this.hasExistingDraft = true;
        this.createdAnticipoId = draft.anticipoId;
        this.createdAnticipoStatus = draft.estatus;
        this.uploadedFileNames = draft.evidenceCount > 0
            ? `${draft.evidenceCount} archivo(s) existente(s)`
            : undefined;
        this.form = {
            ...this.form,
            tipoIngreso: draft.tipoIngreso || '',
            monto: draft.monto,
            medioPago: draft.medioPago || '',
            fechaIngreso: draft.fechaIngreso || '',
            referenciaComprobante: draft.referenciaComprobante || '',
            depositante: draft.depositante || '',
            comentariosAsesor: draft.comentariosAsesor || '',
            productoId: draft.productoId || ''
        };
    }

    handleFieldChange(event) {
        const field = event.target.dataset.field;
        this.form = {
            ...this.form,
            [field]: event.detail.value
        };

        if (field === 'tipoIngreso' && event.detail.value !== TIPO_RESERVA) {
            this.form = {
                ...this.form,
                productoId: ''
            };
        }
    }

    handleSaveDraft() {
        if (this.hasNoVehiclesForReserva) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Reserva sin vehículos disponibles',
                    message: NO_VEHICLES_MESSAGE,
                    variant: 'error'
                })
            );
            return;
        }

        if (!this.hasRelatedClient) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Cliente relacionado requerido',
                    message: 'La oportunidad debe tener una cuenta relacionada para registrar la solicitud.',
                    variant: 'error'
                })
            );
            return;
        }

        if (!this.validateRequiredFields()) {
            return;
        }

        const payload = {
            anticipoId: this.createdAnticipoId,
            opportunityId: this.recordId,
            monto: Number(this.form.monto),
            tipoIngreso: this.form.tipoIngreso,
            medioPago: this.form.medioPago,
            fechaIngreso: this.form.fechaIngreso,
            referenciaComprobante: this.form.referenciaComprobante,
            depositante: this.form.depositante,
            comentariosAsesor: this.form.comentariosAsesor,
            productoId: this.isReservaVehiculo && this.form.productoId ? this.form.productoId : null
        };
        const saveAction = this.createdAnticipoId
            ? updateDraftSolicitud({ payload })
            : createDraftSolicitud({ payload });

        this.isLoading = true;
        saveAction
            .then((result) => {
                this.createdAnticipoId = result.anticipoId;
                this.createdAnticipoStatus = result.estatus;
                const wasUpdate = !!payload.anticipoId;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: wasUpdate ? 'Borrador actualizado' : 'Borrador creado',
                        message: wasUpdate
                            ? 'La solicitud de ingreso fue actualizada.'
                            : 'La solicitud de ingreso fue creada en estado Borrador.',
                        variant: 'success'
                    })
                );
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'No se pudo crear el borrador',
                        message: this.reduceError(error),
                        variant: 'error'
                    })
                );
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    validateRequiredFields() {
        const fields = [...this.template.querySelectorAll('[data-required="true"]')];
        return fields.reduce((isValid, field) => {
            field.reportValidity();
            return isValid && field.checkValidity();
        }, true);
    }

    handleUploadFinished(event) {
        const files = event.detail.files || [];
        this.uploadedFileNames = files.map((file) => file.name).join(', ');
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Evidencia cargada',
                message: `${files.length} archivo(s) asociado(s) al anticipo.`,
                variant: 'success'
            })
        );
    }

    handleSendToTreasury() {
        if (!this.createdAnticipoId || !this.hasUploadedEvidence) {
            return;
        }

        this.isLoading = true;
        sendToTreasury({ anticipoId: this.createdAnticipoId })
            .then((result) => {
                this.createdAnticipoStatus = result.estatus;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Solicitud enviada',
                        message: 'Solicitud enviada a validación de Tesorería.',
                        variant: 'success'
                    })
                );
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'No se pudo enviar a Tesorería',
                        message: this.reduceError(error),
                        variant: 'error'
                    })
                );
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    reduceError(error) {
        const messages = [];
        const addMessage = (message) => {
            if (typeof message === 'string' && message.trim()) {
                messages.push(message.trim());
            }
        };
        const collectFieldErrors = (fieldErrors) => {
            if (!fieldErrors || typeof fieldErrors !== 'object') {
                return;
            }
            Object.values(fieldErrors).forEach((errors) => {
                if (Array.isArray(errors)) {
                    errors.forEach((item) => addMessage(item?.message));
                } else {
                    addMessage(errors?.message);
                }
            });
        };
        const collectErrors = (value) => {
            if (!value) {
                return;
            }
            if (Array.isArray(value)) {
                value.forEach((item) => collectErrors(item));
                return;
            }
            if (typeof value === 'string') {
                addMessage(value);
                return;
            }
            addMessage(value.message);
            collectErrors(value.pageErrors);
            collectFieldErrors(value.fieldErrors);
            collectErrors(value.errors);
            collectFieldErrors(value.output?.fieldErrors);
            collectErrors(value.output?.errors);
            addMessage(value.output?.message);
        };

        collectErrors(error?.body);
        addMessage(error?.message);

        const uniqueMessages = [...new Set(messages)];
        return uniqueMessages.length ? uniqueMessages.join(', ') : 'Error inesperado.';
    }
}
