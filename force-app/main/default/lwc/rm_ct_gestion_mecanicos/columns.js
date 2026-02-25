const COLUMNS = [
    {
        label: 'Mecánico',
        fieldName: 'mechanicURL',
        type: 'url',
        initialWidth: 200,
        typeAttributes: {label: { fieldName: 'mechanicName' }, target: '_blank'},
        cellAttributes: { alignment: 'left',
            style: { 
                fieldName: 'cellClass' 
            } 
        }
    },
    {
        label: 'Actividad',
        fieldName: 'nameURL',
        type: 'url',
        initialWidth: 250,
        typeAttributes: {label: { fieldName: 'name' }, target: '_blank'},
        cellAttributes: { alignment: 'left',
            style: {
                fieldName: 'cellClass' 
            }
        }
    },
    {
        label: 'Estatus',
        fieldName: 'status',
        type: 'text',
        initialWidth: 200,
        cellAttributes: { alignment: 'center',
            style: {
                fieldName: 'statusColor' 
            }
        }
    },
    {
        label: 'Taller',
        fieldName: 'tallerName',
        type: 'text',
        initialWidth: 300,
        // typeAttributes: {label: { fieldName: 'tallerName' }, target: '_blank'},
        cellAttributes: { alignment: 'left',
            style: { 
                fieldName: 'cellClass' 
            } 
        }
    }
];
export default COLUMNS;