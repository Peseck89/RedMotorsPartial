import { LightningElement, track, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import deleteTrabajo from "@salesforce/apex/TrabajoController.deleteTrabajo";
import deleteSubtrabajo from "@salesforce/apex/TrabajoController.deleteSubtrabajo";
import getTrabajos from "@salesforce/apex/TrabajoController.getTrabajos";
import getUTSTipoTrabajo from "@salesforce/apex/TrabajoController.getUTSTipoTrabajo";
import getWorkOrder from "@salesforce/apex/TrabajoController.getWorkOrder";
import getWorkOrders from '@salesforce/apex/TipoTrabajoCasoController.getWorkOrders';
import saveTrabajo from "@salesforce/apex/TrabajoController.saveTrabajo";
import search from '@salesforce/apex/SampleLookupController.search';
import saveSubtrabajos from "@salesforce/apex/TrabajoController.saveSubtrabajos";
import NAME_FIELD from '@salesforce/schema/tiposDeTrabajo__c.Name';

export default class CT_CrearTrabajoaRealizar_lwc extends LightningElement {
  myFields = [NAME_FIELD];
  @track reloadTrabajos = false; 
  @track trabajos = []; // Lista de trabajos a realizar
  @track trabajos2 = []; 
  @track showModal = false; // Controla la visibilidad del modal de subtrabajos
  @track subtrabajosTemporal = []; // Subtrabajos temporales para edición
  @track trabajoSeleccionado = {}; // Trabajo seleccionado para agregar subtrabajos
  @api recId; // Id del Caso (se recibe automáticamente si el LWC está en un record page)
  @track workOrderId;  
  @track isLoading = false;
  nextTrabajoId = 1; // Contador para IDs de trabajos
  nextSubtrabajoId = 1; // Contador para IDs de subtrabajos
  initialSelection = [];
  @track selectedTrabajo = {}; 
  @track selectedAseguradora = {}; 
  @track selectedCentroDeCostos = {}; 
  @api trabajo; 
  tipoDeTrabajo = '';
  SubTipoDeTrabajo = '';
  @api tipoDeTrabajoId;
  @track disabeldTrabajosButton = false;
  @track disabledSubtrabajosButton = false;
  @track firstScreen = true;
  @track crearTipoDeTrabajo = false;
  @track wiredWorkOrders;
  @track selectedWorkOrderId;
  @track isSavingTrabajo = false;
  @track workOrdersOptions = [];
  @track creacionTipoDeTrabajoSub = false;

  prioridadOptions = [
    { label: "Sugerido", value: "Sugerido" },
    { label: "Necesario", value: "Necesario" },
    { label: "Recomendado", value: "Recomendado" },
  ];

  tipoCargoOptions = [
    { label: "Cliente", value: "Cliente" },
    { label: "Garantía", value: "Garantía" },
    { label: "BSI", value: "BSI" },
    { label: "Aseguradora", value: "Aseguradora" },
    { label: "BSI interno	", value: "BSI interno" },
    { label: "Interno", value: "Interno" },
  ];

  aprobadorOptions = [
    { label: "Asesor", value: "Asesor" },
    { label: "Cliente", value: "Cliente" },
  ];
  
  connectedCallback() {
    this.loadWorkOrder();
    this.loadTrabajos();
  }

  async loadWorkOrder(){
    this.workOrderId = await getWorkOrder({ casoId: this.recId });
    this.selectedWorkOrderId = this.workOrderId;
  }

  async loadTrabajos() {
    this.isLoading = true;
    try {
      const trabajosExistentes = await getTrabajos({ casoId: this.recId });
      console.log('trabajosExistentes ',trabajosExistentes);
      this.trabajos = trabajosExistentes.map((trabajo) => ({
          id: trabajo.id || `local-${this.nextTrabajoId++}`,
          workOrderId: trabajo.workOrderId ? trabajo.workOrderId : this.selectedWorkOrderId,
          disabledWorkOrder: trabajo.workOrderId ? true : false,
          idAseguradora: trabajo.id +'Aseguradora',
          idCentroDeCostos: trabajo.id +'CentroDeCostos',
          changeAlias : false,
          checked: false,
          prioridad: trabajo.prioridad,
          mostrarAseguradora: trabajo.tipoCargo === 'Aseguradora',
          aseguradora: trabajo.aseguradora,
          isButtonDisabled: trabajo.id ? false : true,
          selectedAseguradora: trabajo.aseguradora ? { 
            id: trabajo.aseguradora, 
            title: trabajo.aseguradoraNombre 
          } : { id: null, title: null },
          mostrarCentroDeCostos: trabajo.tipoCargo === 'Interno',
          centroDeCostos: trabajo.centroDeCostos,
          selectedCentroDeCostos: trabajo.centroDeCostos ? { 
            id: trabajo.centroDeCostos, 
            title: trabajo.centroDeCostosNombre 
          } : { id: null, title: null },
          nombre:  trabajo.tipoTrabajo,
          manoDeObra : trabajo.manoDeObra,
          manoDeObraNombre : trabajo.manoDeObraNombre,
          nombreTrabajo : trabajo.nombreTrabajo,
          alias: trabajo.alias != '' ? trabajo.alias : trabajo.nombreTrabajo,
          selectedTrabajo: trabajo.tipoTrabajo ? { 
            id: trabajo.tipoTrabajo, 
            title: trabajo.nombreTrabajo 
          } : { id: null, title: null },
          tipoCargo: trabajo.tipoCargo,
          aprobador: trabajo.aprobador,
          utsDelTipoDeTrabajo : trabajo.utsDelTipoDeTrabajo,
          disabledUts: true,
          totalSubtrabajos: trabajo.totalSubtrabajos, 
          uts: trabajo.nombreTrabajo != '-Control final' && trabajo.nombreTrabajo != 'CONTROL FINAL' && trabajo.nombreTrabajo != 'Control final' && trabajo.nombreTrabajo != 'Lavado Red Motos' ? trabajo.uts: 0,
          utsReal: trabajo.nombreTrabajo != '-Control final' && trabajo.nombreTrabajo != 'CONTROL FINAL' && trabajo.nombreTrabajo != 'Control final' && trabajo.nombreTrabajo != 'Lavado Red Motos' ? trabajo.utsReal != undefined && trabajo.utsReal != null && trabajo.utsReal != 0 
          ? Math.round(trabajo.utsReal)
            : Math.round(trabajo.uts * 12) : 0,
              subtrabajos: trabajo.subtrabajos.map((subtrabajo) => ({
              id: subtrabajo.id || `local-${this.nextSubtrabajoId++}`,
              nombre: subtrabajo.tipoTrabajoNombre,
              disabledUts : subtrabajo.utsDelTipoDeTrabajo ? true : false,
              tipoTrabajo : subtrabajo.tipoTrabajo,
              tipoTrabajoNombre : subtrabajo.tipoTrabajoNombre,
              alias: subtrabajo.alias,
              selectedSubTrabajo: subtrabajo.pasoDeTrabajo ? { 
                id: subtrabajo.pasoDeTrabajo, 
                title: subtrabajo.nombre 
              } : { id: null, title: null },
              manoDeObra: subtrabajo.manoDeObra ? subtrabajo.manoDeObra : trabajo.manoDeObra,
              selectedManoDeObra: (subtrabajo.manoDeObra ?? trabajo.manoDeObra) ? {
                id: subtrabajo.manoDeObra ?? trabajo.manoDeObra,
                title: subtrabajo.manoDeObra ? subtrabajo.manoDeObraNombre : trabajo.manoDeObraNombre
              } : { id: null, title: null },      
              selectedTipoTrabajo: (subtrabajo.tipoTrabajo ?? trabajo.tipoTrabajo) ? {
                id: subtrabajo.tipoTrabajo ?? trabajo.tipoTrabajo,
                title: subtrabajo.tipoTrabajo ? subtrabajo.tipoTrabajoNombre : null
              } : { id: null, title: null },             
              uts: subtrabajo.tipoTrabajoNombre != '-Control final' && subtrabajo.tipoTrabajoNombre != 'CONTROL FINAL' && subtrabajo.tipoTrabajoNombre != 'Control final' && subtrabajo.tipoTrabajoNombre != 'Lavado Red Motos' ? subtrabajo.uts != null ? subtrabajo.uts : subtrabajo.horas :0,
              horas: subtrabajo.tipoTrabajoNombre != '-Control final' && subtrabajo.tipoTrabajoNombre != 'CONTROL FINAL' && subtrabajo.tipoTrabajoNombre != 'Control final' && subtrabajo.tipoTrabajoNombre != 'Lavado Red Motos' ? subtrabajo.horas :0,
              checked: false,
          })),
      }));
      if(this.trabajos.length === 0){
        console.log('trabajosExistentes null2 ',trabajosExistentes);
        this.trabajos = [
          {
            id: `local-${this.nextTrabajoId++}`,
            checked: false,
            prioridad: "Sugerido",
            nombre: "Nuevo Trabajo",
            tipoCargo: "Cliente",
            aprobador: "Asesor",
            isButtonDisabled : true,
            selectedTrabajo: { id: '', title: '' },
            uts: 0,
            subtrabajos: [],
          },
        ];
        this.disabeldTrabajosButton = true;
      }else{
        this.disabeldTrabajosButton = false;
        if(this.isSavingTrabajo == true){
          this.handleAddWork();
          this.isSavingTrabajo = false;
        }  
      }
      console.log('this.trabajos ',this.trabajos);
      this.isLoading = false;
    } catch (error) {
      console.log('error ',error);
      console.log('error ',error.body);

      this.isLoading = false;
      this.showToast("Error", error.body.message, "error");
    }
  }
  @wire(getWorkOrders, { caseId: '$recId' })
    workOrders(result) {
        this.wiredWorkOrders = result;
        if (result.data) {
            this.workOrdersOptions = result.data.map(workOrder => ({
                label: workOrder.WorkOrderNumber,
                value: workOrder.Id
            }));

            if (this.workOrdersOptions && this.workOrdersOptions.length === 1) {
                this.selectedWorkOrderId = this.workOrdersOptions[0].value;
            }
        }
    }
    
    get showWorkOrderCombo(){
        return this.workOrdersOptions.length > 1;
    }

    handleOrdenSelection(event){
        //this.workOrderId = event.detail.value;
        //this.selectedWorkOrderId = event.detail.value;
        const id = event.target.dataset.id;
        this.updateTrabajo(id, "workOrderId", event.detail.value);
        console.log('workOrderId: ' + event.detail.value);
    }
  handleCancelTrabajo(){
    this.firstScreen = true;
    this.creacionTipoDeTrabajo = false;
  }
  handleCancelTrabajoSub(){
    this.creacionTipoDeTrabajoSub = false;
  }
  handleCrear(){
      this.firstScreen = false;
      this.creacionTipoDeTrabajo = true;
  }
  handleCrearSub(){
    this.creacionTipoDeTrabajoSub = true;
  }
  handleSuccessTrabajo(event) {
    const evt = new ShowToastEvent({
        title: 'Registro correcto',
        message: 'Record ID: ' + event.detail.id,
        variant: 'success',
    });
    this.dispatchEvent(evt);
    this.firstScreen = true;
    this.creacionTipoDeTrabajo = false;
  }
  handleSuccessTrabajoSub(event){
    const evt = new ShowToastEvent({
        title: 'Registro correcto',
        message: 'Record ID: ' + event.detail.id,
        variant: 'success',
    });
    this.dispatchEvent(evt);
    this.creacionTipoDeTrabajoSub = false;
  }
  handleTipoTrabajoLookupSelectionChange(event) {
    const id = event.target.dataset.id;
    let selectedValue = event.detail;      
    if (Array.isArray(selectedValue) && selectedValue.length > 0) {
      selectedValue = selectedValue[0]; 
    }
    getUTSTipoTrabajo({ idTipoTrabajo: selectedValue })
    .then((results) => {
      this.updateTrabajo(id, "uts", results);
     
      console.log('results ',results);
      if(results && results >0){
        this.updateTrabajo(id, "disabledUts", true);
        let utsRealF = Math.round(results * 12);
        this.updateTrabajo(id, "utsReal", utsRealF);
      }else{
        this.updateTrabajo(id, "disabledUts", false);
      }
    })
    if (selectedValue) {
      const lookupElement = event.target;
      const selectedRecord = lookupElement.getSelection()[0];
      if(selectedRecord){
        this.updateTrabajo(id, "alias", selectedRecord.title);
      }
    }
    this.updateTrabajo(id, "nombre", selectedValue);
  }
  handleUTSRealChange(event) {
    const id = event.target.dataset.id;
    let value = event.detail.value;
    if (value === '' || isNaN(value)) {
        value = 0;
    } else {
        value = Math.max(0, Math.round(Number(value)));
    }
    const utsF = parseFloat((value / 12).toFixed(3));
    this.updateTrabajo(id, "uts", utsF);
    this.updateTrabajo(id, "utsReal", Math.round(value));
}
  handleLookupAseguradoraChange(event) {
    const id = event.target.dataset.id;
    let selectedValue = event.detail;
    if (Array.isArray(selectedValue) && selectedValue.length > 0) {
      selectedValue = selectedValue[0]; 
    }
    if (selectedValue) {
      const lookupElement = event.target;
      const selectedRecord = lookupElement.getSelection()[0];
      this.updateTrabajo(id, "aseguradora", selectedValue);
      if(selectedRecord){
        this.updateTrabajo(id, "selectedAseguradora", { id: selectedValue, title: selectedRecord.title });
      }
    } else {
      // Si se limpia el lookup, asegurarnos de resetearlo
      this.updateTrabajo(id, "aseguradora", null);
      this.updateTrabajo(id, "selectedAseguradora", { id: null, title: null });
    }
  }

  handleLookupCentroDeCostosChange(event) {
    const id = event.target.dataset.id;
    let selectedValue = event.detail;
    if (Array.isArray(selectedValue) && selectedValue.length > 0) {
      selectedValue = selectedValue[0]; 
    }
    if (selectedValue) {
      const lookupElement = event.target;
      const selectedRecord = lookupElement.getSelection()[0];
      this.updateTrabajo(id, "centroDeCostos", selectedValue);
      if(selectedRecord){
        this.updateTrabajo(id, "selectedCentroDeCostos", { id: selectedValue, title: selectedRecord.title });
      }
    } else {
      this.updateTrabajo(id, "centroDeCostos", null);
      this.updateTrabajo(id, "selectedCentroDeCostos", { id: null, title: null });
    }
  }

  handleSubtipoTipoDeTrabajoLookupSelectionChange(event){
    const id = event.target.dataset.id;
    let selectedValue = event.detail;
    if (Array.isArray(selectedValue) && selectedValue.length > 0) {
      selectedValue = selectedValue[0]; 
    }
    if (selectedValue) {
      const lookupElement = event.target;
      const selectedRecord = lookupElement.getSelection()[0];
      this.updateSubtrabajoTemporal(id, "tipoTrabajo", selectedValue);

      getUTSTipoTrabajo({ idTipoTrabajo: selectedValue })
      .then((results) => {
        this.updateSubtrabajoTemporal(id, "uts", results);
        if(results && results > 0){
          this.updateSubtrabajoTemporal(id, "disabledUts", true);
        } else {
          this.updateSubtrabajoTemporal(id, "disabledUts", false);
        }
      });

      if (selectedRecord) {
        this.updateSubtrabajoTemporal(id, "selectedTipoTrabajo", {
          id: selectedValue,
          title: selectedRecord.title
        });
        this.updateSubtrabajoTemporal(id, "alias", selectedRecord.title);
        this.updateSubtrabajoTemporal(id, "nombre", selectedRecord.title); 
      }
    } else {
      this.updateSubtrabajoTemporal(id, "tipoTrabajo", null);
      this.updateSubtrabajoTemporal(id, "selectedTipoTrabajo", { id: null, title: null });
      this.updateSubtrabajoTemporal(id, "nombre", "");
    }
  }

  
  handleLookupsearch(event) {
    const lookupElement = event.target;
    let firedElement = event.target.id;
    if (firedElement.includes('Aseguradora2')) {
      firedElement = firedElement.replace('Aseguradora2', 'Aseguradora');
    }
    if (firedElement.includes('CentroCosto2')) {
      firedElement = firedElement.replace('CentroCosto2', 'CentroCosto');
    }
    if (firedElement.includes('SubTipoDeTrabajo2')) {
      firedElement = firedElement.replace('SubTipoDeTrabajo2', 'SubTipoDeTrabajo');
    }
    if (firedElement.includes('TipoDeTrabajo3')) {
      firedElement = firedElement.replace('TipoDeTrabajo3', 'TipoDeTrabajo');
    }
    if (firedElement.includes('TipoDeTrabajo4')) {
      firedElement = firedElement.replace('TipoDeTrabajo4', 'TipoDeTrabajo');
    }
    var paramenters = event.detail;
    paramenters["firedElement"] = firedElement;
    paramenters["caseId"] = this.recId;
    search(paramenters)
    .then((results) => {
        lookupElement.setSearchResults(results);
    })
    .catch((error) => {
      this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
      this.errors = [error];
    });
  }
  handleAddWork() {
    this.trabajos = [
      ...this.trabajos,
      {
        id: `local-${this.nextTrabajoId++}`,
        checked: false,
        prioridad: "Sugerido",
        nombre: "Nuevo Trabajo",
        tipoCargo: "Cliente",
        aprobador: "Asesor",
        workOrderId: this.workOrderId,
        isButtonDisabled : true,
        selectedTrabajo: { id: '', title: '' },
        uts: 0,
        subtrabajos: [],
      },
    ];
    this.disabeldTrabajosButton = true;
  }

  async handleSaveOne(event) {
    this.isLoading = true;
    const trabajoId = event.target.dataset.id;
    let trabajoNull = false;
    const trabajo = this.trabajos.find((t) => t.id === trabajoId);
    if(trabajo.uts == null || trabajo.uts == 0){
      this.isLoading = false;
      this.showToast("Error Cantidad", 'Debe ingresar un valor mayor a 0 para el campo Cantidad', "error");
    }
    else{
      try {
        await saveTrabajo({
          trabajo: {
            id: trabajo.id.startsWith("local") ? null : trabajo.id,
            prioridad: trabajo.prioridad,
            aseguradora: trabajo.aseguradora,
            centroDeCostos: trabajo.centroDeCostos,
            alias: trabajo.alias,
            changeAlias: trabajo.changeAlias,
            tipoTrabajo: trabajo.nombre,
            tipoCargo: trabajo.tipoCargo,
            aprobador: trabajo.aprobador,
            uts: trabajo.uts,
            totalSubtrabajos: trabajo.totalSubtrabajos,
          },
          casoId: this.recId,
          workOrderId: trabajo.workOrderId ? trabajo.workOrderId : this.selectedWorkOrderId
        });
        if(trabajo.id.startsWith("local")){
          this.disabeldTrabajosButton = false;
        }
        this.showToast("Éxito", "Trabajo guardado correctamente", "success");
        this.isSavingTrabajo = true;
        this.loadTrabajos(); // Recargar los datos después de guardar
        this.isLoading = false;
      } catch (error) {
        this.isLoading = false;
        this.showToast("Error", error.body.message, "error");
      }
    }
  }

  handleCancelar() {
    this.dispatchEvent(new CustomEvent("close", {
        bubbles: true,
        composed: true
    }));
  }

  handleCancelarSubTrabajo() {
    if(this.reloadTrabajos == true){
      this.loadTrabajos();
      this.reloadTrabajos = false;
    }
    this.showModal = false;
  }

  handleCheckChange(event) {
    const id = event.target.dataset.id;
    this.updateTrabajo(id, "checked", event.target.checked);
  }

  handlePrioridadChange(event) {
    const id = event.target.dataset.id;
    this.updateTrabajo(id, "prioridad", event.detail.value);
  }
  handleAliasChange(event){
    const id = event.target.dataset.id;
    this.updateTrabajo(id, "alias", event.detail.value);
    this.updateTrabajo(id, "changeAlias", true);
  }
  handleUTSChange(event){
    const id = event.target.dataset.id;
    let value = event.detail.value;
    if (value && value.includes('.')) {
        const parts = value.split('.');
        if (parts[1].length > 3) {
            value = `${parts[0]}.${parts[1].substring(0, 3)}`;
            event.target.value = value;
        }
    }
    this.updateTrabajo(id, "uts", value);
    let utsRealF = Math.round(value * 12);
    this.updateTrabajo(id, "utsReal", utsRealF);
  }

  handleNombreChange(event) {
    const id = event.target.dataset.id;
    this.updateTrabajo(id, "nombre", event.target.value);
  }

  handleTipoCargoChange(event) {
    const id = event.target.dataset.id;
    const tipoCargo = event.detail.value;
    this.trabajos = this.trabajos.map((trabajo) =>
      trabajo.id === id
        ? { ...trabajo, tipoCargo, mostrarAseguradora: tipoCargo === 'Aseguradora', mostrarCentroDeCostos: tipoCargo === 'Interno' }
        : trabajo
    );
    this.updateTrabajo(id, "tipoCargo", event.detail.value);
  }

  handleAprobadorChange(event) {
    const id = event.target.dataset.id;
    this.updateTrabajo(id, "aprobador", event.detail.value);
  }

  updateTrabajo(id, field, value) {
    this.trabajos = this.trabajos.map((trabajo) =>
      trabajo.id === id ? { ...trabajo, [field]: value } : trabajo
    );
  }

  handleOpenSubtrabajos(event) {
    const trabajoId = event.target.dataset.id;
    this.trabajoSeleccionado = this.trabajos.find((t) => t.id === trabajoId);
    this.subtrabajosTemporal = JSON.parse(
      JSON.stringify(this.trabajoSeleccionado.subtrabajos)
    );
    if (this.subtrabajosTemporal.length > 0) {
      this.disabledSubtrabajosButton = false;
    }
    console.log('this.subtrabajosTemporal.length ',this.subtrabajosTemporal.length);
    if (this.subtrabajosTemporal.length === 0) {
      console.log('this.disabledSubtrabajosButton ',this.disabledSubtrabajosButton);
      this.disabledSubtrabajosButton = true;
      console.log('this.disabledSubtrabajosButton2 ',this.disabledSubtrabajosButton);
      console.log('this.trabajoSeleccionado.nombre',this.trabajoSeleccionado.nombre);

      if(this.trabajoSeleccionado.nombre != null){
        this.subtrabajosTemporal = [
          ...this.subtrabajosTemporal,
          {
            id: `local-${this.nextSubtrabajoId++}`,
            nombre: "",
            selectedSubTrabajo: { id: '', title: '' },
            tipoTrabajo: this.trabajoSeleccionado.nombre,
            nombre: this.trabajoSeleccionado.nombreTrabajo,
            alias: this.trabajoSeleccionado.nombreTrabajo,
            selectedTipoTrabajo: { id: this.trabajoSeleccionado.nombre, title: this.trabajoSeleccionado.nombreTrabajo},
            uts: this.trabajoSeleccionado.utsDelTipoDeTrabajo,
            disabledUts : this.trabajoSeleccionado.utsDelTipoDeTrabajo ? true : false,
            checked: false,
          },
        ];
      }
      else{
        this.subtrabajosTemporal = [
          ...this.subtrabajosTemporal,
          {
            id: `local-${this.nextSubtrabajoId++}`,
            nombre: "",
            alias: "",
            selectedSubTrabajo: { id: '', title: '' },
            selectedTipoTrabajo: { id: '', title: '' },
            uts: 0,
            checked: false,
          },
        ];
      }
    }
    this.showModal = true;
  }

  agregarFilaSubtrabajo() {
    this.disabledSubtrabajosButton = true;
    this.subtrabajosTemporal = [
      ...this.subtrabajosTemporal,
      {
        id: `local-${this.nextSubtrabajoId++}`,
        nombre: "",
        alias: "",
        selectedSubTrabajo: { id: '', title: '' },
        selectedManoDeObra: { id: '', title: '' },
        selectedTipoTrabajo: { id: '', title: '' },
        uts: 0,
        checked: false,
      },
    ];
  }


  handleCheckSubtrabajo(event) {
    const id = event.target.dataset.id;
    this.updateSubtrabajoTemporal(id, "checked", event.target.checked);
  }

  handleSubtrabajoNombreChange(event) {
    const id = event.target.dataset.id;
    this.updateSubtrabajoTemporal(id, "nombre", event.target.value);
  }
  handleSubtrabajoAliasChange(event) {
    const id = event.target.dataset.id;
    this.updateSubtrabajoTemporal(id, "alias", event.target.value);
  }

  handleSubtrabajoUtsChange(event) {
    const id = event.target.dataset.id;
    let value = event.detail.value;
    if (value && value.includes('.')) {
        const parts = value.split('.');
        if (parts[1].length > 3) {
            value = `${parts[0]}.${parts[1].substring(0, 3)}`;
            event.target.value = value;
        }
    }
    this.updateSubtrabajoTemporal(id, "uts",value);
  }

  updateSubtrabajoTemporal(id, field, value) {
    this.subtrabajosTemporal = this.subtrabajosTemporal.map((st) =>
      st.id === id ? { ...st, [field]: value } : st
    );
  }

  async handleDeleteTrabajo(event) {
    this.isLoading = true;
    const trabajoId = event.target.dataset.id;
    if (trabajoId.startsWith("local")) {
      this.trabajos = this.trabajos.filter((t) => t.id !== trabajoId);
      this.disabeldTrabajosButton = false;
      this.isLoading = false;
    } else {
      try {
        await deleteTrabajo({ trabajoId });
        this.trabajos = this.trabajos.filter((t) => t.id !== trabajoId);
        const tieneIdNulo = this.trabajos.some((t) => t.id.startsWith("local"));
        console.log('tieneIdNulo1 ',tieneIdNulo);
        this.disabeldTrabajosButton = tieneIdNulo ? true : false;
        this.showToast("Éxito", "Trabajo eliminado correctamente", "success");
        this.isLoading = false;
      } catch (error) {
        this.isLoading = false;
        this.showToast("Error", error.body.message, "error");
      }
    }
  }

  async handleDeleteSubtrabajo(event) {
    this.isLoading = true;
    const subtrabajoId = event.target.dataset.id;
    if (subtrabajoId.startsWith("local")) {
      this.subtrabajosTemporal = this.subtrabajosTemporal.filter(
        (st) => st.id !== subtrabajoId
      );
      this.isLoading = false;
    } else {
      try {
        await deleteSubtrabajo({ subtrabajoId });
        this.subtrabajosTemporal = this.subtrabajosTemporal.filter(
          (st) => st.id !== subtrabajoId
        );
        this.isLoading = false;
        this.reloadTrabajos = true;
        this.showToast("Éxito", "Subtrabajo eliminado correctamente", "success");
      } catch (error) {
        this.isLoading = false;
        this.showToast("Error", error.body.message, "error");
      }
    }
  }

  async guardarSubtrabajos() {
    this.isLoading = true;

    const tieneUtsCeroONulo = this.subtrabajosTemporal.some(
        subtrabajo => subtrabajo.uts === 0 || subtrabajo.uts === null || isNaN(subtrabajo.uts)
    );

    if (tieneUtsCeroONulo) {
        this.isLoading = false;
        this.showToast("Error Cantidad", 'Debe ingresar un valor mayor a 0 para el campo Cantidad', "error");
        return;
    }

    try {
        const datosEnvio = {
            trabajoId: this.trabajoSeleccionado.id,
            tipoDeTrabajoId: this.trabajoSeleccionado.nombre,
            subtrabajos: this.subtrabajosTemporal.map(st => ({
                id: st.id,
                nombre: st.nombre || '',
                tipoTrabajo: st.tipoTrabajo || '',
                uts: st.uts || 0,
                alias: st.alias || '',
                manoDeObra: st.manoDeObra || null
            })),
            caseId: this.recId,
            workOrderId: this.trabajoSeleccionado.workOrderId || this.selectedWorkOrderId,
            prioridad: this.trabajoSeleccionado.prioridad || 'Sugerido',
            tipodecargo: this.trabajoSeleccionado.tipoCargo || 'Cliente',
            aseguradora: this.trabajoSeleccionado.aseguradora || null,
            centrodecosto: this.trabajoSeleccionado.centroDeCostos || null
        };

        await saveSubtrabajos(datosEnvio);

        const trabajosActualizados = await getTrabajos({ casoId: this.recId });

        const trabajoActualizado = trabajosActualizados?.find(t => t.id === this.trabajoSeleccionado.id);
        console.log('trabajoActualizado ',trabajoActualizado);
        if (!trabajoActualizado) {
            throw new Error('No se encontró el trabajo actualizado');
        }
        this.subtrabajosTemporal = (trabajoActualizado.subtrabajos || []).map(st => ({
            ...st,
            selectedTipoTrabajo: st.tipoTrabajoNombre
                ? { id: st.tipoTrabajoNombre, title: st.tipoTrabajoNombre }
                : { id: '', title: '' }
        }));

        this.showToast("Éxito", "Subtrabajos guardados correctamente", "success");
        this.reloadTrabajos = true;
        this.disabledSubtrabajosButton = this.subtrabajosTemporal.length === 0;
        this.agregarFilaSubtrabajo();

    } catch (error) {
        console.error('Error al guardar subtrabajos:', error);
        this.showToast("Error", error.body?.message || error.message, "error");
    } finally {
        this.isLoading = false;
    }
}


  notifyUser(title, message, variant) {
    const toastEvent = new ShowToastEvent({
      title,
      message,
      variant
    });
    this.dispatchEvent(toastEvent);
  }

  showToast(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title,
        message,
        variant,
      })
    );
  }
}