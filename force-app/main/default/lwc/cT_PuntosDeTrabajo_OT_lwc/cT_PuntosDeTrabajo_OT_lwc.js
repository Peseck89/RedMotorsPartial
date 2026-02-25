import { LightningElement, track, api } from 'lwc';
import getWorkOrderDetails from '@salesforce/apex/ct_otRedis_ctrl.getWorkOrderDetails';

export default class CT_PuntosDeTrabajo_OT_lwc extends LightningElement {
    @track groupedItems = [];
    @track totalAmount = 0;
    @track isLoading = false;

    connectedCallback() {
        this.fetchWorkOrderDetails();
    }

    fetchWorkOrderDetails() {
        this.isLoading = true;

        // Extract WorkOrderId from the URL
        const url = window.location.href;
        const workOrderIdMatch = url.match(/\/WorkOrder\/([a-zA-Z0-9]{18})/);

        if (workOrderIdMatch && workOrderIdMatch[1]) {
            const workOrderId = workOrderIdMatch[1];
            console.log('WorkOrderId:', workOrderId);

            getWorkOrderDetails({ woId: workOrderId })
                .then((result) => {
                    if (result && result.workOrderLineItems) {
                        console.log('result');
                        console.log(result);
                        let groupedMap = {};
                        let totalAmount = 0;

                        // Process WorkOrderLineItems
                        result.workOrderLineItems.forEach((item) => {
                            const groupName = item.tiposDeTrabajo__r?.Name || 'General';
                            if (!groupedMap[groupName]) {
                                groupedMap[groupName] = {
                                    title: groupName,
                                    currencyIso: item.WorkOrder.CurrencyIsoCode,
                                    groupTotal: 0,
                                    items: [],
                                };
                            }

                            // Extract Tipo_de_Cargo_Formula__c from related tipoCargos__r records
                            let tipoDeCargoFormulas = [];
                            if (item.tipoCargos__r && item.tipoCargos__r.length > 0) {
                                tipoDeCargoFormulas = item.tipoCargos__r.map(
                                    (tipoCargo) => tipoCargo.Tipo_de_Cargo_Formula__c
                                );
                            }

                            const itemPrice = parseFloat(item.TotalPrice) || 0;
                            groupedMap[groupName].groupTotal += itemPrice;
                            totalAmount += itemPrice;
                            //let uts = subTrabajo.Cantidad_de_horas__c * 12;
                            groupedMap[groupName].items.push({
                                name: item.Producto_OR_Alias__c,
                                bmwCodigoProducto: item.BMW_CodigoDeProducto__c,
                                tipoDeCargo: tipoDeCargoFormulas.join(', '), // Join multiple formulas if applicable
                                quantity: item.Quantity,
                                //horas: item.Cantidad_de_horas__c,
                                //uts: uts,
                                totalPrice: itemPrice.toLocaleString("es-US", {
                                    minimumFractionDigits: 0,
                                    maximumFractionDigits: 2,
                                }),
                                currencyIso: item.WorkOrder.CurrencyIsoCode,
                            });
                        });

                        // Prepare grouped items
                        this.groupedItems = Object.values(groupedMap).map((group) => ({
                            ...group,
                            groupTotal: group.groupTotal.toLocaleString("es-US", {
                                minimumFractionDigits: 0,
                                maximumFractionDigits: 2,
                            })
                        }));

                        // Update total amount
                        this.totalAmount = totalAmount.toLocaleString("es-US", {
                            minimumFractionDigits: 0,
                            maximumFractionDigits: 2,
                        })
                    }
                    this.isLoading = false;
                })
                .catch((error) => {
                    console.error('Error fetching WorkOrder details:', error);
                    this.isLoading = false;
                });
        } else {
            console.error('WorkOrderId not found in the URL');
            this.isLoading = false;
        }
    }
}