import { LightningElement, api, track } from "lwc";
import obtenerTelefonos from "@salesforce/apex/TelefonoController.obtenerTelefonos";
import guardarTelefono from "@salesforce/apex/TelefonoController.guardarTelefono";
import eliminarTelefono from "@salesforce/apex/TelefonoController.eliminarTelefono";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import obtenerTiposDatosComunicacion from "@salesforce/apex/TelefonoController.obtenerTiposDatosComunicacion";

const COLUMNS = [
  { label: "Número", fieldName: "N_mero_de_tel_fono__c", type: "text" },
  { label: "Código de área", fieldName: "C_digo_de_rea__c", type: "text" },
  { label: "Clase", fieldName: "Tipo_telefono__c", type: "text" },
  {
    label: "Tipo",
    fieldName: "Tipo_de_datos_de_comunicaci_n__rName",
    type: "text",
  },
  {
    label: "Teléfono principal",
    fieldName: "Telefono_principal__c",
    type: "boolean",
  },
  {
    type: "action",
    typeAttributes: {
      rowActions: [
        { label: "Editar", name: "editar" },
        { label: "Eliminar", name: "eliminar" },
      ],
    },
  },
];

export default class Telefonoscuenta extends LightningElement {
  @api accountId;
  @api tipocliente;

  @track telefonos = [];
  @track telefonoActual = {};
  @track primerTelefono = null;
  @track otrosTelefonos = [];
  @track isModalOpen = false;
  @track isEditMode = false;
  @track hasRendered = false;
  @track tiposDatosComunicacion = [];
  @track mostrarDropdown = false;
  @track isJuridico = false;

  columns = COLUMNS;

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

  tiposTelefono = [
    { label: "Fijo", value: "Fijo" },
    { label: "Móvil", value: "Móvil" },
  ];

  connectedCallback() {
    this.cargarTiposDatosComunicacion();
    if (this.tipocliente === "Cliente Jurídico" || this.tipocliente == 'Cuenta empresarial') {
      this.isJuridico = true;
    }
   
    this.telefonoActual = {
      C_digo_de_rea__c: '+506'
      // otros campos si se quieren precargados al inicio Jhon
    };
    console.log('Telefono iNical');
    console.log(this.telefonoActual);
    console.log('Telefono id');
    console.log(this.accountId);
  }

  renderedCallback() {
    if (this.hasRendered) return;
    this.hasRendered = true;
    this.recargarTelefonos();
  }

