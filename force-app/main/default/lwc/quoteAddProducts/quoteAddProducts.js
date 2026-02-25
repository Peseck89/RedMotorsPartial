import { LightningElement, api, track, wire } from 'lwc';
import {loadStyle} from 'lightning/platformResourceLoader';
import screenActionCss from '@salesforce/resourceUrl/ScreenQuickActionLwc' 
import searchProducts from "@salesforce/apex/QLIGridController.searchProducts";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveLines from '@salesforce/apex/QLIGridController.saveQlis';
import findTrabajos from '@salesforce/apex/QLIGridController.findTrabajos';
import getQlis from '@salesforce/apex/QLIGridController.getQlis';
import deleteQli from '@salesforce/apex/QLIGridController.deleteQlis';
import { getRecord } from "lightning/uiRecordApi";
import Id from '@salesforce/user/Id';
import CanDeleteWolis__c from '@salesforce/schema/User.CanDeleteWolis__c';
import CanDeleteWolisMo__c from '@salesforce/schema/User.CanDeleteWolisMo__c';
import CanEditSalePrice__c from '@salesforce/schema/User.Can_edit_sale_price__c';
import CanEditMOPrice__c from '@salesforce/schema/User.Can_edit_MO_price__c';
import deleteTrabajo from "@salesforce/apex/TrabajoQuoteController.deleteTrabajo";
import deleteSubtrabajo from "@salesforce/apex/TrabajoQuoteController.deleteSubtrabajo";
import getTrabajos from "@salesforce/apex/TrabajoQuoteController.getTrabajos";
import getUTSTipoTrabajo from "@salesforce/apex/TrabajoQuoteController.getUTSTipoTrabajo";
import saveTrabajo from "@salesforce/apex/TrabajoQuoteController.saveTrabajo";
import search from '@salesforce/apex/SampleLookupController.search';
import saveSubtrabajos from "@salesforce/apex/TrabajoQuoteController.saveSubtrabajos";
import archivarTarea from "@salesforce/apex/TrabajoQuoteController.archivarTarea";
import updateTareaPrioridad from "@salesforce/apex/TrabajoQuoteController.updateTareaPrioridad";
import getTiposTrabajoPorMO from '@salesforce/apex/QLIGridController.getTiposTrabajoPorMO';
import NAME_FIELD from '@salesforce/schema/tiposDeTrabajo__c.Name';

const TIPO_CARGO_OPTIONS = [
  { label: "Cliente",      value: "1" },
  { label: "Interno",      value: "2" },
  { label: "Aseguradora",  value: "3" },
  { label: "Garantía",     value: "4" },
  { label: "BSI",          value: "5" },
  { label: "BSI interno",  value: "6" },
];

const tipoCargoLabelByValue = TIPO_CARGO_OPTIONS.reduce((m,o)=> (m[o.value]=o.label,m), {});
const tipoCargoValueByLabel = TIPO_CARGO_OPTIONS.reduce((m,o)=> (m[o.label]=o.value,m), {});

function toTipoCargoValue(v) {
  if (v == null || v === '') return "1";
  const s = String(v).trim();
  if (tipoCargoLabelByValue[s]) return s;                 // ya es value
  return tipoCargoValueByLabel[s] || "1";                 // venía como label
}

function toTipoCargoLabel(v) {
  const val = toTipoCargoValue(v);
  return tipoCargoLabelByValue[val] || "Cliente";
}

export default class QuoteAddProducts extends LightningElement {
  @api recordId;
  @track modifiedList = [];
  linesIds = ['search'];
  @track deletelines = [];
  @track deleteQlis = [];

  //Permissions
  userId = Id;
  CanDeleteWolis__c;
  CanDeleteWolisMo__c;
  CanEditSalePrice__c;
  CanEditMOPrice__c;

  //Flags
  showDelete = false;
  showSearchModal = false;
  showMoveLines = false;
  showMoveLines2 = false;
  alreadyGetLines = false;
  @track vieneInicio = false;
  
  @track tareaNoSeleccionada = true;

  @track isLoaded = false;
  @track searchKeyTrabajo = '';
  @track searchTrabajoResults = [];
  @track prioridadSeleccionada = '';
  @track selectedTrabajoName = '';
  @track selectedTrabajoId = '';
  @track searchTrabajoTerm = ''; 
  @track collapsedByKey = {};

  yFields = [NAME_FIELD];
  @track reloadTrabajos = false; 
  @track trabajos = []; // Lista de trabajos a realizar
  @track trabajos2 = []; 
  @track showModal = false; // Controla la visibilidad del modal de subtrabajos
  @track subtrabajosTemporal = []; // Subtrabajos temporales para edición
  @track trabajoSeleccionado = {}; // Trabajo seleccionado para agregar subtrabajos
  @api recId; // Id del Caso (se recibe automáticamente si el LWC está en un record page)
  @track workOrderId;  
  @track isLoading = false;
  @track diabledTarea = false;
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
  @track disabeldTrabajosButton = false; // <- mantener nombre ya usado
  @track disabledSubtrabajosButton = false;
  @track firstScreen = false;
  @track crearTipoDeTrabajo = false;
  @track wiredWorkOrders;
  @track selectedWorkOrderId;
  @track isSavingTrabajo = false;
  @track workOrdersOptions = [];
  @track creacionTipoDeTrabajoSub = false;
  @track screenZero = true;
  @track taskGroups = [];
  @track currentTaskKey = null;
  @track priorityByKey = {};
  @track prioridadSelected = '';
  @track sendFromOtherMethod = false;
  @track recordatorio = false;
  @track showArchiveModal = false;
  @track selectedTipoCargoTop = "1";   
  @track selectedAprobadorTop  = "Asesor";

  prioridadOptions = [
    { label: "Sugerido", value: "Sugerido" },
    { label: "Necesario", value: "Necesario" },
    { label: "Recomendado", value: "Recomendado" },
  ];

  tipoCargoOptions = [
    { label: "Cliente", value: "1" },
    { label: "Garantía", value: "4" },
    { label: "BSI", value: "5" },
    { label: "Aseguradora", value: "3" },
    { label: "BSI interno", value: "6" },
    { label: "Interno", value: "2" },
  ];

  aprobadorOptions = [
    { label: "Asesor", value: "Asesor" },
    { label: "Cliente", value: "Cliente" },
  ];
  
  //SearchText
  emptyObject = {"isSearch": true, "aprobado": false, "Bodega": "", "bodegaID": "", "cantidad": 1, "cantidadDevolucion": 0, "cantidadDisponible": 0, "currencyCode": "", "despachoEmail": "", "discount": 0, "esKit": false, "estadoEntrega": "", "estadoReserva": "", "estadoSoftland": "", "ID": "search", "idExtBodega": "", "isClosed": false, "locations": [], "Name": "", "precio": 0, "priceBookEntry": "", "ProductCode": "", "productId": "", "productType": "","estadoAprobacion": "", "ProductXBodegaID": "", "quantityByLocation": {}, "softlandQuantities": [], "softlandQuantity": 0, "unitPrice": 0, "validated": false, "wolId": "", "isMO": false, "CanDeleteWolis__c": false, bodegas:[] };
  searchInput = '';

  //Excluded Types
  excludedTypes = ['mano de obra', 'subcontrato'];

  //Monto Total
  montoTotal = 0;
  currencyCode;
  @track tipoCargoByKey = {};   // key de tarea -> "1"…"6"
  @track aprobadorByKey = {};   // key de tarea -> "Asesor"/"Cliente"

  /*Wired functions*/
  @wire(getRecord, { recordId: Id, fields: [CanDeleteWolis__c,CanDeleteWolisMo__c,CanEditMOPrice__c,CanEditSalePrice__c]}) 
  userDetails({error, data}) {
    if (data) {
      this.CanDeleteWolis__c   = true; //data.fields.CanDeleteWolis__c.value;
      this.CanDeleteWolisMo__c = true;//data.fields.CanDeleteWolisMo__c.value;
      this.CanEditMOPrice__c   = true;//data.fields.Can_edit_MO_price__c.value;
      this.CanEditSalePrice__c = true; //data.fields.Can_edit_sale_price__c.value;
    } else if (error) {
      this.error = error ;
    }
  }

