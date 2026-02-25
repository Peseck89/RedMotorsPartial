// editar-account-juridica.js
import { LightningElement, api, track } from 'lwc';
import getAccountById from '@salesforce/apex/ct_nuevoAccountController.getAccountById';
import actualizarCuenta from '@salesforce/apex/ct_nuevoAccountController.actualizarCuenta';
import actualizarCorreoYTelefono from '@salesforce/apex/ct_nuevoAccountController.actualizarCorreoYTelefono';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import eliminarCuenta from '@salesforce/apex/ct_nuevoAccountController.eliminarCuenta';
import esPerfilAdministrador from '@salesforce/apex/ct_nuevoAccountController.esPerfilAdministrador';
import buscarActividadComercial from '@salesforce/apex/ct_nuevoAccountController.buscarActividadComercial';


export default class EditarAccountJuridica extends LightningElement {
    @api recordId;
    @api tipocliente;

    @track nombre = '';
    @track giro = '';
    @track pais = '';
    @track cedula = '';
    @track tipodeclientecampo = '';
    @track tipodeidentificacion = '';
    @track giroNegocioOptions
    @track isLoading = false;
    @track mostrarError = false;

    @track puedeEditarCedula = false;

    @track tieneIdentificacion = false;
    @track tieneCorreo = false;
    @track tieneDireccion = false;
    @track tieneContacto = false;
    @track tieneTelefono = false;

    @track actividadComercialId;
    @track actividadComercialName = '';
    @track actividadOptions = [];
    @track showActividadOptions = false;


    handleActividadSearch(event) {
        const searchKey = event.target.value;
        this.actividadComercialName = searchKey;

        if (searchKey.length >= 2) {
            buscarActividadComercial({ searchKey })
                .then(result => {
                    this.actividadOptions = result;
                    this.showActividadOptions = result.length > 0;
                })
                .catch(error => {
                    console.error('Error al buscar actividad comercial:', error);
                });
        } else {
            this.showActividadOptions = false;
        }
    }

    handleSelectActividad(event) {
        const selectedId = event.currentTarget.dataset.id;
        const selectedCodigo = event.currentTarget.dataset.codigo;
        const selectedNombre = event.currentTarget.dataset.nombre;
        this.actividadComercialId = selectedId;
        this.actividadComercialName = `${selectedCodigo} - ${selectedNombre}`;
        this.showActividadOptions = false;
    }

    connectedCallback() {
        this.esperarRecordId();


        
    }

    esperarRecordId(reintentos = 3) {
        this.isLoading = true;
        if (this.recordId) {
            console.log('RecordId recibido:', this.recordId);
            this.cargarCuenta();
            this.cargarGiros();
            esPerfilAdministrador()
            .then(resultado => {
                console.log('resultado: ', resultado);
                this.puedeEditarCedula = !resultado;
            })
            .catch(error => {
                console.error('Error al verificar perfil:', error);
            });
            this.isLoading = false;
        } else if (reintentos > 0) {
            console.warn('Esperando recordId... reintentos restantes:', reintentos);
            setTimeout(() => {
                this.esperarRecordId(reintentos - 1);
            }, 2000); // espera 2 segundos
        } else {
            console.error('No se recibió recordId después de varios intentos');
            this.showToast('Error', 'No se pudo obtener el ID del registro.', 'error');
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

    async cargarCuenta() {
        this.isLoading = true;
        try {
            const acc = await getAccountById({ accountId: this.recordId });
            this.nombre = acc.Name || '';
            this.giro = acc.Description || '';
            this.pais = acc.PaisPicklist__c || '';
            this.cedula = acc.Cedula__c || '';
            this.tipodeclientecampo = acc.Tipos_de_cuenta__c || '';
            this.tipodeidentificacion = acc.Tipo_de_Documento__c || '';
            this.actividadComercialId = acc.C_digo_actividad_econ_mica_Hacienda__c || null;
            this.actividadComercialName = acc.C_digo_actividad_econ_mica_Hacienda__r ? acc.C_digo_actividad_econ_mica_Hacienda__r.Name : '';
            console.log('actividadComercialName');
            console.log(this.actividadComercialName);
            if (acc.C_digo_actividad_econ_mica_Hacienda__r) {
                const codigo = acc.C_digo_actividad_econ_mica_Hacienda__r.Name || '';
                const nombre = acc.C_digo_actividad_econ_mica_Hacienda__r.Nombre_actividad_econ_mica__c || '';
                this.actividadComercialName = `${codigo} - ${nombre}`;
            }
        } catch (error) {
            this.showToast('Error', 'No se pudo cargar la cuenta.', 'error');
            console.error(error);
        }
        this.isLoading = false;
    }

    handleInputChange(event) {
        const field = event.target.name;
        let value = event.target.value;
        // Aplicar limpieza a los campos con letras solamente
        if (['nombre', 'giro'].includes(field)) {
            const cleaned = value.replace(/[^a-zA-ZáéíóúÁÉÍÓÚñÑ\s]/g, '');
            
            // Actualizar el valor del input DOM directamente
            if (value !== cleaned) {
                event.target.value = cleaned;
            }

            value = cleaned;
        }

        this[field] = value;
    }

    validarCampos() {
        return this.nombre && this.giro && this.cedula && this.pais;
    }

    async handleGuardar() {
        this.mostrarError = false;

        const faltantes = [];

        //if (!this.tieneIdentificacion) faltantes.push('Identificación');
        if (!this.tieneCorreo) faltantes.push('Correo');
        if (!this.tieneDireccion) faltantes.push('Dirección');
        if (!this.tieneTelefonos) faltantes.push('Teléfono');
        if (!this.tieneContacto) faltantes.push('Contacto');

        if (faltantes.length > 0) {
            const mensaje = `Debe agregar: ${faltantes.join(', ')}.`;
            this.showToast('Error', mensaje, 'error');
            return;
        }

        if (!this.validarCampos()) {
            this.mostrarError = true;
            this.showToast('Error', 'Completa todos los campos obligatorios.', 'error');
            return;
        }

        const datos = {
            Name: this.nombre,
            Description: this.giro,
            Cedula__c: this.cedula,
            PaisPicklist__c: this.pais,
            Tipos_de_cuenta__c: this.tipodeclientecampo,
            Tipo_de_Documento__c: this.tipodeidentificacion,
            Actividad_Comercial__c: this.actividadComercialId
        };

        this.isLoading = true;
        try {
            await actualizarCuenta({ accountId: this.recordId, campos: datos });
            this.showToast('Éxito', 'La cuenta fue actualizada correctamente.', 'success');
            window.location.reload();
            await actualizarCorreoYTelefono({ accountId: this.recordId });
            window.location.reload();
        } catch (error) {
            console.error(error);
            let mensajeError = 'Ocurrió un error inesperado.';
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
    
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}