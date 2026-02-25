import { LightningElement,api,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import columns from './columns';
import { reduceErrors } from 'c/ldsUtils';
import { refreshApex } from '@salesforce/apex';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createOpportunity from '@salesforce/apex/RM_VU_CrearOportunidad_Ctrl.createOpportunity';
import searchAccouns from '@salesforce/apex/SampleLookupController.searchRecords';
import rm_vn_crear_opp_acc_form from 'c/rm_vn_crear_opp_acc_form';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import PHONE_FIELD from '@salesforce/schema/Account.Phone';
import LightningAlert from "lightning/alert";
import validarCuenta from '@salesforce/apex/RM_VU_CrearOportunidad_Ctrl.validarCuenta'; 
import crearCuenta from '@salesforce/apex/RM_VU_CrearOportunidad_Ctrl.crearCuenta'; 


export default class Rm_vu_crear_opp_confirmar extends NavigationMixin(LightningElement)  {
    @api accountId = '';

    columns = columns;

    @track prodXBodItems = [];
    @track selectedProdXBodItems = [];
    @track prodXBodItemIds = [];
    ventanaActual = false;
    tipoDeCliente = '';
    departamento = '';
    cuentaFacturacion = '';
    leadSource = '';
    realizaTestDrive = '';
    aniodelvehiculo = '';
    isLoading = false;
    formaPago ='';
    plazoEnMeses = '';
    prima = 0;
    entidad = '';
    tipoDeUso = '';
    esConquista = false;
    esFinanciado = false;
    @api showAccountInput = false;

    accountErrors = [];
    accountInitialSelection = [];   
    
    _defaultResult = [{
        id: 'new-account',
        sObjectType: 'Account',
        icon: 'standard:account',
        title: 'Nueva Cuenta',
        subtitle: 'Cuenta'
    }];   
    
    newRecordOptions = [{label:'Nueva cuenta',value:'Account'}];

    @wire(getRecord, { recordId: '$accountId', fields: [NAME_FIELD], optionalFields: [] })
    wiredAccount({ error, data }) {
        if (data) {
            this.account = data;
            this.accountInitialSelection = [{
                id: this.accountId,
                sObjectType: 'Account',
                icon: 'standard:account',
                title: data.fields.Name.value,
                subtitle: 'Cuenta'
            }]; 
            // this.accountErrors = undefined;
        } else if (error) {
            // this.error = error;        
        }
    }

    account;

    connectedCallback() {  
        this.cuentaFacturacion = this.accountId;           
    } 

    handleBackClick(){
        this.dispatchEvent(new CustomEvent('gobackstep'));
    }

    get items(){
        let tmpRecords = [];
        for (let i = 0; i < this.selectedProdXBodItems.length; i++) {
            let tmpRecord = {
                prodXBodId:this.selectedProdXBodItems[i].Id,
                pbeId:this.selectedProdXBodItems[i].pbeId
            }
            tmpRecords[i] = tmpRecord;
        }  
        return tmpRecords;
    }

    handleCreateOppClick(){
        this.isLoading = true;
        if(this.ventanaActual){
            
            createOpportunity({
                accountId:this.accountId,
                items: this.items,
                contactoId : this.contactCuenta,
                strTipoDeCliente: this.tipoDeCliente,
                strDepartamento: this.departamento,
                strCuentaFacturacion: this.cuentaFacturacion,
                strLeadSource: this.leadSource,
                realizaTestDrive: this.realizaTestDrive,
                strAniodelvehiculo : this.aniodelvehiculo,
                tipoDeUso : this.tipoDeUso,
                fechaPosibleCompra : this.fechaPosibleCompra,
                formaDePago : this.formaPago,
                plazoEnMeses : this.plazoEnMeses,
                prima : this.prima,
                entidad : this.entidad,
            }).then((result)=>{         
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: result.opportunityId,
                        objectApiName: 'Opportunity',
                        actionName: 'view'
                    },
                });
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Crear oportunidad',
                    message: 'La oportunidad ha sido creada correctamente.',
                    variant: 'success'
                }));             
                this.dispatchEvent(new CustomEvent('close'));
            })
            .catch((error) => {
                this.error = reduceErrors(error).join(', ');
                const specificText = 'No esta permitido la creacion de oportunidades relacionadas a la cuenta Bavarian Motors';
                if (this.error.includes(specificText)) {
                    this.error = specificText;
                }
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error al crear la oportunidad',
                    message: this.error,
                    variant: 'error'
                }));
            })
            .finally(()=>{
                this.isLoading = false;
            });  
        }else{
            this.ventanaActual = true;
            this.isLoading = false;
        }          
    }
    
    get records(){
        return prodXBodItems;
    }

    @api
    set records(value){
        this.prodXBodItems = value;
        this.selectedProdXBodItems = this.prodXBodItems;
        this.prodXBodItemIds = [];
        for (let i = 0; i < this.prodXBodItems.length; i++) {
            this.prodXBodItemIds[i]= this.prodXBodItems[i].Id;
        };
    } 
        
    get isDisableButton(){
        return this.isLoading;
    }
    
    handleAccountSearch(event){
        const lookupElement = event.target;
        let params = event.detail;
       
        params["firedElement"] = 'Account';
        params["icon"] = 'standard:account';
        params["objName"] = 'Account';
        params["displayedObjName"] = 'Cuenta';

        searchAccouns(params)
            .then((results) => {                 
                lookupElement.setSearchResults(results);
            }).catch((error)=>{

            });
    }
    
    @track nameCuenta;
    @track apellidoCuenta;
    @track telCuenta;
    @track emailCuenta;
    @track contactCuenta;
    @track correoFact;
    @track cuentaError = false;
    @track cuentaErrorEmpresarial = false;
    @track esPersonal = false;
    @track fechaPosibleCompra;

    handleAccountSelectionChange(event){    
        let action;  
        [action] = event.detail;
        
        // if (action && action == 'new-account') {


        // }else {
            this.accountId = action;
        // }

        this.cuentaFacturacion = this.accountId;
        this.isLoading = true;
        validarCuenta({ cuentaId: this.accountId})
        .then(result => {
          // handle success, maybe show a success message              
          console.log('Cuenta: ' + result[0]);
          if(result != undefined && result != null){
            this.esPersonal = result[0].IsPersonAccount;
            if(result[0].IsPersonAccount){
                if(result[0].FirstName == '' || result[0].FirstName == null || result[0].FirstName == undefined ||
                result[0].LastName == '' || result[0].LastName == null || result[0].LastName == undefined ||
                result[0].Phone == '' || result[0].Phone == null || result[0].Phone == undefined ||
                result[0].PersonEmail == '' || result[0].PersonEmail == null || result[0].PersonEmail == undefined ||
                result[0].Invoice_Email__c == '' || result[0].Invoice_Email__c == null || result[0].Invoice_Email__c == undefined 
                ){
                    var test = '';
                    this.cuentaError = true;
                    this.cuentaErrorEmpresarial = false;  
                    this.nameCuenta = result[0].FirstName;
                    this.apellidoCuenta = result[0].LastName;
                    this.telCuenta = result[0].Phone;
                    this.cuentaFacturacion = this.accountId;
                    this.correoFact = result[0].Invoice_Email__c;
                    this.emailCuenta = result[0].PersonEmail;
                    this.contactCuenta = result[0].PersonContactId;
                    this.isLoading = false;
                }else{
                    this.cuentaErrorEmpresarial = false;                
                    this.cuentaError = false; 
                    this.nameCuenta = result[0].FirstName;
                    this.apellidoCuenta = result[0].LastName;
                    this.telCuenta = result[0].Phone;
                    this.correoFact = result[0].Invoice_Email__c;
                    this.emailCuenta = result[0].PersonEmail;
                    this.cuentaFacturacion = this.accountId;
                    this.contactCuenta = result[0].PersonContactId;
                    this.isLoading = false;
                }
            }else{
                if(result[0].Name == '' || result[0].Name == null || result[0].Name == undefined ||
                result[0].Phone == '' || result[0].Phone == null || result[0].Phone == undefined ||
                result[0].CorreoElectronicoEmpresarial__c == '' || result[0].CorreoElectronicoEmpresarial__c == null || result[0].CorreoElectronicoEmpresarial__c == undefined ||
                result[0].Invoice_Email__c == '' || result[0].Invoice_Email__c == null || result[0].Invoice_Email__c == undefined 
                ){
                    var test = '';
                    this.cuentaErrorEmpresarial = true;
                    this.cuentaError = false; 
                    this.nameCuenta = result[0].Name;
                    this.telCuenta = result[0].Phone;
                    this.cuentaFacturacion = this.accountId;
                    this.correoFact = result[0].Invoice_Email__c;
                    this.emailCuenta = result[0].CorreoElectronicoEmpresarial__c;                
                    this.isLoading = false;
                }else{                    
                    this.cuentaErrorEmpresarial = false;                
                    this.cuentaError = false; 
                    this.nameCuenta = result[0].Name;
                    this.telCuenta = result[0].Phone;
                    this.cuentaFacturacion = this.accountId;
                    this.correoFact = result[0].Invoice_Email__c;
                    this.emailCuenta = result[0].CorreoElectronicoEmpresarial__c;                
                    this.isLoading = false;
                }
            }            
            
          }
          this.isLoading = false;
        })
        .catch(error => {
            // handle error
            this.isLoading = false;
            console.error('Error geting record', error);
        });

    }

    cambiarEmailFact(event) {
        this.correoFact = event.detail.value;
    }
    cambiarNombre(event) {
        this.nameCuenta = event.detail.value;
    }
    cambiarApellido(event) {
        this.apellidoCuenta = event.detail.value;
    }
    cambiarPhone(event) {
        this.telCuenta = event.detail.value;
    }
    cambiarEmail(event) {
        this.emailCuenta = event.detail.value;
    }

    handleContact(event) {
        this.contactCuenta = event.target.value;
    }

    actualizarCuenta(){
        console.log(this.esPersonal);
        if(!this.esPersonal){
            if(this.accountId == '' || this.accountId == null || this.accountId == undefined
            || this.nameCuenta == '' || this.nameCuenta == null || this.nameCuenta == undefined           
            || this.telCuenta == '' || this.telCuenta == null || this.telCuenta == undefined ||
            this.emailCuenta == '' || this.emailCuenta == null || this.emailCuenta == undefined || 
            this.correoFact == '' || this.correoFact == null || this.correoFact == undefined
            ){
                LightningAlert.open({
                    message: "Por favor llene todos los campos.",
                    theme: "error",
                    label: "Error!",
                });
            }else{        
                this.isLoading = true;
                console.log('Entro crear cuenta');
                console.log(this.accountId);
                crearCuenta({ cuentaId: this.accountId,nombre: this.nameCuenta, apellido:this.apellidoCuenta, telefono: this.telCuenta, email: this.emailCuenta, emailFact: this.correoFact})
                .then(result => {
                    this.isLoading = false;
                    this.cuentaError = false;
                    this.cuentaErrorEmpresarial  = false;
                    console.log(result);
                })
                .catch(error => {
                    // handle error
                    this.isLoading = false;
                    console.error('Error geting record', error);
                });
            }
        }else{
            if(this.accountId == '' || this.accountId == null || this.accountId == undefined
            || this.nameCuenta == '' || this.nameCuenta == null || this.nameCuenta == undefined
            || this.apellidoCuenta == '' || this.apellidoCuenta == null || this.apellidoCuenta == undefined
            || this.telCuenta == '' || this.telCuenta == null || this.telCuenta == undefined ||
            this.emailCuenta == '' || this.emailCuenta == null || this.emailCuenta == undefined || 
            this.correoFact == '' || this.correoFact == null || this.correoFact == undefined
            ){
                LightningAlert.open({
                    message: "Por favor llene todos los campos.",
                    theme: "error",
                    label: "Error!",
                });
            }else{        
                this.isLoading = true;
                console.log('Entro crear cuenta');
                console.log(this.accountId);
                crearCuenta({ cuentaId: this.accountId,nombre: this.nameCuenta, apellido:this.apellidoCuenta, telefono: this.telCuenta, email: this.emailCuenta, emailFact: this.correoFact})
                .then(result => {
                    this.isLoading = false;
                    this.cuentaError = false;
                    this.cuentaErrorEmpresarial  = false;
                    console.log(result);
                })
                .catch(error => {
                    // handle error
                    this.isLoading = false;
                    console.error('Error geting record', error);
                });
            }
        }        
    }



    get isDisableNextButton(){
        return this.selectedProdXBodItems.length == 0 || this.cuentaErrorEmpresarial == true ||  this.cuentaError == true || this.accountId == null || this.accountId == undefined || this.accountId == '';
    }

    handleProdXBoditemsSelection(event){
        this.selectedProdXBodItems = event.detail.selectedRows;
    }

    handleNewRecordEvent(event){
        this.accountInitialSelection = [];
        rm_vn_crear_opp_acc_form.open({
            size: 'small',
            description: 'Formulario para la creación de una cuenta'
            // content: 'Passed into content api',
        })
        .then((result) => {
            if (result && result.accountId && result.accountId != null) {
                this.accountId = result.accountId;

                this.dispatchEvent(new ShowToastEvent({
                    title: 'Cuenta creada',
                    message: 'La cuenta ha sido creada correctamente.',
                    variant: 'success'
                }));
            }
        });
    }

    handleTipoCliente(event){
        /*
        tipoDeCliente = '';
        departamento = '';
        cuentaFacturacion = '';
        leadSource = '';
        realizaTestDrive = false;
        */
        this.tipoDeCliente = event.target.value;
        console.log('==============================');
        console.log(this.tipoDeCliente);
        var tipoCliente = event.target.value;
        console.log('==============================');
        console.log(tipoCliente);
        if(tipoCliente == 'Conquista'){
            this.esConquista = true;
        }else{
            this.esConquista = false;
        }

    }

    handleDepartamento(event){
        this.departamento = event.target.value;
    }

    handleCuentaFacturacion(event){
        this.cuentaFacturacion = event.target.value;
    }
    handleFormaPago(event){
        this.formaPago = event.target.value;
        if(this.formaPago == 'Financiado'){
            this.esFinanciado = true;
        }else{
            this.esFinanciado = false;
        }
    }
    handlePlazoMeses(event){
        this.plazoEnMeses = event.target.value;
    }
    handlePrima(event){
        this.prima = event.target.value;
    }
    handleEntidad(event){
        this.entidad = event.target.value;
    }
    handleLeadSource(event){
        this.leadSource = event.target.value;
    }

    handleRealiza(event){
        this.realizaTestDrive  = event.target.value;
    }

    handleAnio(event){
        this.aniodelvehiculo = event.target.value;
    }

    handleTipoUso(event){
        this.tipoDeUso = event.target.value;
    }

    handleFechaPosibleCompra(event){
        this.fechaPosibleCompra = event.target.value;
    }
}