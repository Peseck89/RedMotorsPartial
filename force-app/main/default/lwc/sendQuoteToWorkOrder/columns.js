export default [
    { 
        label: 'Código', 
        fieldName: 'productCode', 
        type: 'text', 
        editable: false,
        initialWidth: 180
    },
    {
        label: 'Producto',
        fieldName: 'productURL',
        type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'name'
            },
            target: '_blank'
        },
        editable: false,
        initialWidth: 250,
        wrapText: true,
        sortable: false
    },
    { 
        label: 'Precio', 
        fieldName: 'price', 
        type: 'currency', 
        editable: true ,
        typeAttributes: { currencyCode: 'USD', alignment: 'right'},
        initialWidth: 160,
        cellAttributes: {
            style: {
                fieldName: 'backgroudColor' 
            }
        }
    },
    { 
        label: 'Alias', 
        fieldName: 'alias', 
        type: 'text', 
        editable: true,
        initialWidth: 250,
        wrapText: true,
        sortable: false
    },
    { 
        label: 'Disponible', 
        fieldName: 'cantidadDisponible', 
        type: 'number', 
        editable: false,
        initialWidth: 120,
        typeAttributes: { alignment: 'center'}
    },
    { 
        label: 'Cantidad', 
        fieldName: 'cantidad', 
        type: 'number', 
        editable: true,
        initialWidth: 100,
        typeAttributes: { currencyCode: 'USD', alignment: 'center'}
    },
    { 
        label: 'Precio Venta', 
        fieldName: 'precioVenta', 
        type: 'currency', 
        editable: true,
        typeAttributes: { currencyCode: 'USD', alignment: 'right'},
        initialWidth: 160,
        cellAttributes: {
            style: {
                fieldName: 'backgroudColor' 
            }
        }
    },
    { 
        label: 'Bodega', 
        fieldName: 'bodega', 
        type: 'text', 
        editable: false,
        initialWidth: 250,
        wrapText: true,
        sortable: false
    },
    { 
        label: 'Enviado a Orden', 
        fieldName: 'enOrden', 
        type: 'boolean', 
        editable: false,
        initialWidth: 150
    },
    { 
        label: 'Enviar a Caso', 
        fieldName: 'enCaso', 
        type: 'boolean', 
        editable: true,
        initialWidth: 150
    },
];