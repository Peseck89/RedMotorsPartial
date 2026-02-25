import { LightningElement, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import obtenerTiposDocumentoCuenta from '@salesforce/apex/ct_nuevoAccountController.obtenerTiposDocumentoCuenta';
import validarCuentaExistente from '@salesforce/apex/ct_nuevoAccountController.validarCuentaExistente';


export default class CreateAccountLWC extends LightningElement {
    @track tipoCliente = 'Cliente Físico';
    @track tipoDeClienteCampo = 'Persona Física';
    @track tipoDeIdentificacion = 'a6HPH000000yhTV2AY';
    @track Pais = 'Costa Rica';
    @track Cedula = '';
    @track isFirstStep = true;
    @track isCuentaPersonal = false;
    @track isCuentaEmpresarial = false;
    @track mostrarError = false;
    @track clienteFisico = true;
    @track clienteJuridico = false;
    @track defaultPais = 'Costa Rica';
    @track recordTypeId;
    @track deshabilitarPais = false;

    @track camposInvalidos = [];
    @track tiposDocumento = [];

    recordTypeIdFisico;
    recordTypeIdJuridico;

    handleChangeTipoDocumento(event) {
        this.tipoDeIdentificacion = event.detail.value;
        const labelSeleccionado = this.getTipoDocumentoLabel();
    
        if (labelSeleccionado.includes('jurídica')) {
            this.Pais = 'Costa Rica';
            this.deshabilitarPais = true;
        } else {
            this.deshabilitarPais = false;
        }
    }
    
    cambiarPais(){
        this.deshabilitarPais = true;
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

    handleChangePais(event) {
        this.Pais = event.detail.value;
    }

    resetCampos() {
        this.tipoDeClienteCampo = this.clienteFisico ? 'Persona Física' : 'Persona Jurídica';
        this.deshabilitarPais = false;
        this.Pais = 'Costa Rica';
        this.Cedula = '';
        this.mostrarError = false;
        this.camposInvalidos = [];
        this.tiposDocumento = [];
    }

    
    connectedCallback(){
        this.cargarPaises();
        this.tipoDeClienteCampo = 'Persona Física';
        this.obtenerTiposDeDocumento(); // ← llamada aquí
    }

    get tipoDocumentoOptions() {
        //this.obtenerTiposDeDocumento();
        return this.tiposDocumento.map(doc => {
            return {
                label: doc.Tipo_de_documento__r.Name,
                value: doc.Tipo_de_documento__c
            };
        });
    }

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    wiredAccountInfo({ data, error }) {
        if (data) {
            for (let rtId in data.recordTypeInfos) {
                const rt = data.recordTypeInfos[rtId];
                if (rt.name === 'Cliente Físico') {
                    this.recordTypeIdFisico = rtId;
                } else if (rt.name === 'Cuenta empresarial') {
                    this.recordTypeIdJuridico = rtId;
                }
            }
            console.log(this.recordTypeIdJuridico);
            this.recordTypeId = this.recordTypeIdFisico;
        } else if (error) {
            console.error('Error al obtener record types de Account', error);
        }
    }

    handleClienteFisico() {
        this.tipoCliente = 'Cliente Físico';
        this.clienteFisico = true;
        this.clienteJuridico = false;
        this.recordTypeId = this.recordTypeIdFisico;
        this.tipoDeIdentificacion = 'a6HPH000000yhTV2AY';
        this.resetCampos();
        this.obtenerTiposDeDocumento(); // <- para refrescar combobox
    }

    handleClienteJuridico() {
        this.tipoCliente = 'Cliente Jurídico';
        this.clienteFisico = false;
        this.clienteJuridico = true;
        this.recordTypeId = this.recordTypeIdJuridico;
        this.tipoDeIdentificacion = 'a6FO5000000Q2B3MAK';
        this.resetCampos();
        this.obtenerTiposDeDocumento(); // <- para refrescar combobox
        console.log('es juridica');
        console.log(this.recordTypeId);
    }

    handleInputCedula(event) {
        this.mostrarError = false;
        let value = event.target.value;

        // Limita a máximo 12 dígitos
        if (value.length > 12) {
            value = value.slice(0, 12);
        }

        this.Cedula = value;
    }

    obtenerTiposDeDocumento() {
        this.deshabilitarPais = false;
        console.log('entro a tipo doc')
        console.log(this.tipoDeClienteCampo)
        if (this.tipoDeClienteCampo && this.tipoDeClienteCampo !== '--None--') {
            obtenerTiposDocumentoCuenta({ tipoCuenta: this.tipoDeClienteCampo })
                .then(result => {
                    this.tiposDocumento = result;
                    console.log(result);
                    console.log(this.tiposDocumento);
                })
                .catch(error => {
                    console.error('Error al obtener tipos de documento:', error);
                });
        } else {
            this.tiposDocumento = [];
        }
    }

    async handleSiguiente() {
        //this.tipoDeClienteCampo = this.template.querySelector('lightning-combobox[data-id="tipoDeClienteCampo"]').value;

        this.tipoDeIdentificacion = this.template.querySelector('lightning-combobox[data-id="tipoDeIdentificacion"]').value;

        this.Pais = this.template.querySelector('lightning-combobox[data-id="Pais"]').value;

        this.Cedula = this.template.querySelector('lightning-input[data-id="Cedula"]').value;
        const labelDoc = this.getTipoDocumentoLabel();
        const cedulaVal = this.Cedula.trim();

        this.camposInvalidos = [];
    
        if (!this.tipoDeClienteCampo || this.tipoDeClienteCampo === '--None--') {
            this.camposInvalidos.push('Tipo de Cliente');
        }
    
        if (!this.tipoDeIdentificacion || this.tipoDeIdentificacion === '--None--') {
            this.camposInvalidos.push('Tipo de Identificación');
        }
    
        if (!this.Pais || this.Pais === '--None--') {
            this.camposInvalidos.push('País de la Identificación');
        }
    
        // Validaciones generales
        if (!cedulaVal) {
            this.camposInvalidos.push('Identificación es obligatoria');
        } else if (labelDoc.includes('física') || labelDoc.includes('nacional') ) {
            if (!/^\d{9}$/.test(cedulaVal) || cedulaVal.startsWith('0')) {
                this.camposInvalidos.push('La cédula física debe contener exactamente 9 dígitos, sin ceros iniciales ni guiones');
            }
        } else if (labelDoc.includes('jurídica')) {
            if (!/^\d{10}$/.test(cedulaVal) || cedulaVal.startsWith('0')) {
                this.camposInvalidos.push('La cédula jurídica debe contener exactamente 10 dígitos, sin ceros iniciales ni guiones');
            }
        } else if (labelDoc.includes('dimex')) {
            if (!/^\d{12}$/.test(cedulaVal) || cedulaVal.startsWith('0')) {
                this.camposInvalidos.push('El número DIMEX debe contener exactamente 12 dígitos, sin ceros iniciales ni guiones');
            }
        } else if (labelDoc.includes('pasaporte')) {
            if (!/^[a-zA-Z0-9]{6,9}$/.test(cedulaVal)) {
                this.camposInvalidos.push('El pasaporte debe contener entre 6 y 9 caracteres alfanuméricos (sin guiones)');
            }
        }else if(labelDoc.includes('nite')){
            if (!/^\d{9}$/.test(cedulaVal)) {
                this.camposInvalidos.push('El número nite debe tener 9 números.');
            }            
        } else {
            // En caso de documento no reconocido, se mantiene la validación genérica
            if (!/^\d{9,12}$/.test(cedulaVal)) {
                this.camposInvalidos.push('Identificación debe contener entre 9 y 12 dígitos numéricos');
            }
        }
    
        if (this.camposInvalidos.length > 0) {
            this.mostrarError = true;
            return;
        }

          // 🛑 Validación contra cuentas existentes
        try {
            await validarCuentaExistente({ 
                cedula: cedulaVal, 
                tipoCuenta: this.tipoDeClienteCampo 
            });
        } catch (error) {
            this.mostrarError = true;
            this.camposInvalidos = ['Ya existe una cuenta con este tipo y número de cédula.'];
            return;
        }
    
        this.mostrarError = false;
        this.isFirstStep = false;
    
        if (this.tipoCliente === 'Cliente Físico') {
            this.isCuentaPersonal = true;
        } else {
            this.isCuentaEmpresarial = true;
        }
        
    }

    handleChangeTipoDeClienteCampo(event) {
        this.tipoDeClienteCampo = event.detail.value;
        this.obtenerTiposDeDocumento(); // ← llamada aquí
    }
    

    handleCancelar() {
        // Puedes personalizar esto según tu flujo
        this.isFirstStep = true;
        this.isCuentaPersonal = false;
        this.isCuentaEmpresarial = false;
        this.mostrarError = false;
        this.camposInvalidos = [];
        this.Cedula = '';
    }

    getTipoDocumentoLabel() {
        const tipo = this.tipoDocumentoOptions.find(opt => opt.value === this.tipoDeIdentificacion);
        console.log(tipo ? tipo.label.toLowerCase() : '');
        return tipo ? tipo.label.toLowerCase() : '';
    }
}