import { LightningElement, track, api, wire } from 'lwc';
import searchProducts from "@salesforce/apex/WoliGridController.searchProducts";
import updateFreshPriceFromSoftland from "@salesforce/apex/WoliGridController.updateFreshPriceFromSoftland";

import USER_ID from '@salesforce/user/Id';
import { getRecord } from "lightning/uiRecordApi";
import PROFILE_NAME from '@salesforce/schema/User.Profile.Name';

import empresaFactura from '@salesforce/schema/WorkOrder.empresaFactura__c';
import empresaFactura2 from '@salesforce/schema/Quote.empresaFactura__c';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLS = [
  { label: 'Código', fieldName: 'ProductCode', type: 'text' },
  { label: 'Producto', fieldName: 'Name', type: 'text' },

  { label: 'Sustitutivo', fieldName: 'sustitutivo', type: 'text' },
  { label: 'Alternativo', fieldName: 'alternativo', type: 'text' },
  { label: 'Margen', fieldName: 'margen', type: 'text' },
  { label: 'Tránsito', fieldName: 'transito', type: 'text' },

  { label: 'Precio', fieldName: 'precio', type: 'currency', typeAttributes: { maximumFractionDigits: 2, currencyCode: { fieldName: 'currencyCode' } } },
];

const originalCOLS = [...COLS];

export default class WoSearchDetailProduct extends LightningElement {
    @api recordId;
    @api showSearchModal;

    @track productList = [];
    @track cols = [...COLS];

    @track showButtonPrice = true;
    @track showButtonUpdatePrice = false; // estado "estoy en precios"
    @track showButtonLocation = true;

    idList = [];
    productIds = [];
    workOrderList = [];

    productCodeSelected;
    pricebookEntryIdSelected; // ✅ nuevo para actualizar UnitPrice del PBE correcto

    disablePriceRederence = true;
    disableLocalizaciones = true;

    selectedRows = [];

    refreshTable = true;
    bodegasCols = new Set();

    showDetailedSearch = true;

    disableButtons = false;
    toogleLabelPricebook = 'Ver Lista de Precios';
    toogleLabelUpdatePricebook = 'Actualizar Precio';
    toogleLabelLocation = 'Ver Localizaciones';

    empresaFactura;

    // ✅ Admin filter (Profile.Name contiene "admin")
    @track isAdminProfile = false;
    profileName;

    @wire(getRecord, { recordId: USER_ID, fields: [PROFILE_NAME] })
    userProfileWire({ error, data }) {
        if (data) {
            const pName = data.fields?.Profile?.value?.fields?.Name?.value;
            this.profileName = pName;
            this.isAdminProfile = !!pName && pName.toLowerCase().includes('admin');
        } else if (error) {
            this.isAdminProfile = false;
        }
    }

    // ✅ SOLO muestra el botón si estoy en vista de precios y soy admin
    get showUpdatePriceButton() {
        return this.showButtonUpdatePrice && this.isAdminProfile;
    }

    @wire(getRecord, { recordId: '$recordId', fields: [empresaFactura] })
    empresaFacturaWO({ error, data }) {
        if (data) this.empresaFactura = data.fields.empresaFactura__c.value;
        else if (error) this.error = error;
    }

    @wire(getRecord, { recordId: '$recordId', fields: [empresaFactura2] })
    empresaFacturaQO({ error, data }) {
        if (data) this.empresaFactura = data.fields.empresaFactura__c.value;
        else if (error) this.error = error;
    }

    handleSearchProduct() {
        const pickListValue = '';
        const searchinput = this.template.querySelector("lightning-input")?.value || '';

        this.resetCOLS();
        this.refreshTable = false;

        searchProducts({ productType: pickListValue, queryValue: searchinput, workOrder: this.recordId })
            .then((result) => {
                // Asegura ID (por si a veces no viene)
                this.productList = (result || []).map(r => {
                    const row = { ...r };
                    if (!row.ID) {
                        row.ID = row.productId || row.priceBookEntry || `ROW_${Math.random().toString(36).slice(2)}`;
                    }
                    return row;
                });

                this.addBodegaColumns(this.productList);
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                // eslint-disable-next-line no-console
                console.log(error);
            });
    }

    selectProducts() {
        const dt = this.template.querySelector("lightning-datatable");
        const selectedRecords = dt ? dt.getSelectedRows() : [];

        this.idList = [];
        this.productIds = [];
        this.workOrderList = [];
        this.productCodeSelected = null;
        this.pricebookEntryIdSelected = null;

        if (selectedRecords && selectedRecords.length) {
            selectedRecords.forEach(currentItem => {
                currentItem.CanDeleteWolis__c = true;
                this.idList.push(currentItem.ID);
                this.productIds.push(currentItem.productId);
                this.workOrderList.push(currentItem);
            });

            if (selectedRecords.length === 1) {
                const only = selectedRecords[0];
                this.productCodeSelected = only.ProductCode;

                this.pricebookEntryIdSelected =
                    only.priceBookEntry ||
                    only.pricebookEntryId ||
                    only.PricebookEntryId ||
                    null;

                this.disablePriceRederence = false;
                this.disableLocalizaciones = false;
            } else {
                this.disablePriceRederence = true;
                this.disableLocalizaciones = true;
            }
        } else {
            this.disablePriceRederence = true;
            this.disableLocalizaciones = true;
        }

        this.selectedRows = this.idList;
    }

