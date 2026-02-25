import { LightningElement, track, api } from 'lwc';
import getProducts_test from '@salesforce/apex/ProductControllerTwo.searchProductxBodegaxQuote';



const DELAY = 100;

const COLS = [
    { label: 'Código', fieldName: 'ProductCode', type: 'text' },
    { label: 'Producto', fieldName: 'Name', type: 'text' },
    { label: 'Precio', fieldName: 'precio', type: 'currency',typeAttributes: {  maximumFractionDigits: 2,currencyCode: { fieldName: 'currencyCode' } } },
    { label: 'Bodega', fieldName: 'Bodega', type: 'text' },
    { label: 'Cantidad disponible', fieldName: 'cantidadDisponible', type: 'text' },
    { label: 'Tipo', fieldName: 'productType', type: 'text' },
];

export default class AddProductsToQuoteLineItem extends LightningElement {
    cols = COLS;
    @api recId;
    @api quoteList = [];
    @api idList = [];
    productIds = [];
    quantityselected=0;
    visibleFlag=false;
    @track selectedRows=[];
    picklistValues=[];
    productCode = '';
    @api productName = '';
    productList = [];
    productList_test = [];
    error;
    showSelectedProductsFlag=false;


    searchProductAction(){
        var pickListValue = this.template.querySelector("[data-id = 'comboTipotrabajo']").value;
        var pickListCriteriaValue = this.template.querySelector("[data-id = 'comboSearchCriteria']").value;
        console.debug('value: ' + pickListValue + ' , criteria: ' + pickListCriteriaValue);

        var searchInput = this.template.querySelector("lightning-input").value;

        getProducts_test({productType : pickListValue, productName : searchInput, searchCriteria : pickListCriteriaValue, quoteId : this.recId})
            .then((result) => {
                this.productList_test = result;
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.productList_test = undefined;
                console.log('Error in getProducts_test!!!!!!! ' + error);
            })
            .finally(() => {
                if(this.quoteList.length != 0){
                    setTimeout(
                        () => this.selectedRows = this.quoteList.map(record=>record.ID)
                    );
                }
            });


    }

    selectProducts(){
        var selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
        console.log('SELECTED' + selectedRecords);
        if(selectedRecords){
            let ids = '';
            selectedRecords.forEach(currentItem => {
                if(this.idList.indexOf(currentItem.ID) == -1){
                    this.idList.push(currentItem.ID);
                    this.productIds.push(currentItem.productId);
                    this.quoteList.push(currentItem);
                }
            });
            this.selectedIds = ids.replace(/^,/, '');
        }
        this.setQuantitySelected();
    }

    get options(){
        return [
            { label: 'Busqueda solo en bodega correspondiente', value: 'ServiceTerritory'},
            { label: 'Busqueda SOLAMENTE de mano de obra', value: 'Mano de Obra'}
        ];
    }

    get optionsSearchCriteria(){
        return [
            { label: 'Nombre', value: 'xNombre'},
            { label: 'Codigo', value: 'xCodigo'}
        ];
    }

    handleNavigate(){
        if(this.visibleFlag) this.visibleFlag = false;
        else this.visibleFlag = true;
        this.selectedRows = this.idList;
    }

    handleDeleteLine(event){
        this.quoteList = event.detail.deletedRecords;
        this.idList = event.detail.deletedIds;
        this.quantityselected = this.idList.length;
    }

    showSelectedProducts(){
        this.productList = this.quoteList.map(record => record);
        this.selectedRows = this.quoteList.map(record => record.ID);
        this.showSelectedProductsFlag = true;
    }

    closeSelectedProducts(){
        this.showSelectedProductsFlag = false;
    }

    deselectProducts(event){
        console.log('Deselect:' + event.detail.selectedRows);
        this.quoteList = event.detail.selectedRows.map(record => record);
        this.idList = this.selectedRows;
        this.setQuantitySelected();
    }

    setQuantitySelected(){
        console.log('quantityselected: ' + this.quantityselected);
        console.log('quoteList: ' + this.quoteList.length);
        this.quantityselected = this.quoteList.length;
    }

    handleClose(event){
        window.location = window.location.href;
        return false;
    }
}