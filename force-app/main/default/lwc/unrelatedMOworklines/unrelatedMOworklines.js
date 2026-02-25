import { LightningElement, api, track, wire } from 'lwc';
import getNoRelatedMOs from '@salesforce/apex/NorelatedMOdatatableController.getNoRelatedMOs';
import getWorkTypeName from '@salesforce/apex/NorelatedMOdatatableController.getWorkTypeName';
import saveUnrelatedMOs from '@salesforce/apex/NorelatedMOdatatableController.saveUnrelatedMOs';
import getCaseWorkTypesNotStarted from '@salesforce/apex/NorelatedMOdatatableController.getCaseWorkTypesNotStarted';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

const COLSMIN = [
    { label: 'Código', fieldName: 'ProductCode', type: 'text' },
    { label: 'Producto', fieldName: 'ProductName', type: 'text' },
    { label: 'Tipo de Cargo', fieldName: 'chargeType', type: 'text' },
    //{ label: 'Tipo de Trabajo', fieldName: 'workTypeName', type: 'text' },
    { label: 'Precio Unitario', fieldName: 'unitPrice', type: 'currency', typeAttributes: { maximumFractionDigits: 2, currencyCode: { fieldName: 'currencyCode' } } },
    //{ label: 'Alias', fieldName: 'Bodega', type: 'text', editable: true },
    //{ label: 'Cantidad de Horas', fieldName: 'cantidadDisponible', type: 'number', editable: true },
    //{ label: 'Descuento', fieldName: 'productType', type: 'percent', editable: true, step: '0.0001',maximumFractionDigits: '3'},
    //{ label: 'UT', fieldName: 'ut', type: 'number', editable: true },
];

const COLS = [
    { label: 'Código', fieldName: 'ProductCode', type: 'text' },
    { label: 'Producto', fieldName: 'ProductName', type: 'text' },
    { label: 'Tipo de Cargo', fieldName: 'chargeType', type: 'text' },
    { label: 'Tipo de Trabajo', fieldName: 'workTypeName', type: 'text' },
    { label: 'Precio', fieldName: 'unitPrice', type: 'currency', typeAttributes: { maximumFractionDigits: 2, currencyCode: { fieldName: 'currencyCode' } } },
    { label: 'Alias', fieldName: 'alias', type: 'text', editable: false },
    { label: 'Cant. Horas', fieldName: 'cantidadHoras', type: 'number', editable: false },
    { label: 'Descuento', fieldName: 'discount', type: 'percent', editable: false, step: '1', maximumFractionDigits: '3', minimumFractionDigits: '2', },
    // { label: 'UT', fieldName: 'ut', type: 'number', editable: false },
];

export default class UnrelatedMOworklines extends NavigationMixin(LightningElement) {
    @api recordId = '0WOU9000001Zcg9OAC';
    @track unrelatedmos = [];
    cols = COLSMIN;
    minwindow = true;
    @api recId;
    currentWorktype;
    workTypeID;
    selectedRows = [];
    data = false;
    saveDraftValues;
    isLoaded = false;
    caseId;

    tooglewindow() {
        this.minwindow = !this.minwindow;
        if (!this.minwindow) {
            this.cols = COLS;
        } else { this.cols = COLSMIN; }

        //this.unrelatedmos=unrelatedmos;
    }

    handleTipodeTrabajo(event) {
        console.log('handleTipodeTrabajo');
        console.log(event.currentTarget.value);
        this.workTypeID = event.currentTarget.value;
        console.log('workTypeID');
        console.log(this.workTypeID);
        if (this.workTypeID ) {
            // this.handleGetWorkTypeName(event.currentTarget.value);
            this.updateWorktype();
        }
    }

    updateWorktype() {
        let selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
        console.log('@selectedRecords@');
        console.log(selectedRecords);

        console.log('@workTypeID@');
        console.log(this.workTypeID);
        if (selectedRecords) {
            selectedRecords.forEach(currentMO => {
                this.unrelatedmos.forEach(currentItem => {
                    console.log('@currentItem.wolId@');
                    console.log(currentItem.wolId+ " currentMO.wolId: "+currentMO.wolId);
                    if (currentItem.wolId === currentMO.wolId){
                        // currentMO.workTypeName = this.currentWorktype;
                        currentMO.workTypeID = this.workTypeID;
                        console.log(this.workTypeID);
                    }
                });
            });
            this.unrelatedmos = JSON.parse(JSON.stringify(this.unrelatedmos));
            console.log(JSON.parse(JSON.stringify(this.unrelatedmos)));
            // this.selectedRows = [];
            this.currentWorktype = null;
        }
    }

