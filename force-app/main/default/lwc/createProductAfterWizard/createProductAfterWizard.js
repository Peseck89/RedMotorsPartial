import { LightningElement, api, track } from 'lwc';
import createProduct from '@salesforce/apex/CreateProductAfterWizardController.createProduct';
import createNewModeloByFamilia from '@salesforce/apex/CreateProductAfterWizardController.createNewModeloByFamilia';
import getPricebook from '@salesforce/apex/CreateProductAfterWizardController.getPricebook';
import createPBEntry from '@salesforce/apex/CreateProductAfterWizardController.createPBEntry';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class CreateProductAfterWizard extends NavigationMixin(LightningElement)  {
    recordId;
    priceBookId = null;
    @api recordTypeId;
    @api recordTypeDescripton;
    @api label;
    @api recordTypeApiName;
    @api brand;
    @api category;
    @api group;
    @api family;
    //name = 'Name';
    @track productObject = {
        RecordTypeId: null,
        Marca__c: null,
        Categor_a_veh_culo__c: null,
        Grupo__c: null,
        Familia__c: null,
        Modelo_De_Inter_s__c: null,
        Codigo_de_Producto__c: null,
        Name: null,
        Codigo_Info__c: null,
        Description: null,
        Se_Muestra_en_Sitio__c: false,
        Nombre_Digital__c: null,
        Orden_Sitio_Web__c: null,
        IsActive : false


    };

    @track priceBookObject = {
        Description: null,
        Name: null,
        IsActive: true
    };
    pb2Name = '';
    createPricebook = false;

    @track entryObject = {
        Vendedor__c: null,
        Gerente__c: null,
        Jefe__c: null,
        Costo_Fijo__c: null,
        UnitPrice: null,
        Pricebook2Id: null,
        Product2Id: null,
        IsActive: true
    };

    //toogle render
    showMdi = true;
    isLoading = false;
    isCreatingProduct = true;
    disableButton = false;

    buttonText = "Crear Producto";

    connectedCallback(){
        if(this.productObject.RecordTypeId === null){
            this.productObject.RecordTypeId = this.recordTypeId;
            this.productObject.Marca__c = this.brand;
            this.productObject.Categor_a_veh_culo__c = this.category;
            this.productObject.Grupo__c = this.group;
            this.productObject.Familia__c = this.family;
        }
        if(this.priceBookId === null){
            this.getPricebookbyBrand();
        }
    }

    get acceptedFormats() {
        return [".pdf"];
    }

    handleFieldChange(event) {
        // Get the data-id of the triggering element
        const fieldId = event.target.dataset.id;
        const value = event.detail.value;

        // Log the fieldId and value for debugging
        console.log(`Field ID: ${fieldId}, Value: ${value}`);

        // Update the corresponding key in the productObject
        if (fieldId in this.productObject) {
            this.productObject[fieldId] = value;
            if(fieldId === "Name"){
                this.productObject.Modelo_De_Inter_s__c = value;
            }
        } else {
            console.warn(`Unhandled field: ${fieldId}`);
        }

        // Log the updated productObject for debugging
        let obs = JSON.parse(JSON.stringify(this.productObject));
        console.log('Updated productObject:', obs);
    }

    handleEntryFieldChange(event) {
        // Get the data-id of the triggering element
        const fieldId = event.target.dataset.id;
        const value = event.detail.value;

        // Log the fieldId and value for debugging
        console.log(`Field ID: ${fieldId}, Value: ${value}`);

        // Update the corresponding key in the productObject
        if (fieldId in this.entryObject && fieldId != 'Pricebook2Id') {
            this.entryObject[fieldId] = value;
        }else if(fieldId === 'Pricebook2Id'){
            console.log('Change Pricebook');
            this.entryObject.Pricebook2Id = value[0];
        } else {
            console.warn(`Unhandled field: ${fieldId}`);
        }

        // Log the updated productObject for debugging
        let obs = JSON.parse(JSON.stringify(this.entryObject));
        console.log('Updated productObject:', obs);
    }

    handleCreateProduct(){
        if(!this.recordId){
            this.createNewMDI();
        }
        else{
            this.navigateToRecord(this.recordId);
        }
    }

    handleUploadFinished(){
        this.isCreatingProduct = true;
        this.disableButton = false;
    }

    navigateToRecord(recordId) {
        // Use NavigationMixin to navigate to the record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Product2', // Object API Name
                actionName: 'view'
            }
        });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    //Server Calls
    createNewMDI() {
        this.isLoading = true;
        createNewModeloByFamilia({ brand: this.brand, globalPicklist: 'Modelo_de_Interes2', newValue: this.productObject.Name, controllingFieldValue: this.family, recordTypeId: this.recordTypeId, recordTypeDescripton: this.recordTypeDescripton,
            label: this.label, recordTypeApiName: this.recordTypeApiName})
            .then((result) => {
                console.log('MDI RESULT');
                console.log(result);
                // Show success message
                if(result == 204){
                    console.log('Valor picklistCreado MDI ahora producto');
                    this.createProduct2();
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
    }

   createProduct2() {
    const productJson = JSON.stringify(this.productObject);

    createProduct({ productJson: productJson })
        .then((result) => {
            if (result.success) {
                // Éxito: Mostrar mensaje y continuar
                this.showToast('Success', 'Se creó correctamente el producto!', 'success');
                this.recordId = result.recordId;
                this.entryObject.Product2Id = this.recordId;
                
                if (this.recordId) {
                    this.disableButton = true;
                    this.buttonText = 'Ver el Producto Creado';
                    this.isCreatingProduct = false;
                }
                this.createPBEntry(); // Continuar con el siguiente paso
            } else {
                // Error: Mostrar el mensaje específico del flujo
                this.showToast('Error', result.errorMessage, 'error'); // <<-- Aquí se muestra el error de validación
            }
            this.isLoading = false;
        })
        .catch((error) => {
            // Errores inesperados (ej: falla en la llamada Apex)
            this.showToast('Error', 'Error al conectar con el servidor.', 'error');
            console.error('Error:', error);
        });
}

    createPBEntry() {
        // Convert the productObject to JSON
        const json = JSON.stringify(this.entryObject);
        console.log(this.createPricebook);
        // Call the Apex method
        createPBEntry({ pricebookJson: JSON.stringify(this.priceBookObject),pentryJson: json, createPricebook: this.createPricebook })
            .then((result) => {
                if (result) {
                    // Apex call was successful
                    this.showToast('Success', 'Se creó correctamente la lista de precio!', 'success');
                    //this.handleSuccess(); // Call another method if needed
                } else {
                    // Handle the case where the Apex method returns false
                    this.showToast('Error', 'Falló la creación de lista de precio para el producto', 'error');
                }
            })
            .catch((error) => {
                // Handle any errors from the Apex call
                this.showToast('Server Error', 'Falló la creación de lista de precio para el producto', 'error');
                console.error('Error:', error);
            });
    }


    getPricebookbyBrand() {
        // Convert the productObject to JSON
        const productJson = JSON.stringify(this.productObject);

        // Call the Apex method
        getPricebook({ brand: this.brand })
            .then((result) => {
                if (result) {
                    // Apex call was successful
                    console.log(result);
                    if(result != 'null'){
                        this.priceBookId = result;
                        this.entryObject.Pricebook2Id = result;
                    } else{
                        this.createPricebook = true;
                        this.showToast('Warning', 'No se encontró Pricebook para esta marca: '+ this.brand, 'Warning');
                        this.priceBookObject.Name = this.brand + ' - ' + new Date().getFullYear();
                        this.priceBookObject.Description = this.priceBookObject.Name;
                        this.pb2Name = this.priceBookObject.Name;
                        console.log(JSON.parse(JSON.stringify(this.priceBookObject)));
                    }
                } else {
                    // Handle the case where the Apex method returns false
                    this.showToast('Error', 'Failed ', 'error');
                }
            })
            .catch((error) => {
                console.error('Error:', error);
            });
    }
}