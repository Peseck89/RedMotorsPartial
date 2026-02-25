import { LightningElement, track, wire, api } from 'lwc';
import getDatos from '@salesforce/apex/ct_CustomAsset.getCuentaInfo'; 

export default class CustomSecondContactSection_lwc extends LightningElement {
  @api recordId;
  @track correoFacturacion;
  @track direccionResidencial;
  @track estadoCivil;
  @track fechaNacimiento;
  @track fechaRegistro;

  connectedCallback(){
    
  }
  @wire(getDatos, { recordId: '$recordId' })
  getAccountSetting({ error, data }) {
    if (data) {
        console.log('======================data======================');
        console.log(data);
        this.correoFacturacion = data[0].Account.Invoice_Email__c;
        this.direccionResidencial = data[0].Account.Direccion_Residencial__c;
        this.estadoCivil = data[0].Account.EstadoCivilTipos__c;
        this.fechaNacimiento = data[0].Account.Fecha_Nacimiento__c
        this.fechaRegistro = data[0].Account.fechaRegistro__c;
        
    } else if (error) {
        console.log(error);
    }
}

}