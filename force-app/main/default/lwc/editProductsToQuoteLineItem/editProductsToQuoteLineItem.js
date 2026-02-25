import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import saveLines from '@salesforce/apex/ProductControllerTwo.saveQuoteLineItems';
import getPriceAccess from '@salesforce/apex/ProductController.getPriceAccess';
import getBetaAccess from '@salesforce/apex/ProductController.getBetaAccess';
import getMOAccess from '@salesforce/apex/ProductControllerTwo.getMOAccess';
import getServereOrderResponse from '@salesforce/apex/ProductController.getServereOrderResponse';
import getQolis from '@salesforce/apex/ProductControllerTwo.getQolis';
import getAvailabilityQuote from '@salesforce/apex/ProductControllerTwo.getAvailabilityByQuote';
import deleteQolis from '@salesforce/apex/ProductControllerTwo.deleteQlis';

const COLSSPECIALORDER = [
    { label: 'CÓDIGO', fieldName: 'ProductCode', type: 'text' },
    { label: 'PRODUCTO', fieldName: 'Name', type: 'text' },
    { label: 'LOCALIZACIÓN', fieldName: 'location', type: 'text' },
    { label: 'CANTIDAD SOFTLAND', fieldName: 'softlandQuantity', type: 'text' },
    { label: 'CANTIDAD SOLICITADA', fieldName: 'cantidad', type: 'text' },
];

export default class EditProductsToQuoteLineItem extends NavigationMixin(LightningElement) {
    /* Variables */
    @api propertyValue="checkbox-unique-id-81";
    @api lines;
    @track modifiedList;
    @api quoteids;
    @api productids;
    @api recid;
    @api isLoaded = false;
    cols = COLSSPECIALORDER;
    modifiedIds;
    deleteLines = [];
    deleteQlis = [];
    specialQuoteIds = [];
    @track specialQuotes = [];
    specialQuoteQuantity = 0;
    showDelete = false;
    showRealAvailability=false;
    showReserveButton=false;
    showReserveWarning=false;
    showPreview=false;
    showModal=false;
    saveOnline=false;
    showModifiedUnitPrice=false;
    accessModifiedSalesPrice=false;
    accessModifiedMOPrice=false;
    showBetaStuff=false;
    alreadyGetLines=false;
    montototal=0;
    currency='CRC';
    idQuote;
    result;
    error;
    _title = '';
    message = '';
    variant = 'error';
    mode = 'dismissible';
    variantOptions = [
        { label: 'error', value: 'error' },
        { label: 'warning', value: 'warning' },
        { label: 'success', value: 'success' },
        { label: 'info', value: 'info' },
    ];

    /* Wired functions */


    /*  Init Callback function */
    connectedCallback(){
        console.log('Entra a connected callback');
        let tempPickList = JSON.parse(JSON.stringify(this.lines));
        tempPickList.map(e => {
            if(e.productType == 'Material'){
                e.productType = 'Materiales';
            }
            if( e.productType == 'Mano de Obra'){
                e.cantidadDisponible = 1000;
            }
            this.currency = e.currencyCode;
        })
        console.log("Lista a modificar");
        console.log(tempPickList);
        
        this.modifiedList = tempPickList;

        let tempIdList = JSON.parse(JSON.stringify(this.quoteids));
        this.modifiedIds = tempIdList;
        console.log('tempIdList' + tempIdList);
        this.setMontoTotal();
        this.showReserveButton = true;
        console.log('Reach handleAccess');
        this.handleAccess();
    }

    /* Handle Functions */
    handleAccess(){
        // get Can_edit_sale_price__c permission from current user
        getPriceAccess()
        .then((result) => {
            this.accessModifiedSalesPrice = result;
            this.showModifiedUnitPrice = this.accessModifiedMOPrice || this.accessModifiedSalesPrice;
            console.log('accessModifiedSalesPrice: ' + result);
            console.log('Result showModifiedUnitPrice: ' + this.showModifiedUnitPrice);
        })
        .catch((error) => {
            console.log('Error in getPriceAccess: ' + error);
        });
        // get Can_edit_MO_price__c permission from current user
        getMOAccess()
        .then((result) => {
            this.accessModifiedMOPrice=result;
            this.showModifiedUnitPrice = this.accessModifiedMOPrice || this.accessModifiedSalesPrice;
            console.log('accessModifiedMOPrice: ' + result);
            console.log('Result showModifiedUnitPrice: ' + this.showModifiedUnitPrice);
        })
        .catch((error) => {
            console.log(error);
        });
        //get is_Beta_Tester__c permission from current user
        getBetaAccess()
        .then((result) => {
            //this.showBetaStuff=true;
            this.showBetaStuff=result;
            console.log(result);
        })
        .catch((error) => {
            console.log(error);  
        });
    }

