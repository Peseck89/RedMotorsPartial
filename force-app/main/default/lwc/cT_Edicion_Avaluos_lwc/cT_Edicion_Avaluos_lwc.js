import { LightningElement, api, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";
import getAvaluoData from "@salesforce/apex/cT_Registro_Avaluos_ctrl.getAvaluoData";
import updateAvaluo from "@salesforce/apex/cT_Registro_Avaluos_ctrl.updateAvaluo";
import getPromedios from "@salesforce/apex/cT_Registro_Avaluos_ctrl.getPromedios";
import getCurrentUserProfileName from "@salesforce/apex/cT_Registro_Avaluos_ctrl.getCurrentUserProfileName";

export default class CT_Edicion_Avaluos_lwc extends LightningElement {
  @api recordId;
  vehicleData = {};
  @track suggestedValue = "";
  @track formatSuggestedValue;
  @track formatSuggestedBossValue;
  @track bossSuggestedValue = "";
  @track observations;
  @track promedios = {};
  @track promedioSistema = "";
  @track formatPromedioSistema = "";
  @track tipoMoneda;
  
  @track hasValidProfile = false;
  @track canEdit = false
  @track targetProfiles = [
    "Jefe de ventas",
    "System Administrator",
    "Administrador de Sistema",
  ];

  error;

  @wire(getCurrentUserProfileName)
  wiredProfile({ data, error }) {
    if (data) {
      const userProfile = data.toLowerCase();
      const profilesToCheck = this.targetProfiles.map((profile) =>
        profile.toLowerCase()
      );

      this.hasValidProfile = profilesToCheck.some((profile) =>
        userProfile.includes(profile)
      );

      this.canEdit = !this.hasValidProfile

      console.log('Puede editar? ', this.hasValidProfile, "Perfil: ", data);
      
    } else if (error) {
      console.error("Error al obtener perfil:", error);
    }
  }

  @wire(getAvaluoData, { recordId: "$recordId" })
  wiredAvaluo({ error, data }) {
    if (data) {
      this.vehicleData = {
        placa: data.Placa__c,
        numeroVin: data.VIN__c,
        traccion: data.Tracci_n__c,
        carroceria: data.Carrocer_a__c,
        numeroChasis: data.N_mero_de_Chasis__c,
        categoria: data.Categor_a__c,
        estilo: data.Estilo__c,
        capacidadPersonas: data.Capacidad_de_Personas__c,
        anio: data.Anio_Number__c,
        color: data.Color__c,
        combustible: data.Combustible__c,
        cantidadEmbargos: data.Cantidad_de_Embargos__c,
        marca: data.Marca__c,
        modelo: data.Modelo__c,
        moneda: data.CurrencyIsoCode,
        propietario: data.Propietario__c,
        observations: data.Observaciones__c,
        suggestedValue: data.Valor_Sugerido__c,
        bossSuggestedValue: data.Valor_Sugerido_Jefe_Usados__c,
      };
      this.tipoMoneda = data.CurrencyIsoCode; 
      this.observations = data.Observaciones__c || "";
      this.suggestedValue = data.Valor_Sugerido__c || "";

      this.formatSuggestedValue = Intl.NumberFormat("es-ES", {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
      }).format(this.suggestedValue);
      
      this.bossSuggestedValue = data.Valor_Sugerido_Jefe_Usados__c || 0;
      
      this.formatSuggestedBossValue = Intl.NumberFormat("es-ES", {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
      }).format(this.bossSuggestedValue);

      console.log(data);
    } else if (error) {
      console.log(data);
      console.error("Error cargando datos:", error);
    }
  }

  @wire(getPromedios, { avaluoId: "$recordId" })
  wiredPromedios({ error, data }) {
    if (data) {
      this.promedios = data;
      this.promedioSistema = data.Promedio_Jefe_Usados__c;
      this.formatPromedioSistema = Intl.NumberFormat("es-ES", {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
      }).format(this.promedioSistema);

      this.error = undefined;
      console.log("Promedios: ", data);
      console.log("Promedios valuador: ", data.Promedio_Jefe_Usados__c);
      console.log("Promedios formateado: ", this.formatPromedioSistema);
    } else if (error) {
      this.error = error;
      this.promedios = undefined;
      console.log("Promedios error: ", error);
    }
  }

  handleObservationsChange(event) {
    this.observations = event.target.value;
  }

  handleSuggestedValueChange(event) {
    this.suggestedValue = event.target.value;
  }

  handleBossSuggestedValueChange(event) {
    this.bossSuggestedValue = event.target.value;
  }

  handleSaveAppraisal() {
    if (!this.recordId || this.bossSuggestedValue == null) {
        this.showToast("Error", "Complete el valor del jefe de usados", "error");
        return;
    }

    const avaluoData = {
        recordId: this.recordId,
        observaciones: this.observations,
        valorJefeUsados: this.bossSuggestedValue
    };

    updateAvaluo(avaluoData)
        .then(() => {
            this.showToast("Éxito", "Avalúo actualizado correctamente", "success");
            // Recargar promedios después de la actualización
            window.location.reload();
            return refreshApex(this.wiredPromedios);
        })
        .catch((error) => {
            this.showToast("Error", error, "error");
            console.log('Error al actualizar el avaluo: ', error);
            
        });
  }

  // handleSaveAppraisal() {
  //   if (!this.recordId) {
  //     this.showToast("Error", "ID de registro no disponible", "error");
  //     return;
  //   }

  //   const avaluoData = {
  //     recordId: this.recordId,
  //     observaciones: this.observations,
  //     valorJefeUsados: this.bossSuggestedValue,
  //   };

  //   updateAvaluo(avaluoData)
  //     .then(() => {
  //       this.showToast("Éxito", "Avalúo actualizado correctamente", "success");
  //     })
  //     .catch((error) => {
  //       console.error("Error actualizando:", error);
  //       this.showToast("Error", error.body.message, "error");
  //     });
  // }

  showToast(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
      })
    );
  }
}