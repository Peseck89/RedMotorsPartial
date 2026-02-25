import { LightningElement, track, wire, api } from "lwc";
import getCaso from "@salesforce/apex/ct_casoredi_ctrl.getCaseData";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import updateCaseStatusDetail from "@salesforce/apex/ct_casoredi_ctrl.updateCaseStatusDetail";
import CASE_STATUSDETAIL_FIELD from "@salesforce/schema/Case.StatusDetail__c";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import saveDetalleAsesor from "@salesforce/apex/ct_casoredi_ctrl.saveDetalleAsesor";
import saveNumeroGuia from "@salesforce/apex/ct_casoredi_ctrl.saveNumeroGuia";
import saveColorGuia from "@salesforce/apex/ct_casoredi_ctrl.saveColorGuia";
import saveLavado from "@salesforce/apex/ct_casoredi_ctrl.saveLavado";
import saveObjetoValor from "@salesforce/apex/ct_casoredi_ctrl.saveObjetoValor";
import saveObjetoValorText from "@salesforce/apex/ct_casoredi_ctrl.saveObjetoValorText";
import saveRepuestos from "@salesforce/apex/ct_casoredi_ctrl.saveRepuestos";
import getOwnerName from "@salesforce/apex/ct_casoredi_ctrl.getOwnerName";
import saveCombustibleData from "@salesforce/apex/ct_casoredi_ctrl.saveCombustibleData";
import savePriorityData from "@salesforce/apex/ct_casoredi_ctrl.savePriorityData";

const fields = [CASE_STATUSDETAIL_FIELD];

export default class CT_Info_General_CS_lwc extends LightningElement {
  @api recordId;
  @track assetId;
  @track asesor;
  @track servicio;
  @track fechaIngreso;
  @track cita;
  @track origenCita;
  @track obcervaciones;
  @track diasEnProceso;
  @track consecutivo;
  @track recordType;
  @track estatus;
  @track prioridad;
  @track origenCaso;
  @track ownerCaso;
  @track fechaAbierto;
  @track fechaCerrado;
  @track fechaEntrada;
  @track formatedFechaEntrada;
  @track cita;
  @track mecanicoAsignado;
  @track lavado;
  @track lavadoFormat;
  @track objetoValor;
  @track objetoValorFormat;
  @track numeroGuia = "";
  @track colorGuia = "";
  @track objetoValorTXT;
  @track objetoValorTXTFormat;
  @track repuesto;
  @track repuestoFormat;

  @track statusDetail;
  @track selectedStatusDetail;
  @track picklistOptions = [];
  @track comentarios = ""; // Holds the current textarea content

  @track showEditZoneKM = false;
  @track showEditZone = false;
  @track showEditZoneNumGuia = false;
  @track showEditZoneColorGuia = false;
  @track showEditZoneLavado;
  @track showEditZoneObjetoValor;
  @track showEditZoneObjetoValorTXT;
  @track showEditZoneRepuesto;

  @track tipoCombustible;
  @track tipoCombustibleLabel = "";
  @track nivelCombustible;
  @track nivelCombustibleLabel = "";
  @track porcentajeCarga;
  @track showGasolinaField = false;
  @track showElectricoField = false;
  @track prioridadCaso;
  @track prioridadCasoLabel = "";

  // picklistOptions = [
  //   { label: "Recibido", value: "Recibido" },
  //   { label: "Ingreso Torre de Control", value: "Ingreso Torre de Control" },
  //   { label: "Programación", value: "Programación" },
  //   { label: "Asignado", value: "Asignado" },
  //   { label: "En Proceso", value: "En Proceso" },
  //   { label: "Pruebas", value: "Pruebas" },
  //   { label: "Trabajo externo", value: "Trabajo externo" },
  //   { label: "Pintura", value: "Pintura" },
  //   { label: "Creando presupuesto", value: "Creando presupuesto" },
  //   { label: "Presupuesto autorizado", value: "Presupuesto autorizado" },
  //   { label: "Presupuesto listo", value: "Presupuesto listo" },
  //   { label: "Control de calidad", value: "Control de calidad" },
  //   { label: "Lavado", value: "Lavado" },
  //   { label: "Pedido especial (Varado)", value: "Pedido especial (Varado)" },
  //   { label: "Pedido especial (Rodando)", value: "Pedido especial (Rodando)" },
  //   { label: "Vehículo Listo", value: "Vehículo Listo" },
  //   { label: "Entregado", value: "Entregado" },
  // ];

