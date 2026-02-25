import { LightningElement, api, track } from 'lwc';
import {loadStyle} from 'lightning/platformResourceLoader';
import screenActionCss from '@salesforce/resourceUrl/ScreenQuickActionLwc' 
import searchProducts from "@salesforce/apex/QuoliGridController.searchProducts";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLS = [
    { label: "Código", fieldName: "ProductCode", type: "text" },
    { label: "Producto", fieldName: "Name", type: "text" },
    { label: "Precio", fieldName: "precio", type: "currency", typeAttributes: { maximumFractionDigits: 2, currencyCode: { fieldName: "currencyCode" }}},
    { label: "Tipo", fieldName: "productType", type: "text" }
  ];
  
const originalCOLS = [...COLS];
export default class QuoliGridAddProducts extends LightningElement {
    @api recordId;
    @track cols = COLS;
    @api workOrderList = [];
    @api idList = [];
    productIds = [];
    quantityselected = 0;
    visibleFlag = false;
    @track selectedRows = [];
    productList = [];
    productListResponse = [];
    error;
    showSelectedProductsFlag = false;
    refreshTable = true;
    bodegasCols = new Set();

    connectedCallback(){
        loadStyle(this, screenActionCss);
    }

    searchProductAction() {
        var searchinput = this.template.querySelector("lightning-input").value; //event.target.value
        this.refreshTable = false;
        searchProducts({
          queryValue: searchinput,
          quoteId: this.recordId
        })
          .then((result) => {
            console.log(JSON.stringify(result));
            //this.bodegasCols.clear();
            this.productListResponse = result;
            this.error = undefined;
            this.addBodegaColumns(this.productListResponse);
          })
          .catch((error) => {
            this.error = error;
            this.productListResponse = undefined;
          });
          /*.finally(() => {
            if (this.workOrderList.length != 0) {
              setTimeout(
                () =>
                  (this.selectedRows = this.workOrderList.map(
                    (record) => record.ID
                  ))
              );
            }
          });*/
    }
    selectProducts() {
        var selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
        if (selectedRecords) {
          selectedRecords.forEach((currentItem) => {
            //if (this.validateBodegaPrincipal(currentItem)) {
              if (this.idList.indexOf(currentItem.ID) === -1) {
                this.idList.push(currentItem.ID);
                this.selectedRows.push(currentItem.ID);
                this.productIds.push(currentItem.productId);
                this.workOrderList.push(currentItem);
              }
           // } else {
             // this.removeItemByIndex(this.idList.indexOf(currentItem.ID));
              //this.setMessageShow('Error', 'No puede seleccionar productos sin disponibilidad en la bodega principal.', 'error');
            //}
          });
        } else {
          this.removeItemByIndex(selectedRecords.length);
        }
        this.setQuantitySelected();
      }
    
      removeItemByIndex(index) {
        if (index >= 0) {
          // Remove the item from the arrays
          this.idList.splice(index, 1);
          this.productIds.splice(index, 1);
          this.workOrderList.splice(index, 1);
        }
        this.selectedRows = this.workOrderList.map((record) => record.ID);
      }
    
      get options() {
        return [
          {
            label: "Búsqueda solo en Bodega Correspondiente",
            value: "ServiceTerritory"
          },
          { label: "Búsqueda SOLAMENTE de Mano de Obra", value: "Mano de Obra" } //Busqueda de Mano de Obra
        ];
      }
    
      handleNavigate() {
        if (this.visibleFlag) {
          this.visibleFlag = false;
        } else {
          this.visibleFlag = true;
        }
        this.selectedRows = this.idList;
      }
    
      handleDeleteLine(event) {
        this.workOrderList = event.detail.deletedRecords;
        this.idList = event.detail.deletedIds;
        this.quantityselected = this.idList.length;
      }
    
      showSelectedProducts() {
        this.productList = this.workOrderList.map((record) => record);
        this.selectedRows = this.workOrderList.map((record) => record.ID);
        this.showSelectedProductsFlag = true;
      }
    
      closeSelectedProducts() {
        this.showSelectedProductsFlag = false;
      }
    
      deselectProducts(event) {
        this.workOrderList = event.detail.selectedRows.map((record) => record);
        this.selectedRows = this.workOrderList.map((record) => record.ID);
        this.idList = this.selectedRows;
        console.log(this.workOrderList.length);
        this.setQuantitySelected();
      }
    
      setQuantitySelected() {
        this.quantityselected = this.workOrderList.length;
      }
    
      handleClose(event) {
        window.location = window.location.href;
        return false;
      }
    
      rerenderTable() {
        this.refreshTable = true;
      }
    