    handleAlias(event){
        var modifiedIndex = this.quoteids.indexOf(event.currentTarget.dataset.id);
        this.modifiedList[modifiedIndex].alias = event.currentTarget.value;
    }

    handleQuantity(event){
        var modifiedIndex = this.quoteids.indexOf(event.currentTarget.dataset.id);
        this.modifiedList[modifiedIndex].cantidad = event.detail.value;
        this.setMontoTotal();
    }

    handleQuantityValidation(event){
        var specialQuotesList = JSON.parse(JSON.stringify(this.specialQuotes));
        var modifiedIndex = this.quoteids.indexOf(event.currentTarget.dataset.id);
        var oliUpdated = this.modifiedList[modifiedIndex];
        var deleteSpecialIndex = this.specialQuoteIds.indexOf(event.currentTarget.dataset.id);
        if (!this.showReserveButton && !oliUpdated.productType.toLowerCase().includes('mano de obra')){
            if(oliUpdated.cantidad > oliUpdated.softlandQuantity && oliUpdated.cantidad != 0){
                this.template.querySelector('[data-id="' + event.currentTarget.dataset.id + '"]').className = 'redClass';
                this.setMessageShow('ADVERTENCIA:','Este artículo no tiene existencias en la localización seleccionada.','warning');
                if(deleteSpecialIndex === -1){
                    this.specialQuoteIds.push(event.currentTarget.dataset.id);
                    specialQuotesList.push(oliUpdated);
                }
            }else{
                if(deleteSpecialIndex > -1){
                    specialQuotesList.splice(deleteSpecialIndex, 1);
                    this.specialQuoteIds.splice(deleteSpecialIndex, 1);
                }
                this.template.querySelector('[data-id="'+event.currentTarget.dataset.id+'"]').className='greenClass';
            }
            this.specialQuotes = specialQuotesList;
            this.handleSpecialQuoteLength();
        }
    }

    handleSpecialQuoteLength(){
        this.specialQuoteQuantity = this.specialQuoteIds.length;
        if(this.specialQuoteQuantity > 0) this.template.querySelector('[data-label="quoteQuantity"]').classList.remove('d-none');
        else this.template.querySelector('[data-label="quoteQuantity"]').className = 'd-none';
    }

    handleSalePrice(event) {
        // this.modifiedList=this.test;
        console.log(event.detail.value);
        var modifiedIndex = this.quoteids.indexOf(event.currentTarget.dataset.id);
        console.log('modified price product type: ' + this.modifiedList[modifiedIndex].productType);
        if(this.modifiedList[modifiedIndex].productType === 'Mano de Obra' && this.accessModifiedMOPrice) this.modifiedList[modifiedIndex].unitPrice = event.detail.value;
        if(this.modifiedList[modifiedIndex].productType !== 'Mano de Obra' && this.accessModifiedSalesPrice) this.modifiedList[modifiedIndex].unitPrice = event.detail.value;
        this.setMontoTotal();
    }

    handleDiscount(event){
        var modifiedIndex = this.quoteids.indexOf(event.currentTarget.dataset.id);
        this.modifiedList[modifiedIndex].discount = event.detail.value;
        this.setMontoTotal();
    }

    handleApproval(event){
        var modifiedIndex = this.quoteids.indexOf(event.currentTarget.dataset.id);
        this.modifiedList[modifiedIndex].aprobado = event.detail.checked;
    }

    handleSaveOnline(){
        //this.saveOnline=true;
        this.handleSave();
    }

    handleshowReserveWarning(){
        this.showReserveWarning=this.specialQuoteQuantity > 0;
        this.showModal=this.showReserveWarning;
        if(!this.showReserveWarning){
            this.handleSaveOnline();
        }
    }

    handleshowSpecialPreview(){
        if(this.specialQuoteQuantity > 0){
            this.showPreview=true;
            this.showModal=this.showPreview;
        }
    }

