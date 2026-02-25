import { LightningElement, api, track, wire } from "lwc";
import getAvaluosValidos from "@salesforce/apex/cT_Registro_Avaluos_ctrl.getAvaluosValidos";
import getPromedios from "@salesforce/apex/cT_Registro_Avaluos_ctrl.getPromedios";
import updateAvaluoOpportunity from "@salesforce/apex/cT_Registro_Avaluos_ctrl.updateAvaluoOpportunity";
import getLinkedAvaluos from "@salesforce/apex/cT_Registro_Avaluos_ctrl.getLinkedAvaluos";
import getOpportunityData from "@salesforce/apex/cT_Registro_Avaluos_ctrl.getOpportunityData";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class CT_Lista_Avaluos_Opportunity_lwc extends LightningElement {
  @api recordId;
  @track avaluos = [];
  @track linkedAvaluos = [];
  @track isModalOpen = false;
  @track selectedAvaluo = null;
  @track oppAvaluo = null;
  @track avOpp = null;
  @track promediosData = null;
  @track placaBusqueda = "";
  @track selectedType = "PAR";
  @track tipoOpciones = [
    { label: "Automóvil", value: "PAR" },
    { label: "Motocicleta", value: "MOT" },
  ];
  @track kilometraje;
  @track loading = false;

  @wire(getLinkedAvaluos, { opportunityId: "$recordId" })
  wiredLinkedAvaluos({ error, data }) {
    if (data) {
      this.rawLinkedAvaluos = data;
      console.log("Wired Linked Avaluos: ", data);

      this.linkedAvaluos = data.map((av) => ({
        ...av,
        recordUrl: `/lightning/r/Avaluo__c/${av.Id}/view`,
      }));
    } else if (error) {
      this.dispatchToast("Error", error.body.message, "error");
    }
  }

  @wire(getOpportunityData, { recordId: "$recordId" })
  wiredOpportunity({ error, data }) {
    if (data) {
      this.opportunityData = data;
      this.avOpp = data.Avaluo_Vinculado__c || null;
      this.error = undefined;
      console.log("Datos obtenidos:", JSON.parse(JSON.stringify(data)));
      console.log("Avalúo de la OPP: ", this.avOpp);
    } else if (error) {
      this.error = error;
      this.opportunityData = undefined;
      console.error("Error:", error);
    }
  }

  handleKilometrajeChange(event) {
    this.kilometraje = event.target.value;
  }

  handleSearch() {
    if (this.placaBusqueda === "") {
      this.dispatchToast("Error", "Debe ingresar una placa", "error");
      return;
    }

    getAvaluosValidos({
      placa: this.placaBusqueda.toUpperCase().trim(),
      tipoVehiculo: this.selectedType,
    })
      .then((result) => {
        this.avaluos = result.map((avaluo) => ({
          ...avaluo,
          recordUrl: `${window.location.origin}/lightning/r/Avaluo__c/${avaluo.Id}/view`,
        }));

        console.log("Resultado busqueda avaluos: ", result);

        if (this.avaluos.length === 0) {
          this.dispatchToast(
            "Información",
            "No se encontraron avalúos",
            "info"
          );
        }
      })
      .catch((error) => {
        this.dispatchToast("Error", error.body.message, "error");
      });
  }

  // Manejadores de cambios
  handlePlacaChange(event) {
    this.placaBusqueda = event.target.value;
  }

  handleTypeChange(event) {
    this.selectedType = event.detail.value;
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("es-ES", {
      style: "currency",
      currency: "CRC",
      minimumFractionDigits: 2,
    }).format(value || 0);
  }

  handleOpenModal() {
    this.isModalOpen = true;
    getAvaluosValidos()
      .then((result) => {
        this.avaluos = result;
      })
      .catch((error) => {
        this.dispatchToast("Error", error.body.message, "error");
      });
  }

  async handleViewDetails(event) {
    const avaluoId = event.target.dataset.id;
    this.selectedAvaluo = this.avaluos.find((av) => av.Id === avaluoId);
    this.oppUrl =
      `/lightning/r/Opportunity/${this.selectedAvaluo.Opportunity__c}/view` ||
      null;
    this.oppAvaluo = this.selectedAvaluo.Opportunity__c || null;

    console.log("Avaluo seleccionado: ", this.selectedAvaluo);
    console.log("Opp Avaluo seleccionado: ", this.oppAvaluo);

    // Obtener promedios
    try {
      this.promediosData = await getPromedios({
        avaluoId: this.selectedAvaluo.Id,
      });
    } catch (error) {
      this.promediosData = null;
      this.dispatchToast(
        "Advertencia",
        "Este avalúo no tiene promedio de sistema",
        "warning"
      );
    }
  }

  handleLigarAvaluo() {
    if (!this.kilometraje || isNaN(this.kilometraje)) {
      this.dispatchToast("Error", "Kilometraje inválido", "error");
      return;
    }

    const avaluoYaVinculado = this.rawLinkedAvaluos?.some(
      (av) => av.Id === this.selectedAvaluo.Id
    );

    if (avaluoYaVinculado) {
      this.dispatchToast(
        "Error",
        "Este avalúo ya está vinculado a esta oportunidad",
        "error"
      );
      return;
    }

    if (!this.selectedAvaluo?.Valor_Sugerido_Jefe_Usados__c) {
      this.dispatchToast("Error", "Falta valor de jefe de usados", "error");
      return;
    }

    if (this.selectedAvaluo?.Serecibevehiculo__c === true) {
      this.dispatchToast(
        "Error",
        "El vehículo relacionado a este avalúo ya se recibió en inventario",
        "error"
      );
      return;
    }

    this.loading = true;

    updateAvaluoOpportunity({
      recordId: this.selectedAvaluo.Id,
      oportunidadId: this.recordId,
      kilometraje: this.kilometraje,
    })
      .then(() => {
        this.loading = false;
        this.dispatchToast("Éxito", "Avalúo vinculado", "success");
        return getLinkedAvaluos({ opportunityId: this.recordId });
      })
      .then((result) => {
        this.linkedAvaluos = result.map((av) => ({
          ...av,
          recordUrl: `/lightning/r/Avaluo__c/${av.Id}/view`,
        }));
        this.closeAllModals();
        this.loading = false;
        window.location.reload();
      })
      .catch((error) => {
        this.dispatchToast("Error", error.body.message, "error");
        console.log("Error al vincular el avalúo: ", error.body.message);

        this.loading = false;
      });
  }

  // Metodo viejo para ligar el avaluo
  // handleLigarAvaluo() {
  //   if (!this.kilometraje || isNaN(this.kilometraje)) {
  //     this.dispatchToast(
  //       "Error",
  //       "Ingrese un valor de kilometraje válido",
  //       "error"
  //     );
  //     return;
  //   } else if (
  //     this.selectedAvaluo.Valor_Sugerido_Jefe_Usados__c === null ||
  //     this.selectedAvaluo.Valor_Sugerido_Jefe_Usados__c === "" ||
  //     this.selectedAvaluo.Valor_Sugerido_Jefe_Usados__c === undefined
  //   ) {
  //     this.dispatchToast(
  //       "Error",
  //       "Este avalúo no tiene valor de jefe de usados",
  //       "error"
  //     );
  //     return;
  //   }

  //   updateAvaluoOpportunity({
  //     recordId: this.selectedAvaluo.Id,
  //     oportunidadId: this.recordId,
  //     kilometraje: this.kilometraje,
  //   })
  //     .then(() => {
  //       this.dispatchToast(
  //         "Éxito",
  //         "Avalúo vinculado a la oportunidad",
  //         "success"
  //       );
  //       this.closeAllModals();
  //       this.avaluos = this.avaluos.filter(
  //         (av) => av.Id !== this.selectedAvaluo.Id
  //       );
  //       window.location.reload();
  //     })
  //     .catch((error) => {
  //       const errorMessage =
  //         error?.body?.message ||
  //         error?.message ||
  //         "Error desconocido al vincular el avalúo";
  //       // this.dispatchToast("Error", errorMessage, "error");

  //       console.log("Error: ", error);
  //     });
  // }

  closeModal() {
    this.isModalOpen = false;
  }

  closeDetailsModal() {
    this.selectedAvaluo = null;
  }

  closeAllModals() {
    this.isModalOpen = false;
    this.selectedAvaluo = null;
  }

  dispatchToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }

  // Seleccionar avalúo y vincularlo a la oportunidad
  handleSelectAvaluo(event) {
    const avaluoId = event.target.dataset.id;
    this.updateAvaluoOpportunity(avaluoId);
    this.isModalOpen = false;
  }
}
// Actualizar el campo Oportunidad__c en el avalúo
// updateAvaluoOpportunity(avaluoId) {
//   updateAvaluo({
//     recordId: avaluoId,
//     oportunidadId: this.recordId,
//   })
//     .then(() => {
//       this.dispatchEvent(
//         new ShowToastEvent({
//           title: "Éxito",
//           message: "Avalúo vinculado a la oportunidad",
//           variant: "success",
//         })
//       );
//     })
//     .catch((error) => {
//       this.dispatchEvent(
//         new ShowToastEvent({
//           title: "Error",
//           message: error.body.message,
//           variant: "error",
//         })
//       );
//     });
// }