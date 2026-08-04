import { LightningElement, api, track, wire } from 'lwc';
import getSoftlandPriceReferences from '@salesforce/apex/WoliGridController.getSoftlandPriceReferences';
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import PROFILE_NAME from '@salesforce/schema/User.Profile.Name';

const BASE_COLS = [
    { label: 'ARTICULO', fieldName: 'ARTICULO' },
    { label: 'PRECIO_CON_IVA', fieldName: 'PRECIO_CON_IVA' },
    { label: 'VOR_DOLAR', fieldName: 'VOR_DOLAR' },
    { label: 'VOR', fieldName: 'VOR' },
    { label: 'AEREO_DOLAR', fieldName: 'AEREO_DOLAR' },
    { label: 'AERE', fieldName: 'AERE' },
    { label: 'PRECIO_EMPLEADO', fieldName: 'PRECIO_EMPLEADO' }
];

const FECHA_COL = { label: 'FECHA', fieldName: 'FECHA' };

export default class PricebookReferenceDetails extends LightningElement {
    @track pricebookEntries = [];
    @track error;

    @api productCode;
    @api empresaFactura;

    @track isAdminProfile = false;
    profileName;

    columns = [...BASE_COLS];

    @wire(getRecord, { recordId: USER_ID, fields: [PROFILE_NAME] })
    userProfileWire({ error, data }) {
        if (data) {
            const pName = data.fields?.Profile?.value?.fields?.Name?.value;
            this.profileName = pName;
            this.isAdminProfile = !!pName && pName.toLowerCase().includes('admin');
            this.buildColumns();
        } else if (error) {
            this.isAdminProfile = false;
            this.buildColumns();
        }
    }

    connectedCallback() {
        this.loadData();
    }

    @api
    refresh() {
        this.loadData();
    }

    buildColumns() {
        this.columns = this.isAdminProfile ? [...BASE_COLS, FECHA_COL] : [...BASE_COLS];
    }

    loadData() {
        if (!this.productCode) {
            this.pricebookEntries = [];
            return;
        }

        getSoftlandPriceReferences({
            productCode: this.productCode,
            empresaFactura: this.empresaFactura
        })
            .then(result => {
                const parsed = JSON.parse(result);

                if (parsed?.operationResult && parsed.operationResult.code && parsed.operationResult.code !== '0') {
                    this.pricebookEntries = [];
                    this.error = parsed.operationResult.description || 'Error consultando precios en Softland.';
                    return;
                }

                const normalizedRow = this.normalizeRow(parsed);
                this.pricebookEntries = [normalizedRow];
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.pricebookEntries = [];
            });
    }

    normalizeRow(row) {
        const normalized = { ...(row || {}) };

        const decimalFields = [
            'PRECIO_CON_IVA',
            'VOR_DOLAR',
            'VOR',
            'AEREO_DOLAR',
            'AERE',
            'PRECIO_EMPLEADO',
            'MARIT_DOLAR',
            'MARI',
            'PRECIO_FOB'
        ];

        decimalFields.forEach(field => {
            normalized[field] = this.formatDecimal(normalized[field]);
        });

        if (this.isAdminProfile) {
            normalized.FECHA = normalized.FECHA ? String(normalized.FECHA) : 'N/A';
        } else {
            delete normalized.FECHA;
        }

        return normalized;
    }

    formatDecimal(value) {
        if (value === null || value === undefined || value === '') {
            return '';
        }

        const num = Number(value);
        return Number.isFinite(num) ? num.toFixed(2) : value;
    }
}
