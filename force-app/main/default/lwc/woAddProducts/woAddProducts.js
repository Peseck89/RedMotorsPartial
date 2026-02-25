import { LightningElement, api, track, wire } from 'lwc';
import {loadStyle} from 'lightning/platformResourceLoader';
import screenActionCss from '@salesforce/resourceUrl/ScreenQuickActionLwc' 
import searchProducts from "@salesforce/apex/WoliGridController.searchProducts";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveLines from '@salesforce/apex/WoliGridController.saveWolis';
import getTrabajos from '@salesforce/apex/WoliGridController.getTiposDeTrabajo';
import getWolis from '@salesforce/apex/WoliGridController.getWolis';
import deleteWolis from '@salesforce/apex/WoliGridController.deleteWolis';

import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import WorkOrderLineItem_object from '@salesforce/schema/WorkOrderLineItem';
import Id from '@salesforce/user/Id';
import CanDeleteWolis__c from '@salesforce/schema/User.CanDeleteWolis__c';
import CanDeleteWolisMo__c from '@salesforce/schema/User.CanDeleteWolisMo__c';
import CanEditSalePrice__c from '@salesforce/schema/User.Can_edit_sale_price__c';
import CanEditMOPrice__c from '@salesforce/schema/User.Can_edit_MO_price__c';
import WorkOrderNumber from '@salesforce/schema/WorkOrder.WorkOrderNumber';


export default class WoAddProducts extends LightningElement {
    @api recordId;
    @track modifiedList = [];
    linesIds = ['search'];
    @track deletelines = [];
    @track deleteWolis = [];
    @track tiposTrabajoOptions = [];

    //Permissions
    userId = Id;
    CanDeleteWolis__c;
    CanDeleteWolisMo__c;
    CanEditSalePrice__c;
    CanEditMOPrice__c;
    WorkOrderNumber;

    //Flags
    showDelete = false;
    showSearchModal = false;
    showMoveLines = false;
    alreadyGetLines = false;

    //SearchText
    emptyObject = {"isSearch": true, "aprobado": false, "Bodega": "", "bodegaID": "", "cantidad": 1, "cantidadDevolucion": 0, "cantidadDisponible": 0, "currencyCode": "", "despachoEmail": "", "discount": 0, "esKit": false, "estadoEntrega": "", "estadoReserva": "", "estadoSoftland": "", "ID": "search", "idExtBodega": "", "isClosed": false, "locations": [], "Name": "", "precio": 0, "priceBookEntry": "", "ProductCode": "", "productId": "", "productType": "", "ProductXBodegaID": "", "quantityByLocation": {}, "softlandQuantities": [], "softlandQuantity": 0, "unitPrice": 0, "validated": false, "wolId": "", "isMO": false, "CanDeleteWolis__c": false, bodegas:[] };
    searchInput = '';

    //Maps
    tiposTrabajoMap;

    //Excluded Types
    excludedTypes = ['mano de obra', 'subcontrato'];

    //Monto Total
    montoTotal = 0;
    currencyCode;

    /*Wired functions*/
    @wire(getRecord, { recordId: Id, fields: [CanDeleteWolis__c,CanDeleteWolisMo__c,CanEditMOPrice__c,CanEditSalePrice__c]}) 
    userDetails({error, data}) {
        if (data) {
            //console.log(data);
            this.CanDeleteWolis__c = data.fields.CanDeleteWolis__c.value;
            this.CanDeleteWolisMo__c = data.fields.CanDeleteWolisMo__c.value;
            this.CanEditMOPrice__c = data.fields.Can_edit_MO_price__c.value;
            this.CanEditSalePrice__c = data.fields.Can_edit_sale_price__c.value;
        } else if (error) {
            this.error = error ;
        }
    }

    connectedCallback(){
       
        this.modifiedList = [this.emptyObject];
        this.getTiposTrabajo();
        loadStyle(this, screenActionCss);
    }

    handleSearchText(event){
        this.modifiedList[0].ProductCode = event.currentTarget.value;
        this.searchInput = event.currentTarget.value;//event.target.value
    }

