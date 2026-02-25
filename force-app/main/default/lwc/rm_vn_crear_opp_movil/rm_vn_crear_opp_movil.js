import { LightningElement,api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import rm_vn_crear_opp_modelo_interes from 'c/rm_vn_crear_opp_modelo_interes';
const currentDate = new Date();

export default class Rm_vn_crear_opp_movil extends NavigationMixin(LightningElement) {
    
    step = 1;

    @api recordId;
    @api brand;
    @api year;

    selectedProdXBodItemIds = [];
    selectedProdXBodItems = [];
    
    connectedCallback(){
        this.year = currentDate.getFullYear();
    }

    @api showAccountInput;
    
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
    }

    handleGoNextStepHandle(){
        if (this.step < 3) {
            this.step++;
        }
    }  
    
    handleInventorySelectionEvent(event){
        this.selectedProdXBodItems = [...event.detail.selectedVehicles];
        this.selectedProdXBodItemIds = this.getSelectedProdXBodItems(this.selectedProdXBodItems);
        this.brand  = event.detail.brand;
        this.year  = event.detail.year;

    }
    
    handlCloseEvent(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    get disableNextButton(){
        return !(this.selectedProdXBodItems && this.selectedProdXBodItems.length > 0);
    }

    getSelectedProdXBodItems(selectedProdXBodItems){
        let prodXBodIds = [];
        for (let index = 0; index < selectedProdXBodItems.length; index++) {
            prodXBodIds[index] = selectedProdXBodItems[index].Id;
        }
        return prodXBodIds;
    }

    handleCreateOppModeloInteresHandle(event){
        
        console.log('this.recordId',this.recordId);

        rm_vn_crear_opp_modelo_interes.open({
            size: 'small',
            description: 'Formulario para la creación de una oportunidad de modelo de interés',
            accountId: this.recordId
        })
        .then((result) => {
            if (result != null) {
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: result,
                        objectApiName: 'Opportunity',
                        actionName: 'view'
                    }
                });
    
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Oportunidad creada',
                    message: 'La oportunidad ha sido creada correctamente.',
                    variant: 'success'
                }));
            }

            console.log('result',result);
        });
    }

    handlResetvaluesEvent(){
        this.step = 1;
        this.selectedProdXBodItemIds = [];
        this.selectedProdXBodItems = [];
    }
}