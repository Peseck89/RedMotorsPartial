import { LightningElement, track, wire, api } from "lwc";
import USER_ID from "@salesforce/user/Id";
import LightningAlert from "lightning/alert";
import { getRecord } from "lightning/uiRecordApi";
import NAME_FIELD from "@salesforce/schema/User.Name";
import CONTACT_OBJECT from "@salesforce/schema/Contact";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getAsset from "@salesforce/apex/cT_nuevaCitaGarantia_controller.getAsset";
import checkTiempos from "@salesforce/apex/getHorasCitasFlow.checkTiempos";
import getCedula from "@salesforce/apex/cT_nuevaCitaGarantia_controller.getCedula";
import getActivity from "@salesforce/apex/cT_nuevaCitaGarantia_controller.getActives";
import getAsesores from "@salesforce/apex/cT_nuevaCitaGarantia_controller.getAsesores";
import getServiceT from "@salesforce/apex/cT_nuevaCitaGarantia_controller.getServiceT";
import createEvent from "@salesforce/apex/cT_nuevaCitaGarantia_controller.createEvent";
import getUrlEvent from "@salesforce/apex/cT_nuevaCitaGarantia_controller.getUrlEvent";
import otrosEventos from "@salesforce/apex/cT_nuevaCitaGarantia_controller.otrosEventos";
import guardarAsset from "@salesforce/apex/cT_nuevaCitaGarantia_controller.guardarAsset";
import updateContact from "@salesforce/apex/cT_nuevaCitaGarantia_controller.updateContact";
import updateAccount from "@salesforce/apex/cT_nuevaCitaGarantia_controller.updateAccount";
import getCalendario from "@salesforce/apex/cT_nuevaCitaGarantia_controller.getCalendario";
import getDataAsesor from "@salesforce/apex/cT_nuevaCitaGarantia_controller.getDataAsesor";
import createAccount from "@salesforce/apex/cT_nuevaCitaGarantia_controller.createAccount";
import getKilometros from "@salesforce/apex/cT_nuevaCitaGarantia_controller.getKilometros";
import TIPO_DOCUMENTO_FIELD from "@salesforce/schema/Contact.Tipo_de_Documento__c";
import createContact from "@salesforce/apex/cT_nuevaCitaGarantia_controller.createContact";
import getCurrentUser from "@salesforce/apex/cT_nuevaCitaGarantia_controller.getCurrentUser";
import buscarDuplicado from "@salesforce/apex/cT_nuevaCitaGarantia_controller.buscarDuplicado";
import getDependentMap from "@salesforce/apex/cT_nuevaCitaGarantia_controller.getDependentMap";
import getSeguroDetails from "@salesforce/apex/cT_nuevaCitaGarantia_controller.getSeguroDetails";
import updateContactData from "@salesforce/apex/cT_nuevaCitaGarantia_controller.updateContactData";
import getDataCalendario from "@salesforce/apex/cT_nuevaCitaGarantia_controller.getDataCalendario";
import updateDataAccount from "@salesforce/apex/cT_nuevaCitaGarantia_controller.updateDataAccount";
import verifyContactData from "@salesforce/apex/cT_nuevaCitaGarantia_controller.verifyContactData";
import updateEventOrigen from "@salesforce/apex/cT_nuevaCitaGarantia_controller.updateEventOrigen";
import actualizarHorarios from "@salesforce/apex/cT_nuevaCitaGarantia_controller.actualizarHorarios";
import obtenerDisponibilidadProximosDias from "@salesforce/apex/cT_nuevaCitaGarantia_controller.obtenerDisponibilidadProximosDias";
//import getMantenimiento from  '@salesforce/apex/cT_nuevaCitaGarantia_controller.getMantenimiento';
//import getCampaniasByAssetId from "@salesforce/apex/cT_nuevaCitaGarantia_controller.getCampaniasByAssetId";
//import confirmarCampanias from "@salesforce/apex/cT_nuevaCitaGarantia_controller.confirmarCampanias";

// import generateData from "./cT_generateData";


const columns = [
  { label: "Fecha de inicio", fieldName: "fecha" },
  { label: "Asigned User", fieldName: "user" },
  { label: "Origen", fieldName: "origen" },
  { label: "Calendario", fieldName: "calendario" },
  { label: "Start Date Time", fieldName: "dateTime" },
];

export default class CT_nuevaCitaGarant_lwc extends LightningElement {
  @api recordId;
  @track userId = USER_ID;
  @track userName;
  // Datos para el select de Origen
  @track esContact = false;
  @track assetPlaca = "";
  @track assetVin = "";
  @track urlExiste = true;
  @track esteRecord;
  @track placa;
  @track tipoVehiculo;
  @track numeroChasis;
  @track motor;
  @track salesforceArrayAsesor;
  @track color;
  @track anioVehiculo;
  @track kilometros;
  @track parentAccountSelectedRecord;
  @track parentContactSelectedRecord;
  @track marcaVehiculo;
  @track modeloVehiculo;
  @track marcaOtros;
  @track esCallCenter;
  @track modeloOtros;
  @track marca;
  @track modelo;
  @track modalOptionsMarca;
  @track modalOptionsModelo;
  @track esMoto;
  @track mostrarHoras = false;
  @track noValidar = true;
  //DATOS CUENTA
  @track nombreCuenta;
  @track apellidoCuenta;
  @track apellido;
  @track identificacion;
  @track cedula;
  @track cedulaBuscada;
  @track telefono;
  @track fechaNacimiento;
  @track correoElectronico;
  @track personalEmail;
  @track nombreEncargado;
  @track telefonoEncargado;
  @track showCrtMotos = false;
  @track infoData = false;
  //DATOS CONTACTO
  @track nombreContacto;
  @track apellidoContacto;
  @track telefonoContacto;
  @track correoContacto;
  @track ignorarDuplicado = false;

  //datos evento
  @track fechaSeleccionada;
  @track asesorSel;
  @track calendarioSel;
  @track descripcion;
  @track nuevaFecha;
  @track urlEvento = "";
  picklistOptions = [];
  // Formateo de fecha y hora
  timeZoneOffset = "-06:00";
  ampm = true;

  // Cuenta Personal o Empresarial
  @track personalAccount = false;

  @track mostrarFechaCambio = false;

  @track hasWarrantyPlan = false;

  @track editAccountOwner = false;

  @track editDateAndHour = false;
  @track editPhoneAccount = false;
  @track editEmailAccount = false;

  @track editContact = false;
  @track doCloseModal = true;
  //campos para cambio de fecha Hora
  @track optionsHorarios;
  @track horaElegida;
  @track serviceTerritory;

  @track campaniasTec = false;
  @track campanias;
  //Nuevo para garantia
  @track esGarantias = false;
  @track mostrarHorariosSugeridos = false;
  @track horariosSugeridos = [];
  //nuevo para fechas
  @track fechaActual = new Date();
  @track ultimaFecha;
  @track fechaRespaldo;
  @track horariosSugeridos = [];
  @track paginasFechas = [];
  @track paginaActual = 0;
  @track sinPagina = false;

  // Añade este getter a tu clase
  get messageStyle() {
    return this.resultado.aplicaGarantia ? "color: green" : "color: red";
  }

  handleChangeDateAndHou() {
    this.editDateAndHour = !this.editDateAndHour;
    this.mostrarFechaCambio = false;
  }

  handleChangePhoneAccount() {
    this.editPhoneAccount = !this.editPhoneAccount;
  }

  handleChangeEmailAccount() {
    this.editEmailAccount = !this.editEmailAccount;
  }

  handleEditContact() {
    this.editContact = !this.editContact;
    this.cambioCuenta = false;
    this.noExisteCuenta = false;
    this.actuCuenta = true;
  }

  @wire(getRecord, { recordId: USER_ID, fields: [NAME_FIELD] })
  wiredUser({ error, data }) {
    if (data) {
      this.userName = data.fields.Name.value;
    } else if (error) {
      console.error(error);
    }
  }

  @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
  contactObjectInfo;

  // Get the picklist values based on the Contact object and Tipo_de_Documento__c field
  @wire(getPicklistValues, {
    recordTypeId: "$contactObjectInfo.data.defaultRecordTypeId",
    fieldApiName: TIPO_DOCUMENTO_FIELD,
  })
  wiredPicklistValues({ error, data }) {
    if (data) {
      this.picklistOptions = data.values.map((option) => ({
        label: option.label,
        value: option.value,
      }));
    } else if (error) {
      console.error("Error fetching picklist values:", error);
    }
  }
  @wire(getCalendario, {})
  wiredHubs(result) {
    if (result.data) {
      console.log("data");
      console.log(result);
      console.log(result.data);
      this.salesforceArray = result.data;
    }
  }

  handleHoraSeleccionada(event) {
    const fechaStr = event.target.dataset.fecha;
    const horaStr = event.target.dataset.hora;

    const [day, month, year] = fechaStr.split("/");

    const fechaHoraISO = `${year}-${month}-${day}T${horaStr}:00`;

    const fechaHora = new Date(fechaHoraISO);

    const offsetMinutes = fechaHora.getTimezoneOffset();
    const offsetHours = Math.abs(Math.floor(offsetMinutes / 60));
    const offsetRemainder = Math.abs(offsetMinutes % 60);
    const offsetSign = offsetMinutes > 0 ? "-" : "+";
    const offsetStr = `${offsetSign}${String(offsetHours).padStart(
      2,
      "0"
    )}:${String(offsetRemainder).padStart(2, "0")}`;

    const fechaHoraSalesforce = `${year}-${month}-${day}T${horaStr}:00.000${offsetStr}`;

    this.fechaSeleccionada = fechaHoraSalesforce;

    this.dispatchEvent(
      new ShowToastEvent({
        title: "Hora seleccionada",
        message: `Fecha asignada: ${fechaStr} ${horaStr}`,
        variant: "success",
      })
    );
  }

  async inicializarHorarios() {
    try {
        const hoy = new Date();
        const resultado = await obtenerDisponibilidadProximosDias({
            fechaInicial: hoy.toISOString()
        });
        console.log('=============== resultado ===============');
        console.log(resultado);

        if (Array.isArray(resultado) && resultado.length > 0) {
            const resultadoFiltrado = resultado.filter(dia => Array.isArray(dia.horarios) && dia.horarios.length > 0);
            console.log('=============== Horarios Actuales ==================');
            console.log(resultadoFiltrado);
            this.horariosSugeridos = resultadoFiltrado.map((dia) => ({
                ...dia,
                mostrarTodos: false,
                mostrarBoton: dia.horarios.length > 0,
                // mostrarBoton: dia.horarios.length > 4,
                // horariosVisibles: dia.horarios.slice(0, 4)
                horariosVisibles: []
            }));
            this.paginasFechas = [hoy];
            this.paginaActual = 0;
            this.mostrarHorariosSugeridos = this.serviceTerritory === "Garantías";
            this.sinPagina = true;
        }
    } catch (error) {
      console.log(error);
        console.error('Error al inicializar horarios:', error);
        
    }
  }

  async volverHorarios() {
    if (this.paginaActual === 0) return;

    try {
        this.paginaActual--;
        if(this.paginaActual == 0){
          this.sinPagina = true;
        }else{
          this.sinPagina = false;
        }
        const fechaBase = this.paginasFechas[this.paginaActual];

        const resultado = await obtenerDisponibilidadProximosDias({
            fechaInicial: fechaBase.toISOString()
        });

        if (Array.isArray(resultado) && resultado.length > 0) {
            this.horariosSugeridos = resultado.map((dia) => ({
                ...dia,
                mostrarTodos: false,
                mostrarBoton: dia.horarios.length > 0,
                horariosVisibles: []
                // mostrarBoton: dia.horarios.length > 4,
                // horariosVisibles: dia.horarios.slice(0, 4)
            }));
        } else {
            console.warn('No se pudieron cargar los horarios anteriores.');
        }
    } catch (error) {
        console.error('Error al volver horarios:', error);
    }
  }

