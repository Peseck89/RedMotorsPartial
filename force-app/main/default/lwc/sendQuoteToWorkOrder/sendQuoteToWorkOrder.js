import { LightningElement, api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getQuoteLineItems from '@salesforce/apex/QuoteController.getQuoteLineItems';
import getDefaults from '@salesforce/apex/QuoteController.getDefaults';
import changeCurrencygtQLIs from '@salesforce/apex/QuoteController.changeCurrencygtQLIs';
import getWorkOrderRelated from '@salesforce/apex/QuoteController.getWorkOrderRelated';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveLines from '@salesforce/apex/QuoteController.saveWorkLineItems'; 
import { CloseActionScreenEvent } from 'lightning/actions';


export default class sendQuoteToWorkOrder extends NavigationMixin(LightningElement) {
    @api isLoaded = false;

    // @api recId = '0Q05C000000LlBsSAK'; //Id to test in PortalDev sandbox
    @api recId;
    @api workOrderId;
    @api workOrderOptions = []; 
    @api selectedWorkOrder; 
    @api selectedWorkOrderNumber; 
    @api currencyWO; 
    @api error; 
    @api selectedLines = [];
    oppId = null;
    oppStage = false;
    tieneReservados = false;
    quoteId = null;
    wrapperIdList = [];
    workOrderMap = {};
    selectedRows = [];
    quoteLineItemsList = [];
    workOrderRelatedList = [];
    deleteLines = [];
    showDelete = false;
    hasWorkOrder = true;
    showComponent = false;
    nullItem = false

    //Variables only for testing in Console Log
    productIdList = [];

    /* ======= PASOS ======= */
    step = 1;
    get isStep1() { return this.step === 1; }
    get isStep2() { return this.step === 2; }
    get isStep3() { return this.step === 3; }

    /* ======= Agrupación por Tareas ======= */
    taskGroups = [];                 // [{key, name, lineCount, totalAmount, currencyCode, checked}]
    selectAllTasks = false;
    selectedTaskKeys = new Set();
    get noTasksFound() { return (this.taskGroups || []).length === 0; }

    connectedCallback() {
        console.log('-----CONNECTED CALLBACK-----');
        console.log('Quote Id: ' + this.recId);
        getWorkOrderRelated({ quoteId: this.recId })
            .then((result) => {
                this.workOrderMap = result;
                this.workOrderOptions = Object.keys(result).map((key) => {
                    return { label: result[key], value: key };
                });
            })
            .catch((error) => {
                this.error = error;
                console.error('Error retrieving Work Orders:', error);
            });
        
        getDefaults({ quoteId: this.recId })
            .then((result) => {
                this.oppId = result.oppId;
                this.quoteId = this.recId;
                console.log(result);
               
                this.quoteLineItemsList = result.items;
                this.quoteLineItemsList = this.normalizeItems(result.items);
                this.hasWorkOrder = result.hasWorkOrder;
                if(result.opprecord != 'Taller'){
                    this.oppStage = result.oppStage && result.oppStage == 'Oportunidad Calificada' ? true : false ;
                }                
                this.showComponent = this.hasWorkOrder && !(this.oppStage && this.oppStage != 'Oportunidad Calificada'); 
                    
                console.log('oppId: '+this.oppId);
                console.log('quoteId: '+this.quoteId);
                console.log('hasWorkOrder: '+this.hasWorkOrder);
                this.error = undefined;
            })
    }

    handleWorkOrderChange(event) {
        this.selectedWorkOrder = event.target.value;

        this.wrapperIdList = [];
        this.productIdList = [];
        this.selectedWorkOrderNumber = this.workOrderMap[this.selectedWorkOrder];
        console.log('selectedWorkOrder3', this.selectedWorkOrder);
        console.log('this.selectedWorkOrderNumber ', this.selectedWorkOrderNumber);

        getQuoteLineItems({ workOrder: this.selectedWorkOrder,quoteId: this.quoteId })
        .then((result) => {
            this.oppId = result.oppId;
            this.quoteId = this.recId;
            console.log(result);
           
            this.quoteLineItemsList = result.items;
            this.quoteLineItemsList = this.normalizeItems(result.items);

            this.hasWorkOrder = result.hasWorkOrder;
            this.tieneReservados = result.tieneReservados;
            console.log(' this.tieneReservados ', this.tieneReservados);
            if(result.opprecord != 'Taller'){
                this.oppStage = result.oppStage && result.oppStage == 'Oportunidad Calificada' ? true : false ;
            }          
            console.log('oppId: '+this.oppId);
            console.log('quoteId: '+this.quoteId);
            console.log('hasWorkOrder: '+this.hasWorkOrder);
            this.error = undefined;
            console.log('QuoteLineItemsList: '); 
            console.log(this.quoteLineItemsList); 
            this.currencyWO = result.priceCurrency;
            this.quoteLineItemsList.forEach(currentItem => {
                if (this.quoteLineItemsList.indexOf(currentItem.wrapperId) == -1) {
                    this.workOrderId = currentItem.workOrderId;
                    this.wrapperIdList.push(currentItem.wrapperId);
                    this.productIdList.push(currentItem.productId);
                    console.log('WrapperIdList: ' + this.wrapperIdList);
                    console.log('ProductIdList: ' + this.productIdList); 
                }
            })
        })
        console.log('Selected Work Order1:', this.selectedWorkOrder); 
    }

    handleBackClick() {
        this.selectedWorkOrder = null;
        this.showComponent = true;
        this.step = 1;
    }

    handleChangeCurrency(){
        if(this.tieneReservados == true){
            alert('La orden de trabajo tiene lineas reservadas, para realizar el cambio de moneda es necesario liberar las reservas ya que todos los artículos de la orden se eliminarán y crearán con el envío del presupuesto a la orden.');
        }else{
            const confirmChange = window.confirm(
                'Advertencia: Todas las líneas de la Orden de trabajo se eliminarán y solo quedarán las que se envíen desde el presupuesto.'
            );
            if (confirmChange) {
                changeCurrencygtQLIs({ workOrder: this.selectedWorkOrder,quoteId: this.quoteId })
                .then((result) => {
                    this.oppId = result.oppId;
                    this.quoteId = this.recId;
                    console.log(result);
                   
                    this.quoteLineItemsList = result.items;
                    this.quoteLineItemsList = this.normalizeItems(result.items);

                    this.hasWorkOrder = result.hasWorkOrder;
                    this.tieneReservados = result.tieneReservados;
                    console.log(' this.tieneReservados ', this.tieneReservados);
                    if(result.opprecord != 'Taller'){
                        this.oppStage = result.oppStage && result.oppStage == 'Oportunidad Calificada' ? true : false ;
                    }          
                    console.log('oppId: '+this.oppId);
                    console.log('quoteId: '+this.quoteId);
                    console.log('hasWorkOrder: '+this.hasWorkOrder);
                    this.error = undefined;
                    console.log(this.quoteLineItemsList); 
                    this.currencyWO = result.priceCurrency;
                    this.quoteLineItemsList.forEach(currentItem => {
                        if (this.quoteLineItemsList.indexOf(currentItem.wrapperId) == -1) {
                            this.workOrderId = currentItem.workOrderId;
                            this.wrapperIdList.push(currentItem.wrapperId);
                            this.productIdList.push(currentItem.productId);
                            console.log('WrapperIdList: ' + this.wrapperIdList);
                            console.log('ProductIdList: ' + this.productIdList); 
                        }
                    })
                })
            }
        }
    }

    handleSelectAll(event) {
        const isChecked = event.target.checked;
        this.quoteLineItemsList = this.quoteLineItemsList.map(item => ({ ...item, isSelected: isChecked }));
        this.selectedLines = isChecked 
            ? this.quoteLineItemsList.map(item => item.wrapperId) 
            : [];
    }
    
    handleCheck(event) {
        const wrapperId = event.target.dataset.id; 
        const isChecked = event.target.checked;
        if (isChecked) {
            if (!this.selectedLines.includes(wrapperId)) {
                this.selectedLines = [...this.selectedLines, wrapperId];
            }
        } else {
            this.selectedLines = this.selectedLines.filter(id => id !== wrapperId);
        }
        this.quoteLineItemsList = this.quoteLineItemsList.map(item =>
            (item.wrapperId === wrapperId) ? { ...item, isSelected: isChecked } : item
        );
    }
    
    get isSelectAllChecked() {
        return this.quoteLineItemsList.length > 0 && this.quoteLineItemsList.every(item => item.isSelected);
    }
    
    handleTipodeTrabajo(event){
        this.tipoTrabajo = event.currentTarget.value;
        this.errorTipoTrabajo = '';
    }

    // Helper: trunca a 2 decimales (no redondea)
    trunc2(n) {
        if (!Number.isFinite(n)) return n;
        return n >= 0
            ? Math.floor(n * 100) / 100
            : Math.ceil(n * 100) / 100;
    }
    normalizeItems(items) {
        return (items || []).map(it => {
            const q = Number(it.cantidad);
            if (Number.isFinite(q)) {
                return { ...it, cantidad: this.trunc2(q) };
            }
            return it;
        });
    }
    
    handleQuantity(event) {
        const wrapperId = event.currentTarget.dataset.id;
        const modifiedIndex = this.wrapperIdList.indexOf(wrapperId);
        let raw = event.target.value;
        let num = Number(raw);
        if (!Number.isFinite(num)) {
            return;
        }
        const MIN = 0.01;
        if (num < MIN) num = MIN;
        const truncated = this.trunc2(num);
        event.target.value = truncated.toFixed(2);
        event.target.setCustomValidity('');
        event.target.reportValidity();
        const tmp = JSON.parse(JSON.stringify(this.quoteLineItemsList));
        tmp[modifiedIndex].cantidad = truncated;
        this.quoteLineItemsList = tmp;
    }

    handlePrecioVenta(event) {
        var modifiedIndex = this.wrapperIdList.indexOf(event.currentTarget.dataset.id);
        let tempQuoteLineItemsList = JSON.parse(JSON.stringify(this.quoteLineItemsList));
        tempQuoteLineItemsList[modifiedIndex].precioVenta = event.detail.value;
        this.quoteLineItemsList = tempQuoteLineItemsList;
    }

    handleAlias(event) {
        var modifiedIndex = this.wrapperIdList.indexOf(event.currentTarget.dataset.id);
        let tempQuoteLineItemsList = JSON.parse(JSON.stringify(this.quoteLineItemsList));
        tempQuoteLineItemsList[modifiedIndex].alias = event.currentTarget.value;
        this.quoteLineItemsList = tempQuoteLineItemsList;
    }

    draftValues = [];
    errorTipoTrabajo = '';
    tipoTrabajo = '123456789012345678';

    // MODIFICADO: siempre enviar a Caso (sin preguntar ni checkboxes)
    @api async handleSave() {
        let tempQuoteLineItemsList = JSON.parse(JSON.stringify(this.quoteLineItemsList));
        const linesToSave = tempQuoteLineItemsList.filter(item => 
            this.selectedLines.length ? this.selectedLines.includes(item.wrapperId) : true
        );

        // Forzar “enviar a caso” en servidor
        const enviarACasoAlways = true;

        this.toggle();
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
    
        if (allValid) {
            saveLines({ 
                listTosave: JSON.stringify(linesToSave), 
                workOrder: this.workOrderId,
                quoteId: this.quoteId, 
                oppId: this.oppId,
                enviarACaso: enviarACasoAlways
            })
            .then(() => {
                this._title = 'Success!';
                this.message = 'Las líneas seleccionadas fueron guardadas y enviadas al caso.';
                this.variant = 'success';
                this.showNotification();
                this.navigateToRelatedList();
            })
            .catch((error) => {
                this.toggle();
                this.error = error;
                this._title = 'Ups!';
                this.message = error.body?.message || 'Ocurrió un error al guardar.';
                this.variant = 'warning';
                this.showNotification();
                console.log(error?.body);
            });
        } else {
            this.toggle();
            this._title = 'Error!';
            this.message = 'Revise los campos señalados en ROJO';
            this.showNotification();
        }
    }
    

    handleDeleteLine(event) {
        let tempQuoteLineItemsList = JSON.parse(JSON.stringify(this.quoteLineItemsList));
        let tempDeleteLines = JSON.parse(JSON.stringify(this.wrapperIdList));
        this.deleteLines.forEach(currentItem => {
            tempQuoteLineItemsList.splice(tempDeleteLines.indexOf(currentItem), 1);
            this.wrapperIdList.splice(tempDeleteLines.indexOf(currentItem), 1);
            tempDeleteLines.splice(tempDeleteLines.indexOf(currentItem), 1);
        });
        this.quoteLineItemsList = tempQuoteLineItemsList;
        this.deleteLines = [];
        this.showDelete = (this.deleteLines.length > 0);
    }

    navigateToRelatedList() {
    // Cierra Quick Action si aplica (no truena si no lo es)
    try { this.dispatchEvent(new CloseActionScreenEvent()); } catch(e) {}

    // Intenta refrescar la vista actual (en Lightning Record Page Aura)
    try {
        // eslint-disable-next-line no-eval
        eval("$A.get('e.force:refreshView').fire();");
    } catch(e) {}

    // Genera la URL de la lista relacionada y navega con hard reload
    this[NavigationMixin.GenerateUrl]({
        type: 'standard__recordRelationshipPage',
        attributes: {
            recordId: this.workOrderId,
            objectApiName: 'WorkOrder',
            relationshipApiName: 'WorkOrderLineItems',
            actionName: 'view'
        }
    }).then(url => {
        // Pequeño delay para que se vea el toast y termine cualquier repaint
        setTimeout(() => {
            // Hard refresh para evitar caché de SPA y ver datos recién guardados
            window.open(url, '_self');
        }, 1000);
    });
}


    toggle() {
        this.isLoaded = !this.isLoaded;
    }

    showNotification() {
        const evt = new ShowToastEvent({
            title: this._title,
            message: this.message,
            variant: this.variant,
        });
        this.dispatchEvent(evt);
    }

    // ==============================
    // ======= Flujo de pasos =======
    // ==============================

    // Paso 1 -> Paso 2
    goToTasks = () => {
        if (!this.selectedWorkOrder) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Selecciona una Orden de Trabajo',
                message: 'Debes seleccionar una OT para continuar.',
                variant: 'warning'
            }));
            return;
        }
        this.buildTaskGroups(this.quoteLineItemsList || []);
        this.step = 2;
    }

    // Paso 2 -> Atrás (Paso 1)
    backToStep1 = () => {
        this.step = 1;
    }

    // Agrupación por Tarea
    buildTaskGroups(items) {
        const rows = Array.isArray(items) ? items : [];
        const buckets = new Map();
        for (const r of rows) {
            const key  = r.tareaId || r.Tarea__c || r.tareaQuote || 'NO_TASK';
            const name = r.tareaName || r.Tarea__rName || r.tareaQuote || (r.Tarea__r && r.Tarea__r.Name) || 'Sin tarea';
            if (!buckets.has(key)) buckets.set(key, { key, name, items: [] });
            buckets.get(key).items.push(r);
        }
        const groups = Array.from(buckets.values()).map(g => {
            const total = g.items.reduce((acc, it) => {
                const qty = Number(it.cantidad) || 0;
                const unit = Number(it.precioVenta ?? it.unitPrice ?? it.price ?? 0);
                return acc + (unit * qty);
            }, 0);
            return {
                key: g.key,
                name: g.name,
                lineCount: g.items.length,
                totalAmount: Math.round(total * 100) / 100,
                currencyCode: g.items[0]?.currencyCode || g.items[0]?.currencyCodeProd || '',
                checked: this.selectedTaskKeys.has(g.key)
            };
        }).sort((a,b)=> String(a.name).localeCompare(String(b.name)));
        this.taskGroups = groups;
        this.selectAllTasks = groups.length > 0 && groups.every(x => x.checked);
    }

    handleTaskToggle = (evt) => {
        const key = evt.target.dataset.key;
        const checked = evt.target.checked;
        if (checked) this.selectedTaskKeys.add(key);
        else this.selectedTaskKeys.delete(key);
        this.taskGroups = this.taskGroups.map(t => t.key === key ? { ...t, checked } : t);
        this.selectAllTasks = this.taskGroups.length > 0 && this.taskGroups.every(x => x.checked);
    }

    handleToggleAllTasks = (evt) => {
        const checked = evt.target.checked;
        this.selectAllTasks = checked;
        if (checked) {
            this.selectedTaskKeys = new Set(this.taskGroups.map(t => t.key));
        } else {
            this.selectedTaskKeys = new Set();
        }
        this.taskGroups = this.taskGroups.map(t => ({ ...t, checked }));
    }

    // Paso 2 -> Paso 3 (filtra por tareas seleccionadas y auto-selecciona TODAS las QLIs visibles)
    goToReview = () => {
        if (!this.selectedTaskKeys || this.selectedTaskKeys.size === 0) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Selecciona al menos una tarea',
                message: 'Debes elegir al menos una tarea para continuar.',
                variant: 'warning'
            }));
            return;
        }
        const keys = this.selectedTaskKeys;
        const filtered = (this.quoteLineItemsList || []).filter(it => {
            const k = it.tareaId || it.Tarea__c || it.tareaQuote || 'NO_TASK';
            return keys.has(k);
        });
        this.quoteLineItemsList = this.normalizeItems(filtered);
        this.wrapperIdList = (this.quoteLineItemsList || []).map(it => it.wrapperId);
        this.selectedLines   = (this.quoteLineItemsList || []).map(it => it.wrapperId);
        this.step = 3;
    }
}