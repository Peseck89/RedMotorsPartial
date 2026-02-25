import { LightningElement, track } from 'lwc';
import getPendingTasksForFilters
    from '@salesforce/apex/PendingTasksByBranchController.getPendingTasksForFilters';
import getTiposDeServicio from '@salesforce/apex/PendingTasksByBranchController.getTiposDeServicio';


export default class VehiculosEnTallerTabla extends LightningElement {

    // Filtros
    @track fechaInicio;
    @track fechaFin;
    @track sucursal;
    @track tipoServicio;
    @track asesorId;

    // Datos visuales
    @track rows = [];
    allRows = [];

    // Opciones de filtros
    @track sucursalOptions = [
        { label: 'Todas', value: '' },
        { label: 'Uruca', value: 'Uruca' },
        { label: 'Pinares', value: 'Pinares' },
        { label: 'Escazú', value: 'Escazú' },
        { label: 'Motorrad', value: 'Motorrad' },
        { label: 'Otobai', value: 'Otobai' }
    ];

    @track tipoServicioOptions = [{ label: 'Todos', value: '' }];
    @track asesorOptions = [{ label: 'Todos', value: '' }];

    @track isLoading = false;
    @track error;

    connectedCallback() {
        this.loadTiposServicio();
    
        // Default: últimos 7 días
        const today = new Date();
        const seven = new Date();
        seven.setDate(today.getDate() - 7);

        this.fechaFin = today.toISOString().slice(0, 10);
        this.fechaInicio = seven.toISOString().slice(0, 10);

        this.loadData();
    }

    loadTiposServicio() {
        getTiposDeServicio({sucursal:this.sucursal})
            .then(result => {
                console.log(result);
                let opts = [{ label: 'Todos', value: '' }];

                result.forEach(tipo => {
                    opts.push({
                        label: tipo,
                        value: tipo
                    });
                });

                this.tipoServicioOptions = opts;
            })
            .catch(error => {
                console.error('Error cargando tipos de servicio: ', error);
            });
    }


    // HANDLERS DE FILTROS
    handleFechaInicioChange(e) {
        this.fechaInicio = e.target.value;
    }

    handleFechaFinChange(e) {
        this.fechaFin = e.target.value;
    }

    handleSucursalChange(e) {
        this.sucursal = e.detail.value;
        this.tipoServicio = '';
        this.asesorId = '';
        this.loadTiposServicio();
    }

    handleTipoServicioChange(e) {
        this.tipoServicio = e.detail.value;
        this.applyClientFilters();
    }

    handleAsesorChange(e) {
        this.asesorId = e.detail.value;
        this.applyClientFilters();
    }

    handleBuscar() {
        this.loadData();
    }

    // =====================================================================
    // CARGA DE DATOS DESDE APEX
    // =====================================================================
    loadData() {
        this.isLoading = true;
        this.error = undefined;

        getPendingTasksForFilters({
            fechaInicio: this.fechaInicio || null,
            fechaFin: this.fechaFin || null,
            sucursal: this.sucursal || null,
            asesorId: null
        })
        .then(result => {
            // =============================================
            // FORMATEO DE FILAS LWC
            // =============================================
            this.allRows = (result || []).map(r => {
                // Semáforo → clase visual
                let colorClass = '';
                if (r.semaforo) {
                    const s = r.semaforo.toLowerCase();
                    if (s.includes('rojo')) colorClass = 'alerta-rojo';
                    else if (s.includes('amarillo')) colorClass = 'alerta-amarillo';
                    else if (s.includes('verde')) colorClass = 'alerta-verde';
                }

                return {
                    ...r,

                    // VIN o placa para columna principal
                    vinOrPlaca: r.vin || r.placa || '',

                    // FORMATEO FECHA INGRESO
                    fechaIngresoFmt: r.fechaIngreso
                        ? new Intl.DateTimeFormat('es-CR', {
                              year: 'numeric',
                              month: '2-digit',
                              day: '2-digit',
                              hour: '2-digit',
                              minute: '2-digit'
                          }).format(new Date(r.fechaIngreso))
                        : '',

                    // FORMATEO ÚLTIMO CONTACTO
                    ultimoContactoFmt: r.ultimoContacto
                        ? new Intl.DateTimeFormat('es-CR', {
                              year: 'numeric',
                              month: '2-digit',
                              day: '2-digit',
                              hour: '2-digit',
                              minute: '2-digit'
                          }).format(new Date(r.ultimoContacto))
                        : '',

                    // FORMATEO DÍAS EN TALLER
                    diasEnTallerFmt:
                        r.diasEnTaller !== null && r.diasEnTaller !== undefined
                            ? new Intl.NumberFormat('es-CR').format(r.diasEnTaller)
                            : '',

                    diasSinContactoFmt:
                    r.diasSinContacto !== null && r.diasSinContacto !== undefined
                        ? new Intl.NumberFormat('es-CR').format(r.diasSinContacto)
                        : '',

                    // Clase css para alerta
                    alertaClass: `alerta ${colorClass}`
                };
            });

            this.buildFilterOptionsFromData();
            this.applyClientFilters();
            this.isLoading = false;
        })
        .catch(error => {
            this.error = error;
            this.rows = [];
            this.isLoading = false;
        });
    }

    // =====================================================================
    // ARMADO DE OPCIONES PARA FILTROS DINÁMICOS
    // =====================================================================
    buildFilterOptionsFromData() {
        const tiposSet = new Set();
        const asesoresMap = new Map();

        this.allRows.forEach(r => {
            if (r.tipoServicio) tiposSet.add(r.tipoServicio);
            if (r.asesorId && r.asesorNombre) {
                asesoresMap.set(r.asesorId, r.asesorNombre);
            }
        });

        this.tipoServicioOptions = [{ label: 'Todos', value: '' }];
        tiposSet.forEach(t => this.tipoServicioOptions.push({ label: t, value: t }));

        this.asesorOptions = [{ label: 'Todos', value: '' }];
        asesoresMap.forEach((name, id) => {
            this.asesorOptions.push({ label: name, value: id });
        });

        if (!this.tipoServicioOptions.some(o => o.value === this.tipoServicio)) {
            this.tipoServicio = '';
        }
        if (!this.asesorOptions.some(o => o.value === this.asesorId)) {
            this.asesorId = '';
        }
    }

    // =====================================================================
    // FILTROS EN CLIENTE (sin recargar Apex)
    // =====================================================================
    applyClientFilters() {
        let filtered = [...this.allRows];

        if (this.tipoServicio) {
            filtered = filtered.filter(r => r.tipoServicio === this.tipoServicio);
        }
        if (this.asesorId) {
            filtered = filtered.filter(r => r.asesorId === this.asesorId);
        }

        this.rows = filtered;
    }

    get hasData() {
        return this.rows && this.rows.length > 0;
    }
}