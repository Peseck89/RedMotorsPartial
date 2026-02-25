import { LightningElement, api, track } from 'lwc';
import obtenerIdentificaciones from '@salesforce/apex/IdentificacionController.obtenerIdentificaciones';
import guardarIdentificacion from '@salesforce/apex/IdentificacionController.guardarIdentificacion';
import eliminarIdentificacion from '@salesforce/apex/IdentificacionController.eliminarIdentificacion';
import obtenerTiposDocumento from '@salesforce/apex/IdentificacionController.obtenerTiposDocumentoCuenta';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    { label: 'Tipo', fieldName: 'Tipo_de_documento__rName', type: 'text' },
    { label: 'Número', fieldName: 'Identificaci_n__c', type: 'text' },
    { label: 'País', fieldName: 'Pais__c', type: 'text' },
    { label: 'Contacto Principal', fieldName: 'Identificacion_principal__c', type: 'boolean' },
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

export default class Identificacionesdecuenta extends LightningElement {
    @api accountId;
    @api tipocliente;
    // @api cedula
    @track identificaciones = [];
    @track primerIdentificacion = null;
    @track otrasIdentificaciones = [];
    @track isModalOpen = false;
    @track identificacionActual = {};
    @track deshabilitarPais = false;

    @track isEditMode = false;
    @track hasRendered = false;
    @track mostrarDropdown = false;
    @track tipoIdentificacionOptions = [];
    @track paisOptions = [];
    @track isJuridico = false;

    columns = COLUMNS; // <-- AQUI VA

    renderedCallback() {
        if (this.hasRendered) return;
        this.hasRendered = true;
        this.recargarIdentificaciones();
        this.cargarTiposDocumento();
        this.cargarPaises();
        if (this.tipocliente == 'Cliente Jurídico' || this.tipocliente == 'Cuenta empresarial') {
            this.isJuridico = true;
        }

        setTimeout(() => {
            this.recargarIdentificaciones();
        }, 4000);
    }

    // async recargarIdentificaciones() {
    //     console.log('recargarIdentificaciones');
    //     try {
    //         const result = await obtenerIdentificaciones({ accountId: this.accountId });
    //         if (result && Array.isArray(result)) {
    //             console.log('Hay result');
    //             this.identificaciones = result.map(i => ({
    //                 ...i,
    //                 Tipo_de_documento__rName: i.Tipo_de_documento__r?.Name || ''
    //             }));
    //             this.primerIdentificacion = this.identificaciones.length > 0 ? this.identificaciones[0] : null;
    //             this.otrasIdentificaciones = this.identificaciones.slice(1);
    //         }
    //     } catch (error) {
    //         this.showToast('Error', error.body?.message || 'Error al cargar identificaciones', 'error');
    //     }
    // }

    async recargarIdentificaciones() {
        console.log('recargarIdentificaciones');
        try {
            const result = await obtenerIdentificaciones({ accountId: this.accountId });
            if (result && Array.isArray(result)) {
                console.log('Hay result');
                this.identificaciones = result.map(i => ({
                    ...i,
                    Tipo_de_documento__rName: i.Tipo_de_documento__r?.Name || ''
                }));
    
                // Filtrar identificaciones principales
                const identificacionesPrincipales = this.identificaciones.filter(i => i.Identificacion_principal__c);
                
                if (identificacionesPrincipales.length > 0) {
                    this.primerIdentificacion = identificacionesPrincipales[0];
                    this.otrasIdentificaciones = this.identificaciones.filter(i => i.Id !== this.primerIdentificacion.Id);
                } else {
                    this.primerIdentificacion = this.identificaciones.length > 0 ? this.identificaciones[0] : null;
                    this.otrasIdentificaciones = this.identificaciones.slice(1);
                }
            }
        } catch (error) {
            this.showToast('Error', error.body?.message || 'Error al cargar identificaciones', 'error');
        }
    }

