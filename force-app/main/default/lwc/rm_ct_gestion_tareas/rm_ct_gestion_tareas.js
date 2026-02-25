import { LightningElement,wire } from 'lwc';
import columnsTable from './columns';
import { reduceErrors } from 'c/ldsUtils';
import getData from '@salesforce/apex/RM_CT_GestionTareas_Ctrl.getData';
import reprocesarTrabajoYSubtrabajos from '@salesforce/apex/RM_CT_GestionTareas_Ctrl.reprocesarTrabajoYSubtrabajos';
import deleteTrabajo from '@salesforce/apex/RM_CT_GestionTareas_Ctrl.deleteTrabajo';
import deleteSubtrabajo from '@salesforce/apex/RM_CT_GestionTareas_Ctrl.deleteSubtrabajo';
import asignarMechanico from '@salesforce/apex/RM_CT_GestionTareas_Ctrl.asignarMechanico';
import reasignarMechanico from '@salesforce/apex/RM_CT_GestionTareas_Ctrl.reasignarMechanico';
import updateWorkStepStatus from '@salesforce/apex/RM_CT_GestionTareas_Ctrl.updateWorkStepStatus';
import rm_ct_seleccionar_mecanico from 'c/rm_ct_seleccionar_mecanico';
import rm_confirm_modalbox from 'c/rm_confirm_modalbox';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import searchCases from '@salesforce/apex/RM_CT_GestionTareas_Ctrl.searchCases';
import {getWorkOrderActions, getTrabajoActions, getSubtrabajoActions, getStatusColor } from './rm_ct_gestion_tareas_helper.js';
import { refreshApex } from '@salesforce/apex';
import { subscribe } from 'lightning/empApi';

const columns = columnsTable
export default class Rm_ct_gestion_tareas extends LightningElement {

    columns = columns;

    isLoading = false;
    data = [];
    error;

    // caseNumber = '00012737';

    salesforceURL;

    caseInitialSelection = [
        // {
        //     id:'5006u00000704RSAAY',
        //     sObjectType:'Case',
        //     icon:'case',
        //     title:'00012772',
        //     subtitle:'00012772'
        // }
    ];
    caseId = '5006u000007nFmLAAU';
    caseErrors = [];

    tallerName;
    tallerUrl;

    channelName = '/event/RM_WorkStep__e';
    subscription = [];

    connectedCallback() {
        this.salesforceURL = window.location.origin;
        this.handleSubscribe();
    }

    handleCaseSearch(event) {
        const lookupElement = event.target;
        var params = event.detail;
        params["firedElement"] = 'Caso';
        params["icon"] = 'standard:case';
        params["objName"] = 'Case';
        params["displayedObjName"] = 'Caso';

        searchCases(params)
            .then(results => {
                lookupElement.setSearchResults(results);
            })
            .catch(error => {
                this.caseErrors = error;
            });
    }

    handleCaseSelectionChange(event) {
        console.log('handleCaseSelectionChange');
        this.caseId = '';
        this.data = [];
        if(event.detail && event.detail.length > 0) {
            this.caseId = event.detail[0];
        }
    }

    wiredDataResult;

