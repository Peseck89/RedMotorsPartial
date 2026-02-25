import { LightningElement, api ,wire} from 'lwc';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from "lightning/actions";

import { NavigationMixin } from 'lightning/navigation';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import EMAIL_FIELD from '@salesforce/schema/Account.PersonEmail';
import PHONE_FIELD from '@salesforce/schema/Account.Phone';
import RECORDTYPEID from '@salesforce/schema/Account.RecordTypeId';
import SOFTLAND_CODE from '@salesforce/schema/Account.codigoSoftland__c';
import getSoftlandAccount from '@salesforce/apex/AccountValidationController.getSoftlandAccount';
import updateSoftlandAccount from '@salesforce/apex/AccountValidationController.updateSoftlandAccount';
import updateOnlyId from '@salesforce/apex/AccountValidationController.updateOnlyId';

const fields = [NAME_FIELD, EMAIL_FIELD, PHONE_FIELD, RECORDTYPEID,SOFTLAND_CODE];

export default class accountValidationFlow extends NavigationMixin(LightningElement) {
	// The record page provides recordId and objectApiName
	@api recordId;
	@api objectApiName = 'Account';
	@api isPhysical;
	@api caseId;
	@api accountValidation;
  	accountWrapper;
	softlandRequested=false;
	objectInfo;
	softlandUpdateResponse;
	idType = '';
	cedula = '';
	firstRun = 0;
	errorText = '';
	idTypeWrapper = '';

	softlandTipoId = '';
	softlandNumeroId = '';

	@wire(getRecord, {
		recordId: '$recordId',
		fields
	})
	AccountFields;

