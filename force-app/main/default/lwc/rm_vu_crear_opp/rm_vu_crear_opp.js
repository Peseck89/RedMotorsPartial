import { LightningElement,api,track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
const currentDate = new Date();

export default class Rm_vu_crear_opp extends LightningElement {
    
    step = 1;

    @api recordId;
    prodXBodegaId;
    // prodXBodItem;

    brand = '';
    year = '';
    model = '';
    vin = '';    
    internalColor = '';
    externalColor = '';
    tipoCombustible = '';
    bodegaId = '';
    placa = ''; 

    selectedProdXBodItemIds = [];
    selectedProdXBodItems = [];
    
    connectedCallback(){
        this.year = currentDate.getFullYear();
    }rm_vn_crear_opp

    @api showAccountInput;
    
    connectedCallback(){
        console.log('selectedProdXBodItems');
        console.log(this.selectedProdXBodItems);
        console.log(this.selectedProdXBodItems.length);
    }
    
    get showSelectInventory(){
        return this.step == 1;
    }
    
    get showConfirmation(){
        return this.step == 2;
    }
    
    handleGoBackEvent(){
        if (this.step > 1) {
            this.step--;
        }
        this.selectedProdXBodItemIds = [];
        this.selectedProdXBodItems = [];

        console.log('###########################');
        console.log('====== brand:'+this.brand);
        console.log('====== year:'+this.year);
        console.log('====== model:'+this.model);
        console.log('====== brvinand:'+this.vin);
        console.log('====== internalColor:'+this.internalColor);
        console.log('====== externalColor:'+this.externalColor);
        console.log('====== tipoCombustible:'+this.tipoCombustible);
        console.log('====== placa:'+this.placa);
        console.log('====== prodXBodegaId:'+this.prodXBodegaId);
    }

    handleGoNextStepHandle(){
        if (this.step < 3) {
            this.step++;
        }
    }  
    
    handlCloseEvent(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleVehicleSelectionEvent(event){
        this.selectedProdXBodItems = [...event.detail.selectedRows];
        this.selectedProdXBodItemIds = this.getSelectedItems(this.selectedProdXBodItems);
        this.prodXBodegaId = this.selectedProdXBodItemIds[0];

        console.log('====== prodXBodegaId:'+this.prodXBodegaId);

        this.brand = event.detail.brand && event.detail.brand != '' ? event.detail.brand : '';
        this.year = event.detail.year && event.detail.year != '' ? event.detail.year : '';
        this.model = event.detail.model && event.detail.model != '' ? event.detail.model : '';
        this.vin = event.detail.vin && event.detail.vin != '' ? event.detail.vin : '';
        this.internalColor = event.detail.internalColor && event.detail.internalColor != '' ? event.detail.internalColor : '';
        this.externalColor = event.detail.externalColor && event.detail.externalColor != '' ? event.detail.externalColor : '';
        this.tipoCombustible = event.detail.tipoCombustible && event.detail.tipoCombustible != '' ? event.detail.tipoCombustible : '';
        this.placa = event.detail.placa && event.detail.placa != '' ? event.detail.placa : '';

        console.log('###########################');
        console.log('====== brand:'+this.brand);
        console.log('====== year:'+this.year);
        console.log('====== model:'+this.model);
        console.log('====== brvinand:'+this.vin);
        console.log('====== internalColor:'+this.internalColor);
        console.log('====== externalColor:'+this.externalColor);
        console.log('====== tipoCombustible:'+this.tipoCombustible);
        console.log('====== placa:'+this.placa);
    }

    get isVehicleSelected(){
        return this.selectedProdXBodItems.length > 0;
    }

    get disableNextButton(){
        return !(this.selectedProdXBodItems && this.selectedProdXBodItems.length > 0);
    }


    getSelectedItems(selectedItems){
        let prodXBodIds = [];
        for (let index = 0; index < selectedItems.length; index++) {
            prodXBodIds[index] = selectedItems[index].Id;
        }
        return prodXBodIds;
    }
}