  async irHorarios() {
    try {
        const fechaBase = this.paginasFechas[this.paginaActual];
        const fechaNueva = new Date(fechaBase);
        fechaNueva.setDate(fechaNueva.getDate() + 5);

        const resultado = await obtenerDisponibilidadProximosDias({
            fechaInicial: fechaNueva.toISOString()
        });

        if (Array.isArray(resultado) && resultado.length > 0) {
            this.horariosSugeridos = resultado.map((dia) => ({
                ...dia,
                mostrarTodos: false,
                mostrarBoton: dia.horarios.length > 0,
                horariosVisibles: []
                // mostrarBoton: dia.horarios.length > 4,
                // horariosVisibles: dia.horarios.slice(0, 4)
            }));
            this.paginaActual++;
            if(this.paginaActual == 0){
              this.sinPagina = true;
            }else{
              this.sinPagina = false;
            }
            this.paginasFechas[this.paginaActual] = fechaNueva;
        } else {
            console.warn('No hay más horarios disponibles.');
        }
    } catch (error) {
        console.error('Error al avanzar horarios:', error);
    }
  }


  toggleHorarios(event) {
    const fecha = event.currentTarget.dataset.fecha;

    // Crear nuevo array para reactividad
    const nuevosHorarios = [...this.horariosSugeridos];

    // Buscar el día correspondiente
    const diaIndex = nuevosHorarios.findIndex((d) => d.fecha === fecha);
    const dia = nuevosHorarios[diaIndex];

    if (dia.mostrarTodos) {
      // Colapsar: mostrar solo 4
      nuevosHorarios[diaIndex] = {
        ...dia,
        mostrarTodos: false,
        horariosVisibles: [],
        // horariosVisibles: dia.horarios.slice(0, 4),
      };
    } else {
      // Expandir: mostrar todos y colapsar otros días
      nuevosHorarios.forEach((d, index) => {
        if (d.fecha === fecha) {
          nuevosHorarios[index] = {
            ...d,
            mostrarTodos: true,
            horariosVisibles: [...d.horarios],
          };
        } else if (d.mostrarTodos) {
          nuevosHorarios[index] = {
            ...d,
            mostrarTodos: false,
            horariosVisibles: [],
            // horariosVisibles: d.horarios.slice(0, 4),
          };
        }
      });
    }

    this.horariosSugeridos = nuevosHorarios;
  }

  connectedCallback() {
    this.fetchUserInfo();
    //this.cargarHorariosSugeridos();
    this.inicializarHorarios();
    this.validateGarantiasCalendar();
  }

  fetchUserInfo() {
    getCurrentUser()
      .then((user) => {
        console.log("user.name ", user.Name);
        if (user.Name.includes("Call") || user.Name.includes("Call Center")) {
          this.esContact = true;
        }
      })
      .catch((error) => {
        console.error("Error fetching user:", error);
      });
  }

  @wire(getAsesores, { calendario: "$calendarioSel" })
  wiredAsesor(result) {
    if (result.data) {
      console.log("data");
      console.log(result);
      console.log(result.data, "Asesores");
      this.salesforceArrayAsesor = result.data;

      if (this.calendarioSel === '005PH00000Bg7jVYAR') {
        this.nombreAsesor = 'María Solís Sancho'
        this.valueAsesor = '0054U00000BfakZQAR'
      }
    }
  }

  validateGarantiasCalendar() {
    if (this.calendarioSel === "005Nq00000KfKItIAN" || this.calendarioSel === "005PH00000Bg7jVYAR") {
      this.mostrarHorariosSugeridos = true;
    } else {
      this.mostrarHorariosSugeridos = false;
    }
  }

  handleChangeCalendario(event) {
    this.calendarioSel = event.detail.value;

    this.validateGarantiasCalendar();
    
    // console.log('Calendario seleccionado', this.calendarioSel);
    // console.log('Mostrar horarios sugeridos:', this.mostrarHorariosSugeridos);

    getServiceT({ calendarioSel: this.calendarioSel })
      .then((result) => {
        console.log("Record: " + result);
        if (result) {
          this.serviceTerritory = result;
        }
        this.validateGarantiasCalendar();
      })
      .catch((error) => {
        console.error("Error getting Service", error);
      });

    this.optionsAsesor;
  }

  handleChangeAsesor(event) {
    this.asesorSel = event.detail.value;

    this.valueAsesor = this.asesorSel;
    console.log(this.asesorSel);
  }

  get optionsCalendario() {
    var tempArray = this.salesforceArray;
    var convertedArray = null;
    if (Array.isArray(tempArray) && tempArray.length > 0) {
      convertedArray = tempArray.map((item) => ({
        label: item.Name,
        value: item.Id,
      }));
    }
    // console.log("convertedArray", tempArray);
    return convertedArray;
  }
  
  get optionsAsesor() {
    var tempArray = this.salesforceArrayAsesor;
    var convertedArray = null;
    if (Array.isArray(tempArray) && tempArray.length > 0) {
      convertedArray = tempArray.map((item) => ({
        label: item.Name,
        value: item.Id,
      }));
    }
    return convertedArray;
  }

  // Metadatos Tabla
  data = [];
  columns = columns;
  tieneCalendario = false;
  tieneAsesor = false;
  nombreAsesor = "";
  nombreCalendario = "";
  placeholder = "";

  @wire(getActivity, { recordId: "$recordId" })
  wiredRecordTypes({ error, data }) {
    if (data) {
      console.log("esto regreso data");
      console.log(data);
      this.calendarioSel = data[0].idCalendarioFlow__c;
      console.log("data[0].OrigenEvento__c ", data[0].OrigenEvento__c);
      this.value = data[0].OrigenEvento__c;
      if (this.value == "Contact Center") {
        this.esContact = true;
      }

      console.log(
        "=======================this.calendarioSel======================="
      );
      console.log(this.calendarioSel);
      if (this.calendarioSel != null || this.calendarioSel != "") {
        getDataCalendario({ calendarId: this.calendarioSel })
          .then((result) => {
            if (result) {
              this.nombreCalendario = result[0].Name;
            }
          })
          .catch((error) => {});
        this.tieneCalendario = true;
      }

      this.assetPlaca = data[0].Activo__c;
      console.log(" this.value1 ", this.value);
      console.log(" this.assetPlaca222 ", this.assetPlaca);

      if (data[0]?.Asesor__r?.Name == "Calendario Garantías") {
        console.log("es Garantias");
        this.assetPlaca = data[0]?.Activo__c;
        this.value = "Contact Center";
        this.esGarantias = true;
      }

      if (
        this.assetPlaca != null &&
        this.assetPlaca != undefined &&
        this.value != null &&
        this.value != undefined
      ) {
        this.infoData = true;
        console.log(" this.infoData ", this.infoData);
      }
      console.log(" this.infoData ", this.infoData);

      if (this.assetPlaca != null || this.assetPlaca != undefined) {
        this.placeholder = data[0].Activo__r.numeroDePlaca__c;
      }

      this.valueAsesor = data[0].Asesor__c;
      console.log(
        "=======================this.valueAsesor======================="
      );
      console.log(this.valueAsesor);
      this.nombreAsesor = data[0].Asesor__r.Name;
      if (this.nombreAsesor.includes("Calendario")) {
      } else {
        if (this.valueAsesor != null || this.valueAsesor != "") {
          this.tieneAsesor = true;
        }
      }

      this.fechaSeleccionada = data[0].StartDateTime;
      if (this.calendarioSel == null || this.calendarioSel == "") {
        this.calendarioSel = data[0].OwnerId;
      }

      this.esteRecord = data[0].Id;
      this.descripcion = data[0].Description;
      this.serviceTerritory = data[0].ServiceTerritory__r.Name;
      console.log('OwnerId del evento:', data[0].OwnerId);
      console.log('Asesor del evento:', data[0].Asesor__c);
      console.log('ServiceTerritory__c del evento:', data[0].ServiceTerritory__c);
      console.log('Nombre del Service Territory:', data[0].ServiceTerritory__r.Name);
      console.log('Options Calendario:', JSON.stringify(this.optionsCalendario));
      console.log('Options Asesor:', JSON.stringify(this.optionsAsesor));
    } else if (error) {
      console.error("Error fetching Opportunity record types", error);
    }
  }

  @wire(otrosEventos, { cocheId: "$assetPlaca", cocheVin: "$assetVin" })
  wiredRecordEvents({ error, data }) {
    console.log("================otrosEventos==================");
    console.log("data ", data);
    console.log("this.assetPlaca ", this.assetPlaca);
    console.log("this.assetVin ", this.assetVin);
    if (data && Array.isArray(data) && data.length > 0) {
      data.forEach((con) => {
        var conData = new Object();
        conData.fecha = con.StartDateTimeF__c;
        conData.user = con.AsignedUserFormula__c;
        conData.origen = con.OrigenEvento__c;
        conData.calendario = con.Calendario__c;
        conData.dateTime = con.StartDateTime;
        console.log("==================conData==================");
        console.log(conData);
        console.log(conData.user);
        this.data.push(conData);
      });
    } else if (error) {
      console.error("Error fetching Opportunity record types", error);
    }
  }

  @track noContactExist = false;
  @track showCrtContactModal = false;
  @track AssetWarrantyNumber;
  @track AssetWarrantyTerm;
  @track AssetWarrantyStartDate;
  @track AssetWarrantyEfectiveEndDate;
  @track AssetWarrantyEfectiveStartDate;
  @track AssetWarantyType;

  @track contactName;
  @track contactPhone;
  @track contactEmail;
  @track tipoIdentificacion;
  @track identificacionContacto;

  @track isModalOpen = false;
  @track firstStep = true;
  @track stepTwo = false;
  @track accountExists = true;
  @track empAccount = true;
  @track cambioCuenta = false;
  @track actuCuenta = true;
  @track cambioFechaHora = false;
  @track noExisteCuenta = false;
  @track cuentaEmpresarial = false;
  @track contactoPrincipal = false;
  @track nextButton = false;
  @track thirdStep = false;
  @track contactoPersonalAcc;

  @track seguroVehiculo;

  @track campFirstStep = true;
  @track campSecStep = false;

  @wire(getSeguroDetails, { cocheId: "$assetPlaca", cocheVin: "$assetVin" })
  wiredGetSeguro({ error, data }) {
    console.log("Asset Placa desde Wire Seguro", this.assetPlaca);

    if (data && Array.isArray(data) && data.length > 0) {
      console.log("==============DATA SEGURO==============");
      console.log(data);
      this.seguroVehiculo = data[0].Tipo_seguro__c;
      console.log("Tipo seguro:", this.seguroVehiculo);
      console.log("Tipo de dato seguro: ", typeof this.seguroVehiculo);
    } else {
      this.seguroVehiculo = "Sin seguro activo";
      console.log("Error desde Asset", error);
      console.log("Tipo de dato seguro: ", typeof this.seguroVehiculo);
    }
  }

