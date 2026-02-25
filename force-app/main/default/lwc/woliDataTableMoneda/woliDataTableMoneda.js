import { LightningElement, api, wire } from 'lwc';
import getWorkOrderLineItems from '@salesforce/apex/CalcularWolisTipoCambio.getWorkOrderLineItems';

export default class FlowDatatableWoli extends LightningElement {
    @api workOrderLineItemIds;  // Recibe una cadena de IDs
    @api tipoCambio;  // Tipo de cambio en formato String
    @api moneda;  // Moneda enviada desde el Flow
    lineItems = [];
    totalGeneral = 0;
    error;

    // Columnas para la tabla
    columns = [
        { label: 'Código de Artículo', fieldName: 'codigoArticulo' },
        { label: 'Nombre', fieldName: 'nombre' },
        { label: 'Cantidad', fieldName: 'cantidad' },
        { label: 'Monto Calculado', fieldName: 'montoCalculado' }
    ];
    get monedaInvertida() {
        return this.moneda === 'USD' ? 'CRC' : 'USD';
    }
    get processedWorkOrderLineItemIds() {
        if (this.workOrderLineItemIds) {
            return this.workOrderLineItemIds.split(',')
                .map(id => id.trim())
                .filter(id => id.length > 0);
        }
        return [];
    }

    @wire(getWorkOrderLineItems, { 
        workOrderLineItemIds: '$processedWorkOrderLineItemIds',
        tipoCambio: '$tipoCambio',
        moneda: '$monedaInvertida'
    })
    wiredLineItems({ error, data }) {
        console.log('tipoCambio ',this.tipoCambio);
        console.log('moneda ',this.moneda);
        console.log('data ',data);

        if (data) {
            console.log('### Datos recibidos en LWC:', JSON.stringify(data)); // Depuración

            let monedaDestino = this.moneda || 'CRC'; // Si no viene, usar un valor por defecto
            console.log('data.monedaDestino ',data.monedaDestino);

            this.lineItems = data.lineItems.map(item => {
                const formatter = new Intl.NumberFormat('es-CR', { 
                    minimumFractionDigits: 2, 
                    maximumFractionDigits: 2 
                });

                return {
                    ...item,
                    montoCalculado: `${monedaDestino} ${formatter.format(parseFloat(item.montoCalculado))}`
                };
            });

            const formatter = new Intl.NumberFormat('es-CR', { 
                minimumFractionDigits: 2, 
                maximumFractionDigits: 2 
            });

            this.totalGeneral = `${monedaDestino} ${formatter.format(parseFloat(data.totalGeneral))}`;
            this.error = undefined;
        } else if (error) {
            console.error('### Error en la llamada a Apex:', error);
            this.error = JSON.stringify(error);
            this.lineItems = [];
            this.totalGeneral = 0;
        }
    }

}