import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import createAccount from  '@salesforce/apex/cT_ChangeData_copy_ctrl.createAccount'; 
import updateDataAccount from '@salesforce/apex/cT_ChangeData_copy_ctrl.updateDataAccount';
import updateAccount from  '@salesforce/apex/cT_ChangeData_copy_ctrl.updateAccount';
import createContact from '@salesforce/apex/cT_ChangeData_copy_ctrl.createContact';
import LightningAlert from "lightning/alert";
import updateContact from  '@salesforce/apex/cT_ChangeData_copy_ctrl.updateContact';
import getCedula from  '@salesforce/apex/CT_nuevaCita_controller.getCedula';
import updateFacturacion from  '@salesforce/apex/cT_ChangeData_copy_ctrl.updateFacturacion';
import updateContactData from  '@salesforce/apex/cT_ChangeData_copy_ctrl.updateContactData';
import cambiarFacturacion from '@salesforce/apex/cT_ChangeData_copy_ctrl.cambiarFacturacion';
import getOT from '@salesforce/apex/ct_otRedis_ctrl.getWorkOrderData';
import updateContactOtro from "@salesforce/apex/cT_ChangeData_copy_ctrl.updateContactOtro";

export default class CT_ChangeDataOt_copy_lwc extends LightningElement {
  
  @api recordId; 
  @track editAccountOwner = false
  @track cambioCuenta = false
  @track noExisteCuenta = false
  @track contactAccountId
  @track actuMismo;
  @track cuentaEmpresarial = false
  @track nextButton = false
  @track stepTwo
  @track actuCuenta = false;
  @track editContact
  @track editInvoiceData
  @track IdAsset
  @track placa
  @track parentAccountSelectedRecordInvoice
  @track correoFacturacion
  @track telefonoFacturacion
  @track correoElectronicoEmpresarial
  @track disabledButons
  
