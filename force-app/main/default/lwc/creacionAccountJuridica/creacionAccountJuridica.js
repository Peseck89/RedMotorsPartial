// creacion-account-juridica.js
import { LightningElement, api, track } from 'lwc';
import getDatosCliente from '@salesforce/apex/ApiCreditLWCWS.getInfoCliente';
import crearCuenta from '@salesforce/apex/ct_nuevoAccountController.crearCuentaJuridica';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import eliminarCuenta from '@salesforce/apex/ct_nuevoAccountController.eliminarCuenta';

import actualizarCorreoYTelefono from '@salesforce/apex/ct_nuevoAccountController.actualizarCorreoYTelefono';

import crearIdentificacionInicial from '@salesforce/apex/IdentificacionController.crearIdentificacionInicial';


export default class CreacionAccountJuridica extends NavigationMixin(LightningElement) {
    @api tipocliente;
    @api tipodeclientecampo;
    @api tipodeidentificacion;
    @api pais;
    @api cedula;
    @api recordTypeId;

    @track recordId;
    @track nombre = '';
    @track giro = '';
    @track mostrarError = false;
    @track isLoading = false;

    @track tieneIdentificacion = false;
    @track tieneCorreo = false;
    @track tieneDireccion = false;
    @track tieneContacto = false;
    @track tieneTelefono = false;
    @track giroNegocioOptions
    @track isJuridico

    connectedCallback() {
        this.getInfoCliente();
        this.cargarGiros();
        if(this.tipocliente == 'Juridico'){
            this.isJuridico = true;
            console.log('Tipo de cliente: ', this.tipocliente);
        } else {
            this.isJuridico = false;
            console.log('Tipo de cliente: ', this.tipocliente);
        }
    }

    cargarGiros() {
        this.giroNegocioOptions = [        
            { label: 'Industria y Manufactura', value: 'Industria y Manufactura' },
            { label: 'Comercio', value: 'Comercio' },
            { label: 'Servicios Profesionales y Corporativos', value: 'Servicios Profesionales y Corporativos' },
            { label: 'Salud y Bienestar', value: 'Salud y Bienestar' },
            { label: 'Turismo, Hotelería y Entretenimiento', value: 'Turismo, Hotelería y Entretenimiento' },
            { label: 'Educación', value: 'Educación' },
            { label: 'Finanzas y Seguros', value: 'Finanzas y Seguros' },
            { label: 'Construcción e Inmobiliaria', value: 'Construcción e Inmobiliaria' },
            { label: 'Transporte y Logística', value: 'Transporte y Logística' },
            { label: 'Agroindustria', value: 'Agroindustria' },
            { label: 'Tecnología e Innovación', value: 'Tecnología e Innovación' },
            { label: 'Comunicación y Publicidad', value: 'Comunicación y Publicidad' },
            { label: 'Otros', value: 'Otros' }
        ];
    }

    async getInfoCliente() {
        try {
            const response = await getDatosCliente({ cedulaCliente: this.cedula });
            if (response && response.nombre) {
                //this.nombre = response.nombre;
            }
        } catch (e) {
            console.error('Error al obtener datos del cliente:', e);
        }
    }

    handleInputChange(event) {
        const field = event.target.name;
        this[field] = event.target.value;
    }

    validarCampos() {
        return this.nombre && this.giro && this.cedula && this.pais;
    }

    async handleSiguiente() {
        this.isLoading = true;

        if (!this.validarCampos()) {
            this.mostrarError = true;
            this.isLoading = false;
            this.showToast('Error', 'Completa todos los campos obligatorios.', 'error');
            return;
        }
        console.log('this.recordTypeId Antes de crear')
        console.log(this.recordTypeId)
        const cuenta = {
            Cedula__c: this.cedula,
            Name: this.nombre,
            PaisPicklist__c: this.pais,
            Description: this.giro,
            Tipos_de_cuenta__c: this.tipodeclientecampo,
            Tipo_de_Documento__c: this.tipodeidentificacion,
            RecordTypeId: this.recordTypeId
        };

        try {
            const id = await crearCuenta({ accountData: cuenta });
            this.recordId = id;
            this.showToast('Cuenta creada', 'La cuenta fue creada correctamente.', 'success');
             // Crear Identificación principal
             await crearIdentificacionInicial({
                accountId: this.recordId,
                tipoDocumentoId: this.tipodeidentificacion,
                pais: this.pais,
                numeroIdentificacion: this.cedula
            });
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
        }

        this.isLoading = false;
    }


    async handleCancelar() {
        if (this.recordId) {
            try {
                await eliminarCuenta({ accountId: this.recordId });
                //this.showToast('Cancelado', 'La cuenta ha sido eliminada.', 'info');
            } catch (error) {
                this.showToast('Error', 'No se pudo eliminar la cuenta: ' + (error.body?.message || error.message), 'error');
            }
        }
        window.location.reload();
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    handleActualizacion(event) {
        const { tipo, hayRegistros } = event.detail;
        switch (tipo) {
            case 'direccion': this.tieneDireccion = hayRegistros; break;
            case 'correo': this.tieneCorreo = hayRegistros; break;
            case 'identificacion': this.tieneIdentificacion = hayRegistros; break;
            case 'contacto': this.tieneContacto = hayRegistros; break;
            case 'telefono': this.tieneTelefono = hayRegistros; break;
        }
    }

    async handleFinalizar() {

        const faltantes = [];

        // if ( !this.tieneCorreo || !this.tieneDireccion || !this.tieneContacto) {
        //     this.showToast('Error', 'Debe agregar al menos una Identificación, Dirección, Correo y Contacto relacionado.', 'error');
        //     return;
        // }

        if (!this.tieneCorreo) faltantes.push('Correo');
        if (!this.tieneDireccion) faltantes.push('Dirección');
        if (!this.tieneContacto) faltantes.push('Contacto');
        if (!this.tieneTelefono) faltantes.push('Telefono');

        if (faltantes.length > 0) {
            const mensaje = `Debe agregar: ${faltantes.join(', ')}.`;
            this.showToast('Error', mensaje, 'error');
            return;
        }

        try {
            await actualizarCorreoYTelefono({ accountId: this.recordId });
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    objectApiName: 'Account',
                    actionName: 'view'
                }
            }, true);
            //Recargar la página actual (cerrando el LWC)
            setTimeout(() => {
                window.location.reload();
            }, 1500); // Pequeño delay para asegurar que la navegación ocurra antes

        } catch (e) {
            console.error('Error al actualizar correo y teléfono', e);
        }
        
    }
    
    
}