import { LightningElement, track } from "lwc"; 
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import searchVehicle from "@salesforce/apex/cT_Registro_Avaluos_ctrl.searchVehicle";
import saveAppraisal from "@salesforce/apex/cT_Registro_Avaluos_ctrl.saveAppraisal";
import getPromediosByAttributes from "@salesforce/apex/cT_Registro_Avaluos_ctrl.getPromediosByAttributes";
import saveFilesAV from "@salesforce/resourceUrl/saveFilesAV";

export default class CT_Registro_Avaluos_lwc extends LightningElement {
  @track viewState = "search";
  @track licensePlate = "";
  @track observations = "";
  @track moneda = "USD";
  @track suggestedValue = "";
  @track formatSuggestedBossValue = "No hay información";
  @track isLoading = false;
  @track error = "";
  @track vehicleData = {};
  @track vehiValue = "PAR";

  @track showMissingFieldsModal = false;
  @track missingFields = [];
  @track missingFieldsValues = {};
  @track isSaving = false;
  @track showPromedio = false;
  @track infoModal = false;

  saveFilesAv = saveFilesAV;

  requiredFields = [
    { name: "Marca__c", label: "Marca", type: "text", maxlength: 50 },
    { name: "Modelo__c", label: "Modelo", type: "text", maxlength: 50 },
    {
      name: "N_puertas__c",
      label: "N° Puertas",
      type: "number",
      min: 1,
      max: 10,
    },
    {
      name: "N_mero_de_Chasis__c",
      label: "Número de Chasis",
      type: "text",
      maxlength: 50,
    },
    { name: "Placa__c", label: "Placa", type: "text", maxlength: 50 },
    {
      name: "Propietario__c",
      label: "Propietario",
      type: "text",
      maxlength: 80,
    },
    {
      name: "Tracci_n__c",
      label: "Tracción",
      type: "picklist",
      options: [
        { label: "4x2", value: "4x2" },
        { label: "4x4", value: "4x4" },
      ],
    },
    {
      name: "Trasmision__c",
      label: "Transmisión",
      type: "picklist",
      options: [
        { label: "AUTOMATICA", value: "AUTOMATICA" },
        { label: "MANUAL", value: "MANUAL" },
      ],
    },
    {
      name: "Gravamenes_o_Multas__c",
      label: "Grabámenes o multas",
      type: "picklist",
      options: [
        { label: "Si", value: "Si" },
        { label: "No", value: "No" },
      ],
    },
    { name: "Estilo__c", label: "Estilo", type: "text", maxlength: 50 },
    {
      name: "Estilo_Usado__c",
      label: "Estilo Usado",
      type: "picklist",
      options: [
        { label: "CABRIOLET", value: "CABRIOLET" },
        { label: "COUPE", value: "COUPE" },
        { label: "HATCHBACK", value: "HATCHBACK" },
        { label: "MINIVAN", value: "MINIVAN" },
        { label: "SEDAN", value: "SEDAN" },
        { label: "TODO TERRENO", value: "TODO TERRENO" },
        { label: "CONVERTIBLE", value: "CONVERTIBLE" },
      ],
    },
    {
      name: "Capacidad_de_Personas__c",
      label: "Capacidad de Personas",
      type: "text",
      maxlength: 50,
    },
    { name: "Carrocer_a__c", label: "Carrocería", type: "text", maxlength: 80 },
    { name: "Categor_a__c", label: "Categoría", type: "text", maxlength: 80 },
    { name: "Cilindraje__c", label: "Cilindraje", type: "number", min: 0 },
    { name: "Color__c", label: "Color", type: "text", maxlength: 50 },
    {
      name: "Combustible__c",
      label: "Combustible",
      type: "picklist",
      options: [
        { label: "GASOLINA", value: "GASOLINA" },
        { label: "DIESEL", value: "DIESEL" },
        { label: "HÍBRIDO", value: "HÍBRIDO" },
        { label: "ELÉCTRICO", value: "ELÉCTRICO" },
      ],
    },
  ];

  // Propiedad computada para verificar si todos los campos obligatorios están completos
  get areAllMissingFieldsFilled() {
    return this.missingFields.every((field) => {
      const value =
        this.missingFieldsValues[field.name] || this.vehicleData[field.name];
      return value !== null && value !== undefined && value !== "";
    });
  }