    handleDeleteLine(event) {
        //this.dispatchEvent(new CustomEvent('deleteline'));
        var listaIds;
        var records;
        const lines = 5;//event.target.dataset.factor;
        this.deleteLines.forEach(currentItem => {
            //console.log("Eliminanod"+currentItem);
            this.modifiedList.splice(this.modifiedIds.indexOf(currentItem), 1);
            this.modifiedIds.splice(this.modifiedIds.indexOf(currentItem), 1);
   
        });
        //console.log("Lista después"+this.modifiedIds);
        //this.deleteLines = [];
        this.showDelete = (this.deleteLines.length > 0);
        // console.log('Before dispatchEvent');
        // this.dispatchEvent(new CustomEvent('deleteline', {
        //     detail : {
        //         deletedRecords : this.modifiedList, 
        //         deletedIds : this.modifiedIds
        //     }
        // }));

        //this.deleteQlis = this.deleteLines;
        console.log('deleteQlis: ' + this.deleteQlis + ' length: ' + this.deleteQlis.length);
        if(this.deleteQlis.length > 0){
            console.log('Eliminando '+this.deleteQlis.length+ 'wolis');
            this.deleteQlisUI();
        }
    }

    handlecheck(event){
        var indexes;
        var modifiedIndex=this.quoteids.indexOf(event.currentTarget.dataset.id);
        console.log("modifiedIndex in handle check -> " + modifiedIndex);
        if(event.target.checked){
            this.deleteLines.push(event.currentTarget.dataset.id);
            console.log("Id Qli in check: " + (this.modifiedList[modifiedIndex].qliId));
            if(this.modifiedList[modifiedIndex].qliId){
                this.deleteQlis.push(this.modifiedList[modifiedIndex].qliId);
            }
        }else{
            modifiedIndex = this.deleteLines.indexOf(event.currentTarget.dataset.id);
            this.deleteLines.splice(modifiedIndex, 1);
            modifiedIndex = this.deleteQlis.indexOf(event.currentTarget.dataset.id);
            this.deleteQlis.splice(modifiedIndex, 1);
        }
        this.showDelete = (this.deleteLines.length > 0);
        indexes = this.deleteLines;
        console.log('JSON.stringify(this.deleteQlis)');
        console.log(JSON.stringify(this.deleteQlis));
    }

