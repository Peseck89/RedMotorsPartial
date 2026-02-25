export default [
    { 
        label: 'Nombre',
        fieldName: 'productUrl', 
        type: 'url',
        initialWidth: 250,
        typeAttributes: {label: { fieldName: 'productName' }, target: '_blank'},
    },
    { label: 'Modelo', fieldName: 'productModel',initialWidth: 220},
    { label: 'Vin', fieldName: 'productVin',initialWidth: 200},
    { label: 'Color Interno', fieldName: 'productInternalColor', type: 'text',initialWidth: 100},
    { label: 'Color Externo', fieldName: 'productExternalColor', type: 'text',initialWidth: 120},
    // { label: 'Combustible', fieldName: 'productTipoCombustible', type: 'text',initialWidth: 180},
    { label: 'Precio', fieldName: 'productUnitPrice', type: 'currency',typeAttributes: { currencyCode: 'USD', alignment: 'right'},initialWidth: 150},
    { label: 'Bodega', fieldName: 'bodegaName', type: 'text',initialWidth: 200}
];