import { LightningElement, api, wire } from "lwc";
import getWorkOrderData from "@salesforce/apex/ct_otRedis_ctrl.getPresupuesto";

export default class CT_Presupuestos_OT_lwc extends LightningElement {
  @api recordId;
  workOrders;

  // Call Apex method with the recordId to retrieve WorkOrder data
//   @wire(getWorkOrderData, { woId: "$recordId" })
//   wiredWorkOrders({ error, data }) {
//     if (data) {
//       console.log(data);
//       this.workOrders = data;
//     } else if (error) {
//       console.error("Error:", error);
//     }
//   }

  @wire(getWorkOrderData, { woId: "$recordId" })
  wiredWorkOrders({ error, data }) {
    if (data) {
      console.log(data);
      this.workOrders = data.map((wo) => ({
        ...wo,
        formattedGrandTotal: new Intl.NumberFormat("es-ES", {
          minimumFractionDigits: 2,
          maximumFractionDigits: 2,
        }).format(wo.GrandTotal),
      }));
    } else if (error) {
      console.error("Error:", error);
    }
  }

  // Method to open the WorkOrder record in a new tab
  openWorkOrderRecord(event) {
    const recordId = event.currentTarget.dataset.recordId;
    window.open(`/lightning/r/WorkOrder/${recordId}/view`, "_blank");
  }
}