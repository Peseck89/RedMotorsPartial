import { LightningElement, track, wire, api } from 'lwc';
import getCaso from '@salesforce/apex/ct_casoredi_ctrl.getCaseData'; 
import updateCaseFacturacion from '@salesforce/apex/ct_casoredi_ctrl.updateCaseFacturacion';  

export default class CT_Info_Contact_CS_lwc extends LightningElement {

  @api recordId;
  @track personalAccount
  @track accountId
  @track urlAccount
  @track urlContact
  @track nombrePropietario
  @track correoPropietario
  @track telefonoPropietario
  @track nombreContacto
  @track correoContacto
  @track telefonoContacto
  @track nombreFacturacion
  @track correoFacturacion
  @track telefonoFacturacion

  @wire(updateCaseFacturacion, {recordId: '$recordId'})
  setCaseInvoice({error, data}) {

  }

  @wire(getCaso, {recordId: '$recordId'})
  getCaseData({error, data}) {

    if(data) {
      console.log('===========DATA===========');
      console.log(data);

      this.personalAccount = data[0].Account.IsPersonAccount;

      //if(!this.personalAccount) {
        console.log('==============CONTACTO==================');
        console.log(data[0].ContactId);
        if (data[0].ContactId === null || data[0].ContactId === undefined || data[0].ContactId === '') {
          // Aquí poner la variable para mostrar popup
          this.nombreFacturacion = data[0].Account.Name
        } else {
          this.urlContact = `/lightning/r/${data[0].ContactId}/view`

          this.nombreContacto = data[0].Contact.Name
          this.correoContacto = data[0].Contact.Email
          this.telefonoContacto = data[0].Contact.Phone
          this.nombreFacturacion = data[0].Contact.Name
        }
      //}
      
      this.accountId = data[0].AccountId
      this.urlAccount = `/lightning/r/${data[0].AccountId}/view`

      this.nombrePropietario = data[0].Account.Name
      if(this.personalAccount){
        this.correoPropietario =  data[0].Account.PersonEmail;
      }else{
        this.correoPropietario =  data[0].Account.CorreoElectronicoEmpresarial__c;
      } 
      
      this.telefonoPropietario = data[0].Account.Phone
      this.correoFacturacion = data[0]?.Cuenta_de_Facturacion__r?.Invoice_Email__c || null;
      this.telefonoFacturacion =  data[0]?.Cuenta_de_Facturacion__r?.Invoice_Phone__c || null;

      this.nombreContacto = data[0].Contact.Name
      this.correoContacto = data[0].Contact.Email
      this.telefonoContacto = data[0].Contact.Phone
      this.nombreFacturacion = data[0]?.Cuenta_de_Facturacion__r?.Name || null;
      // this.correoFacturacion = data[0].Account.Invoice_Email__c
      // this.telefonoFacturacion = data[0].Account.Invoice_Phone__c
    } else if(error) {
      console.log('Error de data', error);
    } else {
      console.log(error);
    }
  }

}