    cleanUp() {
        this.productList = [];
        this.idList = [];
        this.productIds = [];
        this.workOrderList = [];
        this.productCodeSelected = null;
        this.pricebookEntryIdSelected = null;
        this.selectedRows = [];
        this.disablePriceRederence = true;
        this.disableLocalizaciones = true;
        this.resetCOLS();
    }

    handleCancel() {
        this.cleanUp();
        this.dispatchEvent(new CustomEvent('cancel', { detail: { message: false } }));
    }

    handleAddLines() {
        this.dispatchEvent(new CustomEvent('addlines', { detail: { message: this.workOrderList } }));
        this.cleanUp();
    }

    //Bodegas Logic
    addBodegaColumns(data) {
        data.forEach((item) => {
            if (!item.bodegas || !item.bodegas.length) return;

            const principal = item.bodegas.find((b) => b.isPrincipal);
            if (!principal) return;

            const fieldName = `bodega_${principal.Id}`;
            item[fieldName] = principal.cantidadDisponible;

            const column = {
                label: principal.name + "(Principal)",
                fieldName: fieldName,
                type: "text"
            };

            this.addColumnAtIndex(principal.Id, column);
        });
    }

    addColumnAtIndex(bodegaId, column) {
        const priceIndex = this.cols.findIndex(c => c.fieldName === 'precio');
        const index = (priceIndex === -1) ? this.cols.length : priceIndex;

        if (!this.bodegasCols.has(bodegaId) && !this.cols.some(c => c.fieldName === column.fieldName)) {
            this.cols = [
                ...this.cols.slice(0, index),
                column,
                ...this.cols.slice(index)
            ];
            this.bodegasCols.add(bodegaId);
        }
        this.rerenderTable();
    }

    resetCOLS() {
        this.cols = [...originalCOLS];
        this.bodegasCols = new Set();
    }

    rerenderTable() {
        this.refreshTable = true;
    }

    handleShowPricebookTableToggle() {
        this.showDetailedSearch = !this.showDetailedSearch;

        const inPriceView = !this.showDetailedSearch;

        this.disableButtons = inPriceView;

        this.showButtonLocation = !inPriceView;
        this.showButtonUpdatePrice = inPriceView;

        this.toogleLabelPricebook = inPriceView ? 'Atrás' : 'Ver Lista de Precios';
        this.selectedRows = this.idList;
    }

    // ✅ Ahora SÍ actualiza precio (y solo admin lo puede ejecutar)
    async handleShowUpdatePricebookTableToggle() {
        if (!this.isAdminProfile) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'No autorizado',
                message: 'Esta acción solo está disponible para perfiles Admin.',
                variant: 'error'
            }));
            return;
        }

        if (this.showDetailedSearch) {
            this.handleShowPricebookTableToggle();
            return;
        }

        if (!this.productCodeSelected) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Sin producto',
                message: 'Selecciona un producto para actualizar el precio.',
                variant: 'warning'
            }));
            return;
        }

        const prevDisable = this.disablePriceRederence;
        this.disablePriceRederence = true;

        try {
            const result = await updateFreshPriceFromSoftland({
                productCode: this.productCodeSelected,
                empresaFactura: this.empresaFactura,
                pricebookEntryId: this.pricebookEntryIdSelected
            });

            if (result?.success) {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Precio actualizado',
                    message: `Nuevo: ${result.newUnitPrice} | Fecha: ${result.fecha || 'N/A'}`,
                    variant: 'success'
                }));

                const child = this.template.querySelector('c-pricebook-reference-details');
                if (child && typeof child.refresh === 'function') {
                    child.refresh();
                }
            } else {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'No se pudo actualizar',
                    message: result?.message || 'Error desconocido',
                    variant: 'error'
                }));
            }
        } catch (e) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error al actualizar precio',
                message: (e?.body?.message) ? e.body.message : (e?.message || 'Error desconocido'),
                variant: 'error'
            }));
        } finally {
            this.disablePriceRederence = prevDisable;
            this.showButtonUpdatePrice = true;
            this.showButtonLocation = false;
            this.disableButtons = true;
            this.selectedRows = this.idList;
        }
    }

    handleShowLocalizacionTableToggle() {
        this.showDetailedSearch = !this.showDetailedSearch;

        const inLocationView = !this.showDetailedSearch;

        this.disableButtons = inLocationView;

        this.showButtonPrice = !inLocationView;
        this.showButtonUpdatePrice = false;

        this.toogleLabelLocation = inLocationView ? 'Atrás' : 'Ver Localizaciones';
        this.selectedRows = this.idList;
    }
}
