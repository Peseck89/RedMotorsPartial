import { LightningElement, api, wire } from 'lwc';
import getGroupedLineItems from '@salesforce/apex/WorkOrderLinesController.getGroupedLineItems';

export default class FlowDatatableWoli extends LightningElement {
    @api workOrderLineItemIds;  // Receives a comma-separated string of IDs
    lineItems = [];
    totalGeneral = 0; // To store the overall total
    error;

    // Column definitions for the table
    columns = [
        { label: 'Código de Artículo', fieldName: 'codigoArticulo' },
        { label: 'Nombre', fieldName: 'nombre' },
        { label: 'Cantidad', fieldName: 'cantidad' },
        { label: 'Monto', fieldName: 'monto' },
        { label: 'Precio a facturar', fieldName: 'precioConDescuento' }
    ];

    get processedWorkOrderLineItemIds() {
        if (this.workOrderLineItemIds) {
            return this.workOrderLineItemIds.split(',')
                .map(id => id.trim())
                .filter(id => id.length > 0);  // Ensures no empty strings
        }
        return [];
    }

    @wire(getGroupedLineItems, { workOrderLineItemIds: '$processedWorkOrderLineItemIds' })
    wiredLineItems({ error, data }) {
        if (data) {
            let totalGeneralSum = 0; // Initialize total general sum

            // Format each line item to include currency and limit to 2 decimal places
            this.lineItems = data.map(trabajoGroup => {
                const totalTrabajoFormatted = parseFloat(trabajoGroup.totalTrabajo).toFixed(2);
                totalGeneralSum += parseFloat(totalTrabajoFormatted); // Accumulate totalTrabajo to total general
                
                return {
                    ...trabajoGroup,
                    items: trabajoGroup.items.map(item => ({
                        ...item,
                        monto: `${trabajoGroup.currency} ${parseFloat(item.monto).toFixed(2)}`,
                        precioConDescuento: `${trabajoGroup.currency} ${parseFloat(item.precioConDescuento).toFixed(2)}`
                    })),
                    totalTrabajo: `${trabajoGroup.currency} ${totalTrabajoFormatted}`
                };
            });
            
            // Store the final total general with currency
            this.totalGeneral = `${data[0].currency} ${totalGeneralSum.toFixed(2)}`;
            this.error = undefined;
        } else if (error) {
            this.error = JSON.stringify(error);
            this.lineItems = [];
            this.totalGeneral = 0;
        }
    }
}