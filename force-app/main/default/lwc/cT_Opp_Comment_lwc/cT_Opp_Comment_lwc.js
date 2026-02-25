import { LightningElement, track, wire, api } from "lwc";
import getDatos from "@salesforce/apex/ct_CustomAsset.getCuentaInfo";
import getOportunidad from "@salesforce/apex/ct_CustomAsset.getUltimoComentario";
import getOpp from "@salesforce/apex/ct_CustomAsset.getOpp";
import updateComentario from "@salesforce/apex/ct_CustomAsset.updateComentario";
import NumPlaca from "@salesforce/resourceUrl/NumPlaca";

import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class CT_Opp_Comment_lwc extends LightningElement {
  numPlaca = NumPlaca;

  @api recordId;
  @track placa;
  @track numeroDeChasis;
  @track comentario = "";
  @track comentarioNegocio = "";
  @track oppId = "";
  @track oppUrl;
  @track consecutivoOpp;
  @track oppRel = "";
  @track tieneRel = false;

  @track showEditZone = false;

  @wire(getDatos, { recordId: "$recordId" })
  getAccountSetting({ error, data }) {
    if (data) {
      this.placa = data[0].Name;
      this.numeroDeChasis = data[0].NumeroDeChasis__c;
      this.oppRel = data[0].Oportunidad_relacionada__c;

      console.log("Oportunidad: ", this.oppRel);
    } else if (error) {
      console.log(error);
    }
  }

  @wire(getOpp, { opportunityId: "$oppRel" })
  getOpp({ error, data }) {
    if (data) {
      this.tieneRel = true;
      this.oppId = data[0].Id;
      this.comentario = data[0].Observaciones_cliente__c;
      this.comentarioNegocio = data[0].Observaciones_negocio__c;
      this.consecutivoOpp = data[0].ConsecutivoOportunidad__c;
      this.oppUrl = `/lightning/r/Opportunity/${data[0].Id}/view`;

      console.log("Log desde Opp consulta: ", data[0]);
      console.log("Log desde Opp consulta dos: ", data);
    } else if (data && data.length <= 0) {
      this.tieneRel = false;
      console.log("Este vehiculo no tiene una oportunidad relacionada");
      this.loadSecondWire();
    } else if (error) {
      this.tieneRel = false;
      console.log("Error desde Opp: ", error);
    }
  }

  async loadSecondWire() {
    try {
      const data = await getOportunidad({ recordId: this.recordId });
      if (data && data.length > 0) {
        this.tieneRel = true;
        this.oppId = data[0].Id;
        this.comentario = data[0].Observaciones_cliente__c;
        this.comentarioNegocio = data[0].Observaciones_negocio__c;
        this.consecutivoOpp = data[0].ConsecutivoOportunidad__c;
        this.oppUrl = `/lightning/r/Opportunity/${data[0].Id}/view`;

        console.log("Log desde Opp consulta (por recordId): ", data[0]);
        console.log("Log desde Opp consulta dos (por recordId): ", data);
      } else if (!data) {
        this.tieneRel = false;
        console.log("Este vehiculo no tiene una oportunidad relacionada");
      } else {
        this.tieneRel = false;
        console.log(
          "Este vehículo no tiene una oportunidad relacionada por recordId"
        );
      }
    } catch (error) {
      console.log("Error en loadSecondWire: ", error);
    }
  }
}