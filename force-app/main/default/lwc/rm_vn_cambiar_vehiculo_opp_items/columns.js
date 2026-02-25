export default [
    { 
        label: 'Código',
        fieldName: 'productUrl', 
        type: 'url',
        initialWidth: 200,
        typeAttributes: {label: { fieldName: 'productCode' }, target: '_blank'},
    },
    { label: 'Marca', fieldName: 'productBrand',initialWidth: 120},
    { label: 'Año', fieldName: 'productYear', type: 'text',initialWidth: 80},
    { label: 'Modelo', fieldName: 'productModel',initialWidth: 220},
    { label: 'Vin', fieldName: 'productVin',initialWidth: 200},
    { label: 'Precio', fieldName: 'productUnitPrice', type: 'currency',typeAttributes: { currencyCode: 'USD', alignment: 'right'},initialWidth: 150}
];