    async cargarTiposDocumento() {
        try {
            const result = await obtenerTiposDocumento({ accountId: this.accountId });
    
            // Obtener los tipos ya usados
            const tiposUsados = new Set(this.identificaciones.map(i => i.Tipo_de_documento__c));
    
            // Filtrar los no usados
            this.tipoIdentificacionOptions = result
                .filter(t => !tiposUsados.has(t.Tipo_de_documento__c))
                .map(t => ({
                    label: t.Tipo_de_documento__r.Name,
                    value: t.Tipo_de_documento__c
                }));
        } catch (e) {
            this.showToast('Error', 'Error al cargar tipos de documento', 'error');
        }
    }
    

    cargarPaises() {
        this.paisOptions = [
            { label: 'Afganistán', value: 'Afganistán' }, { label: 'Albania', value: 'Albania' }, { label: 'Alemania', value: 'Alemania' },
            { label: 'Andorra', value: 'Andorra' }, { label: 'Angola', value: 'Angola' }, { label: 'Antigua y Barbuda', value: 'Antigua y Barbuda' },
            { label: 'Arabia Saudita', value: 'Arabia Saudita' }, { label: 'Argelia', value: 'Argelia' }, { label: 'Argentina', value: 'Argentina' },
            { label: 'Armenia', value: 'Armenia' }, { label: 'Australia', value: 'Australia' }, { label: 'Austria', value: 'Austria' },
            { label: 'Azerbaiyán', value: 'Azerbaiyán' }, { label: 'Bahamas', value: 'Bahamas' }, { label: 'Bangladés', value: 'Bangladés' },
            { label: 'Barbados', value: 'Barbados' }, { label: 'Baréin', value: 'Baréin' }, { label: 'Bélgica', value: 'Bélgica' },
            { label: 'Belice', value: 'Belice' }, { label: 'Benín', value: 'Benín' }, { label: 'Bielorrusia', value: 'Bielorrusia' },
            { label: 'Birmania (Myanmar)', value: 'Birmania (Myanmar)' }, { label: 'Bolivia', value: 'Bolivia' }, { label: 'Bosnia y Herzegovina', value: 'Bosnia y Herzegovina' },
            { label: 'Botsuana', value: 'Botsuana' }, { label: 'Brasil', value: 'Brasil' }, { label: 'Brunéi', value: 'Brunéi' },
            { label: 'Bulgaria', value: 'Bulgaria' }, { label: 'Burkina Faso', value: 'Burkina Faso' }, { label: 'Burundi', value: 'Burundi' },
            { label: 'Bután', value: 'Bután' }, { label: 'Cabo Verde', value: 'Cabo Verde' }, { label: 'Camboya', value: 'Camboya' },
            { label: 'Camerún', value: 'Camerún' }, { label: 'Canadá', value: 'Canadá' }, { label: 'Catar', value: 'Catar' },
            { label: 'Chad', value: 'Chad' }, { label: 'Chile', value: 'Chile' }, { label: 'China', value: 'China' },
            { label: 'Chipre', value: 'Chipre' }, { label: 'Colombia', value: 'Colombia' }, { label: 'Comoras', value: 'Comoras' },
            { label: 'Corea del Norte', value: 'Corea del Norte' }, { label: 'Corea del Sur', value: 'Corea del Sur' }, { label: 'Costa de Marfil', value: 'Costa de Marfil' },
            { label: 'Costa Rica', value: 'Costa Rica' }, { label: 'Croacia', value: 'Croacia' }, { label: 'Cuba', value: 'Cuba' },
            { label: 'Dinamarca', value: 'Dinamarca' }, { label: 'Dominica', value: 'Dominica' }, { label: 'Ecuador', value: 'Ecuador' },
            { label: 'Egipto', value: 'Egipto' }, { label: 'El Salvador', value: 'El Salvador' }, { label: 'Emiratos Árabes Unidos', value: 'Emiratos Árabes Unidos' },
            { label: 'Eritrea', value: 'Eritrea' }, { label: 'Eslovaquia', value: 'Eslovaquia' }, { label: 'Eslovenia', value: 'Eslovenia' },
            { label: 'España', value: 'España' }, { label: 'Estados Unidos', value: 'Estados Unidos' }, { label: 'Estonia', value: 'Estonia' },
            { label: 'Esuatini', value: 'Esuatini' }, { label: 'Etiopía', value: 'Etiopía' }, { label: 'Filipinas', value: 'Filipinas' },
            { label: 'Finlandia', value: 'Finlandia' }, { label: 'Fiyi', value: 'Fiyi' }, { label: 'Francia', value: 'Francia' },
            { label: 'Gabón', value: 'Gabón' }, { label: 'Gambia', value: 'Gambia' }, { label: 'Georgia', value: 'Georgia' },
            { label: 'Ghana', value: 'Ghana' }, { label: 'Granada', value: 'Granada' }, { label: 'Grecia', value: 'Grecia' },
            { label: 'Guatemala', value: 'Guatemala' }, { label: 'Guinea', value: 'Guinea' }, { label: 'Guinea-Bisáu', value: 'Guinea-Bisáu' },
            { label: 'Guinea Ecuatorial', value: 'Guinea Ecuatorial' }, { label: 'Guyana', value: 'Guyana' }
        ];
    }

