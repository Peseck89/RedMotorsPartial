import { api, wire, track } from 'lwc';
import LightningModal from 'lightning/modal';
import { reduceErrors } from 'c/ldsUtils';
import columns from './columns';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import searchAccouns from '@salesforce/apex/SampleLookupController.searchRecords';
import createOpportunity from '@salesforce/apex/RM_VN_CrearOppModeloInteres_Ctrl.createOpportunity';
import validarCuenta from '@salesforce/apex/RM_VN_CrearOppModeloInteres_Ctrl.validarCuenta'; 
import rm_vn_crear_opp_acc_form from 'c/rm_vn_crear_opp_acc_form';
import LightningAlert from "lightning/alert";
import crearCuenta from '@salesforce/apex/RM_VN_CrearOppModeloInteres_Ctrl.crearCuenta'; 
export default class Rm_vn_crear_opp_modelo_interes extends LightningModal {

    @api recordId;
    columns = columns;
    @api accountId;
    opportunityId;
    selectedVehicle = [];
    numeroIdentificacion = '';
    tipoIdentificacion = '';

/* handleNumeroIdentificacion(event) {
    this.numeroIdentificacion = event.detail?.value ?? event.target?.value ?? '';
}

handleTipoIdentificacion(event) {
    this.tipoIdentificacion = event.detail?.value ?? event.target?.value ?? '';
} */
    messageError;

    showAccountInput = false;

    ventanaActual = false;
    tipoDeCliente = '';
    departamento = '';
    cuentaFacturacion = '';
    leadSource = '';
    realizaTestDrive = '';
    aniodelvehiculo = '';
    aniodelvehiculo__c = '';

    @track cuentaError = false;

    tipoDeUso = '';
    fechaPosibleCompra = '';

    esConquista = false;


    isLoading = false;
    formaPago ='';
    plazoEnMeses = '';
    prima = 0;
    entidad = '';
    esFinanciado = false;
    brand;
    familly;
    year;

    showModeloInteresScreen = false;

    showConfirmationScreen = false;

    @track isNextButtonDisabled = true;

    accountErrors = [];
    accountInitialSelection = [];   
    
    _defaultResult = [{
        id: 'new-account',
        sObjectType: 'Account',
        icon: 'standard:account',
        title: 'Nueva Cuenta',
        subtitle: 'Cuenta'
    }]    

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

    connectedCallback(){
        this.showModeloInteresScreen = true;
        this.isNextButtonDisabled = true;

        if (this.accountId != undefined && this.accountId != null && this.accountId != '') {
            this.showAccountInput = false;            
        }else{
            this.showAccountInput = true;
            
        }
        this.cuentaFacturacion = this.accountId;
        console.log('this.cuentaFacturacion',this.cuentaFacturacion);
    }
    
    handleVehicleSelection(event){
        const selectedRecord = event.detail.selectedRecord;
        this.brand = event.detail.brand;
        this.familly = event.detail.familly;
        this.year = event.detail.year;
        console.log('#################################################');
        console.log('this.brand',this.brand);
        console.log('this.familly',this.familly);
        console.log('this.year',this.year);
        let record = {
            Id: selectedRecord.Id,
            productName: selectedRecord.productName,
            productId: selectedRecord.productId,
            productBrand: selectedRecord.productBrand,
            productFamilia: selectedRecord.productFamilia,
            productModel: selectedRecord.productModel,
            productYear: selectedRecord.productYear,
            unitPrice: selectedRecord.unitPrice,
            currencyCode: selectedRecord.currencyCode,
            productUrl: selectedRecord.productUrl,
            pbeId: selectedRecord.pbeId,
        };

        this.selectedVehicle[0] = record;
        this.isNextButtonDisabled = false;
        // console.log('this.isNextButtonDisabled',this.isNextButtonDisabled);
        // console.log('this.selectedVehicle',this.selectedVehicle);
    }

