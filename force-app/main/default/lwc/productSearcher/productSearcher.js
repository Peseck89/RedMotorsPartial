import { LightningElement, track, wire, api } from 'lwc';
import columnsVehicle from './columns';
import { reduceErrors } from 'c/ldsUtils';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProducts from '@salesforce/apex/ProductSearcherController.getProducts';
import search from '@salesforce/apex/SampleLookupController.searchRecords';

const COLUMNS_EXTRA = [
    {
        label: 'Nombre',
        fieldName: 'productUrl',
        type: 'url',
        typeAttributes: { label: { fieldName: 'productName' }, target: '_blank' },
    },
    { label: 'Código', fieldName: 'productCode', initialWidth: 200 },
    { label: 'Precio', fieldName: 'productUnitPrice', type: 'currency', typeAttributes: { currencyCode: 'USD' }, initialWidth: 150 },
    { label: 'Disponible', fieldName: 'Disponible__c', type: 'number', initialWidth: 150 },
    { label: 'Bodega', fieldName: 'bodegaName', type: 'text', initialWidth: 250 }
];

const COLUMNS_MANOOBRA = [
    {
        label: 'Nombre',
        fieldName: 'productUrl',
        type: 'url',
        typeAttributes: { label: { fieldName: 'productName' }, target: '_blank' },
    },
    { label: 'Código', fieldName: 'productCode' },
    { label: 'Precio', fieldName: 'productUnitPrice', type: 'currency', typeAttributes: { currencyCode: 'USD', alignment: 'center' }, initialWidth: 150 }
];

// =========================================================
// ✅ Códigos de bodega
// =========================================================
const BODEGA_BR01 = 'BR01';
const BODEGA_BR02 = 'BR02';
const BODEGA_RM01 = 'RM01';
const BODEGA_ALL  = 'ALL';

export default class ProductSearcher extends LightningElement {

    columnsVehicle = columnsVehicle;
    columnsExtra = COLUMNS_EXTRA;
    columnsManoObra = COLUMNS_MANOOBRA;

    _vehicleOptions;

    @api oppProdIntId = null;
    @api recordId = null;
    @api title = null;
    @api productType;

    pageNumber = 1;
    totalRecords = 0;
    totalPages = 0;
    showFilters = true;

    productName = null;
    vin = null;

    @api brand = null;
    @api year = null;
    @api model = null;
    @api family = null;

    intColor = null;
    extColor = null;

    @api productCode = null;

    // (se queda por compatibilidad)
    @api bodegaId = null;

    bodegaErrors = [];
    bodegaInitialSelection = [];

    isLoading = true;

    prodXBodItem;

    wiredProductsResult;
    @track products = [];
    selectedProductIds = [];

    // =========================================================
    // Bodega dinámica: Auto => BR01 | Kawa/Indian/Polaris => BR02 | Moto => RM01
    // =========================================================
    @track bodegaCode = BODEGA_BR01;
    _bodegaManual = false;

    get usesBr02Bodega() {
        const b = (this.brand || '').toString().toLowerCase();
        return (
            b.includes('kawa') ||
            b.includes('kawasaki') ||
            b.includes('indian') ||
            b.includes('polaris')
        );
    }

    get isMotoVehicle() {
        // Heurística por marca (si tienes un campo real "Tipo de vehículo", úsalo aquí).
        const b = (this.brand || '').toString().toLowerCase();
        return (
            b.includes('kawa') ||
            b.includes('kawasaki') ||
            b.includes('polaris') ||
            b.includes('moto') ||
            b.includes('otobai')
        );
    }

    get bodegaOptions() {
        if (this.usesBr02Bodega) {
            return [
                { label: 'BR02 Pavas', value: BODEGA_BR02 },
                { label: 'Todos', value: BODEGA_ALL }
            ];
        }
        if (this.isMotoVehicle) {
            return [
                { label: 'RM01 Motos', value: BODEGA_RM01 },
                { label: 'Todos', value: BODEGA_ALL }
            ];
        }
        return [
            { label: 'BR01 Autos', value: BODEGA_BR01 },
            { label: 'Todos', value: BODEGA_ALL }
        ];
    }

