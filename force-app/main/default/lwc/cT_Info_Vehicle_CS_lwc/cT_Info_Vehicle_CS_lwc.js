import { LightningElement, track, wire, api } from "lwc";
import getCaso from "@salesforce/apex/ct_casoredi_ctrl.getCaseData";
import getAsset from "@salesforce/apex/ct_casoredi_ctrl.getAsset";
import getImagen from "@salesforce/apex/ct_CustomAsset.getImagen";
import getOportunidad from "@salesforce/apex/ct_casoredi_ctrl.getUltimoComentario";
import updateComentario from "@salesforce/apex/ct_casoredi_ctrl.updateComentario";
import getOpp from "@salesforce/apex/ct_casoredi_ctrl.getOpp";
import updateAssetkilometraje from "@salesforce/apex/cT_ChangeData_ctrl.updateAssetkilometraje";

import getHistorialFechas from "@salesforce/apex/ct_casoredi_ctrl.getHistorialFechas";
import getAssetWarranty from "@salesforce/apex/ct_casoredi_ctrl.getAssetWarranty";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import updateAssetComment from "@salesforce/apex/ct_casoredi_ctrl.updateAssetComment";

export default class CT_Info_Vehicle_CS_lwc extends LightningElement {
  @api recordId;

  @track assetId;
  @track urlAsset;
  @track tipo;
  @track placa;
  @track vin;
  @track marca;
  @track modelo;
  @track anio;
  @track planVenta;
  @track ultVisitaTaller;
  @track kilometraje;
  @track formatKilometraje;
  @track mantPlan;
  @track mostrarHoras;
  @track comentarios;
  @track fechaVentaNuevo;
  @track imagenDefault = 'https://images.vexels.com/media/users/3/154251/isolated/preview/fef0c563c39f2746c35604e969ffe3ef-bmw-car-front-view-silhouette.png?width=1130';
  @track imagenCoche;
  @track noContieneImagen = true;

  @track oppId;
  @track comentario = "";
  @track comentarioNegocio = "";
  @track oppUrl;
  @track consecutivoOpp;
  @track oppRel = "";
  @track tieneRel = false;

  @track showEditZone = false;
  @track showEditZoneKM = false;
  @track historialFechas = [];

  handleEditZone() {
    this.showEditZone = !this.showEditZone;
  }

  handleEditZoneKM() {
    this.showEditZoneKM = !this.showEditZoneKM;
  }

  // Method to construct record URL
  getRecordUrl(recordId) {
    return `/lightning/r/Historial_Fechas__c/${recordId}/view`;
  }

  handleEditZoneChange(event) {
    this.comentarios = event.target.value;
    this.comentarios = event.target.value;
    console.log("estos comentarios:", this.comentarios);
  }