  @wire(getAsset, { cocheId: "$assetPlaca", cocheVin: "$assetVin" })
  wiredRecordAsset({ error, data }) {
    console.log("entro asset");
    console.log("this.assetPlaca ", this.assetPlaca);
    console.log("this.assetVin ", this.assetVin);
    // console.log(data);
    if (data && Array.isArray(data) && data.length > 0) {
      console.log("==============DATA GENERAL==================");
      console.log(data);
      this.placa = data[0].numeroDePlaca__c;
      this.tipoVehiculo = data[0].Tipo_de_veh_culo__c;
      if (
        this.tipoVehiculo == "Motocicleta" ||
        this.tipoVehiculo == "BMW Motos"
      ) {
        this.showCrtMotos = true;
      }
      if (this.tipoVehiculo == "Mula" || this.tipoVehiculo == "Cuadraciclo") {
        this.mostrarHoras = true;
        console.log("Horas", this.mostrarHoras);
      } else {
        console.log("Horas", this.mostrarHoras);
      }
      this.numeroChasis = data[0].NumeroDeChasis__c;
      this.anioVehiculo = data[0].Anio__c;
      this.color = data[0].Color__c;
      this.marcaVehiculo = data[0].marca__c;
      this.modeloVehiculo = data[0].Modelo_Nvo2__c;
      this.marcaOtros = data[0].Marca_Otros__c;
      this.modeloOtros = data[0].Modelo_Otros__c;

      this.nombreCuenta = data[0].Account.Name;
      this.telefono = data[0].Account.Phone;
      this.identificacion = data[0].Account.Cedula__c;

      this.cedula = data[0].Account.codigoSoftland__c;
      this.personalAccount = data[0].Account.IsPersonAccount;
      console.log(this.personalAccount);
      if (this.personalAccount) {
        this.correoElectronico = data[0].Account.PersonEmail;
        this.personalEmail = data[0].Account.PersonEmail;
      } else {
        this.correoElectronico =
          data[0].Account.CorreoElectronicoEmpresarial__c;
        this.personalEmail = data[0].Account.PersonEmail;
      }
      if (!this.personalAccount) {
        if (
          this.infoData == true &&
          (this.telefono == null ||
            this.telefono == "" ||
            this.correoElectronico == null ||
            this.correoElectronico == "")
        ) {
          this.editAccountOwner = !this.editAccountOwner;
          this.cambioCuenta = false;
          this.noExisteCuenta = false;
          this.cuentaEmpresarial = false;
          this.nextButton = false;
          this.stepTwo = false;
          this.actuCuenta = true;
        }
        console.log("==============CONTACTO==================");
        if (
          data[0].ContactId == null ||
          data[0].ContactId == undefined ||
          data[0].ContactId == ""
        ) {
          // Aquí poner la variable para mostrar popup
          this.noContactExist = true;
          this.cambioCuenta = true;
        } else {
          this.noContactExist = false;
          this.parentContactSelectedRecord = data[0].ContactId;
          this.contactName = data[0].Contact.FirstName;
          this.apellidoContacto = data[0].Contact.LastName;
          this.identificacionContacto = data[0].Contact.Cedula__c;
          if (
            this.identificacionContacto == undefined ||
            this.identificacionContacto == null ||
            this.identificacionContacto == ""
          ) {
            if (data[0].Contact.Account.Cedula__c != null) {
              this.identificacionContacto = data[0].Contact.Account.Cedula__c;
            }
          }
          this.contactPhone = data[0].Contact.Phone;
          this.tipoIdentificacion = data[0].Contact.Tipo_de_Documento__c;
          this.contactEmail = data[0].Contact.Email;
          if (
            this.infoData == true &&
            (this.contactPhone == null || this.contactPhone == "")
          ) {
            this.editContact = true;
            this.cambioCuenta = false;
            this.noExisteCuenta = false;
            this.actuCuenta = true;
          }
        }
      } else {
        console.log("==============CONTACTO del asset==================");
        if (
          data[0].ContactId == null ||
          data[0].ContactId == undefined ||
          data[0].ContactId == ""
        ) {
          // Aquí poner la variable para mostrar popup
          //solo si cumple las condiciones
          //this.noContactExist = false
          if (
            this.infoData == true &&
            (this.telefono == null ||
              this.telefono == "" ||
              this.personalEmail == null ||
              this.personalEmail == "")
          ) {
            this.editAccountOwner = !this.editAccountOwner;
            this.cambioCuenta = false;
            this.noExisteCuenta = false;
            this.cuentaEmpresarial = false;
            this.nextButton = false;
            this.stepTwo = false;
            this.actuCuenta = true;
          }

          this.parentContactSelectedRecord = data[0].Account.PersonContactId;
          this.contactName = data[0].Account.FirstName;
          this.apellidoContacto = data[0].Account.LastName;
          this.identificacionContacto = data[0].Account.Cedula__c;
          this.contactPhone = data[0].Account.Phone;
          this.tipoIdentificacion = data[0].Account.Tipo_de_Documento__c;
          this.contactEmail = data[0].Account.PersonEmail;
          this.contactoPersonalAcc = data[0].Account.PersonContactId;
          //this.noContactExist = true
          //this.cambioCuenta = true
        } else {
          this.noContactExist = false;
          this.parentContactSelectedRecord = data[0].ContactId;
          this.contactName = data[0].Contact.FirstName;
          this.apellidoContacto = data[0].Contact.LastName;
          this.identificacionContacto = data[0].Contact.Cedula__c;
          if (
            this.identificacionContacto == undefined ||
            this.identificacionContacto == null ||
            this.identificacionContacto == ""
          ) {
            if (data[0].Contact.Account.Cedula__c != null) {
              this.identificacionContacto = data[0].Contact.Account.Cedula__c;
            }
          }
          this.contactPhone = data[0].Contact.Phone;
          this.tipoIdentificacion = data[0].Contact.Tipo_de_Documento__c;
          this.contactEmail = data[0].Contact.Email;
          if (this.contactPhone == null || this.contactPhone == "") {
            this.editContact = true;
            this.cambioCuenta = false;
            this.noExisteCuenta = false;
            this.actuCuenta = true;
          }
        }
      }

      this.parentAccountSelectedRecord = data[0].AccountId;

      if (this.tipoVehiculo == "Motocicleta") {
        this.esMoto = true;
      }

      //revisar si tiene mantenimiento
      if (
        data[0].Garant_a_de_activo__c != undefined &&
        data[0].Garant_a_de_activo__c != null
      ) {
        this.hasWarrantyPlan = true;
        this.AssetWarrantyNumber =
          data[0].Garant_a_de_activo__r.AssetWarrantyNumber;
        this.AssetWarrantyTerm =
          data[0].Garant_a_de_activo__r.WarrantyTerm.WarrantyTermName;
        this.AssetWarrantyStartDate = data[0].Garant_a_de_activo__r.StartDate;
        this.AssetWarrantyEfectiveEndDate =
          data[0].Garant_a_de_activo__r.EndDate;
        this.AssetWarrantyEfectiveStartDate =
          data[0].Garant_a_de_activo__r.WarrantyTerm.EffectiveStartDate;
        this.AssetWarantyType = data[0].Garant_a_de_activo__r.WarrantyType;
      }
    }
  }

  // handleConfirmacion() {
  //   confirmarCampanias({ assetId: this.assetPlaca })
  //     .then(() => {
  //       this.showToast(
  //         "Éxito",
  //         "Confirmación guardada correctamente",
  //         "success"
  //       );
  //       this.closeCampTec();
  //     })
  //     .catch((error) => {
  //       console.error("Error:", error.body.message);
  //       this.showToast("Error", "Ocurrió un error al guardar", "error");
  //     });
  // }

  // Agregar función para toast
  // showToast(title, message, variant) {
  //   const toastEvent = new ShowToastEvent({
  //     title: title,
  //     message: message,
  //     variant: variant,
  //   });
  //   this.dispatchEvent(toastEvent);
  // }

  cambiarNombreCuenta(event) {
    this.nombreCuenta = event.detail.value;
  }
  cambiarApellidoCuenta(event) {
    this.apellido = event.detail.value;
  }
  cambiarIdentificacionCuenta(event) {
    this.identificacion = event.detail.value;
  }

  cambiarTelefonoCuenta(event) {
    // Remove all non-numeric characters from the input immediately
    this.telefono = event.target.value.replace(/[^\d+]/g, "");

    // Update the input field to reflect the sanitized value
    event.target.value = this.telefono;
  }

  cambiarDescripcion(event) {
    this.descripcion = event.detail.value;
  }

  cambiarCorreoCuenta(event) {
    this.correoElectronico = event.detail.value;
  }

  cambiarCedula(event) {
    this.cedula = event.detail.value;
  }

