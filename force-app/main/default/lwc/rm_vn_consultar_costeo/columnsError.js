export default [
    {
        type: 'action',
        typeAttributes: {
            rowActions: { fieldName: 'actions' },
        },
    },
    { 
        label: 'Nombre',
        fieldName: 'productUrl', 
        type: 'url',
        initialWidth: 250,
        typeAttributes: {label: { fieldName: 'productName' }, target: '_blank'},
    },
    { label: 'Error', fieldName: 'causaError',initialWidth: 100},
    { label: 'Marca', fieldName: 'productBrand',initialWidth: 100},
    { label: 'Modelo', fieldName: 'productModel',initialWidth: 220},
    { label: 'Año', fieldName: 'productYear',initialWidth: 100},
    { label: 'Activo', fieldName: 'isActive', type: 'Boolean',initialWidth: 100},
    { label: 'Es Vehiculo', fieldName: 'esVehiculo', type: 'Boolean',initialWidth: 120},    
    { label: 'Total Monto CR', fieldName: 'sumLocal', type: 'currency',typeAttributes: { currencyCode: 'CRC', alignment: 'right'},initialWidth: 150},
    { label: 'Total Monto USD', fieldName: 'sumDolar', type: 'currency',typeAttributes: { currencyCode: 'USD', alignment: 'right'},initialWidth: 150},
    { label: 'Bodega', fieldName: 'bodegaName', type: 'text',initialWidth: 200},
    { label: 'Días en inventario', fieldName: 'daysInInventory', type: 'number',initialWidth: 200},
];