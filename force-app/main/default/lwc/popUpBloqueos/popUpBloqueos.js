import { LightningElement, api, wire, track } from 'lwc';
import getPendingCasesForCurrentOwner from '@salesforce/apex/popUpBloqueClass.getPendingCasesForCurrentOwner';
import isCurrentUserOwnerOf from '@salesforce/apex/popUpBloqueClass.isCurrentUserOwnerOf';
import markTasksAsRead from '@salesforce/apex/popUpBloqueClass.markTasksAsRead';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPendingTasksForCurrentOwner from '@salesforce/apex/popUpBloqueClass.getPendingTasksForCurrentOwner';


export default class PopUpBloqueos extends LightningElement {
    @track pendingTasks = [];
    @api recordId;
    @track showModal = false;
    @track pendingCases = [];
    @track selectedCases = new Set(); // caseId => list of taskIds

    connectedCallback() {
        this.initialize();
    }

    get pendingCasesWithUrls() {
        return this.pendingCases.map(pc => ({
            ...pc,
            caseIdUrl: pc.caseId ? `/lightning/r/Case/${pc.caseId}/view` : null,
            workOrderIdUrl: pc.workOrderId ? `/lightning/r/WorkOrder/${pc.workOrderId}/view` : null
        }));
    }


    async initialize() {
        // try {
        //     const isOwner = await isCurrentUserOwnerOf({ recordId: this.recordId });
            
        //     // if (!isOwner) {
        //     //     return; // No mostrar modal si no es el propietario del Case o WorkOrder
        //     // }

        //     const result = await getPendingCasesForCurrentOwner();
        //     //result = true;
        //     console.log('================ result ================');
        //     console.log(result);
        //     if (result && result.length > 0) {
            
        //         this.pendingCases = result;
        //         this.showModal = true;
        //     }
        // } catch (error) {
        //     console.error('Error initializing PopUpBloqueos:', error);
        // }
        try {
            const tasks = await getPendingTasksForCurrentOwner();
            console.log('TAREAS FORMATEADAS:', tasks);

            if (tasks && tasks.length > 0) {
                this.pendingCases = tasks;
                this.showModal = true;
                console.log('==================== pendingCases ====================');
                console.log(this.pendingCases[0]);
            }
        } catch (e) {
            console.error(e);
        }
    }

    handleClose() {
        this.showModal = false;
    }

    handleCheckboxChange(event) {
        console.log('En handleCheckboxChange');
        const caseId = event.target.dataset.taskid;

        const checked = event.target.checked;
        console.log( checked);
        if (checked) {
            // Busca la lista de taskIds asociadas a este Case
            console.log('En selecciones');
            console.log(caseId);
            console.log(this.pendingCases);
            console.log(this.selectedCases);
            const selected = this.pendingCases.find(pc => pc.taskId === caseId);
            console.log(selected);
            if (selected) {
                this.selectedCases.add(caseId);
            }
            //this.selectedCases.delete(caseId);
        }
    }

    async handleConfirmRead() {
        if (this.selectedCases.size === 0) {
            this.showToast('Atención', 'Debes seleccionar al menos un caso para confirmar lectura.', 'warning');
            return;
        }

        try {
            // Obtener todos los taskIds de los casos seleccionados
            let taskIdsToUpdate = [];
            for (let caseId of this.selectedCases) {
                const caseItem = this.pendingCases.find(pc => pc.taskId === caseId);
                if (caseItem && caseItem.taskIds) {
                    taskIdsToUpdate = taskIdsToUpdate.concat(caseItem.taskIds);
                }
            }
            console.log('****************** taskIdsToUpdate ***********************');
            const updatedCount = await markTasksAsRead({ taskIds: [...this.selectedCases] });

            this.showToast(
                'Confirmación registrada',
                `${updatedCount} tarea(s) marcada(s) como leídas.`,
                'success'
            );

            // Filtra los casos ya confirmados
            this.pendingCases = this.pendingCases.filter(pc => !this.selectedCases.has(pc.taskId));
            this.selectedCases.clear();

            // Cerrar modal si ya no hay pendientes
            if (this.pendingCases.length === 0) {
                this.showModal = false;
            }
        } catch (error) {
            console.error('Error al actualizar tareas:', error);
            this.showToast('Error', 'No se pudieron actualizar las tareas.', 'error');
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            })
        );
    }
}