  actualizarCuenta() {
    console.log("==============actualizarCuenta================");
    console.log(this.telefono);
    console.log(this.correoElectronico);
    if (this.isValidPhoneNumber(this.telefono)) {
      if (this.validateEmail(this.correoElectronico)) {
        this.showSpinner = true;
        if (this.stepTwo) {
          console.log("entro no existe cuenta");
          if (this.cuentaEmpresarial) {
            console.log("entro es cuenta empresarial");
            createAccount({
              nombreCuenta: this.nombreCuenta,
              apellido: this.apellido,
              cedula: this.cedulaBuscada,
              telefono: this.telefono,
              fechaNacimiento: this.fechaNacimiento,
              correoElectronico: this.correoElectronico,
              nombreEncargado: this.nombreEncargado,
              telefonoEncargado: this.telefonoEncargado,
              esEmpresarial: this.cuentaEmpresarial,
            })
              .then((result) => {
                console.log("cuenta creada correctamente: " + result.Id);
                this.parentAccountSelectedRecord = result.Id;
                updateAccount({
                  cocheId: this.assetPlaca,
                  cocheVin: this.assetVin,
                  cuentaId: this.parentAccountSelectedRecord,
                })
                  .then((result) => {
                    console.log(this.assetPlaca);
                    console.log(this.cocheVin);
                    console.log(this.parentAccountSelectedRecord);
                    // handle success, maybe show a success message
                    console.log(
                      "Record updated successfully, new value: " + result
                    );
                    this.showSpinner = false;
                    if (result) {
                      this.editAccountOwner = false;
                      this.cambioCuenta = false;
                      if (!this.cuentaEmpresarial) {
                        this.editContact = true;
                        this.cuentaEmpresarial = false;
                        this.personalAccount = true;
                        this.contactName = result[0].PersonContact.FirstName;
                        this.apellidoContacto =
                          result[0].PersonContact.LastName;
                        this.contactPhone = result[0].PersonContact.Phone;
                        this.tipoIdentificacion =
                          result[0].PersonContact.Tipo_de_Documento__c;
                        this.contactEmail = result[0].PersonContact.Email;
                      } else {
                        this.cuentaEmpresarial = true;
                        this.personalAccount = false;
                      }
                      this.noExisteCuenta = false;

                      this.nombreCuenta = result[0].Name;
                      this.telefono = result[0].Phone;
                      this.identificacion = result[0].Cedula__c;
                      if (!this.cuentaEmpresarial) {
                        this.personalEmail = result[0].PersonEmail;
                      } else {
                        this.correoElectronico =
                          result[0].CorreoElectronicoEmpresarial__c;
                      }

                      this.cedula = result[0].codigoSoftland__c;
                    }
                  })
                  .catch((error) => {
                    // handle error
                    this.showSpinner = false;
                    console.error("Error updating record", error);
                  });
              })
              .catch((error) => {
                // handle error
                this.showSpinner = false;
                console.error("Error creando record Cuenta", error);
                LightningAlert.open({
                  message: "Error: " + error.body.pageErrors[0].message,
                  theme: "error",
                  label: "Error!",
                });
              });
          } else {
            console.log("entro no es cuenta empresarial");
            console.log(this.cuentaEmpresarial);
            createAccount({
              nombreCuenta: this.nombreCuenta,
              apellido: this.apellido,
              cedula: this.cedulaBuscada,
              telefono: this.telefono,
              fechaNacimiento: this.fechaNacimiento,
              correoElectronico: this.correoElectronico,
              nombreEncargado: this.nombreEncargado,
              telefonoEncargado: this.telefonoEncargado,
              esEmpresarial: this.cuentaEmpresarial,
            })
              .then((result) => {
                console.log("cuenta creada correctamente: " + result.Id);
                this.parentAccountSelectedRecord = result.Id;
                updateAccount({
                  cocheId: this.assetPlaca,
                  cocheVin: this.assetVin,
                  cuentaId: this.parentAccountSelectedRecord,
                })
                  .then((result) => {
                    console.log(this.assetPlaca);
                    console.log(this.cocheVin);
                    console.log(this.parentAccountSelectedRecord);
                    // handle success, maybe show a success message
                    console.log(
                      "Record updated successfully, new value: " + result
                    );
                    this.showSpinner = false;
                    if (result) {
                      this.editAccountOwner = false;
                      this.cambioCuenta = false;
                      if (!this.cuentaEmpresarial) {
                        this.editContact = true;
                        this.personalAccount = true;
                        this.cuentaEmpresarial = false;
                        this.contactName = result[0].PersonContact.FirstName;
                        this.apellidoContacto =
                          result[0].PersonContact.LastName;
                        this.contactPhone = result[0].PersonContact.Phone;
                        this.tipoIdentificacion =
                          result[0].PersonContact.Tipo_de_Documento__c;
                        this.contactEmail = result[0].PersonContact.Email;
                      } else {
                        this.personalAccount = false;
                        this.cuentaEmpresarial = true;
                      }

                      this.noExisteCuenta = false;

                      this.nombreCuenta = result[0].Name;
                      this.telefono = result[0].Phone;
                      this.identificacion = result[0].Cedula__c;

                      if (!this.cuentaEmpresarial) {
                        this.personalEmail = result[0].PersonEmail;
                      } else {
                        this.correoElectronico =
                          result[0].CorreoElectronicoEmpresarial__c;
                      }

                      this.cedula = result[0].codigoSoftland__c;
                    }
                  })
                  .catch((error) => {
                    // handle error
                    this.showSpinner = false;
                    console.error("Error updating record", error);
                  });
              })
              .catch((error) => {
                // handle error
                this.showSpinner = false;
                console.error("Error creando record Cuenta", error);
                LightningAlert.open({
                  message: "Error: " + error.body.pageErrors[0].message,
                  theme: "error",
                  label: "Error!",
                });
              });
          }
        } else {
          if (this.actuCuenta) {
            console.log("se quiere actualizar la cuenta");
            updateDataAccount({
              cuentaId: this.parentAccountSelectedRecord,
              telCuenta: this.telefono,
              identificacioCuenta: this.identificacion,
              correoCuenta: this.correoElectronico,
            })
              .then((result) => {
                console.log(this.parentAccountSelectedRecord);
                console.log("Informacion de cuenta actualizada " + result);
                this.showSpinner = false;
                if (result) {
                  this.actuCuenta = false;
                  this.cambioCuenta = false;
                  this.noExisteCuenta = false;

                  this.editAccountOwner = false;

                  this.nombreCuenta = result[0].Name;
                  this.telefono = result[0].Phone;
                  this.identificacion = result[0].Cedula__c;
                  if (this.personalAccount) {
                    this.cuentaEmpresarial = false;
                    this.personalEmail = result[0].PersonEmail;
                  } else {
                    this.cuentaEmpresarial = true;
                    this.correoElectronico =
                      result[0].CorreoElectronicoEmpresarial__c;
                  }
                  this.cedula = result[0].codigoSoftland__c;
                }
              })
              .catch((error) => {
                // handle error
                this.showSpinner = false;
                console.error("Error updating data record", error);
                LightningAlert.open({
                  message: "Error actualizando la cuenta: Datos existentes.",
                  theme: "error",
                  label: "Error!",
                });
              });
          } else {
            updateAccount({
              cocheId: this.assetPlaca,
              cocheVin: this.assetVin,
              cuentaId: this.parentAccountSelectedRecord,
            })
              .then((result) => {
                console.log(this.assetPlaca);
                console.log(this.cocheVin);
                console.log(this.parentAccountSelectedRecord);
                // handle success, maybe show a success message
                console.log(
                  "Record updated successfully, new value: " + result
                );
                this.showSpinner = false;
                if (result) {
                  this.editAccountOwner = false;

                  this.cambioCuenta = false;
                  this.noExisteCuenta = false;
                  if (this.personalAccount) {
                    this.editContact = true;
                    this.cuentaEmpresarial = false;
                    this.personalEmail = result[0].PersonEmail;
                    this.contactName = result[0].PersonContact.FirstName;
                    this.apellidoContacto = result[0].PersonContact.LastName;
                    this.contactPhone = result[0].PersonContact.Phone;
                    this.tipoIdentificacion =
                      result[0].PersonContact.Tipo_de_Documento__c;
                    this.contactEmail = result[0].PersonContact.Email;
                  } else {
                    this.cuentaEmpresarial = true;
                    this.correoElectronico =
                      result[0].CorreoElectronicoEmpresarial__c;
                  }

                  this.nombreCuenta = result[0].Name;
                  this.telefono = result[0].Phone;
                  this.identificacion = result[0].Cedula__c;

                  //this.correoElectronico =  result[0].CorreoElectronicoEmpresarial__c;
                  this.cedula = result[0].codigoSoftland__c;
                }
              })
              .catch((error) => {
                // handle error
                this.showSpinner = false;
                console.error("Error updating record", error);
              });
          }
        }
      } else {
        LightningAlert.open({
          message: "Formato de correo electronico no valido.",
          theme: "error",
          label: "Error!",
        });
        this.telefonoError = "Formato de correo electronico no valido.";
      }
    } else {
      LightningAlert.open({
        message:
          "Número de teléfono no válido. Debe empezar por +506 y tener una longitud total de 8 dígitos.",
        theme: "error",
        label: "Error!",
      });
      this.telefonoError =
        "Número de teléfono no válido. Debe empezar por +506 y tener una longitud total de 8 dígitos.";
    }
  }
  isValidPhoneNumber(phoneNumber) {
    const phoneNumberPattern = /^\+506\d{8}$/;
    return phoneNumberPattern.test(phoneNumber);
  }

  validateEmail(email) {
    const emailPattern =
      /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.(com|org|net|edu|co|co.cr)$/;
    return emailPattern.test(email);
  }

  handleValueSelectedOnContacto(event) {
    console.log(event.detail.id);
    if (event.detail.id != undefined) {
      this.parentContactSelectedRecord = event.detail.id;
    }
  }

  setNombreContacto(event) {
    this.contactName = event.detail.value;
  }

  setCedulaContacto(event) {
    this.identificacionContacto = event.detail.value;
  }

  setApellidoContacto(event) {
    this.apellidoContacto = event.detail.value;
  }
  setTelefonoContacto(event) {
    // Allow only digits and the "+" symbol
    this.contactPhone = event.target.value.replace(/[^\d+]/g, "");

    // Update the input field to reflect the sanitized value
    event.target.value = this.contactPhone;
  }
  setTipoIdentificacionContacto(event) {
    this.tipoIdentificacion = event.detail.value;
  }
  setCorreoContacto(event) {
    this.contactEmail = event.detail.value;
  }

  clsCrearContacto() {
    console.log("AQUI ENTRA A CREAR CONTACTO");
    this.showSpinner = true;
    createContact({
      cocheId: this.assetPlaca,
      cocheVin: this.assetVin,
      cuenta: this.parentAccountSelectedRecord,
      nombreContacto: this.nombreContacto,
      apellidoContacto: this.apellidoContacto,
      telefonoContacto: this.telefonoContacto,
      correoContacto: this.correoContacto,
    })
      .then((result) => {
        console.log(this.assetPlaca);
        console.log(this.cocheVin);
        console.log(this.parentAccountSelectedRecord);
        console.log("Record updated successfully, new value: " + result);
        if (result) {
          console.log("AQUI SALIO DE CREAR CONTACTO");
          this.showCrtContactModal = false;
          //     this.nombreCuenta = result[0].Name;
          //     this.telefono = result[0].Phone;
          //     this.correoElectronico =  result[0].CorreoElectronicoEmpresarial__c
          //     this.cedula = result[0].codigoSoftland__c;
        }
        this.showSpinner = false;
      })
      .catch((error) => {
        // handle error
        if (error.body.pageErrors[0] != undefined) {
          LightningAlert.open({
            message:
              "Error : Por favor revise los datos ingresados. " +
              error.body.pageErrors[0].message,
            theme: "error",
            label: "Error!",
          });
          this.showSpinner = false;
        } else {
          LightningAlert.open({
            message: "Error : Por favor revise los datos ingresados. ",
            theme: "error",
            label: "Error!",
          });
          this.showSpinner = false;
        }

        console.error("Error updating record", error);
      });
  }

