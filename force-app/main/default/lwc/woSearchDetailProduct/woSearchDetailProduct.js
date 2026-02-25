import  { LightningElement, track, api, wire }from 'lwc';
import searchProducts from "@salesforce/apex/WoliGridController.searchProducts";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import empresaFactura from '@salesforce/schema/WorkOrder.empresaFactura__c';
import empresaFactura2 from '@salesforce/schema/Quote.empresaFactura__c';


const COLS = [
    { label: 'Código', fieldName: 'ProductCode', type: 'text' },
    { label: 'Producto', fieldName: 'Name', type: 'text' },
    { label: 'Precio', fieldName: 'precio', type: 'currency',typeAttributes: {  maximumFractionDigits: 2,currencyCode: { fieldName: 'currencyCode' } } },
    //{ label: 'Bodega', fieldName: 'Bodega', type: 'text' },
    //{ label: 'Cantidad disponible', fieldName: 'cantidadDisponible', type: 'text' },
    { label: 'Tipo', fieldName: 'productType', type: 'text' },
];

const originalCOLS = [...COLS];

export default class WoSearchDetailProduct extends LightningElement {
    @api recordId;
    @api showSearchModal;
    @track productList = [];
    @track cols = [...COLS];
    @track showButtonPrice = true;
    @track showButtonLocation = true;
    idList = [];
    productIds = [];
    workOrderList = [];
    //priceBookIdList = [];
    productCodeSelected;
    disablePriceRederence = true;
    disableLocalizaciones = true;

    selectedRows =[];

    //Bodegas Logic
    refreshTable = true;
    bodegasCols = new Set();
    //Render Logic
    showDetailedSearch = true;

    disableButtons = false;
    toogleLabelPricebook = 'Ver Lista de Precios'; 
    toogleLabelLocation = 'Ver Localizaciones'; 

    //wire
     /*renderedCallback() {
        this.refreshTable = false;
        this.resetCOLS();
      }*/

    @wire(getRecord, { recordId: '$recordId', fields: [empresaFactura]}) 
    empresaFacturaWO({error, data}) {
        //console.log(this.recid);
        if (data) {
            this.empresaFactura = data.fields.empresaFactura__c.value;
        } else if (error) {
           // console.log(error);
            this.error = error ;
        }
    }
    @wire(getRecord, { recordId: '$recordId', fields: [empresaFactura2]}) 
    empresaFacturaQO({error, data}) {
        //console.log(this.recid);
        if (data) {
            this.empresaFactura = data.fields.empresaFactura__c.value;
        } else if (error) {
           // console.log(error);
            this.error = error ;
        }
    }

    handleSearchProduct() {
        var pickListValue = '';
        var searchinput = this.template.querySelector("lightning-input").value;
        this.resetCOLS();
        this.bodegasCols = new Set();
        this.refreshTable = false;
        searchProducts({ productType: pickListValue, queryValue:searchinput, workOrder: this.recordId})
                .then((result) => {
                    this.productList = result;
                    this.addBodegaColumns(this.productList);
                    this.error = undefined;
                })
                .catch((error) => {
                    this.error = error;
                    this.productList_test = undefined;
                    console.log(error);
                    
            });
       
    }

    selectProducts() {
        // console.log(event);
         var selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
         //console.log(selectedRecords);
         this.idList = [];
         this.productIds = [];
         this.workOrderList = [];
         //this.priceBookIdList = [];
         //this.productCodeSelected = '';
         if(selectedRecords){
                 let ids = '';
                 selectedRecords.forEach(currentItem => {
                     //if(this.idList.indexOf(currentItem.ID)==-1){
                        currentItem.CanDeleteWolis__c = true;
                        this.idList.push(currentItem.ID);
                        this.productIds.push(currentItem.productId);
                        this.workOrderList.push(currentItem);
                        //this.priceBookIdList.push(currentItem.priceBookEntry);
                    // }
                    this.productCodeSelected = selectedRecords.length === 1 ? currentItem.ProductCode : this.productCodeSelected;
                    this.disablePriceRederence =  selectedRecords.length > 1;
                    this.disableLocalizaciones =  selectedRecords.length > 1;

 
                 });
                 this.selectedIds = ids.replace(/^,/, '');
             }
             this.selectedRows = this.idList;
        //console.log(JSON.stringify(this.workOrderList));
     }

     cleanUp(){
        this.productList = [];
        this.idList = [];
        this.productIds = [];
        this.workOrderList = [];
        //this.resetCOLS();
    }


    //Events
    handleCancel() {
        this.cleanUp();
        this.dispatchEvent(new CustomEvent('cancel', {
            detail: {
                message: false
            }
        }));
    }

    handleAddLines() {
        this.dispatchEvent(new CustomEvent('addlines', {
            detail: {
                message: this.workOrderList
            }
        }));
        this.cleanUp();
    }


    //Bodegas Logic
    addBodegaColumns(data) {
        // Loop through the data to collect unique bodega names and dynamically add columns
        data.forEach((item) => {
          if (item.bodegas) {
            console.log(item.bodegas);
            item.bodegas.forEach((bodega) => {
              const fieldName = `bodega_${bodega.Id}`;
              item[fieldName] = bodega.cantidadDisponible;
              const columnName = bodega.isPrincipal
                ? bodega.name + "(Principal)"
                : bodega.name;
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
        this.bodegasCols = new Set();
      }

      rerenderTable() {
        this.refreshTable = true;
      }

      handleShowPricebookTableToggle(){
        this.showDetailedSearch = !this.showDetailedSearch;
        this.disableButtons = !this.disableButtons;
        this.showButtonLocation = this.showDetailedSearch ? true : false;
        this.toogleLabelPricebook = this.showDetailedSearch ? 'Ver Lista de Precios' : 'Atrás';
        this.selectedRows = this.idList;
      }
      handleShowLocalizacionTableToggle(){
        this.showDetailedSearch = !this.showDetailedSearch;
        this.disableButtons = !this.disableButtons;
        this.showButtonPrice = this.showDetailedSearch ? true : false;
        this.toogleLabelLocation = this.showDetailedSearch ? 'Ver Localizaciones' : 'Atrás';
        this.selectedRows = this.idList;
      }
}