    computeDefaultBodegaFromBrand() {
        if (this.usesBr02Bodega) return BODEGA_BR02;
        return this.isMotoVehicle ? BODEGA_RM01 : BODEGA_BR01;
    }

    ensureBodegaValidForCurrentOptions() {
        if (this.bodegaCode === BODEGA_ALL) return;
        const allowed = this.bodegaOptions.map(o => o.value);
        if (!allowed.includes(this.bodegaCode)) {
            this.bodegaCode = this.computeDefaultBodegaFromBrand();
        }
    }

    applyDefaultBodegaIfNeeded() {
        if (this.bodegaCode === BODEGA_ALL) return;

        if (this._bodegaManual) {
            this.ensureBodegaValidForCurrentOptions();
            return;
        }

        this.bodegaCode = this.computeDefaultBodegaFromBrand();
        this.ensureBodegaValidForCurrentOptions();
    }

    handleBodegaCodeChange(event) {
        this.bodegaCode = event.detail.value;
        this._bodegaManual = true;

        this.isLoading = true;
        this.pageNumber = 1;
        this.refresh();
    }

    productTypeOptions = [
        { value: 'extra', label: 'Compatibles' },
        { value: 'otros productos', label: 'Otros Productos' },
        { value: 'mano obra', label: 'Otros Gastos' }
    ];

    @track vehiculoTransito = 'All';

    @track vehiculoTransitoOptions = [
        { label: 'Todos', value: 'All' },
        { label: 'Si', value: 'Si' },
        { label: 'No', value: 'No' },
    ];

    handleVehiculoTransitoChange(event) {
        this.vehiculoTransito = event.detail.value;
    }

    handleProductTypeChange(event) {
        this.productType = event.detail.value;

        this._bodegaManual = false;
        this.applyDefaultBodegaIfNeeded();

        this.dispatchEvent(new CustomEvent('producttypeselected', {
            detail: { productType: this.productType }
        }));
    }

    get dynamicColumns() {
        if (this.productType === 'mano obra') return this.columnsManoObra;
        if (this.productType === 'extra' || this.productType === 'otros productos') return this.columnsExtra;
        return this.columnsVehicle;
    }

    get isVehicle() {
        return this.productType === 'vehiculo';
    }

    get showVehicleFilters() {
        return this.productType === 'vehiculo';
    }

    get showFiltersVehiculoManoObra() {
        return this.productType === 'extra' || this.productType === 'otros productos' || this.productType === 'mano obra';
    }

    get isManoObra() {
        return this.productType === 'mano obra';
    }

    get showBodegaFilter() {
        return this.productType === 'vehiculo'
            || this.productType === 'extra'
            || this.productType === 'otros productos';
    }

    sfdcBaseURL;

    esManoDeObra = false;
    esExtra = false;

    connectedCallback() {
        if (this.brand && this.brand.toLowerCase() === 'kawasaki') {
            this.brand = 'Kawa';
        }

        this.sfdcBaseURL = window.location.origin;

        this.applyDefaultBodegaIfNeeded();
    }