  async cargarTiposDatosComunicacion() {
    try {
      const result = await obtenerTiposDatosComunicacion({ accountId: this.accountId });
      this.tiposDatosComunicacion = result.map((item) => ({
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

  // async recargarTelefonos() {
  //   try {
  //     const result = await obtenerTelefonos({ accountId: this.accountId });

  //     if (result && Array.isArray(result)) {
  //       this.telefonos = result.map(t => ({
  //         ...t,
  //         Tipo_de_datos_de_comunicaci_n__rName: t.Tipo_de_datos_de_comunicaci_n__r?.Name || ''
  //       }));

  //       this.primerTelefono = this.telefonos.length > 0 ? this.telefonos[0] : null;
  //       this.otrosTelefonos = this.telefonos.slice(1);
  //     } else {
  //       this.telefonos = [];
  //       this.primerTelefono = null;
  //       this.otrosTelefonos = [];
  //     }

  //     this.dispatchEvent(
  //       new CustomEvent("actualizar", {
  //         detail: { tipo: "telefono", hayRegistros: this.telefonos.length > 0 },
  //       })
  //     );
  //   } catch (error) {
  //     this.showToast(
  //       "Error",
  //       error.body?.message || "Error al cargar teléfonos",
  //       "error"
  //     );
  //     this.telefonos = [];
  //     this.primerTelefono = null;
  //     this.otrosTelefonos = [];
  //   }
  // }

  async recargarTelefonos() {
    try {
      const result = await obtenerTelefonos({ accountId: this.accountId });

      if (result && Array.isArray(result)) {
        this.telefonos = result.map((t) => ({
          ...t,
          Tipo_de_datos_de_comunicaci_n__rName:
            t.Tipo_de_datos_de_comunicaci_n__r?.Name || "",
        }));

        // Filtrar teléfonos principales
        const telefonosPrincipales = this.telefonos.filter(
          (t) => t.Telefono_principal__c
        );

        if (telefonosPrincipales.length > 0) {
          this.primerTelefono = telefonosPrincipales[0];
          this.otrosTelefonos = this.telefonos.filter(
            (t) => t.Id !== this.primerTelefono.Id
          );
        } else {
          this.primerTelefono =
            this.telefonos.length > 0 ? this.telefonos[0] : null;
          this.otrosTelefonos = this.telefonos.slice(1);
        }
      } else {
        this.telefonos = [];
        this.primerTelefono = null;
        this.otrosTelefonos = [];
      }

      this.dispatchEvent(
        new CustomEvent("actualizar", {
          detail: { tipo: "telefono", hayRegistros: this.telefonos.length > 0 },
        })
      );
    } catch (error) {
      this.showToast(
        "Error",
        error.body?.message || "Error al cargar teléfonos",
        "error"
      );
      this.telefonos = [];
      this.primerTelefono = null;
      this.otrosTelefonos = [];
    }
  }

  toggleDropdown() {
    this.mostrarDropdown = !this.mostrarDropdown;
  }

  handleEditar(event) {
    const id = event.currentTarget.dataset.id;
    this.telefonoActual = this.telefonos.find((t) => t.Id === id);
    this.isEditMode = true;
    this.isModalOpen = true;
  }

  handleEliminar(event) {
    const id = event.currentTarget.dataset.id;
    this.eliminarTelefono(id);
  }

  handleAgregar() {
    this.telefonoActual = {};
    this.telefonoActual = {
      C_digo_de_rea__c: '+506'
    };
    this.isEditMode = false;
    this.isModalOpen = true;
  }

  handleRowAction(event) {
    const action = event.detail.action.name;
    const row = event.detail.row;

    if (action === "editar") {
      this.telefonoActual = { ...row };
      this.isEditMode = true;
      this.isModalOpen = true;
    } else if (action === "eliminar") {
      this.eliminarTelefono(row.Id);
    }
  }

  validarTelefono() {
    const t = this.telefonoActual;

    if (!t.Tipo_telefono__c) {
      this.showToast("Error", "Seleccione un tipo de teléfono.", "error");
      return false;
    }

    if (!t.C_digo_de_rea__c) {
      this.showToast("Error", "Seleccione un código de área.", "error");
      return false;
    }

    if (!t.N_mero_de_tel_fono__c) {
      this.showToast("Error", "El número de teléfono es obligatorio.", "error");
      return false;
    }

    const numero = String(t.N_mero_de_tel_fono__c);
    const soloNumeros = /^[0-9]+$/;
    const repetidos = /(\d)\1{4,}/;

    if (!soloNumeros.test(numero)) {
      this.showToast("Error", "El número debe contener solo dígitos.", "error");
      return false;
    }

    if (repetidos.test(numero)) {
      this.showToast(
        "Error",
        "No puede contener más de 4 dígitos consecutivos iguales.",
        "error"
      );
      return false;
    }
    console.log('TIPO DE TELEFONO');
    console.log(t.Tipo_telefono__c);
    if (t.Tipo_telefono__c === "Móvil") {
      if (t.C_digo_de_rea__c === "+506") {
        if (numero.length !== 8) {
          this.showToast(
            "Error",
            "El número móvil en Costa Rica debe tener 8 dígitos.",
            "error"
          );
          return false;
        }
        if (!/^[678]/.test(numero)) {
          this.showToast(
            "Error",
            "El número móvil en Costa Rica debe iniciar con 6, 7 u 8.",
            "error"
          );
          return false;
        }
      }
    }

    if (t.Tipo_telefono__c === "Fijo") {
      if (numero.length !== 8) {
        this.showToast(
          "Error",
          "El número fijo debe tener 8 dígitos.",
          "error"
        );
        return false;
      }
      if (!/^2/.test(numero)) {
        this.showToast("Error", "El número fijo debe iniciar con 2.", "error");
        return false;
      }
    }

    return true;
  }

  async guardarTelefono() {
    if (!this.validarTelefono()) return;

    this.telefonoActual.Cuenta__c = this.accountId;

    try {
      await guardarTelefono({ telefono: this.telefonoActual });
      this.showToast("Éxito", "Teléfono guardado correctamente", "success");
      this.isModalOpen = false;
      await this.recargarTelefonos();
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
      //this.showToast("Error al guardar", e.body?.message || e.message, "error");
    }
  }

  async eliminarTelefono(id) {
    try {
      await eliminarTelefono({ telefonoId: id });
      this.showToast("Eliminado", "Teléfono eliminado", "success");
      await this.recargarTelefonos();
    } catch (e) {
      this.showToast(
        "Error al eliminar",
        e.body?.message || e.message,
        "error"
      );
    }
  }

  handleNumeroChange(event) {
    this.telefonoActual = {
      ...this.telefonoActual,
      N_mero_de_tel_fono__c: event.target.value,
    };
  }

  handleCodigoChange(event) {
    this.telefonoActual = {
      ...this.telefonoActual,
      C_digo_de_rea__c: event.detail.value,
    };

    console.log(this.telefonoActual);
  }

  handleTipoChange(event) {
    this.telefonoActual = {
      ...this.telefonoActual,
      Tipo_telefono__c: event.detail.value,
    };
  }

  handleTelefonoPrincipalChange(event) {
    this.telefonoActual = {
      ...this.telefonoActual,
      Telefono_principal__c: event.target.checked,
    };
  }

  cerrarModal() {
    this.isModalOpen = false;
  }

  get modalTitle() {
    return this.isEditMode ? "Editar Teléfono" : "Agregar Teléfono";
  }

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }

  handleTipoDatoChange(event) {
    this.telefonoActual = {
      ...this.telefonoActual,
      Tipo_de_datos_de_comunicaci_n__c: event.detail.value,
    };
  }
}