    navigateToRelatedList() {
        // Navigate to the Quote Comments related list page
        // for a specific Quote record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recid,
                objectApiName: 'Quote',
                relationshipApiName: 'QuoteLineItems',
                actionName: 'view'
            }
        });
    }

    navigateToQuote(){
        // Navigate to the Quote related list page
        // for a specific Quote record.
        console.log('redirecting ' + this.idQuote);
        //this.serverResponse();
        this[NavigationMixin.Navigate]({
            type : 'standard__recordPage',
            attributes : {
                recordId : this.recid,
                objectApiName : 'Quote',
                actionName : 'view'
            }
        });
    }

    setRealVailability(){
        var error=false;
        var errorMsg=' ';
        this.showRealAvailability=true;
        this.modifiedList.forEach(currentItem => {
            if(currentItem.productType != undefined){
                if(!currentItem.productType.toLowerCase().includes('mano de obra')){
                    if(!currentItem.validated){             
                        this.template.querySelector('[data-id="'+currentItem.ID+'"]').className='warningClass';
                    }else if(currentItem.available){
                        this.template.querySelector('[data-id="'+currentItem.ID+'"]').className='greenClass';
                        this.showReserveButton=false;
                    }else{
                        this.template.querySelector('[data-id="'+currentItem.ID+'"]').className='redClass';
                        if(this.specialQuoteIds.indexOf(currentItem.ID)===-1){
                            this.specialQuoteIds.push(currentItem.ID);
                            this.specialQuotes.push(currentItem);
                            this.handleSpecialQuoteLength();
                        }
                    }
                }
            }else{
                error=true;
                errorMsg=errorMsg+' '+currentItem.ProductCode+',';
            } 
        });
        if(!error){
            if(this.specialQuoteQuantity > 0){
                this.setMessageShow('ADVERTENCIA','Los artículos no tienen existencias en la localización seleccionada.','warning');
            }
        }else{
            this.setMessageShow('ERROR DE CONFIGURACIÓN','Los siguientes articulos'+errorMsg+' no tienen definido el Tipo de Producto','error');
        }
        //Solicitud Odette Aparicio 8/17/2022
        this.showReserveButton=error;//Se elimina validación de que todos los productos deben estar disponibles en softland
        //console.log(this.template.querySelectorAll('[data-label="DisponibleReal"]'));
    }

    setMontoTotal(){
        var monto = 0;
        var montoLinea
        console.log('modifiedList in setMontoTotal: ' + this.modifiedList);
        this.modifiedList.forEach(currentItem => {
            montoLinea = (currentItem.cantidad * currentItem.unitPrice);
            if(currentItem.discount != undefined) montoLinea = montoLinea - (montoLinea * (currentItem.discount)/100);
            monto = monto + montoLinea;
            console.log('valor foreach cantidad: ' + currentItem.cantidad + ' monto: ' + currentItem.unitPrice + ' discount: ' + currentItem.discount);
        });
        var formatter = new Intl.NumberFormat('en-US', {
            style : 'currency',
            currency : this.currency

            // These options are needed to round to whole numbers if that's what you want.
            //minimumFractionDigits: 0, // (this suffices for whole numbers, but will print 2500.10 as $2,500.1)
            //maximumFractionDigits: 0, // (causes 2500.99 to be printed as $2,501)
        });
        this.montototal = formatter.format(monto);
    }

    closeReservar(){
        this.showReserveWarning=false;
        this.showPreview=false;
        this.showModal=false;
    }

    handleLocation(event){
        var newLocation = event.detail.value;
        var modifiedIndex = this.quoteids.indexOf(event.currentTarget.dataset.id);
        console.log(modifiedIndex);
        this.modifiedList[modifiedIndex].softlandQuantity = this.modifiedList[modifiedIndex].softlandQuantities[this.modifiedList[modifiedIndex].locations.indexOf(newLocation)];
        this.modifiedList[modifiedIndex].locations = newLocation;
        this.handleQuantityValidation(event);
    }

    // change isLoaded to the opposite of its current value
    toggle() {
        this.isLoaded = !this.isLoaded;
    }

    setQuoteLisIds(){
        var tempIds = [];
        this.lines.forEach(currentItem => {
            tempIds.push(currentItem.ID);
        });
        this.quoteids = JSON.parse(JSON.stringify(tempIds));
    }

    setMessageShow(title, message, variant){
        this._title = title;
        this.message = message;
        this.variant = variant;
        if(this.variant === 'error' || this.variant === 'warning'){
            this.mode = 'sticky';
        }else{this.mode = 'dismissible'}
        this.showNotification();
    }

    showNotification(){
        const evt = new ShowToastEvent({
            title : this._title,
            message : this.message,
            variant : this.variant,
            mode : this.mode 
        });
        this.dispatchEvent(evt);
    }

    /* Apex Calls */
    @api async handleSave(){
        this.closeReservar();
        this.toggle();
        console.log('Save');
        console.log(this.modifiedList);
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if(allValid){
            saveLines({ listTosave : JSON.stringify(this.modifiedList), quoteId : this.recid, saveOnline:this.saveOnline}) 
            .then((result) => {
                console.log('result succes in save line: ' + result);
                this.idQuote=result;
                // if(this.saveOnline)
                // {
                    this._title = 'Success!';
                    this.message = 'Las líneas de la orden fueron guardadas';
                    this.variant = 'success';
                    this.showNotification();
                    const pageRefresh = window.location.origin + '/lightning/r/Quote/' + this.recid + '/related/QuoteLineItems/view';
                    window.location.replace(pageRefresh);
                    console.log('PageRefreshed');
                    //eval("$A.get('e.force:refreshView').fire();");
                // }
                // else
                // {
                //     //Reservar Online con 10s de espera en respuesta
                //     setTimeout(this.navigateToQuote.bind(this),10000)
                // }
            })
            .catch((error) => {
                console.log(error);
                console.log(error.body.pageErrors[0].message);
                this.toggle();
                this.saveOnline=false;
                var message = error.body.pageErrors[0].message;
                this.error = error;
                this._title = 'Ups!';
                this.message = 'Algo no salió bien en SaveLine, consulte su administrador';
                if(message){
                    this._title  = message;
                    this.message='';
                }
                this.setMessageShow(this._title ,this.message,'error')                           
                this.showNotification();  
            });
        }else{
            this.toggle();
            this._title = 'Error!';
            this.variant = 'error';
            this.message = 'Revise los campos señalados en ROJO';
            this.showNotification();
            //this.showErrorMessage=true;
            //alert('Please update the invalid form entries and try again.');
        }
    }

    @api async deleteQlisUI() {
        console.log('Entra a deleteQlisUI de delete!!!!');
        this.toggle();
        deleteQolis({ listToDelete: JSON.stringify(this.deleteQlis)}) 
        .then((result) => {
            console.log(result);
            this.setMessageShow('Success!','Se eliminaron correctamente las líneas','success'); 
        })
        .catch((error) => {
            this.error = error;
            this._title = 'Intentelo nuevamente!';
            this.message = 'Algo no salió bien, no se pudo eliminar la(s) líneas';
            this.variant = 'warning';                            
            this.showNotification();
            console.log(error);
        })
        .finally(() => {
        // console.log('Finally'); // Finally
            this.setRealVailability();
            this.toggle();
        });
    }

    serverResponse(){
        getServereOrderResponse({order : this.idQuote})
        .then((result) => {
            console.log(result);
            if(result === null) this.setMessageShow('No se tiene respuesta de Softland','Espere unos minutos y  refresque utilizando el botón del pedido "REFRESCAR"','warning');
            else if(result.includes('OSLU')) this.setMessageShow('Respuesta de Softland CORRECTA',result,'success');
            else if(result.toLowerCase().includes('error')) this.setMessageShow('ERROR en el pedido',result,'error');
        })
        .catch((error) => {
            this.error = error;
            this._title = 'Ups!';
            this.message = 'Algo no salió bien, no se pudo conectar con Softland';
            this.variant = 'warning';
            this.showNotification();
            console.log("Error in serverResponse: " + error);
        })
        .finally(() => {
            try{
                setTimeout(location.reload().bind(this),20000);
            }catch{
                console.log("error in finally ServerConnect");
            }
        });
    }

    handleGetQolis(){
        this.toggle();
        getQolis({ listTosave : JSON.stringify(this.modifiedList), quoteId : this.recid})
        .then((result) => {
            this._title = 'Success!';
            this.message = 'Las líneas se obtuvieron correctamente!';
            this.variant = 'success';
            this.alreadyGetLines=true;
            this.showNotification();
            this.lines = JSON.parse(JSON.stringify(result));
            this.setQuoteLisIds();
            this.connectedCallback();
            console.log(this.lines);
            this.modifiedList.forEach(currentItem => {
                currentItem.picklistLocation=([{label : currentItem.location, value : currentItem.location }]);
            });
        })
        .catch((error) => {
            this.error = error;
            this._title = 'Ups!';
            this.message = 'Algo no salió bien, no se pudieron obtener las líneas de la Work Order';
            this.variant = 'warning';                            
            this.showNotification();
            console.log(error);
        })
        .finally(() => {
            this.setRealVailability();
            this.toggle();
        });
    }

    redStyle='';
    greenStyle='';
    mapData= [];
    validateProducts(){
        this.showRealAvailability=false;
        this.toggle();
        getAvailabilityQuote({ listTosave: JSON.stringify(this.modifiedList), quoteId : this.recid}) 
        .then((result) => {
            this._title = 'Verificación con Softland correcta';
            this.message = 'Los productos marcados en ROJO no están disponibles';
            this.variant = 'success';
            this.showNotification();
            //this.handleResetAll();
            this.modifiedList = JSON.parse(JSON.stringify(result));
            console.log(result);
            //console.log(result[0].quantityByLocation.keys());
            var locations;
            this.modifiedList.forEach(currentItem => {
                locations=[];
                for(var key in currentItem.quantityByLocation){
                    locations.push({label : key, value : key });
                    this.mapData.push({label : key, value : key });
                }
                currentItem.picklistLocation = locations;
                currentItem.softlandQuantity = currentItem.softlandQuantities[currentItem.locations.indexOf(currentItem.location)];
                currentItem.available = currentItem.softlandQuantity>=currentItem.cantidad;
            });
            //console.log('WHAAT');
            console.log(JSON.parse(JSON.stringify(this.modifiedList)));
        })
        .catch((error) => {
            this.error = error;
            this._title = 'Ups!';
            this.message = 'Algo no salió bien, no se pudo conectar con Softland';
            this.variant = 'warning';                            
            this.showNotification();
            console.log(error);
        })
        .finally(() => {
            // console.log('Finally'); // Finally
            this.setRealVailability();
            this.toggle();
        });
    }

}