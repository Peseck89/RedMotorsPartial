const CHILD_TASK = 'Tarea hija';
const PARENT_TASK = 'Tarea padre';
const REPROCESSING = 'Reprocesamiento';
const STATUS_NEW = 'Nueva';
const STATUS_IN_PROGRESS = 'En curso';
const STATUS_PAUSED = 'En pausa';
const STATUS_COMPLETED = 'Completada';

export function getWorkOrderActions(workOrder) {
    let actions = [];

    let hasTrabajoSubtrabajoWithoutMechanic = workOrder.trabajos.some(trabajo => !trabajo.mechanicId);

    if(hasTrabajoSubtrabajoWithoutMechanic) {
        actions.push({ label: 'Asignar Mecánico', name: 'asignarMecanico' });
    }

    if(hasTrabajoSubtrabajoWithoutMechanic) {
        actions.push({ label: 'Reasignar Mecánico', name: 'reasignarMecanico' });
    }

    return actions;
}


//create actions for the parent workstep tasks
export function getTrabajoActions(trabajo) {

    let actions = [];
    let allSubWorksAreCompleted = checkIfAllSubtrabajosAreCompleted(trabajo);

    if((trabajo.status === STATUS_COMPLETED || allSubWorksAreCompleted) && trabajo.isReprocessing == 'no') {
        actions.push({ label: 'Reprocesar', name: 'reprocesar' });
    }

    let flagSubtrabajosNotStartedSameMechanic = checkIfAllSubtrabajosAreNewAndAssignedToTheSameMechanic(trabajo);

    if(((!trabajo.modoTrabajo ||  trabajo.modoTrabajo == PARENT_TASK ) && !trabajo.mechanicId) || (!trabajo.mechanicId && flagSubtrabajosNotStartedSameMechanic)) {
        actions.push({ label: 'Asignar Mecánico', name: 'asignarMecanico' });
    }

    if(!trabajo.modoTrabajo || flagSubtrabajosNotStartedSameMechanic || trabajo.modoTrabajo == PARENT_TASK) {
        
        if((!trabajo.status || trabajo.status === STATUS_NEW) && ((trabajo.modoTrabajo == PARENT_TASK && trabajo.mechanicId) || (trabajo.mechanicId && flagSubtrabajosNotStartedSameMechanic))) {
            actions.push({ label: 'Iniciar', name: 'iniciar' });
        }

        if((!trabajo.status || trabajo.status === STATUS_NEW || trabajo.status === STATUS_PAUSED) && trabajo.mechanicId) {
            actions.push({ label: 'Reasignar', name: 'reasignarMecanico' });
        }
        
        let mostrarEnPausa = mismoMecanicoEnCurso(trabajo);

        if((trabajo.status === STATUS_IN_PROGRESS && trabajo.mechanicId) || mostrarEnPausa) {
            actions.push({ label: 'Pausar', name: 'pausar' });
        }
        if(trabajo.status === STATUS_PAUSED && trabajo.mechanicId) {
            actions.push({ label: 'Reanudar', name: 'reanudar' });
        }
        if((trabajo.status === STATUS_IN_PROGRESS || trabajo.status === STATUS_PAUSED) && trabajo.mechanicId) {
            actions.push({ label: 'Completar', name: 'completar' });
        }
    }

    let subtrabajosCompletados = checkIfAllSubtrabajosAreCompleted(trabajo);
    if(trabajo.status === STATUS_NEW && trabajo.isReprocessing == 'si' && !subtrabajosCompletados) {
        actions.push({ label: 'Eliminar', name: 'eliminar-trabajo' });
    }

    return actions;
}

function checkIfAllSubtrabajosAreCompleted(trabajo) {
    let allSubtrabajosAreNew = trabajo.subtrabajos.every(subtrabajo => {
        if(subtrabajo.status && subtrabajo.status === STATUS_COMPLETED) {
            return true;
        }
        return false;
    });
    return allSubtrabajosAreNew;
}

function mismoMecanicoEnCurso(trabajo) {
    let mechanicId;
    let isFirstOne = true;
    let allSubtrabajosAreNew = trabajo.subtrabajos.every(subtrabajo => {
        if(subtrabajo.status && subtrabajo.status === STATUS_IN_PROGRESS) {
            if(isFirstOne) {
                mechanicId = subtrabajo.mechanicId;
                isFirstOne = false;
                return true;
            }
            return mechanicId === subtrabajo.mechanicId;
        }
        return false;
    });
    return allSubtrabajosAreNew;
}

