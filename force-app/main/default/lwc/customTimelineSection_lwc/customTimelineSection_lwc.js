import { LightningElement,wire,api,track } from 'lwc';
import getDatos from '@salesforce/apex/ct_CustomAsset.getCuentaInfo';
import getHistorialInfo from '@salesforce/apex/ct_CustomAsset.getHistorialInfo';


export default class CustomTimelineSection_lwc extends LightningElement {
    @api recordId;
    @track fechaFact;
    @track fechaUltima;
    @track historial;
    @track objetoHistorial = [];

    @wire(getHistorialInfo, { recordId: '$recordId' })
    getHistorialSetting({ error, data }) {
        var arrayTest = [];
        if (data) {
            console.log('======================data Historial======================');
            console.log(data);
            console.log(data.length);            
            for(var i = 0; i < data.length; i++){
                arrayTest.push({ 
                    label: data[i].TipoDeFecha__c + ' ' + data[i].Fecha__c, 
                    value: i + 1 // Adding 1 to start values from 1
                });
            }                                                                                        
        } else if (error) {
            console.log(error);
        }
        console.log('============arrayTest===============');
        console.log(arrayTest);
        if(arrayTest.length >0){
            this.objetoHistorial = [...arrayTest];
            console.log('============objetoHistorial===============');
            console.log(this.objetoHistorial);
        }
        
    }


    @wire(getDatos, { recordId: '$recordId' })
    getAccountSetting({ error, data }) {
        if (data) {
            console.log('======================data======================');
            console.log(data);
            if(data[0].fecha_facturacion_vehiculo__c != null || data[0].fecha_facturacion_vehiculo__c != undefined){
                this.fechaFact = 'Fecha de compra nuevo ' + data[0].fecha_facturacion_vehiculo__c;
            }else{
                this.fechaFact = 'Fecha de compra nuevo ';
            }

            if(data[0].UltimaVisitaAlTaller__c != null || data[0].UltimaVisitaAlTaller__c != undefined){
                this.fechaUltima = 'Última visita al taller ' + data[0].UltimaVisitaAlTaller__c;
            }else{
                this.fechaUltima = 'Última visita al taller ';
            }
            
            
            
        } else if (error) {
            console.log(error);
        }
    }

    async validarGarantia() {
        try {
            // Para depuración
            const citas = await obtenerCitasVehiculo({ assetId: this.assetSeleccionado });
            console.log('Citas encontradas:', citas);
            
            // Luego la validación real
            this.resultado = await validarGarantia({ 
                assetId: this.assetSeleccionado 
            });
            // ...
        } catch (error) {
            // ...
        }
    }
}