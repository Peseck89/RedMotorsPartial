export default [
    { 
        label: 'Nombre de la Orden',
        fieldName: 'WorkOrderURL', 
        type: 'url',
        typeAttributes: {label: { fieldName: 'WorkOrderNumber' }, target: '_blank'},
    },
    { 
        label: 'Número de caso',
        fieldName: 'CaseURL', 
        type: 'url',
        typeAttributes: {label: { fieldName: 'CaseNumber' }, target: '_blank'},
    },    
    { 
        label: 'Acción',
        fieldName: 'WorkStepURL', 
        type: 'url',
        typeAttributes: {label: { fieldName: 'WorkStepName' }, target: '_blank'},
    },    
    { 
        label: 'Minutos iniciales', 
        fieldName: 'startingMinutes',
        type: 'number', 
        typeAttributes:{
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        }
        // type: 'date', 
        // typeAttributes:{
        //     year: "numeric",
        //     month: "2-digit",
        //     day: "2-digit",
        //     hour: "2-digit",
        //     minute: "2-digit"
        // }
    },
    { 
        label: 'Tiempo transcurridos', 
        fieldName: 'WorkTime'
    },    
    { 
        label: 'Tipo cargo', 
        fieldName: 'tipoCargo'
    },
    { 
        label: 'Fecha OT', 
        fieldName: 'WorkOrderCreationDate',
        type: 'date', 
        typeAttributes:{
            year: "numeric",
            month: "2-digit",
            day: "2-digit",
        }
    },        
    { 
        label: 'Estado', 
        fieldName: 'Status'
    },
    { 
        label: 'Asignado a', 
        fieldName: 'CT_AsignadoA__c'
    },
    { 
        label: 'Trabajo a realizar', 
        fieldName: 'CT_TipoDeTrabajoDelCaso__c'
    }
];