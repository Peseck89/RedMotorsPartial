import { LightningElement, track, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import updateMarca from '@salesforce/apex/CreateBrandFamilyCategoryController.updateMarca';
//import getPicklistValuesForRecordType from '@salesforce/apex/CreateBrandFamilyCategoryController.getPicklistValuesForRecordType';
//import getPicklistValuess from '@salesforce/apex/CreateBrandFamilyCategoryController.getPicklistValues';
//import getPicklistValuesWithControllingValues from '@salesforce/apex/CreateBrandFamilyCategoryController.getPicklistValuesWithControllingValues';
import createNewFamilyByBrand from '@salesforce/apex/CreateBrandFamilyCategoryController.createNewFamilyByBrand';
import createNewCategoryByBrand from '@salesforce/apex/CreateBrandFamilyCategoryController.createNewCategoryByBrand';
import createNewGroupByBrand from '@salesforce/apex/CreateBrandFamilyCategoryController.createNewGroupByBrand';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//New Approach
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import MARCA_FIELD from "@salesforce/schema/Product2.Marca__c"; // Import Marca field
import CATEGORY_FIELD from "@salesforce/schema/Product2.Categor_a_veh_culo__c"; // Import Category field
import GROUP_FIELD from "@salesforce/schema/Product2.Grupo__c";
import FAMILY_FIELD from "@salesforce/schema/Product2.Familia__c";

export default class CreateBrandFamilyCategoryValues extends LightningElement {
    //wizard
    @api curretStep;
    @api step1 = false;
    @api step2 = false;
    @api step3 = false;
    @api step4 = false;
    @api step5 = false;

    //Inputs
    @track brand;
    @track category;
    @track group;
    @track family;
 
    //ServerInfo
    @track marcas = [];
    @track categorias = [];
    @track grupos = [];
    @track familias = [];

    //Maps
    @track categoryByBrand;// = new Map();
    @track groupByCategoria;
    @track familyByGroup;

    //Parameters
    @api typeForm;
    @api recordTypeId;
    @api recordTypeDescripton;
    @api label;
    @api recordTypeApiName;
    @api isWizard;
    @api wBrand;
    @api wCategory;
    @api wGroup;
    @api wFamily;

    //Toogle Visibility
    isLoading = false;
    showInputMarca = false;
    showInputCategoria = false;
    showInputGrupo = false;
    isSuccessMarca = false;
    isSuccessFamilia = false;
    showCreate = false;
    showReload = false;

    //Tipos Forms
    showMarcaForm = false;
    showGrupoForm = false;
    showCategoriaForm = false;
    showFamiliaForm = false;
    showProductForm = false;

    marcaGlobalPicklist = 'Marca_de_Interes';
    familiaGlobalPicklist = 'Familia';

    connectedCallback(){
        if(this.marcas.length === 0){
            if((this.typeForm == 'Marca') || (this.typeForm == 'all') || (this.typeForm == 'Grupo')){
                this.showMarcaForm = true;
            }
            if((this.typeForm == 'Categoria') || (this.typeForm == 'all')){
                this.brand = this.isWizard ? this.wBrand:'';
                this.showMarcaForm = this.isWizard ? false : true;
                this.showCategoriaForm = true;
            }
            if((this.typeForm == 'Grupo') || (this.typeForm == 'all')){
                this.category = this.isWizard ? this.wCategory:'';
                this.showMarcaForm = this.isWizard ? false : true;
                this.showCategoriaForm = this.isWizard ? false : true;
                this.showGrupoForm = true;
            }
            if((this.typeForm == 'Familia') || (this.typeForm == 'all')){
                this.group = this.isWizard ? this.wGroup:'';
                this.showMarcaForm = this.isWizard ? false : true;
                this.showCategoriaForm = this.isWizard ? false : true;
                this.showGrupoForm = this.isWizard ? false : true;
                this.showFamiliaForm = true;
            }if((this.typeForm == 'Producto') || (this.typeForm == 'all')){
                this.showProductForm = true;
                this.isWizard = false;
                console.log('STEP CREACION:'+this.recordTypeApiName);
            }
        }
    }

    handleMarcaSelected(event){
        const valueSelected = event.detail.value;
        console.log('Selected Marca:', valueSelected);
        if(valueSelected==='*** Agregar Nueva Marca ***'){
            this.showInputMarca = true;
            this.showCreate = true;
            this.brand = '';
        }else{
            this.brand = valueSelected;
            this.calculateCategoriasValues(valueSelected);
            this.showInputMarca = false;
            this.showCreate = false;
        }
    }

    handleCategoriaSelected(event){
        const valueSelected = event.detail.value;
        if(valueSelected==='*** Agregar Nuevo Tipo ***'){
            this.showInputCategoria = true;
            this.showCreate = true;
            this.category = '';
        }
        else{
            this.category = valueSelected;
            this.calculateGruposValues(valueSelected);
            this.showInputCategoria = false;
            this.showCreate = false;
        }
    }

    handleGrupoSelected(event){
        const valueSelected = event.detail.value;
        if(valueSelected==='*** Agregar Nuevo Grupo ***'){
            this.showInputGrupo = true;
            this.showCreate = true;
            this.group = '';
        }
        else{
            this.group = valueSelected;
            this.calculateFamilyValues(valueSelected);
            this.showInputGrupo = false;
            this.showCreate = false;
        }
    }

    handleFamilySelected(event){
        const valueSelected = event.detail.value;
        if(valueSelected==='*** Agregar Nueva Familia ***'){
            this.family = '';
            this.showInputFamilia = true;
            this.showCreate = true;
        }
        else{
            this.family = valueSelected;
            this.showInputFamilia = false;
            this.showCreate = false;
        } 
    }

    handleBrandChange(event) {
        this.brand = event.detail.value;
    }

    handleCategoryChange(event) {
        this.category = event.detail.value;
    }

    handleGroupChange(event) {
        this.group = event.detail.value;
    }

    handleFamilyChange(event) {
        this.family = event.detail.value;
    }

    handleCreate(){
        console.log('Creando...');
        this.isLoading = true;
        if(this.showInputMarca){
            this.updatePicklist();
        }
        else if (this.typeForm === "Categoria"){
            this.createNewCategory();
        }else if(this.typeForm === "Grupo"){
            this.createNewGrupo();
        }else if(this.typeForm === "Familia"){
            'CREANDO FAMILIA:'
            this.createNewFamily();
        }
    }

    handleReload(){
        window.location.reload();
    }


    // @WIRE FOR PICKLIST VALUES
    //Marca__c
    @wire(getPicklistValues, {
        recordTypeId: '$recordTypeId',
        fieldApiName: MARCA_FIELD
      })
      wiredMarcaValues({ data, error }) {
        if (data) {
          this.marcas = data.values.map((item) => ({
            label: item.label,
            value: item.value
          }));
          //this.marcaSize = true;
          if((this.typeForm == 'Marca')){
            this.marcas.unshift({ label: '*** Agregar Nueva Marca ***', value: '*** Agregar Nueva Marca ***' });
            }
        } else if (error) {
          console.error("Error loading Marca picklist values:", error);
        }
    }

    //Categoria Vehiculo
    @wire(getPicklistValues, {
        recordTypeId: '$recordTypeId', // Replace with your actual Record Type Id for Product2
        fieldApiName: CATEGORY_FIELD
    })
    wiredCategoryValues({ data, error }) {
        if (data) {
            //console.log(data);
            this.categoryByBrand = this.createControllerValueMap(data);
            if(this.isWizard){this.calculateCategoriasValues(this.brand);}
        } else if (error) {
        console.error("Error loading Category picklist values:", error);
        }
    }

    //Grupo__c
    @wire(getPicklistValues, {
        recordTypeId: '$recordTypeId', // Replace with your actual Record Type Id for Product2
        fieldApiName: GROUP_FIELD
    })
    wiredGrupoValues({ data, error }) {
        if (data) {
            //console.log(data);
            this.groupByCategoria = this.createControllerValueMap(data);
            if(this.isWizard){this.calculateGruposValues(this.category);}
        } else if (error) {
        console.error("Error loading Category picklist values:", error);
        }
    }

    //Family
    @wire(getPicklistValues, {
        recordTypeId: '$recordTypeId', // Replace with your actual Record Type Id for Product2
        fieldApiName: FAMILY_FIELD
    })
    wiredFamilyValues({ data, error }) {
        if (data) {
            console.log(data);
            this.familyByGroup = this.createControllerValueMap(data);
            if(this.isWizard){this.calculateFamilyValues(this.group);}
        } else if (error) {
        console.error("Error loading Category picklist values:", error);
        }
    }


    //Updates Values from Apex
    updatePicklist() {
        updateMarca({ globalPicklist: this.marcaGlobalPicklist, newValue: this.brand, recordTypeId: this.recordTypeId, recordTypeDescripton: this.recordTypeDescripton,
                      label: this.label, recordTypeApiName: this.recordTypeApiName})
            .then((result) => {
                // Show success message
                console.log(result);
                if(result == 204){
                    this.showToast('Success', 'El valor fue agregado correctamente', 'success');
                    this.isSuccessMarca = true;
                    this.showCreate = false;
                    this.recordTypeId = this.recordTypeId;
                    this.marcaSize = true;
                } else {
                    this.showToast('Warning', 'La transacción tuvo un error, consulte al administrador', 'Warning');
                }
            })
            .catch((error) => {
                // Show error message
                this.showToast('Error', 'Failed to update' + error, 'error');
                console.error(error);
            })
            .finally(() => {this.isLoading = false; if(!this.isWizard){window.location.reload()}}
        );
    }

    createNewCategory() {
        createNewCategoryByBrand({ globalPicklist: 'Categoria_Vehiculo', newValue: this.category, controllingFieldValue: this.brand, recordTypeId: this.recordTypeId, recordTypeDescripton: this.recordTypeDescripton,
            label: this.label, recordTypeApiName: this.recordTypeApiName})
            .then((result) => {
                // Show success message
                console.log(result);
                if(result == 204){
                    this.showToast('Success', 'El valor fue agregado correctamente', 'success');
                    this.showCreate = false;
                } else {
                    this.showToast('Warning', 'La transacción tuvo un error, consulte al administrador', 'Warning');
                }
            })
            .catch((error) => {
                // Show error message
                this.showToast('Error', 'Failed to update' + error, 'error');
                console.error(error);
            })
            .finally(() => { this.isLoading = false;if(!this.isWizard){window.location.reload()}}
        );
    }

    createNewGrupo() {
        createNewGroupByBrand({ globalPicklist: 'Categor_a', newValue: this.group, controllingFieldValue: this.category, recordTypeId: this.recordTypeId, recordTypeDescripton: this.recordTypeDescripton,
            label: this.label, recordTypeApiName: this.recordTypeApiName})
            .then((result) => {
                // Show success message
                console.log(result);
                if(result == 204){
                    this.showToast('Success', 'El valor fue agregado correctamente', 'success');
                    this.showCreate = false;
                } else {
                    this.showToast('Warning', 'La transacción tuvo un error, consulte al administrador', 'Warning');
                }
            })
            .catch((error) => {
                // Show error message
                this.showToast('Error', 'Failed to update' + error, 'error');
                console.error(error);
            })
            .finally(() => { this.isLoading = false;if(!this.isWizard){window.location.reload()}}
        );
    }

    createNewFamily() {
        createNewFamilyByBrand({ globalPicklist: this.familiaGlobalPicklist, newValue: this.family, controllingFieldValue: this.group, recordTypeId: this.recordTypeId, recordTypeDescripton: this.recordTypeDescripton,
            label: this.label, recordTypeApiName: this.recordTypeApiName})
            .then((result) => {
                // Show success message
                console.log(result);
                if(result == 204){
                    this.showToast('Success', 'El valor fue agregado correctamente', 'success');
                    this.showCreate = false;
                } else {
                    this.showToast('Warning', 'La transacción en picklist Familia tuvo un error, consulte al administrador', 'Warning');
                }
            })
            .catch((error) => {
                // Show error message
                this.showToast('Error', 'Failed to update' + error, 'error');
                console.error(error);
            })
            .finally(() => { this.isLoading = false;if(!this.isWizard){window.location.reload()}}
        );
    }

    /*createNewCategory() {
        createNewPicklistValueWithoutControllingField({ picklistField: 'Categor_a_veh_culo', newValue: this.category})
            .then((result) => {
                // Show success message
                console.log(result);
                /*if(result == 204){
                    this.showToast('Success', 'El valor fue agregado correctamente', 'success');
                } else {
                    this.showToast('Warning', 'La transacción tuvo un error, consulte al administrador', 'Warning');
                }
            })
            .catch((error) => {
                // Show error message
                this.showToast('Error', 'Failed to update' + error, 'error');
                console.error(error);
            })
            .finally(() => { this.isLoading = false;}
        );
    }/*/


    //Helper functions

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

    createControllerValueMap(data) {
        const controllerMap = new Map();
        // Iterate over controllerValues and map to corresponding values
        Object.entries(data.controllerValues).forEach(([key, index]) => {
          // Find all values that match the validFor index
          const valueObjs = data.values.filter((item) => item.validFor.includes(index));
          // Store the array of values in the Map
          controllerMap.set(key, valueObjs.length > 0 ? valueObjs.map((obj) => obj.value) : null);
        });
        return controllerMap;
    }
      
    calculateCategoriasValues(brand) {
        this.categorias = [];
        // Get the array of values for the specified brand
        const values = this.categoryByBrand.get(brand);
      
        // If values exist, transform them into the { label: value, value: value } format
        if (values && values.length > 0) {
          this.categorias = values.map((value) => ({
            label: value,
            value: value,
          }));
        }
      
        // Add the "Agregar Nueva Categoría" option if typeForm is 'Categoria'
        if (this.typeForm === 'Categoria') {
          this.categorias.unshift({
            label: '*** Agregar Nuevo Tipo ***',
            value: '*** Agregar Nuevo Tipo ***',
          });
        }
    }

    calculateGruposValues(key) {
        this.grupos = [];
        // Get the array of values for the specified brand
        const values = this.groupByCategoria.get(key);
      
        // If values exist, transform them into the { label: value, value: value } format
        if (values && values.length > 0) {
          this.grupos = values.map((value) => ({
            label: value,
            value: value,
          }));
        }
      
        // Add the "Agregar Nueva Categoría" option if typeForm is 'Categoria'
        if (this.typeForm === 'Grupo') {
          this.grupos.unshift({
            label: '*** Agregar Nuevo Grupo ***',
            value: '*** Agregar Nuevo Grupo ***',
          });
        }
    }

    calculateFamilyValues(key) {
        this.familias = [];
        // Get the array of values for the specified brand
        const values = this.familyByGroup.get(key);
      
        // If values exist, transform them into the { label: value, value: value } format
        if (values && values.length > 0) {
          this.familias = values.map((value) => ({
            label: value,
            value: value,
          }));
        }
      
        // Add the "Agregar Nueva Familia" option if typeForm is 'Categoria'
        if (this.typeForm === 'Familia') {
          this.familias.unshift({
            label: '*** Agregar Nueva Familia ***',
            value: '*** Agregar Nueva Familia ***',
          });
        }
    }

    ///For wizard
    handlePrevious() {
        const previousEvent = new CustomEvent('previous', {
            detail: { step:  2}
        });
        this.dispatchEvent(previousEvent);
    }

    handleNext() {
        console.log('NEXT '+ this.curretStep);
        const nextEvent = new CustomEvent('next', {
            detail: { step: this.curretStep , brand: this.brand, category: this.category, group: this.group, family: this.family}
        });
        this.dispatchEvent(nextEvent);
    }

    handleReload() {
        window.location.reload();
    }

}