  @wire(getCaso, { recordId: "$recordId" })
  getCaseData({ error, data }) {
    if (data) {
      console.log("===========DATA===========");
      console.log(data);

      this.assetId = data[0].AssetId;

      getHistorialFechas({ assetId: this.assetId })
        .then((result) => {
          if (result) {
            console.log(result);
            this.historialFechas = result.map((fecha) => ({
              ...fecha,
              recordUrl: `/lightning/r/Historial_Fechas__c/${fecha.Id}/view`, // Add computed URL
              usuarioName: fecha.UsuarioQueModifica__c
                ? fecha.UsuarioQueModifica__r.Name
                : "Unknown User", // Handle null case
            }));
            this.error = undefined;
          } else if (error) {
            this.error = error;
            this.historialFechas = [];
          }
        })
        .catch((error) => {
          // handle error
          console.error("Error updating record", error);
        });

      this.urlAsset = `/lightning/r/${data[0].AssetId}/view`;

      console.log("assetId", this.assetId);
      console.log("urlAsset", this.urlAsset);

      this.tipo = data[0].Asset.Tipo_de_veh_culo__c;
      if (
        data[0].Asset.Tipo_de_veh_culo__c == "Mula" ||
        data[0].Asset.Tipo_de_veh_culo__c == "Cuadraciclo"
      ) {
        this.mostrarHoras = true;
      } else {
        this.mostrarHoras = false;
      }

      getImagen({ recordId: this.assetId })
        .then((result) => {
          // handle success, maybe show a success message
          console.log("Imagen del coche: " + result);
          if (result) {
            this.noContieneImagen = false;
            this.imagenCoche =
              "https://redmotors.file.force.com/servlet/servlet.ImageServer?id=" +
              result +
              "&oid=00D0P000000Dvkz";
          }
        })
        .catch((error) => {
          // handle error
          console.error("Error updating record", error);
        });
      if (this.tipo == "Automovil") {
        this.imagenDefault =
          "https://images.vexels.com/media/users/3/154251/isolated/preview/fef0c563c39f2746c35604e969ffe3ef-bmw-car-front-view-silhouette.png?width=1130";
      } else if (this.tipo == "Motocicleta") {
        this.imagenDefault =
          "https://images.vexels.com/media/users/3/177844/isolated/preview/f290c1364a5561d4258d88bd8746a330-silueta-detallada-de-moto-moto.png";
      } else if (this.tipo == "Mula") {
        this.imagenDefault =
          "https://images.vexels.com/media/users/3/210406/isolated/preview/fc5411dda9fca811b09bbd9ad1954a24-silueta-de-buggy-al-aire-libre.png";
      } else if (this.tipo == "Cuadraciclo") {
        this.imagenDefault =
          "https://images.vexels.com/media/users/3/259472/isolated/lists/6257c6869e78b624c462151ff6e3a26e-silueta-detallada-de-atv.png";
      } else {
        this.imagenDefault =
          "https://images.vexels.com/media/users/3/154251/isolated/preview/fef0c563c39f2746c35604e969ffe3ef-bmw-car-front-view-silhouette.png?width=1130";
      }

      this.placa = data[0].Asset.Name;
      this.vin = data[0].Asset.NumeroDeChasis__c;
      this.marca = data[0].Asset.Marca_Nvo__c;
      this.modelo = data[0].Asset.Modelo_Nvo2__c;
      this.combustible = data[0].Asset.Combustible__c;
      this.oppRel = data[0].Asset.Oportunidad_relacionada__c;
      this.anio = data[0].Asset.Anio__c;
      this.comentarios = data[0].Asset.Comentario__c;
      this.fechaVentaNuevo = data[0].Asset.fecha_facturacion_vehiculo__c;
      // this.planVenta = data[0].
      this.ultVisitaTaller = data[0].Asset.UltimaVisitaAlTaller__c;
      this.kilometraje = data[0].Asset.Kilometros__c;
      if (this.kilometraje !== undefined) {
        this.formatKilometraje = Intl.NumberFormat("en-US").format(
          this.kilometraje
        );
      }
      this.mantPlan = data[0].Asset.Detalles_de_Garantia__c;
    } else if (error) {
      console.log("Error de data", error);
    } else {
      console.log(error);
    }
  }
  setKilometraje(event) {
    this.kilometraje = event.target.value;
    console.log("Kilometraje puesto");
    console.log(this.kilometraje);
  }

