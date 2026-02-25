import { LightningElement, api, track, wire } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import setPublicFileWO from '@salesforce/apex/WoliGridController.setPublicFileWO';
import getDepartamentos from '@salesforce/apex/QuoliGridController.getDepartamentos';
import sendSCWO from '@salesforce/apex/WoliGridController.sendSCWO';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import accountName from '@salesforce/schema/WorkOrder.Account.Name';
import number from '@salesforce/schema/WorkOrder.WorkOrderNumber';

const FIELDS = [accountName, number ];

export default class SolicitudCompraWO extends LightningElement {
    value = 'inProgress';
    @api recordId;
    @api accountId;
    @api rows;

    //Servicio Solicitud Reserva
    priority = '';
    department = '';
    @track solicitudSelectedRows = [];
    @track selectedRowsID = [];
    @track selectedMateriales = [];
    @track anticipo = '';
    isFileUploaded = false;


    cliente;
    pedido;
    @track departamentos;
    @track showSendSCButton = true;
    prioridades =[{ label: 'Maritimo', value: 'Maritimo' },{ label: 'Aereo', value: 'Aereo' },{ label: 'VDR', value: 'VDR' }];
    cols = [
        { label: "Código", fieldName: "ProductCode", type: "text" , cellAttributes: { class: {fieldName: 'format' }}},
        { label: "Producto", fieldName: "Name", type: "text" , cellAttributes: { class: {fieldName: 'format' }}},
        { label: "Cantidad", fieldName: "cantidad", type: "number" , cellAttributes: { class: {fieldName: 'format' }}},
    
    ];

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredAccount({ error, data }) {
        if (data) {
          this.cliente = data.fields.Account.displayValue;
          this.pedido = data.fields.WorkOrderNumber.value;
        } else if (error) {
            console.error('Error loading account', error);
        }
    }

    connectedCallback(){
        let tempRows = JSON.parse(JSON.stringify(this.rows));
        tempRows.forEach((ele) => {
            ele.format = "";
         });
         this.rows = tempRows;
         this.handleGetDepartamentos();
    }


    handleDepartment(event) {
      //console.log(event.detail.value);
      this.department = event.detail.value;
      this.checkRequiredFields();
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent('cancel', {
            detail: {
                message: false
            }
        }));
    }

    get acceptedFormats() {
        return [".png", ".jpg", ".jpeg", ".pdf"];
      }
      
      handleUploadFinished(event) {
          // Get the list of uploaded files
          const uploadedFiles = event.detail.files;
          const contentIds = [];
          let uploadedFileNames = "";
          for (let i = 0; i < uploadedFiles.length; i++) {
            uploadedFileNames += uploadedFiles[i].name;
            contentIds.push(uploadedFiles[i].documentId);
          }
          this.isFileUploaded = true;
          this.handlesetPublicFile(contentIds, uploadedFileNames);
          this.checkRequiredFields();
      }

      handleSelectRows(event) {
        this.selectedMateriales = [];
        this.solicitudSelectedRows = [];
        event.detail.selectedRows.forEach((selectedRow) => {
          if(!this.selectedMateriales.includes(selectedRow.ProductCode)){
            this.selectedMateriales.push(selectedRow.ProductCode);
            this.solicitudSelectedRows.push(selectedRow.wolId);
            //this.selectedRowsID.push(selectedRow.ID);
          }
         var el =this.template.querySelector('[data-id=solicitudTable]');
         this.selectedRowsID = this.getUniqueIDs(el.getSelectedRows());
         //this.removeDuplicates(this.selectedMateriales);
         this.checkRequiredFields();
        });
        console.log('SIZE SOLICITUD : '+ this.solicitudSelectedRows.length);
        /*console.log('Materiales');
        console.log(JSON.stringify(this.selectedMateriales));
        console.log('Lineas seleccionadas');
        //console.log(JSON.stringify(this.template.querySelector('[data-id=solicitudTable]').getSelectedRows()));*/
        console.log('Lineas a solicitud');
        console.log(JSON.stringify(this.solicitudSelectedRows));
      }

      getUniqueIDs(data) {
        const lastOccurrences = {};
        const result = [];
      
        // Iterate over the data array to record the last occurrence index of each ProductCode
        data.forEach((item, index) => {
          lastOccurrences[item.ProductCode] = index;
        });
      
        // Iterate over the data array again, collect IDs if it's not the last occurrence of ProductCode
        data.forEach((item, index) => {
          if (lastOccurrences[item.ProductCode] === index) {
            result.push(item.ID);
          } else{
            this.setMessageShow("Error", "Por solicitud de compra solamente puede enviar una línea por cada código de producto. Si desea aumentar la cantidad consolide las lineas en la pantalla anterior", "error");
          }
        });
      
        return result;
      }

      /**Server Calls**/
    handlesetPublicFile(contentIds, uploadedFileNames) {
        setPublicFileWO({ contentIds: contentIds, workOrderId: this.recordId })
          .then((result) => {
            this.dispatchEvent(
                new ShowToastEvent({
                  title: "Success",
                  message:" Files uploaded Successfully: " + uploadedFileNames,
                  variant: "success",
                })
              );
          })
          .catch((error) => {
            console.error(error);
          })
          .finally(() => {
          });
      }

      handleSendSC() {
        this.showSendSCButton = true;
        sendSCWO({departamento: this.department, prioridad: this.priority, anticipo: this.anticipo, workOrderId:this.recordId, idsToSC: this.solicitudSelectedRows})
          .then((result) => {
            if(result==='00'){
              this.setMessageShow("Success", " Solicitud Enviada Correctamente", "success");
              window.location.reload();
            } else{
              this.showSendSCButton = false;
              this.setMessageShow("Error", "El documento de anticipo NO es válido", "error");
            }
            })
          .catch((error) => {
            console.error(error);
          })
          .finally(() => {
          });
      }

      handleGetDepartamentos() {
        getDepartamentos()
          .then((result) => {
            console.log();
            let deartamentosTemp = JSON.parse(result).map(item => {
              // Destructure the properties codigo and nombre
              const { codigo, nombre } = item;
              
              // Return a new object with renamed properties
              return {
                value: codigo, // Rename 'codigo' to 'value'
                label: nombre  // Rename 'nombre' to 'label'
              };
            });
            this.departamentos = deartamentosTemp;
          })
          .catch((error) => {
            console.error(error);
          })
          .finally(() => {
          });
      }

      handleCheckboxChange(event) {
        const checkboxes = this.template.querySelectorAll('[data-element="priority"]');
        console.log(event.target.name);
        // Iterate over all checkboxes
        var isSomethingChecked = false;
        checkboxes.forEach(checkbox => {
            // Uncheck checkboxes that are not the one triggering the event
            if (checkbox.label !== event.target.name) {
                checkbox.checked = false;
            }
            if(checkbox.checked){
              isSomethingChecked  = checkbox.checked;
            }
        });
        this.priority = isSomethingChecked ? event.target.name: '';
        this.checkRequiredFields();
    }

    handleAnticipoChange(event) {
      this.anticipo = event.detail.value;
      this.checkRequiredFields();
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

  checkRequiredFields(){
    const linesSelected = (this.solicitudSelectedRows.length > 0);
    const departamentoSelected = this.department != '';
    const prioritySelected = this.priority != '';
    const anticipoSelected = (this.anticipo != '') || this.isFileUploaded;
    const validityFields = linesSelected && departamentoSelected && prioritySelected && anticipoSelected;
    this.showSendSCButton = !(validityFields);
    console.log('prioritySelected is validated?   '+prioritySelected);
    console.log('Everything is validated?   '+validityFields);
  }

}