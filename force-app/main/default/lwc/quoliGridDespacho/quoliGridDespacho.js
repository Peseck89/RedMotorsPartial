import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import getQuolis from '@salesforce/apex/QuoliGridController.getQuolis';
import deleteQuolis from '@salesforce/apex/QuoliGridController.deleteQuolis';
import saveQuantities from '@salesforce/apex/QuoliGridController.saveQuantities';
import requestDespacho from '@salesforce/apex/QuoliGridController.requestDespacho';
import requestApartar from '@salesforce/apex/QuoliGridController.requestApartar';
import consultarDisponibilidad from '@salesforce/apex/QuoliGridController.consultarDisponibilidad';
import requestDevolucion from '@salesforce/apex/QuoliGridController.requestDevolucion';
import sendPDF from '@salesforce/apex/QuoliGridController.sendPDF';
import lwcDatatableStyle from '@salesforce/resourceUrl/despachoLWCdataTable';
import screenActionCss from '@salesforce/resourceUrl/ScreenQuickActionLwc' 
import {loadStyle} from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from "lightning/uiRecordApi";
import Id from '@salesforce/user/Id';
import CanDeleteWolis__c from '@salesforce/schema/User.CanDeleteWolis__c';
import attachPDFinWO from '@salesforce/apex/savePDFfile.attachPDFinWO';
import QuoteNumber from '@salesforce/schema/Quote.QuoteNumber';

const COLS = [
    { label: "Código", fieldName: "ProductCode", type: "text" , cellAttributes: { class: {fieldName: 'format' }}},
    { label: "Producto", fieldName: "Name", type: "text" , cellAttributes: { class: {fieldName: 'format' }}},
    //{ label: "Precio", fieldName: "precio", type: "currency", typeAttributes: { maximumFractionDigits: 2, currencyCode: { fieldName: "currencyCode" }}},
    //{ label: "Tipo", fieldName: "productType", type: "text" }
    //{ label: "Estado Solicitud de Compra", fieldName: "estadoSolicitudCompra"},
    { label: "Bodega", fieldName: "Bodega", type: "text" , cellAttributes: { class: {fieldName: 'format' }}},
    { label: "Cantidad", fieldName: "cantidad", editable: {fieldName: 'isOpen' }, type: "number" , cellAttributes: { class: {fieldName: 'format' }}},
    
    { label: "Estado", fieldName: "estadoReserva", type: "text", cellAttributes: { class: {fieldName: 'format' }}},
    { label: "Estado Entrega", fieldName: "estadoEntrega", type: "text", cellAttributes: { class: {fieldName: 'format' }}},
    { label: "Estado Softland", fieldName: "estadoSoftland", type: "text", cellAttributes: { class: {fieldName: 'format' }}}

  ];
  const originalCOLS = [...COLS];

  const scompracols = [
    { label: "ID Solicitud de Compra", fieldName: "solicitudCompraID", type: "text" },
    { label: "Código", fieldName: "ProductCode", type: "text"},
    { label: "Producto", fieldName: "Name", type: "text" },
    //{ label: "Precio", fieldName: "precio", type: "currency", typeAttributes: { maximumFractionDigits: 2, currencyCode: { fieldName: "currencyCode" }}},
    //{ label: "Tipo", fieldName: "productType", type: "text" }
    { label: "Bodega", fieldName: "Bodega", type: "text" },
    { label: "Cantidad", fieldName: "cantidad", type: "number" },
    { label: "Cantidad Solicitud de Compra", fieldName: "cantidadSC", type: "number" },
    { label: "Estado Solicitud de Compra", fieldName: "estadoSolicitudCompra"},
    //{ label: "Estado Reserva", fieldName: "estadoReserva", type: "text"},
    { label: "Estado Entrega", fieldName: "estadoEntrega", type: "text"},
    { label: "Estado Softland", fieldName: "estadoSoftland", type: "text"}

  ];

export default class QuoliGridDespacho extends NavigationMixin(LightningElement) {
    recordId;
    @track lines = [];
    @track reservadas = [];
    @track pendientes = [];
    @track solicitudCompras = [];

