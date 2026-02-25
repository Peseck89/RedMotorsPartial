import { LightningElement, track, wire, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import createAccount from "@salesforce/apex/cT_ChangeData_ctrl.createAccount";
import updateDataAccount from "@salesforce/apex/cT_ChangeData_ctrl.updateDataAccount";
import updateAccount from "@salesforce/apex/cT_ChangeData_ctrl.updateAccount";
import createContact from "@salesforce/apex/cT_ChangeData_ctrl.createContact";
import LightningAlert from "lightning/alert";
import getCedula from "@salesforce/apex/CT_nuevaCita_controller.getCedula";

import updateContact from "@salesforce/apex/cT_ChangeData_ctrl.updateContact";
import updateContactOtro from "@salesforce/apex/cT_ChangeData_ctrl.updateContactOtro";
import updateContactData from "@salesforce/apex/cT_ChangeData_ctrl.updateContactData";
import cambiarFacturacionCaso from "@salesforce/apex/cT_ChangeData_ctrl.cambiarFacturacionCaso";
import updateAssetkilometraje from "@salesforce/apex/cT_ChangeData_ctrl.updateAssetkilometraje";
import updateFacturacionCaso from "@salesforce/apex/cT_ChangeData_ctrl.updateFacturacionCaso";
import updateKilometraje from "@salesforce/apex/cT_ChangeData_ctrl.updateKilometraje";
import getHistorialVehiculo from "@salesforce/apex/cT_ChangeData_ctrl.getHistorialVehiculo";
import isCurrentUserAdmin from "@salesforce/apex/cT_ChangeData_ctrl.isCurrentUserAdmin";

import getCaso from "@salesforce/apex/ct_casoredi_ctrl.getCaseData";
import getWO from "@salesforce/apex/ct_casoredi_ctrl.getCaseOrders";

import getTrabajosPostergados from "@salesforce/apex/PN_TrabajosController.getTrabajosApex";
import { refreshApex } from '@salesforce/apex';
import { deleteRecord } from 'lightning/uiRecordApi';
import { reduceErrors } from 'c/ldsUtils';
import { RefreshEvent } from "lightning/refresh";

import RECHAZADO_FIELD from "@salesforce/schema/Archivo_lineas_rechazadas__c.PN_RechazadoCaso__c";
import ID_FIELD from "@salesforce/schema/Archivo_lineas_rechazadas__c.Id";
import { updateRecord } from "lightning/uiRecordApi";

import aceptarTrabajoA from "@salesforce/apex/PN_TrabajosController.aceptarTrabajoApex";


export default class CT_CaseChangeData_lwc extends LightningElement {
  @api recordId;
  @track editAccountOwner = false;
  @track cambioCuenta = false;
  @track noExisteCuenta = false;
  @track cuentaEmpresarial = false;
  @track nextButton = false;
  @track stepTwo;
  @track actuCuenta = false;
  @track editContact;
  @track editInvoiceData;
  @track placa;
  @track contactAccountId;
  @track IdAsset;
  @track showSpinner = false;
  @track showSpinnerTrabajos = false;
  @track parentAccountSelectedRecordInvoice;
  @track correoFacturacion;
  @track telefonoFacturacion;
  @track actuMismo;
  @track actuKilometraje;
  @track estadoCaso;
  @track statusDetail;
  @track disabledButtons = false;

  @track editKm = false;
  @track kilometrajeAsset;
  @track kilometraje;
  @track showEditZoneKM = false;
  @track historiales = [];
  @track isAdmin = false;

  @track editInvoiceData = false;
  @track esCambioFacturacion = false; 
  @track cambioCuenta = false;
  @track actuCuenta = false;
  @track nombreFacturacion;
  @track correoFacturacion;
  @track telefonoFacturacion;
  @track parentAccountSelectedRecordInvoice;

  @track modalActualizarPropietarioVisible = false;
  @track isPersonAccount = false;
  @track accountIdActual = "";
  @track facturacionActual = "";
  @track tipoCliente = "";
  @track caso;
  @track personalFacturacion = false;
  @track crearCuentaVisible = false;
  @track tipoclienteNuevo = "";
  @track tipodeclientecampoNuevo = "";
  @track tipodeidentificacionNuevo = "";
  @track paisNuevo = "";
  @track esFactura = true;
  @track cedulaNueva = "";
  @track alertPropietario = false;
  @track alertFacturacion = false;
  
 //Trabajos Postergados
  @track alertTrabajos = false;
  @track trabajosPostergados = false;
  //@track lsTrabajos = [];
   lsTrabajos;

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }

  @wire(isCurrentUserAdmin)
  checkAdminStatus({ data, error }) {
    if (data) {
      this.isAdmin = data;
      console.log("Es admin? ", this.isAdmin);
    } else if (error) {
      console.error("Error:", error);
    }
  }

  abrirModalActualizarPropietario() {
    if (this.caso && this.caso.Account) {
      this.accountIdActual = this.caso.Account.Id;
      this.isPersonAccount = this.caso.Account.IsPersonAccount;
      this.tipoCliente = this.isPersonAccount ? "fisica" : "juridica";
      this.modalActualizarPropietarioVisible = true;
    }
  }

  cerrarModalActualizarPropietario() {
    this.modalActualizarPropietarioVisible = false;
  }

  handleCuentaActualizada() {
    this.cerrarModalActualizarPropietario();
    this.cargarDatos(); // o lo que uses para refrescar el caso
  }

  setCedulaBuscar(event) {
    this.cedulaBuscada = event.detail.value;
  }

  @wire(getCaso, { recordId: "$recordId" })
  getCaseData({ error, data }) {
    if (data) {
      console.log("===========DATA ACTU COMPONENT===========");
      console.log(data);
      console.log("===========DATA ACTU COMPONENT===========");

      const caso = data[0];

      if (data.length === 0) return;
      const caseRecord = data[0];
      if (!caseRecord) return;

      this.estadoCaso = data[0].Status;

      if (this.estadoCaso == "Cerrado") {
        this.disabledButtons = true;
      } else {
        this.disabledButtons = false;
      }

      var correoRevisar = "";
      this.personalAccount = data[0].Account.IsPersonAccount;
      
      if (!this.personalAccount) {
        if(!data[0].Account.CorreoElectronicoEmpresarial__c || !data[0].Account.Phone) {
          this.alertPropietario = true;
        }
        this.correoElectronico =
          data[0].Account.CorreoElectronicoEmpresarial__c;
        correoRevisar = data[0].Account.CorreoElectronicoEmpresarial__c;
      } else {
        if(!data[0].Account.PersonEmail || !data[0].Account.Phone) {
          this.alertPropietario = true;
        }
        this.personalEmail = data[0].Account.PersonEmail;
        this.correoElectronico = data[0].Account.PersonEmail;
        correoRevisar = data[0].Account.PersonEmail;
      }
      console.log(correoRevisar);
      console.log(this.personalAccount);
      console.log(!this.personalAccount);
      //if(!this.personalAccount) {
      console.log("==============CONTACTO==================");
      console.log(data[0].ContactId);

      if (
        data[0].ContactId === null ||
        data[0].ContactId === undefined ||
        data[0].ContactId === ""
      ) {
        // Aquí poner la variable para mostrar popup
        this.nombreFacturacion = data[0].Account.Name || null;
        this.apellidoContacto = "";
        this.contactName = "";
        this.contactPhone = "";
        this.contactEmail = "";
      } else {
        this.urlContact = `/lightning/r/${data[0].ContactId}/view`;
        this.parentContactSelectedRecord = data[0].ContactId;
        this.apellidoContacto = data[0].Contact.LastName;
        this.contactName = data[0].Contact.FirstName || "";
        this.contactPhone = data[0].Contact.Phone || "";
        this.contactEmail = data[0].Contact.Email || "";
        // this.nombreFacturacion = data[0].Contact.Name;
      }
      //}

      this.accountId = data[0].AccountId;
      this.contactAccountId = data[0].Account?.PersonContactId;
      this.parentAccountSelectedRecord = data[0].AccountId;
      this.urlAccount = `/lightning/r/${data[0].AccountId}/view`;

      this.nombreCuenta = data[0].Account.Name;
      this.identificacion = data[0].Account.Cedula__c;
      this.telefono = data[0].Account.Phone;
      if (
        this.nombreCuenta == null ||
        this.nombreCuenta == "" ||
        correoRevisar == null ||
        correoRevisar == "" ||
        this.telefono == null ||
        this.telefono == ""
      ) {
        // this.editAccountOwner = true;
        this.cambioCuenta = false;
        this.noExisteCuenta = false;
        this.cuentaEmpresarial = false;
        this.nextButton = false;

        this.stepTwo = false;

        this.actuCuenta = true;
      }

      if(!data[0]?.Cuenta_de_Facturacion__r?.Invoice_Email__c || !data[0]?.Cuenta_de_Facturacion__r?.Invoice_Phone__c) {
        this.alertFacturacion = true;
      }

      console.log("Alerta facturacion: ", this.alertFacturacion);
      

      this.correoFacturacion =
        data[0]?.Cuenta_de_Facturacion__r?.Invoice_Email__c || null;
      this.telefonoFacturacion =
        data[0]?.Cuenta_de_Facturacion__r?.Invoice_Phone__c || null;
      this.nombreFacturacion = data[0]?.Cuenta_de_Facturacion__r?.Name || null;

      if (
        this.nombreFacturacion == null &&
        this.telefonoFacturacion == null &&
        this.correoFacturacion == null
      ) {
        // this.editInvoiceData = true;
        this.cambioCuenta = true;
      } else if (
        this.telefonoFacturacion == null ||
        this.correoFacturacion == null
      ) {
        // this.editInvoiceData = true;
        this.actuCuenta = true;
      }

      if (!caso.Cuenta_de_Facturacion__c && caso.Status !== "Cerrado") {
        updateFacturacionCaso({
          recordId: this.recordId,
          correoFact: null,
          phoneFact: null,
        })
          .then(() => {
            window.location.reload();
          })
          .catch((error) => {
            console.error("Error asignando cuenta automáticamente", error);
          });
      }

      this.nombreContacto = data[0].Contact?.Name || "";
      this.correoContacto = data[0].Contact?.Email || "";
      this.identificacionContacto = data[0].Contact?.Cedula__c || "";
      this.telefonoContacto = data[0].Contact?.Phone || "";

      if (
        this.nombreContacto == null ||
        this.nombreContacto == "" ||
        this.correoContacto == null ||
        this.correoContacto == "" ||
        this.telefonoContacto == null ||
        this.telefonoContacto == ""
      ) {
        // this.editContact = true;
        this.cambioCuenta = false;
        this.noExisteCuenta = false;
        this.actuCuenta = true;
      }

      this.IdAsset = data[0].AssetId;

      this.kilometrajeAsset = caseRecord.Asset?.Kilometros__c || null;

      console.log("================== Case Record ==================");
      console.log(data[0]);
      console.log("================== Case Record ==================");  

      this.caso = caseRecord;
      console.log(this.caso);
      this.facturacionActual = this.caso.Cuenta_de_Facturacion__c;
      this.personalFacturacion = this.caso.Cuenta_de_Facturacion__r?.IsPersonAccount;
      console.log('Personal Facturacion: ', this.personalFacturacion);
      
      this.accountIdActual = this.caso.AccountId;
      console.log(this.accountIdActual);
      this.isPersonAccount = this.caso.Account.IsPersonAccount;
      console.log(this.isPersonAccount);
      this.tipoCliente = this.isPersonAccount ? "fisica" : "juridica";
      console.log(this.tipoCliente);
      //this.modalActualizarPropietarioVisible = true;

      // this.kilometrajeAsset = data[0].Asset.Kilometros__c;
      this.actuKilometraje = data[0].Actualizo_Kilometraje__c;
      this.assetUrl = `/lightning/r/${data[0].AssetId}/view`;
      this.cargarHistorial();

      this.placa = data[0].Asset.Name;
      this.statusDetail = data[0].StatusDetail__c;

      console.log("Actualizacion de kilometraje: ", this.actuKilometraje);
    } else if (error) {
      console.log("Error de data", error);
    } else {
      console.log(error);
    }
  }

  @wire(getWO, { caseId: "$recordId" })
  getCaseOrders({ error, data }) {
    if (data) {
      console.log("===========DATA WO ===========");
      console.log(data);
      console.log("===========DATA WO ===========");

      if (data.length > 0 && data[0].Kilometros__c != null) {
        this.kilometrajeOrden = data[0].Kilometros__c;
      } else {
        this.kilometrajeOrden = null;
      }
    } else if (error) {
      console.log("Error de data", error);
    }
  }

  @wire(getTrabajosPostergados, { caseId: "$recordId" })
  getTrabajosApex({ error, data }) {
    if (data) {
      console.log("===========DATA TRABAJOS ===========");
      console.log(data);
      console.log("===========DATA TRABAJOS ===========");

      this.lsTrabajos = data;

      if(data.length > 0) this.alertTrabajos = true;

    } else if (error) {
      console.log("Error de data", error);
    }
  }

  async deleteTrabajo(event) {
      //const recordId = event.target.dataset.recordid;
      const idTrabajo = event.target.dataset.id;

      // Create the recordInput object
      const fields = {};
      fields[ID_FIELD.fieldApiName] = idTrabajo;
      fields[RECHAZADO_FIELD.fieldApiName] = true;
      

      const recordInput = { fields };

      updateRecord(recordInput)
        .then(() => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Success",
              message: "Trabajo Rechazado",
              variant: "success",
            }),
          );
          // Display fresh data in the form
          //return refreshApex(this.getTrabajosApex);
          window.location.reload();
        })
        .catch((error) => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error creating record",
              message: error.body.message,
              variant: "error",
            }),
          );
        });
  }

  aceptarTrabajo(event) {
        //const recordId = event.target.dataset.recordid;
        
        this.handleTrabajosPost();
        
        const idTrabajo = event.target.dataset.id;

        this.showSpinnerTrabajos = true;

        aceptarTrabajoA({
        trabajoId: idTrabajo
      })
        .then((result) => {
          if(result.exito){
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Success",
                message: "Trabajo Restaurado",
                variant: "success",
              }),
            );
          } else{
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Error",
                message: result.msg,
                variant: "error",
              }),
            );
          }
          this.showSpinnerTrabajos = false;
          window.location.reload();
        })
        .catch((error) => {
          console.error("Error aaceotando trabajo:", error);
          this.showSpinnerTrabajos = false;
          
        });

        
  }

  beginRefresh() {
    this.dispatchEvent(new RefreshEvent());
  }

  // Metodos para la cuenta de facturación
  cambiarFacturacion() {
    if (this.parentAccountSelectedRecordInvoice != null) {
      cambiarFacturacionCaso({
        recordId: this.recordId,
        accId: this.parentAccountSelectedRecordInvoice,
        actualizarWorkOrders: true,
      })
        .then(() => {
          this.showSpinner = false;
          window.location.reload();
        })
        .catch((error) => {
          console.error("Error actualizando facturación:", error);
          this.showSpinner = false;
        });
    } else {
      LightningAlert.open({
        message: "Por favor seleccione una cuenta.",
        theme: "error",
        label: "Error!",
      });
    }
  }

  actualizarFacturacion() {
    if (
      this.isValidPhoneNumber(this.telefonoFacturacion) &&
      this.validateEmail(this.correoFacturacion)
    ) {
      this.showSpinner = true;
      updateFacturacionCaso({
        recordId: this.recordId,
        correoFact: this.correoFacturacion,
        phoneFact: this.telefonoFacturacion,
      })
        .then(() => {
          this.showSpinner = false;
          window.location.reload();
        })
        .catch((error) => {
          console.error("Error actualizando datos:", error);
          this.showSpinner = false;
        });
    } else {
      LightningAlert.open({
        message: "Teléfono o correo inválidos.",
        theme: "error",
        label: "Error!",
      });
    }
  }

  isValidPhoneNumber(phoneNumber) {
    const phonePattern = /^\+506\d{8}$/; // +506 seguido de 8 dígitos
    return phonePattern.test(phoneNumber);
  }

  validateEmail(email) {
    const emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    return emailPattern.test(email);
  }

  cargarHistorial() {
    getHistorialVehiculo({ assetId: this.IdAsset })
      .then((result) => {
        this.historiales = result.map((hist, index) => ({
          ...hist,
          isFirst: index === 0,
          isEditing: false,
          tempNuevoKm: hist.NuevoKilometraje__c,
        }));
        this.error = undefined;
      })
      .catch((error) => {
        this.error = error;
        this.historiales = undefined;
      });
  }

  handleEdit(event) {
    const id = event.target.dataset.id;
    this.historiales = this.historiales.map((hist) => {
      if (hist.Id === id) {
        return { ...hist, isEditing: true };
      }
      return hist;
    });
  }

  handleCancel(event) {
    const id = event.target.dataset.id;
    this.historiales = this.historiales.map((hist) => {
      if (hist.Id === id) {
        return {
          ...hist,
          isEditing: false,
          tempNuevoKm: hist.NuevoKilometraje__c,
        };
      }
      return hist;
    });
  }

  setKilometrajeTemp(event) {
    const id = event.target.dataset.id;
    const value = parseFloat(event.target.value);
    this.historiales = this.historiales.map((hist) => {
      if (hist.Id === id) {
        return { ...hist, tempNuevoKm: value };
      }
      return hist;
    });
  }

  async handleSave(event) {
    this.showSpinner = true;
    const id = event.target.dataset.id;
    const historial = this.historiales.find((h) => h.Id === id);

    if (historial.tempNuevoKm < historial.UltimoKilometraje__c) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message: "El nuevo kilometraje no puede ser menor al anterior",
          variant: "error",
        })
      );
      this.showSpinner = false;
      return;
    }

    try {
      this.showSpinner = true;
      await updateKilometraje({
        historialId: id,
        nuevoKm: historial.tempNuevoKm,
        assetId: this.IdAsset,
        caseId: this.recordId,
      });

      this.dispatchEvent(
        new ShowToastEvent({
          title: "Éxito",
          message: "Kilometraje actualizado",
          variant: "success",
        })
      );
      this.showSpinner = false;
      window.location.reload();
    } catch (error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Error",
          message: error.body.message,
          variant: "error",
        })
      );
      this.showSpinner = false;
      console.log("Error actu KM", error.body);
    }
  }

  // Esta función se queda - util
  setKilometraje(event) {
    this.kilometrajeAsset = event.target.value;
    console.log("Kilometraje puesto");
    console.log(this.kilometrajeAsset);
  }

  // Esta función se queda - util
  handleKilometrajeChange() {
    updateAssetkilometraje({
      assetId: this.IdAsset,
      kilometraje: this.kilometrajeAsset,
      caseId: this.recordId,
    })
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Éxito",
            message: "Kilometraje actualizado correctamente",
            variant: "success",
          })
        );
        window.location.reload();
      })
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error de validación",
            message: error.body.message,
            variant: "error",
          })
        );
      });
  }

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }

  handleEditKm() {
    this.editKm = !this.editKm;
    this.showEditZoneKM = false;
  }

  mantenerTrabajosDelay() {

    

    this.handleTrabajosPost();

    

    
  }

  handleTrabajosPost(){
      this.trabajosPostergados = !this.trabajosPostergados;
  }

  handleChangeAccuntOwner() {
    this.editAccountOwner = !this.editAccountOwner;

    this.actuCuenta = true;
    this.cambioCuenta = false;
    this.noExisteCuenta = false;
    this.cuentaEmpresarial = false;
    this.nextButton = false;
    this.esCambioFacturacion = false;
    this.stepTwo = false;
    if(this.alertPropietario === true) {
      this.showToast(
        "Atención!",
        "Debe de completar los datos del propietario antes de continuar.",
        "error"
      );
    }
  }
  handleEditInvoice() {
    this.editInvoiceData = !this.editInvoiceData;
    this.actuCuenta = true;
    this.cambioCuenta = false;
    this.noExisteCuenta = false;
    this.esCambioFacturacion = true;
    console.log('Solo actualizar facturacion: ', this.esCambioFacturacion);
    if(this.alertFacturacion === true) {
      this.showToast(
        "Atención!",
        "Debe de completar los datos de facturación antes de continuar.",
        "error"
      );
    }
  }

  handleEditContact() {
    this.editContact = !this.editContact;
    this.cambioCuenta = false;
    this.noExisteCuenta = false;
    this.actuCuenta = true;
  }
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
    this.telefono = event.detail.value;
  }

  cambiarCorreoCuenta(event) {
    this.correoElectronico = event.detail.value;
    console.log(this.correoElectronico);
  }

  cambiarCedula(event) {
    this.cedula = event.detail.value;
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

  accountMismo() {
    this.actuCuenta = !this.actuCuenta;
    this.actuMismo = !this.actuMismo;
  }

  notAccountExists() {
    this.noExisteCuenta = !this.noExisteCuenta;
    this.nextButton = !this.nextButton;
  }

  empAccountSelect() {
    this.cuentaEmpresarial = !this.cuentaEmpresarial;
  }

  handleBackStepTwo() {
    this.stepTwo = false;
    this.nextButton = false;
    this.noExisteCuenta = false;
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

  handleValueSelectedOnAccountInvoice(event) {
    if (event.detail.id != undefined) {
      this.parentAccountSelectedRecordInvoice = event.detail.id;
    }
  }

  handleValueSelectedOnAccount(event) {
    if (event.detail.id != undefined) {
      this.parentAccountSelectedRecord = event.detail.id;
    }
  }

  actualizarCuenta() {
    console.log("===================actualizarCuenta==================");
    console.log(this.parentAccountSelectedRecord);
    if (true) {
      if (true) {
        this.showSpinner = true;
        console.log("this.stepTwo");
        console.log(this.stepTwo);
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
                  recordId: this.recordId,
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
                        this.contactEmail = result[0].PersonContact.Email;
                        window.location.reload();
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
                      window.location.reload();
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
                  recordId: this.recordId,
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
                      this.cuentaEmpresarial = false;

                      this.nombreCuenta = result[0].Name;
                      this.telefono = result[0].Phone;
                      this.identificacion = result[0].Cedula__c;
                      this.correoElectronico =
                        result[0].CorreoElectronicoEmpresarial__c;
                      this.cedula = result[0].codigoSoftland__c;
                      window.location.reload();
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
          console.log("this.actuCuenta");
          console.log(this.actuCuenta);
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
                  this.cuentaEmpresarial = false;
                  this.editAccountOwner = false;

                  this.nombreCuenta = result[0].Name;
                  this.telefono = result[0].Phone;
                  this.identificacion = result[0].Cedula__c;
                  if (this.personalAccount) {
                    this.personalEmail = result[0].PersonEmail;
                  } else {
                    this.correoElectronico =
                      result[0].CorreoElectronicoEmpresarial__c;
                  }
                  this.cedula = result[0].codigoSoftland__c;

                  this.showToast(
                    "En aprobación",
                    "El cambio de cuenta asociada requiere aprobación. Se ha enviado una solicitud.",
                    "base"
                  );
                  //window.location.reload();
                }
              })
              .catch((error) => {
                // handle error
                this.showSpinner = false;
                console.error("Error updating data record", error);
              });
          } else {
            console.log("this.parentAccountSelectedRecord ");
            console.log(this.parentAccountSelectedRecord);
            updateAccount({
              recordId: this.recordId,
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
                  this.cuentaEmpresarial = false;

                  this.nombreCuenta = result[0].Name;
                  this.telefono = result[0].Phone;
                  this.identificacion = result[0].Cedula__c;
                  if (this.personalAccount) {
                    this.personalEmail = result[0].PersonEmail;
                  } else {
                    this.correoElectronico =
                      result[0].CorreoElectronicoEmpresarial__c;
                  }
                  //this.correoElectronico =  result[0].CorreoElectronicoEmpresarial__c;
                  this.cedula = result[0].codigoSoftland__c;
                  this.showToast(
                    "En aprobación",
                    "El cambio de cuenta asociada requiere aprobación. Se ha enviado una solicitud.",
                    "base"
                  );
                  // window.location.reload();
                }
              })
              .catch((error) => {
                // handle error
                this.showSpinner = false;

                let mensajeError = "Ocurrió un error inesperado.";
                if (error?.body?.pageErrors?.length > 0) {
                  mensajeError = error.body.pageErrors[0].message;
                } else if (error?.body?.fieldErrors) {
                  const fieldErrArray = Object.values(
                    error.body.fieldErrors
                  )[0];
                  if (fieldErrArray && fieldErrArray.length > 0) {
                    mensajeError = fieldErrArray[0].message;
                  }
                } else if (error?.body?.message) {
                  mensajeError = error.body.message;
                } else if (error?.message) {
                  mensajeError = error.message;
                }
                this.showToast("Error", mensajeError, "error");

                console.error("Error updating record", error);
              });
          }
        }
      } else {
        LightningAlert.open({
          message: "Correo invalido.",
          theme: "error",
          label: "Error!",
        });
        this.telefonoError =
          "Número de teléfono no válido. Debe empezar por +506 y tener una longitud total de 10 dígitos.";
      }
    } else {
      LightningAlert.open({
        message:
          "Número de teléfono no válido. Debe empezar por +506 y tener una longitud total de 10 dígitos.",
        theme: "error",
        label: "Error!",
      });
      this.telefonoError =
        "Número de teléfono no válido. Debe empezar por +506 y tener una longitud total de 10 dígitos.";
    }
  }

  isValidPhoneNumber(phoneNumber) {
    const phoneNumberPattern = /^\+506\d{8}$/;
    return phoneNumberPattern.test(phoneNumber);
  }

  validateEmail(email) {
    const emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
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
  setCorreoFact(event) {
    this.correoFacturacion = event.detail.value;
  }
  setTelefonoFac(event) {
    this.telefonoFacturacion = event.detail.value;
  }

  setCedulaContacto(event) {
    this.identificacionContacto = event.detail.value;
  }

  setApellidoContacto(event) {
    this.apellidoContacto = event.detail.value;
  }
  setTelefonoContacto(event) {
    this.contactPhone = event.detail.value;
  }
  setCorreoContacto(event) {
    this.contactEmail = event.detail.value;
  }

  actualizarContactoMismo() {
    console.log(this.parentContactSelectedRecord);
    if (
      this.parentContactSelectedRecord != null ||
      this.parentContactSelectedRecord != undefined
    ) {
      console.log("entre a este 2");
      updateContact({
        recordId: this.recordId,
        contactId: this.parentContactSelectedRecord,
      })
        .then((result) => {
          console.log(this.assetPlaca);
          console.log(this.cocheVin);
          console.log(this.parentContactSelectedRecord);
          console.log("Record updated successfully, new value: " + result);
          this.showCrtContactModal = false;
          this.showSpinner = true;
          if (result) {
            console.log(result);
            this.editAccountOwner = false;
            this.cambioCuenta = false;
            this.noExisteCuenta = false;
            this.cuentaEmpresarial = false;
            this.editContact = false;
            this.contactName = result[0].Name;
            this.contactPhone = result[0].Phone;
            this.contactEmail = result[0].Email;
            window.location.reload();
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
    } else {
      LightningAlert.open({
        message: "La cuenta no tiene un contacto o es una cuenta empresarial.",
        theme: "error",
        label: "Error!",
      });
    }
  }

  actualizarContacto() {
    console.log("===================actualizarContacto==================");
    console.log(this.contactPhone);
    this.showSpinner = true;
    if (this.actuCuenta && this.noExisteCuenta != true) {
      //validacion de telefono
      if (
        this.isValidPhoneNumber(this.contactPhone) &&
        this.validateEmail(this.correoElectronico)
      ) {
        this.showSpinner = true;
        console.log("Entre actualizar COntacto data");
        console.log(this.parentContactSelectedRecord);
        console.log(this.contactName);
        console.log(this.apellidoContacto);
        console.log(this.contactPhone);
        console.log(this.contactEmail);
        console.log(this.identificacionContacto);
        updateContactData({
          contactId: this.parentContactSelectedRecord,
          nombreC: this.contactName,
          apellidoC: this.apellidoContacto,
          phoneC: this.contactPhone,
          emailC: this.contactEmail,
          cedulaCont: this.identificacionContacto,
        })
          .then((result) => {
            console.log("Record updated successfully, new value: " + result);
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
              this.apellidoContacto = result[0].LastName;
              this.contactPhone = result[0].Phone;
              this.contactEmail = result[0].Email;
              if (
                result[0].Cedula__c != null ||
                result[0].Cedula__c != undefined
              ) {
                this.identificacionContacto = result[0].Cedula__c;
              }
              window.location.reload();
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
          message:
            "Número de teléfono no válido. Debe empezar por +506 y tener una longitud total de 10 dígitos.",
          theme: "error",
          label: "Error!",
        });
        this.showSpinner = false;
        this.telefonoError =
          "Número de teléfono no válido. Debe empezar por +506 y tener una longitud total de 10 dígitos.";
      }
    } else {
      if (this.noExisteCuenta) {
        this.showSpinner = true;
        console.log("entro no existe contacto");
        this.showSpinner = true;
        if (this.contactoPrincipal) {
          console.log("es contacto principal");
        }
        if (this.isValidPhoneNumber(this.contactPhone)) {
          createContact({
            recordId: this.recordId,
            cuenta: this.parentAccountSelectedRecord,
            nombreContacto: this.contactName,
            apellidoContacto: this.apellidoContacto,
            telefonoContacto: this.contactPhone,
            correoContacto: this.contactEmail,
          })
            .then((result) => {
              this.cambioCuenta = false;
              this.showSpinner = true;
              console.log(this.parentAccountSelectedRecord);
              console.log("Record updated successfully, new value: " + result);
              if (result) {
                this.showSpinner = false;
                this.editAccountOwner = false;
                this.showCrtContactModal = false;
                this.cambioCuenta = false;
                this.noExisteCuenta = false;
                this.cuentaEmpresarial = false;
                this.editContact = false;
                //window.location.reload();
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
                message: "Error al crear, por favor revise duplicidad.",
                theme: "error",
                label: "Error!",
              });
              this.cambioCuenta = false;
              this.showSpinner = false;
              console.error("Error updating record", error);
            });
        } else {
          LightningAlert.open({
            message:
              "Número de teléfono no válido. Debe empezar por +506 y tener una longitud total de 10 dígitos.",
            theme: "error",
            label: "Error!",
          });
          this.showSpinner = false;
          this.telefonoError =
            "Número de teléfono no válido. Debe empezar por +506 y tener una longitud total de 10 dígitos.";
        }
      } else {
        //validacion de telefono
        this.showSpinner = true;
        console.log(this.parentContactSelectedRecord);
        console.log("entre a este 1");
        updateContactOtro({
          recordId: this.recordId,
          contactId: this.parentContactSelectedRecord,
        })
          .then((result) => {
            console.log(this.assetPlaca);
            console.log(this.cocheVin);
            console.log(this.parentContactSelectedRecord);
            console.log("Record updated successfully, new value: " + result);
            console.log(result);
            this.showCrtContactModal = false;
            this.showSpinner = true;
            if (result) {
              console.log(result);
              this.editAccountOwner = false;
              this.cambioCuenta = false;
              this.noExisteCuenta = false;
              this.cuentaEmpresarial = false;
              this.editContact = false;
              this.contactName = result[0].Name;
              this.contactPhone = result[0].Phone;
              this.contactEmail = result[0].Email;
              window.location.reload();
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
}