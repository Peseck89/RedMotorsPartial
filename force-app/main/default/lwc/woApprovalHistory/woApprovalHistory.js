import { LightningElement, api, track, wire } from 'lwc';
import getData from '@salesforce/apex/WOApprovalHistoryCtrl.getData';

export default class WoApprovalHistory extends LightningElement {
  @api recordId;

  @track loading = true;
  @track instances = [];
  @track steps = [];
  @track workitems = [];
  @track selectedPiId = null;

  columnsInstances = [
    { label: 'Estado', fieldName: 'Status' },
    { label: 'Enviado por (Id)', fieldName: 'SubmittedById' },
    { label: 'Creado', fieldName: 'CreatedDate', type: 'date' },
    { label: 'Completado', fieldName: 'CompletedDate', type: 'date' },
    { label: 'Último actor (Id)', fieldName: 'LastActorId' }
  ];

  columnsSteps = [
    { label: 'Estado paso', fieldName: 'StepStatus' },
    { label: 'Actor (Id)', fieldName: 'ActorId' },
    { label: 'Comentario', fieldName: 'Comments' },
    { label: 'Fecha', fieldName: 'CreatedDate', type: 'date' }
  ];

  columnsWorkitems = [
    { label: 'Actor (Id)', fieldName: 'ActorId' },
    { label: 'Original (Id)', fieldName: 'OriginalActorId' },
    { label: 'Creado', fieldName: 'CreatedDate', type: 'date' }
  ];

  @wire(getData, { recordId: '$recordId' })
  wiredData({ data, error }) {
    this.loading = false;
    if (data) {
      this.instances = data.instances || [];
      this.steps = data.steps || [];
      this.workitems = data.workitems || [];
    } else if (error) {
      // Puedes mostrar un mensaje si quieres
      this.instances = [];
      this.steps = [];
      this.workitems = [];
    }
  }

  get filteredSteps() {
    return this.selectedPiId
      ? this.steps.filter(s => s.ProcessInstanceId === this.selectedPiId)
      : [];
  }

  handleSelectInstance(event) {
    const rows = event.detail.selectedRows || [];
    this.selectedPiId = rows.length ? rows[0].Id : null;
  }
}