  @wire(getOT, {recordId: '$recordId'})
  getWorkOrderData({error, data}) {
    if(data) {
      console.log('===========DATA===========');
      console.log(data);
      this.personalAccount = data[0].Account.IsPersonAccount;

      //if(!this.personalAccount) {
        console.log('==============CONTACTO==================');
        console.log(data[0].ContactId);
        if (data[0].ContactId === null || data[0].ContactId === undefined || data[0].ContactId === '') {
          // Aquí poner la variable para mostrar popup
        } else {
          this.contactName = data[0]?.Contact?.FirstName || null;
          this.apellidoContacto = data[0]?.Contact?.LastName || null;
          this.identificacionContacto = data[0].Contact.Cedula__c || null;
          this.contactPhone = data[0]?.Contact?.Phone || null;
          this.contactEmail = data[0]?.Contact?.Email || null;
          this.idContacto = data[0]?.ContactId || null;
          this.parentContactSelectedRecord = data[0]?.ContactId || null;
          this.contactUrl = `/lightning/r/${this.idContacto}/view`

          console.log(this.contactUrl);
        }
      //}
        if(this.contactName == null || this.contactName == '' || this.contactPhone == null || this.contactPhone == '' || this.contactEmail == null || this.contactEmail == '' ){
          // this.editContact = true
          this.cambioCuenta = false
          this.noExisteCuenta = false
          this.actuCuenta = true
        }
      if(data[0].AccountId === null || data[0].AccountId === undefined || data[0].AccountId === '') {
        this.idCuenta = data[0].AccountId
        console.log('AccountID', this.idCuenta);

      }
      this.parentAccountSelectedRecord =  data[0].AccountId;
      this.contactAccountId = data[0].Account?.PersonContactId;
      this.accountUrl = `/lightning/r/${data[0].AccountId}/view`
      console.log(this.accountUrl);
      this.nombreCuenta = data[0]?.Account?.Name || null;
      this.correoElectronico = data[0]?.Correo__c || null;
      this.telefono = data[0]?.Account?.Phone || null;
      this.nombreFacturacion = data[0]?.Cuenta_de_Facturacion__r?.Name || null;

      if (this.nombreFacturacion == null) {
        if (data && data.length > 0 && data[0]?.Account) {
            this.parentAccountSelectedRecordInvoice = data[0].AccountId;
    
            cambiarFacturacion({
                recordId: this.recordId,
                accId: this.parentAccountSelectedRecordInvoice
            })
            .then(result => {
                console.log(this.parentAccountSelectedRecordInvoice);
                console.log('Record updated successfully, new value: ' + result);
    
                // Handle success              
                this.showSpinner = false
                window.location.reload();
            })
            .catch(error => {
                // Handle error
                this.showSpinner = false;
                console.error('Error updating record', error);
            });
        } else {
            console.error('No account data found or data[0]?.Account is null');
        }
    }
    

      this.correoElectronicoEmpresarial = data[0]?.CorreoElectronicoEmpresarial__c;
      if(this.correoElectronico == null &&this.correoElectronicoEmpresarial != null ){
        this.correoElectronico = this.correoElectronicoEmpresarial;
      }
      this.correoFacturacion = data[0]?.Cuenta_de_Facturacion__r?.Invoice_Email__c || null;
      this.telefonoFacturacion = data[0]?.Cuenta_de_Facturacion__r?.Invoice_Phone__c || null;

      // if(this.correoFacturacion == null && this.telefonoFacturacion == null ){
      //   updateFacturacion({ recordId: this.recordId,correoFact: this.correoElectronico ,phoneFact: this.telefono })
      //   .then(result => {            
      //     console.log('Record updated successfully, new value: ' + result);
          
      //     this.showSpinner = true
      //     if(result){
      //       console.log(result);           
      //       window.location.reload();
      //     }
      //   })
      //   .catch(error => {
      //       // handle error
            
      //       console.error('Error updating record facturacion', error);
      //       this.showSpinner = false
      //   });
      // }

      if (this.correoFacturacion == null && this.telefonoFacturacion == null) {
        // Validar si la cuenta principal tiene datos
        if (this.correoElectronico == null || this.telefono == null) {
          LightningAlert.open({
            message:
              "La cuenta principal no tiene correo y/o teléfono completos. Por favor actualice primero los datos de la cuenta.",
            theme: "error",
            label: "Error!",
          });
          this.showSpinner = false;
        } else {
          updateFacturacion({
            recordId: this.recordId,
            correoFact: this.correoElectronico,
            phoneFact: this.telefono,
          })
            .then((result) => {
              console.log("Record updated successfully, new value: " + result);
              this.showSpinner = true;
              if (result) {
                console.log(result);
                window.location.reload();
              }
            })
            .catch((error) => {
              console.error("Error updating record facturacion", error);
              this.showSpinner = false;
            });
        }
      }

      if(this.telefonoFacturacion == null && this.correoFacturacion == null ){
        // this.editInvoiceData = true;
        this.cambioCuenta = true;
        this.nextButton = true
      }else if(this.telefonoFacturacion == null || this.correoFacturacion == null ){
        // this.editInvoiceData = true;
        this.actuCuenta = true;
      }
      this.activeCreditNote = data[0]?.Nota_de_cr_dito_activa__c || null;
      this.isLocked = data[0]?.isLocked__c || null;
      this.nivelApDescArt = data[0]?.Nivel_de_aprobaci_n_descuento_para_art_c__c || null;
      this.nivelApDescMo = data[0]?.Nivel_de_aprobaci_n_descuento_para_MO__c || null;
      this.estadoApDescMo = data[0]?.Estado_de_aprobaci_n_descuento_MO__c || null;
      this.asset = data[0]?.Asset?.Name || null;
      this.kmOrdenTrabajo = data[0]?.Kilometros__c || null;
      this.realizarEncuesta = data[0]?.Realizar_encuesta__c || null;
      this.catRespuestaEncuesta = data[0]?.BMW_CategorizacionDeRespuestaEncuesta__c || null;
      this.vigenciaPresupuesto = data[0]?.Vigencia_del_presupuesto__c || null;
      this.origen = data[0]?.Origen__c || null;
      this.estadoWO = data[0]?.Etapa_de_flujo_de_trabajo__c || null;
      this.tipoGasto = data[0]?.tipoDeGasto__c || null;
      this.priceBook = data[0]?.Pricebook2Id || null;
      this.actividadComercial = data[0]?.ActividadComercial__c || null;
      this.aseguradora = data[0]?.BMW_Aseguradora__c || null;
      this.centroCosto = data[0]?.BMW_CentroDeCosto__c || null;
      this.comentVisibles = data[0]?.Comentario_CxC__c || null;
      this.IdAsset = data[0]?.AssetId || null;
      this.assetUrl = `/lightning/r/${data[0].AssetId}/view` || null;
      this.placa = data[0]?.Asset?.Name || null;

      this.disabledButons = this.estadoWO == 'Orden Cerrada' || this.estadoWO == 'Orden Facturada' || this.estadoWO == 'Orden Rechazada'
      console.log('Desactivar botones: ', this.disabledButons);
      
    } else if(error) {
      console.log('Error de data', error);
    }
  }

