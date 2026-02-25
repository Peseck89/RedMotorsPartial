import { LightningElement,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord,getRecordCreateDefaults,generateRecordInputForCreate } from 'lightning/uiRecordApi';
import { reduceErrors } from 'c/ldsUtils';
import PEDIDO_ESPECIAL_OBJECT from '@salesforce/schema/Pedido_Especial__c';
import OPPORTUNITY_ID_FIELD from '@salesforce/schema/Pedido_Especial__c.Oportunidad__c';
import FAMILY_FIELD from '@salesforce/schema/Pedido_Especial__c.Familia__c';
import BRAND_FIELD from '@salesforce/schema/Pedido_Especial__c.Marca__c';
import MODEL_FIELD from '@salesforce/schema/Pedido_Especial__c.Modelo__c';
import YEAR_FIELD from '@salesforce/schema/Pedido_Especial__c.Anio__c';
import COLOR_FIELD from '@salesforce/schema/Pedido_Especial__c.Color__c';
import TAPICERIA_CODE_FIELD from '@salesforce/schema/Pedido_Especial__c.Codigo_Tapiceria__c';
import COMMENTS_FIELD from '@salesforce/schema/Pedido_Especial__c.Comentario__c';

export default class CreatePedidoEspecial extends LightningElement {
    
    // @api
    // opportunity = null;
    isLoading = false;
    @api
    opportunityId;
    @api oppid;
    // opportunityIdField = OPPORTUNITY_ID_FIELD.fieldApiName;
    // opportunityIdCreateable;

    model;
    // modelIdField = MODEL_FIELD.fieldApiName;
    // modelIdCreateable;
    // modelErrorMessage;
    
    family;

    brand;
    // brandIdField = BRAND_FIELD.fieldApiName;
    // brandIdCreateable;
    
    year;
    // yearField = YEAR_FIELD.fieldApiName;
    // yearCreateable;
    
    color;
    // colorField = COLOR_FIELD.fieldApiName;
    // colorCreateable;
    
    tapiceriaCode;
    // tapiceriaCodeField = TAPICERIA_CODE_FIELD.fieldApiName;
    // tapiceriaCodeCreateable;

    comments;
    // commentsField = COMMENTS_FIELD.fieldApiName;
    // commentsCreateable;   

    error;

    connectedCallback(){
        console.log(this.opportunityId);
        console.log(this.oppid);
        console.log('test');
    }

    // @wire(getRecordCreateDefaults, { objectApiName: PEDIDO_ESPECIAL_OBJECT })
    // loadPedidoEspecialCreateDefaults({ data, error }) {
    //     if (data) {
    //         // Creates a record input with default field values
    //         this.recordInput = generateRecordInputForCreate(
    //             data.record,
    //             data.objectInfos[PEDIDO_ESPECIAL_OBJECT.objectApiName] // Filters it to only createable fields
    //         );
    //         const fields = this.recordInput.fields;            
    //         this.modelIdCreateable = MODEL_FIELD.fieldApiName in fields;
    //         this.brandIdCreateable = BRAND_FIELD.fieldApiName in fields;
    //         this.yearCreateable = YEAR_FIELD.fieldApiName in fields;
    //         this.colorCreateable = COLOR_FIELD.fieldApiName in fields;            
    //         this.tapiceriaCodeCreateable = TAPICERIA_CODE_FIELD.fieldApiName in fields;
    //         this.commentsCreateable = COMMENTS_FIELD.fieldApiName in fields;
           
    //         this.recordInput.fields[this.opportunityIdField] = this.opportunityId;

    //         this.error = undefined;
    //     } else if (error) {
    //         this.recordInput = undefined;
    //         this.error = error;
    //     }
    //     this.isLoading = false;
    // }

    handleFamilyChange(event) {
        this.family = event.target.value;
    }

    handleBrandChange(event) {
        this.brand = event.target.value;
    }
    
    handleModelChange(event) {
        this.model = event.target.value;
    }

    handleYearChange(event) {
        this.year = event.target.value;
    }

    handleColorChange(event) {
        this.color = event.target.value;
    }

    handleTapiceriaCodeChange(event) {
        this.tapiceriaCode = event.target.value;
    }

    handleCommentsChange(event) {
        this.comments = event.target.value;
    }    

    createPredidoEspecial() {
        const fields = {};
        fields[OPPORTUNITY_ID_FIELD.fieldApiName] = this.oppid;
        fields[FAMILY_FIELD.fieldApiName] = this.family;
        fields[BRAND_FIELD.fieldApiName] = this.brand;
        fields[MODEL_FIELD.fieldApiName] = this.model;
        fields[YEAR_FIELD.fieldApiName] = this.year;
        fields[COLOR_FIELD.fieldApiName] = this.color;
        fields[TAPICERIA_CODE_FIELD.fieldApiName] = this.tapiceriaCode;
        fields[COMMENTS_FIELD.fieldApiName] = this.comments;

        const recordInput = { apiName: PEDIDO_ESPECIAL_OBJECT.objectApiName, fields };
        
        this.isLoading = true;
        createRecord(recordInput)
            .then((record) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Pedido especial creado correctamente: ' + record.id,
                        variant: 'success'
                    })
                );
                this.dispatchEvent(new CustomEvent('closewindow', {
                    detail:{
                    }
                }));
            })
            .catch((error) => {                
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error al crear el registro de pedido especial',
                        message: reduceErrors(error).join(', '),
                        variant: 'error'
                    })
                );
            })
            .finally((error)=>{
                this.isLoading = false;
            });
    }

    validateForm(){
        let flag = 0;
        // let inputElements = this.template.querySelectorAll('lightning-input');
        // inputElements.forEach(element => {
        //     console.log('element name' + element.element.name);
        //     console.log('element ' + element.validity.valid);
        //     //should return true
        //     console.log('element ' + element.validity.customError);            
        //     // if(element.name === 'LastName'){
        //     //    element.value = undefined;
        //     // }            
        // });

        if (this.recordInput.fields[this.modelIdField] == null) {
            this.modelErrorMessage = 'El campo modelo es requerido.';
            flag = 1;
        }
        console.log(this.recordInput.fields[this.modelIdField]);
        return flag;
    }
    
    clear(){
        this.family = null;
        this.model = null;
        this.brand = null;
        this.year = null;
        this.color = null;
        this.tapiceriaCode = null;
        this.comments = null;
    }

    handleCancelClick(event){        
        this.dispatchEvent(new CustomEvent('cancelpedidoespecial', {
            detail:{}
        }));    
    }
}