    handleSearch(){
        console.log(JSON.stringify(this.modifiedList));
        let searchinput = this.searchInput;//event.target.value
        searchProducts({
        productType: '',
        queryValue: searchinput,
        workOrder: this.recordId
        })
        .then((result) => {
            //this.bodegasCols.clear();
            //console.log(JSON.stringify(result));
            //Change this to helper function 
            let tmpObject = result[0];
            tmpObject.ID = tmpObject.ID + this.modifiedList.length;
            //console.log(JSON.stringify(tmpObject));
            //tmpObject.CanDeleteWolis__c = true;
            this.validateUserAccess(tmpObject);
            this.updateBodegaAndCantidadDisponible(tmpObject);
            this.updateLocationsForObject(tmpObject);
            //console.log(JSON.stringify(tmpObject));
            this.modifiedList.push(tmpObject);
            this.linesIds = this.extractIDs(this.modifiedList);
            this.calculateMontoTotal();

        })
        .catch((error) => {
            this.error = error;
            this.productListResponse = undefined;
        });
    }

    handleGetWolis(){
        let lines = this.modifiedList.filter(obj => obj.ID !== "search");
        getWolis({ listTosave: JSON.stringify(lines), workorder:this.recordId})
                            .then((result) => {
                            console.log(JSON.parse(JSON.stringify(result)));
                            this.alreadyGetLines = true;
                            this.modifiedList = JSON.parse(JSON.stringify(result));
                            this.modifiedList.unshift(this.emptyObject);
                            this.linesIds = this.extractIDs(this.modifiedList);
                            
                            this.updateLocations(this.modifiedList);
                            this.setMessageShow('Success!','Las líneas se obtuvieron correctamente!','success');
                            //this.connectedCallback();
                            //console.log(this.lines);
                            this.modifiedList.forEach(currentItem => {
                                currentItem.isClosed = currentItem.isClosed ? currentItem.isClosed : currentItem.aprobadoService === 'Aprobado';
                                this.validateUserAccess(currentItem);
                            });
                           
                            
                            })
                            .catch((error) => {
                                this.setMessageShow('Ups!', 'Algo no salió bien, no se pudieron obtener las líneas de la Work Order','warning');
                                console.log(error);
                        })
                        .finally(() => {
                            this.showReserveButton = true;
                            this.calculateMontoTotal();
                         });
    }

    async deleteWolisUI() {
        deleteWolis({ workorderIds: JSON.stringify(this.deleteWolis)}) 
                                .then((result) => {
                                this.setMessageShow('Success!','Se eliminaron correctamente las líneas','success');
                                })
                                .catch((error) => {                      
                                    this.setMessageShow('Error!','Algo no salió bien, no se pudo eliminar la(s) líneas','error');
                                    console.log(error);
                            })
    }

    getTiposTrabajo(){
        getTrabajos({workorder: this.recordId})
        .then((result) => {
            const mapWorks = new Map();
            /*console.log('TIPOS DE TRBAJO');
            console.log(JSON.parse(JSON.stringify(result)));*/
            let tiposTrabajo = JSON.parse(JSON.stringify(result));
            this.tiposTrabajoOptions = this.getTrabajoOptions(tiposTrabajo);
            tiposTrabajo.forEach(item => {
                mapWorks.set(item.Id, item.Tipotrabajo__c);
            });
            this.tiposTrabajoMap =  mapWorks;
           // console.log(this.tiposTrabajoMap.get('a2iEi000001pnqvIAA'));

        })
        .catch((error) => {
            console.log(error);
        });
    }

    handleDeleteLine(event) {
        this.deletelines.forEach(currentItem => {
            this.modifiedList.splice(this.linesIds.indexOf(currentItem), 1);
            this.linesIds.splice(this.linesIds.indexOf(currentItem), 1);
   
        });
        this.deletelines=[];
        this.showDelete=(this.deletelines.length>0);


        if(this.deleteWolis.length > 0){
            console.log('Eliminando '+this.deleteWolis.length+ 'wolis');
            this.deleteWolisUI();
        }
        this.calculateMontoTotal();
        //this.handleSpecialOrderLength();*/
    }

