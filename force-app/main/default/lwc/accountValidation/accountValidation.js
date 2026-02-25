import { LightningElement, api ,wire, track} from 'lwc';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
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
import actualizaCaso from '@salesforce/apex/AccountValidationController.actualizaCaso';
import actualizaAsset from '@salesforce/apex/AccountValidationController.actualizaAsset';
import getContact from '@salesforce/apex/AccountValidationController.getContact';

const fields = [NAME_FIELD, EMAIL_FIELD, PHONE_FIELD, RECORDTYPEID,SOFTLAND_CODE];

export default class accountValidation extends NavigationMixin(LightningElement) {
	// The record page provides recordId and objectApiName
	@track errorMessageName = '';
	@track errorMessageLastName = '';
	@track errorMessagePhone = '';
	@track errorMessageCorreoPersonal = '';
	@track errorMessageModelo = '';
	@track errorMessageCorreoEmpresarial = '';
	@api recordId;
	@api caseId;
	@api contactId;
	@api assetId;
	@api objectApiName = 'Account';
	@api isPhysical;
	@api accountValidation;
	@track noContacto = false;
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
	get otroModelo() {
		return this.accountValidation.AccountMessageError.includes('Es marca');
	}
	get isNoContacto() {
		return this.accountValidation.AccountMessageError === 'La cuenta es empresarial y el caso NO posee contacto.';
	}
	get noInfoContacto() {
		return this.accountValidation.AccountMessageError === 'Falta información en el CONTACTO, revise los campos necesarios: Correo, Teléfono ,Primer Nombre y Apellido.';
	}
	get correoComodinPersonal() {
		console.log('this.accountValidation.AccountMessageError ', this.accountValidation.AccountMessageError);
		return this.accountValidation.AccountMessageError === 'Esta cuenta personal tiene un correo “comodín”. Por favor actualizar el correo con uno proporcionado por el cliente.';
	}
	get correoComodinEmpresarial() {
		return this.accountValidation.AccountMessageError === 'Esta cuenta empresarial tiene un correo “comodín”. Por favor actualizar el correo con uno proporcionado por el cliente.';
	}
	get desc_general() {
		return getFieldValue(this.AccountFields.data, SOFTLAND_CODE);
	}
	handleAssetSuccess(event) {
		this.errorMessageModelo = '';
		const fields = event.detail.fields;
		console.log('fields ',fields);
        const marca = fields.Marca_Nvo__c;
		const modelo = fields.Modelo_Nvo__c;
		console.log('marca ',marca);
		console.log('modelo ',modelo);

		if(marca != 'Otro' && modelo == 'Otro'){
			this.errorMessageModelo = 'Es marca: ' + marca+ ' y tiene en el campo modelo la opción:Otro, por favor especifique su modelo.';
		}
		event.stopPropagation();
		if (this.errorMessageModelo) {
			console.log('no actualiza asset');
		}
		else{ 
			this.template.querySelector('lightning-record-edit-form').submit(fields);
			actualizaAsset({assetId:this.assetId,modelo:fields.Modelo_Nvo__c})
				.then((result) => {	
			})
			.catch((error) => {
				console.log(error);
			})
			this.dispatchEvent(new CustomEvent('updateasset', {
				detail: {
					success: true//,
				}
			}));
		}
	}
	handleCaseSuccess(event) {
		const fields = event.detail.fields; 
		console.log('fields.ContactId ',fields.ContactId);
		console.log('fields.case ',this.accountValidation.CaseId);

		event.stopPropagation();
		this.template.querySelector('lightning-record-edit-form').submit(fields);
		console.log('actualizando caso el contacto2eee', fields);
		actualizaCaso({caseId:this.accountValidation.CaseId,contactId:fields.ContactId})
			.then((result) => {	
			})
			.catch((error) => {
				console.log(error);
			})
		this.dispatchEvent(new CustomEvent('updatecase', {
			detail: {
				success: true//,
			}
		}));
	}
	handleContactSuccess(event) {
		const fields = event.detail.fields;
		event.stopPropagation();
		if (this.errorMessageName || this.errorMessageLastName || this.errorMessagePhone) {
            // Display the error message or take appropriate action
            console.log('Cannot submit. Please correct the input.');
        } else {	
			this.template.querySelector('lightning-record-edit-form').submit(fields);
			setTimeout(() => {

			this.dispatchEvent(new CustomEvent('updatecontact', {
				detail: {
					success: true
				}
			}));
		}, 2000);

		}
	}
	handleSuccessAccountPersonal(event) {
		const fields = event.detail.fields;
		console.log('fields ',fields);
        const correoPersonal = fields.Email;
		console.log('campo1Value ',correoPersonal);
		if(correoPersonal == 'n/a@redmotorscr.com' || correoPersonal == 'contabilidabmw@redmotorscr.com'){
			this.errorMessageCorreoPersonal = 'Por favor módifica el correo comodín';
		}
		event.stopPropagation();
		if (this.errorMessageCorreoPersonal) {
            // Display the error message or take appropriate action
            console.log('Cannot submit. Please correct the input personal.');
        } else {
		this.template.querySelector('lightning-record-edit-form').submit(fields);
		this.dispatchEvent(new CustomEvent('updatepersonaccount', {
			detail: {
				success: true//,
			}
		}));
	}
	}
	handleSuccessAccountEmpresarial(event) {
		console.log('validando 4');
		console.log('enviando evento1');
		const fields = event.detail.fields;
		console.log('fields ',fields);
        const correoEmpresarial = fields.CorreoElectronicoEmpresarial__c;
		console.log('campo1Value ',correoEmpresarial);
		if(correoEmpresarial == 'n/a@redmotorscr.com' || correoEmpresarial == 'contabilidabmw@redmotorscr.com'){
			this.errorMessageCorreoEmpresarial = 'Por favor módifica el correo comodín';
		}
		event.stopPropagation();
		if (this.errorMessageCorreoEmpresarial) {
            // Display the error message or take appropriate action
            console.log('Cannot submit. Please correct the input empresarial.');
        } else {
		this.template.querySelector('lightning-record-edit-form').submit(fields);
		this.dispatchEvent(new CustomEvent('updatempresarialaccount', {
			detail: {
				success: true//,
			}
		}));
		}
	}
	handleSubmit(event) {
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
			if(this.accountWrapper.contribuyente.length>0){
				this.idTypeWrapper = this.accountWrapper.contribuyente[0].tipo;
			}			
			test=this.softlandUpdateResponse;
			this.updateSoftlandAccount();	
			this.updateOnlyId();
		}else{
			this.dispatchEvent(new CustomEvent('updateaccount', {
				detail: {
					success: true,
					action: event.target.dataset.id
				}
			}));
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
                recordId: this.accountValidation.CaseId,
                objectApiName: 'Case',
               // relationshipApiName: 'WorkOrderLineItems',
                actionName: 'view'
            }
        });
	}

	connectedCallback() {
		this.requestSoftlandAccount();
		console.log(JSON.stringify(this.accountValidation));
		this.getContactFromCase();

	}

	/*Apex Calls */
	handleNameChange(event) {
        const inputValue = event.detail.value;
        if (!/^[a-z  A-Z á é ó ú í Á É Í Ó Ú]*$/.test(inputValue)) {
			this.errorMessageName = 'Formato de Nombre inválido.';
        } else {
            // Clear the error message if the input is valid
            this.errorMessageName = '';
        }
    }
	handleLastNameChange(event) {
        const inputValue = event.detail.value;
        if (!/^[a-z  A-Z á é ó ú í Á É Í Ó Ú]*$/.test(inputValue)) {
			this.errorMessageLastName = 'Formato de Apellido inválido.';
        } else {
            // Clear the error message if the input is valid
            this.errorMessageLastName = '';
        }
    }
	handlePhoneChange(event) {
        const inputValue = event.detail.value;
		const phoneNumberPattern = /^\+506\d{8}$/;
        if (!phoneNumberPattern.test(inputValue)) {
			this.errorMessagePhone = 'Formato de Teléfono inválido (+50612345678).';
        } else {
            // Clear the error message if the input is valid
            this.errorMessagePhone = '';
        }
    }
	handleCorreoEmpresarialChange(event) {
        const inputValue = event.detail.value;
        const emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
		const regexCom = /\.com$/;
		const regexDobleCom = /\.com\.com$/;


        if (regexDobleCom.test(inputValue) || !regexCom.test(inputValue) || !emailPattern.test(inputValue) || inputValue == '' || inputValue == 'n/a@redmotorscr.com' || inputValue == 'contabilidabmw@redmotorscr.com') {
			this.errorMessageCorreoEmpresarial = 'Correo inválido.';
        } else {
            // Clear the error message if the input is valid
            this.errorMessageCorreoEmpresarial = '';
        }
    }
	handleCorreoPersonalChange(event) {
        const inputValue = event.detail.value;
        const emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
        if (!emailPattern.test(inputValue) || inputValue == '' || inputValue == 'n/a@redmotorscr.com' || inputValue == 'contabilidabmw@redmotorscr.com') {
			this.errorMessageCorreoPersonal = 'Correo inválido.';
        } else {
            // Clear the error message if the input is valid
            this.errorMessageCorreoPersonal = '';
        }
    }
	requestSoftlandAccount() {
		getSoftlandAccount({AcountId:this.recordId})
			.then((result) => {
				this.softlandRequested=result!=null;
				this.accountWrapper=result;
				//nuevos campos guardados
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
	getContactFromCase() {
		getContact({caseId:this.accountValidation.CaseId})
			.then((result) => {
				this.contactId=result;
			})
			.catch((error) => {
				console.log(error);
			})
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
	updateSoftlandAccount({accountWrapper:JSON.stringify(this.accountWrapper)})
			.then((result) => {
        //this.softlandRequested=result;
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