  connectedCallback(){
    this.modifiedList = [this.emptyObject];
    this.buildGroups();              
    loadStyle(this, screenActionCss);
  }

  async handleAddTarea() {
    try {
      await this.handleAddNewTarea();
    } catch (e) {
      const msg = this.reduceErrors ? this.reduceErrors(e) : (e?.body?.message || e?.message || 'Error');
      this.showToast("Error", msg, "error");
    }
  }

  toggleGroup(event) {
    const key = event.currentTarget.dataset.task;
    const grp = (this.taskGroups || []).find(g => g.key === key);
    const cur = grp ? !!grp.isCollapsed : true;
    const next = !cur;

    this.collapsedByKey = { ...this.collapsedByKey, [key]: next };
    this.taskGroups = this.taskGroups.map(g =>
      g.key === key ? { ...g, isCollapsed: next } : g
    );
  }
  isPrincipalLine(item) {
    const t = item?.tareaId || null;
    const w = item?.trabajoARealizar || null;
    const s = item?.subTrabajoARealizar || null;
    return !!t && t === w && t === s;
  }
  normalizeId(v) {
    if (!v) return null;
    const s = String(v).trim();
    return s ? s.substring(0, 18) : null;
  }

  isPrincipalByTrabajo(item) {
    const tareaId   = this.normalizeId(item?.tareaId);
    const trabajoId = this.normalizeId(item?.trabajoARealizar);
    return !!tareaId && tareaId === trabajoId;
  }

  collapseAll() {
    const map = {};
    (this.taskGroups || []).forEach(g => { map[g.key] = true; });
    this.collapsedByKey = map;
    this.taskGroups = this.taskGroups.map(g => ({ ...g, isCollapsed: true }));
  }
  expandAll() {
    this.collapsedByKey = {};
    this.taskGroups = this.taskGroups.map(g => ({ ...g, isCollapsed: false }));
  }

  async handleAddNewTarea() {
    this.isLoaded = true;
    this.tareaNoSeleccionada = false;
    try {
      const id = await saveTrabajo({
        trabajo: {
          id: null,
          prioridad: this.prioridadSeleccionada,
          alias: this.selectedTrabajoName,
          tipoTrabajo: this.selectedTrabajoId,
          tipoCargo: toTipoCargoLabel(this.selectedTipoCargoTop || '1'),
          aprobador: this.selectedAprobadorTop || 'Asesor',
          uts: -1
        },
        quoteId: this.recordId
      });
      if(id == null){
        this.showToast("Error tarea duplicada", 'Ya existe esta tarea agregada al presupuesto', "error");
      }else{
        this.showToast("Éxito", "Tarea guardada correctamente", "success");
        this.sendFromOtherMethod = true;
        this.handleGetQlis();
        this.selectedTrabajoId = '';
        this.selectedTrabajoName = '';
      }
    } catch (error) {
      this.showToast("Error al guardar la Tarea", 'No hay pricebook entry para esta tarea', "error");
    } finally {
      this.isLoaded = false;
    }
  }

  sanitizeLinesForServer(lines) {
    return lines.map(src => {
      const it = { ...src };
      delete it.locations;            
      delete it.bodegas;              
      delete it.quantityByLocation;  
      delete it.softlandQuantities;   
      delete it.available;           
      delete it.validated;            
      delete it.isSearch;             
      delete it.isChecked;            
      if (it.unitPrice === '' || it.unitPrice == null) it.unitPrice = 0;
      if (it.cantidad   === '' || it.cantidad   == null) it.cantidad   = 0;
      if (it.discount   === '' || it.discount   == null) it.discount   = 0;
      return it;
    });
  }

  handleTipoCargoChangeUno = (evt) => {
    this.selectedTipoCargoTop = evt.detail.value;
  };

  handleAprobadorChangeUno = (evt) => {
    this.selectedAprobadorTop = evt.detail.value;
  };

  buildGroups() {
    const rows = (this.modifiedList || []).filter(r => r && r.ID !== 'search');

    const buckets = new Map();
    for (const r of rows) {
      const key  = r.tareaId   || 'NO_TASK';
      const name = r.tareaName || 'Sin tarea';
      if (!buckets.has(key)) buckets.set(key, { key, name, items: [] });
      buckets.get(key).items.push(r);
    }

    const typeOrder = (t) => {
      const v = (t || '').toString().toLowerCase();
      if (v.includes('material')) return 0;
      if (v.includes('mano'))     return 1;
      return 2;
    };

    const collapsed = this.collapsedByKey || {};
    const priority  = this.priorityByKey  || {};

    const groups = Array.from(buckets.values()).map(g => {
      g.items.sort((a, b) => {
        const ta = typeOrder(a.productType);
        const tb = typeOrder(b.productType);
        if (ta !== tb) return ta - tb;
        return (a.Name || '').localeCompare(b.Name || '');
      });
      g.isDefaultMostrador = g.items.some(it => !!it.defaultMostrador);
      const acc = g.items.reduce((a, it) => {
        const qty   = Number(it.cantidad)  || 0;
        const price = Number(it.unitPrice) || 0;
        a.amount += price * qty;
        return a;
      }, { amount: 0 });

      g.currencyCode = g.items[0]?.currencyCode || '';
      g.totalAmount  = Math.round(acc.amount * 100) / 100;
      g.lineCount    = g.items.length;

      let seed = priority[g.key];
      if (!seed) {
        const mo = g.items.find(x =>
          ((x.productType || '').toLowerCase().includes('mano')) && x.prioridad
        );
        seed = (mo && mo.prioridad)
            || (g.items.find(x => x.prioridad)?.prioridad)
            || 'Necesario';
        priority[g.key] = seed;
      }
      g.prioridad = seed;
      g.prioridadIsNecesario   = seed === 'Necesario';
      g.prioridadIsSugerido    = seed === 'Sugerido';
      g.prioridadIsRecomendado = seed === 'Recomendado';
      g.prioridadClass = this.computePrioridadClass(seed);
      const principal =
        g.items.find(it => this.isPrincipalByTrabajo(it))       // tarea == trabajo
        || g.items.find(it => this.isPrincipalLine && this.isPrincipalLine(it)); // fallback (tarea == trabajo == sub)

      let estado = principal?.estadoAprobacion || '';

      // (Opcional) si no hay principal, deriva un estado agregado simple:
      if (!estado) {
        if (g.items.some(it => (it.estadoAprobacion || '').toLowerCase() === 'rechazado')) {
          estado = 'Rechazado';
        } else if (g.items.some(it => (it.estadoAprobacion || '').toLowerCase() === 'pendiente')) {
          estado = 'Pendiente';
        } else if (g.items.some(it => (it.estadoAprobacion || '').toLowerCase() === 'aprobado')) {
          estado = 'Aprobado';
        } else {
          estado = ''; // sin estado
        }
      }

      g.estadoAprobacion = estado;
      g.estadoAprobacionClass = this.computeEstadoAprobacionClass(estado);
      // Normalización de Tipo de cargo (UI usa value "1"…"6")
     const firstItem = g.items[0] || {};
      const tLocal = (this.trabajos || []).find(x => x.id === g.key);

      // 1) desde trabajos (puede venir como value o label)
      let seedCargo = tLocal?.tipoCargo; // puede ser "1"… "6" o label
      let seedAprob = tLocal?.aprobador;

      // 2) si no hay en trabajos, usar lo que recolectamos de las líneas
      if (!seedCargo && this.tipoCargoByKey && this.tipoCargoByKey[g.key]) {
        seedCargo = this.tipoCargoByKey[g.key]; // value seguro
      }
      if (!seedAprob && this.aprobadorByKey && this.aprobadorByKey[g.key]) {
        seedAprob = this.aprobadorByKey[g.key]; // label seguro
      }

      // 3) si aún no hay, escanear cualquier línea del grupo (no solo la primera)
      if (!seedCargo) {
        const anyWithCargo = g.items.find(it => it && it.tipoCargo);
        if (anyWithCargo) seedCargo = anyWithCargo.tipoCargo; // label
      }
      if (!seedAprob) {
        const anyWithAprob = g.items.find(it => it && it.Aprobador);
        if (anyWithAprob) seedAprob = anyWithAprob.Aprobador; // label
      }

      // 4) normalizar y defaults
      g.tipoCargo = toTipoCargoValue(seedCargo || 'Cliente'); // UI necesita value "1"…"6"
      g.aprobador = (seedAprob || 'Asesor').trim();
      const hasState = Object.prototype.hasOwnProperty.call(collapsed, g.key);
      g.isCollapsed = hasState ? collapsed[g.key] : true;
      if (!hasState) collapsed[g.key] = g.isCollapsed;

      return g;
    }).sort((a, b) => a.name.localeCompare(b.name));

    this.taskGroups     = groups;
    this.priorityByKey  = { ...priority };
    this.collapsedByKey = { ...collapsed };
  }

