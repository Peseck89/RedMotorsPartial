export default [  
    {
        label: 'Caso',
        fieldName: 'caseLink',
        type: 'url',
        initialWidth: 125,
        typeAttributes: {label: { fieldName: 'caseNumber' }, target: '_blank'},
        cellAttributes: { alignment: 'left',
            style: { 
                fieldName: 'cellClass' 
            } 
        }
    },
    {
        label: 'Orden',
        fieldName: 'workOrderLink',
        type: 'url',
        initialWidth: 90,
        typeAttributes: {label: { fieldName: 'workOrderNumber' }, target: '_blank'},
        cellAttributes: { alignment: 'left' ,
            style: { 
                fieldName: 'cellClass' 
            } 
        }
    },
    {
        label: 'Trabajo',
        fieldName: 'trabajoLink',
        type: 'url',
        initialWidth: 170,
        typeAttributes: {label: { fieldName: 'workStepName' }, target: '_blank'},
        cellAttributes: { alignment: 'left',
            style: { 
                fieldName: 'cellClass' 
            } 
        }
    },
    {
        label: 'Subtrabajo',
        fieldName: 'subtrabajoLink',
        type: 'url',
        // initialWidth: 170,
        typeAttributes: {label: { fieldName: 'workStepName' }, target: '_blank'},
        cellAttributes: { alignment: 'left',
            style: { 
                fieldName: 'cellClass' 
            } 
        }
    },
    {
        label: 'HE',
        fieldName: 'totalHorasEstimadas',
        type: 'number',
        title: 'Horas Estimadas',
        cellAttributes: {
            formatter: (cellValue) => formatTime(cellValue),
            alignment: 'right',
            style: { 
                fieldName: 'cellClass' 
            }
        },
        typeAttributes: {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2,
            format: '#,##0.0'
        },
        initialWidth: 100
    },
    {
        label: 'MT',
        fieldName: 'totalMinutosReales',
        type: 'number',
        title: 'Total de minutos trabajados',
        cellAttributes: { 
            formatter: (cellValue) => formatTime(cellValue),
            alignment: 'right',
            style: { 
                fieldName: 'cellClass' 
            }
        },
        typeAttributes: {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2,
            format: '#,##0.0'
        },
        initialWidth: 100
    },
    {
        label: 'Estatus',
        fieldName: 'status',
        type: 'text',
        initialWidth: 100,
        cellAttributes: { 
            alignment: 'center',
            style: {
                fieldName: 'statusCellClass' 
            },
            // class: { fieldName: 'workStepStatusClass' }
        }
    },
    { 
        label: 'Fecha Inicio', 
        fieldName: 'startTime', 
        type: 'date-local' , 
        initialWidth: 100,
        cellAttributes: {
            style: {
                fieldName: 'cellClass' 
            }
        }
    },
    { 
        label: 'Fecha Fin', 
        fieldName: 'endTime', 
        type: 'date-local', 
        initialWidth: 100,
        cellAttributes: {
            style: {
                fieldName: 'cellClass' 
            }
        }
    },
    {
        label: 'Mecánico',
        fieldName: 'mechanicLink',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'mechanicName'}, target: '_blank'
        },
        initialWidth: 150,
        cellAttributes: {
            style: {
                fieldName: 'cellClass' 
            }
        }
    },
    // {
    //     label: 'Taller',
    //     fieldName: 'territoryLink',
    //     type: 'url',
    //     typeAttributes: {
    //         label: { fieldName: 'territoryName' }, target: '_blank'
    //     },
    //     initialWidth: 150,
    //     cellAttributes: {
    //         style: {
    //             fieldName: 'cellClass' 
    //         }
    //     }
    // },
    {
        type: 'action',
        typeAttributes: {
            rowActions: { fieldName: 'actions' },
        },
        cellAttributes: {
            style: {
                fieldName: 'cellClass' 
            }
        }
    }
];