import { LightningElement, api, track } from 'lwc';
import obtenerContactos from '@salesforce/apex/ContactoPorCuentaController.obtenerContactos';
import guardarContactoPorCuenta from '@salesforce/apex/ContactoPorCuentaController.guardarContactoPorCuenta';
import eliminarContactoPorCuenta from '@salesforce/apex/ContactoPorCuentaController.eliminarContactoPorCuenta';
import obtenerTiposContacto from '@salesforce/apex/ContactoPorCuentaController.obtenerTiposContacto';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import verificarCorreoExistente from '@salesforce/apex/ContactoPorCuentaController.verificarCorreoExistente';
import obtenerTiposDatosComunicacion from '@salesforce/apex/CorreoController.obtenerTiposDatosComunicacion';
import obtenerTiposDatosComunicacionTel from "@salesforce/apex/TelefonoController.obtenerTiposDatosComunicacion";


export default class Contactosrelacionadoscuenta extends LightningElement {
    @api accountId;
    @api tipocliente;

    @track contactos = [];
    @track primerContacto = null;
    @track otrosContactos = [];
    @track tiposContacto = [];
    @track contactoActual = {};
    @track isModalOpen = false;
    @track tiposDatosComunicacion = [];
    @track tiposDatosComunicacionTel = [];
    @track hasRendered = false;
    @track mostrarDropdown = false;
    @track isJuridico = false;
    @track deshabilitarGuardar = false;
    @track isSegundoPaso = false;
    tiposTelefono = [
        { label: "Fijo", value: "Fijo" },
        { label: "Móvil", value: "Móvil" },
      ];
    codigosArea = [
        { label: "+506 (Costa Rica)", value: "+506" },
        { label: "+1 (Estados Unidos)", value: "+1" },
        { label: "+54 (Argentina)", value: "+54" },
        { label: "+501 (Belice)", value: "+501" },
        { label: "+591 (Bolivia)", value: "+591" },
        { label: "+55 (Brasil)", value: "+55" },
        { label: "+56 (Chile)", value: "+56" },
        { label: "+57 (Colombia)", value: "+57" },
        { label: "+53 (Cuba)", value: "+53" },
        { label: "+1 (República Dominicana)", value: "+1 (República Dominicana)" },
        { label: "+593 (Ecuador)", value: "+593" },
        { label: "+503 (El Salvador)", value: "+503" },
        { label: "+502 (Guatemala)", value: "+502" },
        { label: "+592 (Guyana)", value: "+592" },
        { label: "+504 (Honduras)", value: "+504" },
        { label: "+52 (México)", value: "+52" },
        { label: "+505 (Nicaragua)", value: "+505" },
        { label: "+507 (Panamá)", value: "+507" },
        { label: "+595 (Paraguay)", value: "+595" },
        { label: "+51 (Perú)", value: "+51" },
        { label: "+1 (Puerto Rico)", value: "+1 (Puerto Rico)" },
        {
          label: "+1 (San Cristóbal y Nieves)",
          value: "+1 (San Cristóbal y Nieves)",
        },
        { label: "+1 (Santa Lucía)", value: "+1 (Santa Lucía)" },
        {
          label: "+1 (San Vicente y las Granadinas)",
          value: "+1 (San Vicente y las Granadinas)",
        },
        { label: "+597 (Surinam)", value: "+597" },
        { label: "+598 (Uruguay)", value: "+598" },
        { label: "+58 (Venezuela)", value: "+58" },
      ];

      

    renderedCallback() {
        if (this.hasRendered) return;
        this.hasRendered = true;
        this.recargarContactos();
        this.cargarTipos();
        this.cargarTiposDatosComunicacion();
        this.cargarTiposDatosComunicacionTel();
        console.log('Tipo Cliente desde contactos relacionados: ', this.tipocliente);
        if (this.tipocliente === 'Cliente Jurídico' || this.tipocliente == 'Cuenta empresarial') {
            this.isJuridico = true;
        }
    }