  handleTipoCargoChangeDos = (evt) => {
    const key = evt.currentTarget.dataset.task;
    const valueCode = evt.detail.value;               // "1"…"6"
    const valueLabel = toTipoCargoLabel(valueCode);   // "Cliente", etc.

    // UI del grupo
    this.taskGroups = this.taskGroups.map(g =>
      g.key === key ? { ...g, tipoCargo: valueCode } : g
    );

    // Trabajos (coherente con UI: value)
    this.trabajos = (this.trabajos || []).map(t =>
      t.id === key ? { ...t, tipoCargo: valueCode } : t
    );

    // QLIs: guardo **label** en tipoCargo__c
    this.applyCargoAprobadorToQlis(key, valueLabel, null);

    this.buildGroups();
  };

  handleAprobadorChangeDos = (evt) => {
    const key = evt.currentTarget.dataset.task;
    const value = evt.detail.value; // "Asesor" / "Cliente"

    this.taskGroups = this.taskGroups.map(g =>
      g.key === key ? { ...g, aprobador: value } : g
    );

    this.trabajos = (this.trabajos || []).map(t =>
      t.id === key ? { ...t, aprobador: value } : t
    );

    this.applyCargoAprobadorToQlis(key, null, value);
    this.buildGroups();
  };

  applyCargoAprobadorToQlis(taskKey, tipoCargoLabelOrNull, aprobadorOrNull) {
    const updated = (this.modifiedList || []).map(it => {
      if (!it || it.ID === 'search') return it;
      const isFromTask = (it.tareaId || 'NO_TASK') === taskKey;
      if (!isFromTask) return it;
      const patched = { ...it };
      if (tipoCargoLabelOrNull !== null && tipoCargoLabelOrNull !== undefined) {
        patched.tipoCargo__c = tipoCargoLabelOrNull;   // para DML
        patched.tipoCargo    = tipoCargoLabelOrNull;   // para UI (buildGroups)
      }
      if (aprobadorOrNull !== null && aprobadorOrNull !== undefined) {
        patched.Aprobador__c = aprobadorOrNull;        // para DML
        patched.Aprobador    = aprobadorOrNull;        // para UI
      }
      return patched;
    });
    this.modifiedList = updated;
  }

  handleAddLineByTask(evt){
    this.currentTaskKey = evt.currentTarget.dataset.task;
    this.handleSearch();
  }

  handleAdvancedSearchByTask(evt){
    this.currentTaskKey = evt.currentTarget.dataset.task;
    this.handleShowSearch();
  }

  handleGetTrabajosByTask(evt){
    this.currentTaskKey = evt.currentTarget.dataset.task;
    this.handleGetTrabajos();
  }
  
  handleArchivarTarea(evt) {
    this.currentTaskKey = evt.currentTarget.dataset.task;
    this.showArchiveModal = true; 
  }

  handleArchiveOnly() {
    if (this.isLoaded) return;
    this.recordatorio = false;
    this.showArchiveModal = false;
    this.handleArchivar();
  }

  handleArchiveWithReminder() {
    if (this.isLoaded) return;
    this.recordatorio = true;
    this.showArchiveModal = false;
    this.handleArchivar();
  }

  handleCancelArchive() {
    this.showArchiveModal = false;
  }

  handleSearchText(event){
    this.modifiedList[0].ProductCode = event.currentTarget.value;
    this.searchInput = event.currentTarget.value;
  }

  get comboboxClass() {
    return 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open';
  }
  get hasSearchRow() {
    return Array.isArray(this.modifiedList) && this.modifiedList.length > 0 && this.modifiedList[0]?.isSearch;
  }
  get searchRow() {
    return this.hasSearchRow ? this.modifiedList[0] : {};
  }

  handleSearchTrabajoChange(event) {
    this.selectedTrabajoName = event.target.value; 
    this.searchKeyTrabajo = event.target.value;

    if (this.searchKeyTrabajo.length > 1) { 
      findTrabajos({ searchKeyTrabajo: this.searchKeyTrabajo })
        .then(result => { this.searchTrabajoResults = result; })
        .catch(() => { this.searchTrabajoResults = []; });
    } else {
      this.searchTrabajoResults = [];
    }
  }

  handleSelectTrabajo(event) {
    const selectedId = event.currentTarget.dataset.id;
    const selected = this.searchTrabajoResults.find(t => t.Id === selectedId);
    if (selected) {
      this.selectedTrabajoName = selected.Name;
      this.selectedTrabajoId = selectedId;
      this.searchKeyTrabajo = selected.Name;
      this.searchTrabajoResults = [];
      this.tareaNoSeleccionada = false;
      this.prioridadSeleccionada = 'Necesario';
    } else {
      this.tareaNoSeleccionada = true;
    }
  }

  handleSearch() {
  const searchinput = this.searchInput;
  searchProducts({ productType: '', queryValue: searchinput, quote: this.recordId })
    .then(async (result) => {
      if (!result || !result.length) return; // sin resultados
      let tmpObject = { ...result[0] };
      tmpObject.ID = tmpObject.ID + this.modifiedList.length;

      // Si viene de una tarea, igual que antes
      if (this.currentTaskKey && this.currentTaskKey !== 'NO_TASK') {
        tmpObject.tareaId = this.currentTaskKey;
        const grp = this.taskGroups.find(g => g.key === this.currentTaskKey);
        if (grp) {
          tmpObject.tipoCargo__c = toTipoCargoLabel(grp.tipoCargo);
          tmpObject.tipoCargo    = toTipoCargoLabel(grp.tipoCargo);
          tmpObject.Aprobador__c = grp.aprobador || 'Asesor';
          tmpObject.Aprobador    = grp.aprobador || 'Asesor';
          tmpObject.tareaName    = grp.name;
        }
      }

      // *** NUEVO: si es Mano de Obra, resolver Trabajo/Subtrabajo
      if ((tmpObject.productType || '').toLowerCase() === 'mano de obra' && tmpObject.productId) {
        try {
          const mapa = await getTiposTrabajoPorMO({ product2Ids: [tmpObject.productId] });
          const ttId = mapa ? mapa[tmpObject.productId] : null;
          if (ttId) {
            tmpObject.trabajoARealizar    = ttId;
            tmpObject.subTrabajoARealizar = ttId;
          } else {
            // si no hay mapeo, decidir si se agrega algun mensaje de error
           
          }
        } catch (e) {
          // opcional: toast de error
        }
      }

      this.validateUserAccess(tmpObject);
      this.updateLocationsForObject(tmpObject);
      this.modifiedList.push(tmpObject);
      this.linesIds = this.extractIDs(this.modifiedList);
      this.calculateMontoTotal();
      this.buildGroups();
    })
    .catch((error) => {
      this.error = error;
      this.productListResponse = undefined;
    });
}

  async handleArchivar() {
    this.isLoaded = true;
    try {
      await archivarTarea({ quoteId: this.recordId, tareaId: this.currentTaskKey, recordatorio: this.recordatorio });
      this.showToast("Éxito", "Tarea archivada correctamente", "success");
    } catch (e) {
      this.showToast("Error", e?.body?.message || e?.message || e, "error");
    } finally {
      this.sendFromOtherMethod = true;
      this.handleGetQlis();
      this.isLoaded = false;
    }
  }

  async handleGetTrabajos() {
    this.firstScreen = true;
    this.screenZero = false;
    await this.loadTrabajosAndMerge();
    this.ensureOneBlankTrabajo();
    const hasBlank = (this.trabajos || []).some(t => this.isBlankTrabajo(t));
    this.disabeldTrabajosButton = hasBlank;   
  }