    //retrieve data
    @wire(getData, { caseId: '$caseId' })
    wiredData(result) {
        this.isLoading = true;
        this.wiredDataResult = result;
        if (result.data) {
            this.data = result.data.map(row => {
                if (row.workOrders) {
                    let newRow = Object.assign({}, row, { _children: row.workOrders });
                    newRow.cellClass = 'background-color: #c9c9c9;';
                    newRow.statusCellClass = 'background-color: #c9c9c9;';
                    newRow.caseLink = `${this.salesforceURL}/${row.id}`;
                    newRow.territoryLink = `${this.salesforceURL}/${row.territoryId}`;
                    this.tallerName = row.territoryName;
                    this.tallerUrl = newRow.territoryLink;

                    delete newRow.workOrders;

                    newRow._children = newRow._children.map(child => {
                        let newRow = Object.assign({}, child, { _children: child.trabajos });
                        newRow.workOrderLink = `${this.salesforceURL}/${child.id}`;
                        newRow.cellClass = 'background-color: #e5e5e5;';
                        newRow.statusCellClass = 'background-color: #e5e5e5;';
                        
                        newRow.actions = getWorkOrderActions(child);

                        delete newRow.trabajos;
                        

                        newRow._children = newRow._children.map(grandchild => {
                            let newRow = Object.assign({}, grandchild, { _children: grandchild.subtrabajos });
                            newRow.trabajoLink = `${this.salesforceURL}/${grandchild.id}`;
                            newRow.cellClass = 'background-color: #f3f3f3;';
                            newRow.statusCellClass = getStatusColor(newRow,true);

                            if(grandchild.mechanicId)
                            newRow.mechanicLink = `${this.salesforceURL}/${grandchild.mechanicId}`;

                            //crea an action for each grandchild, if the status is 'Completada'
                            newRow.actions = getTrabajoActions(grandchild);
                            //     newRow.cellClass += 'color:#aeaeae;';

                            //calculate totalHorasReales base on totalMinutosReales take into account null values, save as decimal value with 2 decimal places
                            // newRow.totalHorasReales = grandchild.totalMinutosReales ? grandchild.totalMinutosReales / 60 : 0;
                            delete newRow.subtrabajos;

                            newRow._children = newRow._children.map(greatgrandchild => {
                                let newRow = Object.assign({}, greatgrandchild);
                                newRow.subtrabajoLink = `${this.salesforceURL}/${greatgrandchild.id}`;
                                newRow.cellClass = 'background-color: white;';
                                newRow.statusCellClass = getStatusColor(greatgrandchild);
                                if(greatgrandchild.mechanicId)
                                newRow.mechanicLink = `${this.salesforceURL}/${greatgrandchild.mechanicId}`;

                                //crea an action for each grandgrandchild, if the status is 'Completada'
                                newRow.actions = getSubtrabajoActions(greatgrandchild,grandchild);
                                // newRow.cellClass += 'color:#aeaeae;';

                                //calculate totalHorasReales base on totalMinutosReales take into account null values, save as decimal value with 2 decimal places
                                newRow.totalHorasReales = greatgrandchild.totalMinutosReales ? greatgrandchild.totalMinutosReales : 0;
                                delete newRow.subtrabajos;
                                return newRow;
                            });
                            return newRow;
                        });
                        return newRow;
                    });
                    return newRow;
                }
                return row;
            });
            // console.log('data', this.data);
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.data = [];
        }
        if(result.data || result.error) {
            this.isLoading = false;
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'reprocesar':
                this.handleReprocessing(row);
                break;
            case 'asignarMecanico':
                    this.handleAsignarMecanico(row);
                break;
            case 'reasignarMecanico':
                this.handleReasignarMecanico(row);
                break;
            case 'eliminar-trabajo':
                this.handleDeleteTrabajo(row);
                break;
            case 'eliminar-subtrabajo':
                this.handleDeleteSubtrabajo(row);
                break;
            case 'iniciar':
                this.hendleUpdateWorkStepStatus(row,'En curso');
                break;
            case 'reanudar':
                this.hendleUpdateWorkStepStatus(row,'En curso');
                break;
            case 'pausar':
                this.hendleUpdateWorkStepStatus(row,'En pausa');
                break;
            case 'completar':
                this.hendleUpdateWorkStepStatus(row,'Completada');
                break;
            default:
                // handle other actions as needed
                break;
        }
    }

