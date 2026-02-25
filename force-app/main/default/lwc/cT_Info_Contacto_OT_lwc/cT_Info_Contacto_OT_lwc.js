import { LightningElement, track, wire, api } from 'lwc';
import getOT from '@salesforce/apex/ct_otRedis_ctrl.getWorkOrderData';
import updateAccountComment from '@salesforce/apex/ct_otRedis_ctrl.updateAccountComment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 
export default class CT_Info_Contacto_OT_lwc extends LightningElement {

  @api recordId;

  // Informacion de contacto
  @track idCuenta
  @track idContacto
  @track contactUrl
  @track accountUrl
  @track accountName
  @track contactName
  @track contactPhone
  @track contactEmail
  @track email
  @track accountPhone
  @track invoiceName
  @track invoiceEmail
  @track invoicePhoneNumber
  @track activeCreditNote
  @track isLocked
  @track nivelApDescArt
  @track nivelApDescMo
  @track estadoApDescMo
  @track personalAccount
  @track asset
  @track kmOrdenTrabajo
  @track realizarEncuesta
  @track catRespuestaEncuesta
  @track vigenciaPresupuesto
  @track origen
  @track tipoGasto
  @track priceBook
  @track actividadComercial
  @track aseguradora
  @track centroCosto
  @track comentarios
  @track comentVisibles

  @track showEditZone = false

  handleEditZone() {
    this.showEditZone = !this.showEditZone
  }

  handleEditZoneChange(event){
    this.comentarios = event.target.value;
    this.comentarios = event.target.value;
    console.log('estos comentarios:', this.comentarios);
  }

  @wire(getOT, {recordId: '$recordId'})
  getWorkOrderData({error, data}) {
    if(data) {
      console.log('===========DATA===========');
      console.log(data);
      this.personalAccount = data[0].Account.IsPersonAccount;

      //if(!this.personalAccount) {
        console.log('==============CONTACTO==================');
        console.log(data[0].ContactId);
        if (data[0].ContactId === null || data[0].ContactId === undefined || data[0].ContactId === '') {
          // Aquí poner la variable para mostrar popup
        } else {
          this.contactName = data[0]?.Contact?.Name || null;
          this.contactPhone = data[0]?.Contact?.Phone || null;
          this.contactEmail = data[0]?.Contact?.Email || null;
          this.idContacto = data[0]?.ContactId || null;
          this.contactUrl = `/lightning/r/${this.idContacto}/view`

          console.log(this.contactUrl);
        }
      //}

      if(data[0].AccountId === null || data[0].AccountId === undefined || data[0].AccountId === '') {
        this.idCuenta = data[0].AccountId
        console.log('AccountID', this.idCuenta);

      } 
      this.idCuenta = data[0].AccountId
      this.accountUrl = `/lightning/r/${data[0].AccountId}/view`
      console.log(this.accountUrl);
      this.accountName = data[0].Account.Name
      this.email = data[0].Correo__c
      this.accountPhone = data[0].Account.Phone
      this.invoiceName = data[0]?.Cuenta_de_Facturacion__r?.Name || null;
      this.invoiceEmail = data[0]?.Cuenta_de_Facturacion__r?.Invoice_Email__c || null;
      this.invoicePhoneNumber = data[0]?.Cuenta_de_Facturacion__r?.Invoice_Phone__c || null;
      this.activeCreditNote = data[0].Nota_de_cr_dito_activa__c
      this.isLocked = data[0].isLocked__c
      this.nivelApDescArt = data[0].Nivel_de_aprobaci_n_descuento_para_art_c__c
      this.nivelApDescMo = data[0].Nivel_de_aprobaci_n_descuento_para_MO__c
      this.estadoApDescMo = data[0].Estado_de_aprobaci_n_descuento_MO__c
      this.asset = data[0].Asset.Name
      this.kmOrdenTrabajo = data[0].Kilometros__c
      this.realizarEncuesta = data[0].Realizar_encuesta__c
      this.catRespuestaEncuesta = data[0].BMW_CategorizacionDeRespuestaEncuesta__c
      this.vigenciaPresupuesto = data[0].Vigencia_del_presupuesto__c
      this.origen = data[0].Origen__c
      this.tipoGasto = data[0].tipoDeGasto__c
      this.priceBook = data[0].Pricebook2Id
      this.actividadComercial = data[0].ActividadComercial__c
      this.aseguradora = data[0].BMW_Aseguradora__c
      this.centroCosto = data[0].BMW_CentroDeCosto__c
      this.comentVisibles = data[0].Account.Comentario__c
    } else if(error) {
      console.log('Error de data', error);
    }
  }

  guardarComentarios(){
    console.log('entro a comentarios');
    console.log(this.idCuenta);
    updateAccountComment({ accountId: this.idCuenta, comment: this.comentarios })
    .then(() => {
        // Handle successful update
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Account details updated successfully',
                variant: 'success',
            })
        );
        window.location.reload();
    })
    .catch(error => {
        // Handle error
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error updating Account details',
                message: error.body.message,
                variant: 'error',
            })
        );
    }); 
  }
}