    @wire(getProducts, {
        productType: '$productType',
        oppProdIntId: '$oppProdIntId',
        productName: '$productName',
        productCode: '$productCode',
        bodegaCode: '$bodegaCode',     // BR01/BR02/RM01/ALL
        bodegaId: '$bodegaId',
        year: '$year',
        vin: '$vin',
        brand: '$brand',
        family: '$family',
        intColor: '$intColor',
        extColor: '$extColor',
        model: '$model',
        recordId: '$recordId',
        vehiculoTransito: '$vehiculoTransito',
        pageNumber: '$pageNumber'
    })
    wiredProducts(result) {
        this.products = [];
        this.wiredProductsResult = result;

        if (result.data && result.data.products) {
            let records = JSON.parse(JSON.stringify(result.data.products));

            Object.values(result.data.products).forEach((item, index) => {
                if (typeof item === "object") {

                    let pbeFantasia;
                    let pbeBavarian;

                    if (this.productType === 'vehiculo') {
                        if (result.data.preciosFantasia) {
                            pbeFantasia = result.data.preciosFantasia.find((element) => {
                                return element.Name === item.Producto__r.modelo__c;
                            });
                        }
                        if (result.data.preciosBavarian) {
                            pbeBavarian = result.data.preciosBavarian.find((element) => {
                                return element.Product2Id === item.Producto__c;
                            });
                        }
                    } else if (result.data.prices) {
                        if (this.productType === 'extra' || this.productType === 'otros productos') {
                            pbeBavarian = result.data.prices.find(({ Product2Id }) => item.Producto__r.Id === Product2Id);
                        } else if (this.productType === 'mano obra') {
                            pbeBavarian = result.data.prices.find(({ Product2Id }) => item.Id === Product2Id);
                        }
                    }

                    if (item.Producto__r) {
                        records[index].productId = item.Producto__r.Id ? item.Producto__r.Id : '';
                        records[index].productCode = item.Producto__r.Codigo_de_Producto__c ? item.Producto__r.Codigo_de_Producto__c : '';
                        records[index].productName = item.Producto__r.Name ? item.Producto__r.Name : '';
                        records[index].productBrand = item.Producto__r.marcaVehiculo__c ? item.Producto__r.marcaVehiculo__c : '';
                        records[index].productModel = item.Producto__r.modelo__c ? item.Producto__r.modelo__c : '';
                        records[index].productFamily = item.Producto__r.VN_Familia__c ? item.Producto__r.VN_Familia__c : '';
                        records[index].productVin = item.Producto__r.vin__c ? item.Producto__r.vin__c : '';
                        records[index].productYear = item.Producto__r.Ano__c ? item.Producto__r.Ano__c : '';
                        records[index].productColor = item.Producto__r.Color__c ? item.Producto__r.Color__c : '';
                        records[index].productColorExterno = item.Producto__r.Color_Externo__c ? item.Producto__r.Color_Externo__c : '';
                        records[index].productPriceFantasia = pbeFantasia && pbeFantasia.UnitPrice ? parseFloat(pbeFantasia.UnitPrice).toFixed(2) : 0;
                        records[index].productUrl = this.sfdcBaseURL + '/' + item.Producto__r.Id;
                        records[index].pbeFantasiaId = pbeFantasia ? pbeFantasia.Id : 0.0;
                        records[index].pbeBavarianId = pbeBavarian ? pbeBavarian.Id : 0.0;

                    } else if (this.productType === 'mano obra') {
                        records[index].productId = null;
                        records[index].productCode = item.Codigo_de_Producto__c ? item.Codigo_de_Producto__c : '';
                        records[index].productName = item.Name ? item.Name : '';
                        records[index].productQuantity = 1;
                        records[index].productUrl = this.sfdcBaseURL + '/' + item.Id;
                    } else {
                        records[index].productId = item.Id;
                        records[index].productCode = item.Codigo_de_Producto__c ? item.Codigo_de_Producto__c : '';
                        records[index].productName = item.Name ? item.Name : '';
                        records[index].productUrl = this.sfdcBaseURL + '/' + item.Id;
                    }

                    if (this.productType === 'vehiculo') {
                        records[index].productUnitPrice = pbeFantasia && pbeFantasia.UnitPrice ? parseFloat(pbeFantasia.UnitPrice).toFixed(2) : 0;
                    } else {
                        records[index].productUnitPrice = pbeBavarian && pbeBavarian.UnitPrice ? parseFloat(pbeBavarian.UnitPrice).toFixed(2) : 0;
                    }

                    if (item.Bodega__r) {
                        const code = item.Bodega__r.Bodega__c ? (item.Bodega__r.Bodega__c + ' - ') : '';
                        records[index].bodegaName = (code + (item.Bodega__r.Name || '')).trim();
                    } else {
                        records[index].bodegaName = '';
                    }
                }
            });

            this.products = records;
            this.totalRecords = result.data.totalRecords ? result.data.totalRecords : 0;
            if (this.totalRecords > 0) {
                this.totalPages = Math.ceil(result.data.totalRecords / result.data.pageSize);
            }

        } else if (result.error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error !',
                    message: reduceErrors(result.error).join(', '),
                    variant: 'error'
                })
            );
        }

        this.isLoading = false;
    }

    handleBackClick() {
        this.pageNumber--;
        this.refresh();
    }

    handleNextClick() {
        this.pageNumber++;
        this.refresh();
    }

    get isEnablePrevButton() {
        return !(this.totalPages > 0 && this.pageNumber > 1);
    }

    get isEnableNextButton() {
        return !(this.totalPages > 1 && this.pageNumber !== this.totalPages);
    }

    inputVehiculoCompatibleId;

    handleProductSelection(event) {
        const selectedRows = event.detail.selectedRows;

        this.selectedProductIds = [];
        let selectedItem;

        for (let i = 0; i < selectedRows.length; i++) {
            this.selectedProductIds.push(selectedRows[i].Id);
            this.prodXBodItem = selectedRows[i];
            selectedItem = selectedRows[i];
        }

        this.dispatchEvent(new CustomEvent('productselection', {
            detail: {
                products: [...this.selectedProductIds],
                prodXBodegaId: [...this.selectedProductIds],
                prodXBodItem: this.prodXBodItem,
                vehiculoCompatibleId: this.inputVehiculoCompatibleId,
                esManoDeObra: this.esManoDeObra,
                esExtra: this.esExtra,
                productType: this.productType,
                selectedRows: selectedRows
            }
        }));
    }

    get maxRowSelection() {
        return this.isVehicle === true ? 1 : 5;
    }

    customTimeOut;
    @api
    refresh() {
        if (this.customTimeOut) clearTimeout(this.customTimeOut);

        this.isLoading = true;
        this.selectedProductIds = [];

        this.customTimeOut = setTimeout(() => {
            refreshApex(this.wiredProductsResult);
            this.isLoading = false;
        }, 400);
    }

    handleBodegaSearch(event) {
        const lookupElement = event.target;
        var params = event.detail;

        params["firedElement"] = 'Bodega';
        params["icon"] = 'standard:user';
        params["objName"] = 'Bodega__c';
        params["displayedObjName"] = 'Bodega';

        search(params)
            .then((results) => {
                lookupElement.setSearchResults(results);
            });
    }

    handleBodegaSelectionChange(event) {
        let bodId = null;
        [bodId] = event.detail;
        this.bodegaId = bodId !== undefined ? bodId : null;
    }

    get vehicleOptions() {
        return this._vehicleOptions;
    }

    @api
    set vehicleOptions(value) {
        if (value) {
            this._vehicleOptions = value;
            if (this._vehicleOptions.length === 1) {
                this.brand = this._vehicleOptions[0].brand;
                this.model = this._vehicleOptions[0].model;
                this.year = this._vehicleOptions[0].year;
                this.inputVehiculoCompatibleId = this._vehicleOptions[0].value;

                this._bodegaManual = false;
                this.applyDefaultBodegaIfNeeded();
            }
        }
    }

    handleVehicleCompatibleChange(event) {
        if (event.detail.value !== undefined) {
            this.inputVehiculoCompatibleId = event.detail.value;

            this._vehicleOptions.forEach((item) => {
                if (event.detail.value === item.value) {
                    this.brand = item.brand;
                    this.model = item.model;
                    this.year = item.year;

                    this._bodegaManual = false;
                    this.applyDefaultBodegaIfNeeded();
                }
            });
        }
    }

    handleBrandChange(event) {
        this.brand = event.detail.recordTypeId;

        this._bodegaManual = false;
        this.applyDefaultBodegaIfNeeded();
    }
}
