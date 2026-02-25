export default [
    { 
        label: 'VIN', 
        fieldName: 'productVin',
        initialWidth: 320,
        cellAttributes: {
            style: {
                fieldName: 'backgroudColor' 
            }
        }
    },
    { 
        label: 'Modelo', 
        fieldName: 'productModel',
        initialWidth: 350,
        cellAttributes: {
            style: {
                fieldName: 'backgroudColor' 
            }
        }
    },
    { 
        label: 'Color externo', 
        fieldName: 'productExternalColor', 
        type: 'text',
        initialWidth: 310,
        cellAttributes: {
            style: {
                fieldName: 'backgroudColor' 
            }
        }
    }, 
    { 
        label: 'Tapicería', 
        fieldName: 'productInternalColor', 
        type: 'text',
        initialWidth: 100,
        cellAttributes: {
            style: {
                fieldName: 'backgroudColor' 
            }
        }
    },
    { 
        label: 'Precio', 
        fieldName: 'productPriceFantasia', 
        type: 'currency',
        typeAttributes: { currencyCode: 'USD', alignment: 'right'},
        initialWidth: 350,
        cellAttributes: {
            style: {
                fieldName: 'backgroudColor' 
            }
        }
    }
];