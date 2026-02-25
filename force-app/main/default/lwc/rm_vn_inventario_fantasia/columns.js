export default [
    { 
        label: 'Modelo',
        fieldName: 'productUrl', 
        type: 'url',
        initialWidth: 250,
        typeAttributes: {label: { fieldName: 'productModel' }, target: '_blank'},
    },
    // { label: 'Modelo', fieldName: 'productModel',initialWidth: 220},
    { label: 'Precio', fieldName: 'unitPrice', type: 'currency',typeAttributes: { currencyCode: { fieldName: 'currencyCode' }, alignment: 'right'},initialWidth: 150}
];