    toggleDropdown() {
        this.mostrarDropdown = !this.mostrarDropdown;
    }

    handleEditar(event) {
        const id = event.currentTarget.dataset.id;
        this.identificacionActual = this.identificaciones.find(i => i.Id === id);
        this.isEditMode = true;
        this.isModalOpen = true;

        // Asegurar que el tipo actual esté en las opciones, aunque ya esté en uso
        const yaIncluido = this.tipoIdentificacionOptions.some(opt => opt.value === this.identificacionActual.Tipo_de_documento__c);

        if (!yaIncluido && this.identificacionActual.Tipo_de_documento__r?.Name) {
            this.tipoIdentificacionOptions = [
                ...this.tipoIdentificacionOptions,
                {
                    label: this.identificacionActual.Tipo_de_documento__r.Name,
                    value: this.identificacionActual.Tipo_de_documento__c
                }
            ];
        }
    }

    handleEliminar(event) {
        const id = event.currentTarget.dataset.id;
        this.eliminarIdentificacion(id);
    }

    handleAgregar() {
        if (!this.tipoIdentificacionOptions || this.tipoIdentificacionOptions.length === 0) {
            this.showToast('Aviso', 'Ya se han agregado todas las identificaciones permitidas.', 'warning');
            return;
        }
        this.identificacionActual = { Identificacion_principal__c: false };
        this.isEditMode = false;
        this.isModalOpen = true;
    }