  picklistOptions = [
    { label: "Orden Aperturada", value: "Orden Aperturada" },
    { label: "Recepción Realizada", value: "Recibido" },
    {
      label: "Recibido en Torre de Control",
      value: "Ingreso Torre de Control",
    },
    { label: "Por Asignar", value: "Por Asignar" },
    { label: "En Proceso", value: "En Proceso" },
    {
      label: "Elaboracíón de Presupuesto",
      value: "Elaboracíón de presupuesto",
    },
    { label: "Pendiente de Aprobación", value: "Pendiente de Aprobación" },
    { label: "Presupuesto Autorizado", value: "Presupuesto autorizado" },
    {
      label: "Pendiente de Pedido Especial",
      value: "Pendiente de pedido especial",
    },
    { label: "Trabajo Externo", value: "Trabajo externo" },
    { label: "Pintura", value: "Pintura" },
    {
      label: "Asignación de Prueba en Carretera y Control de Calidad",
      value: "Asignación de prueba en carretera y control de calidad",
    },
    { label: "Lavado", value: "Lavado" },
    { label: "Vehículo Listo", value: "Vehículo Listo" },
  ];

  tipoCombustibleOptions = [
    { label: "Gasolina", value: "Gasolina" },
    { label: "Eléctrico", value: "Eléctrico" },
    { label: "Diesel", value: "Diesel" }
  ];

  nivelCombustibleOptions = [
    { label: "Vacío", value: "Vacío" },
    { label: "Un cuarto", value: "Un cuarto" },
    { label: "Medio", value: "Medio" },
    { label: "Tres cuartos", value: "Tres cuartos" },
    { label: "Full", value: "Full" },
  ];

  // nivelCombustibleOptions = [
  //   { label: 'vacío', value: 'vacío' },
  //   { label: 'un cuarto', value: 'un cuarto' },
  //   { label: 'un medio', value: 'un medio' },
  //   { label: 'full', value: 'full' }
  // ];

  prioridadCasoOptions = [
    { label: "Alta", value: "Alta" },
    { label: "Media", value: "Media" },
    { label: "Baja", value: "Baja" },
  ];
  get caseStatusDetail() {
    return getFieldValue(this.case.data, CASE_STATUSDETAIL_FIELD);
  }
  handleCombustibleChange(event) {
    this.tipoCombustible = event.detail.value;
    this.tipoCombustibleLabel =
      this.tipoCombustibleOptions.find(
        (option) => option.value === this.tipoCombustible
      )?.label || "";

    // Mostrar campos dependientes
    if (this.tipoCombustible === "Eléctrico") {
      this.nivelCombustible = "";
    }
    this.showGasolinaField =
      this.tipoCombustible === "Gasolina" || this.tipoCombustible === "Diesel";
    this.showElectricoField = this.tipoCombustible === "Eléctrico";
  }

  handleNivelCombustibleChange(event) {
    this.nivelCombustible = event.detail.value;
    this.nivelCombustibleLabel =
      this.nivelCombustibleOptions.find(
        (option) => option.value === this.nivelCombustible
      )?.label || "";
  }