    @track pendientesSelectedRows = [];
    @track reservadasSelectedRows = [];
    @track suggestSolicitudCompra = [];
    notAvailableIds = [];
    quoteNumber;
    pendientesDraftValues = [];
    reservadasDraftValues = [];
    refreshTable = false;
    cols = COLS;
    reservadaCols;
    compraCols = scompracols;
    iframeSrc = "/apex/AlbaranPDFGroupTcQuote?Id=";
    emailPDF;
    userId = Id;
  
    //Toogle visivility
    showDelete = false;
    showDevolution = false;
    showPendientesTable = true;
    isLoaded = false;
    needValidation = true;
    showPDF = false;
    showPendienteButtons = false;
    showReservaButtons = false;
    showSolicitudCompra = false;
    showSCbutton = false;
  
    //
  
    /*Wire functions*/
    @wire(getRecord, {
      recordId: Id,
      fields: [CanDeleteWolis__c]
    })
    userDetails({ error, data }) {
      if (data) {
        this.CanDeleteWolis__c = data.fields.CanDeleteWolis__c.value;
      } else if (error) {
        this.error = error;
      }
    }
  
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    @wire(getRecord, { recordId: "$recordId", fields: [QuoteNumber] })
    QuoteNumber({ error, data }) {
      if (data) {
        this.quoteNumber = data.fields.QuoteNumber.value;
      } else if (error) {
        console.log(error);
        this.error = error;
      }
    }

    connectedCallback() {
        this.handleGetQuolis();
        Promise.all([
            loadStyle(this, lwcDatatableStyle),
            loadStyle(this, screenActionCss)
        ])
        .then(() => {
            console.log("Loaded Successfully despachoLWCdataTable and screenActionCss");
        })
        .catch((error) => {
            console.log(error);
        });
        //this.reservadaCols = this.cols.map(col => ({ ...col, editable: col.fieldName === 'cantidadDevolucion' ? true : false }));
        this.addDevolucionColumn();
        this.iframeSrc = this.iframeSrc + this.recordId;
    }
  
    addDevolucionColumn() {
      const newColumn = {
        label: "Cantidad Devolución",
        fieldName: "cantidadDevolucion",
        editable: { fieldName: "isOpen" },
        type: "number",
        cellAttributes: { class: { fieldName: "format" } }
      };
      const index = COLS.findIndex((column) => column.fieldName === "cantidad");
      this.reservadaCols = [
        ...this.cols.slice(0, index + 1),
        newColumn,
        ...COLS.slice(index + 1)
      ];
    }
    /*
    handleActive() {
      console.log("Hello World");
    }*/
  
    filterByEstadoReserva(data, estadoToFilter) {
      if(estadoToFilter === 'Solicitud de Compra'){
        return data.filter((item) => (item.estadoReserva === 'Pendiente de reserva' && item.estadoSolicitudCompra));
      }
      return data.filter((item) => item.estadoReserva === estadoToFilter && (!item.estadoSolicitudCompra||item.estadoSolicitudCompra === 'Recibido en bodega'));
    }
  
