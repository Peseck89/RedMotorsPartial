import { LightningElement, api, track } from 'lwc';
import obtenerCorreos from '@salesforce/apex/CorreoController.obtenerCorreos';
import guardarCorreo from '@salesforce/apex/CorreoController.guardarCorreo';
import eliminarCorreo from '@salesforce/apex/CorreoController.eliminarCorreo';
import obtenerTiposDatosComunicacion from '@salesforce/apex/CorreoController.obtenerTiposDatosComunicacion';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    { label: 'Correo', fieldName: 'Name', type: 'email' },
    { label: 'Tipo de Comunicación', fieldName: 'Tipo_de_datos_de_comunicaci_n__rName', type: 'text' },
    { label: 'Correo Principal', fieldName: 'Principal__c', type: 'boolean' },
    { label: 'Activo', fieldName: 'Activo__c', type: 'boolean' },
    {
        type: 'action',
        typeAttributes: {
            rowActions: [
                { label: 'Editar', name: 'editar' },
                { label: 'Eliminar', name: 'eliminar' }
            ]
        }
    }
];

export default class Correosdecuenta extends LightningElement {
    @api accountId;
    @api tipocliente;

    @track correos = [];
    @track correoActual = {};
    @track primerCorreo;
    @track otrosCorreos = [];
    @track tiposDatosComunicacion = [];
    @track isModalOpen = false;
    @track isEditMode = false;
    @track hasRendered = false;
    @track mostrarDropdown = false;
    @track isJuridico = false;

    columns = COLUMNS;

    renderedCallback() {
        if (this.hasRendered) return;
        this.hasRendered = true;
        this.recargarCorreos();
        this.cargarTiposDatosComunicacion();

        if (this.tipocliente === 'Cliente Jurídico' || this.tipocliente == 'Cuenta empresarial') {
            this.isJuridico = true;
        }
        console.log('Correo id');
        console.log(this.accountId);
    }

    async cargarTiposDatosComunicacion() {
        try {
            const result = await obtenerTiposDatosComunicacion({ accountId: this.accountId });
            this.tiposDatosComunicacion = result.map(item => ({
                label: item.Name,
                value: item.Id,
            }));
        } catch (error) {
            this.showToast('Error', 'Error al cargar tipos de comunicación', 'error');
        }
    }

    // async recargarCorreos() {
    //     try {
    //         const result = await obtenerCorreos({ accountId: this.accountId });
    
    //         this.correos = result.map(c => ({
    //             ...c,
    //             Tipo_de_datos_de_comunicaci_n__rName: c.Tipo_de_datos_de_comunicaci_n__r?.Name || ''
    //         }));
    
    //         // Separar el primer correo
    //         this.primerCorreo = this.correos.length > 0 ? this.correos[0] : null;
    //         this.otrosCorreos = this.correos.slice(1);
    
    //         this.dispatchEvent(new CustomEvent('actualizar', {
    //             detail: { tipo: 'correo', hayRegistros: this.correos.length > 0 }
    //         }));
    //     } catch (error) {
    //         this.showToast('Error', error.body?.message || 'Error al cargar correos', 'error');
    //     }
    // }
    
    async recargarCorreos() {
        try {
            const result = await obtenerCorreos({ accountId: this.accountId });
    
            this.correos = result.map(c => ({
                ...c,
                Tipo_de_datos_de_comunicaci_n__rName: c.Tipo_de_datos_de_comunicaci_n__r?.Name || ''
            }));
    
            // Buscar el correo principal
            const principalCorreos = this.correos.filter(c => c.Principal__c);
            
            if (principalCorreos.length > 0) {
                this.primerCorreo = principalCorreos[0];
                this.otrosCorreos = this.correos.filter(c => c.Id !== this.primerCorreo.Id);
            } else {
                this.primerCorreo = null;
                this.otrosCorreos = [...this.correos];
            }
    
            this.dispatchEvent(new CustomEvent('actualizar', {
                detail: { tipo: 'correo', hayRegistros: this.correos.length > 0 }
            }));
        } catch (error) {
            this.showToast('Error', error.body?.message || 'Error al cargar correos', 'error');
        }
    }