  actualizarContacto() {
    this.showSpinner = true;
    var datosValidos = true;
    console.log(
      "=====================VALORES HASTA AQUI CONTACTO==================="
    );
    console.log(this.parentContactSelectedRecord);
    console.log(
      "=====================VALORES HASTA AQUI CUENTA==================="
    );
    console.log(this.parentAccountSelectedRecord);
    console.log(this.personalAccount);
    if (!this.personalAccount) {
      verifyContactData({
        contactId: this.parentContactSelectedRecord,
        accountId: this.parentAccountSelectedRecord,
      })
        .then((result) => {
          console.log(result);
          if (result == true) {
            datosValidos = false;
          }
          if (datosValidos) {
            if (this.actuCuenta && this.noExisteCuenta != true) {
              //validacion de telefono
              if (this.isValidPhoneNumber(this.contactPhone)) {
                if (this.validateEmail(this.contactEmail)) {
                  console.log("Entre actualizar COntacto data");
                  console.log(this.parentContactSelectedRecord);
                  updateContactData({
                    contactId: this.parentContactSelectedRecord,
                    nombreC: this.contactName,
                    apellidoC: this.apellidoContacto,
                    phoneC: this.contactPhone,
                    tipoI: this.tipoIdentificacion,
                    emailC: this.contactEmail,
                    cedulaCont: this.identificacionContacto,
                    cocheId: this.assetPlaca,
                    cocheVin: this.assetVin,
                  })
                    .then((result) => {
                      console.log(this.assetPlaca);
                      console.log(this.cocheVin);
                      console.log(this.parentAccountSelectedRecord);
                      console.log(
                        "Record updated successfully, new value: " + result
                      );
                      this.showCrtContactModal = false;
                      this.showSpinner = false;
                      this.actuCuenta = false;
                      if (result == undefined || result == "") {
                        this.showSpinner = false;
                        LightningAlert.open({
                          message:
                            "Ocurrio un problema al actualizar el contacto.",
                          theme: "error",
                          label: "Error!",
                        });

                        //     this.nombreCuenta = result[0].Name;
                        //     this.telefono = result[0].Phone;
                        //     this.correoElectronico =  result[0].CorreoElectronicoEmpresarial__c + ' ' +result[0].PersonEmail;
                        //     this.cedula = result[0].codigoSoftland__c;
                      } else {
                        this.showSpinner = false;
                        this.editAccountOwner = false;
                        this.cambioCuenta = false;
                        this.noExisteCuenta = false;
                        this.cuentaEmpresarial = false;
                        this.showCrtContactModal = false;
                        this.editContact = false;
                        this.contactName = result[0].FirstName;

                        this.contactPhone = result[0].Phone;
                        this.tipoIdentificacion =
                          result[0].Tipo_de_Documento__c;
                        this.contactEmail = result[0].Email;
                        if (
                          result[0].Cedula__c != null ||
                          result[0].Cedula__c != undefined
                        ) {
                          this.identificacionContacto = result[0].Cedula__c;
                        }
                      }
                      this.showSpinner = false;
                    })
                    .catch((error) => {
                      // handle error
                      LightningAlert.open({
                        message:
                          "Ocurrio un problema al actualizar el contacto.",
                        theme: "error",
                        label: "Error!",
                      });
                      console.error("Error updating record", error);
                      this.showSpinner = false;
                    });
                } else {
                  LightningAlert.open({
                    message: "Formato de correo electronico no valido.",
                    theme: "error",
                    label: "Error!",
                  });
                  this.showSpinner = false;
                }
              } else {
                LightningAlert.open({
                  message:
                    "Número de teléfono no válido. Debe empezar por +506 y tener una longitud total de 8 dígitos.",
                  theme: "error",
                  label: "Error!",
                });
                this.showSpinner = false;
                this.telefonoError =
                  "Número de teléfono no válido. Debe empezar por +506 y tener una longitud total de 8 dígitos.";
              }
            } else {
              if (this.noExisteCuenta) {
                console.log("entro no existe contacto");
                if (this.esContactoPrincipal) {
                  console.log("es contacto principal");
                }
                if (this.isValidPhoneNumber(this.contactPhone)) {
                  if (this.validateEmail(this.contactEmail)) {
                    createContact({
                      cocheId: this.assetPlaca,
                      cocheVin: this.assetVin,
                      cuenta: this.parentAccountSelectedRecord,
                      nombreContacto: this.contactName,
                      apellidoContacto: this.apellidoContacto,
                      telefonoContacto: this.contactPhone,
                      tipoIdentificacionContacto: this.tipoIdentificacion,
                      correoContacto: this.contactEmail,
                    })
                      .then((result) => {
                        this.cambioCuenta = false;

                        console.log(this.assetPlaca);
                        console.log(this.cocheVin);
                        console.log(this.parentAccountSelectedRecord);
                        console.log(
                          "Record updated successfully, new value: " + result
                        );
                        console.log(result);
                        //this.parentContactSelectedRecord = result.Id
                        if (result) {
                          console.log(
                            "=================result================="
                          );
                          console.log(result.Id);
                          console.log(result[0].Id);
                          this.showSpinner = false;
                          this.parentContactSelectedRecord = result[0].Id;
                          this.editAccountOwner = false;
                          this.showCrtContactModal = false;
                          this.cambioCuenta = false;
                          this.noExisteCuenta = false;
                          this.cuentaEmpresarial = false;
                          this.editContact = false;
                          //     this.nombreCuenta = result[0].Name;
                          //     this.telefono = result[0].Phone;
                          //     this.correoElectronico =  result[0].CorreoElectronicoEmpresarial__c + ' ' +result[0].PersonEmail;
                          //     this.cedula = result[0].codigoSoftland__c;
                        }
                      })
                      .catch((error) => {
                        this.showSpinner = false;
                        // handle error
                        LightningAlert.open({
                          message:
                            "No se puede actualizar el contacto de una cuenta personal.",
                          theme: "error",
                          label: "Error!",
                        });
                        this.cambioCuenta = false;
                        this.showSpinner = false;
                        console.error("Error updating record", error);
                      });
                  } else {
                    LightningAlert.open({
                      message: "Formato de correo electronico no valido.",
                      theme: "error",
                      label: "Error!",
                    });
                    this.showSpinner = false;
                    this.telefonoError =
                      "Formato de correo electronico no valido.";
                  }
                } else {
                  LightningAlert.open({
                    message:
                      "Número de teléfono no válido. Debe empezar por +506 y tener una longitud total de 8 dígitos.",
                    theme: "error",
                    label: "Error!",
                  });
                  this.showSpinner = false;
                  this.telefonoError =
                    "Número de teléfono no válido. Debe empezar por +506 y tener una longitud total de 8 dígitos.";
                }
              } else {
                //validacion de telefono

                updateContact({
                  cocheId: this.assetPlaca,
                  cocheVin: this.assetVin,
                  contactId: this.parentContactSelectedRecord,
                })
                  .then((result) => {
                    console.log(this.assetPlaca);
                    console.log(this.cocheVin);
                    console.log(this.parentContactSelectedRecord);
                    console.log(
                      "Record updated successfully, new value: " + result
                    );
                    this.showCrtContactModal = false;
                    this.showSpinner = false;
                    if (result) {
                      console.log(result);
                      this.editAccountOwner = false;
                      this.cambioCuenta = false;
                      this.noExisteCuenta = false;
                      this.cuentaEmpresarial = false;
                      this.editContact = false;
                      this.contactName = result[0].FirstName;
                      this.apellidoContacto = result[0].LastName;
                      this.contactPhone = result[0].Phone;
                      this.tipoIdentificacion = result[0].Tipo_de_Documento__c;
                      this.contactEmail = result[0].Email;
                      if (
                        this.contactEmail == null ||
                        this.contactEmail == "" ||
                        this.contactEmail == "n/a@redmotorscr.com"
                      ) {
                        this.editContact = true;
                        this.cambioCuenta = false;
                        this.noExisteCuenta = false;
                        this.actuCuenta = true;
                      }
                      //     this.nombreCuenta = result[0].Name;
                      //     this.telefono = result[0].Phone;
                      //     this.correoElectronico =  result[0].CorreoElectronicoEmpresarial__c + ' ' +result[0].PersonEmail;
                      //     this.cedula = result[0].codigoSoftland__c;
                    }
                  })
                  .catch((error) => {
                    // handle error
                    console.error("Error updating record", error);
                    this.showSpinner = false;
                  });
              }
            }
          } else {
            LightningAlert.open({
              message:
                "En contacto si es una cuenta jurídica se debe colocar un contacto físico.",
              theme: "error",
              label: "Error!",
            });
            this.showSpinner = false;
          }
        })
        .catch((error) => {
          // handle error
          LightningAlert.open({
            message: "Ocurrio un problema al actualizar el contacto.",
            theme: "error",
            label: "Error!",
          });
          console.error("Error updating record", error);
          this.showSpinner = false;
        });
    } else {
      if (this.actuCuenta && this.noExisteCuenta != true) {
        //validacion de telefono
        if (this.isValidPhoneNumber(this.contactPhone)) {
          if (this.validateEmail(this.contactEmail)) {
            console.log("Entre actualizar COntacto data");
            console.log(this.parentContactSelectedRecord);
            updateContactData({
              contactId: this.parentContactSelectedRecord,
              nombreC: this.contactName,
              apellidoC: this.apellidoContacto,
              phoneC: this.contactPhone,
              tipoI: this.tipoIdentificacion,
              emailC: this.contactEmail,
              cedulaCont: this.identificacionContacto,
              cocheId: this.assetPlaca,
              cocheVin: this.assetVin,
            })
              .then((result) => {
                console.log(this.assetPlaca);
                console.log(this.cocheVin);
                console.log(this.parentAccountSelectedRecord);
                console.log(
                  "Record updated successfully, new value: " + result
                );
                this.showCrtContactModal = false;
                this.showSpinner = false;
                this.actuCuenta = false;
                if (result == undefined || result == "") {
                  this.showSpinner = false;
                  LightningAlert.open({
                    message: "Ocurrio un problema al actualizar el contacto.",
                    theme: "error",
                    label: "Error!",
                  });

                  //     this.nombreCuenta = result[0].Name;
                  //     this.telefono = result[0].Phone;
                  //     this.correoElectronico =  result[0].CorreoElectronicoEmpresarial__c + ' ' +result[0].PersonEmail;
                  //     this.cedula = result[0].codigoSoftland__c;
                } else {
                  this.showSpinner = false;
                  this.editAccountOwner = false;
                  this.cambioCuenta = false;
                  this.noExisteCuenta = false;
                  this.cuentaEmpresarial = false;
                  this.showCrtContactModal = false;
                  this.editContact = false;
                  this.contactName = result[0].FirstName;

                  this.contactPhone = result[0].Phone;
                  this.tipoIdentificacion = result[0].Tipo_de_Documento__c;
                  this.contactEmail = result[0].Email;
                  if (
                    result[0].Cedula__c != null ||
                    result[0].Cedula__c != undefined
                  ) {
                    this.identificacionContacto = result[0].Cedula__c;
                  }
                }
                this.showSpinner = false;
              })
              .catch((error) => {
                // handle error
                LightningAlert.open({
                  message: "Ocurrio un problema al actualizar el contacto.",
                  theme: "error",
                  label: "Error!",
                });
                console.error("Error updating record", error);
                this.showSpinner = false;
              });
          } else {
            LightningAlert.open({
              message: "Formato de correo electronico no valido.",
              theme: "error",
              label: "Error!",
            });
            this.showSpinner = false;
          }
        } else {
          LightningAlert.open({
            message:
              "Número de teléfono no válido. Debe empezar por +506 y tener una longitud total de 8 dígitos.",
            theme: "error",
            label: "Error!",
          });
          this.showSpinner = false;
          this.telefonoError =
            "Número de teléfono no válido. Debe empezar por +506 y tener una longitud total de 8 dígitos.";
        }
      } else {
        if (this.noExisteCuenta) {
          console.log("entro no existe contacto");
          if (this.esContactoPrincipal) {
            console.log("es contacto principal");
          }
          if (this.isValidPhoneNumber(this.contactPhone)) {
            if (this.validateEmail(this.contactEmail)) {
              createContact({
                cocheId: this.assetPlaca,
                cocheVin: this.assetVin,
                cuenta: this.parentAccountSelectedRecord,
                nombreContacto: this.contactName,
                apellidoContacto: this.apellidoContacto,
                telefonoContacto: this.contactPhone,
                tipoIdentificacionContacto: this.tipoIdentificacion,
                correoContacto: this.contactEmail,
              })
                .then((result) => {
                  this.cambioCuenta = false;

                  console.log(this.assetPlaca);
                  console.log(this.cocheVin);
                  console.log(this.parentAccountSelectedRecord);
                  console.log(
                    "Record updated successfully, new value: " + result
                  );
                  console.log(result);
                  //this.parentContactSelectedRecord = result.Id
                  if (result) {
                    console.log("=================result=================");
                    console.log(result.Id);
                    console.log(result[0].Id);
                    this.showSpinner = false;
                    this.parentContactSelectedRecord = result[0].Id;
                    this.editAccountOwner = false;
                    this.showCrtContactModal = false;
                    this.cambioCuenta = false;
                    this.noExisteCuenta = false;
                    this.cuentaEmpresarial = false;
                    this.editContact = false;
                    //     this.nombreCuenta = result[0].Name;
                    //     this.telefono = result[0].Phone;
                    //     this.correoElectronico =  result[0].CorreoElectronicoEmpresarial__c + ' ' +result[0].PersonEmail;
                    //     this.cedula = result[0].codigoSoftland__c;
                  }
                })
                .catch((error) => {
                  this.showSpinner = false;
                  // handle error
                  LightningAlert.open({
                    message:
                      "No se puede actualizar el contacto de una cuenta personal.",
                    theme: "error",
                    label: "Error!",
                  });
                  this.cambioCuenta = false;
                  this.showSpinner = false;
                  console.error("Error updating record", error);
                });
            } else {
              LightningAlert.open({
                message: "Formato de correo electronico no valido.",
                theme: "error",
                label: "Error!",
              });
              this.showSpinner = false;
            }
          } else {
            LightningAlert.open({
              message:
                "Número de teléfono no válido. Debe empezar por +506 y tener una longitud total de 8 dígitos.",
              theme: "error",
              label: "Error!",
            });
            this.showSpinner = false;
            this.telefonoError =
              "Número de teléfono no válido. Debe empezar por +506 y tener una longitud total de 8 dígitos.";
          }
        } else {
          //validacion de telefono

          updateContact({
            cocheId: this.assetPlaca,
            cocheVin: this.assetVin,
            contactId: this.parentContactSelectedRecord,
          })
            .then((result) => {
              console.log(this.assetPlaca);
              console.log(this.cocheVin);
              console.log(this.parentContactSelectedRecord);
              console.log("Record updated successfully, new value: " + result);
              this.showCrtContactModal = false;
              this.showSpinner = false;
              if (result) {
                console.log(result);
                this.editAccountOwner = false;
                this.cambioCuenta = false;
                this.noExisteCuenta = false;
                this.cuentaEmpresarial = false;
                this.editContact = false;
                this.contactName = result[0].FirstName;
                this.apellidoContacto = result[0].LastName;
                this.contactPhone = result[0].Phone;
                this.tipoIdentificacion = result[0].tipoIdentificacion;
                this.contactEmail = result[0].Email;
                if (
                  this.contactEmail == null ||
                  this.contactEmail == "" ||
                  this.contactEmail == "n/a@redmotorscr.com"
                ) {
                  this.editContact = true;
                  this.cambioCuenta = false;
                  this.noExisteCuenta = false;
                  this.actuCuenta = true;
                }
                //     this.nombreCuenta = result[0].Name;
                //     this.telefono = result[0].Phone;
                //     this.correoElectronico =  result[0].CorreoElectronicoEmpresarial__c + ' ' +result[0].PersonEmail;
                //     this.cedula = result[0].codigoSoftland__c;
              }
            })
            .catch((error) => {
              // handle error
              console.error("Error updating record", error);
              this.showSpinner = false;
            });
        }
      }
    }

    console.log("========datosValidos========");
    console.log(datosValidos);

    if (datosValidos) {
    }
  }

