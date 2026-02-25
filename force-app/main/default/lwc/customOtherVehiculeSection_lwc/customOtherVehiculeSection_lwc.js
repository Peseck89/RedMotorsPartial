import { LightningElement, track, wire, api } from 'lwc';
import getDatos from '@salesforce/apex/ct_CustomAsset.getCuentaInfo';
import getAssets from '@salesforce/apex/ct_CustomAsset.getAssets';

const columns = [
  { 
    label: 'Placa', 
    fieldName: 'recordUrl', 
    type: 'url', 
    typeAttributes: { 
      label: { fieldName: 'Name' }, 
      target: '_blank' 
    } 
  },
  { label: 'Marca', fieldName: 'Marca_Nvo__c' },
  { label: 'Modelo', fieldName: 'Modelo_Nvo__c' },
  { label: 'Año', fieldName: 'Anio__c' }
];

export default class CustomOtherVehiculeSection_lwc extends LightningElement {
  columns = columns;
  @track data = [];
  @api recordId;

  connectedCallback(){
    getAssets({ recordId: this.recordId })
      .then(result => {
        console.log('vehiculo creado correctamente: ' + result);
        if (result) {
          // Add the recordUrl for each record
          this.data = result.map(record => ({
            ...record,
            recordUrl: `/lightning/r/${record.Id}/view`
          }));
          console.log('Data', this.data);
          console.log('Id Vehiculo:', this.data[0].Id);
        }
      })
      .catch(error => {
        console.error('Error updating record', error);
      });
  }

  @wire(getDatos, { recordId: '$recordId' })
  getAccountSetting({ error, data }) {
    if (data) {
      console.log('======================data tabla======================');
      console.log(data);
      this.otroVehiculo = data[0].otroVehiculo;
      console.log('Datos otro vehiculo:', this.otroVehiculo);
    } else if (error) {
      console.log(error);
    }
  }
}