  get options() {
    return [
      { label: "Automóvil", value: "PAR" },
      { label: "Motocicleta", value: "MOT" },
    ];
  }

  get monedaOptions() {
    return [{ label: "USD", value: "USD" }];
  }

  // Método para determinar la clase CSS de un campo
  fieldClass(fieldName) {
    const value =
      this.missingFieldsValues[fieldName] || this.vehicleData[fieldName];
    const isEmpty = value === null || value === undefined || value === "";
    return isEmpty ? "slds-has-error" : "";
  }

  // Método para mostrar el mensaje de error debajo del campo
  showFieldError(fieldName) {
    const value =
      this.missingFieldsValues[fieldName] || this.vehicleData[fieldName];
    return (
      (value === null || value === undefined || value === "") &&
      this.missingFields.some((f) => f.name === fieldName)
    );
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
    this.licensePlate = event.target.value;
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

          console.log("Resultado: ", this.vehicleData);

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
    const tieneGravamenes = response.cantidadEmbargos > 0 ? "Si" : "No";

    return {
      Marca__c: response.marca || "",
      Modelo__c: response.modelo || "",
      Motor__c: response.motor || "",
      N_puertas__c: response.n_puertas || null,
      N_mero_de_Chasis__c: response.numeroChasis || "",
      Placa__c: this.licensePlate,
      Propietario__c: response.propietario || "",
      Tracci_n__c: response.traccion || "",
      Trasmision__c: response.trasmision || "",
      Gravamenes_o_Multas__c: tieneGravamenes,
      Estilo__c: response.estilo || "Desconocido",
      Estilo_Usado__c: response.estilo_usado || "",
      Capacidad_de_Personas__c: response.capacidad || "",
      Carrocer_a__c: response.carroceria || "",
      Categor_a__c: response.categoria || "",
      Cilindraje__c: response.cilindraje || null,
      Color__c: response.color || "",
      Combustible__c: response.combustible || "",
      numeroVin: response.numeroVin || "",
      anio: response.anio || "",
      capacidadPersonas: response.capacidad || 0,
      placa: this.licensePlate,
      numeroChasis: response.numeroChasis || "",
      categoria: response.categoria || "",
      estilo: response.estilo || "Desconocido",
      color: response.color || "",
      cantidadEmbargos: response.cantidadEmbargos || 0,
      propietario: response.propietario || "",
      marca: response.marca || "",
      modelo: response.modelo || "",
      traccion: response.traccion || "",
      carroceria: response.carroceria || "",
      combustible: response.combustible || "",
    };
  }

  handleRegisterAppraisal() {
    this.missingFields = this.checkMissingFields();
    if (this.missingFields.length > 0) {
      this.showMissingFieldsModal = true;
    } else {
      this.viewState = "appraisal";
      this.consultarPromedios();
    }
  }

  handleSaveAppraisal() {
    if (!this.observations.trim() || !this.suggestedValue.trim()) {
      this.showToast(
        "Error",
        "Complete observaciones y valor sugerido",
        "error"
      );
      return;
    }

    this.saveAppraisalData();
  }

  handleInfoModalOpen() {
    this.infoModal = true;
  }

  handleInfoModalClose() {
    this.infoModal = false;
  }

  checkMissingFields() {
    return this.requiredFields
      .filter((field) => {
        const value = this.vehicleData[field.name];
        return value === null || value === undefined || value === "";
      })
      .map((field) => {
        return {
          ...field,
          isText: field.type === "text",
          isNumber: field.type === "number",
          isPicklist: field.type === "picklist",
        };
      });
  }

  handleMissingFieldChange(event) {
    const fieldName = event.target.dataset.field;
    let value = event.target.value;

    const uppercaseFields = [
      "Marca__c",
      "Modelo__c",
      "Tracci_n__c",
      "Trasmision__c",
      "Combustible__c",
    ];
    if (uppercaseFields.includes(fieldName)) {
      value = value.toUpperCase();
    }

    this.missingFieldsValues = {
      ...this.missingFieldsValues,
      [fieldName]: value,
    };
  }

