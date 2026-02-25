import { LightningElement, track, wire, api } from "lwc";
import getTrabajos from "@salesforce/apex/ct_casoredi_ctrl.getTrabajos";
import getCaso from "@salesforce/apex/ct_casoredi_ctrl.getCaseData";
import getWO from "@salesforce/apex/ct_casoredi_ctrl.getWO";
import getWorkOrdersByCaseId from "@salesforce/apex/ct_casoredi_ctrl.getWorkOrdersByCaseId";
import getPresupuesto from "@salesforce/apex/ct_otRedis_ctrl.getPresupuesto";

import { NavigationMixin } from "lightning/navigation";

export default class CT_PuntosDeTrabajo_CS_lwc extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @track objetoHistorial = [];
  @track objetoHistorialWithUrl = [];
  @track quotes = [];
  @track workOrders = [];

  @wire(getWorkOrdersByCaseId, { caseId: "$recordId" })
  getWorkOrders({ error, data }) {
    if (data) {
      this.workOrders = data.map((wo) => {
        return {
          ...wo,
          formattedTotalFinal: wo.totalFinal__c
            ? wo.totalFinal__c.toLocaleString("es-US", {
                minimumFractionDigits: 0,
                maximumFractionDigits: 2,
              })
            : "0.00",
        };
      });
      console.log("Work Orders:", this.workOrders);
      if (this.workOrders.length > 0) {
        this.loadPresupuesto();
      }
    } else if (error) {
      console.error("Error retrieving Work Orders:", error);
    }
  }

  loadPresupuesto() {
    const woId = this.workOrders[0].Id;
    console.log("Llamando a getPresupuesto con woId:", woId);
    getPresupuesto({ woId: woId })
      .then((result) => {
        console.log("Presupuestos recibidos:", result);
        this.quotes = result.map((q) => ({
          ...q,
          formattedGrandTotal: new Intl.NumberFormat("es-ES", {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2,
          }).format(q.GrandTotal),
        }));
      })
      .catch((error) => {
        console.error("Error al obtener presupuesto:", error);
      });
  }

  openQuoteRecord(event) {
    event.preventDefault();
    const quoteId = event.currentTarget.dataset.recordId;
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: quoteId,
        objectApiName: "Quote", // Asegúrate de que sea el API name correcto para Quote
        actionName: "view",
      },
    });
  }

  openWorkOrderRecord(event) {
    event.preventDefault();
    const recordId = event.currentTarget.dataset.recordId;
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: recordId,
        objectApiName: "WorkOrder",
        actionName: "view",
      },
    });
  }

  @wire(getTrabajos, { recordId: "$recordId" })
  getTrabajosData({ error, data }) {
    if (data) {
      console.log("===========DATA Trabajos===========");
      console.log(data);
      this.objetoHistorial = data.map((trabajo) => ({
        ...trabajo,
        trabajoUrl: `/lightning/r/${trabajo.Id}/view`,
        cantidadHorasMultiplicadas: trabajo.Total_de_horas__c * 12,
      }));
    } else if (error) {
      console.error("Error en getTrabajosData", error);
    }
  }

  openRecord(event) {
    event.preventDefault();
    const recordId = event.currentTarget.dataset.recordId;
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: recordId,
        objectApiName: "Tipo_de_trabajo_del_caso__c",
        actionName: "view",
      },
    });
  }

  openRecordOt(event) {
    event.preventDefault();
    const recordId = event.currentTarget.dataset.recordId;
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: recordId,
        objectApiName: "WorkOrder",
        actionName: "view",
      },
    });
  }

  @track objetoWo = [];

  @wire(getWO, { recordId: "$recordId" })
  getWorkOrderData({ error, data }) {
    if (data) {
      console.log("===========DATA WO===========");
      console.log(data);
      this.objetoWo = data;
    } else if (error) {
      console.error("Error en getWorkOrderData", error);
    }
  }

  @track mecAsig;
  @track nombreCuenta;

  @wire(getCaso, { recordId: "$recordId" })
  getCaseData({ error, data }) {
    console.log("getCaseData");
    if (data) {
      console.log("===========DATA Caso===========");
      console.log(data);
      if (data[0].Mecanico_Asignado__c) {
        this.mecAsig = data[0].Mecanico_Asignado__r.Name;
      }
      this.accountId = data[0].AccountId;
    } else if (error) {
      console.error("Error en getCaseData", error);
    }
  }
}