// CT_quoteServiceBudget_lwc
import { LightningElement, api, wire, track } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getTareasAgrupadas from "@salesforce/apex/QuoteServiceController.getTareasAgrupadas";
import getItemsPorTarea from "@salesforce/apex/QuoteServiceController.getItemsPorTarea";
import updateItemsPorTarea from "@salesforce/apex/QuoteServiceController.updateItemsPorTarea";

const QUOTE_CURRENCY_FIELD = "Quote.CurrencyIsoCode";

export default class CT_quoteServiceBudget_lwc extends LightningElement {
  @api recordId;

  @track tareasAgrupadas = [];
  @track selectedTareaIds = [];
  @track todosItems = [];
  @track itemsAgrupadosPorTarea = [];
  @track isLoading = false;
  @track isSending = false;
  @track showStep1 = true;
  @track showStep2 = false;
  @track currencyIsoCode = "USD";

  get hasTareas() {
    return this.tareasAgrupadas.length > 0;
  }

  get showNoTareasMessage() {
    return !this.hasTareas && !this.isLoading;
  }

  get isNextButtonDisabled() {
    return this.selectedTareaIds.length === 0 || this.isLoading;
  }

  get selectedTareasCount() {
    return this.selectedTareaIds.length;
  }

  get totalItemsSeleccionados() {
    return this.todosItems.length;
  }

  get totalMontoSeleccionado() {
    return this.todosItems.reduce(
      (total, item) => total + (item.TotalPrice || 0),
      0
    );
  }

  get totalMontoFormatted() {
    return this.formatCurrency(this.totalMontoSeleccionado);
  }

  @wire(getRecord, { recordId: "$recordId", fields: [QUOTE_CURRENCY_FIELD] })
  wiredQuote({ error, data }) {
    if (data) {
      this.currencyIsoCode = data.fields.CurrencyIsoCode.value;
      this.loadTareasAgrupadas();
    } else if (error) {
      console.error("Error loading quote:", error);
      this.showToast(
        "Error",
        "Error al cargar información de la cotización",
        "error"
      );
    }
  }

  getPrioridadDisplayText(prioridad) {
    const prioridadMap = {
      Necesario: "Urgente",
      Recomendado: "Sugerido",
      Sugerido: "Próximo",
      Normal: "Normal",
    };
    return prioridadMap[prioridad] || prioridad;
  }

  async loadTareasAgrupadas() {
    if (!this.recordId) return;

    this.isLoading = true;
    try {
      const result = await getTareasAgrupadas({ quoteId: this.recordId });
      console.log(
        "Tareas agrupadas con estado de envío:",
        JSON.parse(JSON.stringify(result))
      );

      if (result && result.length > 0) {
        this.tareasAgrupadas = result.map((tarea) => {
          const uniqueId = tarea.trabajoARealizarId
            ? `Trabajo_${tarea.trabajoARealizarId}`
            : `Tarea_${tarea.tareaId}`;

          const prioridadClass = this.getPrioridadClass(tarea.prioridad);

          const prioridadDisplay = this.getPrioridadDisplayText(
            tarea.prioridad
          );

          // Determinar clase CSS basada en el estado de envío
          const rowClass = tarea.yaEnviada
            ? "slds-text-color_weak slds-is-disabled"
            : "";
          const statusText = tarea.yaEnviada
            ? "Enviado a Service"
            : tarea.itemsEnviados > 0
            ? `Parcial (${tarea.itemsEnviados}/${tarea.cantidadItems})`
            : "Pendiente";

          return {
            ...tarea,
            id: uniqueId,
            currencyIsoCode: this.currencyIsoCode,
            prioridadClass: prioridadClass,
            prioridadDisplay: prioridadDisplay,
            totalTareaFormatted: this.formatCurrency(tarea.totalTarea),
            isSelected:
              this.selectedTareaIds.includes(uniqueId) && !tarea.yaEnviada,
            yaEnviada: tarea.yaEnviada,
            statusText: statusText,
            rowClass: rowClass,
            // Para mostrar tooltip con detalles de envío
            statusTooltip: tarea.yaEnviada
              ? "Todos los items de esta tarea ya fueron enviados a BMW Service"
              : tarea.itemsEnviados > 0
              ? `${tarea.itemsEnviados} de ${tarea.cantidadItems} items enviados`
              : "Ningún item enviado aún",
          };
        });
      } else {
        this.tareasAgrupadas = [];
      }
    } catch (error) {
      console.error("Error loading grouped tasks:", error);
      this.showToast("Error", "Error al cargar las tareas agrupadas", "error");
    } finally {
      this.isLoading = false;
    }
  }

  getPrioridadClass(prioridad) {
    const prioridadClasses = {
      Necesario: "slds-text-color_error",
      Recomendado: "slds-text-color_success",
      Sugerido: "--slds-g-color-warning-base-70 warning-text",
      Normal: "slds-text-color_default",
    };
    return prioridadClasses[prioridad] || "slds-text-color_default";
  }

