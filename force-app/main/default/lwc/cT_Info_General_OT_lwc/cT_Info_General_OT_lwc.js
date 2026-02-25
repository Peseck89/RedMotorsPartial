import { LightningElement, track, wire, api } from 'lwc';
import getOT from '@salesforce/apex/ct_otRedis_ctrl.getWorkOrderData'; 
import saveDetalleAsesor from '@salesforce/apex/ct_otRedis_ctrl.saveDetalleAsesor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

 
export default class CT_Info_General_OT_lwc extends LightningElement {

  @api recordId;
  @track numOt
  @track caso
  @track fechaCita
  @track fechaEntrada
  @track currIsoCode
  @track observaciones
  @track parentWorkOrder
  @track isClosed
  @track etapaFlujoOt
  @track detalleEstado
  @track prioridad
  @track tipoServicio
  @track duracion
  @track asesorOt
  @track owner
  @track rootOt
  @track codigoProd
  @track fechaFacturacion
  @track fechaRecibido
  @track fechaEntregado
  @track fechaPrevistaEntrega
  @track serviceTerritory
  @track mecanico
  @track subject
  @track description
  @track finanDispAltica
  @track deseaFinanciamiento
  @track finanUtilizadoAltica
  @track monedaAltica
  @track pagador
  @track notiCargoBsi
  @track updateBsi
  @track fechaUltNotiBsi
  @track creadoPor
  @track fechaCreacion
  @track ultModiPor

  @track asesor
  @track servicio
  @track fechaIngreso
  @track cita
  @track origenCita
  @track diasProceso
  @track comentarios = ''; // Holds the current textarea content

  @track showEditZone = false

  handleEditZone() {
    this.showEditZone = !this.showEditZone
  }

  // Capture textarea input
  handleTextareaChange(event) {
    this.comentarios = event.target.value;
  }

  // Save the content to the Case field
  handleSave() {
    // Call Apex method to save the data
    saveDetalleAsesor({ caseId: this.recordId, detalleAsesor: this.comentarios })
        .then(() => {
            // Show success message and exit edit mode
            this.showEditZone = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Detalle Asesor updated successfully',
                    variant: 'success',
                }),
            );
        })
        .catch(error => {
            // Handle errors
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating Detalle Asesor',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        });
}

  @wire(getOT, {recordId: '$recordId'})
  getWorkOrderData({error, data}) {
    if(data) {
      console.log('===========DATA===========');
      console.log(data);
      
      this.numOt = data[0].WorkOrderNumber || ""
      this.caso = data[0].CaseId || ""
      this.fechaCita = data[0].Fecha_Cita__c || ""
      this.fechaEntrada = data[0].Fecha_de_Entrada__c || ""
      this.currIsoCode = data[0].CurrencyIsoCode || ""
      // this.observaciones = data[0].
      // this.parentWorkOrder = data[0].ParentWorkOrderId
      // this.isClosed = data[0].IsClosed
      // this.etapaFlujoOt = data[0].Etapa_de_flujo_de_trabajo__c
      // this.detalleEstado = data[0].Detalle_de_estado__c
      this.diasProceso = data[0].Dias_en_proceso__c || ""
      // this.prioridad = data[0].Priority
      this.servicio = data[0].Tipo_de_servicio__c || ""
      this.duracion = data[0].Duration || ""
      this.asesorOt = data[0].OwnerOT__c || ""
      // this.owner = data[0].
      // this.rootOt = data[0].RootWorkOrderId
      // this.codigoProd = data[0].BMW_CodigoDeProducto__c
      this.fechaFacturacion = data[0].Fecha_de_facturacion__c || ""
      this.fechaRecibido = data[0].Fecha_de_Recibido__c || ""
      this.fechaEntregado = data[0].Fecha_veh_culo_listo__c || ""
      this.fechaPrevistaEntrega = data[0].Fecha_prevista_de_entrega__c || ""
      // this.mecanico = data[0].CT_Mecanico__c
      this.subject = data[0].Subject || ""
      this.description = data[0].Description || ""
      // this.finanDispAltica = data[0].Financiamiento_disponible_Altica__c
      // this.deseaFinanciamiento = data[0].Desea_financiamiento__c
      // this.finanUtilizadoAltica = data[0].Financiamiento_utilizado_Altica__c
      // this.monedaAltica = data[0].Moneda_financiamiento_Altica__c
      // this.pagador = data[0].BMW_Pagador__c
      // this.notiCargoBsi = data[0].Notificaci_n_Cargo_BSI__c
      // this.updateBsi = data[0].Update_BSI__c
      // this.fechaUltNotiBsi = data[0].Fecha_Ultima_Notificaci_n_BSI_Update__c
      this.creadoPor = data[0].CreatedById || ""
      this.comentarios = data[0].Detalle_Asesor__c || ""
      this.fechaCreacion = data[0].CreatedDate || ""
      // this.ultModiPor = data[0].LastModifiedById
      this.origenCita = data[0].Origen__c || ""

    } else if(error) {
      console.log('Error de data', error);
    }
  }
}