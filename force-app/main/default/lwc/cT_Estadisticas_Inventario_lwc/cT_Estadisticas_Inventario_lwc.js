import { LightningElement, track, wire } from 'lwc';
import obtenerEstadisticasTodosModelos from '@salesforce/apex/cT_Registro_Avaluos_ctrl.obtenerEstadisticasTodosModelos';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Constante para items por página
const PAGE_SIZE = 20;

export default class EstadisticasInventario extends LightningElement {
    @track datosCompletos = [];
    @track datosFiltrados = [];
    @track datosPaginados = [];
    @track loading = true;
    
    // Filtros
    marcaFiltro = '';
    modeloFiltro = '';
    anioFiltro = '';
    
    // Paginación
    currentPage = 1;
    totalPages = 1;
    pageSize = PAGE_SIZE;
    
    // Totales
    totalModelos = 0;
    totalInventario = 0;
    totalRecibos = 0;
    totalVentas = 0;
    
    // Columnas de la tabla
    columns = [
        { label: 'Marca', fieldName: 'marca', sortable: true, type: 'text' },
        { label: 'Modelo', fieldName: 'modelo', sortable: true, type: 'text' },
        { label: 'Año', fieldName: 'anio', sortable: true, type: 'text' },
        { 
            label: 'Inv. Actual', 
            fieldName: 'cantidadInventario', 
            sortable: true, 
            type: 'number',
            cellAttributes: { alignment: 'center' }
        },
        { 
            label: 'Recibos Disp.', 
            fieldName: 'cantidadRecibos', 
            sortable: true, 
            type: 'number',
            cellAttributes: { alignment: 'center' }
        },
        { 
            label: 'Total Disp.', 
            fieldName: 'totalDisponible', 
            sortable: true, 
            type: 'number',
            cellAttributes: { alignment: 'center' }
        },
        { 
            label: 'Días Prom. Inv.', 
            fieldName: 'diasPromedioInventario', 
            sortable: true, 
            type: 'number',
            typeAttributes: { 
                minimumFractionDigits: 1,
                maximumFractionDigits: 1 
            },
            cellAttributes: { alignment: 'center' }
        },
        { 
            label: 'Días Prom. Rec.', 
            fieldName: 'diasPromedioRecibos', 
            sortable: true, 
            type: 'number',
            typeAttributes: { 
                minimumFractionDigits: 1,
                maximumFractionDigits: 1 
            },
            cellAttributes: { alignment: 'center' }
        },
        { 
            label: 'Ventas (6m)', 
            fieldName: 'ventasUltimos6Meses', 
            sortable: true, 
            type: 'number',
            cellAttributes: { alignment: 'center' }
        },
        { 
            label: 'Precio Última Venta', 
            fieldName: 'precioUltimaVenta', 
            sortable: true, 
            type: 'currency',
            typeAttributes: { currencyCode: 'USD' },
            cellAttributes: { alignment: 'center' }
        },
        { 
            label: 'Última Venta', 
            fieldName: 'fechaUltimaVenta', 
            sortable: true, 
            type: 'date-local',
            typeAttributes: {
                day: 'numeric',
                month: 'numeric', 
                year: 'numeric'
            },
            cellAttributes: { alignment: 'center' }
        }
    ];
    
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy = 'marca';
    
    // GETTERS para controlar estado de botones
    get isFirstPage() {
        return this.currentPage === 1;
    }
    
    get isLastPage() {
        return this.currentPage === this.totalPages || this.totalPages === 0;
    }
    
    @wire(obtenerEstadisticasTodosModelos)
    wiredEstadisticas({ error, data }) {
        this.loading = true;
        if (data) {
            // Asegurar que todos los campos necesarios existan
            this.datosCompletos = data.map((item, index) => ({
                id: `modelo-${index}`,
                marca: item.marca || '',
                modelo: item.modelo || '',
                anio: item.anio || '',
                cantidadInventario: item.cantidadInventario || 0,
                cantidadRecibos: item.cantidadRecibos || 0,
                totalDisponible: item.totalDisponible || 0,
                diasPromedioInventario: item.diasPromedioInventario || 0,
                diasPromedioRecibos: item.diasPromedioRecibos || 0,
                ventasUltimos6Meses: item.ventasUltimos6Meses || 0,
                precioUltimaVenta: item.precioUltimaVenta || 0,
                fechaUltimaVenta: item.fechaUltimaVenta || null,
            }));
            
            this.calcularTotales();
            this.aplicarFiltros();
            this.loading = false;
        } else if (error) {
            console.error('Error:', error);
            this.loading = false;
            this.showToast('Error', 'No se pudieron cargar las estadísticas', 'error');
        }
    }
    
