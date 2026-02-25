export default [
    { 
        label: 'Modelo',
        fieldName: 'productUrl', 
        type: 'url',
        initialWidth: 250,
        typeAttributes: {label: { fieldName: 'productModel' }, target: '_blank'},
    },
    { label: 'Marca', fieldName: 'productBrand',initialWidth: 100},
    { label: 'Familia', fieldName: 'productFamilia',initialWidth: 100},
    { label: 'Año', fieldName: 'productYear',initialWidth: 100},
    { label: 'Precio', fieldName: 'unitPrice', type: 'currency',typeAttributes: { currencyCode: { fieldName: 'currencyCode' }, alignment: 'right'},initialWidth: 150}
];