    handlecheck(event) {
        console.log('modifiedIndex');
        console.log(event.currentTarget.dataset.id);
        var modifiedIndex = this.linesIds.indexOf(event.currentTarget.dataset.id); 
        //console.log(modifiedIndex);
        if(event.target.checked){
            this.deletelines.push(event.currentTarget.dataset.id);
            if(this.modifiedList[modifiedIndex].wolId){
                this.deleteWolis.push(this.modifiedList[modifiedIndex].wolId);
            }
            //console.log("Ingresamos a elimianr"+(modifiedIndex) );

        }else{
            modifiedIndex = this.deletelines.indexOf(event.currentTarget.dataset.id);
            //console.log("Quitamos de eliminar deletelines"+(modifiedIndex) );
            this.deletelines.splice(modifiedIndex, 1);
            modifiedIndex = this.deleteWolis.indexOf(event.currentTarget.dataset.id);
            this.deleteWolis.splice(modifiedIndex, 1);
        }
        this.showDelete=(this.deletelines.length > 0);
        this.showMoveLines = this.deletelines.length == 1;

    }

    handleBodegaSelect(event){
        var newLocation = event.detail.value;
        var modifiedIndex = this.linesIds.indexOf(event.currentTarget.dataset.id); 
        console.log(modifiedIndex + '  '+ newLocation);
        this.updateCantidadDisponibleForObject(this.modifiedList[modifiedIndex], newLocation);

    }

    handleTrabajoSelect(event){
        console.log(event.detail.value);
        let modifiedIndex = this.linesIds.indexOf(event.currentTarget.dataset.id); 
        this.modifiedList[modifiedIndex].TipoTrabajoCaso = event.detail.value;
        this.modifiedList[modifiedIndex].tiposDeTrabajo = this.tiposTrabajoMap.get(event.detail.value);
        console.log(JSON.parse(JSON.stringify(this.modifiedList)));
    }

    handleShowSearch(){
        this.showSearchModal=true;
    }

    
    handleCancelSearch(event){
        var message = event.detail.message;
        this.showSearchModal = false;
    }

    handleSalePrice(event) {
        // this.modifiedList=this.test;
         var modifiedIndex=this.linesIds.indexOf(event.currentTarget.dataset.id); 
         this.modifiedList[modifiedIndex].unitPrice=event.detail.value;
         this.calculateMontoTotal();
        
     }

    handleAlias(event) {
        // this.modifiedList=this.lines;
        //console.log(event.currentTarget.dataset.id);
         var modifiedIndex=this.linesIds.indexOf(event.currentTarget.dataset.id); 
         this.modifiedList[modifiedIndex].alias=event.currentTarget.value;
    }

    handleQuantity(event) {
         var modifiedIndex=this.linesIds.indexOf(event.currentTarget.dataset.id); 
         this.modifiedList[modifiedIndex].cantidad=event.detail.value;
         this.calculateMontoTotal();
     }

    handleAddLines(event) {
        const workOrderList = event.detail.message;
        console.log('Received workOrderList from child:', JSON.stringify(workOrderList));
        this.showSearchModal = false;
        this.updateBodegaAndCantidadDisponibleInList(workOrderList);
        this.updateLocations(workOrderList);
        this.modifiedList = [...this.modifiedList, ...workOrderList];
        this.linesIds = this.extractIDs(this.modifiedList);
        // Process the workOrderList as needed
        this.calculateMontoTotal();
    }
  

