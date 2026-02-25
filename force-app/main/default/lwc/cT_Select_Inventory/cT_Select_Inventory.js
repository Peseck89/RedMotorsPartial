import { LightningElement, api, track, wire } from 'lwc';
import { reduceErrors } from 'c/ldsUtils';
import { refreshApex } from '@salesforce/apex';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import addVehicle from '@salesforce/apex/RM_VN_QuoteController.addVehicle';
import getProductDataFromOLI from '@salesforce/apex/ProductSearcherController.getProductDataFromOLI';
import accountValidation from '@salesforce/apex/AccountValidationController.accountValidationByOpportunity';

export default class CT_Select_Inventory extends LightningElement {
    
    hideExtraButtons = false;

    @api recordId;

    // oppLineItemId = null;
    prodXBodegaId;
    oppProdInteresId;
    prodXBodItem;

    //Added account validation for Email and Phone
    accountValidationFlag=false;
    accountValidationRequired=false;
    accountId;
    isPhysical=false;
    validationObject;
    @api property;

    isLoading = false;

    showProductSearcher = true;

    @api brand = '';
    @api model = '';
    @api family = '';
    @api year = '';

    step = 1;

    connectedCallback(){
        console.log('RecordId : ' + this.recordId);
        this.handleAccountValidation();
        this.hideExtraButtons = true;
    }

    //@wire(getRecord, { recordId: '$recordId', fields }) opportunity;
    wiredProductDataResult;
    @wire(getProductDataFromOLI, { oppProdInteresId: '$oppProdInteresId' })
    wiredProductData(result) {
        this.isLoading = true;
        this.wiredProductDataResult = result;
        if (result.data) {            
            if (result.data.brand && result.data.model) {                
                this.step ++;
                this.brand = result.data.brand ? result.data.brand : null;
                this.model = result.data.model ? result.data.model : null;
                this.family = result.data.family ? result.data.family : null;
                this.year = result.data.year ? result.data.year : null;
            }
            this.error = undefined;
        } else if (result.error) {
            this.error = error;
            this.brand = null;            
            this.model = null;    
            this.family = null;    
            this.year = null;    
        }
        this.isLoading = false;
    }   

    get isDisableAcceptButton(){
        return this.prodXBodegaId == null;
    }

    handleNextPreviewClick(event){ 
        if(this.accountValidationRequired){
            this.handleAccountValidation();
        }        
        this.step = 3;
    }

    handleGetBackToStepTwoEvent(event){
        if(this.accountValidationRequired){
            this.handleAccountValidation();
        } 
        this.step = 2;
    }
    