  // connectedCallback() {
  //     const data = generateData({ amountOfRecords: 100 });
  //     this.data = data;
  // }

  clsCreateContactModal() {
    this.showCrtContactModal = false;
  }

  handleFechaHora() {
    this.cambioFechaHora = !this.cambioFechaHora;
  }

  handleValueSelectedOnAccount(event) {
    if (event.detail.id != undefined) {
      this.parentAccountSelectedRecord = event.detail.id;
    }
  }

  handleValueSelectedOnPlaca(event) {
    console.log(event.detail.id);
    if (event.detail.id != undefined) {
      console.log(event.detail.id);
      this.assetPlaca = event.detail.id;
    }
  }

  handleValueSelectedOnVIN(event) {
    console.log(event.detail.id);
    if (event.detail.id != undefined) {
      console.log(event.detail.id);
      this.assetVin = event.detail.id;
      this.assetPlaca = event.detail.id;
    }
  }

  @track value = "";

  get optionsContact() {
    return [
      { label: "Contact Center", value: "Contact Center" },
      { label: "Whatsapp EDNA", value: "Whatsapp_EDNA" },
    ];
  }

  get options() {
    if ((this.userId = "005PH000006DwKTYA0")) {
      return [
        { label: "Ninguno", value: "" },
        { label: "Llamada télefonica", value: "Llamada telefónica" },
        { label: "Sin cita", value: "Sin cita" },
        { label: "Whatsapp", value: "Whatsapp" },
        { label: "Presencial", value: "Presencial" },
        { label: "Correo electrónico", value: "Correo electrónico" },
        { label: "Interno", value: "Interno" },
        { label: "Campaña de frenos", value: "Campaña de frenos" },
        {
          label: "Campaña previo de entrega",
          value: "Campaña previo de entrega",
        },
        { label: "Whatsapp EDNA", value: "Whatsapp_EDNA" },
      ];
    } else {
      return [
        { label: "Ninguno", value: "" },
        { label: "Llamada télefonica", value: "Llamada telefónica" },
        { label: "Sin cita", value: "Sin cita" },
        { label: "Whatsapp", value: "Whatsapp" },
        { label: "Presencial", value: "Presencial" },
        { label: "Correo electrónico", value: "Correo electrónico" },
        { label: "Interno", value: "Interno" },
        // {label: 'Contact Center', value:'Contact Center'},
        { label: "Campaña de frenos", value: "Campaña de frenos" },
        {
          label: "Campaña previo de entrega",
          value: "Campaña previo de entrega",
        },
      ];
    }
  }

  modalValue = "";

  get modalOptions() {
    return [
      { label: "Ninguno", value: "" },
      { label: "Automóvil", value: "Automóvil" },
      { label: "Motocicleta", value: "Motocicleta" },
      { label: "Mula", value: "Mula" },
      { label: "Cuadraciclo", value: "Cuadraciclo" },
    ];
  }

  @track showSpinner = false;

  appointmentBack() {
    console.log("app back");
    console.log("this.infoData ", this.infoData);

    this.infoData = false;
  }

  validaSeleccion() {
    this.showSpinner = true;
    console.log("=================validaSeleccion=================");
    console.log(this.assetPlaca);
    console.log(this.assetVin);
    console.log(this.value);

    console.log("0=====0");
    console.log(this.assetPlaca != "");
    console.log(this.assetPlaca != undefined);

    console.log(this.assetVin != "");
    console.log(this.assetVin != undefined);
    if (
      ((this.assetPlaca != "" && this.assetPlaca != undefined) ||
        (this.assetVin != "" && this.assetVin != undefined)) &&
      this.value != "" &&
      this.value != undefined
    ) {
      this.infoData = true;
      this.showSpinner = false;
      if (this.noContactExist === true) {
        this.actuCuenta = false;
        this.cambioCuenta = true;
        setTimeout(() => {
          this.showCrtContactModal = true;
        }, 500);
      }

      if (
        (this.noContactExist != true && this.contactPhone == null) ||
        this.contactPhone == ""
      ) {
        this.editContact = true;
        this.cambioCuenta = false;
        this.noExisteCuenta = false;
        this.actuCuenta = true;
      }
      if (
        (this.noContactExist != true && this.contactEmail == null) ||
        this.contactEmail == "" ||
        this.contactEmail == "n/a@redmotorscr.com"
      ) {
        this.editContact = true;
        this.cambioCuenta = false;
        this.noExisteCuenta = false;
        this.actuCuenta = true;
      }
      if (!this.personalAccount) {
        if (
          this.telefono == null ||
          this.telefono == "" ||
          this.correoElectronico == null ||
          this.correoElectronico == "" ||
          this.correoElectronico == "n/a@redmotorscr.com"
        ) {
          this.editAccountOwner = true;
          this.cambioCuenta = false;
          this.noExisteCuenta = false;
          this.cuentaEmpresarial = false;
          this.nextButton = false;
          this.stepTwo = false;
          this.actuCuenta = true;
        }
      } else {
        if (
          this.telefono == null ||
          this.telefono == "" ||
          this.personalEmail == null ||
          this.personalEmail == "" ||
          this.personalEmail == "n/a@redmotorscr.com"
        ) {
          this.editAccountOwner = true;
          this.cambioCuenta = false;
          this.noExisteCuenta = false;
          this.cuentaEmpresarial = false;
          this.nextButton = false;
          this.stepTwo = false;
          this.actuCuenta = true;
        }
      }

      console.log(this.assetPlaca);
      console.log(this.assetVin);

    } else {
      LightningAlert.open({
        message: "Por favor llene todos los campos.",
        theme: "error",
        label: "Error!",
      });
      this.showSpinner = false;

      // this.dispatchEvent(evt);
    }
  }

  handleChange(event) {
    this.value = event.detail.value;
    console.log("Origen de la cita");
    console.log(this.value);
  }

  setPlaca(event) {
    this.placa = event.detail.value;
  }

  setNumeroChasis(event) {
    this.numeroChasis = event.detail.value;
  }

  setMotor(event) {
    this.motor = event.detail.value;
  }

  setColor(event) {
    this.color = event.detail.value;
  }

  setAnio(event) {
    this.anioVehiculo = event.detail.value;
  }

  setKilimetros(event) {
    this.kilometros = event.detail.value;
  }

  setCedulaBuscar(event) {
    this.cedulaBuscada = event.detail.value;
  }

  setNombreEncargado(event) {
    this.nombreEncargado = event.detail.value;
  }

  setTelefonoEncargado(event) {
    this.telefonoEncargado = event.detail.value;
  }

  appointmentBack() {
    console.log("this.infoData app back2 ", this.infoData);
    this.infoData = false;
    this.cambioCuenta = false;
    this.noExisteCuenta = false;
    this.cuentaEmpresarial = false;
    this.actuCuenta = false;
  }

  accountChange() {
    this.cambioCuenta = !this.cambioCuenta;
    this.nextButton = !this.nextButton;
    this.actuCuenta = false;
  }

  accountUpdate() {
    this.actuCuenta = !this.actuCuenta;
    this.noExisteCuenta = false;
    this.nextButton = false;
    this.cambioCuenta = false;
  }

  notAccountExists() {
    this.noExisteCuenta = !this.noExisteCuenta;
    this.nextButton = !this.nextButton;
  }
  @track esContactoPrincipal = false;
  contactoPrincipal() {
    this.esContactoPrincipal = !this.esContactoPrincipal;
  }

  cerrarModal() {
    console.log(this.assetPlaca);
    console.log(this.assetVin);
    getKilometros({
      cocheId: this.assetPlaca,
      cocheVin: this.assetVin,
      kilometros: this.kilometros,
    })
      .then((result) => {
        // handle success, maybe show a success message
        console.log("kilometros pasa: " + result);
        if (result) {
          this.showCrtMotos = false;
        } else {
          LightningAlert.open({
            message: "El Kilometraje no puede ser menor al anterior.",
            theme: "error",
            label: "Error!",
          });
        }
      })
      .catch((error) => {
        // handle error
        this.showSpinner = false;
        console.error("Error buscando cedula ", error);
      });
  }

  handleStepTwo() {
    this.showSpinner = true;
    var obtenerCedula = this.cedulaBuscada;
    if (
      obtenerCedula != null &&
      obtenerCedula != "" &&
      obtenerCedula != undefined
    ) {
      console.log("cedula a buscar: " + obtenerCedula);

      getCedula({ cedula: obtenerCedula })
        .then((result) => {
          // handle success, maybe show a success message
          console.log("cedula encontrada: " + result);
          if (result) {
            var splitArray = result[0].split(";");
            this.nombreCuenta = splitArray[0];
            this.apellido = splitArray[1];
            this.cedula = this.cedulaBuscada;
            this.telefono = splitArray[4];
            this.fechaNacimiento = splitArray[6];
            this.correoElectronico = splitArray[3];
            this.stepTwo = true;
            this.showSpinner = false;

            this.noExisteCuenta = false;
          }
        })
        .catch((error) => {
          // handle error
          this.showSpinner = false;
          console.error("Error buscando cedula ", error);
        });
    } else {
      this.showSpinner = false;
      LightningAlert.open({
        message: "Por favor llene todos los campos.",
        theme: "error",
        label: "Error!",
      });
    }

    this.cambioCuenta = false;
    this.nextButton = false;
  }

  handleBackStepTwo() {
    this.stepTwo = false;
    this.nextButton = false;
    this.noExisteCuenta = false;
  }

  setContactoPrincipal() {
    this.contactoPrincipal = !this.contactoPrincipal;
  }

  empAccountSelect() {
    this.cuentaEmpresarial = !this.cuentaEmpresarial;
  }

  openModal() {
    this.isModalOpen = true;
  }

  handleChangeAccuntOwner() {
    this.editAccountOwner = !this.editAccountOwner;

    this.cambioCuenta = false;
    this.noExisteCuenta = false;
    this.cuentaEmpresarial = false;
    this.nextButton = false;

    this.stepTwo = false;

    this.actuCuenta = true;
  }

  showThirdStep() {
    this.secondStep = false;

    if (this.accountExists == false) {
      var obtenerCedula = this.cedulaBuscada;
      if (
        obtenerCedula != null &&
        obtenerCedula != "" &&
        obtenerCedula != undefined &&
        this.placa != null &&
        this.placa != undefined &&
        this.placa != "" &&
        this.numeroChasis != null &&
        this.numeroChasis != undefined &&
        this.numeroChasis != "" &&
        this.motor != null &&
        this.motor != undefined &&
        this.motor != "" &&
        this.anioVehiculo != null &&
        this.anioVehiculo != undefined &&
        this.anioVehiculo != "" &&
        this.kilometros != null &&
        this.kilometros != undefined &&
        this.kilometros != ""
      ) {
        console.log("cedula a buscar: " + obtenerCedula);

        getCedula({ cedula: obtenerCedula })
          .then((result) => {
            // handle success, maybe show a success message
            console.log("cedula encontrada: " + result);
            if (result) {
              var splitArray = result[0].split(";");
              this.nombreCuenta = splitArray[0];
              this.apellido = splitArray[1];
              this.cedula = this.cedulaBuscada;
              this.telefono = splitArray[4];
              this.fechaNacimiento = splitArray[6];
              this.correoElectronico = splitArray[3];
              this.thirdStep = true;
            }
          })
          .catch((error) => {
            // handle error
            console.error("Error buscando cedula ", error);
          });
      } else {
        LightningAlert.open({
          message: "Por favor llene todos los campos.",
          theme: "error",
          label: "Error!",
        });
      }
    }
  }