  handleKilometrajeChange() {
    console.log("Entro");
    updateAssetkilometraje({
      assetId: this.assetId,
      kilometraje: this.kilometraje,
    })
      .then(() => {
        // Handle successful update
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Case details updated successfully",
            variant: "success",
          })
        );
        window.location.reload();
      })
      .catch((error) => {
        // Handle error
        this.dispatchEvent(
          new ShowToastEvent({
            title: "El Kilometraje no puede ser menor al anterior.",
            message: error.body.message,
            variant: "error",
          })
        );
      });
  }

  guardarComentarios() {
    console.log("entro comentarios");
    updateAssetComment({ assetId: this.assetId, comment: this.comentarios })
      .then(() => {
        // Handle successful update
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Case details updated successfully",
            variant: "success",
          })
        );
        window.location.reload();
      })
      .catch((error) => {
        // Handle error
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error updating case details",
            message: error.body.message,
            variant: "error",
          })
        );
      });
  }

  @track hasWarrantyPlan = false;
  @track AssetWarrantyNumber;
  @track AssetWarrantyTerm;
  @track AssetWarrantyStartDate;
  @track AssetWarrantyEfectiveEndDate;
  @track AssetWarrantyEfectiveStartDate;
  @track AssetWarantyType;
  @track warranties;

  @wire(getAssetWarranty, { assetId: "$assetId" })
  wiredWarranties({ error, data }) {
    if (data) {
      this.hasWarrantyPlan = true;
      this.warranties = data;
    } else if (error) {
      this.warranties = undefined;
      // Handle error
    }
  }

  @wire(getAsset, { assetId: "$assetId" })
  getAsset({ error, data }) {
    console.log("Entro al asset");
    console.log("Data", data);
    if (data && Array.isArray(data) && data.length > 0) {
      console.log("==============ASSET=============");
      console.log(data);

      if (
        data[0].Garant_a_de_activo__c != undefined &&
        data[0].Garant_a_de_activo__c != null
      ) {
        this.hasWarrantyPlan = true;
        this.AssetWarrantyNumber =
          data[0].Garant_a_de_activo__r.AssetWarrantyNumber;
        this.AssetWarrantyTerm =
          data[0].Garant_a_de_activo__r.WarrantyTerm.WarrantyTermName;
        this.AssetWarrantyStartDate = data[0].Garant_a_de_activo__r.StartDate;
        this.AssetWarrantyEfectiveEndDate =
          data[0].Garant_a_de_activo__r.EndDate;
        this.AssetWarrantyEfectiveStartDate =
          data[0].Garant_a_de_activo__r.WarrantyTerm.EffectiveStartDate;
        this.AssetWarantyType = data[0].Garant_a_de_activo__r.WarrantyType;
      }
    } else if (error) {
      console.log("Error de data", error);
    }
  }

  // @wire(getOportunidad, { assetId: "$assetId" })
  // getOportunidad({ error, data }) {
  //   if (data && Array.isArray(data) && data.length > 0) {
  //     this.oppId = data[0].Id;
  //     this.comentario = data[0].Observaciones_cliente__c;
  //     this.comentarioNegocio = data[0].Observaciones_negocio__c;
  //     this.consecutivoOpp = data[0].ConsecutivoOportunidad__c;
  //     this.oppUrl = `/lightning/r/Opportunity/${data[0].Id}/view`;

  //     console.log("------------------ Respuesta OPP -------------------");

  //     console.log("OUTPUT : ", this.assetId);
  //     console.log("Comentario OPP: ", this.comentario);
  //     console.log("ID del Caso:", this.recordId);
  //     console.log("AssetId obtenido:", this.assetId);
  //     console.log("Oportunidad obtenida:", this.oppId);
  //   } else if (error) {
  //     console.error("Error consulta comentario", error);
  //   }
  // }

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
      const data = await getOportunidad({ assetId: this.assetId });
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

  // handleComentarioChange(event) {
  //   this.comentario = event.target.value;
  // }

  // actualizarComentario() {
  //   updateComentario({ recordId: this.oppId, comentario: this.comentario })
  //     .then(() => {
  //       this.mostrarNotificacion('Éxito', 'Comentario actualizado correctamente', 'success');
  //     })
  //     .catch((error) => {
  //       console.error("Error al actualizar comentario", error);
  //       this.mostrarNotificacion('Error', 'No se pudo actualizar el comentario', 'error');
  //     });
  // }

  // mostrarNotificacion(titulo, mensaje, variante) {
  //   this.dispatchEvent(
  //     new ShowToastEvent({
  //       title: titulo,
  //       message: mensaje,
  //       variant: variante
  //     })
  //   );
  //   window.location.reload()

  // }
}