  handleContinueAfterMissingFields() {
    this.vehicleData = {
      ...this.vehicleData,
      ...this.missingFieldsValues,
    };

    this.showMissingFieldsModal = false;
    this.viewState = "appraisal";
    this.consultarPromedios();
  }

  handleSaveMissingFields() {
    // Verificación adicional
    if (!this.areAllMissingFieldsFilled) {
      this.showToast("Error", "Por favor complete todos los campos", "error");
      return;
    }

    this.handleContinueAfterMissingFields();
  }

  handleCancelMissingFields() {
    this.showMissingFieldsModal = false;
    this.missingFields = [];
    this.missingFieldsValues = {};
  }

  saveAppraisalData() {
    this.isSaving = true;

    const appraisalData = {
      placa: this.vehicleData.Placa__c,
      observaciones: this.observations,
      valorSugerido: parseFloat(this.suggestedValue),
      vin: this.vehicleData.numeroVin,
      traccion: this.vehicleData.Tracci_n__c,
      carroceria: this.vehicleData.Carrocer_a__c,
      numeroChasis: this.vehicleData.N_mero_de_Chasis__c,
      categoria: this.vehicleData.Categor_a__c,
      estilo: this.vehicleData.Estilo__c,
      capacidadPersonas: this.vehicleData.Capacidad_de_Personas__c,
      anio: this.vehicleData.anio,
      color: this.vehicleData.Color__c,
      combustible: this.vehicleData.Combustible__c,
      cantidad_de_embargos: this.vehicleData.cantidadEmbargos,
      marca: this.vehicleData.Marca__c,
      modelo: this.vehicleData.Modelo__c,
      propietario: this.vehicleData.Propietario__c,
      moneda: this.moneda,
      motor: this.vehicleData.Motor__c,
      n_puertas: this.vehicleData.N_puertas__c,
      trasmision: this.vehicleData.Trasmision__c,
      gravamenes_o_multas: this.vehicleData.Gravamenes_o_Multas__c,
      estilo_usado: this.vehicleData.Estilo_Usado__c,
      carroceria: this.vehicleData.Carrocer_a__c,
      cilindraje: this.vehicleData.Cilindraje__c,
    };

    saveAppraisal(appraisalData)
      .then((recordId) => {
        this.infoModal = false;
        this.showToast("Éxito", "Avalúo guardado", "success");
        this.navigateToRecord(recordId);
        // this.resetForm();
      })
      .catch((error) => {
        this.infoModal = false;
        this.showToast("Error", error.body?.message || error.message, "error");
      })
      .finally(() => {
        this.infoModal = false;
        this.isSaving = false;
      });
  }

  navigateToRecord(recordId) {
    // this[NavigationMixin.Navigate]({
    //     type: 'standard__recordPage',
    //     attributes: {
    //         recordId: recordId,
    //         actionName: 'view'
    //     }
    // });
    location.replace(`/lightning/r/Avaluo__c/${recordId}/view`);
  }

  consultarPromedios() {
    const marca = this.vehicleData.Marca__c;
    const modelo = this.vehicleData.Modelo__c;
    const anio = this.vehicleData.anio;
    const combustible = this.vehicleData.Combustible__c;
    const traccion = this.vehicleData.Tracci_n__c;
    const trasmision = this.vehicleData.Trasmision__c;

    if (
      !marca ||
      !modelo ||
      !anio ||
      !combustible ||
      !traccion ||
      !trasmision
    ) {
      this.formatSuggestedBossValue = "Complete todos los campos";
      this.promedio = undefined;
      return;
    }

    getPromediosByAttributes({
      marca: marca,
      modelo: modelo,
      anio: anio,
      combustible: combustible,
      traccion: traccion,
      trasmision: trasmision,
    })
      .then((result) => {
        this.promedio = result;
        this.error = undefined;
        this.showPromedio = true;
        this.valorSugeridoSistema =
          this.promedio.Promedio_Jefe_Usados__c || "No hay información";
      })
      .catch((error) => {
        this.error = error.body?.message || "Error consultando promedios";
        this.formatSuggestedBossValue = "Error en consulta";
      });
  }

  resetForm() {
    this.licensePlate = "";
    this.observations = "";
    this.suggestedValue = "";
    this.vehicleData = {};
    this.viewState = "search";
    this.missingFields = [];
    this.missingFieldsValues = {};
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