    handleAttachPDF() {
      attachPDFinWO({
          woId: this.recordId,
          fromButton: 'Despacho de repuestos',
          vfNamePage: 'AlbaranPDFGroupTc?id=' + this.recordId,
          save: false,
          enviarEmail: true
      })
      .then(result => {
          this.messagePDF = 'Success';
  
          if (result === 'Email Success') {
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Success',
                      message: 'Se envió el correo electrónico correctamente',
                      variant: 'success'
                  })
              );
          } else if (result === 'Email Error') {
              console.error('Failed with result: ' + result);
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Error',
                      message: 'No se pudo enviar el correo electrónico. Favor de revisar el territorio de servicio.',
                      variant: 'error'
                  })
              );
          }
      })
      .catch(error => {
          console.error('Failed with error: ' + error);
      });
  }
  
    handleRowPendientesSelection(event) {
      this.pendientesSelectedRows = [];
      event.detail.selectedRows.forEach((selectedRow) => {
        if (selectedRow.isOpen) {
          this.pendientesSelectedRows.push(selectedRow.wolId);
        }
      });
  
      this.showDelete = this.pendientesSelectedRows.length > 0;
    }
  
    handleRowReservadasSelection(event) {
      this.reservadasSelectedRows = [];
      event.detail.selectedRows.forEach((selectedRow) => {
        if (selectedRow.isOpen /*&& !selectedRow.estadoSolicitudCompra*/) {
          console.log(JSON.stringify(selectedRow));
          this.reservadasSelectedRows.push(selectedRow.wolId);
        }
      });
      this.template.querySelector('[data-id="reservada"]').selectedRows =
        this.reservadas
          .filter((item) => this.reservadasSelectedRows.includes(item.wolId))
          .map((item) => item.ID);
      this.showDevolution = this.reservadasSelectedRows.length > 0;
    }
  
    /**Server Calls**/
    handleGetQuolis() {
      this.showPendientesTable = false;
      this.showReservadasTable = false;
      getQuolis({ listTosave: JSON.stringify([]), quoteId: this.recordId })
        .then((result) => {
          this.setFacturadaStyle(result);
          this.lines = JSON.parse(JSON.stringify(result));
          console.log('this.lines1 ',this.lines );
          console.log('this.lines[0] ',this.lines[0]);

          this.emailPDF = this.lines ? this.lines[0].despachoEmail : "";
          result = result.filter(obj => ["Materiales", "Kit"].includes(obj.productType));

          this.pendientes = this.filterByEstadoReserva(
            JSON.parse(JSON.stringify(result)),
            "Pendiente de reserva"
          );

          this.reservadas = this.filterByEstadoReserva(
            JSON.parse(JSON.stringify(result)),
            "Reservado"
          );

          this.solicitudCompras = this.filterByEstadoReserva(
            JSON.parse(JSON.stringify(result)),
            "Solicitud de Compra"
          );

          this.showPendienteButtons = this.pendientes.length > 0;
          this.showReservaButtons = this.reservadas.length > 0;
        })
        .catch((error) => {
          console.error(error);
        })
        .finally(() => {
          this.showPendientesTable = true;
          this.showReservadasTable = true;
        });
    }
  
    handleDeleteQuolis() {
      //if(this.getUserPermissionToDelete()){
        this.isLoaded = true;
        deleteQuolis({ quoteIds: JSON.stringify(this.pendientesSelectedRows) })
          .then((result) => {
            this.setMessageShow(
              "Success",
              "Se han eliminado las líneas correctamente",
              "success"
            );
            this.visualDelete();
          })
          .catch((error) => {
            console.error(error);
          })
          .finally(() => {
            this.isLoaded = false;
          });
      /*}else{
        this.setMessageShow(
          "Warning",
          "No tiene los permisos necesarios para borrar líneas, consulte su administrador",
          "warning"
        );
      }*/
    }
  
    @api async handleSave(event) {
      this.updateObjects(event.detail.draftValues);
      this.isLoaded = true;
      saveQuantities({
        jsonString: JSON.stringify(this.pendientes),
        quoteId: this.recordId
      })
        .then((result) => {
          this.setMessageShow(
            "Success",
            "Se han GUARDADO las Nuevas CANTIDADES correctamente.",
            "success"
          );
          this.isLoaded = false;
          this.pendientesDraftValues = [];
          this.needValidation = true;
        })
        .catch((error) => {
          this.isLoaded = false;
        });
    }
  
    @api async handleSaveReservadas(event) {
      const isDevolucionChanged = event.detail.draftValues.some(
        (obj) => "cantidadDevolucion" in obj
      );
      this.updateObjectsReservada(event.detail.draftValues);
      this.isLoaded = true;
      saveQuantities({
        jsonString: JSON.stringify(this.reservadas),
        quoteId: this.recordId
      })
        .then((result) => {
          this.setMessageShow(
            "Success",
            "Se han GUARDADO las CANTIDADES DE DEVOLUCIÓN correctamente.",
            "success"
          );
          if (isDevolucionChanged) {
            this.setMessageShow(
              "Warning",
              "Se requiere dar click en devolución para completar su solicitud de DEVOLUCIÓN",
              "warning"
            );
          }
          this.isLoaded = false;
          this.reservadasDraftValues = [];
          this.needValidation = true;
        })
        .catch((error) => {
          this.isLoaded = false;
        });
    }
  
    handleConsultarDisponibilidad() {
      this.isLoaded = true;
      this.showPendientesTable = false;
      consultarDisponibilidad({
        jsonString: JSON.stringify(this.pendientes),
        quoteId: this.recordId,
        quoteNumber: this.quoteNumber
      })
        .then((result) => {
          var isError = false;
          this.notAvailableIds = [];
          //console.log(JSON.parse(JSON.stringify(result)));
          result.forEach((ele) => {
            if (!ele.available) {
              ele.format = (!ele.available && ele.existenciasOtrasBodegas === 'false') ? "slds-theme_error" : "";
              ele.format = (!ele.available && ele.existenciasOtrasBodegas === 'true') ? "slds-theme_warning" : ele.format;
              ele.estadoSoftland = ele.otherInventoryText;
              if(ele.format === "slds-theme_error"){
                this.notAvailableIds.push(ele.wolId);
                this.showSCbutton = true;
                this.suggestSolicitudCompra.push(ele);
              }
              isError = true;
            }
          });
          this.setFacturadaStyle(result);
          this.pendientes = JSON.parse(JSON.stringify(result));
          const title = isError ? "Error" : "Success";
          const message = isError
            ? "Verifique las líneas en ROJO"
            : "Cantidades Validadas";
          this.setMessageShow(title, message, title.toLowerCase());
          this.isLoaded = false;
        })
        .catch((error) => {
          console.error(error);
          this.setMessageShow(
            error.body.exceptionType,
            error.body.message,
            "error"
          );
        })
        .finally(() => {
          this.showPendientesTable = true;
          this.isLoaded = false;
          this.needValidation = false;
        });
    }
  
    handleRequestDespacho() {
      this.isLoaded = true;
      requestDespacho({
        quoteNumber: this.quoteNumber,
        notAvailableIds: this.notAvailableIds,
        selectedIDList: this.pendientesSelectedRows
      })
        .then((result) => {
          const messageType = result.includes("validación.")
            ? "error"
            : "success";
          this.setMessageShow(messageType.toUpperCase(), result, messageType);
        })
        .catch((error) => {
          console.error(error);
          this.setMessageShow(
            error.body.exceptionType,
            error.body.message,
            "error"
          );
        })
        .finally(() => {
          this.handleGetQuolis();
          this.isLoaded = false;
        });
    }
  
    handleRequestApartar() {
      this.isLoaded = true;
      requestApartar({
        quoteNumber: this.quoteNumber,
        notAvailableIds: this.notAvailableIds,
        selectedIDList: this.pendientesSelectedRows
      })
        .then((result) => {
          const messageType = result.includes("validación.")
            ? "error"
            : "success";
          this.setMessageShow(messageType.toUpperCase(), result, messageType);
          this.reloadOrder();
        })
        .catch((error) => {
          console.error(error);
          this.setMessageShow(
            error.body.exceptionType,
            error.body.message,
            "error"
          );
        })
        .finally(() => {
          this.handleGetQuolis();
          this.isLoaded = false;
        });
    }
  
    handleRequestDevolution() {
      this.isLoaded = true;
      requestDevolucion({
        quoteNumber: this.quoteNumber,
        devolutionIds: this.reservadasSelectedRows
      })
        .then((result) => {
          const messageType = result.includes("validación.")
            ? "error"
            : "success";
          this.setMessageShow(messageType.toUpperCase(), result, messageType);
          this.reloadOrder();
        })
        .catch((error) => {
          console.error(error);
          this.setMessageShow(
            error.body.exceptionType,
            error.body.message,
            "error"
          );
        })
        /*.finally(() => {
          this.reservadasSelectedRows = [];
          this.showDevolution = false;
          this.handleGetQuolis();
          this.isLoaded = false;
        });*/
    }
  
    handlePrintDespacho() {
      this.showPDF = !this.showPDF;
      console.log('this.emailPDF ',this.emailPDF);
      console.log('this.recordId ',this.recordId);

      sendPDF({ quoteId: this.recordId, email: this.emailPDF })
        .then((result) => {
          const messageType = result.includes("Success") ? "success" : "error";
          this.setMessageShow(
            messageType.toUpperCase(),
            "Se ha enviado el PDF correctamente",
            messageType
          );
        })
        .catch((error) => {
          console.error(error);
          this.setMessageShow(
            error.body.exceptionType,
            error.body.message,
            "error"
          );
        })
        .finally(() => {
          this.reservadasSelectedRows = [];
          this.showDevolution = false;
          this.handleGetQuolis();
          this.isLoaded = false;
        });
      /*this.setMessageShow(
        "Warning",
        "No se ha desarrollado",
        "warning"
      );*/
    }
  
    /* Helper Functions*/
  
    visualDelete() {
      this.showPendientesTable = false;
      const objectArray = JSON.parse(JSON.stringify(this.pendientes));
      const filteredArray = objectArray.filter(
        (obj) => !this.pendientesSelectedRows.includes(obj.wolId)
      );
      this.pendientes = filteredArray;
      this.resetPendientesSelectedList();
      this.showPendientesTable = true;
    }
  
    updateObjects(updateArray) {
      const objectArray = JSON.parse(JSON.stringify(this.pendientes));
      const filteredArray = objectArray.map((obj) => {
        const updateObj = updateArray.find((update) => update.ID === obj.ID);
        if (updateObj) {
          // Merge the properties from the update object into the original object
          return { ...obj, ...updateObj };
        }
        return obj;
      });
  
      this.pendientes = filteredArray;
    }
  
    updateObjectsReservada(updateArray) {
      const objectArray = JSON.parse(JSON.stringify(this.reservadas));
      const filteredArray = objectArray.map((obj) => {
        const updateObj = updateArray.find((update) => update.ID === obj.ID);
        if (updateObj) {
          // Merge the properties from the update object into the original object
          return { ...obj, ...updateObj };
        }
        return obj;
      });
  
      this.reservadas = filteredArray;
    }
  
    resetPendientesSelectedList() {
      this.pendientesSelectedRows = [];
      this.showDelete = false;
    }
  
    setMessageShow(title, message, variant) {
      const mode =
        this.variant === "error" || this.variant === "warning"
          ? "sticky"
          : "dismissible";
      const evt = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
        mode: mode
      });
      this.dispatchEvent(evt);
    }
  
    setFacturadaStyle(result) {
      result.forEach((ele) => {
        ele.isOpen = !ele.isClosed;
        if (ele.isClosed) {
          ele.format = ele.isClosed
            ? "slds-theme_shade slds-theme_alert-texture"
            : ele.format;
        } else if(ele.estadoEntrega.includes("Pendiente devolución nota de crédito")){
            ele.isOpen = false;
            ele.format = "slds-theme_shade slds-theme_alert-texture";
  
        } else {
          ele.format = ele.estadoEntrega.includes("Pendiente de devolución")
            ? "slds-theme_warning slds-theme_alert-texture"
            : ele.format;
        }
        ele.isOpen = ele.estadoSolicitudCompra ? false : ele.isOpen;
      });
    }
  
    getUserPermissionToDelete(){
      return this.CanDeleteWolis__c;
    }
  
    reloadOrder() {
     window.location.reload();
    }

    handleSolicitudCompra(){
      this.showSolicitudCompra = true;
    }

    handleCancelSolicitud(event){
      var message = event.detail.message;
      this.showSolicitudCompra = false;
    }

}