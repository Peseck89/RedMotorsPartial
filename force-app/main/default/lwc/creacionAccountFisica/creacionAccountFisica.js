// creacion-account-fisica.js
import { LightningElement, api, track } from 'lwc';
import getDatosCliente from '@salesforce/apex/ApiCreditLWCWS.getInfoCliente';
import crearCuenta from '@salesforce/apex/ct_nuevoAccountController.crearCuenta';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import actualizarCorreoYTelefono from '@salesforce/apex/ct_nuevoAccountController.actualizarCorreoYTelefono';
import eliminarCuenta from '@salesforce/apex/ct_nuevoAccountController.eliminarCuenta';
import { NavigationMixin } from 'lightning/navigation';
import crearIdentificacionInicial from '@salesforce/apex/IdentificacionController.crearIdentificacionInicial';
import esPerfilAdministrador from '@salesforce/apex/ct_nuevoAccountController.esPerfilAdministrador';


export default class CreacionAccountFisica extends NavigationMixin(LightningElement) {
    @api tipocliente;
    @api tipodeclientecampo;
    @api tipodeidentificacion;
    @api pais;
    @api cedula;
    @api recordTypeId;

    @track isLoading = false;
    @track recordId;
    @track mostrarError = false;
    @track mensajeError = 'Por favor revise los errores.';

    @track firstName = '';
    @track secondName = '';
    @track lastName = '';
    @track genero = '';
    @track fechaNacimiento = '';
    @track profesion = '';
    @track estadoCivil = '';

    @track tieneIdentificacion = false;
    @track tieneCorreo = false;
    @track tieneDireccion = false;
    @track tieneContacto = false;
    @track tieneTelefonos = false;

    @api actualizarTieneIdentificacion(valor) {
        this.tieneIdentificacion = valor;
    }
    @api actualizarTieneCorreo(valor) {
        this.tieneCorreo = valor;
    }
    @api actualizarTieneDireccion(valor) {
        this.tieneDireccion = valor;
    }
    @api actualizarTieneContacto(valor) {
        this.tieneContacto = valor;
    }

    generoOptions = [
        { label: 'Hombre', value: 'Hombre' },
        { label: 'Mujer', value: 'Mujer' }
    ];

    estadoCivilOptions = [
        { label: 'Casado', value: 'Casado' },
        { label: 'Desconocido', value: 'Desconocido' },
        { label: 'Divorciado', value: 'Divorciado' },
        { label: 'Separado', value: 'Separado' },
        { label: 'Soltero', value: 'Soltero' },
        { label: 'Viudo', value: 'Viudo' },
        { label: 'Ninguno', value: 'Ninguno' }
    ];

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

    connectedCallback() {
        this.getInfoCliente();
        this.cargarPaises();
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

    async getInfoCliente() {
        try {
            const response = await getDatosCliente({ cedulaCliente: this.cedula });
            if (response) {
                const nombres = response.nombre?.split(' ') || [];
                this.firstName = nombres[0] || '';
                this.secondName = nombres.slice(1).join(' ');
                this.genero = nombres[0]?.endsWith('a') ? 'Mujer' : 'Hombre';
                this.lastName = `${response.apellido1 || ''} ${response.apellido2 || ''}`.trim();
                this.fechaNacimiento = response.fechaNacimiento;
                this.profesion = response.profesiones?.[0] || '';
                this.estadoCivil = response.estadoCivil;
            }
        } catch (e) {
            console.error('Error en getInfoCliente', e);
        }
    }

    handleInputChange(event) {
        this.mostrarError = false;
        const field = event.target.name;
        let value = event.target.value;
    
        // Aplicar limpieza a los campos con letras solamente
        if (['firstName', 'secondName', 'lastName', 'profesion'].includes(field)) {
            const cleaned = value.replace(/[^a-zA-ZáéíóúÁÉÍÓÚñÑ\s]/g, '');
            
            // Actualizar el valor del input DOM directamente
            if (value !== cleaned) {
                event.target.value = cleaned;
            }
    
            value = cleaned;
        }
    
        this[field] = value;
    }
    
    handlePaisChange(event) {
        const field = event.target.name;
        let value = event.detail.value;
        this[field] = value;
            
    }
    

    validarCampos() {
        if (!this.firstName || !this.lastName || !this.genero || !this.fechaNacimiento ||
            !this.profesion || !this.estadoCivil || !this.cedula || !this.pais) {
                this.showToast('Error', 'Completa todos los campos obligatorios.', 'error');
                this.mensajeError = 'Completa todos los campos obligatorios.'
            return false;
        }
    
        const hoy = new Date();
        const fechaNac = new Date(this.fechaNacimiento);
    
        const edad = hoy.getFullYear() - fechaNac.getFullYear();
        const mes = hoy.getMonth() - fechaNac.getMonth();
        const dia = hoy.getDate() - fechaNac.getDate();
    
        // Ajuste si aún no ha cumplido años este año
        const edadReal = (mes < 0 || (mes === 0 && dia < 0)) ? edad - 1 : edad;
        if(edadReal < 18 || edadReal > 100){
            this.mensajeError = 'La fecha de nacimiento es incorrecta (El cliente debe ser mayor de 18 y menor que 100 años).'
            this.showToast('Error', 'La fecha de nacimiento es incorrecta (El cliente debe ser mayor de 18 y menor que 100 años).', 'error');
        }
        return edadReal >= 18 && edadReal <= 100;
    }

    async handleSiguiente() {
        this.isLoading = true;
        this.mostrarError = false;
        if (!this.validarCampos()) {
            this.mostrarError = true;
            this.isLoading = false;
            
            return;
        }
    
        const cuenta = {
            Cedula__c: this.cedula,
            PaisPicklist__c: this.pais,
            Tipos_de_cuenta__c: this.tipodeclientecampo,
            Tipo_de_Documento__c: this.tipodeidentificacion,
            FirstName: this.firstName,
            MiddleName: this.secondName,
            LastName: this.lastName,
            Sexo__c: this.genero,
            Fecha_Nacimiento__c: this.fechaNacimiento,
            Profesiones__c: this.profesion,
            EstadoCivilTipos__c: this.estadoCivil,
            RecordTypeId: this.recordTypeId
        };
    
        try {
            const id = await crearCuenta({ accountData: cuenta });
            this.recordId = id;
            //this.showToast('Cuenta creada', 'La cuenta fue creada correctamente.', 'success');
            console.log('Entro a crear Iniciales');
            console.log('Datos Iniciales');
            console.log(this.recordId);
            console.log(this.tipodeidentificacion);
            console.log(this.cedula);
            await crearIdentificacionInicial({
                accountId: this.recordId,
                tipoDocumentoId: this.tipodeidentificacion,
                pais: this.pais,
                numeroIdentificacion: this.cedula
            });
    
        } catch (error) {
            console.log(error);
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

    async handleFinalizar() {
        const faltantes = [];

        // if (!this.tieneIdentificacion) faltantes.push('Identificación');
        if (!this.tieneCorreo) faltantes.push('Correo');
        if (!this.tieneDireccion) faltantes.push('Dirección');
        if (!this.tieneTelefonos) faltantes.push('Teléfono');
        // if (!this.tieneContacto) faltantes.push('Contacto');

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
}