    handleShowModeloInteresScreenClick(){
        this.showModeloInteresScreen = true;
        this.showConfirmationScreen = false;
        this.selectedVehicle = [];
        this.brand = undefined;
        this.familly = undefined;
        this.year = undefined;
        this.accountId = undefined;     
        this.isNextButtonDisabled = true;   
    }

    handleShowConfirmationScreenClick(){
        this.showModeloInteresScreen = false;
        this.showConfirmationScreen = true;
    }

    handleCreateOpportunity(event) {
    console.log('this.brand', this.brand);
    console.log('this.familly', this.familly);
    console.log('this.year', this.year);
  /*   console.log('numeroIdentificacion:', this.numeroIdentificacion);
    console.log('tipoIdentificacion:', this.tipoIdentificacion); */

    this.isLoading = true;
    console.log('ventanaActual:', this.ventanaActual);

    if (this.ventanaActual) {
        const form = this.template.querySelector('lightning-record-edit-form[data-id="oppForm"]');

        const allValid = [...form.querySelectorAll('lightning-input-field, lightning-input')]
            .every((input) => input.reportValidity());

        if (allValid) {
            createOpportunity({
                accountId: this.accountId,
                productFantasiaId: this.selectedVehicle[0].Id,
                priceBookEntryId: this.selectedVehicle[0].pbeId,
                brand: this.brand,
                familly: this.familly,
                year: this.year,
                contactoId: this.contactCuenta,
                strTipoDeCliente: this.tipoDeCliente,
                strDepartamento: this.departamento,
                strCuentaFacturacion: this.cuentaFacturacion,
                strLeadSource: this.leadSource,
                realizaTestDrive: this.realizaTestDrive,
                strAniodelvehiculo: this.aniodelvehiculo,
                tipoDeUso: this.tipoDeUso,
                fechaPosibleCompra: this.fechaPosibleCompra,
                formaDePago: this.formaPago,
                plazoEnMeses: this.plazoEnMeses,
                prima: this.prima,
                entidad: this.entidad,
                numeroIdentificacion: this.numeroIdentificacion,
                tipoIdentificacion: this.tipoIdentificacion
            })
            .then((result) => {
                this.close(result.opportunityId);
                this.messageError = undefined;
            })
            .catch((error) => {
                console.error('Error createOpportunity', error);
                this.messageError = reduceErrors(error);
            })
            .finally(() => {
                this.isLoading = false;
            });

        } else {
            alert('Por favor, complete todos los campos obligatorios.');
            this.isLoading = false;
        }
    } else {
        this.ventanaActual = true;
        this.isLoading = false;
    }
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
                console.error('Error geting record', error);
            });
    }

    @track nameCuenta;
    @track apellidoCuenta;
    @track telCuenta;
    @track emailCuenta;
    @track contactCuenta;
    @track correoFact;
    @track cuentaErrorEmpresarial = false;
    @track esPersonal = false;

    handleAccountSelectionChange(event){    
        let action;  
        [action] = event.detail;
        
        // if (action && action == 'new-account') {


        // }else {
            this.accountId = action;
        // }
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
        console.log('esta Cuenta');
        console.log(this.contactCuenta );
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
                    this.cuentaErrorEmpresarial = false;
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
                    this.cuentaErrorEmpresarial = false;
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



    handleNewRecordEvent(event){
        this.accountInitialSelection = [];
        console.log('============================entro aqui============================');
        rm_vn_crear_opp_acc_form.open({
            size: 'small',
            description: 'Formulario para la creación de una cuenta'
            // content: 'Passed into content api',
        })
        .then((result) => {
            if (result && result.accountId && result.accountId != null) {
                this.accountId = result.accountId;
            }
        });
    }

    get isCreateOpportunityDisabled(){
        return this.accountId == undefined || this.cuentaErrorEmpresarial == true ||  this.cuentaError == true || this.isLoading;
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

    get displayError() {
        return this.messageError && this.messageError.length > 0;
    }
}