  handleEditInvoice() {
    this.editInvoiceData = !this.editInvoiceData
    // if(this.nombreFacturacion == null || this.correoFacturacion == null || this.telefonoFacturacion == null){
    //   LightningAlert.open({
    //     message: "Por favor complete los datos de facturación.",
    //     theme: "error",
    //     label: "Error!",
    //   });
    // }else{
    //   this.editInvoiceData = !this.editInvoiceData
    // }
    
  }

  setCorreoFact(event){
    this.correoFacturacion = event.detail.value;
  }
  setTelefonoFac(event){
    this.telefonoFacturacion = event.detail.value;
  }

  handleChangeAccuntOwner() {
    this.editAccountOwner = !this.editAccountOwner

    this.cambioCuenta = false
    this.noExisteCuenta = false
    this.cuentaEmpresarial = false
    this.nextButton = false

    this.stepTwo = false

    this.actuCuenta = true
  }

  handleEditContact() {
    this.editContact = !this.editContact
    this.cambioCuenta = false
    this.noExisteCuenta = false
    this.actuCuenta = true
  }
  cambiarNombreCuenta(event){
    this.nombreCuenta = event.detail.value;
  }
  cambiarApellidoCuenta(event){
    this.apellido = event.detail.value;
  }
  cambiarIdentificacionCuenta(event){
    this.identificacion = event.detail.value;
  }

  cambiarTelefonoCuenta(event){
    this.telefono = event.detail.value;
  }

  cambiarCorreoCuenta(event){
    this.correoElectronico = event.detail.value;
  }
  
  cambiarCedula(event){
    this.cedula = event.detail.value;
  }

  accountChange() {
    this.cambioCuenta = !this.cambioCuenta
    this.nextButton = !this.nextButton
    this.actuCuenta = false
  }

  accountUpdate() {

    if(this.nombreFacturacion == null ||this.nombreFacturacion == ''){
      LightningAlert.open({
        message: "No puede actualizar los datos sin una cuenta seleccionada.",
        theme: "error",
        label: "Error!",
      });
    }else{
      this.actuCuenta = !this.actuCuenta
      this.noExisteCuenta = false
      this.nextButton = false
      this.cambioCuenta = false
    }
    
  }

  notAccountExists() {
    this.noExisteCuenta = !this.noExisteCuenta
    this.nextButton = !this.nextButton
  }

  empAccountSelect() {
    this.cuentaEmpresarial = !this.cuentaEmpresarial
  }

  handleBackStepTwo() {
    this.stepTwo = false
    this.nextButton = false
    this.noExisteCuenta = false
  }

  handleStepTwo() {
    
    this.showSpinner = true
      var obtenerCedula = this.cedulaBuscada;
      if(obtenerCedula != null && obtenerCedula != '' && obtenerCedula != undefined  ){
        console.log('cedula a buscar: ' + obtenerCedula);

        getCedula({ cedula: obtenerCedula})
        .then(result => {
          // handle success, maybe show a success message              
          console.log('cedula encontrada: ' + result);        
          if(result){
            var splitArray = result[0].split(';');
            this.nombreCuenta = splitArray[0];
            this.apellido = splitArray[1];
            this.cedula = this.cedulaBuscada;
            this.telefono = splitArray[4];
            this.fechaNacimiento = splitArray[6];
            this.correoElectronico = splitArray[3];
            this.stepTwo = true
            this.showSpinner = false

            this.noExisteCuenta = false;
          }
        })
        .catch(error => {
            // handle error
            this.showSpinner = false
            console.error('Error buscando cedula ', error);
        });
      }else{
        this.showSpinner = false
        LightningAlert.open({
          message: "Por favor llene todos los campos.",
          theme: "error",
          label: "Error!",
        });
      }
      
    
    this.cambioCuenta = false
    this.nextButton = false

  }

