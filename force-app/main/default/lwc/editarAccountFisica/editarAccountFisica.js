// editar-account-fisica.js
import { LightningElement, api, track } from 'lwc';
import getAccountById from '@salesforce/apex/ct_nuevoAccountController.getAccountById';
import actualizarCuenta from '@salesforce/apex/ct_nuevoAccountController.actualizarCuenta';
import actualizarCorreoYTelefono from '@salesforce/apex/ct_nuevoAccountController.actualizarCorreoYTelefono';
import eliminarCuenta from '@salesforce/apex/ct_nuevoAccountController.eliminarCuenta';
import esPerfilAdministrador from '@salesforce/apex/ct_nuevoAccountController.esPerfilAdministrador';
import buscarActividadComercial from '@salesforce/apex/ct_nuevoAccountController.buscarActividadComercial';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EditarAccountFisica extends LightningElement {
    @api recordId;

    @track firstName = '';
    @track secondName = '';
    @track lastName = '';
    @track genero = '';
    @track fechaNacimiento = '';
    @track profesion = '';
    @track estadoCivil = '';
    @track pais = 'Costa Rica';
    @track cedula = '';
    @track tipodeclientecampo = '';
    @track tipodeidentificacion = '';

    @track isLoading = false;
    @track mostrarError = false;

    @track puedeEditarCedula = false;

    @track tieneIdentificacion = false;
    @track tieneCorreo = false;
    @track tieneDireccion = false;
    @track tieneContacto = false;
    @track tieneTelefonos = false;


    @track actividadComercialId;
    @track actividadComercialName = '';
    @track actividadOptions = [];
    @track showActividadOptions = false;


     handleActividadSearch(event) {
        console.log('Entro a buscar seleccionados');
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
        console.log('Datos seleccionados');
        console.log(actividadComercialName);
        console.log(actividadComercialId);
    }

    handleSelectActividad(event) {
        const selectedId = event.currentTarget.dataset.id;
        const selectedCodigo = event.currentTarget.dataset.codigo;
        const selectedNombre = event.currentTarget.dataset.nombre;
        this.actividadComercialId = selectedId;
        this.actividadComercialName = `${selectedCodigo} - ${selectedNombre}`;
        this.showActividadOptions = false;
    }

    

    generoOptions = [
        { label: 'Hombre', value: 'Hombre' },
        { label: 'Mujer', value: 'Mujer' }
    ];

    validarCampos() {
        return this.firstName && this.lastName && this.genero && this.fechaNacimiento &&
               this.profesion && this.estadoCivil && this.cedula && this.pais;
    }
    
    profesionOptions = [
        { label: 'Medicina', value: 'Medicina' },
        { label: 'Administración', value: 'Administración' },
        { label: 'Ingenieria', value: 'Ingenieria' },
        { label: 'Leyes', value: 'Leyes' },
        { label: 'Arquitectura', value: 'Arquitectura' },
        { label: 'Negocio y Finanzas', value: 'Negocio y Finanzas' },
        { label: 'Empresario', value: 'Empresario' },
        { label: 'Educación', value: 'Educación' },
        { label: 'Publicidad/Comunicación', value: 'Publicidad/Comunicación' },
        { label: 'Veterinaria', value: 'Veterinaria' },
        { label: 'Odontología', value: 'Odontología' },
        { label: 'Otros', value: 'Otros' }
    ];

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

    estadoCivilOptions = [
        { label: 'Casado', value: 'Casado' }, { label: 'Desconocido', value: 'Desconocido' },
        { label: 'Divorciado', value: 'Divorciado' }, { label: 'Separado', value: 'Separado' },
        { label: 'Soltero', value: 'Soltero' }, { label: 'Viudo', value: 'Viudo' },
        { label: 'Ninguno', value: 'Ninguno' }
    ];

    connectedCallback() {
        console.log('RecordId recibido en V2:', this.recordId);
        this.esperarRecordId();
        // this.cargarCuenta();
        // this.cargarPaises();
        // esPerfilAdministrador()
        // .then(resultado => {
        //     this.puedeEditarCedula = !resultado;
        // })
        // .catch(error => {
        //     console.error('Error al verificar perfil:', error);
        // });
    }

    esperarRecordId(reintentos = 3) {
        this.isLoading = true;
        if (this.recordId) {
            console.log('RecordId recibido:', this.recordId);
            this.cargarCuenta(); 
            this.cargarPaises();
            this.cargarCuenta();
            this.cargarPaises();
            esPerfilAdministrador()
            .then(resultado => {
                this.puedeEditarCedula = !resultado;
            })
            .catch(error => {
                console.error('Error al verificar perfil:', error);
                this.showToast('Error', 'No se pudo verificar el perfil.', 'error');
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

    async cargarCuenta() {
        this.isLoading = true;
        try {
            const acc = await getAccountById({ accountId: this.recordId });
            this.firstName = acc.FirstName || '';
            this.secondName = acc.MiddleName || '';
            this.lastName = acc.LastName || '';
            this.genero = acc.Sexo__c || '';
            this.fechaNacimiento = acc.Fecha_Nacimiento__c || '';
            this.profesion = acc.Profesiones__c || '';
            this.estadoCivil = acc.EstadoCivilTipos__c || '';
            this.cedula = acc.Cedula__c || '';
            this.pais = acc.PaisPicklist__c || 'Costa Rica';
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
            this.showToast('Error', 'No se pudo cargar la cuenta', 'error');
            console.error(error);
        }
        this.isLoading = false;
    }

    handlePaisChange(event) {
        const field = event.target.name;
        let value = event.detail.value;
        this[field] = value;
            
    }

    handleInputChange(event) {
        const field = event.target.name;
        let value = event.target.value;

        if (["firstName", "secondName", "lastName", "profesion"].includes(field)) {
            value = value.replace(/[^a-zA-ZáéíóúÁÉÍÓÚñÑ\s]/g, '');
            event.target.value = value;
        }

        this[field] = value;
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

        this.isLoading = true;
        const datos = {
            FirstName: this.firstName,
            MiddleName: this.secondName,
            LastName: this.lastName,
            Sexo__c: this.genero,
            Fecha_Nacimiento__c: this.fechaNacimiento,
            Profesiones__c: this.profesion,
            EstadoCivilTipos__c: this.estadoCivil,
            Cedula__c: this.cedula,
            PaisPicklist__c: this.pais,
            Tipos_de_cuenta__c: this.tipodeclientecampo,
            Tipo_de_Documento__c: this.tipodeidentificacion,
            Actividad_Comercial__c: this.actividadComercialId
        };

        try {
            await actualizarCuenta({ accountId: this.recordId, campos: datos });
            this.showToast('Éxito', 'La cuenta fue actualizada correctamente.', 'success');
            
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
            case 'telefono': this.tieneTelefonos = hayRegistros; break;
        }
    }


    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}