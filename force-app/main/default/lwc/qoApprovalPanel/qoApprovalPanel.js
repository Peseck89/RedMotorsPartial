// qoApprovalPanel.js
import { LightningElement, api, wire, track } from 'lwc';
import load from '@salesforce/apex/QOApprovalPanelCtrl.load';
import canView from '@salesforce/apex/QOApprovalPanelCtrl.canView';
import approve from '@salesforce/apex/QOApprovalPanelCtrl.approve';
import reject from '@salesforce/apex/QOApprovalPanelCtrl.reject';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import COM_FIELD from '@salesforce/schema/Quote.CPComentariosDelAsesor__c';

export default class QoApprovalPanel extends LightningElement {
  @api recordId;

  // --- Wire handles (para refreshApex)
  _wiredLoad;
  _wiredCanView;

  // --- Estado UI
  @track data; // DataResp { instances:[], myWorkitems:[] }
  @track visible = false; // controlado por canView()
  @track isBusy = false;

  // Modal
  @track showDialog = false;
  @track dialogTitle = '';
  @track confirmLabel = '';
  @track comments = '';
  _pendingAction = null; // 'approve' | 'reject'
  _pendingWorkitemId = null;

  // ---------------------------
  // Wires (solo a métodos cacheables)
  // ---------------------------
  @wire(getRecord, { recordId: '$recordId', fields: [COM_FIELD] })
  quoteRec;

  get advisorComment() {
    return getFieldValue(this.quoteRec?.data, COM_FIELD) || '';
  }

  @wire(load, { recordId: '$recordId' })
  wiredLoad(resp) {
    this._wiredLoad = resp;
    if (resp?.data) {
      // Clonamos y marcamos flag por instancia
      const cloned = JSON.parse(JSON.stringify(resp.data));
      cloned.instances = (cloned.instances || []).map((pi) => ({
        ...pi,
        isPending: pi.status === 'Pending'
      }));
      this.data = cloned;
    }
    // opcional: maneja resp.error
  }

  @wire(canView, { recordId: '$recordId' })
  wiredCanView(resp) {
    this._wiredCanView = resp;
    if (resp && resp.data !== undefined) {
      this.visible = resp.data;
    }
    // opcional: maneja resp.error
  }

  // ---------------------------
  // Getters usados por el HTML
  // ---------------------------
  get canRender() {
    return this.visible === true;
  }

  get instances() {
    return this.data?.instances || [];
  }

  get instancesLength() {
    return this.instances.length;
  }

  get hasMyWorkitems() {
    return (this.data?.myWorkitems?.length || 0) > 0;
  }

  get myWorkitems() {
    return this.data?.myWorkitems || [];
  }

  // Columnas de la lightning-datatable
  get wiColumns() {
    return [
      {
        label: 'Creado',
        fieldName: 'createdDate',
        type: 'date',
        typeAttributes: {
          year: 'numeric',
          month: '2-digit',
          day: '2-digit',
          hour: '2-digit',
          minute: '2-digit'
        }
      },
      { label: 'Actor', fieldName: 'actorName', type: 'text' },
      {
        type: 'action',
        typeAttributes: {
          rowActions: [
            { label: 'Aprobar', name: 'approve' },
            { label: 'Rechazar', name: 'reject' }
          ]
        }
      }
    ];
  }

  // ---------------------------
  // Acciones de tabla / modal
  // ---------------------------
  handleRowAction(event) {
    const { action, row } = event.detail || {};
    if (!action || !row) return;

    this._pendingWorkitemId = row.id;
    this.comments = '';

    if (action.name === 'approve') {
      this._pendingAction = 'approve';
      this.dialogTitle = 'Aprobar solicitud';
      this.confirmLabel = 'Aprobar';
      this.showDialog = true;
    } else if (action.name === 'reject') {
      this._pendingAction = 'reject';
      this.dialogTitle = 'Rechazar solicitud';
      this.confirmLabel = 'Rechazar';
      this.showDialog = true;
    }
  }

  onComments(evt) {
    this.comments = evt.detail?.value || '';
  }

  closeDialog() {
    this.showDialog = false;
    this._pendingAction = null;
    this._pendingWorkitemId = null;
    this.comments = '';
  }

  // Confirma la acción del modal y llama a Apex imperativamente
  async confirmAction() {
    if (!this._pendingAction || !this._pendingWorkitemId) return;
    this.isBusy = true;
    try {
      if (this._pendingAction === 'approve') {
        const fresh = await approve({
          workitemId: this._pendingWorkitemId,
          comments: this.comments,
          recordId: this.recordId
        });
        this.data = fresh;
        this.toast('Approved', 'La solicitud fue aprobada.', 'success');
      } else if (this._pendingAction === 'reject') {
        const fresh = await reject({
          workitemId: this._pendingWorkitemId,
          comments: this.comments,
          recordId: this.recordId
        });
        this.data = fresh;
        this.toast('Rejected', 'La solicitud fue rechazada.', 'success');
      }

      // Refresca los wires cacheables
      await Promise.all([
        refreshApex(this._wiredLoad),
        refreshApex(this._wiredCanView)
      ]);
    } catch (e) {
      this.toast(
        'Error',
        e?.body?.message || e?.message || 'No se pudo procesar la acción',
        'error'
      );
    } finally {
      this.isBusy = false;
      this.closeDialog();
    }
  }

  // ---------------------------
  // Botón "Refrescar"
  // ---------------------------
  async refresh() {
    this.isBusy = true;
    try {
      await Promise.all([
        refreshApex(this._wiredLoad),
        refreshApex(this._wiredCanView)
      ]);
    } catch (e) {
      this.toast(
        'Error',
        e?.body?.message || e?.message || 'No se pudo refrescar',
        'error'
      );
    } finally {
      this.isBusy = false;
    }
  }

  // ---------------------------
  // Utilidades
  // ---------------------------
  toast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }
}