  handlePorcentajeCargaChange(event) {
    this.porcentajeCarga = event.target.value;
  }
  handlePrioridadChange(event) {
    this.prioridadCaso = event.detail.value;
    this.prioridadCasoLabel =
      this.prioridadCasoOptions.find(
        (option) => option.value === this.prioridadCaso
      )?.label || "";
  }
  handleSaveCombustible() {
    saveCombustibleData({
      caseId: this.recordId,
      tipoCombustible: this.tipoCombustible,
      nivelCombustible: this.nivelCombustible,
      porcentajeCarga: this.porcentajeCarga,
    })
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Éxito",
            message: "Datos de combustible guardados correctamente",
            variant: "success",
          })
        );
        window.location.reload();
      })
      .catch((error) => {
        console.log("Error al guardar combustible: ", error);
        
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: error.body.message,
            variant: "error",
          })
        );
      });
  }
  handleSavePriority() {
    savePriorityData({
      caseId: this.recordId,
      prioridad: this.prioridadCaso,
    })
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Éxito",
            message: "Datos de prioridad del caso guardados correctamente",
            variant: "success",
          })
        );
        window.location.reload();
      })
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: error.body.message,
            variant: "error",
          })
        );
      });
  }
  handleEditZoneKM() {
    this.showEditZoneKM = !this.showEditZoneKM;
  }

  handleEditZone() {
    this.showEditZone = !this.showEditZone;
  }

  handleEditZoneNumGuia() {
    this.showEditZoneNumGuia = !this.showEditZoneNumGuia;
  }

  handleEditZoneColorGuia() {
    this.showEditZoneColorGuia = !this.showEditZoneColorGuia;
  }

  handleEditZoneLavado() {
    this.showEditZoneLavado = !this.showEditZoneLavado;
  }

  handleEditZoneObjetoValor() {
    this.showEditZoneObjetoValor = !this.showEditZoneObjetoValor;
  }

  handleEditZoneObjetoValorTXT() {
    this.showEditZoneObjetoValorTXT = !this.showEditZoneObjetoValorTXT;
  }

  handleEditZoneRepuesto() {
    this.showEditZoneRepuesto = !this.showEditZoneRepuesto;
  }

  @wire(getRecord, { recordId: "$recordId", fields })
  case;

  handleChange(event) {
    console.log("=============statusDetail=============");

    this.statusDetail = event.target.value;
    console.log(this.statusDetail);
  }

  handleSave() {
    console.log("=============statusDetail SAVE=============");
    console.log(this.recordId);
    console.log(this.statusDetail);
    updateCaseStatusDetail({
      caseId: this.recordId,
      statusDetail: this.statusDetail,
    })
      .then(() => {
        // Handle successful update
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Case Status Detail updated successfully",
            variant: "success",
          })
        );
        window.location.reload();
      })
      .catch((error) => {
        // Handle error
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error updating Case Status Detail",
            message: error.body.message,
            variant: "error",
          })
        );
      });
  }

  handleTextareaChange(event) {
    this.comentarios = event.target.value;
  }
  handleTextareaChangeGuia(event) {
    this.numeroGuia = event.target.value;
  }
  handleTextareaChangeColorGuia(event) {
    this.colorGuia = event.target.value;
  }
  handleTextareaChangeObjetoValorTXT(event) {
    this.objetoValorTXT = event.target.value;
  }

  get noLavado() {
    return !this.lavado;
  }

  get noObjetoValor() {
    return !this.objetoValor;
  }

  get noRepuesto() {
    return !this.repuesto;
  }

  handleCheckboxChangeLavado(event) {
    // this.lavado = event.target.checked;
    const newValue = event.target.dataset.value === "true";
    this.lavado = newValue;

    saveLavado({
      caseId: this.recordId,
      ReqLavado: this.lavado, // Se pasa el valor booleano de 'lavado'
    })
      .then(() => {
        // Show success message and exit edit mode
        this.showEditZoneLavado = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Requiere lavado updated successfully",
            variant: "success",
          })
        );
        // window.location.reload();
        if (this.lavado === true) {
          this.lavadoFormat = "Si";
        } else if (this.lavado === false) {
          this.lavadoFormat = "No";
        }
      })
      .catch((error) => {
        // Handle errors
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error updating Requiere lavado",
            message: error.body.message,
            variant: "error",
          })
        );
      });
  }

  handleCheckboxChangeObjetoValor(event) {
    // this.objetoValor = event.target.checked;
    const newValue = event.target.dataset.value === "true";
    this.objetoValor = newValue;

    saveObjetoValor({
      caseId: this.recordId,
      objValor: this.objetoValor, // Se pasa el valor booleano de 'lavado'
    })
      .then(() => {
        // Show success message and exit edit mode
        this.showEditZoneObjetoValor = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Objeto de valor updated successfully",
            variant: "success",
          })
        );
        // window.location.reload();
        if (this.objetoValor === true) {
          this.objetoValorFormat = "Si";
        } else if (this.objetoValor === false) {
          this.objetoValorFormat = "No";
        }
      })
      .catch((error) => {
        // Handle errors
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error updating Objeto de valor",
            message: error.body.message,
            variant: "error",
          })
        );
      });
  }

  handleCheckboxChangeRepuesto(event) {
    // this.objetoValor = event.target.checked;
    const newValue = event.target.dataset.value === "true";
    this.repuesto = newValue;

    saveRepuestos({
      caseId: this.recordId,
      LlevarseRepuestos: this.repuesto, // Se pasa el valor booleano de 'lavado'
    })
      .then(() => {
        // Show success message and exit edit mode
        this.showEditZoneRepuesto = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Llevar repuestos updated successfully",
            variant: "success",
          })
        );
        // window.location.reload();
        if (this.repuesto === true) {
          this.repuestoFormat = "Si";
        } else if (this.repuesto === false) {
          this.repuestoFormat = "No";
        }
      })
      .catch((error) => {
        // Handle errors
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error updating Llevar Repuesto",
            message: error.body.message,
            variant: "error",
          })
        );
      });
  }

  handleSaveComen() {
    // Call Apex method to save the data
    saveDetalleAsesor({
      caseId: this.recordId,
      detalleAsesor: this.comentarios,
    })
      .then(() => {
        // Show success message and exit edit mode
        this.showEditZone = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Detalle Asesor actualizado correctamente",
            variant: "success",
          })
        );
      })
      .catch((error) => {
        // Handle errors
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error updating Detalle Asesor",
            message: error.body.message,
            variant: "error",
          })
        );
      });
  }
  handleSaveNumGuia() {
    saveNumeroGuia({
      caseId: this.recordId,
      numGuia: this.numeroGuia,
    })
      .then(() => {
        // Show success message and exit edit mode
        this.showEditZoneNumGuia = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Numero de guia updated successfully",
            variant: "success",
          })
        );
      })
      .catch((error) => {
        // Handle errors
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error updating Numero de guia",
            message: error.body.message,
            variant: "error",
          })
        );
      });
  }
  handleSaveColorGuia() {
    saveColorGuia({
      caseId: this.recordId,
      colorDeGuia: this.colorGuia,
    })
      .then(() => {
        // Show success message and exit edit mode
        this.showEditZoneColorGuia = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Color de guia updated successfully",
            variant: "success",
          })
        );
      })
      .catch((error) => {
        // Handle errors
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error updating Color de guia",
            message: error.body.message,
            variant: "error",
          })
        );
      });
  }
  handleSaveLavado() {
    saveLavado({
      caseId: this.recordId,
      ReqLavado: this.lavado, // Se pasa el valor booleano de 'lavado'
    })
      .then(() => {
        // Show success message and exit edit mode
        this.showEditZoneLavado = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Requiere lavado updated successfully",
            variant: "success",
          })
        );
        window.location.reload();
      })
      .catch((error) => {
        // Handle errors
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error updating Requiere lavado",
            message: error.body.message,
            variant: "error",
          })
        );
      });
  }
  handleSaveObjetoValor() {
    saveObjetoValor({
      caseId: this.recordId,
      objValor: this.objetoValor, // Se pasa el valor booleano de 'lavado'
    })
      .then(() => {
        // Show success message and exit edit mode
        this.showEditZoneObjetoValor = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Objeto de valor updated successfully",
            variant: "success",
          })
        );
        window.location.reload();
      })
      .catch((error) => {
        // Handle errors
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error updating Objeto de valor",
            message: error.body.message,
            variant: "error",
          })
        );
      });
  }

  handleSaveObjetoValorTXT() {
    saveObjetoValorText({
      caseId: this.recordId,
      objValorText: this.objetoValorTXT, // Se pasa el valor booleano de 'lavado'
    })
      .then(() => {
        // Show success message and exit edit mode
        this.showEditZoneObjetoValorTXT = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Objetos de valor updated successfully",
            variant: "success",
          })
        );
        window.location.reload();
      })
      .catch((error) => {
        // Handle errors
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error updating Objetos de valor",
            message: error.body.message,
            variant: "error",
          })
        );
      });
  }

  handleSaveRepuesto() {
    saveRepuestos({
      caseId: this.recordId,
      LlevarseRepuestos: this.repuesto, // Se pasa el valor booleano de 'repuesto'
    })
      .then(() => {
        // Show success message and exit edit mode
        this.showEditZoneRepuesto = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Llevar repuesto updated successfully",
            variant: "success",
          })
        );
        window.location.reload();
      })
      .catch((error) => {
        // Handle errors
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error updating Llevar repuesto",
            message: error.body.message,
            variant: "error",
          })
        );
      });
  }

  @wire(getCaso, { recordId: "$recordId" })
  getCaseData({ error, data }) {
    console.log(data);
    if (data) {
      this.tipoCombustible = data[0].TipoDeCombustible__c;
      this.tipoCombustibleLabel =
        this.tipoCombustibleOptions.find(
          (option) => option.value === this.tipoCombustible
        )?.label || "";

      this.nivelCombustible = data[0].NivelDeCombustible__c;
      this.nivelCombustibleLabel =
        this.nivelCombustibleOptions.find(
          (option) => option.value === this.nivelCombustible
        )?.label || "";
      this.prioridadCaso = data[0].Priority;
      this.prioridadCasoLabel =
        this.prioridadCasoOptions.find(
          (option) => option.value === this.prioridadCaso
        )?.label || "";
      this.porcentajeCarga = data[0].PorcentajeDeCargaElectrica__c;

      this.showGasolinaField =
        this.tipoCombustible === "Gasolina" ||
        this.tipoCombustible === "Diesel";
      this.showElectricoField = this.tipoCombustible === "Eléctrico";
      console.log("===========DATA INFO GENERAL===========");
      console.log(data);

      this.assetId = data[0].assetId;
      this.prioridad = data[0].Priority;
      this.servicio = data[0].Service_Territory_Name_Formula__c;
      this.cita = data[0].Cita__c;
      this.statusDetail = data[0].StatusDetail__c;

      this.statusDetail = data[0].StatusDetail__c;
      this.selectedStatusDetail =
        this.picklistOptions.find(
          (option) => option.value === this.statusDetail
        )?.label || this.statusDetail; // Si no hay coincidencia, se asigna ''

      console.log("Case Status Detail: ", this.selectedStatusDetail);

      this.origenCita = data[0].Origin;
      this.consecutivo = data[0].Consecutivo__c;
      this.recordType = data[0].RecordTypeId;
      this.estatus = data[0].Status;
      this.origenCaso = data[0].Origin;
      this.ownerCaso = data[0].OwnerId;
      this.fechaAbierto = data[0].FechaEntrada__c;
      this.fechaCerrado = data[0].ClosedDate;
      this.lavado = data[0].Requiere_lavado__c;
      this.objetoValor = data[0].Objetos_de_valor__c;
      this.numeroGuia = data[0].N_mero_y_color_de_gu_a__c;
      this.colorGuia = data[0].Color_de_g_ia__c;
      this.objetoValorTXT = data[0].ObjetosValor__c;
      this.repuesto = data[0].Llevarse_repuestos__c;

      // this.fechaEntrada = data[0].FechaEntrada__c;
      if (data[0].FechaEntrada__c) {
        const fecha = new Date(data[0].FechaEntrada__c);
        const fechaFormateada = fecha.toLocaleDateString("es-ES");
        this.fechaEntrada = fechaFormateada;
      }
      this.cita = data[0].Cita__c;
      this.mecanicoAsignado = data[0].Mecanico_Asignado__c;
      this.comentarios = data[0].Detalle_Asesor__c;
      // this.comentarios = data[0].Description;
      // this.fechaIngreso = data[0].
      // this.diasEnProceso = data[0].
      // this.obcervaciones = data[0].
      // this.asesor = data[0].

      if (this.lavado === true) {
        this.lavadoFormat = "Si";
      } else if (this.lavado === false) {
        this.lavadoFormat = "No";
      }

      if (this.objetoValor === true) {
        this.objetoValorFormat = "Si";
      } else if (this.objetoValor === false) {
        this.objetoValorFormat = "No";
      }

      if (this.repuesto === true) {
        this.repuestoFormat = "Si";
      } else if (this.repuesto === false) {
        this.repuestoFormat = "No";
      }
    } else if (error) {
      console.log("Error de data", error);
    } else {
      console.log(error);
    }
  }

  connectedCallback() {
    this.loadOwnerName();
  }

  loadOwnerName() {
    getOwnerName({ caseId: this.recordId })
      .then((result) => {
        this.asesor = result;
      })
      .catch((error) => {
        console.error("Error fetching owner name:", error);
      });
  }
}