    async guardarIdentificacion() {
        // if (!this.identificacionActual.Tipo_de_documento__c || !this.identificacionActual.Identificaci_n__c || !this.identificacionActual.Pais__c) {
        //     this.showToast('Error', 'Completa todos los campos', 'error');
        //     return;
        // }
        const tipoDoc = this.tipoIdentificacionOptions.find(t => t.value === this.identificacionActual.Tipo_de_documento__c)?.label?.toLowerCase() || '';
        console.log('TIPO DE DOCUMENTO');
        console.log(tipoDoc);
        const cedulaVal = this.identificacionActual.Identificaci_n__c?.toString().trim();
        const camposInvalidos = [];

        // Validación de campos obligatorios
        if (!this.identificacionActual.Tipo_de_documento__c || !cedulaVal || !this.identificacionActual.Pais__c) {
            this.showToast('Error', 'Completa todos los campos obligatorios', 'error');
            return;
        }

        // Validaciones según tipo de documento
        if (tipoDoc.includes('física') || tipoDoc.includes('nacional')) {
            if (!/^\d{9}$/.test(cedulaVal) || cedulaVal.startsWith('0')) {
                camposInvalidos.push('La cédula física debe contener exactamente 9 dígitos, sin ceros iniciales ni guiones.');
            }
        } else if (tipoDoc.includes('jurídica')) {
            if (!/^\d{10}$/.test(cedulaVal) || cedulaVal.startsWith('0')) {
                camposInvalidos.push('La cédula jurídica debe contener exactamente 10 dígitos, sin ceros iniciales ni guiones.');
            }
        } else if (tipoDoc.includes('dimex')) {
            if (!/^\d{12}$/.test(cedulaVal) || cedulaVal.startsWith('0')) {
                camposInvalidos.push('El número DIMEX debe contener exactamente 12 dígitos, sin ceros iniciales ni guiones.');
            }
        } else if (tipoDoc.includes('pasaporte')) {
            if (!/^[a-zA-Z0-9]{6,9}$/.test(cedulaVal)) {
                camposInvalidos.push('El pasaporte debe contener entre 6 y 9 caracteres alfanuméricos (sin guiones).');
            }
        }else if(labelDoc.includes('nite')){
            if (!/^\d{10}$/.test(cedulaVal)) {
                this.camposInvalidos.push('El número nite debe tener 10 números.');
            }            
        }  else {
            // Validación genérica si no se reconoce el tipo
            if (!/^\d{9,12}$/.test(cedulaVal)) {
                camposInvalidos.push('La identificación debe contener entre 9 y 12 dígitos numéricos.');
            }
        }

        if (camposInvalidos.length > 0) {
            this.showToast('Error', camposInvalidos.join('\n'), 'error');
            return;
        }


        this.identificacionActual.Cuenta__c = this.accountId;
        this.identificacionActual.Tipo_cliente__c = this.tipocliente;

        try {
            // const tipoYaExiste = this.identificaciones.some(i => 
            //     i.Tipo_de_documento__c === this.identificacionActual.Tipo_de_documento__c &&
            //     i.Id !== this.identificacionActual.Id
            // );
            
            // if (tipoYaExiste) {
            //     this.showToast('Error', 'Ya existe una identificación con este tipo. Solo se permite una por tipo.', 'error');
            //     return;
            // }
            
            await guardarIdentificacion({ identificacion: this.identificacionActual });
            this.showToast('Éxito', 'Identificación guardada', 'success');
            this.isModalOpen = false;
            this.dispatchEvent(new CustomEvent('actualizar', {
                detail: { tipo: 'identificacion', hayRegistros: true }
            }));
            await this.recargarIdentificaciones();
            await this.cargarTiposDocumento();
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
            //this.showToast('Error al guardar', e.body?.message || 'Error inesperado', 'error');
        }
    }

    async eliminarIdentificacion(id) {
        try {
            await eliminarIdentificacion({ identificacionId: id });
            this.showToast('Eliminado', 'Identificación eliminada', 'success');
            await this.recargarIdentificaciones();
            await this.cargarTiposDocumento();
        } catch (e) {
            this.showToast('Error al eliminar', e.body?.message || 'Error inesperado', 'error');
        }
    }

    handleTipoChange(event) {
        const tipoSeleccionado = event.detail.value;
        const labelSeleccionado = this.tipoIdentificacionOptions.find(opt => opt.value === tipoSeleccionado)?.label?.toLowerCase() || '';
        console.log(labelSeleccionado);
        this.identificacionActual = {
            ...this.identificacionActual,
            Tipo_de_documento__c: tipoSeleccionado
        };
    
        if (labelSeleccionado.includes('jurídica')) {
            this.identificacionActual.Pais__c = 'Costa Rica';
            this.deshabilitarPais = true;
        } else {
            this.deshabilitarPais = false;
        }
    }
    

    handleNumeroChange(event) {
        this.identificacionActual = { ...this.identificacionActual, Identificaci_n__c: event.target.value };
    }

    handlePaisChange(event) {
        this.identificacionActual = { ...this.identificacionActual, Pais__c: event.detail.value };
    }

    handlePrincipalChange(event) {
        this.identificacionActual = { ...this.identificacionActual, Identificacion_principal__c: event.target.checked };
    }

    cerrarModal() {
        this.isModalOpen = false;
    }

    get modalTitle() {
        return this.isEditMode ? 'Editar Identificación' : 'Agregar Identificación';
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}