    async cargarTiposDatosComunicacionTel() {
        try {
          const result = await obtenerTiposDatosComunicacionTel({ accountId: this.accountId });
          this.tiposDatosComunicacionTel = result.map((item) => ({
            label: item.Name,
            value: item.Id,
          }));
        } catch (error) {
          this.showToast(
            "Error",
            "No se pudieron cargar los tipos de datos.",
            "error"
          );
        }
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
    handleTipoDatoChange(event) {
        this.contactoActual = { ...this.contactoActual, Tipo_de_datos_de_comunicaci_n__c: event.detail.value };
    }

    handleTipoChangeTipoTel(event) {
        this.contactoActual = {
          ...this.contactoActual,
          Tipo_telefono__c: event.detail.value,
        };
      }

    handleTipoDatoChangeTel(event) {
        this.contactoActual = {
          ...this.contactoActual,
          Tipo_de_datos_de_comunicaci_n_tel_fono__c: event.detail.value,
        };
    }

    connectedCallback(){
        this.contactoActual = {
            codigoArea: '+506'
            // otros campos si se quieren precargados al inicio Jhon
        };
        console.log('contacto iNical');
        console.log(this.contactoActual);
        console.log(this.contactoActual.codigoArea);
    }

    async recargarContactos() {
        try {
            const result = await obtenerContactos({ accountId: this.accountId });
            
            if (result && Array.isArray(result)) {
                this.contactos = result.map(c => ({
                    ...c,
                    ContactName: c.Contact__r?.Name,
                    Tipo_de_contacto__rName: c.Tipo_de_contacto__r?.Name
                }));

                const contactosPrimarios = this.contactos.filter(c => c.Es_primario__c);

                if (contactosPrimarios.length > 0) {
                    this.primerContacto = contactosPrimarios[0];
                    this.otrosContactos = this.contactos.filter(c => c.Id !== this.primerContacto.Id);
                } else {
                    this.primerContacto = this.contactos.length > 0 ? this.contactos[0] : null;
                    this.otrosContactos = this.contactos.slice(1);
                }
            } else {
                this.contactos = [];
                this.primerContacto = null;
                this.otrosContactos = [];
            }

            this.dispatchEvent(new CustomEvent('actualizar', {
                detail: { tipo: 'contacto', hayRegistros: this.contactos.length > 0 }
            }));

        } catch (error) {
            this.showToast('Error', error.body?.message || 'Error al cargar contactos', 'error');
            this.contactos = [];
            this.primerContacto = null;
            this.otrosContactos = [];
        }
    }

    async cargarTipos() {
        try {
            const result = await obtenerTiposContacto();
            this.tiposContacto = result.map(t => ({ label: t.Name, value: t.Id }));
        } catch (error) {
            this.showToast('Error', 'No se pudieron cargar tipos de contacto.', 'error');
        }
    }

    toggleDropdown() {
        this.mostrarDropdown = !this.mostrarDropdown;
    }

    handleAgregar() {
        this.contactoActual = {};
        this.contactoActual = {
            codigoArea: '+506',
            Es_primario__c: false
            // otros campos si se quieren precargados al inicio Jhon
        };
        this.isModalOpen = true;
    }

    handleNombreChange(e) {
        const field = e.target.name;
        let value = e.target.value;
        const cleaned = value.replace(/[^a-zA-ZáéíóúÁÉÍÓÚñÑ\s]/g, '');
        if (value !== cleaned) {
            e.target.value = cleaned;
        }

        this[field] = value;
        
        this.contactoActual = { ...this.contactoActual, nombre: e.target.value };
    }


    handleFinalizar() {
        this.isModalOpen = false;
        this.isSegundoPaso = false;
        this.recargarContactos();
    
        this.dispatchEvent(new CustomEvent('actualizar', {
            detail: { tipo: 'contacto', hayRegistros: true }
        }));
    }

    
    handleTipoChange(e) {
        this.contactoActual = { ...this.contactoActual, Tipo_de_contacto__c: e.detail.value };
    }

    handleCorreoChange(e) {
        this.contactoActual = { ...this.contactoActual, correo: e.target.value };
    }

    handleCodigoChange(e) {
        this.contactoActual = { ...this.contactoActual, codigoArea: e.detail.value };
        console.log(this.contactoActual);
    }

    handleTelefonoChange(e) {
        this.contactoActual = { ...this.contactoActual, telefono: e.target.value };
    }

    handleEsPrimarioChange(e) {
        this.contactoActual = { ...this.contactoActual, Es_primario__c: e.target.checked };
    }

    async guardar() {

        this.deshabilitarGuardar = true;

        const camposFaltantes = [];
    
        // Verifica campos requeridos
        if (!this.contactoActual.nombre) camposFaltantes.push('Nombre del Contacto');
        if (!this.contactoActual.Tipo_de_contacto__c) camposFaltantes.push('Tipo de Contacto');
        if (!this.contactoActual.correo) camposFaltantes.push('Correo');
        if (!this.contactoActual.Tipo_de_datos_de_comunicaci_n__c) camposFaltantes.push('Tipo de Comunicación Correo');
        if (!this.contactoActual.codigoArea) camposFaltantes.push('Código de Área');
        if (!this.contactoActual.telefono) camposFaltantes.push('Teléfono');
        if (!this.contactoActual.Tipo_de_datos_de_comunicaci_n_tel_fono__c) camposFaltantes.push('Tipo de Comunicación Teléfono');
        if (!this.contactoActual.Tipo_telefono__c) camposFaltantes.push('Clase');
    
        if (camposFaltantes.length > 0) {
            this.deshabilitarGuardar = false;
            this.showToast(
                'Campos obligatorios',
                `Completa los siguientes campos: ${camposFaltantes.join(', ')}`,
                'error'
            );
            return;
        }


       
        // if (!this.contactoActual.nombre || !this.contactoActual.Tipo_de_contacto__c) {
        //     this.deshabilitarGuardar = false;
        //     this.showToast('Error', 'Completa los campos obligatorios', 'error');
        //     return;
        // }else if(!this.contactoActual.correo){
        //     this.deshabilitarGuardar = false;
        //     this.showToast('Error', 'Debe llenar el campo de correo electrónico.', 'error');
        //     return;
        // }
    
        // Validación del correo
        if (this.contactoActual.correo) {
            const correo = this.contactoActual.correo.trim();
            const maxUsernameLength = 64;
            const correoRegex = new RegExp(
                "^(?![.])([a-zA-Z0-9._-]{1,64})(?<![.])@(?=.{1,255}$)(?!-)[A-Za-z0-9-]+(?<!-)\\.[A-Za-z]{2,63}$"
            );
            const partesCorreo = correo.split('@');
            const usuario = partesCorreo[0];
    
            if (correo.includes(' ')) {
                this.deshabilitarGuardar = false;
                this.showToast('Error', 'El correo no debe contener espacios.', 'error');
                return;
            }
    
            if (usuario.length > maxUsernameLength) {
                this.deshabilitarGuardar = false;
                this.showToast('Error', 'El nombre de usuario del correo no puede tener más de 64 caracteres.', 'error');
                return;
            }
    
            if (usuario.startsWith('.') || usuario.endsWith('.')) {
                this.deshabilitarGuardar = false;
                this.showToast('Error', 'El usuario del correo no puede iniciar ni terminar con punto.', 'error');
                return;
            }
    
            if (usuario.includes('..')) {
                this.deshabilitarGuardar = false;
                this.showToast('Error', 'El usuario del correo no puede tener puntos consecutivos.', 'error');
                return;
            }
    
            if (!correoRegex.test(correo)) {
                this.deshabilitarGuardar = false;
                this.showToast('Error', 'El formato del correo no es válido.', 'error');
                return;
            }
        }
        
        // Validación del teléfono
        if (this.contactoActual.telefono) {
            const numero = String(this.contactoActual.telefono);
            const soloNumeros = /^[0-9]+$/;
            const repetidos = /(\d)\1{4,}/;
    
            if (!soloNumeros.test(numero)) {
                this.deshabilitarGuardar = false;
                this.showToast('Error', 'El teléfono debe contener solo números.', 'error');
                return;
            }
    
            if (repetidos.test(numero)) {
                this.deshabilitarGuardar = false;
                this.showToast('Error', 'No puede contener más de 4 dígitos consecutivos iguales.', 'error');
                return;
            }
    
            if (this.contactoActual.codigoArea === '+506') {
                if (numero.length !== 8) {
                    this.deshabilitarGuardar = false;
                    this.showToast('Error', 'El número en Costa Rica debe tener 8 dígitos.', 'error');
                    return;
                }
                if (!/^[678]/.test(numero) && this.contactoActual.Tipo_telefono__c == 'Móvil' ) {
                    this.deshabilitarGuardar = false;
                    this.showToast('Error', 'El número en Costa Rica debe iniciar con 6, 7 u 8.', 'error');
                    return;
                }
                if (!/^[2]/.test(numero) && this.contactoActual.Tipo_telefono__c == 'Fijo' ) {
                    this.deshabilitarGuardar = false;
                    this.showToast('Error', 'El número fijo debe iniciar con 2.', 'error');
                    return;
                }
            }
        }
    
        if (this.contactoActual.codigoArea && !this.contactoActual.telefono) {
            this.deshabilitarGuardar = false;
            this.showToast('Error', 'Si selecciona un código de área debe ingresar un número de teléfono.', 'error');
            return;
        }
    
        try {
            const data = {
                nombreContacto: this.contactoActual.nombre,
                tipoContactoId: this.contactoActual.Tipo_de_contacto__c,
                correo: this.contactoActual.correo,
                codigoArea: this.contactoActual.codigoArea,
                telefono: this.contactoActual.telefono,
                esPrimario: this.contactoActual.Es_primario__c, // ✅ clave correcta para Apex
                accountId: this.accountId,
                contactoId: this.contactoActual.contactoId,     // ✅ para evitar crear nuevo contacto
                relacionId: this.contactoActual.relacionId,      // ✅ para evitar crear nueva relación

                tipoDatoCorreoId: this.contactoActual.Tipo_de_datos_de_comunicaci_n__c,
                tipoDatoTelefonoId: this.contactoActual.Tipo_de_datos_de_comunicaci_n_tel_fono__c,
                tipoTelefono: this.contactoActual.Tipo_telefono__c
            };
            const yaExiste = await verificarCorreoExistente({
                correo: this.contactoActual.correo,
                accountId: this.accountId,
                contactoId: this.contactoActual.contactoId
            });
            if (yaExiste) {
                this.showToast('Advertencia', 'Este correo ya está registrado en otra cuenta o contacto.', 'warning');
            
                // Esperar 3 segundos antes de continuar
                await new Promise(resolve => setTimeout(resolve, 1500));
            }
            
            const contactoId =  await guardarContactoPorCuenta({ data });
            this.showToast('Éxito', 'Contacto agregado', 'success');
            console.log(contactoId);
            console.log(this.accountId);
            console.log('Este es el tipoCliente');
            console.log(this.tipocliente);
            //this.isModalOpen = false;
            this.contactoActual.contactoId = contactoId;
            this.isSegundoPaso = true;
            this.dispatchEvent(new CustomEvent('actualizar', {
                detail: { tipo: 'contacto', hayRegistros: true }
            }));
    
            await this.recargarContactos();
        } catch (error) {
            let mensajeError = 'Ocurrió un error inesperado.';
            this.deshabilitarGuardar = true;
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
    }
    
    

    handleEliminar(event) {
        const id = event.currentTarget.dataset.id;
        this.eliminarContacto(id);
    }

    async eliminarContacto(id) {
        try {
            await eliminarContactoPorCuenta({ relacionId: id });

            this.showToast('Eliminado', 'Contacto eliminado', 'success');
            await this.recargarContactos();
        } catch (error) {
            this.showToast('Error', error.body?.message || 'Error al eliminar', 'error');
        }
    }

    cerrarModal() {
        this.isSegundoPaso = false;
        this.isModalOpen = false;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    handleEditar(event) {
        const id = event.currentTarget.dataset.id;
    
        // Buscar el contacto en la lista combinada (por si no está en primerContacto)
        const contacto = [...this.contactos, ...this.otrosContactos].find(c => c.Id === id);
    
        if (contacto) {
            this.contactoActual = {
                nombre: contacto.ContactName,
                Tipo_de_contacto__c: contacto.Tipo_de_contacto__c,
                correo: contacto.Correo__c,
                codigoArea: contacto.C_digo_de_rea__c,
                telefono: contacto.Tel_fono__c,
                Es_primario__c: contacto.Es_primario__c,
                Tipo_de_datos_de_comunicaci_n__c: contacto.Tipo_de_datos_de_comunicaci_n__c,
                Tipo_de_datos_de_comunicaci_n_tel_fono__c: contacto.Tipo_de_datos_de_comunicaci_n_tel_fono__c,
                Tipo_telefono__c: contacto.Tipo_tel_fono__c,
                contactoId: contacto.Contact__c,    // ✅ ID del Contact (para update)
                relacionId: contacto.Id             // ✅ ID del Contacto_por_cuenta__c (para update)
            };
            this.isModalOpen = true;
            this.isSegundoPaso = true;
        }
    }
    

    
}