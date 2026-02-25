export default [
    { 
        label: 'Pedido', 
        fieldName: 'numeroPedido', 
        type: 'text',
        initialWidth: 200,
        cellAttributes: {
            style: {
                fieldName: 'backgroudColor' 
            }
        }
    },
    { 
        label: 'VIN', 
        fieldName: 'productVin',
        initialWidth: 200,
        cellAttributes: {
            style: {
                fieldName: 'backgroudColor' 
            }
        }
    },
    { 
        label: 'Modelo', 
        fieldName: 'productModel',
        initialWidth: 220,
        cellAttributes: {
            style: {
                fieldName: 'backgroudColor' 
            }
        }
    },
    { 
        label: 'Color Exter', 
        fieldName: 'productExternalColor', 
        type: 'text',
        initialWidth: 180,
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
        initialWidth: 250,
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
        label: 'Equipamiento', 
        fieldName: 'codigoEquipamiento', 
        type: 'text',
        initialWidth: 200,
        cellAttributes: {
            style: {
                fieldName: 'backgroudColor' 
            }
        }
    },
    { 
        label: 'Ubicación', 
        fieldName: 'bodegaName', 
        type: 'text',
        initialWidth: 200,
        cellAttributes: {
            style: {
                fieldName: 'backgroudColor' 
            }
        }
    },
    { 
        label: 'Nombre',
        fieldName: 'productUrl', 
        type: 'url',
        initialWidth: 250,
        typeAttributes: {label: { fieldName: 'productName' }, target: '_blank'},
        cellAttributes: {
            style: {
                fieldName: 'backgroudColor' 
            }
        }
    },
    // { 
    //     label: 'Color', 
    //     fieldName: 'productInternalColor', 
    //     type: 'text',
    //     initialWidth: 100,
    //     cellAttributes: {
    //         style: {
    //             fieldName: 'backgroudColor' 
    //         }
    //     }
    // },
    { 
        label: 'Fecha de Ingreso', 
        fieldName: 'fechaIngresoTransito', 
        type: 'text',
        initialWidth: 250,
        cellAttributes: {
            style: {
                fieldName: 'backgroudColor' 
            }
        }
    },
    { 
        label: 'Días en inventario', 
        fieldName: 'noDiasInventario', 
        type: 'text',
        initialWidth: 200,
        cellAttributes: {
            style: {
                fieldName: 'backgroudColor' 
            }
        }
    },
    { 
        label: 'Combustible', 
        fieldName: 'productTipoCombustible', 
        type: 'text',
        initialWidth: 180,
        cellAttributes: {
            style: {
                fieldName: 'backgroudColor' 
            }
        }
    },
    { 
        label: 'Reportado', 
        fieldName: 'reportado', 
        type: 'boolean',
        initialWidth: 150,
        cellAttributes: {
            style: {
                fieldName: 'backgroudColor' 
            }
        }
    },
    { 
        label: 'Comentario', 
        fieldName: 'comentario', 
        type: 'text',
        initialWidth: 200,
        cellAttributes: {
            style: {
                fieldName: 'backgroudColor' 
            }
        }
    }
];