function checkIfAllSubtrabajosAreNewAndAssignedToTheSameMechanic(trabajo) {
    let mechanicId;
    let isFirstOne = true;
    let allSubtrabajosAreNew = trabajo.subtrabajos.every(subtrabajo => {
        if(!subtrabajo.status || subtrabajo.status === STATUS_NEW) {
            if(isFirstOne) {
                mechanicId = subtrabajo.mechanicId;
                isFirstOne = false;
                return true;
            }
            return mechanicId === subtrabajo.mechanicId;
        }
        return false;
    });
    return allSubtrabajosAreNew;
}

//create actions for the child workstep tasks
export function getSubtrabajoActions(subtrabajo,trabajo) {

    let actions = [];

    if(subtrabajo.status === STATUS_COMPLETED && subtrabajo.isReprocessing == 'no') {
        actions.push({ label: 'Reprocesar', name: 'reprocesar' });
    }
    
    if((!subtrabajo.status || subtrabajo.status === STATUS_NEW) && !subtrabajo.mechanicId) {
        actions.push({ label: 'Asignar Mecánico', name: 'asignarMecanico' });
    }
    
    if(subtrabajo.status && subtrabajo.status === STATUS_NEW && subtrabajo.mechanicId && (!subtrabajo.modoTrabajo || subtrabajo.modoTrabajo == CHILD_TASK || !trabajo.status || trabajo.status === STATUS_NEW  || trabajo.status === STATUS_IN_PROGRESS)) {
        actions.push({ label: 'Iniciar', name: 'iniciar' });
    }

    if((!subtrabajo.status || subtrabajo.status === STATUS_NEW || subtrabajo.status === STATUS_PAUSED) && (!subtrabajo.modoTrabajo || subtrabajo.modoTrabajo == CHILD_TASK || !trabajo.status || trabajo.status === STATUS_NEW  || trabajo.status === STATUS_IN_PROGRESS) && subtrabajo.mechanicId) {
        actions.push({ label: 'Reasignar', name: 'reasignarMecanico' });
    }

    if(subtrabajo.status === STATUS_IN_PROGRESS && subtrabajo.mechanicId && (!subtrabajo.modoTrabajo || subtrabajo.modoTrabajo == CHILD_TASK) && (!trabajo.status || trabajo.status === STATUS_NEW || trabajo.status === STATUS_IN_PROGRESS)) {
        actions.push({ label: 'Pausar', name: 'pausar' });
    }

    if(subtrabajo.status === STATUS_PAUSED && subtrabajo.mechanicId && (!subtrabajo.modoTrabajo || subtrabajo.modoTrabajo == CHILD_TASK) && (!trabajo.status || trabajo.status === STATUS_NEW || trabajo.status === STATUS_IN_PROGRESS)) {
        actions.push({ label: 'Reanudar', name: 'reanudar' });
    }
    if((subtrabajo.status === STATUS_IN_PROGRESS || subtrabajo.status === STATUS_PAUSED) && subtrabajo.mechanicId && (!subtrabajo.modoTrabajo || subtrabajo.modoTrabajo == CHILD_TASK)  && (!trabajo.status || trabajo.status === STATUS_NEW || trabajo.status === STATUS_IN_PROGRESS)) {
        actions.push({ label: 'Completar', name: 'completar' });
    }

    if((!subtrabajo.status || subtrabajo.status === STATUS_NEW) && subtrabajo.isReprocessing == 'si') {
        actions.push({ label: 'Eliminar', name: 'eliminar-subtrabajo' });
    }
    
    return actions;
}

export function getStatusColor(row,esTrabajo) {
    let css  = '';
    if(row.status === STATUS_NEW) {
        return 'background-color: #929292;';
    }else if(row.status === STATUS_IN_PROGRESS) {
        return 'background-color: #0070d2;color:white;';
    } else if(row.status === STATUS_PAUSED) {
        return 'background-color: var(--slds-g-color-warning-base-60, #fe9339); color: var(--slds-g-color-neutral-base-10, #181818);';
    } else if(row.status === STATUS_COMPLETED) {
        return 'background-color: var(--slds-g-color-success-base-50, #2e844a);color: var(--slds-g-color-neutral-base-100, #fff);';
    }else {
        return esTrabajo ? 'background-color: #f3f3f3;' : 'background-color: white;';
    }
}