  handleValueSelectedOnAccountInvoice(event){
    if(event.detail.id != undefined){
      this.parentAccountSelectedRecordInvoice = event.detail.id;
    }
  }


  accountMismo() {
    this.actuCuenta = !this.actuCuenta;
    this.actuMismo = !this.actuMismo;

  }

  actualizarContactoMismo(){
    if(this.parentContactSelectedRecord != null || this.parentContactSelectedRecord != undefined){
      updateContact({
        recordId: this.recordId,
        contactId: this.parentContactSelectedRecord,
      }).then((result) => {
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
            // Esta es la redireccion problematica
            window.location.reload();
          }
        })
        .catch((error) => {
          // handle error
  
          console.error("Error updating record", error);
          this.showSpinner = false;
        });
      
    }else{
      LightningAlert.open({
        message:
          "La cuenta no tiene un contacto o es una cuenta empresarial.",
        theme: "error",
        label: "Error!",
      });
    }
    
  }

  handleValueSelectedOnAccount(event) {

    if(event.detail.id != undefined){
      this.parentAccountSelectedRecord = event.detail.id;
    }
  }

  actualizarCuenta(){
    if (this.isValidPhoneNumber(this.telefono) && this.validateEmail(this.correoElectronico)) {
      this.showSpinner = true
      console.log('this.stepTwo');
      console.log(this.stepTwo);
      if(this.stepTwo){
        console.log('entro no existe cuenta');
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
        }else{
          console.log('entro no es cuenta empresarial');
          console.log(this.cuentaEmpresarial);
          createAccount({ nombreCuenta:this.nombreCuenta,apellido:this.apellido,cedula:this.cedulaBuscada,telefono:this.telefono,fechaNacimiento:this.fechaNacimiento,correoElectronico:this.correoElectronico,nombreEncargado:this.nombreEncargado,telefonoEncargado:this.telefonoEncargado,esEmpresarial:this.cuentaEmpresarial})
          .then(result => {        
            console.log('cuenta creada correctamente: ' + result.Id);
            this.parentAccountSelectedRecordInvoice = result.Id;
            cambiarFacturacion({ recordId: this.recordId, accId : this.parentAccountSelectedRecordInvoice })
              .then(result => {

                console.log(this.parentAccountSelectedRecordInvoice);
                // handle success, maybe show a success message              
                console.log('Record updated successfully, new value: ' + result);
                this.showSpinner = false
                window.location.reload();
                
              })
              .catch(error => {
                  // handle error
                  this.showSpinner = false
                  console.error('Error updating record', error);
              });
            })
          .catch(error => {
              // handle error
              this.showSpinner = false;
              console.error('Error creando record Cuenta', error);
              LightningAlert.open({
                message: "Error: " + error.body.pageErrors[0].message,
                theme: "error",
                label: "Error!",
              });
              
          });
        }
      }
    } else {
      LightningAlert.open({
        message: "Número de teléfono no válido. Debe empezar por +506 y tener una longitud total de 10 dígitos." ,
        theme: "error",
        label: "Error!",
      });
        this.telefonoError = 'Número de teléfono no válido. Debe empezar por +506 y tener una longitud total de 11 dígitos.';
    }
    
  }

  isValidPhoneNumber(phoneNumber) {
    const phoneNumberPattern = /^\+506\d{8}$/;
    return phoneNumberPattern.test(phoneNumber);
  }

  setCedulaBuscar(event) {
    this.cedulaBuscada = event.detail.value;
  }
  validateEmail(email) {
    const emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    return emailPattern.test(email);
  }

  handleValueSelectedOnContacto(event) {
    console.log(event.detail.id);
    if(event.detail.id != undefined){
      this.parentContactSelectedRecord = event.detail.id;
    }
  }
  setNombreContacto(event){
    this.contactName = event.detail.value;
  }

  setCedulaContacto(event) {
    this.identificacionContacto = event.detail.value;
  }

  setApellidoContacto(event){
    this.apellidoContacto = event.detail.value;
  }
  setTelefonoContacto(event){
    this.contactPhone = event.detail.value;
  }
  setCorreoContacto(event){
    this.contactEmail = event.detail.value;
  }


  actualizarContacto(){
    this.showSpinner = true
      if(this.actuCuenta && this.noExisteCuenta != true){
        //validacion de telefono
        if(this.isValidPhoneNumber(this.contactPhone) && this.validateEmail(this.contactEmail)){
          console.log('Entre actualizar COntacto data');
          updateContactData({contactId: this.parentContactSelectedRecord,nombreC: this.contactName,apellidoC:this.apellidoContacto,phoneC: this.contactPhone, emailC: this.contactEmail, cedulaCont: this.identificacionContacto})
          .then(result => {
            console.log(this.assetPlaca);
            console.log(this.cocheVin);
            console.log(this.parentAccountSelectedRecord);      
            console.log('Record updated successfully, new value: ' + result);
            this.showCrtContactModal = false
            this.showSpinner = false
            this.actuCuenta = false
            if(result== undefined || result == ''){
              this.showSpinner = false
              LightningAlert.open({
                message: "Ocurrio un problema al actualizar el contacto.",
                theme: "error",
                label: "Error!",
              });
              
          //     this.nombreCuenta = result[0].Name;
          //     this.telefono = result[0].Phone;
          //     this.correoElectronico =  result[0].CorreoElectronicoEmpresarial__c + ' ' +result[0].PersonEmail;
          //     this.cedula = result[0].codigoSoftland__c;
            }else{
              this.showSpinner = false
                this.editAccountOwner = false;          
                this.cambioCuenta = false
                this.noExisteCuenta = false
                this.cuentaEmpresarial = false
                this.showCrtContactModal = false;  
                this.editContact = false;
                this.contactName = result[0].FirstName
                this.apellidoContacto = result[0].LastName
                this.contactPhone = result[0].Phone
                this.contactEmail = result[0].Email 
                if(result[0].Cedula__c != null || result[0].Cedula__c != undefined) {
                  this.identificacionContacto = result[0].Cedula__c
                }
                window.location.reload();
            }
            this.showSpinner = false
  
          })
          .catch(error => {
              // handle error
              LightningAlert.open({
                message: "Ocurrio un problema al actualizar el contacto.",
                theme: "error",
                label: "Error!",
              });
              console.error('Error updating record', error);
              this.showSpinner = false
          });
        } else {
          LightningAlert.open({
            message: "Número de teléfono no válido. Debe empezar por +506 y tener una longitud total de 11 dígitos." ,
            theme: "error",
            label: "Error!",
          });
          this.showSpinner = false
            this.telefonoError = 'Número de teléfono no válido. Debe empezar por +506 y tener una longitud total de 11 dígitos.';
        }
        
      }else{
        if(this.noExisteCuenta){
          console.log('entro no existe contacto');
          if(this.contactoPrincipal){
            console.log('es contacto principal');
          }
          if(this.isValidPhoneNumber(this.contactPhone) && this.validateEmail(this.contactEmail)){
            createContact({recordId: this.recordId,cuenta: this.parentAccountSelectedRecord,nombreContacto: this.contactName,apellidoContacto:this.apellidoContacto,telefonoContacto: this.contactPhone, correoContacto: this.contactEmail })
          .then(result => {
            this.cambioCuenta = false

            console.log(this.assetPlaca);
            console.log(this.cocheVin);
            console.log(this.parentAccountSelectedRecord);      
            console.log('Record updated successfully, new value: ' + result);
            if(result){
              
              this.showSpinner = false
              this.editAccountOwner = false;  
              this.showCrtContactModal = false;        
              this.cambioCuenta = false
              this.noExisteCuenta = false
              this.cuentaEmpresarial = false
              this.editContact = false;
              window.location.reload();
          //     this.nombreCuenta = result[0].Name;
          //     this.telefono = result[0].Phone;
          //     this.correoElectronico =  result[0].CorreoElectronicoEmpresarial__c + ' ' +result[0].PersonEmail;
          //     this.cedula = result[0].codigoSoftland__c;
            }
          })
          .catch(error => {
            this.showSpinner = false
              // handle error
              LightningAlert.open({
                message: "Error al crear.",
                theme: "error",
                label: "Error!",
              });
              this.cambioCuenta = false
              this.showSpinner = false
              console.error('Error updating record', error);
          });
          }else {
            LightningAlert.open({
              message: "Número de teléfono no válido. Debe empezar por +506 y tener una longitud total de 11 dígitos." ,
              theme: "error",
              label: "Error!",
            });
            this.showSpinner = false
              this.telefonoError = 'Número de teléfono no válido. Debe empezar por +506 y tener una longitud total de 11 dígitos.';
          }
          
        
      }else{
        //validacion de telefono

        updateContactOtro({ recordId: this.recordId,contactId: this.parentContactSelectedRecord })
          .then(result => {
            console.log(this.assetPlaca);
            console.log(this.cocheVin);
            console.log(this.parentContactSelectedRecord);      
            console.log('Record updated successfully, new value: ' + result);
            this.showCrtContactModal = false
            this.showSpinner = false
            if(result){
              console.log(result);
              this.editAccountOwner = false;          
              this.cambioCuenta = false
              this.noExisteCuenta = false
              this.cuentaEmpresarial = false
              this.editContact = false;
              this.contactName = result[0].Name
              this.contactPhone = result[0].Phone
              this.contactEmail = result[0].Email 
              window.location.reload();
          //     this.nombreCuenta = result[0].Name;
          //     this.telefono = result[0].Phone;
          //     this.correoElectronico =  result[0].CorreoElectronicoEmpresarial__c + ' ' +result[0].PersonEmail;
          //     this.cedula = result[0].codigoSoftland__c;
            }
          })
          .catch(error => {
              // handle error
              console.error('Error updating record', error);
              this.showSpinner = false
          });
        
       
      }

    }
   
  }

  cambiarFacturacion(){
    if(this.parentAccountSelectedRecordInvoice != null){
      cambiarFacturacion({ recordId: this.recordId, accId : this.parentAccountSelectedRecordInvoice })
      .then(result => {            
        console.log('Record updated successfully, new value: ' + result);
        
        this.showSpinner = true
        if(result){
          console.log(result);           
          window.location.reload();
      //     this.nombreCuenta = result[0].Name;
      //     this.telefono = result[0].Phone;
      //     this.correoElectronico =  result[0].CorreoElectronicoEmpresarial__c + ' ' +result[0].PersonEmail;
      //     this.cedula = result[0].codigoSoftland__c;
        }
      })
      .catch(error => {
          // handle error
          
          console.error('Error updating record facturacion', error);
          this.showSpinner = false
      });
    } else {
      LightningAlert.open({
        message: "Por favor seleccione una cuenta." ,
        theme: "error",
        label: "Error!",
      });      
    }
  }

  actualizarFacturacion(){
    console.log('===================actualizarFact==================');
    console.log(this.recordId);
    if(this.isValidPhoneNumber(this.telefonoFacturacion)  && this.validateEmail(this.correoElectronico) ){
      updateFacturacion({ recordId: this.recordId,correoFact: this.correoFacturacion ,phoneFact: this.telefonoFacturacion })
      .then(result => {            
        console.log('Record updated successfully, new value: ' + result);
        
        this.showSpinner = true
        if(result){
          console.log(result);           
          window.location.reload();
      //     this.nombreCuenta = result[0].Name;
      //     this.telefono = result[0].Phone;
      //     this.correoElectronico =  result[0].CorreoElectronicoEmpresarial__c + ' ' +result[0].PersonEmail;
      //     this.cedula = result[0].codigoSoftland__c;
        }
      })
      .catch(error => {
          // handle error
          
          console.error('Error updating record facturacion', error);
          this.showSpinner = false
      });
    } else {
      LightningAlert.open({
        message: "Número de teléfono no válido. Debe empezar por +506 y tener una longitud total de 11 dígitos." ,
        theme: "error",
        label: "Error!",
      });
      this.showSpinner = false
        this.telefonoError = 'Número de teléfono no válido. Debe empezar por +506 y tener una longitud total de 11 dígitos.';
    }
    
  }
}