    // Calcular totales generales
    calcularTotales() {
        this.totalModelos = this.datosCompletos.length;
        this.totalInventario = this.datosCompletos.reduce((sum, item) => sum + (item.cantidadInventario || 0), 0);
        this.totalRecibos = this.datosCompletos.reduce((sum, item) => sum + (item.cantidadRecibos || 0), 0);
        this.totalVentas = this.datosCompletos.reduce((sum, item) => sum + (item.ventasUltimos6Meses || 0), 0);
    }
    
    // Manejar cambios en filtros
    handleMarcaChange(event) {
        this.marcaFiltro = event.target.value;
        this.aplicarFiltros();
    }
    
    handleModeloChange(event) {
        this.modeloFiltro = event.target.value;
        this.aplicarFiltros();
    }
    
    handleAnioChange(event) {
        this.anioFiltro = event.target.value;
        this.aplicarFiltros();
    }
    
    // Aplicar filtros
    aplicarFiltros() {
        let filtrados = [...this.datosCompletos];
        
        if (this.marcaFiltro) {
            filtrados = filtrados.filter(item => 
                item.marca && item.marca.toLowerCase().includes(this.marcaFiltro.toLowerCase())
            );
        }
        
        if (this.modeloFiltro) {
            filtrados = filtrados.filter(item => 
                item.modelo && item.modelo.toLowerCase().includes(this.modeloFiltro.toLowerCase())
            );
        }
        
        if (this.anioFiltro) {
            filtrados = filtrados.filter(item => 
                item.anio && item.anio.toLowerCase().includes(this.anioFiltro.toLowerCase())
            );
        }
        
        this.datosFiltrados = filtrados;
        this.currentPage = 1;
        this.paginarDatos();
    }
    
    // Paginación
    paginarDatos() {
        this.totalPages = Math.ceil(this.datosFiltrados.length / this.pageSize);
        
        const startIndex = (this.currentPage - 1) * this.pageSize;
        const endIndex = startIndex + this.pageSize;
        
        this.datosPaginados = this.datosFiltrados.slice(startIndex, endIndex);
    }
    
    previousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.paginarDatos();
        }
    }
    
    nextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.paginarDatos();
        }
    }
    
    // Ordenamiento
    onHandleSort(event) {
        const { fieldName, sortDirection } = event.detail;
        this.sortedBy = fieldName;
        this.sortDirection = sortDirection;
        
        this.datosFiltrados = this.sortData(fieldName, sortDirection);
        this.paginarDatos();
    }
    
    sortData(fieldName, sortDirection) {
        const data = [...this.datosFiltrados];
        const reverse = sortDirection === 'asc' ? 1 : -1;
        
        data.sort((a, b) => {
            const valueA = a[fieldName] || 0;
            const valueB = b[fieldName] || 0;
            
            if (typeof valueA === 'string') {
                return reverse * valueA.localeCompare(valueB);
            }
            
            return reverse * (valueA - valueB);
        });
        
        return data;
    }
    
    // Exportar a Excel
    exportToExcel() {
        if (this.datosFiltrados.length === 0) {
            this.showToast('Información', 'No hay datos para exportar', 'info');
            return;
        }
        
        // Crear contenido CSV
        const headers = [
            'Marca', 'Modelo', 'Año', 'Inventario Actual', 'Recibos Disponibles',
            'Total Disponible', 'Días Promedio Inventario', 'Días Promedio Recibos',
            'Ventas Últimos 6 Meses', 'Precio Última Venta',
            'Fecha Última Venta'
        ].join(',');
        
        const rows = this.datosFiltrados.map(item => [
            `"${item.marca || ''}"`,
            `"${item.modelo || ''}"`,
            `"${item.anio || ''}"`,
            item.cantidadInventario || 0,
            item.cantidadRecibos || 0,
            item.totalDisponible || 0,
            item.diasPromedioInventario || 0,
            item.diasPromedioRecibos || 0,
            item.ventasUltimos6Meses || 0,
            item.precioUltimaVenta || 0,
            item.fechaUltimaVenta || '',
        ].join(','));
        
        const csvContent = [headers, ...rows].join('\n');
        
        // Crear y descargar archivo
        const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement('a');
        const url = URL.createObjectURL(blob);
        
        link.setAttribute('href', url);
        link.setAttribute('download', `estadisticas_vehiculos_${new Date().toISOString().slice(0,10)}.csv`);
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        
        this.showToast('Éxito', 'Datos exportados correctamente', 'success');
    }
    
    // Mostrar notificaciones
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}
