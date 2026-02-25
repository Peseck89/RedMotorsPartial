import { LightningElement, api, track } from "lwc";
import obtenerDirecciones from "@salesforce/apex/DireccionController.obtenerDirecciones";
import guardarDireccion from "@salesforce/apex/DireccionController.guardarDireccion";
import eliminarDireccion from "@salesforce/apex/DireccionController.eliminarDireccion";
import obtenerProvincias from "@salesforce/apex/DireccionController.obtenerProvincias";
import obtenerCantones from "@salesforce/apex/DireccionController.obtenerCantones";
import obtenerDistritos from "@salesforce/apex/DireccionController.obtenerDistritos";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import obtenerCantonesPorProvincia from "@salesforce/apex/DireccionController.obtenerCantonesPorProvincia";
import obtenerDistritosPorCanton from "@salesforce/apex/DireccionController.obtenerDistritosPorCanton";

const COLUMNS = [
  { label: "Dirección", fieldName: "Direccion__c", type: "text" },
  { label: "Provincia", fieldName: "ProvinciaNombre", type: "text" },
  { label: "Cantón", fieldName: "CantonNombre", type: "text" },
  { label: "Distrito", fieldName: "DistritoNombre", type: "text" },
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

export default class Direccionesdecuenta extends LightningElement {
  @api accountId;
  @api tipocliente;

  @track direcciones = [];
  @track primerDireccion = null;
  @track otrasDirecciones = [];
  @track isModalOpen = false;
  @track direccionActual = {};
  @track isEditMode = false;
  @track provincias = [];
  @track cantones = [];
  @track distritos = [];
  @track hasRendered = false;
  @track mostrarDropdown = false;

  @track isJuridico = false

  columns = COLUMNS;

  connectedCallback() {
    this.cargarProvincias();


    console.log('Tipo Cliente desde direcciones: ', this.tipocliente);
        if(this.tipocliente == 'Cliente Jurídico' || this.tipocliente == 'Cuenta empresarial') {
            this.isJuridico = true
            console.log('Es juridico? ', this.isJuridico);
        }
  }

  renderedCallback() {
    if (this.hasRendered) return;
    this.hasRendered = true;
    this.recargarDirecciones();
  }

  async cargarProvincias() {
    try {
      const result = await obtenerProvincias();
      this.provincias = result.map((p) => ({ label: p.Name, value: p.Id }));
    } catch (error) {
      this.showToast("Error", "No se pudieron cargar las provincias.", "error");
    }
  }

  async cargarCantones() {
    try {
      const result = await obtenerCantones();
      this.cantones = result.map((c) => ({ label: c.Name, value: c.Id }));
    } catch (error) {
      this.showToast("Error", "No se pudieron cargar los cantones.", "error");
    }
  }

  async cargarDistritos() {
    try {
      const result = await obtenerDistritos();
      this.distritos = result.map((d) => ({ label: d.Name, value: d.Id }));
    } catch (error) {
      this.showToast("Error", "No se pudieron cargar los distritos.", "error");
    }
  }

  handleAgregar() {
    this.direccionActual = {};
    this.isEditMode = false;
    this.isModalOpen = true;
  }

  handleRowAction(event) {
    const action = event.detail.action.name;
    const row = event.detail.row;

    if (action === "editar") {
      this.direccionActual = {
        ...row,
        Provincia__c: row.ProvinciaId,
        Canton__c: row.CantonId,
        Distrito__c: row.DistritoId,
      };
      this.isEditMode = true;
      this.isModalOpen = true;
    } else if (action === "eliminar") {
      this.eliminarDireccion(row.Id);
    }
  }

  async guardarDireccion() {
    const d = this.direccionActual;
    if (!d.Direccion__c || d.Direccion__c.trim() === "") {
      this.showToast("Error", "La dirección no puede estar vacía.", "error");
      return;
    }
    if (!d.Provincia__c || !d.Canton__c || !d.Distrito__c) {
      this.showToast(
        "Error",
        "Provincia, Cantón y Distrito son obligatorios.",
        "error"
      );
      return;
    }

    d.Cuenta__c = this.accountId;

    try {
      await guardarDireccion({ direccion: d });
      this.showToast("Éxito", "Dirección guardada correctamente", "success");
      this.isModalOpen = false;
      await this.recargarDirecciones();
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
      //this.showToast("Error al guardar", error.body?.message, "error");
    }
  }

  async eliminarDireccion(id) {
    try {
      await eliminarDireccion({ direccionId: id });
      this.showToast("Eliminado", "Dirección eliminada", "success");
      await this.recargarDirecciones();
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

      //this.showToast("Error al eliminar", error.body?.message, "error");
    }
  }

  // async recargarDirecciones() {

  //     const result = await obtenerDirecciones({ accountId: this.accountId });
  //     this.direcciones = result.map(dir => ({
  //         ...dir,
  //         ProvinciaNombre: dir.Provincia__r?.Name || '',
  //         ProvinciaId: dir.Provincia__c,
  //         CantonNombre: dir.Canton__r?.Name || '',
  //         CantonId: dir.Canton__c,
  //         DistritoNombre: dir.Distrito__r?.Name || '',
  //         DistritoId: dir.Distrito__c
  //     }));

  //     this.dispatchEvent(new CustomEvent('actualizar', { detail: { tipo: 'direccion', hayRegistros: this.direcciones.length > 0 } }));

  // }

  async recargarDirecciones() {
    try {
        const result = await obtenerDirecciones({ accountId: this.accountId });

        if (result && Array.isArray(result)) {
            this.direcciones = result.map((dir) => ({
                ...dir,
                ProvinciaNombre: dir.Provincia__r?.Name || "",
                ProvinciaId: dir.Provincia__c,
                CantonNombre: dir.Canton__r?.Name || "",
                CantonId: dir.Canton__c,
                DistritoNombre: dir.Distrito__r?.Name || "",
                DistritoId: dir.Distrito__c
            }));

            // Filtrar direcciones principales
            const direccionesPrincipales = this.direcciones.filter(d => d.Direccion_principal__c);
            
            if (direccionesPrincipales.length > 0) {
                this.primerDireccion = direccionesPrincipales[0];
                this.otrasDirecciones = this.direcciones.filter(d => d.Id !== this.primerDireccion.Id);
            } else {
                this.primerDireccion = this.direcciones.length > 0 ? this.direcciones[0] : null;
                this.otrasDirecciones = this.direcciones.slice(1);
            }
        } else {
            this.direcciones = [];
            this.primerDireccion = null;
            this.otrasDirecciones = [];
        }

        this.dispatchEvent(new CustomEvent("actualizar", {
            detail: { tipo: "direccion", hayRegistros: this.direcciones.length > 0 }
        }));
    } catch (error) {
        this.showToast("Error", error.body?.message || "Error al cargar direcciones", "error");
        this.direcciones = [];
        this.primerDireccion = null;
        this.otrasDirecciones = [];
    }
}

  toggleDropdown() {
    this.mostrarDropdown = !this.mostrarDropdown;
  }

  handleEditar(event) {
    const id = event.currentTarget.dataset.id;
    this.direccionActual = this.direcciones.find((d) => d.Id === id);
    this.isEditMode = true;
    this.isModalOpen = true;
  }

  handleEliminar(event) {
    const id = event.currentTarget.dataset.id;
    this.eliminarDireccion(id);
  }

  handleInputChange(event) {
    this.direccionActual = {
      ...this.direccionActual,
      Direccion__c: event.target.value,
    };
  }

  async handleProvinciaChange(event) {
      const provinciaId = event.detail.value;
      this.direccionActual = {
          ...this.direccionActual,
          Provincia__c: provinciaId,
          Canton__c: null,
          Distrito__c: null
      };
      this.cantones = [];
      this.distritos = [];

      try {
          const result = await obtenerCantonesPorProvincia({ provinciaId });
          this.cantones = result.map(c => ({ label: c.Name, value: c.Id }));
      } catch (error) {
          this.showToast('Error', 'No se pudieron cargar los cantones.', 'error');
      }
  }

  async handleCantonChange(event) {
      const cantonId = event.detail.value;
      this.direccionActual = {
          ...this.direccionActual,
          Canton__c: cantonId,
          Distrito__c: null
      };
      this.distritos = [];

      try {
          const result = await obtenerDistritosPorCanton({ cantonId });
          this.distritos = result.map(d => ({ label: d.Name, value: d.Id }));
      } catch (error) {
          this.showToast('Error', 'No se pudieron cargar los distritos.', 'error');
      }
  }

  handleDistritoChange(event) {
    this.direccionActual = {
      ...this.direccionActual,
      Distrito__c: event.detail.value,
    };
  }

  cerrarModal() {
    this.isModalOpen = false;
  }

  get modalTitle() {
    return this.isEditMode ? "Editar Dirección" : "Agregar Dirección";
  }

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }
  
  handleDireccionPrincipalChange(event) {
    this.direccionActual = {
      ...this.direccionActual,
      Direccion_principal__c: event.target.checked,
    };
  }



}