  handleCheckboxChange(event) {
    const tareaId = event.target.dataset.id;
    const isChecked = event.target.checked;

    // Encontrar la tarea para verificar si ya fue enviada
    const tarea = this.tareasAgrupadas.find((t) => t.id === tareaId);

    // No permitir seleccionar tareas ya enviadas
    // if (tarea && tarea.yaEnviada) {
    //   event.preventDefault();
    //   return;
    // }

    if (isChecked) {
      if (!this.selectedTareaIds.includes(tareaId)) {
        this.selectedTareaIds = [...this.selectedTareaIds, tareaId];
      }
    } else {
      this.selectedTareaIds = this.selectedTareaIds.filter(
        (id) => id !== tareaId
      );
    }

    this.tareasAgrupadas = this.tareasAgrupadas.map((tarea) => ({
      ...tarea,
      isSelected: this.selectedTareaIds.includes(tarea.id) && !tarea.yaEnviada,
    }));
  }

  // quoteServiceBudget.js - Solo mostrar la parte del handleNext
  async handleNext() {
    console.log("=== NEXT BUTTON CLICKED ===");
    console.log("Selected tarea IDs:", this.selectedTareaIds);

    if (this.selectedTareaIds.length === 0) {
      this.showToast("Info", "Por favor selecciona al menos una tarea", "info");
      return;
    }

    this.isLoading = true;
    try {
      this.todosItems = [];
      this.itemsAgrupadosPorTarea = [];

      const tareasSeleccionadas = this.tareasAgrupadas.filter((tarea) =>
        this.selectedTareaIds.includes(tarea.id)
      );

      console.log(
        "Tareas seleccionadas para cargar items:",
        tareasSeleccionadas
      );

      for (const tarea of tareasSeleccionadas) {
        console.log("Cargando items para tarea:", tarea.tareaName);
        console.log("tareaId a buscar:", tarea.tareaId);

        const items = await getItemsPorTarea({
          quoteId: this.recordId,
          trabajoARealizarId: tarea.trabajoARealizarId,
          tareaId: tarea.tareaId, // Este es el campo importante - Tarea__c
        });

        console.log(`Items obtenidos para tarea ${tarea.tareaName}:`, items);
        console.log(`Cantidad de items: ${items ? items.length : 0}`);

        // **VERIFICACIÓN CRÍTICA**: ¿Coincide el número de items con lo esperado?
        if (items && items.length > 0) {
          if (items.length !== tarea.cantidadItems) {
            console.warn(
              `DISCREPANCIA: Tarea ${tarea.tareaName} esperaba ${tarea.cantidadItems} items pero se encontraron ${items.length}`
            );
          }

          const itemsProcesados = items.map((item) => ({
            ...item,
            productName: item.Product2?.Name || "Sin producto",
            description: item.Description || "",
            tipo: item.BMW_TipoDeArticulo__c || "Otros",
            unitPriceFormatted: this.formatCurrency(item.UnitPrice),
            totalPriceFormatted: this.formatCurrency(item.TotalPrice),
          }));

          this.todosItems = [...this.todosItems, ...itemsProcesados];

          this.itemsAgrupadosPorTarea.push({
            tarea: tarea,
            items: itemsProcesados,
            totalTarea: tarea.totalTarea,
            totalTareaFormatted: this.formatCurrency(tarea.totalTarea),
            cantidadItems: items.length,
            cantidadItemsEsperados: tarea.cantidadItems, // Para debug
          });
        } else {
          console.log(
            `No se encontraron items para la tarea: ${tarea.tareaName}`
          );
        }
      }

      console.log("Todos los items cargados:", this.todosItems);
      console.log("Items agrupados por tarea:", this.itemsAgrupadosPorTarea);

      this.showStep1 = false;
      this.showStep2 = true;
    } catch (error) {
      console.error("Error loading task details:", error);
      this.showToast(
        "Error",
        "Error al cargar detalles de las tareas",
        "error"
      );
    } finally {
      this.isLoading = false;
    }
  }

  handleBack() {
    this.showStep1 = true;
    this.showStep2 = false;
    this.todosItems = [];
    this.itemsAgrupadosPorTarea = [];
  }

  formatCurrency(amount) {
    if (amount === null || amount === undefined) return "$0.00";
    return new Intl.NumberFormat("es-US", {
      style: "currency",
      currency: this.currencyIsoCode,
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    }).format(amount);
  }

  async handleSendToService() {
    this.isSending = true;
    try {
      await updateItemsPorTarea({
        quoteId: this.recordId,
        tareaIds: this.selectedTareaIds,
        sendToService: true,
      });

      this.showToast(
        "Éxito",
        "Tareas enviadas a BMW Service correctamente",
        "success"
      );

      // Resetear y recargar
      this.showStep1 = true;
      this.showStep2 = false;
      this.selectedTareaIds = [];
      this.todosItems = [];
      this.itemsAgrupadosPorTarea = [];

      // Recargar tareas para actualizar estados
      this.loadTareasAgrupadas();
    } catch (error) {
      console.error("Error sending to service:", error);
      this.showToast("Error", "Error al enviar tareas a service", "error");
    } finally {
      this.isSending = false;
    }
  }

  showToast(title, message, variant) {
    this.dispatchEvent(
      new ShowToastEvent({
        title,
        message,
        variant,
      })
    );
  }
}