    handleSave() {
        this.isLoaded = true;
        /*this.saveDraftValues = event.detail.draftValues;
        var tempList = JSON.parse(JSON.stringify(this.unrelatedmos));
       
        console.log('Antes');
        console.log(tempList);
        event.detail.draftValues.forEach(draft=> {
            tempList.forEach(currentMO => {
                if(draft.wolId === currentMO.wolId){
                    currentMO.alias= draft.alias ? draft.alias  : null;
                    currentMO.cantidadHoras= draft.cantidadHoras ? draft.cantidadHoras  : null;
                    currentMO.discount= draft.discount ? draft.discount  : null;
                    currentMO.ut= draft.ut ? draft.ut  : null;
                }
            });
        }); 
        console.log('Después');
        this.unrelatedmos = JSON.parse(JSON.stringify(tempList));
        console.log(JSON.parse(JSON.stringify(this.unrelatedmos)));/*/
        this.handleSaveMOs();

    }

    customValidation() {
        var validity = true;
        console.log(JSON.parse(JSON.stringify(this.unrelatedmos)))
        this.unrelatedmos.forEach(currentMO => {
            if (!currentMO.workTypeID) {
                console.log('Falta Worktype');
                validity = false;
            }
        });
        return validity;
    }

    setMessageShow(title, message, variant) {
        var mode;
        if (this.variant === 'error' || this.variant === 'warning') {
            mode = 'sticky';
        } else { mode = 'dismissible' }
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    navigateToCase() {
        // Navigate to the Case
        console.log('redirecting ' + this.caseId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.caseId,
                objectApiName: 'Case',
                // relationshipApiName: 'WorkOrderLineItems',
                actionName: 'view'
            }
        });

    }
    /* Init Callback function */
    connectedCallback() {
        this.handleGetWolis();
    }


    //Server Calls
    handleGetWolis() {
        getNoRelatedMOs({ workorder: this.recordId })
            .then((result) => {
                console.log('Cantidad MOs:' + result.length);
                this.data = result.length > 0;
                this.unrelatedmos = (result);

            })
            .catch((error) => {
                console.log(error);
            })
            .finally(() => {
                this.caseId = this.data ? this.unrelatedmos[0].caseId : null;
                console.log('CasoId:' + JSON.stringify(this.caseId));
            });
    }

    handleGetWorkTypeName(workType) {
        getWorkTypeName({ workType: workType })
            .then((result) => {
                console.log(result);
                this.currentWorktype = result;
                console.log(workType);
                this.workTypeID = workType;

            })
            .catch((error) => {
                console.log(error);
            })
            .finally(() => {
                this.updateWorktype();
            });
    }

    handleSaveMOs() {
        // let selectedWolisWithWorkType = this.unrelatedmos.filter(wol => wol.workTypeID);
        let selectedWolisWithWorkType = this.template.querySelector("lightning-datatable").getSelectedRows();
        console.log('selectedWolisWithWorkType');
        console.log(selectedWolisWithWorkType);
        // if (selectedWolisWithWorkType.length > 0) {
            // console.log('JSON.stringify(this.selectedWolisWithWorkType)');
            // console.log(JSON.stringify(selectedWolisWithWorkType));
            this.tooglewindow();
            saveUnrelatedMOs({ JSONmowrapper: JSON.stringify(selectedWolisWithWorkType),workorder: this.recordId, selectedCaseWorkTypeId: this.selectedCaseWorkTypeId })
                .then((result) => {
                    console.log(result);
                    this.setMessageShow('Success! ', 'La líneas de MO se han guardado correctamente', 'success');
                })
                .catch((error) => {
                    console.log(error);
                    this.setMessageShow('Ups! ', 'Contacte a su administrador', 'error');
                })
                .finally(() => {
                    this.isLoaded = false;
                    this.refreshAccounts();
                    this.navigateToCase();
                });
        // } else {
        //     this.setMessageShow('Ups! ', 'Seleccione un tipo de trabajo del caso.', 'error');
        //     this.isLoaded = false;
        // }

    }

    refreshAccounts() {
        return refreshApex(this.handleGetWolis());
    }


    get isSaveButtonDisabled() {
        return !(this.selectedMOS.length > 0 && (this.selectedCaseWorkTypeId || this.workTypeID));
    }

    selectedMOS = [];
    handleRowSelection(event) {
        this.selectedMOS = event.detail.selectedRows;
        console.log('selectedMOS');
        console.log(this.selectedMOS);
        console.log('workTypeID');
        console.log(this.workTypeID);
        if (this.workTypeID ) {
            this.updateWorktype();
        }
    }

    @track workTypesOptions = [];
    @wire(getCaseWorkTypesNotStarted, { workOrderId: '$recordId' })    
    wireWorkTypes({ error, data }) {
        if (data) {
            this.workTypes = data;
            this.workTypesOptions = data.map(workType => {
                let name = workType?.Paso_de_trabajo__r?.Name
                return { label: name, value: workType.Id };
            });
            //agrega al inicio, el valor de ligar a nuevo trabajo
            // this.workTypesOptions.unshift({ label: 'Ligar a nuevo trabajo', value: null });
            console.log('workTypesOptions');
            console.log(this.workTypesOptions);
        } else if (error) {
            console.log(error);
        }
    }

    selectedCaseWorkTypeId;
    handleCaseWorkTypeChange(event){
        this.selectedCaseWorkTypeId = event.detail.value;
        console.log('selectedCaseWorkTypeId');
        console.log(this.handleTipodeTrabajo);
    }
}