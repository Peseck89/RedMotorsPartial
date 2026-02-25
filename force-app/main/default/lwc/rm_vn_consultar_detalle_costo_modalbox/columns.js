export default [
    { label: 'Linea', fieldName: 'linea',initialWidth: 100},
    { 
        label: 'Nombre',
        fieldName: 'name', 
        // type: 'url',
        initialWidth: 100,
        // typeAttributes: {label: { fieldName: 'name' }, target: '_blank'},
    },
    { label: 'Rubro', fieldName: 'rubro'},
    { label: 'Monto USD', fieldName: 'dollarAmount', type: 'currency',typeAttributes: { currencyCode: 'USD', alignment: 'right'},initialWidth: 150},
    { label: 'Monto CR', fieldName: 'colonAmount', type: 'currency',typeAttributes: { currencyCode: 'CRC', alignment: 'right'},initialWidth: 150}
];