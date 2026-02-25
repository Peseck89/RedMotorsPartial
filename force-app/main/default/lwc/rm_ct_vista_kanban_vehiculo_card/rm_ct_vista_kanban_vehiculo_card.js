import { LightningElement, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation'

export default class Rm_ct_vista_kanban_vehiculo_card extends NavigationMixin(LightningElement) {

    @api stage
    @api record

    sfdcBaseURL;
    connectedCallback() {
        this.sfdcBaseURL = window.location.origin;         
    }  

    navigateToRecord(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.id,
                objectApiName: event.target.dataset.object,
                actionName: 'view',
            },
        });
    }

    get customerName(){
        return this.record && this.record.Account ? this.record.Account.Name : '';
    }

    get customerId(){
        return this.record && this.record.Account ? this.record.Account.Id : '';
    }  
    
    get vehicleName(){
        return this.record && this.record.Asset ? this.record.Asset.Name : '';
    }

    get accountName(){
        return this.record && this.record.Account ? this.record.Account.Name : '';
    }
    
    get vehicleId(){
        return this.record && this.record.Asset ? this.record.Asset.Id : '';
    }    

    get hasMechanicAssigned(){
        return this.record && this.record.Mecanico_Asignado__c && this.record.Mecanico_Asignado__r;
    }

    get mechanicName(){
        return this.record && this.record.Mecanico_Asignado__c && this.record.Mecanico_Asignado__r ? this.record.Mecanico_Asignado__r.Name : '';
    }

    get caseURL(){
        return this.sfdcBaseURL + '/'+this.record.Id;
    }

    get accountURL(){
        if (this.record.Account) {            
            return this.sfdcBaseURL + '/'+this.record.AccountId;
        }else{
            return '#';
        }
    }

    get workOrderURL(){
        return this.sfdcBaseURL + '/'+this.record.Id;
    }
    
    get mechanicURL(){
        if (this.record.Mecanico_Asignado__c) {            
            return this.sfdcBaseURL + '/'+this.record.Mecanico_Asignado__c;
        }else{
            return '#';
        }
    } 
    
    get vehicleURL(){
        if (this.record.Asset) {            
            return this.sfdcBaseURL + '/'+this.record.Asset.Id;
        }else{
            return '#';
        }
    }   
    
    handleDragStart(event){
        event.dataTransfer.setData("caseId", this.record.Id);
    }
}