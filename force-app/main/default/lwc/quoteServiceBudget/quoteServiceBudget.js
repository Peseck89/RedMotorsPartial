// quoteServiceBudget.js
import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getQuoteLineItems from '@salesforce/apex/QuoteServiceController.getQuoteLineItems';
import updateQuoteLineItems from '@salesforce/apex/QuoteServiceController.updateQuoteLineItems';

export default class QuoteServiceBudget extends LightningElement {
    @api recordId; // Quote ID
    
    @track quoteLineItems = [];
    @track selectedRows = [];
    @track groupedItems = [];
    @track isLoading = false;
    @track isSending = false;
    @track showStep1 = true;
    @track showStep2 = false;
    @track currencyIsoCode = 'USD';

    columns = [
        { label: 'Tarea', fieldName: 'tareaName', type: 'text' },
        { label: 'Producto', fieldName: 'productName', type: 'text' },
        { label: 'Cantidad', fieldName: 'Quantity', type: 'number' },
        { 
            label: 'Precio Unitario', 
            fieldName: 'UnitPrice', 
            type: 'currency', 
            typeAttributes: { 
                currencyCode: { fieldName: 'currencyIsoCode' },
                minimumFractionDigits: 2 
            } 
        },
        { 
            label: 'Total', 
            fieldName: 'TotalPrice', 
            type: 'currency', 
            typeAttributes: { 
                currencyCode: { fieldName: 'currencyIsoCode' },
                minimumFractionDigits: 2 
            } 
        },
        { label: 'Tipo', fieldName: 'BMW_TipoDeArticulo__c', type: 'text' }
    ];

    @wire(getRecord, { recordId: '$recordId', fields: ['Quote.CurrencyIsoCode'] })
    wiredQuote({ error, data }) {
        if (data) {
            this.currencyIsoCode = data.fields.CurrencyIsoCode.value;
            // Actualizar columnas con la moneda correcta
            this.updateCurrencyColumns();
        } else if (error) {
            console.error('Error loading quote:', error);
        }
    }

    get isNextDisabled() {
        return this.selectedRows.length === 0;
    }

    connectedCallback() {
        this.loadQuoteLineItems();
    }

    updateCurrencyColumns() {
        this.columns = [
            { label: 'Tarea', fieldName: 'tareaName', type: 'text' },
            { label: 'Producto', fieldName: 'productName', type: 'text' },
            { label: 'Cantidad', fieldName: 'Quantity', type: 'number' },
            { 
                label: 'Precio Unitario', 
                fieldName: 'UnitPrice', 
                type: 'currency', 
                typeAttributes: { 
                    currencyCode: this.currencyIsoCode,
                    minimumFractionDigits: 2 
                } 
            },
            { 
                label: 'Total', 
                fieldName: 'TotalPrice', 
                type: 'currency', 
                typeAttributes: { 
                    currencyCode: this.currencyIsoCode,
                    minimumFractionDigits: 2 
                } 
            },
            { label: 'Tipo', fieldName: 'BMW_TipoDeArticulo__c', type: 'text' }
        ];
    }

    async loadQuoteLineItems() {
        this.isLoading = true;
        try {
            const result = await getQuoteLineItems({ quoteId: this.recordId });
            
            this.quoteLineItems = result.map(item => ({
                ...item,
                tareaName: item.TrabajoARealizar__r?.Name || item.Tarea__c || 'Sin Tarea',
                productName: item.Product2?.Name || 'Sin Producto',
                Id: item.Id,
                currencyIsoCode: this.currencyIsoCode
            }));
            
        } catch (error) {
            console.error('Error loading quote line items:', error);
            this.showToast('Error', 'Error al cargar los items de cotización', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
    }

    handleNext() {
        // Agrupar items seleccionados por tarea
        this.groupSelectedItems();
        this.showStep1 = false;
        this.showStep2 = true;
    }

    handleBack() {
        this.showStep1 = true;
        this.showStep2 = false;
    }

    formatCurrency(amount) {
        return new Intl.NumberFormat('es-US', {
            style: 'currency',
            currency: this.currencyIsoCode,
            minimumFractionDigits: 2
        }).format(amount || 0);
    }

    groupSelectedItems() {
        const grouped = {};
        
        this.selectedRows.forEach(item => {
            const tareaKey = item.TrabajoARealizar__c || item.Tarea__c || 'general';
            
            if (!grouped[tareaKey]) {
                grouped[tareaKey] = {
                    key: tareaKey,
                    nombreTarea: item.TrabajoARealizar__r?.Name || item.Tarea__c || 'Tarea General',
                    items: [],
                    totalTarea: 0,
                    totalTareaFormatted: ''
                };
            }
            
            // Formatear los valores de cada item
            const formattedItem = {
                ...item,
                unitPriceFormatted: this.formatCurrency(item.UnitPrice),
                totalPriceFormatted: this.formatCurrency(item.TotalPrice)
            };
            
            grouped[tareaKey].items.push(formattedItem);
            grouped[tareaKey].totalTarea += item.TotalPrice || 0;
        });
        
        // Formatear el total de cada bloque
        Object.values(grouped).forEach(bloque => {
            bloque.totalTareaFormatted = this.formatCurrency(bloque.totalTarea);
        });
        
        this.groupedItems = Object.values(grouped);
    }

    async handleSendToService() {
        this.isSending = true;
        try {
            const itemIds = this.selectedRows.map(item => item.Id);
            
            await updateQuoteLineItems({ 
                quoteLineItemIds: itemIds,
                sendToService: true
            });
            
            this.showToast('Éxito', 'Tareas enviadas a BMW Service correctamente', 'success');
            
            // Resetear el componente
            this.showStep1 = true;
            this.showStep2 = false;
            this.selectedRows = [];
            this.groupedItems = [];
            
        } catch (error) {
            console.error('Error sending to service:', error);
            this.showToast('Error', 'Error al enviar tareas a service: ' + error.body?.message, 'error');
        } finally {
            this.isSending = false;
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}