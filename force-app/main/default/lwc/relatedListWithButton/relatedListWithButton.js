import { LightningElement, api, wire } from 'lwc';
import getRecords from '@salesforce/apex/RelatedListController.getRecords';
import getUserInfoLW from '@salesforce/apex/RelatedListController.getUserInfo';
import getML from '@salesforce/apex/RelatedListController.getMecLider';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { deleteRecord } from 'lightning/uiRecordApi';
import { reduceErrors } from 'c/ldsUtils';
import { RefreshEvent } from "lightning/refresh";

export default class RelatedListWithButton extends LightningElement  {
    @api recordId;
    
    profileName;
    emailUser;
    idUser;
    isML;
    isSupervisor;

    isModalOpen = false;

   recordIdNota = null;

    objectApiName = "NotaTecnica__c";   // Objeto hijo
    fields = "";          
    title = 'Notas Técnicas';
    
    readOnly = false;

    editMecLider = false;

    generoPresupuesto = false;

    reqPrueba = false;

    mecLiderName = "";

    idTec = "";

    viewCaseOwner = false;

    btnNewDisable = false;

    records = [];
    columns = [];
    // Agregamos columna de acciones para botón
    actionColumn = {
        label: 'Nota',
        type: 'button',
        typeAttributes: {
            label: 'Ver Nota',
            name: 'view',
            title: 'Ver registro',
            variant: 'brand'
        }
    };

    actionColumnDelete = {
        label: 'Borrar',
        type: 'button',
        typeAttributes: {
            label: 'Borrar',
            name: 'delete',
            title: 'Borrar registro',
            variant: 'destructive'
        }
    };



    @wire(getRecords, {
        parentId: '$recordId',
        objectApi: '$objectApiName',
        fields: '$fields'
    })
    wired(result) {
        if (result.data) {
            this.records = result.data;
        } else if (result.error) {
            console.log("error kev");
            console.error(result.error);
        }
    }


    connectedCallback() {
        getUserInfoLW ()
        .then(result => {
            console.log("result getUserInfoLW " + JSON.stringify(result));
             this.profileName = result.Profile.Name;
             this.emailUser = result.Email;
             this.idUser = result.Id;
             this.isML = result.PN_EsMecanicoLider__c;
             this.isSupervisor = result.PN_EsSupervisorNT__c;

             // Construye columnas dinámicamente y agrega botón al final
            console.log("nombre perfilassas : " + this.profileName);
            console.log("is Supervisor : " + this.isSupervisor);
            console.log("is ML : " + this.isML);

            this.fields = "NombreTecnicoFx__c,MecanicoLiderFx__c,CreatedDate,EstadoPresupuestoFx__c,Nota__c,FechaHoraAprobacion__c,PN_NombreAprobadorFx__c";

            let fieldLabels = ['Tecnico','Mecanico Lider','Fecha de Creacion','Presupuesto','Nota','Fecha y Hora', 'Aprobado por:'];
            

           let fieldsApi = this.fields.split(',');

            console.log("fieldsApi " + fieldsApi);

            let columnas = [];


            for (let i = 0; i < fieldsApi.length; i++) {
                let field = fieldsApi[i];
                let label = fieldLabels[i];

                // Si es el campo de fecha y hora
                if (field === 'FechaHoraAprobacion__c' || field === 'CreatedDate') {
                    columnas.push({
                        label: label,
                        fieldName: field,
                        type: 'date',
                        typeAttributes: {
                            day: '2-digit',
                            month: '2-digit',
                            year: 'numeric',
                            hour: '2-digit',
                            minute: '2-digit',
                            hour12: false,
                            timeZone: 'America/Mexico_City'
                        }
                    });
                } else {
                    columnas.push({ label: label, fieldName: field });
                }
            }

            console.log("columnas " + columnas);

            this.columns = columnas;
             
            //this.columns.push({label: 'Aprobado por: ', fieldName: 'MecanicoLiderFx__c'});
            this.columns.push(this.actionColumn);

            //if(this.profileName == "Mecanico Lider" || this.profileName == "Asesor de Taller V2" || this.profileName == "Asesor de Taller"){
            if(this.isML){
               this.btnNewDisable = true;
               this.columns.push(this.actionColumnDelete);
            } 
            
            if(this.isSupervisor){
                this.btnNewDisable = true;
                
            } 


        })
        .catch(error => {
            console.log("error getUserInfoLW");
            console.error(error);
        });


        
    }

    /** Botones superiores **/
    handleNew() {
        console.log('Nuevo registro');
    }
    handleImport() {
        console.log('Importar registros');
    }
    handleViewAll() {
        console.log('Ver todos');
    }

    /** Acción del botón de la fila **/
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'view') {
            // Aquí puedes navegar al registro o mostrar un modal
            console.log('Ver registro Id: ' + row.Id);
            console.log('Ver registro case owner: ' + row.Case__r.OwnerId);
            console.log('Ver registro this.profileName4434: ' + this.profileName);
            

            this.generoPresupuesto = row.GeneroPresupuesto__c;

            //if(this.profileName == "Mecanico Lider" || this.profileName == "Asesor de Taller V2" || this.profileName == "Asesor de Taller"){
            if(this.isML){
                console.log("entra ML23");
                this.recordIdNota = row.Id;
                this.readOnly = false;
                this.editMecLider = true;
                this.openModal();
            }
            else if(this.isSupervisor  || this.idUser == row.Case__r.OwnerId){
                console.log("entra CaseO");
                this.recordIdNota = row.Id;
                this.readOnly = true;
                this.viewCaseOwner = true;
                this.openModal();
            }
            else{
                console.log("entra nywhere");
                this.recordIdNota = row.Id;
                this.readOnly = true;
                this.openModal();
            }
        } else if(actionName === 'delete'){
            this.deleteRecord(row.Id);
        }
    }

    async deleteRecord(id) {
        

        try {
            await deleteRecord(id);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Nota Eliminada',
                    variant: 'success'
                })
            );
            //await refreshApex(this.lsTrabajos);
            //this.beginRefresh();
            window.location.reload();
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error deleting record',
                    message: reduceErrors(error).join(', '),
                    variant: 'error'
                })
            );
        }
    }

    beginRefresh() {
        this.dispatchEvent(new RefreshEvent());
    }


    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.readOnly = false;
        this.recordIdNota = null;
        this.isModalOpen = false;
        this.editMecLider = false;
        this.generoPresupuesto = false;
        this.viewCaseOwner = false;
    }

    submitForm() {
        this.template.querySelector('lightning-record-edit-form').submit();
    }

    handleSuccess(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Registro creado',
                message: 'Id: ' + event.detail.id,
                variant: 'success'
            })
        );
        this.closeModal();
        window.location.reload();
    }

    handlePruebaChange(event) {
        this.reqPrueba = event.detail.value;
    }

    handleTecnicoChange(event) {
        //this.reqPrueba = event.detail.value;
        
        this.idTec = event.detail.value;

        console.log("idTec " + JSON.stringify(this.idTec));

        console.log(typeof this.idTec);

        if(this.idTec != null && this.idTec != "" && this.idTec != []){
            getML({idTecnico: String(this.idTec)})
                .then(result => {
                    console.log("result ML " + result);
                    this.mecLiderName = result;
                })
                .catch(error => {
                    console.log("error get ML");
                    console.error(error);
                });
        } else {
            this.mecLiderName = "";
        }
            
        
    }
}