  isBlankTrabajo(t) {
    return String(t.id).startsWith('local-')
      && !(t.selectedTrabajoId || (t.selectedTrabajo && t.selectedTrabajo.id))
      && !(t.nombreTrabajo || t.nombre)  
      && (!t.uts || Number(t.uts) === 0)
      && (!t.subtrabajos || t.subtrabajos.length === 0)
      && !(t.alias && t.alias.trim());
  }

  buildBlankTrabajoRow() {
    return {
      id: `local-${this.nextTrabajoId++}`,
      checked: false,
      prioridad: this.prioridadSeleccionada || 'Necesario',
      nombreTrabajo: '',
      alias: '',
      selectedTrabajo: { id: '', title: '' },
      selectedTrabajoId: null,
      selectedTrabajoName: null,
      tipoCargo: '1',
      aprobador: 'Asesor',
      workOrderId: this.workOrderId,
      isButtonDisabled: true,
      uts: 0,
      utsReal: 0,
      subtrabajos: [],
    };
  }

  ensureOneBlankTrabajo() {
    const arr = this.trabajos || [];
    const blanks = arr.filter(t => this.isBlankTrabajo(t));
    if (blanks.length === 0) {
      this.trabajos = [...arr, this.buildBlankTrabajoRow()];
    } else if (blanks.length > 1) {
      const firstBlankId = blanks[0].id;
      this.trabajos = arr.filter(t => !this.isBlankTrabajo(t) || t.id === firstBlankId);
    }
  }

  handleCancelar(){
    this.firstScreen = false;
    this.screenZero = true;
    this.selectedTrabajoId = '';
    this.selectedTrabajoName = '';
    this.reloadLines(); 
  }

  handleOrdenSelection(event){
    const id = event.target.dataset.id;
    this.updateTrabajo(id, "workOrderId", event.detail.value);
  }

  handleCancelTrabajo(){
    if(this.vieneInicio == true){
      this.screenZero = true;
      this.vieneInicio = false;
    }else{
      this.firstScreen = true;
    }
    this.creacionTipoDeTrabajo = false;
  }
  handleCancelTrabajoSub(){
    this.creacionTipoDeTrabajoSub = false;
  }
  handleCrearNT(){
    this.vieneInicio = true;
    this.screenZero = false;
    this.creacionTipoDeTrabajo = true;
  }
  handleCrear(){
    this.firstScreen = false;
    this.creacionTipoDeTrabajo = true;
  }
  handleCrearSub(){
    this.creacionTipoDeTrabajoSub = true;
  }

  handleSuccessTrabajo(event) {
    this.dispatchEvent(new ShowToastEvent({
      title: 'Registro correcto',
      message: 'Record ID: ' + event.detail.id,
      variant: 'success',
    }));
    if(this.vieneInicio == true){
      this.screenZero = true;
      this.vieneInicio = false;
    }else{
      this.firstScreen = true;
    }
    this.creacionTipoDeTrabajo = false;
  }