    handleDeleteTrabajo(row) {
        this.isLoading = true;
        deleteTrabajo({'ttcId':row.id})
        .then(result => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Eliminar Trabajo',
                    message: 'Se eliminó el trabajo correctamente.',
                    variant: 'success'
                })
            );
            this.handleRefresh();
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Eliminar Trabajo Error',
                    message: reduceErrors(error).join(', '),
                    variant: 'error'
                })
            );
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    handleDeleteSubtrabajo(row) {
        this.isLoading = true;
        deleteSubtrabajo({'sttcId':row.id})
        .then(result => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Eliminar Subtrabajo',
                    message: 'Se eliminó el subtrabajo correctamente.',
                    variant: 'success'
                })
            );
            this.handleRefresh();
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Eliminar Subtrabajo Error',
                    message: reduceErrors(error).join(', '),
                    variant: 'error'
                })
            );
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    hendleUpdateWorkStepStatus(row,status) {
        this.isLoading = true;
        updateWorkStepStatus({'workStepId':row.workStepId, 'status':status})
        .then(result => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Iniciar Trabajo',
                    message: 'Se inicio el trabajo correctamente.',
                    variant: 'success'
                })
            );
            this.handleRefresh();
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Iniciar Trabajo Error',
                    message: reduceErrors(error).join(', '),
                    variant: 'error'
                })
            );
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    handleAsignarMecanico(row) {
        rm_ct_seleccionar_mecanico.open({
            size: 'small'
        })
        .then(selection => {
            //if selection is null, do nothing
            if(!selection || !selection.mechanic) return;

            this.isLoading = true;

            asignarMechanico({'recordId':row.id, 'mechanicId':selection.mechanic})
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Asignar Mecánico',
                        message: 'Se asignó el mecánico correctamente.',
                        variant: 'success'
                    })
                );
                this.handleRefresh();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Asignar Mecánico Error',
                        message: reduceErrors(error).join(', '),
                        variant: 'error'
                    })
                );
            })
            .finally(() => {
                this.isLoading = false;
            });
        })
    }

    handleReasignarMecanico(row) {
        rm_ct_seleccionar_mecanico.open({
            size: 'small'
        })
        .then(selection => {
            //if selection is null, do nothing
            if(!selection || !selection.mechanic) return;

            this.isLoading = true;

            reasignarMechanico({'workStepId':row.workStepId, 'mechanicId':selection.mechanic})
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Reasignar Mecánico',
                        message: 'Se reasignó el mecánico correctamente.',
                        variant: 'success'
                    })
                );
                this.handleRefresh();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Reasignar Mecánico Error',
                        message: reduceErrors(error).join(', '),
                        variant: 'error'
                    })
                );
            })
            .finally(() => {
                this.isLoading = false;
            });
        })
    }

    handleReprocessing(row) {
        //check if the work type is subtrabajo and if the modo trabajo is 'Tarea padre'
        //if so, open the modal box to ask confirmation to reprocess
        // if(row.workType === 'subtrabajo' && row.modoTrabajo == 'Tarea padre') {
        //     rm_confirm_modalbox.open({
        //         size: 'small',
        //         title: 'Reprocesar Subtrabajo',
        //         message: 'El subtrabajo a reprocesar se trabajo a nivel trabajo, por lo que para reprocesarlo, crearemos inicialmente el trabajo y luego el subtrabajo, ¿Está seguro que desea reprocesar este subtrabajo?',
        //     })
        //     .then(selection => {
                // console.log('selection');
                // console.log(selection);
                // if(selection && selection == 'ok') {
                    // let ttcId = row.parentWorkStepId;
                //     console.log('ttcId');
                //     console.log(ttcId);
                //     rm_ct_seleccionar_mecanico.open({
                //         size: 'small'
                //     })
                //     .then(selection => {
                //         //if selection is null, do nothing
                //         if(!selection) return;
                        // this.reprocesarSubtareaYSubtrabajo(ttcId,row.id,undefined);
                    // });
                // }
        //     })
        // }else{
            
        // }

        this.reprocesarTrabajoOSubtrabajo(row);
    }

    reprocesarTrabajoOSubtrabajo(row){
        if(row.workType === 'trabajo') {
            this.reprocesarSubtareaYSubtrabajo(row.id,undefined);
        } else if (row.workType === 'subtrabajo') {
            this.reprocesarSubtareaYSubtrabajo(row.ttcId, row.id);
        }
    }

    reprocesarSubtareaYSubtrabajo(ttcId,sttcId){
        this.isLoading = true;
        reprocesarTrabajoYSubtrabajos({'ttcId':ttcId, 'sttcId':sttcId})
        .then(result => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Reprocesar Trabajo',
                    message: 'Se creo un nuevo registro para el reproceso del trabajo seleccionado.',
                    variant: 'success'
                })
            );
            this.handleRefresh();
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Reprocesar Trabajo Error',
                    message: reduceErrors(error).join(', '),
                    variant: 'error'
                })
            );
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    get defaultExpandedRows() {
        // Recoge todos los IDs de las filas para expandirlas todas por defecto
        let allRowIds = [];
        if(this.data && this.data.length > 0)
        this.data.forEach(row => {
            allRowIds.push(row.id);
            if (row._children) {
                row._children.forEach(child => {
                    allRowIds.push(child.id);
                    if (child._children) {
                        child._children.forEach(grandchild => {
                            allRowIds.push(grandchild.id);
                        });
                    }
                });
            }
        });
        return allRowIds;
    }

    formatTime(minutes) {
        let hours = Math.floor(minutes / 60);
        let remainingMinutes = minutes % 60;
        return `${hours}h ${remainingMinutes}m`;
    }

    handleRefresh() {
        this.isLoading = true;
        return refreshApex(this.wiredDataResult);
    }
    
    handleSubscribe() {
        console.log('Subscribed to channel RM_WorkStep__e gestion tareas');
        const messageCallback = (response) => {
            return refreshApex(this.wiredDataResult);
        };

        subscribe(this.channelName, -1, messageCallback).then(response => {
            this.subscription = response;
        });
    }


    get mostrarDetalle() {
        return this.showResume != undefined && this.showResume;
    }
}