    toggleDropdown() {
        this.mostrarDropdown = !this.mostrarDropdown;
    }

    handleEditar(event) {
        const id = event.currentTarget.dataset.id;
        this.correoActual = this.correos.find(correo => correo.Id === id);
        this.isEditMode = true;
        this.isModalOpen = true;
    }

    handleEliminar(event) {
        const id = event.currentTarget.dataset.id;
        this.eliminarCorreo(id);
    }

    handleAgregar() {
        this.correoActual = { Activo__c: true };
        this.isEditMode = false;
        this.isModalOpen = true;
    }

    async guardarCorreo() {
        const correo = this.correoActual.Name?.trim();
        const caracteresProhibidos = /[\s"'\(\)\[\]\{\},;:!\/\\%&*\+=\?<>]/g;
        const regexBasicoCorreo = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        if (!correo) {
            this.showToast('Error', 'El correo es obligatorio', 'error');
            return;
        }
        if (!this.correoActual.Tipo_de_datos_de_comunicaci_n__c) {
            this.showToast('Error', 'El tipo de Comunicación es obligatorio', 'error');
            return;
        }
        if (!regexBasicoCorreo.test(correo)) {
            this.showToast('Error', 'Formato de correo no válido', 'error');
            return;
        }
        if (caracteresProhibidos.test(correo)) {
            this.showToast('Error', 'El correo contiene caracteres no permitidos', 'error');
            return;
        }
        if (correo.startsWith('.') || correo.endsWith('.')) {
            this.showToast('Error', 'El correo no puede iniciar ni terminar con punto (.)', 'error');
            return;
        }

        // Validar que no existan puntos consecutivos en el correo
        if (correo.includes('..')) {
            this.showToast('Error', 'El correo no puede contener puntos consecutivos', 'error');
            return;
        }

        
        this.correoActual.Account__c = this.accountId;

        try {
            console.log('LLEGUE HASTA ACA');
            await guardarCorreo({ correo: this.correoActual });
            this.showToast('Éxito', 'Correo guardado correctamente', 'success');
            this.isModalOpen = false;
            await this.recargarCorreos();
        } catch (error) {
            let mensajeError = 'Ocurrió un error inesperado.';

            // Prioridad: pageErrors > fieldErrors > message genérica
            if (error?.body?.pageErrors?.length > 0) {
                mensajeError = error.body.pageErrors[0].message;
            } else if (error?.body?.fieldErrors) {
                const fieldErrArray = Object.values(error.body.fieldErrors)[0];
                if (fieldErrArray && fieldErrArray.length > 0) {
                    mensajeError = fieldErrArray[0].message;
                }
            } else if (error?.body?.message) {
                mensajeError = error.body.message;
            } else if (error?.message) {
                mensajeError = error.message;
            }
            this.showToast('Error', mensajeError, 'error');
            //this.showToast('Error al guardar', e.body?.message || e.message, 'error');
        }
    }

    async eliminarCorreo(id) {
        try {
            await eliminarCorreo({ correoId: id });
            this.showToast('Eliminado', 'Correo eliminado', 'success');
            await this.recargarCorreos();
        } catch (e) {
            this.showToast('Error al eliminar', e.body?.message || e.message, 'error');
        }
    }

    handleCorreoChange(event) {
        this.correoActual = { ...this.correoActual, Name: event.target.value };
    }

    handleTipoDatoChange(event) {
        this.correoActual = { ...this.correoActual, Tipo_de_datos_de_comunicaci_n__c: event.detail.value };
    }

    handleActivoChange(event) {
        this.correoActual = { ...this.correoActual, Activo__c: event.target.checked };
    }

    handlePrincipalChange(event) {
        this.correoActual = { ...this.correoActual, Principal__c: event.target.checked };
    }

    cerrarModal() {
        this.isModalOpen = false;
    }

    get modalTitle() {
        return this.isEditMode ? 'Editar Correo' : 'Agregar Correo';
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}