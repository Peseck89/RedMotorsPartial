import { LightningElement, track } from 'lwc';
import validarGarantia from '@salesforce/apex/AssetGarantiaController.validarGarantia';
import obtenerDetalleCompleto from '@salesforce/apex/AssetGarantiaController.obtenerDetalleCompleto';
import { NavigationMixin } from 'lightning/navigation';
import crearEvento from '@salesforce/apex/AssetGarantiaController.crearEvento';

export default class AssetGarantiaLookupLwc extends NavigationMixin(LightningElement) {
    @track assetSeleccionado = null;
    @track mostrarModal = false;
    @track mostrarDetalles = false;
    @track isLoading = false;
    @track detallesCompletos = [];
    @track thisEventoFinal;
    @track isLoading; 
    @track vehiculoPlaca = true; 
    @track vehiculoVin = false; 
    
    @track resultado = {
        aplicaGarantia: false,
        mensaje: '',
        totalCitas: 0,
        eventosConsiderados: [],
        fechaInicio: null,
        fechaFin: null
    };

    // Getters computados
    get isButtonDisabled() {
        return !this.assetSeleccionado || this.isLoading;
    }

    get messageStyle() {
        return this.resultado.aplicaGarantia ? 'color: green' : 'color: red';
    }

    get toggleDetailsLabel() {
        return this.mostrarDetalles ? 'Ocultar detalles' : 'Mostrar detalles';
    }

    get hasDetalles() {
        return this.detallesCompletos.length > 0;
    }

    handleCaseClick(event) {
        const caseId = event.currentTarget.dataset.id;
        if (caseId) {
            // Construye la URL manualmente
            const baseUrl = window.location.origin;
            const recordUrl = `${baseUrl}/lightning/r/Case/${caseId}/view`;
            window.open(recordUrl, '_blank');
        }
    }

    // handleCaseClick(event) {
    //     const caseId = event.currentTarget.dataset.id;
    //     if (caseId) {
    //         this[NavigationMixin.Navigate]({
    //             type: 'standard__recordPage',
    //             attributes: {
    //                 recordId: caseId,
    //                 objectApiName: 'Case',
    //                 actionName: 'view'
    //             }
    //         });
    //     }
    // }

    getCaseUrl(caseId) {
        return `/lightning/r/Case/${caseId}/view`;
    }

    handleSeleccion(event) {
        this.assetSeleccionado = event.detail?.id || null;
        this.resetResultados();
    }

    handleSearchPlaca() {
        this.vehiculoPlaca = true;
        this.vehiculoVin = false;
    }

    handleSearchVin() {
        this.vehiculoVin = true;
        this.vehiculoPlaca = false;
    }

    async validarGarantia() {
        if (!this.assetSeleccionado) {
            this.mostrarError('Seleccione un vehículo primero');
            return;
        }

        this.isLoading = true;
        this.resetResultados();
        
        try {
            this.resultado = await validarGarantia({ assetId: this.assetSeleccionado });
            const detallesRaw = await obtenerDetalleCompleto({ assetId: this.assetSeleccionado });
            
            // Mapeamos los detalles para asegurar la estructura correcta
            this.detallesCompletos = detallesRaw.map(detalle => ({
                ...detalle,
                casoId: detalle.casoId,
                caso: detalle.caso || 'N/A'
            }));
            console.log('Detalles completos obtenidos:', detallesRaw);
            
            this.mostrarModal = true;
        } catch (error) {
            this.mostrarError('Error al validar garantía: ' + this.parseError(error));
        } finally {
            this.isLoading = false;
        }
    }

    toggleDetalles() {
        this.mostrarDetalles = !this.mostrarDetalles;
    }

    async agendarCita() {
        this.isLoading = true;
        console.log('Este es el id del coche');
        console.log(this.assetSeleccionado);
        try {
            const result = await crearEvento({ cocheId: this.assetSeleccionado });
            this.thisEventoFinal = result;
            
            // Navegar al registro del evento recién creado para saltarlo y pasarnos a la vista del calendario
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: result.Id,
                    objectApiName: 'Event',
                    actionName: 'view'
                },
            });
            this.cerrarModal();
            this.isLoading = false; 
        } catch (error) {
            this.isLoading = false; 
            console.error('Error al crear el evento:', error);
            // Opcional: mostrar un toast de error
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body?.message || 'No se pudo crear el evento.',
                    variant: 'error'
                })
            );
        }           
    }

    irABMWService() {
        // this[NavigationMixin.Navigate]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: 'https://redmotors.my.site.com/s/disponibilidades?servicio=BMW&callcenter=true'
        //         // url: 'https://redmotors.my.site.com/s/disponibilidades?servicio=BMW?callcenter=true'
        //         // url: 'https://redmotors.my.site.com/CustomCommunityLogIn?callcenter=true'
        //     }
        // });

        window.open('https://redmotors.my.site.com/s/disponibilidades?servicio=BMW&callcenter=true', '_blank');
        this.cerrarModal();
    }

    cerrarModal() {
        this.mostrarModal = false;
        this.mostrarDetalles = false;
    }

    mostrarError(mensaje) {
        this.resultado = {
            ...this.resultado,
            aplicaGarantia: false,
            mensaje: mensaje
        };
        this.mostrarModal = true;
    }

    parseError(error) {
        let errorMsg = error.body?.message || error.message || 'Error desconocido';
        return errorMsg.split(':')[0];
    }

    resetResultados() {
        this.resultado = {
            aplicaGarantia: false,
            mensaje: '',
            totalCitas: 0,
            eventosConsiderados: [],
            fechaInicio: null,
            fechaFin: null
        };
        this.detallesCompletos = [];
    }
}