  handleSuccessTrabajoSub(event){
    this.dispatchEvent(new ShowToastEvent({
      title: 'Registro correcto',
      message: 'Record ID: ' + event.detail.id,
      variant: 'success',
    }));
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
        if(results && results >0){
          this.updateTrabajo(id, "disabledUts", true);
          let utsRealF = Math.round(results * 12);
          this.updateTrabajo(id, "utsReal", utsRealF);
        }else{
          this.updateTrabajo(id, "disabledUts", false);
        }
      });
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
      this.updateTrabajo(id, "aseguradora", null);
      this.updateTrabajo(id, "selectedAseguradora", { id: null, title: null });
    }
  }

  getEstadoTextClass(status) {
    const s = (status || '').toLowerCase();
    if (s === 'aprobado')  return 'slds-text-color_success slds-text-title_bold';
    if (s === 'pendiente') return 'slds-text-color_warning slds-text-title_bold';
    if (s === 'rechazado') return 'slds-text-color_error slds-text-title_bold';
    return '';
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
          this.updateSubtrabajoTemporal(id, "disabledUts", !!results && results > 0);
        });

      if (selectedRecord) {
        this.updateSubtrabajoTemporal(id, "selectedTipoTrabajo", { id: selectedValue, title: selectedRecord.title });
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
    if (firedElement.includes('Aseguradora2'))  firedElement = firedElement.replace('Aseguradora2', 'Aseguradora');
    if (firedElement.includes('CentroCosto2'))  firedElement = firedElement.replace('CentroCosto2', 'CentroCosto');
    if (firedElement.includes('SubTipoDeTrabajo2')) firedElement = firedElement.replace('SubTipoDeTrabajo2', 'SubTipoDeTrabajo');
    if (firedElement.includes('TipoDeTrabajo3')) firedElement = firedElement.replace('TipoDeTrabajo3', 'TipoDeTrabajo');
    if (firedElement.includes('TipoDeTrabajo4')) firedElement = firedElement.replace('TipoDeTrabajo4', 'TipoDeTrabajo');
    var paramenters = event.detail;
    paramenters["firedElement"] = firedElement;
    paramenters["caseId"] = this.recId;
    search(paramenters)
      .then((results) => { lookupElement.setSearchResults(results); })
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
        tipoCargo: "1",
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
    const trabajo = this.trabajos.find((t) => t.id === trabajoId);

    if(trabajo.selectedTrabajoId == null || trabajo.selectedTrabajoId == ''){
      trabajo.selectedTrabajoId = trabajo.nombre;
    }
    if(trabajo.uts == null || trabajo.uts == 0){
      this.isLoading = false;
      this.showToast("Error Cantidad", 'Debe ingresar un valor mayor a 0 para el campo Cantidad', "error");
      return;
    }

    try {
      await saveTrabajo({
        trabajo: {
          id: trabajo.id.startsWith("local") ? null : trabajo.id,
          prioridad: trabajo.prioridad,
          alias: trabajo.alias,
          tipoTrabajo: trabajo.selectedTrabajoId,
          tarea: this.currentTaskKey,
          tipoCargo: toTipoCargoLabel(trabajo.tipoCargo), // label al server
          aprobador: trabajo.aprobador,
          uts: trabajo.uts,
          totalSubtrabajos: trabajo.totalSubtrabajos ? trabajo.totalSubtrabajos : 1,
        },
        quoteId: this.recordId
      });
      if(trabajo.id.startsWith("local")){
        this.disabeldTrabajosButton = false;
      }
      this.showToast("Éxito", "Trabajo guardado correctamente", "success");
      this.isSavingTrabajo = true;
      await this.refreshAfterSaveTrabajo();
      this.isLoading = false;
    } catch (error) {
      this.isLoading = false;
      this.showToast("Error", error?.body?.message || error?.message || 'Error', "error");
    }
  }

  appendBlankTrabajoRow() {
    this.trabajos = [
      ...(this.trabajos || []),
      {
        id: `local-${this.nextTrabajoId++}`,
        checked: false,
        prioridad: this.prioridadSeleccionada || 'Necesario',
        nombre: 'Nuevo Trabajo',
        tipoCargo: '1',
        aprobador: 'Asesor',
        workOrderId: this.workOrderId,
        isButtonDisabled: true,
        selectedTrabajo: { id: '', title: '' },
        uts: 0,
        utsReal: 0,
        subtrabajos: [],
      },
    ];
    this.disabeldTrabajosButton = true;
  }

  async refreshAfterSaveTrabajo() {
    await this.loadTrabajosAndMerge();
    this.trabajos = (this.trabajos || []).filter(t => !String(t.id).startsWith('local-'));
    this.appendBlankTrabajoRow();
    this.selectedTrabajoId = '';
    this.selectedTrabajoName = '';
  }

  handleCancelarSubTrabajo() {
    if(this.reloadTrabajos == true){
      this.loadTrabajosAndMerge();
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
    const tipoCargoValue = event.detail.value; // "1"…"6"
    const label = toTipoCargoLabel(tipoCargoValue);
    const mostrarAseguradora   = (label === 'Aseguradora');
    const mostrarCentroDeCostos = (label === 'Interno');

    this.trabajos = this.trabajos.map((trabajo) =>
      trabajo.id === id
        ? { ...trabajo, tipoCargo: tipoCargoValue, mostrarAseguradora, mostrarCentroDeCostos }
        : trabajo
    );
    this.updateTrabajo(id, "tipoCargo", tipoCargoValue);
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
    this.subtrabajosTemporal = JSON.parse(JSON.stringify(this.trabajoSeleccionado.subtrabajos));
    if (this.subtrabajosTemporal.length > 0) {
      this.disabledSubtrabajosButton = false;
    }
    if (this.subtrabajosTemporal.length === 0) {
      this.disabledSubtrabajosButton = true;
      if(this.trabajoSeleccionado.nombre != null){
        this.subtrabajosTemporal = [
          ...this.subtrabajosTemporal,
          {
            id: `local-sub-${this.nextSubtrabajoId++}`,
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
      } else {
        this.subtrabajosTemporal = [
          ...this.subtrabajosTemporal,
          {
            id: `local-sub-${this.nextSubtrabajoId++}`,
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
        id: `local-sub-${this.nextSubtrabajoId++}`,
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
        await deleteTrabajo({  trabajoId: trabajoId, quoteId: this.recordId  });
        this.trabajos = this.trabajos.filter((t) => t.id !== trabajoId);
        const tieneIdNulo = this.trabajos.some((t) => t.id.startsWith("local"));
        this.disabeldTrabajosButton = tieneIdNulo ? true : false;
        this.showToast("Éxito", "Trabajo eliminado correctamente", "success");
        this.isLoading = false;
      } catch (error) {
        this.isLoading = false;
        this.showToast("Error", error?.body?.message || error?.message || 'Error', "error");
      }
    }
  }

  async handleDeleteSubtrabajo(event) {
    this.isLoading = true;
    const subtrabajoId = event.target.dataset.id;
    if (subtrabajoId.startsWith("local")) {
      this.subtrabajosTemporal = this.subtrabajosTemporal.filter((st) => st.id !== subtrabajoId);
      this.isLoading = false;
    } else {
      try {
        await deleteSubtrabajo({ subtrabajoId: subtrabajoId, quoteId: this.recordId });
        this.subtrabajosTemporal = this.subtrabajosTemporal.filter((st) => st.id !== subtrabajoId);
        this.isLoading = false;
        this.reloadTrabajos = true;
        this.showToast("Éxito", "Subtrabajo eliminado correctamente", "success");
      } catch (error) {
        this.isLoading = false;
        this.showToast("Error", error?.body?.message || error?.message || 'Error', "error");
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
        tareaId: this.currentTaskKey,
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
        quoteId: this.recordId,
        prioridad: this.trabajoSeleccionado.prioridad || 'Sugerido',
        tipodecargo: toTipoCargoLabel(this.trabajoSeleccionado.tipoCargo || '1') // label para server
      };

      await saveSubtrabajos(datosEnvio);

      const trabajosActualizados = await getTrabajos({ quoteId: this.recordId, tareaId: this.currentTaskKey });
      const trabajoActualizado = trabajosActualizados?.find(t => t.id === this.trabajoSeleccionado.id);

      this.showToast("Éxito", "Subtrabajos guardados correctamente", "success");
      this.reloadTrabajos = true;
      this.disabledSubtrabajosButton = this.subtrabajosTemporal.length === 0;
      this.agregarFilaSubtrabajo();

    } catch (error) {
      this.showToast("Error", error?.body?.message || error?.message || "Error al guardar subtrabajos", "error");
    } finally {
      this.isLoading = false;
    }
  }

  notifyUser(title, message, variant) {
    const toastEvent = new ShowToastEvent({ title, message, variant });
    this.dispatchEvent(toastEvent);
  }

  handleGetQlis(){
    let linesRaw = this.modifiedList.filter(obj => obj.ID !== "search");
    const lines = this.sanitizeLinesForServer(linesRaw);
    getQlis({ listTosave: JSON.stringify(lines), quote:this.recordId})
      .then((result) => {
        this.alreadyGetLines = true;
        this.modifiedList = JSON.parse(JSON.stringify(result));
        this.modifiedList.unshift(this.emptyObject);
        this.linesIds = this.extractIDs(this.modifiedList);
        this.updateLocations(this.modifiedList);
        if(this.sendFromOtherMethod == false){
          this.setMessageShow('Success!','Las líneas se obtuvieron correctamente!','success');
        }else{
          this.sendFromOtherMethod = false;
        }
        const byKey = {};
        for (const r of this.modifiedList) {
          if (!r || r.ID === 'search') continue;
          const key = r.tareaId || 'NO_TASK';
          if (!byKey[key] && r.prioridad) {
            byKey[key] = r.prioridad;
          }
        }
        this.priorityByKey = byKey;
        this.modifiedList.forEach(currentItem => {
          this.validateUserAccess(currentItem);
        });
        this.buildGroups();              
      })
      .catch(() => {
        this.setMessageShow('Ups!', 'Algo no salió bien, no se pudieron obtener las líneas del presupuesto','warning');
      })
      .finally(() => {
  this.showReserveButton = true;
  this.calculateMontoTotal();

  // 🔎 Construir mapas robustos por tarea a partir de las líneas
  const cargoByKey = {};
  const aprobByKey = {};
  for (const r of (this.modifiedList || [])) {
    if (!r || r.ID === 'search') continue;
    const key = r.tareaId || 'NO_TASK';

    // tomar el primer no vacío que encontremos
    if (!cargoByKey[key] && r.tipoCargo) {
  cargoByKey[key] = toTipoCargoValue(String(r.tipoCargo));  
}
if (!aprobByKey[key] && r.Aprobador) {
  aprobByKey[key] = String(r.Aprobador).trim();               
}
  }
  // merge con lo que ya teníamos (sin pisar lo existente)
  this.tipoCargoByKey = { ...cargoByKey, ...(this.tipoCargoByKey || {}) };
  this.aprobadorByKey = { ...aprobByKey, ...(this.aprobadorByKey || {}) };

  this.buildGroups();
});

  }

  handleDeleteLine(event) {
    var deletelines1 = [];
    this.deletelines.forEach(currentItem => {
      deletelines1.push(currentItem.substring(0,18));
      this.modifiedList.splice(this.linesIds.indexOf(currentItem), 1);
      this.linesIds.splice(this.linesIds.indexOf(currentItem), 1);
    });
    deleteQli({quoteIds:deletelines1}) 
      .then(() => {})
      .catch((error) => {
        let message = error?.body?.pageErrors?.[0]?.message;
        this.error = error;
        this._title = message || 'Ups!';
        this.message = message ? '' : 'Algo no salió bien, la linea no se eliminó';
        this.setMessageShow(this._title ,this.message,'error')                           
        this.showNotification && this.showNotification();
      })
      .finally(() => {
        this.calculateMontoTotal();
        this.buildGroups();              
      });
    this.deletelines=[];
    this.showDelete=(this.deletelines.length>0);
  }

  get disableDeleteButton() {
    return !this.showDelete;
  }

  handlecheck(event) {
    const id = String(event.currentTarget.dataset.id);

    const idx = this.modifiedList.findIndex(it => String(it.ID) === id);
    if (idx > -1) {
      const checked = !!event.target.checked;
      const updated = [...this.modifiedList];
      updated[idx] = { ...updated[idx], isChecked: checked };
      this.modifiedList = updated;
    }

    let modifiedIndex = this.linesIds.indexOf(id);
    if (event.target.checked) {
      this.deletelines.push(id);
      if (this.modifiedList[modifiedIndex]?.qolId) {
        this.deleteQlis.push(this.modifiedList[modifiedIndex].qolId);
      }
    } else {
      modifiedIndex = this.deletelines.indexOf(id);
      if (modifiedIndex > -1) this.deletelines.splice(modifiedIndex, 1);
      modifiedIndex = this.deleteQlis.indexOf(id);
      if (modifiedIndex > -1) this.deleteQlis.splice(modifiedIndex, 1);
    }
    this.showDelete   = this.deletelines.length > 0;
    this.showMoveLines = this.deletelines.length === 1;
  }

  async handleDeleteLinesByTask(evt) {
    const taskKey = evt.currentTarget.dataset.task || 'NO_TASK';
    this.isLoaded = true;

    const selectedInTask = (this.modifiedList || [])
      .filter(it => it && it.ID !== 'search'
        && String(it.isChecked) === 'true'
        && (it.tareaId || 'NO_TASK') === taskKey);

    if (!selectedInTask.length) {
      this.showToast('Sin selección', 'Seleccione al menos una línea de esta tarea', 'warning');
      this.isLoaded = false;
      return;
    }

    const deletable = selectedInTask.filter(it => it.CanDeleteWolis__c && !it.isClosed);
    const blocked   = selectedInTask.filter(it => !(it.CanDeleteWolis__c && !it.isClosed));

    if (blocked.length) {
      this.showToast(
        'Aviso',
        'Algunas líneas no se pueden eliminar (reservadas, cerradas o sin permiso). Se eliminarán solo las permitidas.',
        'warning'
      );
    }
    if (!deletable.length) {
      this.isLoaded = false;
      return;
    }

    const serverIds = deletable
      .filter(it => !!it.qolId)
      .map(it => (it.qolId.length > 18 ? it.qolId.substring(0, 18) : it.qolId));
    const localIds  = deletable
      .filter(it => !it.qolId)
      .map(it => it.ID);

    try {
      if (serverIds.length) {
        await deleteQli({ quoteIds: serverIds });
      }

      const idsToRemove = new Set([...localIds, ...deletable.map(it => it.ID)]);
      this.modifiedList = (this.modifiedList || []).filter(it => !idsToRemove.has(it.ID));

      this.deletelines   = [];
      this.deleteQlis    = [];
      this.showDelete    = false;
      this.showMoveLines = false;

      this.linesIds = this.extractIDs(this.modifiedList);
      this.calculateMontoTotal();
      this.buildGroups();

      this.showToast('Éxito', `Se eliminaron ${deletable.length} línea(s) de la tarea`, 'success');
    } catch (error) {
      const msg = error?.body?.pageErrors?.[0]?.message
              || error?.body?.message
              || error?.message
              || 'No se pudieron eliminar las líneas';
      this.showToast('Error', msg, 'error');
    } finally {
      this.isLoaded = false;
    }
  }

  handleBodegaSelect(event){
    var newLocation = event.detail.value;
    var modifiedIndex = this.linesIds.indexOf(event.currentTarget.dataset.id); 
    this.updateCantidadDisponibleForObject(this.modifiedList[modifiedIndex], newLocation);
  }

  handleShowSearch(){
    this.showSearchModal=true;
  }
  
  handleCancelSearch(){
    this.showSearchModal = false;
  }
  
  handleSalePrice(event) {
    const modifiedIndex = this.linesIds.indexOf(event.currentTarget.dataset.id); 
    this.modifiedList[modifiedIndex].unitPrice = event.detail.value;
    this.calculateMontoTotal();
    this.buildGroups(); 
  }

  handleAlias(event) {
  const rowId = String(event.currentTarget.dataset.id);
  const value = event.detail?.value ?? event.currentTarget.value ?? '';
  const idx = this.modifiedList.findIndex(it => String(it.ID) === rowId);
  if (idx > -1) {
    const current = this.modifiedList[idx];
    this.modifiedList = [
      ...this.modifiedList.slice(0, idx),
      { ...current, alias: value },
      ...this.modifiedList.slice(idx + 1)
    ];
  }
}


  handleQuantity(event) {
    const idFromDom = String(event.currentTarget.dataset.id);
    const raw = event.detail?.value;
    const qty = raw === '' || raw === null || raw === undefined ? null : parseFloat(raw);
    if (qty === null || isNaN(qty)) {
      return;
    }
    const idx = this.modifiedList.findIndex(it => String(it.ID) === idFromDom);
    if (idx === -1) return;
    const updated = [...this.modifiedList];
    updated[idx] = { ...updated[idx], cantidad: qty };
    this.modifiedList = updated;
    this.linesIds = this.extractIDs(this.modifiedList);
    this.calculateMontoTotal();
    if (typeof this.buildGroups === 'function') {
      this.buildGroups();
    }
  }

  computeEstadoAprobacionClass(status) {
    const s = (status || '').toLowerCase();
    if (s === 'aprobado')  return 'slds-badge slds-theme_success';
    if (s === 'pendiente') return 'slds-badge slds-theme_warning';
    if (s === 'rechazado') return 'slds-badge slds-theme_error';
    return 'slds-badge';
  }


  handleAddLines(event) {
    const QuoteList = event.detail.message;
    this.showSearchModal = false;
    if (this.currentTaskKey && this.currentTaskKey !== 'NO_TASK') {
      const grp = this.taskGroups.find(g => g.key === this.currentTaskKey);
      QuoteList.forEach(it => {
        it.tareaId = this.currentTaskKey;
        if (grp) {
          it.tipoCargo__c = toTipoCargoLabel(grp.tipoCargo); // label
          it.tipoCargo    = toTipoCargoLabel(grp.tipoCargo);   
          it.Aprobador__c = grp.aprobador || 'Asesor';
          it.Aprobador    = grp.aprobador || 'Asesor';    
          it.tareaName = grp.name;
        }
      });
    }
    this.updateLocations(QuoteList);
    this.modifiedList = [...this.modifiedList, ...QuoteList];
    this.linesIds = this.extractIDs(this.modifiedList);
    this.calculateMontoTotal();
    this.buildGroups();
    this.currentTaskKey = null;                
  }

  @api async handleSaveGeneral() {
    if (this.isLoaded) return;           
    this.isLoaded = true;
    this.syncAliasesFromDOM();
    const allValid = [...this.template.querySelectorAll('lightning-input')]
      .reduce((ok, cmp) => (cmp.reportValidity(), ok && cmp.checkValidity()), true);

    if (!allValid) {
      this._title = 'Error!';
      this.message = 'Revise los campos señalados en ROJO';
      this.isLoaded = false;
      this.showNotification && this.showNotification();
      return;
    }

    try {
      const lines = this.modifiedList
        .filter(l => l.ID !== 'search')
        .map(({ locations, ...rest }) => rest);
      if (!lines.length) {
        this.navigateGeneral(); // hace reload
        return;
      }

      await saveLines({
        jsonString: JSON.stringify(lines),
        quote: this.recordId
      });

      this.modifiedList = this.modifiedList.filter(l => l.ID === 'search');

      this.setMessageShow('Guardado', 'Líneas agregadas', 'success');
      this.navigateGeneral();

    } catch (error) { 
      const message =
        error?.body?.pageErrors?.[0]?.message ||
        error?.body?.message ||
        error?.message ||
        'Algo no salió bien, consulte a su administrador';
      this.setMessageShow('Ups!', message, 'error');
      this.error = error;
    } finally {
      this.isLoaded = false;
    }
  }

  @api async handleSave() {
    if (this.isLoaded) return;          
    this.isLoaded = true;
    this.syncAliasesFromDOM();
    const allValid = [...this.template.querySelectorAll('lightning-input')]
      .reduce((ok, cmp) => (cmp.reportValidity(), ok && cmp.checkValidity()), true);

    if (!allValid) {
      this._title = 'Error!';
      this.message = 'Revise los campos señalados en ROJO';
      this.isLoaded = false;
      this.showNotification && this.showNotification();
      return;
    }

    try {
      const lines = this.modifiedList
        .filter(l => l.ID !== 'search')
        .map(({ locations, ...rest }) => rest);

      if (!lines.length) {
        this.isLoaded = false;
        return;
      }

      await saveLines({
        jsonString: JSON.stringify(lines),
        quote: this.recordId
      });

      this.modifiedList = this.modifiedList.filter(l => l.ID === 'search');

      await this.reloadLines(); // <- wrapper que llama a handleGetQlis()

      this.setMessageShow('Guardado', 'Líneas agregadas', 'success');

    } catch (error) {
      const message =
        error?.body?.pageErrors?.[0]?.message ||
        error?.body?.message ||
        error?.message ||
        'Algo no salió bien, consulte a su administrador';
      this.setMessageShow('Ups!', message, 'error');
      this.error = error;
    } finally {
      this.isLoaded = false;
    }
  }

  async reloadLines() {
    this.sendFromOtherMethod = true;
    await this.handleGetQlis();
  }

  extractIDs(data) {
    return data.map(item => item.ID);
  }
 handleRowTrabajoSelectionChange(event) {
  const rowId = String(event.target.dataset.id);

  // El c-lookup entrega el id en event.detail; si viene arreglo, toma el primero
  let selectedValue = event.detail;
  if (Array.isArray(selectedValue) && selectedValue.length > 0) {
    selectedValue = selectedValue[0];
  }

  // También toma el registro seleccionado para obtener el "title"
  const lookupElement = event.target;
  const selectedRecord = lookupElement.getSelection
    ? lookupElement.getSelection()[0]
    : null;

  const ttId   = this.normalizeId(selectedValue || (selectedRecord ? selectedRecord.id : null));
  const ttName = selectedRecord ? selectedRecord.title : '';

  const idx = this.modifiedList.findIndex(it => String(it.ID) === rowId);
  if (idx === -1) return;

  const updated = [...this.modifiedList];
  const it = { ...updated[idx] };

  it.trabajoARealizar     = ttId;
  it.subTrabajoARealizar  = ttId;
  it.trabajoARealizarName = ttName;
  it.selectedTrabajoRow   = (ttId && ttName) ? [{ id: ttId, title: ttName }] : [];

  const isMO = ((it.productType || '').toLowerCase().includes('mano'));
  it.renderTrabajoLookup = isMO && !this.isPrincipalByTrabajo(it);

  updated[idx] = it;
  this.modifiedList = updated;

  this.buildGroups && this.buildGroups();
}

  updateLocationsForObject(item) {
    if(!this.excludedTypes.includes((item.productType || '').toLowerCase())){
      if (item && item.bodegas) {
        const hasUruca = item.bodegas.some(bodega => bodega.name.includes("Uruca"));
        item.locations = item.bodegas
          .filter(bodega => bodega.isPrincipal || (hasUruca && bodega.name === "Bodega de Apartados"))
          .map(bodega => ({ label: bodega.name, value: bodega.name }));
      }
    }
    const isMO = ((item.productType || '').toLowerCase().includes('mano'));
  item.isMO = isMO;
  item.renderTrabajoLookup = isMO && !this.isPrincipalByTrabajo(item);

  item.selectedTrabajoRow = (item.trabajoARealizar && item.trabajoARealizarName)
    ? [{ id: this.normalizeId(item.trabajoARealizar), title: item.trabajoARealizarName }]
    : [];

    item.estadoAprobacionClass = this.computeEstadoAprobacionClass(item.estadoAprobacion);
  }

  get prioridadClass() {
    switch (this.prioridadSeleccionada) {
      case 'Necesario':   return 'custom-picklist texto-rojo';
      case 'Sugerido':    return 'custom-picklist texto-amarillo';
      case 'Recomendado': return 'custom-picklist texto-verde';
      default:            return 'custom-picklist';
    }
  }
  syncAliasesFromDOM() {
  // Baja los alias que estén en pantalla (aunque no hayan lanzado evento)
  const inputs = this.template.querySelectorAll('lightning-input[name="alias"][data-id]');
  if (!inputs) return;

  const mapById = new Map(this.modifiedList.map(it => [String(it.ID), it]));
  inputs.forEach(inp => {
    const rowId = String(inp.dataset.id);
    if (mapById.has(rowId)) {
      const row = mapById.get(rowId);
      // clonar inmutablemente
      const idx = this.modifiedList.findIndex(it => String(it.ID) === rowId);
      if (idx > -1) {
        const current = this.modifiedList[idx];
        this.modifiedList = [
          ...this.modifiedList.slice(0, idx),
          { ...current, alias: inp.value ?? '' },
          ...this.modifiedList.slice(idx + 1)
        ];
      }
    }
  });
}

  computePrioridadClass(value) {
    switch (value) {
      case 'Necesario':   return 'custom-picklist texto-rojo';
      case 'Sugerido':    return 'custom-picklist texto-amarillo';
      case 'Recomendado': return 'custom-picklist texto-verde';
      default:            return 'custom-picklist';
    }
  }

  handlePrioridadChangeUno(event) {
    this.prioridadSeleccionada = event.target.value;
  }

  handlePrioridadChangeDos(event) {
    const key = event.currentTarget.dataset.task; 
    const value = event.target.value;

    this.priorityByKey = { ...this.priorityByKey, [key]: value };

    this.taskGroups = this.taskGroups.map(g =>
      g.key === key
        ? { ...g, prioridad: value, prioridadClass: this.computePrioridadClass(value) }
        : g
    );
    this.currentTaskKey = key;
    this.prioridadSelected = value;
    this.handleChangePrioridadTarea();
  }

  async handleChangePrioridadTarea() {
    this.isLoaded = true;
    try {
      await updateTareaPrioridad({ quoteId: this.recordId, tareaId: this.currentTaskKey, prioridad: this.prioridadSelected });
      this.showToast("Éxito", "Prioridad de Tarea Actualizada correctamente", "success");
    } catch (e) {
      this.showToast("Error", e?.body?.message || e?.message || e, "error");
    } finally {
      this.sendFromOtherMethod = true;
      this.handleGetQlis();
      this.isLoaded = false;
    }
  }

  updateLocations(data) {
    data.forEach(item => {
      if(!this.excludedTypes.includes((item.productType || '').toLowerCase())){
        this.validateUserAccess(item);
        if (item && item.bodegas) {
          const hasUruca = item.bodegas.some(bodega => bodega.name.includes("Uruca"));
          item.locations = item.bodegas
            .filter(bodega => bodega.isPrincipal || (hasUruca && bodega.name === "Bodega de Apartados"))
            .map(bodega => ({ label: bodega.name, value: bodega.name }));
          if (item.Bodega) {
            this.updateCantidadDisponibleForObject(item, item.Bodega);
          }
        }
      }
      const isMO = ((item.productType || '').toLowerCase().includes('mano'));
      item.isMO = isMO;
      item.renderTrabajoLookup = isMO && !this.isPrincipalByTrabajo(item);

      // Mantener selección del lookup si ya hay valor
      item.selectedTrabajoRow = (item.trabajoARealizar && item.trabajoARealizarName)
        ? [{ id: this.normalizeId(item.trabajoARealizar), title: item.trabajoARealizarName }]
        : [];
      item.estadoAprobacionClass = this.computeEstadoAprobacionClass(item.estadoAprobacion);
    });
  }

  updateCantidadDisponibleForObject(item, selectedBodegaName) {
    const selectedBodega = (item.bodegas || []).find(bodega => bodega.name === selectedBodegaName);
    if (selectedBodega) {
      item.cantidadDisponible = selectedBodega.cantidadDisponible;
      item.bodegaID = selectedBodega.Id;
    }
    return item;
  }

  setMessageShow(title, message, variant = 'info') {
    const mode = (variant === 'error' || variant === 'warning') ? 'dismissable' : 'pester';
    this.dispatchEvent(new ShowToastEvent({ title, message, variant, mode }));
  }

  navigateToOrder() {
    this.setMessageShow('Success!','Se guardó la tarea correctamente','success');
  }
  navigateGeneral() {
    this.setMessageShow('Success!','Se guardaron correctamente las líneas','success');
    window.location.reload()
  }

  validateUserAccess(currentItem){
    if (currentItem.qolId) {
      currentItem.CanDeleteWolis__c = (
        this.CanDeleteWolis__c &&
        !((currentItem.estadoReserva === 'Reservado') || (currentItem.hasOwnProperty('estadoSolicitudCompra')))
      );

      if ((currentItem.productType || '').toLowerCase() === 'mano de obra') {
        currentItem.CanDeleteWolis__c = this.CanDeleteWolisMo__c;
      }
    } else {
      currentItem.CanDeleteWolis__c = true;
    }

    // los de búsqueda nunca se pueden borrar
    currentItem.CanDeleteWolis__c = currentItem.isSearch ? false : currentItem.CanDeleteWolis__c;

    const isDefault = !!currentItem.defaultMostrador;

    // 🔹 cantidad
    currentItem.disableQuantity =
      !currentItem.CanDeleteWolis__c ||
      currentItem.isClosed ||
      isDefault;

    // 🔹 bodega
    currentItem.disableBodega =
      currentItem.isClosed ||
      isDefault;

    // 🔹 alias
    currentItem.disableAlias =
      currentItem.isClosed ||
      isDefault;

    this.validateEditSalesPriceUserAccess(currentItem);
  }


  validateEditSalesPriceUserAccess(currentItem){
  const isMO      = (currentItem.productType || '').toLowerCase() === 'mano de obra';
  const isDefault = !!currentItem.defaultMostrador;

  let disabled;
  if (isMO) {
    disabled = currentItem.isClosed
      ? currentItem.isClosed
      : !this.CanEditMOPrice__c;
  } else {
    disabled = currentItem.isClosed
      ? currentItem.isClosed
      : !this.CanEditSalePrice__c;
  }

  // si es mostrador, no se puede editar el precio nunca
  if (isDefault) {
    disabled = true;
  }

  currentItem.canEditSalesPrice = disabled; // true = disabled en el input
}


  handleMoveTop(){
    let originalPos = this.linesIds.indexOf(this.deletelines[0]);
    let desirePos = 1;
    this.swapPositions(originalPos, desirePos, 'lines');
    this.swapPositions(originalPos, desirePos, 'id');
  }

  handleMoveUp(){
    let originalPos = this.linesIds.indexOf(this.deletelines[0]);
    let desirePos = originalPos - 1;
    this.swapPositions(originalPos, desirePos, 'lines');
    this.swapPositions(originalPos, desirePos, 'id');
  }

  handleMoveDown(){
    let originalPos = this.linesIds.indexOf(this.deletelines[0]);
    let desirePos = originalPos + 1;
    this.swapPositions(originalPos, desirePos, 'lines');
    this.swapPositions(originalPos, desirePos, 'id');
  }

  handleMoveBottom(){
    let originalPos = this.linesIds.indexOf(this.deletelines[0]);
    let desirePos = this.linesIds.length - 1;
    this.swapPositions(originalPos, desirePos, 'lines');
    this.swapPositions(originalPos, desirePos, 'id');
  }

  swapPositions(originalPos, desirePos, type) {
    if (desirePos == 0 || desirePos >= this.modifiedList.length) {
      throw new Error("Invalid positions provided");
    }
    if(type == 'id'){
      let tempId = this.linesIds[originalPos];
      this.linesIds[originalPos] = this.linesIds[desirePos];
      this.linesIds[desirePos] = tempId;
    } else{
      let temp = this.modifiedList[originalPos];
      this.modifiedList[originalPos] = this.modifiedList[desirePos];
      this.modifiedList[desirePos] = temp;
    }
  }

  calculateMontoTotal(){
    this.currencyCode = this.modifiedList[1]?.currencyCode || ''; 
    const sum = this.modifiedList.reduce((sum, item) => sum + (item.unitPrice * item.cantidad || 0), 0);
    this.montoTotal = Math.round(sum * 100) / 100;
  }

  async fetchTrabajosExistentes() {
    const trabajosExistentes = await getTrabajos({ quoteId: this.recordId, tareaId: this.currentTaskKey });

    return trabajosExistentes.map((trabajo) => ({
      id: trabajo.id || `local-${this.nextTrabajoId++}`,
      changeAlias: false,
      checked: false,
      prioridad: trabajo.prioridad,
      isButtonDisabled: !!trabajo.id ? false : true,
      nombre: trabajo.tipoTrabajo,
      manoDeObra: trabajo.manoDeObra,
      manoDeObraNombre: trabajo.manoDeObraNombre,
      nombreTrabajo: trabajo.nombreTrabajo,
      alias: trabajo.alias !== '' ? trabajo.alias : trabajo.nombreTrabajo,
      selectedTrabajo: trabajo.tipoTrabajo ? { id: trabajo.tipoTrabajo, title: trabajo.nombreTrabajo } : { id: null, title: null },
      tipoCargo: toTipoCargoValue(trabajo.tipoCargo), // normalizar a value para la UI
      aprobador: trabajo.aprobador,
      utsDelTipoDeTrabajo: trabajo.utsDelTipoDeTrabajo,
      disabledUts: true,
      totalSubtrabajos: trabajo.totalSubtrabajos,
      uts: (trabajo.nombreTrabajo !== '-Control final' && trabajo.nombreTrabajo !== 'CONTROL FINAL' && trabajo.nombreTrabajo !== 'Control final' && trabajo.nombreTrabajo !== 'Lavado Red Motos')
            ? trabajo.uts : 0,
      utsReal: (trabajo.nombreTrabajo !== '-Control final' && trabajo.nombreTrabajo !== 'CONTROL FINAL' && trabajo.nombreTrabajo !== 'Control final' && trabajo.nombreTrabajo !== 'Lavado Red Motos')
            ? (trabajo.utsReal ? Math.round(trabajo.utsReal) : Math.round(trabajo.uts * 12)) : 0,
      subtrabajos: (trabajo.subtrabajos || []).map((subtrabajo) => ({
        id: subtrabajo.id || `local-sub-${this.nextSubtrabajoId++}`,
        nombre: subtrabajo.tipoTrabajoNombre,
        disabledUts: subtrabajo.utsDelTipoDeTrabajo ? true : false,
        tipoTrabajo: subtrabajo.tipoTrabajo,
        tipoTrabajoNombre: subtrabajo.tipoTrabajoNombre,
        alias: subtrabajo.alias,
        selectedSubTrabajo: subtrabajo.pasoDeTrabajo ? { id: subtrabajo.pasoDeTrabajo, title: subtrabajo.nombre } : { id: null, title: null },
        manoDeObra: subtrabajo.manoDeObra ? subtrabajo.manoDeObra : trabajo.manoDeObra,
        selectedManoDeObra: (subtrabajo.manoDeObra ?? trabajo.manoDeObra) ? {
          id: subtrabajo.manoDeObra ?? trabajo.manoDeObra,
          title: subtrabajo.manoDeObra ? subtrabajo.manoDeObraNombre : trabajo.manoDeObraNombre
        } : { id: null, title: null },
        selectedTipoTrabajo: (subtrabajo.tipoTrabajo ?? trabajo.tipoTrabajo) ? {
          id: subtrabajo.tipoTrabajo ?? trabajo.tipoTrabajo,
          title: subtrabajo.tipoTrabajo ? subtrabajo.tipoTrabajoNombre : null
        } : { id: null, title: null },
        uts: (subtrabajo.tipoTrabajoNombre !== '-Control final' && subtrabajo.tipoTrabajoNombre !== 'CONTROL FINAL' && subtrabajo.tipoTrabajoNombre !== 'Control final' && subtrabajo.tipoTrabajoNombre !== 'Lavado Red Motos')
            ? (subtrabajo.uts != null ? subtrabajo.uts : subtrabajo.horas) : 0,
        horas: (subtrabajo.tipoTrabajoNombre !== '-Control final' && subtrabajo.tipoTrabajoNombre !== 'CONTROL FINAL' && subtrabajo.tipoTrabajoNombre !== 'Control final' && subtrabajo.tipoTrabajoNombre !== 'Lavado Red Motos')
            ? subtrabajo.horas : 0,
        checked: false,
      })),
    }));
  }

  async loadTrabajosAndMerge() {
    this.isLoading = true;
    try {
      const existentes = await this.fetchTrabajosExistentes();
      const locales = (this.trabajos || []).filter(t => String(t.id).startsWith('local-'));

      if (existentes.length > 0) {
        const localesSinDuplicar = locales.filter(l => !existentes.some(e => e.id === l.id));
        this.trabajos = [...existentes, ...localesSinDuplicar];
        this.disabeldTrabajosButton = false;
      } else {
        this.trabajos = locales.length ? locales : [{
          id: `local-${this.nextTrabajoId++}`,
          checked: false,
          prioridad: this.prioridadSeleccionada,
          nombre: "Nuevo Trabajo",
          tipoCargo: "1",
          aprobador: "Asesor",
          isButtonDisabled: true,
          selectedTrabajo: { id: '', title: '' },
          uts: 0,
          subtrabajos: [],
        }];
        this.disabeldTrabajosButton = true;
      }

    } catch (error) {
      this.showToast("Error", error?.body?.message || 'Error al cargar trabajos', "error");
    } finally {
      this.isLoading = false;
    }
  }

  updateSubtrabajoEnTrabajos(trabajoId, subId, field, value) {
    this.trabajos = (this.trabajos || []).map(t => {
      if (t.id !== trabajoId) return t;
      const subtrabajos = (t.subtrabajos || []).map(st =>
        st.id === subId ? { ...st, [field]: value } : st
      );
      return { ...t, subtrabajos };
    });
  }

  showToast(title, message, variant = 'info') {
    const evt = new ShowToastEvent({
      title,
      message,
      variant,
      mode: 'pester' 
    });
    this.dispatchEvent(evt);
  }
}