    handleAddNewItemEvent(event){
        if(this.accountValidationRequired){
            this.handleAccountValidation();
        } 
        this.isLoading = true;
        console.log('this.brand ',this.brand);
        console.log('this.year ',this.year);
        console.log('this.model ',this.model);
        console.log('this.family ',this.family);
        console.log('this.recordId ',this.recordId);
        console.log('this.oppProdInteresId ',this.oppProdInteresId);
        console.log('this.prodXBodegaId ',this.prodXBodegaId);
        console.log('event.detail.quoteId ',event.detail.quoteId);

        addVehicle({
            oppId: this.recordId,
            oppProdIntId:this.oppProdInteresId,
            prodXBodegaId:this.prodXBodegaId,
            existingQuoteId: event.detail.quoteId,
        })
        .then((response)=>{
            // eval("$A.get('e.force:refreshView').fire();");
            this.dispatchEvent(new ShowToastEvent({
                title: 'Agregado a presupuesto',
                message: 'Vehiculo agregado a presupuesto',
                variant: 'success'
            }));
            this.dispatchEvent(new CloseActionScreenEvent());
            
            window.location.reload();
        })
        .catch((error)=>{
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error al crear el presupuesto',
                message: reduceErrors(error).join(', '),
                variant: 'error'
            }));            
        })
        .finally(()=>{
            this.isLoading = false;
        });     
    }

    handleCreateSpecialOrderClick(){
        if(this.accountValidationRequired){
            this.handleAccountValidation();
        } 
        this.showProductSearcher = false;
    }

    get showPedidoEspecialForm(){
        return !this.showProductSearcher;
    }
  
    handleInventorySelectionEvent(event){
        let selectedVehicle = [...event.detail.selectedVehicles];
        console.log('handleInventorySelectionEvent');
        console.log(selectedVehicle);
        if(this.accountValidationRequired){
            this.handleAccountValidation();
        } 
        // [ this.prodXBodegaId ] = event.detail.prodXBodegaId;    
        // this.prodXBodItem = event.detail.prodXBodItem;  

        console.log('**selectedItem**');
        console.log(selectedVehicle);

        //selectedVehicle contains this structure, so we need to extract the object
        // [
        //     {
        //         "Id": "a2eU90000004fpNIAQ",
        //         "productId": "01tPH000004DUUDYA4",
        //         "productCode": "1HGCM82633A123456",
        //         "productName": "BMW, X1 SDRIVE18I, NEGRO, 2024, MOTOR 34997427, XLINE , KUSW, FACT E7P0158",
        //         "productBrand": "BMW",
        //         "productModel": "BMW-X1-18I-VR-XLINE",
        //         "productVin": "WB30G410XRRA60384",
        //         "productTipoCombustible": "Gasolina",
        //         "productYear": "2024",
        //         "productInternalColor": "Gasolina", 
        //         "productExternalColor": "Black Saphire",
        //         "productPriceFantasia": "63000.00",
        //         "fechaIngresoTransito": "2024-04-05",
        //         "noDiasInventario": 211,
        //         "tapiceria": "KHCX",
        //         "codigoEquipamiento": "codigo aquipamiento aqui 2",
        //         "numeroPedido": "0021070",
        //         "reportado": true,
        //         "comentario": "test ffff ffff dsdsd ffff",
        //         "bodegaName": "Vehículos Nuevos Uruca",
        //         "productUrl": "https://redmotors--partialp2.sandbox.lightning.force.com/01tPH000004DUUDYA4",
        //         "backgroudColor": "background-color: #f3f3f3;",
        //         "pbeFantasiaId": "01u4U00000x4MIEQA2",
        //         "pbeSoftlandId": "01uPH000001AjHqYAK"
        //     }
        // ]

        let vehicle = selectedVehicle[0];
        console.log('**vehicle**');
        console.log(vehicle);
        console.log('vehiculoId ',vehicle.Id);

        this.prodXBodItem = vehicle;
        this.prodXBodegaId = vehicle.Id;
        
    }

    handleProdInteresSelectionEvent(event){
        console.log('handleProdInteresSelectionEvent');
        console.log(event.detail);
        if(this.accountValidationRequired){
            this.handleAccountValidation();
        } 
        this.brand = null;     
        this.model = null;
        [ this.oppProdInteresId ] = event.detail.oppProdInteresId;
        this.isLoading = true;        
        refreshApex(this.wiredProductDataResult);
    }    

    handleCancelPedidoEspecialEvent(event){
        if(this.accountValidationRequired){
            this.handleAccountValidation();
        } 
        this.showProductSearcher = true;
    }

    handleCloseWindowEvent(event){        
        this.dispatchEvent(new CloseActionScreenEvent());        
    }

    get isStepOne(){
        return this.step == 1;
    }

    get isStepTwo(){
        return this.step == 2;
    }

    get isStepThree(){
        return this.step == 3;
    }
    
    handleGoBackToStepOneClick(event){
        if(this.accountValidationRequired){
            this.handleAccountValidation();
        }         
        this.step = 1;        
        this.oppProdInteresId = null;
        this.prodXBodegaId = null;
        this.prodXBodItem = null;
    }   

    handleGoBackToStepTwoEvent(event){   
        if(this.accountValidationRequired){
            this.handleAccountValidation();
        }      
        this.step = 2;                    
        this.prodXBodegaId = null;
        this.prodXBodItem = null;        
    }

    handleAccountValidation(){
        if(!this.accountValidationRequired){
            accountValidation({oppId : this.recordId})
            .then((result) => {
                console.log(JSON.parse(result));
                if(result){
                    var account=JSON.parse(result);
                    this.accountValidationFlag=account.validate;
                    this.accountValidationRequired=account.validate;
                    this.accountId=account.Id;
                    this.isPhysical=account.isPhysical
                    this.validationObject=account;
                    //console.log(result);
                }
            })
            .catch((error) => {
                console.log('Error en account Validation by Opportunity');
                console.log(error);
                
            });
        }else{this.accountValidationFlag=true;}
    }

    handleUpdateAccount(event) {
        this.accountValidationFlag=!event.detail.success;
        if(event.detail.action==='Save'){
           this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Información actualizada correctamente',
                variant: 'success'
            }));
           this.accountValidationRequired=false;
        } 
   }
}