  checkChasisLength() {
    const primerosCuatro = this.numeroChasis.slice(0, 4);
    if (
      /^(0000|1111|2222|3333|4444|5555|6666|7777|8888|9999)$/.test(
        primerosCuatro
      )
    ) {
      LightningAlert.open({
        message: "El chasis no puede comenzar con cuatro dígitos iguales.",
        theme: "error",
        label: "Error!",
      });
      return false;
    }

    if (this.numeroChasis.length === 17) {
      return true;
    } else {
      LightningAlert.open({
        message: "El chasis debe tener 17 dígitos.",
        theme: "error",
        label: "Error!",
      });
      return false;
    }
  }

  crearVehiculo() {
    if (this.checkChasisLength()) {
      if (
        this.placa != null &&
        this.placa != undefined &&
        this.placa != "" &&
        this.numeroChasis != null &&
        this.numeroChasis != undefined &&
        this.numeroChasis != "" &&
        this.motor != null &&
        this.motor != undefined &&
        this.motor != "" &&
        this.anioVehiculo != null &&
        this.anioVehiculo != undefined &&
        this.anioVehiculo != "" &&
        this.kilometros != null &&
        this.kilometros != undefined &&
        this.kilometros != ""
      ) {
        //revisar si primero crear Cuenta
        if (this.accountExists == false) {
          console.log("Se necesitan datos de cuenta");
          //si este esta en true, se debe crear como empresarial
          this.empAccount;
          console.log("Cuenta Empresarial " + this.empAccount);
          if (this.isValidPhoneNumber(this.telefono)) {
            if (this.validateEmail(this.correoElectronico)) {
              console.log(this.nombreCuenta);
              console.log(this.apellido);
              console.log(this.cedula);
              console.log(this.telefono);
              console.log(this.fechaNacimiento);
              console.log(this.correoElectronico);
              console.log(this.nombreEncargado);
              console.log(this.telefonoEncargado);
              console.log(this.empAccount);

              createAccount({
                nombreCuenta: this.nombreCuenta,
                apellido: this.apellido,
                cedula: this.cedula,
                telefono: this.telefono,
                fechaNacimiento: this.fechaNacimiento,
                correoElectronico: this.correoElectronico,
                nombreEncargado: this.nombreEncargado,
                telefonoEncargado: this.telefonoEncargado,
                esEmpresarial: this.empAccount,
              })
                .then((result) => {
                  console.log("cuenta creada correctamente: " + result);
                  if (result) {
                    this.parentAccountSelectedRecord = result.Id;
                    guardarAsset({
                      numeroPlaca: this.placa,
                      tipoVehi: this.tipo,
                      marca: this.marca,
                      modelo: this.modelo,
                      numeroChasis: this.numeroChasis,
                      motor: this.motor,
                      color: this.color,
                      anio: this.anioVehiculo,
                      kilometros: this.kilometros,
                      accountSelected: this.parentAccountSelectedRecord,
                    })
                      .then((result) => {
                        // handle success, maybe show a success message
                        console.log("vehiculo creado correctamente: " + result);
                        if (result) {
                          this.assetPlaca = result.Id;
                          if (this.assetPlaca != null) {
                            this.infoData = true;
                            this.isModalOpen = false;
                            this.accountExists = true;
                            this.firstStep = true;
                            this.secondStep = false;
                            this.empAccount = false;
                            this.thirdStep = false;
                            this.showCrtContactModal = true;
                          }
                        }
                      })
                      .catch((error) => {
                        // handle error
                        console.error("Error creando record Asset", error);
                        LightningAlert.open({
                          message: "Error: " + error.body.pageErrors[0].message,
                          theme: "error",
                          label: "Error!",
                        });
                      });
                  }
                })
                .catch((error) => {
                  // handle error
                  console.error("Error creando record Cuenta", error);
                  LightningAlert.open({
                    message: "Error: " + error.body.pageErrors[0].message,
                    theme: "error",
                    label: "Error!",
                  });
                });
            } else {
              console.error("Error creando record Cuenta");
              LightningAlert.open({
                message: "Por favor validar el formato del correo electronico.",
                theme: "error",
                label: "Error!",
              });
            }
          } else {
            console.error("Error creando record Cuenta");
            LightningAlert.open({
              message:
                "El numero debe iniciar con el codigo +506 seguido de 8 números.",
              theme: "error",
              label: "Error!",
            });
          }
        } else {
          //guardar Asset Nuevo
          console.log("Entro Guardar");
          //numeroPlaca
          guardarAsset({
            numeroPlaca: this.placa,
            tipoVehi: this.tipo,
            marca: this.marca,
            modelo: this.modelo,
            numeroChasis: this.numeroChasis,
            motor: this.motor,
            color: this.color,
            anio: this.anioVehiculo,
            kilometros: this.kilometros,
            accountSelected: this.parentAccountSelectedRecord,
          })
            .then((result) => {
              // handle success, maybe show a success message
              console.log("vehiculo creado correctamente: " + result);
              if (result) {
                this.assetPlaca = result.Id;
                if (this.assetPlaca != null) {
                  this.infoData = true;
                  this.isModalOpen = false;
                  this.accountExists = true;
                  this.firstStep = true;
                  this.secondStep = false;
                  this.empAccount = false;
                  this.thirdStep = false;
                  this.showCrtContactModal = true;
                }
              }
            })
            .catch((error) => {
              // handle error
              console.error(
                "Error creando record Asset",
                error.body.pageErrors[0].message
              );
              LightningAlert.open({
                message: "Error: " + error.body.pageErrors[0].message,
                theme: "error",
                label: "Error!",
              });
            });
        }
      } else {
        console.log("No pudo crear");
      }
    }
    console.log("Listo para crear");
  }

  submitDetails() {
    if (
      this.placa != null &&
      this.placa != undefined &&
      this.placa != "" &&
      this.numeroChasis != null &&
      this.numeroChasis != undefined &&
      this.numeroChasis != "" &&
      this.motor != null &&
      this.motor != undefined &&
      this.motor != "" &&
      this.anioVehiculo != null &&
      this.anioVehiculo != undefined &&
      this.anioVehiculo != "" &&
      this.kilometros != null &&
      this.kilometros != undefined &&
      this.kilometros != ""
    ) {
      //revisar si primero crear Cuenta
      if (
        this.accountExists == false &&
        (this.parentAccountSelectedRecord == null ||
          this.parentAccountSelectedRecord == undefined)
      ) {
        console.log("Se necesitan datos de cuenta 2");
        console.log(this.nombreCuenta);
        console.log(this.apellido);
        console.log(this.cedula);
        console.log(this.telefono);
        console.log(this.fechaNacimiento);
        console.log(this.correoElectronico);
        console.log(this.nombreEncargado);
        console.log(this.telefonoEncargado);
        console.log(this.empAccount);
        createAccount({
          nombreCuenta: this.nombreCuenta,
          apellido: this.apellido,
          cedula: this.cedulaBuscada,
          telefono: this.telefono,
          fechaNacimiento: this.fechaNacimiento,
          correoElectronico: this.correoElectronico,
          nombreEncargado: this.nombreEncargado,
          telefonoEncargado: this.telefonoEncargado,
          esEmpresarial: this.empAccount,
        })
          .then((result) => {
            console.log("cuenta creada correctamente: " + result);
            console.log(result);
            if (result) {
              this.parentAccountSelectedRecord = result.Id;
              guardarAsset({
                numeroPlaca: this.placa,
                tipoVehi: this.tipo,
                marca: this.marca,
                modelo: this.modelo,
                numeroChasis: this.numeroChasis,
                motor: this.motor,
                color: this.color,
                anio: this.anioVehiculo,
                kilometros: this.kilometros,
                accountSelected: this.parentAccountSelectedRecord,
              })
                .then((result) => {
                  // handle success, maybe show a success message
                  console.log("vehiculo creado correctamente: " + result);
                  if (result) {
                    this.isModalOpen = false;
                    this.assetPlaca = result.Id;
                    if (this.assetPlaca != null) {
                      this.infoData = true;
                      this.isModalOpen = false;
                      this.accountExists = true;
                      this.firstStep = true;
                      this.secondStep = false;
                      this.empAccount = false;
                      this.thirdStep = false;
                      this.showCrtContactModal = true;
                    }
                  }
                })
                .catch((error) => {
                  // handle error
                  console.error("Error creando record Asset", error);
                  LightningAlert.open({
                    message: "Error: " + error.body.pageErrors[0].message,
                    theme: "error",
                    label: "Error!",
                  });
                });
            }
          })
          .catch((error) => {
            // handle error
            console.error("Error creando record Cuenta", error);
            LightningAlert.open({
              message: "Error: " + error.body.pageErrors[0].message,
              theme: "error",
              label: "Error!",
            });
          });
      } else {
        //guardar Asset Nuevo
        console.log("Entro Guardar");
        //numeroPlaca
        guardarAsset({
          numeroPlaca: this.placa,
          tipoVehi: this.tipo,
          marca: this.marca,
          modelo: this.modelo,
          numeroChasis: this.numeroChasis,
          motor: this.motor,
          color: this.color,
          anio: this.anioVehiculo,
          kilometros: this.kilometros,
          accountSelected: this.parentAccountSelectedRecord,
        })
          .then((result) => {
            // handle success, maybe show a success message
            console.log("vehiculo creado correctamente: " + result);
            if (result) {
              this.assetPlaca = result.Id;
              if (this.assetPlaca != null) {
                this.infoData = true;
                this.firstStep = false;
                this.secondStep = true;
              }
            }
          })
          .catch((error) => {
            // handle error
            console.error(
              "Error creando record Asset",
              error.body.pageErrors[0].message
            );
            LightningAlert.open({
              message: "Error: " + error.body.pageErrors[0].message,
              theme: "error",
              label: "Error!",
            });
          });
      }
    } else {
      console.error("Error faltan campos ");
      LightningAlert.open({
        message: "Error: Por favor complete todos los datos.",
        theme: "error",
        label: "Error!",
      });
    }
  }

  @track mostrarHorarios = false;

  validarHorarios(event) {
    this.nuevaFecha = event.detail.value;
    console.log(this.nuevaFecha);
    var date = new Date(this.nuevaFecha);
    var day = String(date.getDate()).padStart(2, "0"); // Add leading zero if needed
    var month = String(date.getMonth() + 1).padStart(2, "0"); // Months are zero-based, so add 1
    var year = date.getFullYear();
    var formattedDate = `${day}/${month}/${year}`;

    var sucursal = this.serviceTerritory;
    checkTiempos({ str: sucursal, dat: formattedDate })
      .then((response) => {
        console.error("Resultado consultar fecha ", response);
        var tempArray = response[0].split(",");
        var convertedArray = null;
        console.log(Array.isArray(tempArray));
        console.log(tempArray.length > 0);
        if (Array.isArray(tempArray) && tempArray.length > 0) {
          convertedArray = tempArray.map((item) => ({
            label: item,
            value: item,
          }));
        }
        console.log(convertedArray);
        this.mostrarHorarios = true;
        this.optionsHorarios = response;
      })
      .catch((error) => {
        console.error("Error consultando fecha ", error);
      });

    this.mostrarFechaCambio = true;
  }

  handleChangeHora(event) {
    this.horaElegida = event.detail.value;
  }
  @track horaGuardada;
  cambiarHorarios() {
    console.log(this.nuevaFecha);
    console.log(this.horaElegida);
    this.showSpinner = true;
    actualizarHorarios({ recordId: this.esteRecord, fecha: this.nuevaFecha })
      .then((response) => {
        this.fechaSeleccionada = response.StartDateTime;
        this.fechaSeleccionada = response.StartDateTime;
        this.horaGuardada = response.StartDateTime;
        console.error("Resultado consultar fecha ", response);
        //this.noValidar = false;
        this.showSpinner = false;
      })
      .catch((error) => {
        console.error("Error consultando fecha ", error);
        LightningAlert.open({
          message: "Error: " + error.body.pageErrors[0].message,
          theme: "error",
          label: "Error!",
        });
      });
    //this.fechaSeleccionada = response.StartDateTime;
    this.fechaSeleccionada = this.fechaSeleccionada;
  }

