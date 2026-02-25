import { LightningElement, track } from "lwc";
import validarGarantia from "@salesforce/apex/AssetGarantiaController.validarGarantia";
import { NavigationMixin } from "lightning/navigation";

export default class AssetGarantiaLookup_lwc extends NavigationMixin(
  LightningElement
) {
  @track assetSeleccionado;
  @track mostrarModal = false;
  @track resultado = {
    aplicaGarantia: false,
    mensaje: "",
  };

  // 1. Manejar selección del lookup
  handleSeleccion(event) {
    // El evento valueselected devuelve el detalle con id
    if (event.detail && event.detail.id) {
      this.assetSeleccionado = event.detail.id;
    } else {
      this.assetSeleccionado = null;
    }
  }

  // 2. Validar garantía con Apex
  async validarGarantia() {
    this.isLoading = true; // Mostrar spinner de carga
    try {
      // Validar que tenemos un ID seleccionado
      if (!this.assetSeleccionado) {
        this.resultado = {
          aplicaGarantia: false,
          mensaje: "Seleccione un vehículo primero",
        };
        this.mostrarModal = true;
        this.isLoading = false;
        return;
      }

      this.resultado = await validarGarantia({
        assetId: this.assetSeleccionado,
      });
      this.mostrarModal = true;
      this.isLoading = false;
    } catch (error) {
      console.error("Error validando garantía:", error);
      this.resultado = {
        aplicaGarantia: false,
        mensaje: "Error al validar garantía: " + error.body.message,
      };
      this.mostrarModal = true;
      this.isLoading = false;
    }
  }

  // 3. Cerrar modal
  cerrarModal() {
    this.mostrarModal = false;
  }

  // 4. Redirigir a creación de cita
  agendarCita() {
    // Agregar parámetro para pre-seleccionar el Asset
    this[NavigationMixin.Navigate]({
      type: "standard__objectPage",
      attributes: {
        objectApiName: "Event",
        actionName: "new",
      },
      state: {
        defaultFieldValues: "WhatId=" + this.assetSeleccionado,
        nooverride: "1",
      },
    });
  }
}