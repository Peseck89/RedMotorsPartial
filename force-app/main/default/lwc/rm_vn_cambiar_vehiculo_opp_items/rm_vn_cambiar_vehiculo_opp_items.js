import { LightningElement, track, api, wire } from 'lwc';
import columns from './columns';
import { reduceErrors } from 'c/ldsUtils';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOppLineItems from '@salesforce/apex/RM_VN_CambiarVehiculo_Ctrl.getOppLineItems';

const DELAY = 300;

export default class Rm_vn_cambiar_vehiculo_opp_items extends LightningElement {
    columns = columns;
    @api oppId;
    @track pageNumber = 1;
    @track totalRecords = 0;
    @track totalPages = 0;

    @track selectedOppLineItemIds = [];
    @track oppLineItems = [];

    wiredOppLineItemsResult;

    isLoading = false;

    sfdcBaseURL;
    connectedCallback() {
        this.sfdcBaseURL = window.location.origin;         
    } 

    @wire(getOppLineItems,{ oppId: '$oppId', pageNumber : "$pageNumber" })    
    wiredProducts(result) { 
        this.oppLineItems = [];       
        this.wiredOppLineItemsResult = result;
        if (result.data && result.data.records) {
            let tmpRecords = [];
            Object.values(result.data.records).forEach((item, index) => {
                if (typeof item === "object") {
                    let record = {
                    Id :  item.Id,
                    productId :  item.Product2.Id ? item.Product2.Id : '',
                    productCode :  item.Product2.Codigo_de_Producto__c ? item.Product2.Codigo_de_Producto__c : '',
                    productName : item.Product2.Name ? item.Product2.Name : '',
                    productBrand : item.Product2.marcaVehiculo__c ? item.Product2.marcaVehiculo__c : '',
                    productModel : item.Product2.modelo__c ? item.Product2.modelo__c : '',
                    productVin : item.Product2.vin__c ? item.Product2.vin__c : '',
                    productYear : item.Product2.Anno__c ? item.Product2.Anno__c : '',
                    productUnitPrice : item.UnitPrice ? item.UnitPrice : 0.0,
                    productInternalColor : item.Product2.Color__c ? item.Product2.Color__c : '',
                    productExternalColor : item.Product2.Color_Externo__c ? item.Product2.Color_Externo__c : '',
                    productUrl: this.sfdcBaseURL + '/'+item.Product2.Id
                };
                    tmpRecords[index] = record;
                }
            });
            
            this.oppLineItems = tmpRecords;            
            this.totalRecords = result.data.totalRecords ? result.data.totalRecords : 0;
            if(this.totalRecords > 0){
                this.totalPages = Math.ceil(result.data.totalRecords / result.data.pageSize);
            }        
        }else if(result.error){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error !',
                    message: reduceErrors(result.error).join(', '),
                    variant: 'error'
                })
            );
        }
        this.isLoading = false;
    }

    handleOppLineItemsSelection(event){
        const selectedRows = event.detail.selectedRows;    
        this.selectedOppLineItemIds = [];
        this.selectedOppLineItems = [];
        for (let i = 0; i < selectedRows.length; i++) {
            this.selectedOppLineItemIds.push(selectedRows[i].Id);
            this.selectedOppLineItems.push(selectedRows[i]);
        }        
    }
    
    handleBackClick(){
        this.pageNumber--;
    }

    handleNextClick(){
        this.pageNumber++;
    }

    get isEnablePrevButton(){
        return !(this.totalPages > 0 && this.pageNumber > 1);
    }

    get isEnableNextButton(){
        return !(this.totalPages > 1 && this.pageNumber != this.totalPages);
    }

    handleNextStepClick(event){
        this.dispatchEvent(new CustomEvent('nextstep', {
            detail:{
                oppLineItems: [...this.selectedOppLineItems]         
                }
            }));
    }  
    
    get disableNextButton(){
        return this.selectedOppLineItems == undefined || this.selectedOppLineItems == null || this.selectedOppLineItems.length == 0;
    }
}