	get desc_general() {
		return getFieldValue(this.AccountFields.data, SOFTLAND_CODE);
	}
	handleSubmit(event) {
		console.log('Entro a guardar');
		var accTemp=JSON.parse(JSON.stringify(this.accountWrapper));
		var test=null;
		const inputFields = this.template.querySelectorAll(
			'[data-type="softlandField"]'
		);
		if (this.softlandRequested && inputFields && event.target.dataset.id === 'Save') {
			inputFields.forEach(field => {
				console.log(field.dataset.name);
				switch(field.dataset.name) {
					case 'Softland_Email__c':
					  accTemp.email=field.value;
					  break;
					case 'Softland_Phone__c':
					  accTemp.telefono1=field.value;
					  break;
					case 'Softland_FE_Email__c':
					  accTemp.email_doc_electronico=field.value;
					  accTemp.email_doc_electronico_copia=field.value;
					  break;
					case 'Softland_Phone2__c':
					  accTemp.telefono2=field.value;
					  break;
					case 'Softland_Tipo_Documento__c':
					  this.idType=field.value;
					  break;
					case 'Softland_Numero_Identificacion__c':
					  this.cedula=field.value;
					  break;
				}
				console.log(field.value);
			});
			console.log(accTemp);
			this.accountWrapper=accTemp;
			console.log('accountWrapper');
			console.log(this.accountWrapper.contribuyente.length);
			if(this.accountWrapper.contribuyente.length>0){
				this.idTypeWrapper = this.accountWrapper.contribuyente[0].tipo;
			}
			test=this.softlandUpdateResponse;
			console.log('antes a updateSoftlandAccount');
			this.updateSoftlandAccount();	
			this.updateOnlyId();
			console.log('recordId');
			console.log(this.recordId);
			this[NavigationMixin.Navigate]({
				type: 'standard__recordPage',
				attributes: {
					recordId: this.caseId,
					objectApiName: 'Case',
					actionName: 'view'
				}
			});
		}else{
			console.log('es cancel');
			location.reload();

		}

	}
	showNotification(title,message,variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
			mode:'sticky'
        });
        this.dispatchEvent(evt);
    }

	navigateToaccount(){

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.caseId,
                objectApiName: 'Case',
               // relationshipApiName: 'WorkOrderLineItems',
                actionName: 'view'
            }
        });
	}

	connectedCallback() {
		this.requestSoftlandAccount();
		console.log(JSON.stringify(this.accountValidation));
	}

	/*Apex Calls */
	requestSoftlandAccount() {
		getSoftlandAccount({AcountId:this.recordId})
			.then((result) => {
				console.log(result);
				this.softlandRequested=result!=null;
				this.accountWrapper=result;
				this.softlandTipoId = result.contribuyente[0].tipo;
				this.softlandNumeroId = result.contribuyente[0].id;
				console.log(JSON.parse(JSON.stringify(result)));
			})
			.catch((error) => {
				console.log(error);
			})
		/*.finally(() => {
		// console.log('Finally'); // Finally
		    this.setRealVailability();
		    this.toggle();
		});*/
	}

	updateOnlyId(){
		console.log(this.recordId);
        //console.log(this.opportunity.data);
        //cast string to number, checks amount anticipo greater than 1000       
		if(this.firstRun == 0 ){     
			updateOnlyId({  
				cedula: this.cedula,
				tipoDocumento: this.idType,
				cuenta: this.recordId
			}).then((result)=>{
				if(this.firstRun == 0 ){
					if(result){
						console.log('ID Actualizado');
						this.firstRun = 1;
					}
				}            
			})
			.catch((error)=>{
				console.log(error);
			})
			.finally(() => {
			
			});
		}
	}

  updateSoftlandAccount() {
	console.log('Entro a updateSoftlandAccount');
	updateSoftlandAccount({accountWrapper:JSON.stringify(this.accountWrapper)})
			.then((result) => {
        //this.softlandRequested=result;
				console.log('dentroß a updateSoftlandAccount');
				console.log(JSON.parse(result));
				console.log(JSON.parse(result).operationResult.description);
				this.softlandUpdateResponse= JSON.parse(result).operationResult;
			})
			.catch((error) => {
				console.log(error);
				console.log(error.body.message[0].message);
				this.showNotification('Error',error.body.message[0].message,'error');
			})
		.finally(() => {
			if(this.softlandUpdateResponse.code=='00'){
				this.dispatchEvent(new CustomEvent('updateaccount', {
					detail: {
						success: true,
						action: 'Save'
					}
				}));
			}else{this.showNotification('Error al actualizar con softland',this.softlandUpdateResponse.description,'error');}
		});
	}


	validateDocumentTypeAndCedula(documentType, cedula) {
		console.log(documentType);
		console.log(cedula);
		// Define regular expressions for each document type
		const regexMap = {
			'01': /^[0-9]{9}$/,
			'02': /^[0-9]{10}$/,
			'03': /^[0-9]{12}$/,
			'04': /^[0-9]{10}$/,
		};
	
		// Check if the document type is in the regexMap
		if (regexMap.hasOwnProperty(documentType)) {
			const regex = regexMap[documentType];
			// Check if the cedula matches the regular expression
			if (!regex.test(cedula)) {
				// Validation failed
				return false;
			}
		}
	
		// Validation passed
		return true;
	}

	handleInputChangeTipo(event) {
        var inputValue = event.detail.value; // Get the new value from the input field
		this.idType = inputValue;
        const isValid = this.validateDocumentTypeAndCedula(inputValue,this.cedula);

        if (!isValid) {
            this.errorText = 'Error: El número de identificación jurídica debe tener 10 números.'
			+'El número de identificación física debe tener 9 números.'
			+'El número dimex debe tener 12 números.'
			+'El número nite debe tener 10 números.'; 
        } else {
            this.errorText = ''; // Clear the error message
        }
    }
	//idType = '';
	//cedula = '';
	handleInputChange(event) {
		console.log('entro validar');
        var inputValue = event.detail.value; // Get the new value from the input field
		this.cedula = inputValue;
        const isValid = this.validateDocumentTypeAndCedula(this.idType,inputValue);
		console.log(isValid);
        if (!isValid) {
            this.errorText = 'Error: El número de identificación jurídica debe tener 10 números.'
			+'El número de identificación física debe tener 9 números.'
			+'El número dimex debe tener 12 números.'
			+'El número nite debe tener 10 números.'; 
        } else {
            this.errorText = ''; // Clear the error message
        }
    }

}