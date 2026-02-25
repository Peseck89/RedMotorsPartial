import { LightningElement,wire,api,track } from 'lwc';
import { reduceErrors } from 'c/ldsUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import getOpportunityRelatedProducts from '@salesforce/apex/Registrar_Anticipo_Controller.getOpportunityRelatedProducts';
import addReceiptOportunity from '@salesforce/apex/Registrar_Anticipo_Controller.addReceiptOportunity';
import ANTICIPO_OBJECT from '@salesforce/schema/Anticipo__c';
import { NavigationMixin } from 'lightning/navigation';

// Define the fields you need (Opportunity Name and RecordType DeveloperName)
const FIELDS = [
    'Opportunity.RecordType.DeveloperName'
];

export default class Registrar_Anticipo_Select_Vehicle extends NavigationMixin(LightningElement) {
    
    @api
    oppId;
    

    @track 
    isLoading = false;
    
    @api
    identifier;

    inputVehicleId;

    @api
    amount = 0;

    recordTypeDeveloperName;

    vehicleOptions = [];
    @wire(getOpportunityRelatedProducts, {
        oppId: '$oppId'
    })listInfo({ error, data }) {
        if (data) {
            let preparedOptions = [];            
            data.forEach((item, index) => {           
                
                let _brand = '';
                let _model = '';
                let _name = '';
                let _vin = '';
                let _productId = '';

                if (item.Product2) {
                    _productId = item.Product2.Id;
                    if (item.Product2.Marca__c && item.Product2.Marca__c) {
                        _brand = item.Product2.Marca__c;
                    }
                    if (item.Product2.Modelo_De_Inter_s__c && item.Product2.Modelo_De_Inter_s__c) {
                        _model = item.Product2.Modelo_De_Inter_s__c;
                    }                    
                    if (item.Product2.Name && item.Product2.Name) {
                        _name = item.Product2.Name;
                    }
                    if (item.Product2.vin__c && item.Product2.vin__c) {
                        _vin = item.Product2.vin__c;
                    }                    
                }
                let option = {                    
                    value: item.Id,
                    label: _name + ' - '+_vin,
                    brand: _brand,
                    model: _model,
                    productId: _productId
                };
                preparedOptions[index] = option;             
            });
            this.vehicleOptions = preparedOptions;

            if (this.vehicleOptions.length == 1) {
                this.inputVehicleId = this.vehicleOptions[0].value;
            }
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.vehicleOptions = [];
        }
    }   

    handleVehicleChange(event){
        this.inputVehicleId = event.detail.value;
        console.log('vehiculo seleccionado');
        console.log(event.detail.value);
    }
        
    handleBackClick(){
        this.dispatchEvent(new CustomEvent('gotosteptwo'));
    }

    handleSuccessEvent(event){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Tiempo improductivo registrado',
                message: 'El tiempo improductivo ha sido registrado correctamente.',
                variant: 'success'
            })
            );
            this.isLoading = false;
            this.dispatchEvent(new CustomEvent(''));
    }

    handleSubmitEvent(event){
        this.dispatchEvent(new CustomEvent('isloading'));
    }

    connectedCallback(){
        console.log(this.oppId);
    }

    handleAcceptClick(event){        
        this.isLoading = true;
        //cast string to number, checks amount anticipo greater than 1000
        // if(Number(this.amount) >= 1000){
            
            addReceiptOportunity({
                oppId: this.oppId,
                productId: this.getProductId(),
                identifier: this.identifier,
                monto:this.amount
            }).then((result)=>{
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: result.anticipoId,
                        objectApiName: ANTICIPO_OBJECT.objectApiName,
                        actionName: 'view'
                    }
                });
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Anticipo creado correctamente',
                        variant: 'success'
                    })
                );
            })
            .catch((error)=>{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Relacionar Anticipo Error!',
                        message: reduceErrors(error).join(', '),
                        variant: 'error'
                    })
                );
            })
            .finally(() => {
                this.isLoading = false;
            });
        // }else{
        //     this.dispatchEvent(
        //         new ShowToastEvent({
        //             title: 'Error',
        //             message: 'Para aplicar el anticipo es requerido que el monto sea mayor a $ 1,000.',
        //             variant: 'error'
        //         })
        //     );
        // }
    }

    getProductId(){
        let productId;
        this.vehicleOptions.forEach((item)=>{
            if(item.value == this.inputVehicleId){
                productId = item.productId;
                return;
            }
        });
        return productId;
    }

    get hasVehicles(){
        return this.vehicleOptions.length;
    }


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

}