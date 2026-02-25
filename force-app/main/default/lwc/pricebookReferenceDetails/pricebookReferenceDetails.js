import { LightningElement, api, track } from 'lwc';
//import getPricebookEntries from "@salesforce/apex/WoliGridController.getPricebookEntries";
import getSoftlandPriceReferences from "@salesforce/apex/WoliGridController.getSoftlandPriceReferences"

const COLS = [
    { label: 'ARTICULO', fieldName: 'ARTICULO' },
    { label: 'PRECIO_CON_IVA', fieldName: 'PRECIO_CON_IVA' },
    { label: 'VOR_DOLAR', fieldName: 'VOR_DOLAR' },
    { label: 'VOR', fieldName: 'VOR' },
    { label: 'MARIT_DOLAR', fieldName: 'MARIT_DOLAR' },
    { label: 'MARI', fieldName: 'MARI' },
    { label: 'AEREO_DOLAR', fieldName: 'AEREO_DOLAR' },
    { label: 'AERE', fieldName: 'AERE' },
    { label: 'PRECIO_EMPLEADO', fieldName: 'PRECIO_EMPLEADO' }
];

export default class PricebookReferenceDetails extends LightningElement {
    //@api recordIds = []; // Expecting a comma-separated list of IDs
    @track pricebookEntries;
    @api productCode;
    @api empresaFactura;
    columns = COLS;

    connectedCallback() {
        console.log(JSON.stringify(this.productCode));
       // console.log(JSON.stringify(this.));
        this.loadData();
    }

    loadData() {
        if (this.productCode) {
            console.log('this.productCode ',this.productCode);
            console.log('this.empresaFactura ',this.empresaFactura);
            //const ids = this.recordIds.split(',').map(id => id.trim());
            getSoftlandPriceReferences({ productCode: this.productCode, empresaFactura: this.empresaFactura })
                .then(result => {
                    console.log(JSON.parse(result));
                    //console.log(JSON.stringify(JSON.parse(result)));
                    this.pricebookEntries = [this.roundDecimalsOptimized(JSON.parse(result))];
                    this.error = undefined;
                })
                .catch(error => {
                    this.error = error;
                    this.pricebookEntries = undefined;
                });
        }
    }

    roundDecimalsOptimized(jsonData) {
        return Object.fromEntries(
            Object.entries(jsonData).map(([key, value]) => [
                key,
                value.includes('.') && !isNaN(value) ? parseFloat(value).toFixed(2) : value
            ])
        );
    }

}