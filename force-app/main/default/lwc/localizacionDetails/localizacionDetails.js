import { LightningElement, api, track } from 'lwc';
import getSoftlandLocations from "@salesforce/apex/WoliGridController.getSoftlandLocations"
const COLS = [
    { label: 'Articulo', fieldName: 'articulo' },
    { label: 'Bodega', fieldName: 'bodega' },
    { label: 'Localización', fieldName: 'localizacion' },
    { label: 'Cantidad Disponible', fieldName: 'cant_disponible' }
];
export default class LocalizacionDetails extends LightningElement {
    @track locations;
    @api productCode;
    @api empresaFactura;
    columns = COLS;
    
    connectedCallback() {
        this.loadData();
    }
        
    loadData() {
        if (this.productCode) {
            getSoftlandLocations({ productCode: this.productCode, empresaFactura: this.empresaFactura })
                .then(result => {
                    const parsedResult = JSON.parse(result);
                    this.locations = parsedResult.Data;
                    this.error = undefined;
                })
                .catch(error => {
                    this.error = error;
                    this.locations = undefined;
                }
            );
        }
    }
}