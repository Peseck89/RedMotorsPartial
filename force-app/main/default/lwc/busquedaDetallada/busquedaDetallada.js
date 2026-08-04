import { LightningElement, track, api, wire } from 'lwc';
import searchProducts from "@salesforce/apex/BusquedaDetalladaController.searchProducts";
import updateFreshPriceFromSoftland from "@salesforce/apex/BusquedaDetalladaController.updateFreshPriceFromSoftland";

import USER_ID from '@salesforce/user/Id';
import { getRecord } from "lightning/uiRecordApi";
import PROFILE_NAME from '@salesforce/schema/User.Profile.Name';

import empresaFactura from '@salesforce/schema/WorkOrder.empresaFactura__c';
import empresaFactura2 from '@salesforce/schema/Quote.empresaFactura__c';
import getActivePricebooks from '@salesforce/apex/BusquedaDetalladaController.getActivePricebooks';
import getActiveServiceTerritories from '@salesforce/apex/BusquedaDetalladaController.getActiveServiceTerritories';

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

export default class BusquedaDetallada extends LightningElement {
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
    pricebookEntryIdSelected; // ✅ nuevo para actualizar PBE correcto

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

    firstScreen = true;
    pricebookOptions = [];
    selectedPricebookId = null;
    selectedPricebookName = '';

    // ✅ Admin filter
    @track isAdminProfile = false;
    profileName;

    // ✅ Wire del usuario actual para leer Profile.Name
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

    // ✅ SOLO muestra el botón si estás en vista de precios y el perfil contiene Admin
    get showUpdatePriceButton() {
        return this.showButtonUpdatePrice && this.isAdminProfile;
    }

    @wire(getActivePricebooks)
    wiredPricebooks({ data, error }) {
        if (data) {
            this.pricebookOptions = data.map(pb => ({
                label: pb.IsStandard ? `${pb.Name} (Estándar)` : pb.Name,
                value: pb.Id
            }));
        } else if (error) {
            this.toast('Error', 'No fue posible cargar las listas de precios', 'error');
        }
    }

    handlePricebookChange(event) {
        this.selectedPricebookId = event.detail.value;
        const opt = this.pricebookOptions.find(o => o.value === this.selectedPricebookId);
        this.selectedPricebookName = opt ? opt.label : '';
    }

    // Service Territory
    territoryOptions = [];
    selectedTerritoryId = null;
    selectedTerritoryName = '';

    @wire(getActiveServiceTerritories)
    wiredTerritories({ data, error }) {
        if (data) {
            this.territoryOptions = data.map(st => ({ label: st.Name, value: st.Id }));
        } else if (error) {
            this.toast('Error', 'No fue posible cargar los territorios de servicio', 'error');
        }
    }

    handleTerritoryChange(event) {
        this.selectedTerritoryId = event.detail.value;
        const opt = this.territoryOptions.find(o => o.value === this.selectedTerritoryId);
        this.selectedTerritoryName = opt ? opt.label : '';
    }

    get disableContinue() {
        return !(this.selectedPricebookId);
    }

    handleContinue() {
        if (this.disableContinue) return;
        this.cleanUp();
        this.firstScreen = false;

        this.showDetailedSearch = true;
        this.showButtonPrice = true;
        this.showButtonLocation = true;
        this.showButtonUpdatePrice = false;
        this.toogleLabelPricebook = 'Ver Lista de Precios';
        this.toogleLabelLocation = 'Ver Localizaciones';
    }

    handleBackToFirst() {
        this.firstScreen = true;
        this.cleanUp();

        this.showDetailedSearch = true;
        this.showButtonPrice = true;
        this.showButtonLocation = true;
        this.showButtonUpdatePrice = false;
        this.toogleLabelPricebook = 'Ver Lista de Precios';
        this.toogleLabelLocation = 'Ver Localizaciones';
    }

