// Ajuste anticipos montos minimos
// Anticipo minimo $500 para motos nuevas 
//     Harley_Davidson
//     Indian
//     Kawasaki
//     KTM
//     Motorrad
//     Polaris

// El resto 1000   
//     BMW
//     MINI
//     Autos_Usados

// Anticipo minimo "motos usadas" sean apartir de $200.
//     Motos_Usados

import { LightningElement,api,wire } from 'lwc';
import findPayment from '@salesforce/apex/Registrar_Anticipo_Controller.findPayment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { reduceErrors } from 'c/ldsUtils';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

// Define the fields you need (Opportunity Name and RecordType DeveloperName)
const FIELDS = [
    'Opportunity.RecordType.DeveloperName'
];

const motorcycleBrands = [
    "harley_davidson",
    "indian",
    "kawasaki",
    "ktm",
    "motorrad",
    "polaris"
];

export default class Registrar_Anticipo_Consultar extends LightningElement {
    
    inputIdentifier;

    @api
    oppId;

    isPaymentIdentifierValid;

    paymentNotFound;

    handleIdentifierChange(event){
        this.inputIdentifier = event.detail.value;
    }

    get isDisableButton(){
        return this.inputIdentifier == null || this.inputIdentifier.length == 0;
    }

    handleClick(){
        console.log('recordTypeDeveloperName');
        console.log(this.recordTypeDeveloperName);
        this.dispatchEvent(new CustomEvent('showloading'));
        let minimumAmount = 0;
        console.log('this.oppId ',this.oppId);
        findPayment({ identifier: this.inputIdentifier,oppId: this.oppId })
        .then((result) => {
            let amount = result.monto_anticipo ? Number(result.monto_anticipo) : 0;

            if(result.monto_anticipo){

                //validar los montos minimos permitidos
                if(this.isNewMotorcycle(this.recordTypeDeveloperName)){
                    minimumAmount = 500;
                } else if(this.recordTypeDeveloperName.includes('Motos_Usados')){
                    minimumAmount = 200;
                }else {
                    minimumAmount = 1000;
                }
                
                console.log('minimumAmount');
                console.log(minimumAmount);

                if(amount >= minimumAmount){
                    this.dispatchEvent(new CustomEvent('paymentvalidated', {
                        detail:{
                            identifier: this.inputIdentifier,
                            amount: amount,
                        }
                    }));
                } else {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Anticipo minimo requerido',
                        message: 'Se requiere un anticipo minimo de '+ minimumAmount,
                        variant: 'error'
                    })); 
                }
            
            } else {                    
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Agregar anticipo',
                    message: 'Error al consultar el anticip',
                    variant: 'error'
                }));  
            }
        })
        .catch((error) => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Agregar anticipo',
                message: reduceErrors(error).join(', '),
                variant: 'error'
            })); 
        })
        .finally(()=>{
            this.dispatchEvent(new CustomEvent('hideloading'));
        });

    }

    recordTypeDeveloperName;
    // Wire getRecord to fetch the Opportunity record
    @wire(getRecord, { recordId: '$oppId', fields: FIELDS })
    wiredOpportunity({ error, data }) {
        if (data) {
            this.recordTypeDeveloperName = data.fields.RecordType.value.fields.DeveloperName.value;
        } else if (error) {
            // Handle the error
            console.error(error);
        }
    }

    isNewMotorcycle(brand) {
        if (brand === null) {
            return false;
        }
        brand = brand.toLowerCase();
        return motorcycleBrands.includes(brand);
    }

}