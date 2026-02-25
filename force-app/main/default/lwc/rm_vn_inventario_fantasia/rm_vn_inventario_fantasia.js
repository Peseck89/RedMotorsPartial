import { LightningElement, api, wire,track } from 'lwc';
import columns from './columns';
import { reduceErrors } from 'c/ldsUtils';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getBrands from '@salesforce/apex/RM_VN_InventarioFantasia_Ctrl.getBrands';
import getRecords from '@salesforce/apex/RM_VN_InventarioFantasia_Ctrl.getRecords';
import searchFamilyByBrand from '@salesforce/apex/RM_VN_InventarioFantasia_Ctrl.searchFamilyByBrand'

const DELAY = 300;

export default class Rm_vn_inventario_fantasia extends LightningElement {

    columns = columns;

    @api accountId;
    @api opportunityId;

    brandOptions = [];
    familyOptions = [];

    brand;
    familly
    year = new Date().getFullYear();

    pageNumber = 1;
    totalRecords = 0;
    totalPages = 0;

    @track records = [];
    @track isLoading = false;
    @track noRecords = false;
    @track currentPage = 1;
    @track isFirstPage = true;


    errors;
    familyErrors = [];
    familyInitialSelection=[];

    sfdcBaseURL;
    connectedCallback() {
        this.sfdcBaseURL = window.location.origin;         
    }

    @wire(getBrands)
    wiredBrands({ data, error }) {
        this.brandOptions = [];
        if (data) {
            this.brandOptions = data.map(item => ({ 'label': item.label, 'value': item.value }));
        }
    }

    handleRecordTypeSelectedEvent(event) {
        this.brand = event.detail.recordTypeId;
        console.log('this.brand', this.brand);
        this.handleSearch();
    }

    handleYearChange(event) {
        const search = event.target.value;
        if (search != this.year) {
            if (search != undefined && search != null && search != '') {
                this.year = search;
                this.handleSearch();   
            }            
        }
    }

    handleSearch() {
        this.isLoading = true;
        getRecords({ brand: this.brand, familly: this.familly, year: this.year, pageNumber: this.pageNumber})
        .then(result => {
            this.records = [];
            if (result.records) {                    
                let tmpRecords = [];
                this.noRecords = this.records.length === 0;
                Object.values(result.records).forEach((item, index) => {
                    if (typeof item === "object") {
                        let pbe;
                        if (result.preciosFantasia) {
                            pbe = result.preciosFantasia.find((element) => {
                                return element.Product2Id === item.Id;
                            });
                        }
    
                        let record = {
                            Id: item.Id,
                            productName: item.Name ? item.Name : '',
                            productId: item.Id ? item.Id : '',
                            productBrand: item.Marca__c ? item.Marca__c : '',
                            productModel: item.Modelo_De_Inter_s__c ? item.Modelo_De_Inter_s__c : '',
                            productYear: item.Anno__c ? item.Anno__c : '',
                            productFamilia: item.Familia__c ? item.Familia__c : '',
                            unitPrice: pbe && pbe.UnitPrice ? parseFloat(pbe.UnitPrice).toFixed(2) : 0,
                            currencyCode: pbe && pbe.CurrencyCode ? parseFloat(pbe.CurrencyCode) : 0,
                            productUrl: this.sfdcBaseURL + '/' + item.Id,
                            pbeId: pbe ? pbe.Id : null
                        };
                        tmpRecords[index] = record;
    
                        pbe = undefined;
                    }
                });
    
                this.records = tmpRecords;
                this.totalRecords = result.totalRecords ? result.totalRecords : 0;
                if (this.totalRecords > 0) {
                    this.totalPages = Math.ceil(result.totalRecords / result.pageSize);
                }
            }
            this.isLoading = false;
        })
        .catch(error => {
            // Handle any error that occurred in any of the previous steps.
            this.isLoading = false;
            console.error("Error fetching records: ", error);
        });
    }    


    handleFamilySearch(event){
        console.log('test');
        const lookupElement = event.target;
        let params = event.detail;
        params["objName"] = 'Product2';
        params["displayedObjName"] = 'Familia';
        params["icon"] = 'standard:category';
        params["brand"] = this.brand;

        searchFamilyByBrand(params)
            .then((results) => {
                lookupElement.setSearchResults(results);
            });
    }

    handleFamilySelectionChange(event){   
        this.familly = null;
        [ this.familly ] = event.detail;
        if (this.familly == undefined) {
            this.familly = null;
        }    
        console.log('this.familly',this.familly);
        this.handleSearch(); 
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        if (selectedRows.length > 0) {
            const selectedRecord = selectedRows[0];
            
            // Fire the custom event
            const selectEvent = new CustomEvent('recordselect', {
                detail: {
                    selectedRecord:selectedRecord,
                    brand: this.brand,
                    familly: this.familly,
                    year: this.year
                }
            });
            this.dispatchEvent(selectEvent);
        }
        console.log('================== selected record ==================');
        console.log('brand',this.brand);
        console.log('familly',this.familly);
        console.log('year',this.year);
    }

    handleAccountChange(event) {
        this.accountId = event.detail.value;
    }

}