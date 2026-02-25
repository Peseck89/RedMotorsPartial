import { LightningElement, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import searchVehicle from "@salesforce/apex/cT_Registro_Avaluos_ctrl.searchVehicle";
import getPromediosConsul from '@salesforce/apex/cT_Registro_Avaluos_ctrl.getPromediosConsul';
 
export default class CT_Consulta_Avaluos_lwc extends LightningElement {
  @track viewState = "search";

  @track licensePlate = "";
  @track observations = "";
  @track moneda = "USD";
  @track suggestedValue = "";

  @track isLoading = false;
  @track error = "";

  @track vehicleData = null;

  @track vehiValue = "PAR";

  @track promediosList = [];

  get options() {
    return [
      { label: "Automóvil", value: "PAR" },
      { label: "Motocicleta", value: "MOT" },
    ];
  }

  get monedaOptions() {
    return [
      { label: "USD", value: "USD" },
      // { label: 'CRC', value: 'CRC' },
    ];
  }

  handleMonedaChange(event) {
    this.moneda = event.detail.value;
  }

  handleVhiChange(event) {
    this.vehiValue = event.detail.value;
  }

  handleBack() {
    if (this.viewState === "details") {
      this.viewState = "search";
    } else if (this.viewState === "appraisal") {
      this.viewState = "details";
    }
  }

  get isSearchView() {
    return this.viewState === "search";
  }

  get isDetailsView() {
    return this.viewState === "details";
  }

  get isAppraisalView() {
    return this.viewState === "appraisal";
  }

  get searchButtonLabel() {
    return this.isLoading ? "Consultando..." : "Consultar";
  }

  handleLicensePlateChange(event) {
    this.licensePlate = event.target.value.toUpperCase();
  }

  handleObservationsChange(event) {
    this.observations = event.target.value;
  }

  handleSuggestedValueChange(event) {
    this.suggestedValue = event.target.value;
  }

  handleSearch() {
    if (!this.licensePlate.trim()) {
      this.error = "Por favor ingrese un número de placa";
      return;
    }

    this.isLoading = true;
    this.error = "";

    searchVehicle({
      licensePlate: this.licensePlate.toUpperCase().trim(),
      tipoVehiculo: this.vehiValue,
    })
      .then((result) => {
        if (result.error) {
          this.error = result.error;
          this.showToast("Error", result.error, "error");
          return;
        }

        if (result.found) {
          this.vehicleData = this.mapResponseToFields(result);
          this.viewState = "details";

          console.log("Vehiculo: ", result);

          const source = result.source === "internal" ? "Salesforce" : "Credid";
          this.showToast(
            "Búsqueda Exitosa",
            `Datos obtenidos de ${source}`,
            "success"
          );

          this.consultarPromedios();
        } else {
          this.error = "Vehículo no encontrado en ningún sistema";
        }
      })
      .catch((error) => {
        this.error = `Error: ${error.body?.message || error.message}`;
        this.showToast("Error", this.error, "error");
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  mapResponseToFields(response) {
    this.marca = response.marca;
    this.modelo = response.modelo;
    this.anio = response.anio;
    this.combustible = response.combustible;
    this.traccion = response.traccion;

    return {
      placa: this.licensePlate.toUpperCase(),
      numeroVin: response.numeroVin || "",
      traccion: response.traccion || "",
      carroceria: response.carroceria || "",
      numeroChasis: response.numeroChasis || "",
      categoria: response.categoria || "",
      estilo: "", // Campo no existe en Asset
      capacidadPersonas: response.capacidad || 0,
      anio: response.anio || "",
      color: response.color || "",
      combustible: response.combustible || "",
      cantidadEmbargos: response.cantidadEmbargos || 0,
      marca: response.marca || "",
      modelo: response.modelo || "",
      propietario: response.propietario || "",
    };
  }

  mapApiResponseToVehicleData(apiData) {
    const ownerInfo = apiData.Dato?.InformacionPropietario?.[0] || {};

    return {
      placa: this.licensePlate.toUpperCase(),
      numeroVin: apiData.Dato?.NumeroVinCarroceria || "",
      traccion: apiData.Dato?.Traccion || "",
      carroceria: apiData.Dato?.Carroceria || "",
      numeroChasis: apiData.Dato?.NumeroChasis || "",
      categoria: apiData.Dato?.TipoCategoria || "",
      estilo: apiData.Dato?.Estilo || "",
      capacidadPersonas: apiData.Dato?.Capacidad || 0,
      año: apiData.Dato?.Anio || "",
      color: apiData.Dato?.Color || "",
      combustible: apiData.Dato?.Motor?.Combustible || "",
      cantidadEmbargos: apiData.Dato?.CantidadEmbargos || 0,
      marca: apiData.Dato?.Marca || "",
      modelo: apiData.Dato?.Modelo || "",
      propietario: ownerInfo.Nombre || "",
      valorHacienda: apiData.Dato?.ValorHacienda || 0,
      fechaInscripcion:
        apiData.Dato?.InformacionRegistral?.FechaInscripcion || "",
      motorNumero: apiData.Dato?.Motor?.Numero || "",
      cilindrada: apiData.Dato?.Motor?.Cilindrada || 0,
      infracciones: apiData.Dato?.Infracciones?.length || 0,
      levantamientos: apiData.Dato?.Levantamientos?.length || 0,
    };
  }

  handleRegisterAppraisal() {
    this.viewState = "appraisal";
  }

  get formatPromedioValuador() {
    return this.formatCurrency(this.promedio?.Promedio_Valuador__c);
  }

  get formatPromedioJefe() {
    return this.formatCurrency(this.promedio?.Promedio_Jefe_Usados__c);
  }

  consultarPromedios() {
    console.log('Entro consulta promedios');
    
    getPromediosConsul({
      marca: this.marca,
      modelo: this.modelo,
      anio: this.anio,
      combustible: this.combustible,
      traccion: this.traccion,
    })
      .then((result) => {
        console.log('Entro al result');
        
        if (Array.isArray(result)) {
          this.promediosList = result;
          console.log('Promedios obtenidos: ', this.promediosList);
          if (result.length > 0) {
            // Tomar el primer resultado como el promedio principal
            this.promedio = result[0];
          }
        } else {
          // Manejo para respuesta no array (backward compatibility)
          this.promedio = result;
          this.promediosList = result ? [result] : [];
          console.log('Promedios obtenidos: ', this.promediosList);
        }
        this.error = undefined;
      })
      .catch((error) => {
        console.log('Entro a catch error', error);
        
        this.error =
          error.body?.message ||
          "No se encontraron promedios para estos valores";
        this.promedio = undefined;
        this.promediosList = [];
      });
  }

  // Función para formatear moneda
  formatCurrency(value) {
    return value != null
      ? new Intl.NumberFormat("es-ES", {
          style: "currency",
          currency: "USD",
          minimumFractionDigits: 2,
        }).format(value)
      : "N/A";
  }

  resetForm() {
    this.licensePlate = "";
    this.observations = "";
    this.suggestedValue = "";
    this.vehicleData = null;
    this.viewState = "search";
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant,
    });
    this.dispatchEvent(event);
  }
}