      addBodegaColumns(data) {
        // Loop through the data to collect unique bodega names and dynamically add columns
        data.forEach((item) => {
          if (item.bodegas) {
            item.bodegas.forEach((bodega) => {
              item[bodega.name] = bodega.cantidadDisponible;
              console.log(bodega.name);
              const fieldName = bodega.name; 
              const columnName = bodega.isPrincipal
                ? fieldName + "(Principal)"
                : fieldName;
              const column = {
                label: columnName,
                fieldName: fieldName,
                type: "text"
              };
              this.addColumnAtIndex(bodega.Id, column);
            });
          }
        });
      }
    
      validateBodegaPrincipal(data) {
        if (data.productType === "Materiales") {
            const principalBodega = data.bodegas.find(bodega => bodega.isPrincipal && bodega.cantidadDisponible > 0);
            const hasApartados = data.bodegas.find(bodega => bodega.name.toLowerCase().includes("apartados") && bodega.cantidadDisponible > 0);
            if (!principalBodega && hasApartados) {
                data.bodegaID = hasApartados.Id;
                data.Bodega = hasApartados.name;
                data.cantidadDisponible = hasApartados.cantidadDisponible;
                data.changedToApartados = true;
            } else{
              data.changedToApartados = false;
            }
            return !!principalBodega || !!hasApartados;
        }
        return true;
      }
    
      addColumnAtIndex(bodegaId, column) {
        const index = 2 + this.bodegasCols.size;
        if (index >= 0 && index <= this.cols.length && !this.bodegasCols.has(bodegaId)) {
          this.cols.splice(index, 0, column);
          this.bodegasCols.add(bodegaId);
        }
        this.orderColumns();
        this.rerenderTable();
      }
    
      orderColumns() {
        const principalColumnIndex = this.cols.findIndex(col => col.label.endsWith("(Principal)"));
        if (principalColumnIndex !== -1) {
          // Remove the existing principal column from its current position
          const removedColumn = this.cols.splice(principalColumnIndex, 1)[0];
          // Insert the removed principal column at the second position
          this.cols.splice(2, 0, removedColumn);
        }
      }
    
      resetCOLS() {
        if (this.cols.length > 4) {
          this.cols = [...originalCOLS];
        }
      }
    
      setMessageShow(title, message, variant) {
        const mode = this.variant === "error" || this.variant === "warning" ? "sticky" : "dismissible";
        const evt = new ShowToastEvent({
          title: title,
          message: message,
          variant: variant,
          mode: mode
        });
        this.dispatchEvent(evt);
      }

      //ELiminar deprecated
      setRealVailability(){
        var error=false;
        var productNotAvailable = false;
        var errorMsg=' ';
        this.showRealAvailability=true;
        this.modifiedList.forEach(currentItem => {
            if(currentItem.productType!=undefined){
                if((!currentItem.productType.toLowerCase().includes('mano de obra') && !currentItem.productType.toLowerCase().includes('subcontrato') ) && !currentItem.isClosed){
                    if(!currentItem.validated){             
                        this.template.querySelector('[data-id="'+currentItem.ID+'"]').className='warningClass';
                    }else if(currentItem.available){
                        this.template.querySelector('[data-id="'+currentItem.ID+'"]').className='greenClass';
                    }else{
                        productNotAvailable = true;
                        this.template.querySelector('[data-id="'+currentItem.ID+'"]').className='redClass';
                        this.autoCheckToDelete(currentItem.ID, currentItem.wolId);
                        currentItem.isChecked = this.workOrderSetting.only_available_spare_parts__c;
                        //this.template.querySelector('[data-id="'+currentItem.ID+'"]').className='redClass';
                        if(this.specialOrderIds.indexOf(currentItem.ID)===-1){
                            this.specialOrderIds.push(currentItem.ID);
                            this.specialOrders.push(currentItem);
                            this.handleSpecialOrderLength();
                        }
                    }
                }
            }else{
                error=true;
                errorMsg=errorMsg+' '+currentItem.ProductCode+',';
            } 
        });
        if(productNotAvailable){
            this.showReserveButton = this.workOrderSetting.only_available_spare_parts__c;
        } else{
            this.showReserveButton = false;
        }
        if(!error){
            if(this.specialOrderQuantity>0){
                this.setMessageShow('ADVERTENCIA','Los artículos no tienen existencias en la localización seleccionada.','warning');
            }
        }else{
            this.setMessageShow('ERROR DE CONFIGURACIÓN','Los siguientes articulos'+errorMsg+' no tienen definido el Tipo de Producto','error');
        }
    }
}