  handleChangeTipo(event) {
    this.tipo = event.detail.value;
    if (this.tipo == "Mula" || this.tipo == "Cuadraciclo") {
      this.mostrarHoras = true;
      console.log("Horas", this.mostrarHoras);
    } else {
      this.mostrarHoras = false;
      console.log("Horas", this.mostrarHoras);
    }
    getDependentMap({
      controlField: "Tipo_de_veh_culo__c",
      depentField: "Marca_Nvo__c",
    })
      .then((result) => {
        // handle success, maybe show a success message
        console.log(result);
        if (result) {
          const values = result[this.tipo];
          console.log(values);
          var marcas;
          marcas = [];
          marcas.push({ label: "-- --", value: "" });
          values.forEach((element) => {
            marcas.push({ label: element, value: element });
          });
          this.modalOptionsMarca = marcas;
        }
      })
      .catch((error) => {
        // handle error
        console.error("Error updating record", error);
      });
  }

  handleChangeMarca(event) {
    this.marca = event.detail.value;
    getDependentMap({
      controlField: "Marca_Nvo__c",
      depentField: "Modelo_Nvo2__c",
    })
      .then((result) => {
        // handle success, maybe show a success message
        console.log(result);
        if (result) {
          const values = result[this.marca];
          console.log(values);
          var marcas;
          marcas = [];
          marcas.push({ label: "-- --", value: "" });
          values.forEach((element) => {
            marcas.push({ label: element, value: element });
          });
          this.modalOptionsModelo = marcas;
        }
      })
      .catch((error) => {
        // handle error
        console.error("Error updating record", error);
      });
  }

  @track citaCreadaExit = false;
  @track errCrearCita = false;

  handleCloseErrModal() {
    this.errCrearCita = false;
  }

  cerrarModalDup() {
    this.existeOtroEvento = false;
  }

  @track recordCreado = "";
  @track existeOtroEvento = "";
  @track aceptaDup = false;
  @track botonDup = true;

  setAceptaDup() {
    this.aceptaDup = !this.aceptaDup;
    this.botonDup = !this.botonDup;
    this.ignorarDuplicado = true;
  }

  cerrarDupConfirma() {
    this.assetPlaca;
    this.valueAsesor;
    this.serviceTerritory;
    this.calendarioSel;
    this.fechaSeleccionada;
    this.kilometros;
    this.showSpinner = true;
    if (
      this.asesorSel != null &&
      this.asesorSel != "" &&
      this.asesorSel != undefined
    ) {
      this.valueAsesor = this.asesorSel;
    }
    console.log("========================CALENDARIO=========================");
    console.log(this.calendarioSel);
    console.log("========================ASESOR=========================");
    console.log(this.valueAsesor);
    console.log(
      "========================serviceTerritory========================="
    );
    console.log(this.serviceTerritory);
    if (
      this.valueAsesor == undefined ||
      this.valueAsesor == "" ||
      this.valueAsesor == null
    ) {
      this.valueAsesor = this.asesorSel;
    }
    console.log("========================ASESOR2=========================");
    console.log(this.valueAsesor);
    console.log(this.fechaSeleccionada);
    console.log(this.serviceTerritory);

    getDataAsesor({ asesorId: this.valueAsesor })
      .then((result) => {
        // handle success, maybe show a success message
        console.log("Asesor obtenido: " + result);

        if (result) {
          this.valueAsesor = result[0].Name;
        }
      })
      .catch((error) => {
        // handle error
        console.error("Error obteniendo el asesor ", error);
      });
    //Revisar por otros eventos mismos datos

    if (this.aceptaDup == true) {
      this.showSpinner = true;
      console.log("===============Contacto==================");
      console.log(this.parentContactSelectedRecord);
      console.log("===================Origen======================");
      console.log(this.value);
      createEvent({
        contactId: this.parentContactSelectedRecord,
        cocheId: this.assetPlaca,
        asesorId: this.valueAsesor,
        sucursal: this.calendarioSel,
        fechaHoraSolicitada: this.fechaSeleccionada,
        kilometros: this.kilometros,
        serviceTerritoryBuscar: this.serviceTerritory,
        origenCita: this.value,
        comentarios: this.descripcion,
        ignorarDuplicado: this.ignorarDuplicado,
      })
        .then((result) => {
          // handle success, maybe show a success message
          console.log("Evento creado: " + result);
          this.citaCreadaExit = true;
          this.showSpinner = false;
          if (result) {
            this.recordCreado = result;
            updateEventOrigen({
              idShadow: this.recordCreado,
              origenCorrecto: this.value,
            })
              .then((result) => {
                // handle success, maybe show a success message
                console.log("Evento creado: " + result);
                if (result != null && result != "" && result != undefined) {
                }
              })
              .catch((error) => {
                // handle error
                console.error("Error cambiando el origen ", error);
                this.errCrearCita = true;
              });
            this.urlExiste = false;
          }
          console.log(this.recordCreado);
        })
        .catch((error) => {
          // handle error
          console.error("Error creando el evento ", error);
          this.errCrearCita = true;
          this.showSpinner = false;
        });
    }
  }

  crearEvento() {
    this.assetPlaca;
    this.valueAsesor;
    this.serviceTerritory;
    this.calendarioSel;
    this.fechaSeleccionada;
    this.kilometros;
    this.showSpinner = true;
    if (
      this.asesorSel != null &&
      this.asesorSel != "" &&
      this.asesorSel != undefined
    ) {
      this.valueAsesor = this.asesorSel;
    }
    console.log("========================CALENDARIO=========================");
    console.log(this.calendarioSel);
    console.log("========================ASESOR=========================");
    console.log(this.valueAsesor);
    console.log(
      "========================serviceTerritory========================="
    );
    console.log(this.serviceTerritory);
    if (
      this.valueAsesor == undefined ||
      this.valueAsesor == "" ||
      this.valueAsesor == null
    ) {
      this.valueAsesor = this.asesorSel;
      this.showSpinner = false;
      if (
        this.valueAsesor == undefined ||
        this.valueAsesor == "" ||
        this.valueAsesor == null
      ) {
        LightningAlert.open({
          message: "Error: Seleccione un asesor.",
          theme: "error",
          label: "Error!",
        });
      }
    } else {
      console.log(this.fechaSeleccionada);
      console.log(this.serviceTerritory);

      getDataAsesor({ asesorId: this.valueAsesor })
        .then((result) => {
          // handle success, maybe show a success message
          console.log("Asesor obtenido: ");
          console.log(result);

          if (result) {
            this.valueAsesor = result[0].Name;
          }
        })
        .catch((error) => {
          // handle error
          console.error("Error obteniendo el asesor ", error);
        });
      //Revisar por otros eventos mismos datos

      console.log("Datos de buscar duplicidad");
      console.log(this.valueAsesor);
      console.log(this.calendarioSel);
      console.log(this.fechaSeleccionada);
      console.log(this.esteRecord);

      buscarDuplicado({
        asesorId: this.valueAsesor,
        sucursal: this.calendarioSel,
        fechaHoraSolicitada: this.fechaSeleccionada,
        esteEvento: this.esteRecord,
      })
        .then((result) => {
          // handle success, maybe show a success message
          console.log("Evento encontrado: " + result);

          if (result == true) {
            this.showSpinner = false;
            this.existeOtroEvento = true;
          } else {
            console.log("===============Contacto==================");
            console.log(this.parentContactSelectedRecord);
            console.log("===================Origen======================");
            console.log(this.value);
            console.log("asesor buscado");
            console.log(this.valueAsesor);
            createEvent({
              contactId: this.parentContactSelectedRecord,
              cocheId: this.assetPlaca,
              asesorId: this.valueAsesor,
              sucursal: this.calendarioSel,
              fechaHoraSolicitada: this.fechaSeleccionada,
              kilometros: this.kilometros,
              serviceTerritoryBuscar: this.serviceTerritory,
              origenCita: this.value,
              comentarios: this.descripcion,
              ignorarDuplicado: this.ignorarDuplicado,
            })
              .then((result) => {
                // handle success, maybe show a success message
                console.log("Evento creado: " + result);
                this.citaCreadaExit = true;
                this.showSpinner = false;
                if (result) {
                  this.recordCreado = result;
                  updateEventOrigen({
                    idShadow: this.recordCreado,
                    origenCorrecto: this.value,
                  })
                    .then((result) => {
                      // handle success, maybe show a success message
                      console.log("Evento creado: " + result);
                      if (
                        result != null &&
                        result != "" &&
                        result != undefined
                      ) {
                      }
                    })
                    .catch((error) => {
                      // handle error
                      console.error("Error cambiando el origen ", error);
                      this.errCrearCita = true;
                    });
                  this.urlExiste = false;
                }
                console.log(this.recordCreado);
              })
              .catch((error) => {
                // handle error
                console.error("Error creando el evento ", error);
                this.errCrearCita = true;
                this.showSpinner = false;
              });
          }
        })
        .catch((error) => {
          // handle error
          console.error("Error creando el evento ", error);
          this.errCrearCita = true;
          this.showSpinner = false;
        });
    }
  }

  irAevento() {
    console.log("origen seleccionado vale=============");
    console.log(this.value);

    console.log(this.recordCreado);
    console.log(this.esteRecord);

    console.log(this.urlEvento);

    if (
      this.urlEvento == "" ||
      this.urlEvento == null ||
      this.urlEvento == undefined
    ) {
      getUrlEvent({
        idShadow: this.recordCreado,
        esteRecord: this.esteRecord,
        origenCorrecto: this.value,
      })
        .then((result) => {
          // handle success, maybe show a success message
          console.log("Evento creado: " + result);
          if (result != null && result != "" && result != undefined) {
            this.urlEvento = result;
            window.location.replace("/" + result);
            //window.location.replace("https://redmotors--partialp2.sandbox.lightning.force.com/"+result);
          }
        })
        .catch((error) => {
          // handle error
          console.error("Error creando el evento ", error);
          this.errCrearCita = true;
        });
    } else {
      window.location.replace("/" + this.urlEvento);
      //window.location.replace("https://redmotors--partialp2.sandbox.lightning.force.com/"+this.urlEvento);
    }
  }

  irAcalendario() {
    console.log("origen seleccionado vale");
    console.log(this.value);

    console.log(this.recordCreado);
    console.log(this.esteRecord);
    getUrlEvent({
      idShadow: this.recordCreado,
      esteRecord: this.esteRecord,
      origenCorrecto: this.value,
    })
      .then((result) => {
        // handle success, maybe show a success message
        console.log("Evento creado: " + result);
        if (result != null && result != "" && result != undefined) {
        }
      })
      .catch((error) => {
        // handle error
        console.error("Error abriendo nueva en el evento ", error);
        this.errCrearCita = true;
      });
    window.location.replace("/lightning/o/Event/home");
    // windows.location.replace("https://redmotors--partialp2.sandbox.lightning.force.com/lightning/o/Event/home");
  }

  handleChangeModelo(event) {
    this.modelo = event.detail.value;
  }

  closeModal() {
    this.isModalOpen = false;
    this.accountExists = true;
    this.firstStep = true;
    this.secondStep = false;
    this.empAccount = false;
    this.thirdStep = false;
  }

  previousStep() {
    this.firstStep = true;
    this.secondStep = false;
    this.accountExists = true;
    this.empAccount = false;
    this.thirdStep = false;
  }

  showSecondStep() {
    this.firstStep = false;
    this.thirdStep = false;
    this.secondStep = true;
    this.empAccount = false;
    this.accountExists = true;
  }

  handleAccountExistsChange() {
    this.accountExists = !this.accountExists;
    this.empAccount = false;
  }

  handleEmpAccount() {
    this.empAccount = !this.empAccount;
  }

  // Eventos para buscar por placa o por vin
  @track vehiculoPlaca = true;
  @track vehiculoVin = false;

  handleSearchPlaca() {
    this.vehiculoPlaca = true;
    this.vehiculoVin = false;
  }

  handleSearchVin() {
    this.vehiculoVin = true;
    this.vehiculoPlaca = false;
  }

  closeCampTec() {
    this.campaniasTec = false;
  }
}