    @api async handleSave() {
        console.log('Save');
        const allValid = [
            ...this.template.querySelectorAll('lightning-input, lightning-combobox')
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
                if (allValid) {
                    let lines = this.modifiedList.filter(obj => obj.ID !== "search");
                    lines.forEach(item => {
                        delete item.locations;
                    });
                    console.log(JSON.stringify(lines));
                    saveLines({ jsonString : JSON.stringify(lines), workorder:this.recordId}) 
                            .then((result) => {
                                console.log(result);
                                this.navigateToOrder();
                                })
                            .catch((error) => {
                                console.log(error);
                                console.log(error.body.pageErrors[0].message);
                                
                                this.saveOnline=false;
                                let message = error.body.pageErrors[0].message;
                                this.error = error;
                                this._title = 'Ups!';
                                this.message = 'Algo no salió bien, consulte su administrador';
                                if(message){
                                    this._title  = message;
                                    this.message='';
                                }
                                this.setMessageShow(this._title ,this.message,'error')                           
                                this.showNotification();
                                
                            })
                            .finally(() => {
                            
                            });
                        
                } else {
                    this.setMessageShow('Error!' ,'Revise los campos señalados en ROJO','error')
                }

    }

    extractIDs(data) {
        return data.map(item => item.ID);
    }

    updateBodegaAndCantidadDisponibleInList(data) {
        // Loop through each object in the list
        data.forEach(obj => {
          // Find the principal bodega in the bodegas array of the current object
          const principalBodega = obj.bodegas.find(bodega => bodega.isPrincipal);
      
          if (principalBodega) {
            // Set the Bodega attribute to the name of the principal bodega
            obj.Bodega = principalBodega.name;
      
            // Set the cantidadDisponible attribute to the cantidadDisponible of the principal bodega
            obj.cantidadDisponible = principalBodega.cantidadDisponible;
          }
        });
      }

      updateLocationsForObject(item) {
        if(!this.excludedTypes.includes(item.productType.toLowerCase())){
            if (item && item.bodegas) {
                const hasUruca = item.bodegas.some(bodega => bodega.name.includes("Uruca"));
                item.locations = item.bodegas
                    .filter(bodega => bodega.isPrincipal || (hasUruca && bodega.name === "Bodega de Apartados"))
                    .map(bodega => ({
                        label: bodega.name,
                        value: bodega.name
                    }));
            }
        }
    }
    

    updateLocations(data) {
        data.forEach(item => {
            if(!this.excludedTypes.includes(item.productType.toLowerCase())){
                this.validateUserAccess(item);
                if (item && item.bodegas) {
                    const hasUruca = item.bodegas.some(bodega => bodega.name.includes("Uruca"));
                    item.locations = item.bodegas
                        .filter(bodega => bodega.isPrincipal || (hasUruca && bodega.name === "Bodega de Apartados"))
                        .map(bodega => ({
                            label: bodega.name,
                            value: bodega.name
                        }));
                }
            }
        });
    }
    
    /*updateLocations(data) {
        data.forEach(item => {
          this.validateUserAccess(item);
          item.locations =  item.bodegas.map(bodega => ({
            label: bodega.name,
            value: bodega.name
          }));
        });
    }*/

    /*updateLocationsForObject(item) {
        if (item && item.bodegas) {
          item.locations = item.bodegas.map(bodega => ({
            label: bodega.name,
            value: bodega.name
          }));
        }
    }*/

    updateBodegaAndCantidadDisponible(item){
        const principalBodega = item.bodegas.find(bodega => bodega.isPrincipal);
        if (principalBodega) {
          // Set the Bodega attribute to the name of the principal bodega
          item.Bodega = principalBodega.name;
      
          // Set the cantidadDisponible attribute to the cantidadDisponible of the principal bodega
          item.cantidadDisponible = principalBodega.cantidadDisponible;
        }
    }

    getTrabajoOptions(data) {
        return data.map(item => ({
            label: item.Tipotrabajo__r.Name,
            value: item.Id
        }));
    }

    updateCantidadDisponibleForObject(item, selectedBodegaName) {
        // Find the bodega with the matching name
        const selectedBodega = item.bodegas.find(bodega => bodega.name === selectedBodegaName);
        
        // If the bodega is found, update cantidadDisponible in the main object
        if (selectedBodega) {
            item.cantidadDisponible = selectedBodega.cantidadDisponible;
            item.bodegaID = selectedBodega.Id;
        }
        
        return item;
    }

    setMessageShow(title, message, variant) {
        const mode =
          this.variant === "error" || this.variant === "warning"
            ? "sticky"
            : "dismissible";
        const evt = new ShowToastEvent({
          title: title,
          message: message,
          variant: variant,
          mode: mode
        });
        this.dispatchEvent(evt);
      }

      navigateToOrder() {
        // Navigate to the CaseComments related list page
        // for a specific Case record.
        console.log('redirecting '+this.idOrder);
        //this.serverResponse();
        this.setMessageShow('Success!','Se guardaron correctamente las líneas','success');
        window.location.reload()
        
    }

    validateUserAccess(currentItem){
            if(currentItem.wolId){
                currentItem.CanDeleteWolis__c = (this.CanDeleteWolis__c && !((currentItem.estadoReserva === 'Reservado') || (currentItem.hasOwnProperty('estadoSolicitudCompra'))));
                if(currentItem.productType.toLowerCase()==='mano de obra'){
                    currentItem.CanDeleteWolis__c = this.CanDeleteWolisMo__c;
                }
            }else {
                currentItem.CanDeleteWolis__c = true;
            }
            currentItem.CanDeleteWolis__c = currentItem.isSearch ? false : currentItem.CanDeleteWolis__c;
            currentItem.disableQuantity = !currentItem.CanDeleteWolis__c || currentItem.isClosed;
            //JSON.parse(JSON.stringify(currentItem));
            this.validateEditSalesPriceUserAccess(currentItem);
    }

    validateEditSalesPriceUserAccess(currentItem){
        if(currentItem.productType.toLowerCase()==='mano de obra'){
            currentItem.canEditSalesPrice = currentItem.isClosed ? currentItem.isClosed : !this.CanEditMOPrice__c;
        }else{
            currentItem.canEditSalesPrice = currentItem.isClosed ? currentItem.isClosed : !this.CanEditSalePrice__c;
        }

    }


    handleMoveTop(){
        let originalPos = this.linesIds.indexOf(this.deletelines[0]);
        let desirePos = 1;
        console.log('Moving pos '+ originalPos + ' to desire pos '+desirePos);
        this.swapPositions(originalPos, desirePos, 'lines');
        this.swapPositions(originalPos, desirePos, 'id');
    }

    handleMoveUp(){
        /*console.log(JSON.stringify(this.deletelines));
        console.log(JSON.stringify(this.linesIds.indexOf(this.deletelines[0])));*/
        let originalPos = this.linesIds.indexOf(this.deletelines[0]);
        let desirePos = originalPos - 1;
        //console.log('Moving pos '+ originalPos + ' to desire pos '+desirePos);
        this.swapPositions(originalPos, desirePos, 'lines');
        this.swapPositions(originalPos, desirePos, 'id');
        //var modifiedIndex=this.linesIds.indexOf(event.currentTarget.dataset.id); 
        //this.modifiedList[modifiedIndex].alias=event.currentTarget.value;
    }

    handleMoveDown(){
        let originalPos = this.linesIds.indexOf(this.deletelines[0]);
        let desirePos = originalPos + 1;
        this.swapPositions(originalPos, desirePos, 'lines');
        this.swapPositions(originalPos, desirePos, 'id');
    }

    handleMoveBottom(){
        let originalPos = this.linesIds.indexOf(this.deletelines[0]);
        let desirePos = this.linesIds.length - 1;
        this.swapPositions(originalPos, desirePos, 'lines');
        this.swapPositions(originalPos, desirePos, 'id');

    }


    swapPositions(originalPos, desirePos, type) {
        if (desirePos == 0 || 
            desirePos >= this.modifiedList.length
        ) {
            throw new Error("Invalid positions provided");
        }
        
        if(type == 'id'){
            let tempId = this.linesIds[originalPos];
            this.linesIds[originalPos] = this.linesIds[desirePos];
            this.linesIds[desirePos] = tempId;
        } else{
            // Swap the elements at the originalPos and desirePos
            let temp = this.modifiedList[originalPos];
            this.modifiedList[originalPos] = this.modifiedList[desirePos];
            this.modifiedList[desirePos] = temp;
        }
    }

    calculateMontoTotal(){
        this.currencyCode = this.modifiedList[1]?.currencyCode || ''; 
        const sum = this.modifiedList.reduce((sum, item) => sum + (item.unitPrice * item.cantidad || 0), 0);
        this.montoTotal = Math.round(sum * 100) / 100;
    }

}