    // wire empresaFactura
    @wire(getRecord, { recordId: '$recordId', fields: [empresaFactura] })
    empresaFacturaWO({ error, data }) {
        if (data) {
            this.empresaFactura = data.fields.empresaFactura__c.value;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [empresaFactura2] })
    empresaFacturaQO({ error, data }) {
        if (data) {
            this.empresaFactura = data.fields.empresaFactura__c.value;
        } else if (error) {
            this.error = error;
        }
    }

    handleSearchProduct() {
        var pickListValue = '';
        var searchinput = this.template.querySelector("lightning-input").value;
        this.resetCOLS();
        this.refreshTable = false;

        searchProducts({
            productType: pickListValue,
            queryValue: searchinput,
            workOrder: this.recordId,
            priceBookId: this.selectedPricebookId,
            serviceTerritoryId: this.selectedTerritoryId
        })
            .then((result) => {
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
                this.productList_test = undefined;
                // eslint-disable-next-line no-console
                console.log(error);
            });
    }

    selectProducts() {
        var selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
        this.idList = [];
        this.productIds = [];
        this.workOrderList = [];

        this.productCodeSelected = null;
        this.pricebookEntryIdSelected = null;

        if (selectedRecords) {
            let ids = '';
            selectedRecords.forEach(currentItem => {
                currentItem.CanDeleteWolis__c = true;
                this.idList.push(currentItem.ID);
                this.productIds.push(currentItem.productId);
                this.workOrderList.push(currentItem);

                if (selectedRecords.length === 1) {
                    this.productCodeSelected = currentItem.ProductCode;

                    this.pricebookEntryIdSelected =
                        currentItem.priceBookEntry ||
                        currentItem.pricebookEntryId ||
                        currentItem.PricebookEntryId ||
                        null;

                    this.disablePriceRederence = false;
                    this.disableLocalizaciones = false;
                } else {
                    this.disablePriceRederence = true;
                    this.disableLocalizaciones = true;
                }
            });
            this.selectedIds = ids.replace(/^,/, '');
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
        this.resetCOLS();
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

    validateBodegaPrincipal(data) {
        if (data.productType === "Materiales") {
            const principalBodega = data.bodegas.find(bodega => bodega.isPrincipal && bodega.cantidadDisponible > 0);
            const hasApartados = data.bodegas.find(bodega => bodega.name.toLowerCase().includes("apartados") && bodega.cantidadDisponible > 0);
            if (!principalBodega && hasApartados) {
                data.bodegaID = hasApartados.Id;
                data.Bodega = hasApartados.name;
                data.cantidadDisponible = hasApartados.cantidadDisponible;
                data.changedToApartados = true;
            } else {
                data.changedToApartados = false;
            }
            return !!principalBodega || !!hasApartados;
        }
        return true;
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

    orderColumns() {
        const principalColumnIndex = this.cols.findIndex(col => col.label.endsWith("(Principal)"));
        if (principalColumnIndex !== -1) {
            const removedColumn = this.cols.splice(principalColumnIndex, 1)[0];
            this.cols.splice(2, 0, removedColumn);
        }
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

    // ✅ Ahora sí actualiza precio y SOLO admin
    async handleShowUpdatePricebookTableToggle() {
        if (!this.isAdminProfile) {
            this.toast('No autorizado', 'Esta acción solo está disponible para perfiles Admin.', 'error');
            return;
        }

        if (this.showDetailedSearch) {
            this.handleShowPricebookTableToggle();
            return;
        }

        if (!this.productCodeSelected) {
            this.toast('Sin producto', 'Selecciona un producto para actualizar el precio.', 'warning');
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
                this.toast('Precio actualizado', `Nuevo: ${result.newUnitPrice} | Fecha: ${result.fecha || 'N/A'}`, 'success');

                const child = this.template.querySelector('c-pricebook-reference-details');
                if (child && typeof child.refresh === 'function') {
                    child.refresh();
                }
            } else {
                this.toast('No se pudo actualizar', result?.message || 'Error desconocido', 'error');
            }
        } catch (e) {
            this.toast(
                'Error al actualizar precio',
                (e?.body?.message) ? e.body.message : (e?.message || 'Error desconocido'),
                'error'
            );
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

    toast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
